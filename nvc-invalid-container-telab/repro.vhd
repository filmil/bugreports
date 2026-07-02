-- Reproducer for: ** Fatal: (init): invalid container kind T_ELAB for NAHBIRQ
--
-- Distilled from GRLIB (grlib.amba package constant NAHBIRQ used in the port
-- subtype bounds of the ahbctrl component declaration; cf. issue #1537).
--
--   nvc --std=1993 -a repro.vhd
--   nvc --std=1993 -e tb
--
-- Crashes with --std=1993 and --std=2002.  Passes if any one of these holds:
--   * analyzed with --relaxed
--   * --std=2008
--   * NAHBIRQ's initializer is foldable at analysis time (e.g. plain "32",
--     or bare "CFG(0)" with no arithmetic around the indexed name)
--   * the component is declared in the instantiating architecture instead of
--     in a package
--   * direct entity instantiation is used instead of the component
--
-- The component generic default is one trigger; a component port whose array
-- bound or scalar range references NAHBIRQ crashes identically (that is how
-- GRLIB hits it: ahb_mst_in_type.hirq is std_logic_vector(NAHBIRQ-1 downto 0)
-- and ahbctrl is instantiated via the component declared in grlib.amba).

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
