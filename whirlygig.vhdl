----------------------------------------------------------------------------------
-- Company: Crash Barrier Ltd
-- Engineer: Andy Green
--
-- Create Date:    20:43:12 11/05/2007
-- Design Name: "whirlygig" Random number generator
-- Module Name:    whirlygig - Behavioral
-- Project Name: whirlygig
-- Target Devices:
-- Tool versions:
-- Description: Serial random number generator
--
-- Dependencies:
--
-- Revision: ZD - Added 'SAVE' attribute to the inverters
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity whirlygig is
	Port (
		pClock : in STD_LOGIC;
		pSerialOut : out std_logic_vector(7 downto 0)
	);

	constant cCountResultWidth : integer := 8;
	constant cCountInvsInRing :  integer := 3;

	constant cCountUnitsPool : integer := 16;
	constant cCountAddressBits : integer := 4;

	constant cCountAddressLatches : integer := (cCountResultWidth * cCountAddressBits);

	constant cCountUnits : integer := cCountUnitsPool + cCountAddressLatches + cCountResultWidth;


	constant cCountRingsPerBit : integer := 7;

end whirlygig;

architecture Behavioral of whirlygig is

	attribute keep : string;
	attribute S : string;

	signal sInv : std_logic_vector((cCountUnits * cCountInvsInRing) - 1 downto 0);
	signal sLatch : std_logic_vector(cCountUnits - 1 downto 0);
	signal sSerialOut : std_logic_vector(cCountResultWidth - 1 downto 0);
	signal ctr : std_logic_vector(3 downto 0); -- 7 24MHz clocks per sample
	signal flip : STD_LOGIC;

	attribute keep of sInv : signal is "true";
	attribute S of sInv : signal is "true";

begin


processRings: process(
 sInv
)
begin
	for i in 0 to cCountUnits - 1 loop
		sInv(i * cCountInvsInRing + 0) <= not sInv(i * cCountInvsInRing + cCountInvsInRing - 1);
		sInv(i * cCountInvsInRing + 1) <= not sInv(i * cCountInvsInRing);
		sInv(i * cCountInvsInRing + 2) <= not sInv(i * cCountInvsInRing + 1);
--		sInv(i * cCountInvsInRing + 3) <= not sInv(i * cCountInvsInRing + 2);
--		sInv(i * cCountInvsInRing + 4) <= not sInv(i * cCountInvsInRing + 3);
--		sInv(i * cCountInvsInRing + 5) <= not sInv(i * cCountInvsInRing + 4);
--		sInv(i * cCountInvsInRing + 6) <= not sInv(i * cCountInvsInRing + 5);
	end loop;
end process processRings;


processSample: process(
	pClock
)
   variable j: integer := 0;
begin
	if (pClock'EVENT and pClock = '1') then
		for i in 0 to (sLatch'LENGTH - 1) loop
			sLatch(i) <= sLatch((i - 1) mod (cCountUnits)) xor sInv(i * cCountInvsInRing + 1) xor flip;
		end loop;

		flip <= not flip;

		ctr <= ctr + 1;
		if (ctr = "1101") then
			ctr <= "0000";
			pSerialOut <= sSerialOut;
		end if;

		for i in 0 to (sSerialOut'LENGTH - 1) loop

			sSerialOut(i) <=  (
				sSerialOut(i) xor (sLatch( CONV_INTEGER(
				sLatch( cCountUnitsPool + i * cCountAddressBits + cCountAddressBits - 1 downto
					cCountUnitsPool + i * cCountAddressBits)) )));

		end loop;

	end if;
end process processSample;
end Behavioral;

