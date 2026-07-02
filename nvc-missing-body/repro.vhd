-- Minimal reproducer for an NVC elaboration crash:
--
--   ** Fatal: (init): missing body for WORK.CCTRL5NV.PA_MSB()I
--
-- Reduced from GRLIB's lib/gaisler/noelv/core/cctrl5nv.vhd (grlib-gpl-2025.2),
-- where the same pattern aborts elaboration of the NOEL-V subsystem with
-- "missing body for ...CCTRL5NV.PA_MSB()I".  GRLIB hits the identical bug in
-- grgpio.vhd (calc_nirqmux) and spictrlx.vhd (wlen, spip_bits).
--
-- Reproduce (any of --std=1993/2008, with or without --relaxed):
--
--   nvc -a nvc_missing_body_repro.vhd
--   nvc -e top_repro
--
-- All three of the following ingredients are required; removing any one of
-- them lets the design elaborate:
--
--   1. pa_msb: an architecture-level niladic function whose value depends on
--      a generic (globally static per instance);
--   2. ppn: an architecture-level constant whose subtype bound calls pa_msb,
--      with its attributes (ppn'length) referenced from inside a subprogram
--      (pte_cached below; note it is never called); and
--   3. any later declaration or statement that uses pa_msb in a globally
--      static expression (the signal s below).

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
