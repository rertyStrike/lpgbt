----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.08.2020 01:51:26
-- Design Name: 
-- Module Name: lpgbt_uplink_scrambler_60bitOrder58 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library xil_defaultlib;
use xil_defaultlib.lpgbtfpga_package.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lpgbt_uplink_scrambler_60bitOrder58 is
    GENERIC (
        INIT_SEED                         : in std_logic_vector(59 downto 0)    := x"8D52495FBA847AF"
    );
    PORT (
        -- Clocks & reset
        clk_i                             : in  std_logic;
        clkEn_i                           : in  std_logic;

        reset_i                           : in  std_logic;

        -- Data
        data_i                            : in  std_logic_vector(59 downto 0);
        data_o                            : out std_logic_vector(59 downto 0);

        -- Control
        bypass                            : in  std_logic
    );

end lpgbt_uplink_scrambler_60bitOrder58;

architecture Behavioral of lpgbt_uplink_scrambler_60bitOrder58 is
   
SIGNAL scrambledData        : std_logic_vector(59 downto 0);

BEGIN                 --========####   Architecture Body   ####========--
    -- Scrambler output register
    reg_proc: PROCESS(clk_i, reset_i)
    BEGIN
        IF rising_edge(clk_i) THEN
            IF reset_i = '1' THEN
                scrambledData    <= INIT_SEED;
            ELSIF clkEn_i = '1' THEN
                scrambledData(59 downto 58) <=  data_i(59 downto 58) xnor
                                                data_i(20 downto 19)  xnor
                                                data_i(1 downto 0)  xnor
                                                scrambledData(41  downto 40)  xnor
                                                scrambledData(3 downto 2);
                scrambledData(57 downto 39) <=  data_i(57 downto 39) xnor
                                                data_i(18 downto 0)  xnor
                                                scrambledData(39  downto 21)  xnor
                                                scrambledData(20 downto 2) xnor
                                                scrambledData(59  downto 41);
                                            
                scrambledData(38 downto 0)  <=  data_i(38 downto 0) xnor
                                                scrambledData(59  downto 21)  xnor
                                                scrambledData(40 downto 2);        
            END IF;
        END IF;
    END PROCESS;

    data_o    <= scrambledData WHEN bypass = '0' ELSE
                 data_i;

END behavioral;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--