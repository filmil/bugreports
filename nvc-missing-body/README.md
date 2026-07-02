# NVC bug report: "missing body" for architecture-level function used in globally static bounds

Draft bug report for https://github.com/nickg/nvc/issues — reproducer in
`repro.vhd` (same directory).

With `nvc` on `$PATH` (override via `make NVC=/path/to/nvc`):

```
make repro   # runs: nvc -a repro.vhd && nvc -e top_repro
             # fails with the bug's fatal error while the bug is present
make check   # exits 0 iff the bug reproduces (for scripting/CI)
make clean
```

## Title

Elaboration fails with "missing body for ...PA_MSB()I" when an uncalled
subprogram references a constant whose bound calls an architecture-level
function

## Version

Reproduced on current master, commit 55395b8db33e964bafcd1dbec71297bccbd09e0d
(2026-07-02): `nvc 1.22-devel (1.21.0.r68.g55395b8d) (Using LLVM 18.1.3)`,
built with `configure --with-llvm=/usr/bin/llvm-config-18 --disable-lto`.

Also reproduced on commit 324ed157094c6426bceb0db2594ea9ce07a1a1c7, and 1.18.x
fails with the same message on the originating GRLIB code. (1.19.0–1.21.0
instead fail there with "invalid container kind T_ELAB for NAHBIRQ", cf.
#1537, which is fixed on current master.)

## Steps to reproduce

```
nvc -a repro.vhd
nvc -e top_repro
```

Output (analysis succeeds silently; elaboration exits 1):

```
** Fatal: (init): missing body for WORK.TOP_REPRO.U0.PA_MSB()I
```

Elaborating the inner entity directly (`nvc -e cctrl5nv`) fails identically,
with the message naming the entity instead of the instance path:

```
** Fatal: (init): missing body for WORK.CCTRL5NV.PA_MSB()I
```

The failure is independent of the VHDL standard (1993 and 2008 tested) and of
`--relaxed`.

## Reproducer (30 lines, self-contained)

```vhdl
entity cctrl5nv is
  generic (
    riscv_mmu : integer := 1
    );
end;

architecture rtl of cctrl5nv is

  function pa_msb return integer is
  begin
    return riscv_mmu + 32;
  end;

  constant ppn : bit_vector(pa_msb downto 12) := (others => '0');

  -- Never called; its mere presence triggers the crash.
  function pte_cached return bit is
    variable paddr : bit_vector(ppn'length - 1 downto 0);
  begin
    return paddr(0);
  end;

  signal s : bit_vector(pa_msb + 1 downto 0);
begin
end;

entity top_repro is
end;

architecture tb of top_repro is
begin
  u0 : entity work.cctrl5nv generic map (riscv_mmu => 1);
end;
```

## Analysis

All three ingredients are required; removing any one of them lets the design
elaborate successfully:

1. `pa_msb` — an architecture-level **niladic function** whose result depends
   on a generic (globally static per instance, not locally static);
2. `ppn` — an architecture-level constant whose subtype bound calls `pa_msb`,
   with an attribute of it (`ppn'length`) referenced **inside a subprogram**
   (`pte_cached`); the subprogram is never called, its declaration alone is
   sufficient;
3. a later declaration whose subtype bound uses `pa_msb` in a globally static
   expression (`signal s`).

Notably, substituting the direct call `pa_msb` for `ppn'length` inside
`pte_cached` (bypassing the constant) makes the crash disappear, as does
moving the body of `pa_msb` into a constant
(`constant pa_msb : integer := riscv_mmu + 32;`).

## Real-world impact

This aborts elaboration of the GRLIB (grlib-gpl-2025.2) NOEL-V subsystem
`gaisler.noelvsys`:

```
** Fatal: (init): missing body for ...CCTRL5NV.PA_MSB()I
```

`lib/gaisler/noelv/core/cctrl5nv.vhd` declares niladic wrapper functions
(`pa_msb`, `va_msb`, `ga_msb`, `gpa_msb`, `gva_msb`) that are used pervasively
in constant/subtype bounds and inside the process-local subprograms of its 9k
line FSM process. The same pattern exists in `lib/gaisler/misc/grgpio.vhd`
(`calc_nirqmux`) and `lib/gaisler/spi/spictrlx.vhd` (`wlen`, `spip_bits`).

With the wrapper functions converted to constants in the GRLIB source (a
behavior-preserving workaround), the full NOEL-V subsystem elaborates and
simulates correctly on unpatched nvc at the version above.
