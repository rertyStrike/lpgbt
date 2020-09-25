----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.08.2020 01:51:26
-- Design Name: 
-- Module Name: lpgbt_uplink_descrambler_53bitOrder49 - Behavioral
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

entity lpgbt_uplink_descrambler_53bitOrder49 is
   PORT (
     -- Clocks & reset
     clk_i                             : in  std_logic;
     clkEn_i                           : in  std_logic;

     reset_i                           : in  std_logic;

     -- Data
     data_i                            : in  std_logic_vector(52 downto 0);
     data_o                            : out std_logic_vector(52 downto 0);

     -- Control
     bypass                            : in  std_logic
);
end lpgbt_uplink_descrambler_53bitOrder49;


--! @brief descrambler53bitOrder49 ARCHITECTURE - 53bit Order 49 descrambler
architecture Behavioral of lpgbt_uplink_descrambler_53bitOrder49 is

    SIGNAL memory_register        : std_logic_vector(52 downto 0);
    SIGNAL descrambledData        : std_logic_vector(52 downto 0);

BEGIN                 --========####   Architecture Body   ####========--

    -- Scrambler output register
    reg_proc: PROCESS(clk_i, reset_i)
    BEGIN

        IF rising_edge(clk_i) THEN
            IF reset_i = '1' THEN
                descrambledData  <= (OTHERS => '0');
                memory_register  <= (OTHERS => '0');

            ELSIF clkEn_i = '1' THEN
                memory_register               <=  data_i;

                descrambledData(52 downto 49) <=  data_i(52 downto 49) xnor data_i(12 downto 9) xnor data_i(3 downto 0);
                descrambledData(48 downto 40) <=  data_i(48 downto 40) xnor data_i(8 downto 0) xnor memory_register(52 downto 44);
                descrambledData(39 downto 0)  <=  data_i(39 downto 0)  xnor memory_register(52 downto 13) xnor memory_register(43 downto 4);

            END IF;

        END IF;

    END PROCESS;

    data_o    <= descrambledData WHEN bypass = '0' ELSE
                 data_i;

END behavioral;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--