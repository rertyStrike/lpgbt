----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.08.2020 14:19:19
-- Design Name: 
-- Module Name: lpgbt_downlink_descrambler - Behavioral
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

--! Include the IEEE VHDL standard LIBRARY
LIBRARY ieee;
USE ieee.std_logic_1164.all;
library xil_defaultlib;
use xil_defaultlib.lpgbtfpga_package.all;

--! @brief descrambler58bitOrder58 - 58bit Order 58 descrambler
ENTITY lpgbt_downlink_descrambler IS
   PORT (
        -- Clocks & reset
        clk_i                             : in  std_logic;
        clkEn_i                           : in  std_logic;

        reset_i                           : in  std_logic;

        -- Data
        data_i                            : in  std_logic_vector(35 downto 0);
        data_o                            : out std_logic_vector(35 downto 0);

        -- Control
        bypass                            : in  std_logic
   );
END lpgbt_downlink_descrambler;

--! @brief descrambler36bitOrder36 ARCHITECTURE - 36bit Order 36 descrambler
ARCHITECTURE behavioral of lpgbt_downlink_descrambler IS

    SIGNAL memory_register        : std_logic_vector(35 downto 0);
    SIGNAL descrambledData        : std_logic_vector(35 downto 0);

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

                descrambledData(35 downto 25) <=    data_i(35 downto 25) xnor 
                                                    data_i(10 downto 0) xnor 
                                                    memory_register(35 downto 25);
                
                descrambledData(24 downto 0)  <=    data_i(24 downto 0)  xnor 
                                                    memory_register(35 downto 11) xnor 
                                                    memory_register(24 downto 0);

            END IF;

        END IF;

    END PROCESS;

    data_o    <= descrambledData WHEN bypass = '0' ELSE
                 data_i;

END behavioral;