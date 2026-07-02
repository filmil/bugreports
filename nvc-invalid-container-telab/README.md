# NVC bug report: "invalid container kind T_ELAB" for package constant referenced from a component declaration

Draft bug report for https://github.com/nickg/nvc/issues — reproducer in
`repro.vhd` (same directory).

With `nvc` on `$PATH` (override via `make NVC=/path/to/nvc`):

```
make repro   # runs: nvc --std=1993 -a repro.vhd && nvc --std=1993 -e tb
             # fails with the bug's fatal error while the bug is present
make check   # exits 0 iff the bug reproduces (for scripting/CI)
make clean
```

## Title

Elaboration crashes with "invalid container kind T_ELAB" when a package-hosted
component declaration references an analysis-time-unfoldable package constant
(VHDL-93/2002, strict)

## Version

Reproduced on current master, commit 55395b8db33e964bafcd1dbec71297bccbd09e0d
(2026-07-02): `nvc 1.22-devel (1.21.0.r68.g55395b8d) (Using LLVM 18.1.3)`, and
on commit 324ed157094c6426bceb0db2594ea9ce07a1a1c7. Same fatal message as
historical issue #1537 (fixed for its 1.21-era trigger); this is a still-live
variant.

## Steps to reproduce

```
nvc --std=1993 -a repro.vhd
nvc --std=1993 -e tb
```

Output (analysis succeeds; elaboration dies with a stack trace and a "Please
report this bug" banner):

```
** Fatal: (init): invalid container kind T_ELAB for NAHBIRQ
```

## Reproducer (self-contained, 4 small design units)

```vhdl
package pkg is
  type int_array is array (0 to 0) of integer;
  constant CFG : int_array := (others => 0);
  -- Indexed name => not locally static in VHDL-93/2002, so strict analysis
  -- leaves NAHBIRQ unfolded in the package.
  constant NAHBIRQ : integer := CFG(0) + 32;
  component duv is
    generic ( g : integer := NAHBIRQ );
  end component;
end package;

entity duv is
  generic ( g : integer );
end;

architecture rtl of duv is
begin
end;

use work.pkg.all;

entity tb is
end entity;

architecture behav of tb is
begin
  u: duv;  -- component instantiation, default binding
end architecture;
```

## Analysis

All four ingredients are required; each was verified with a passing negative
control:

1. A package constant whose initializer is a **compound expression containing
   an indexed name of another constant** (`CFG(0) + 32`). Indexed names are
   not locally static in VHDL-93/2002, so strict analysis leaves `NAHBIRQ`
   unfolded in the package. Plain `32` folds and passes; notably, a bare
   `CFG(0)` with no surrounding arithmetic also passes. The aggregate-choice
   style of `CFG` (named, positional, `others`) is irrelevant.
2. A **component declaration in a package** referencing that constant. Generic
   default, array port bound (`bit_vector(NAHBIRQ-1 downto 0)`), and scalar
   port range (`integer range 0 to NAHBIRQ`) all crash identically. The same
   component declared in the instantiating architecture passes.
3. A **component instantiation** (default binding or explicit configuration
   specification). Direct entity instantiation passes; elaborating the entity
   as top level passes. Only the component declaration matters — the bound
   entity can use literal bounds and the port/generic can be left open.
4. **Strict analysis with --std=1993 or --std=2002.** Analyzing with
   `--relaxed` passes (the constant folds at analysis time), and `--std=2008`
   or the default standard passes (2008 locally-static rules).

Likely mechanism: when elaborating the component binding, NVC re-evaluates the
component declaration's generic defaults / port subtype bounds; the evaluation
reaches the unfolded package constant but resolves its container relative to
the elaboration root (T_ELAB) instead of the constant's home package, tripping
the "invalid container kind" assertion during (init).

## Real-world impact

GRLIB (grlib-gpl-2025.2) analyzed without `--relaxed` cannot elaborate any
design containing an AHB bus: `grlib.amba` declares
`constant NAHBIRQ : integer := 32 + 32*GRLIB_CONFIG_ARRAY(grlib_amba_inc_nirq);`
and a component `ahbctrl` whose port record fields are bound by it
(`hirq : std_logic_vector(NAHBIRQ-1 downto 0)`), and every GRLIB design
instantiates `ahbctrl` via that component:

```
** Fatal: (init): invalid container kind T_ELAB for NAHBIRQ
```

Analyzing the libraries with `--relaxed` avoids the crash.
