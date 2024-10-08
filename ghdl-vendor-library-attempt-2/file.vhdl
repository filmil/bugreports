library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all;

entity demo is
		port (
		i, ib: in std_logic;
		o: out std_logic

);
end entity;

architecture demo of demo is

    component ibufds is
    generic(
        DIFF_TERM: boolean := true;
        IOSTANDARD: string
    );
    port(
        i: in std_logic;
        ib: in std_logic;
        o: out std_logic
    );
    end component;

begin

	c: ibufds
	generic map (
	    diff_term =>  true,
	    iostandard => "LVDS25"
    )
	port map (
		i => i,
		ib => ib,
		o => o
	);
end architecture;

