-------------------------------------------------------
-- Author: Zach Davis
-- Based on work by: Jack Gasset @ Gadget Factory
--                   Andy Green @ Crash Barrier Ltd
-- 
-- Create Date:    17:28:46 05/20/2012 
-- Design Name: 
-- Module Name:    whirlyfly - Behavioral 
-- Project Name: whirlyfly
-- Target Devices: Papilio One 500K
-- Description: Random number generator 
--              with serial output.
--
-- Dependencies: Whirlygig rng core: whirlygig.vhd
--               Xilinx uart: bbfifo_16x8.vhd,
--                            kcuartx.vhd,
--                            uart_tx.vhd
--               Papilio ucf: BPC3003_2.03+.ucf
--
--
-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity whirlyfly is
  Port ( extclk : in  STD_LOGIC;
         tx     : out  STD_LOGIC);
end whirlyfly;

architecture Behavioral of whirlyfly is

-- Uart related stuff
  component uart_tx is
    port ( data_in : in std_logic_vector(7 downto 0);
           write_buffer : in std_logic;
           reset_buffer : in std_logic;
           en_16_x_baud : in std_logic;
           serial_out : out std_logic;
           buffer_full : out std_logic;
           buffer_half_full : out std_logic;
           clk : in std_logic);
  end component; 
  
  COMPONENT dcm32to96
    PORT(
      CLKIN_IN : IN std_logic;          
      CLKFX_OUT : OUT std_logic;
      CLKIN_IBUFG_OUT : OUT std_logic;
      CLK0_OUT : OUT std_logic
      );
  END COMPONENT;	

-- RNG component
  component whirlygig
	port(
      pClock : in STD_LOGIC;
      pSerialOut : out std_logic_vector(7 downto 0)
      );
  end component;
  
-- intermediat signals
  signal data_present : std_logic;
  signal dout : std_logic_vector(7 downto 0);
  signal en_16_x_baud, clk : STD_LOGIC;
  signal baud_count : integer range 0 to 5 :=0;
  signal sample_clk_cnt : integer := 0;

begin

  Inst_whirlygig: whirlygig port map(
	pClock => clk,
	pSerialOut => dout
    );

  Inst_dcm32to96: dcm32to96 PORT MAP(
    CLKIN_IN => extclk,
    CLKFX_OUT => clk,
    CLKIN_IBUFG_OUT => open,
    CLK0_OUT => open
    );		
  
  INST_UART_TX : uart_tx
    port map (
      data_in => dout,
      write_buffer => data_present,
      reset_buffer => '0',
      en_16_x_baud => en_16_x_baud,
      clk => clk,
      serial_out => tx,
      buffer_half_full => open,
      buffer_full => open
      );

  baud_timer: process(clk)
  begin
    if clk'event and clk='1' then
      if baud_count=1 then
        baud_count <= 0;
        en_16_x_baud <= '1';
      else
        baud_count <= baud_count + 1;
        en_16_x_baud <= '0';
      end if;
    end if;
  end process baud_timer;

-- create a clock that determines the sample
-- rate of the generator
  sample_clk_proc : process(clk)
  begin
    if rising_edge(clk) then
      if( sample_clk_cnt = 512 ) then
            sample_clk_cnt <= 0;
            data_present <= '1';
        else
            sample_clk_cnt <= sample_clk_cnt + 1;
            data_present <= '0';
      end if;
    end if;
    end process sample_clk_proc;
  
end Behavioral;

