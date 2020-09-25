----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.08.2020 23:41:00
-- Design Name: 
-- Module Name: lpgbt_uplink_scrambler - Behavioral
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

--! Include the lpGBT-FPGA specific package
library xil_defaultlib;
use xil_defaultlib.lpgbtfpga_package.all;

--! @brief lpgbt_uplink_scrambler - Uplink descrambler
--! @details
--! The lpgbt_uplink_scrambler module restores the scrambled data using the algorithm specified
--! by the lpGBT.
ENTITY lpgbt_uplink_scrambler IS
   GENERIC(
        FEC                             : integer RANGE 0 to 2                  --! FEC selection can be: FEC5 or FEC12
   );
   PORT (
        -- Clock and reset
        clk_i                           : in  std_logic;                        --! Input clock USEd to decode the received data
        clkEn_i                         : in  std_logic;                        --! Clock enable USEd WHEN the input clock is different from 40MHz

        reset_i                         : in  std_logic;                        --! Uplink datapath's reset SIGNAL

        -- Data
        fec5_data_i                     : in  std_logic_vector(233 downto 0);   --! FEC5 User data input from decoder (scrambled)
        fec12_data_i                    : in  std_logic_vector(205 downto 0);   --! FEC12 User data input from decoder (scrambled)

        fec5_data_o                     : out std_logic_vector(233 downto 0);   --! FEC5 User data output (descrambled)
        fec12_data_o                    : out std_logic_vector(205 downto 0);   --! FEC12 User data output (descrambled)

        -- Control
        bypass                          : in  std_logic                         --! Bypass uplink scrambler (test purpose only)
   );
END lpgbt_uplink_scrambler;

--! @brief lpgbt_uplink_scrambler - Uplink Scrambler
--! @details The lpgbt_uplink_scrambler ARCHITECTURE instantiates 58bit and 51bit descramblers to descrambles the
--! data for all of the available configuration: FEC5 / FEC12 and DATARATE_5G12 / DATARATE_10G24
ARCHITECTURE behavioral OF lpgbt_uplink_scrambler IS


    -- Components declaration
    COMPONENT lpgbt_uplink_scrambler_60bitOrder58
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
    END COMPONENT;

    COMPONENT lpgbt_uplink_scrambler_58bitOrder58
       GENERIC (
            INIT_SEED                         : in std_logic_vector(57 downto 0)    := "01" & x"A52495FBA847AF"
        );
       PORT (
            -- Clocks & reset
            clk_i                             : in  std_logic;
            clkEn_i                           : in  std_logic;

            reset_i                           : in  std_logic;

            -- Data
            data_i                            : in  std_logic_vector(57 downto 0);
            data_o                            : out std_logic_vector(57 downto 0);

            -- Control
            bypass                            : in  std_logic
       );
    END COMPONENT;

    COMPONENT lpgbt_uplink_scrambler_51bitOrder49
       GENERIC (
            INIT_SEED                         : in std_logic_vector(50 downto 0)    := "101" & x"2495FBA847AF"
        );
       PORT (
            -- Clocks & reset
            clk_i                             : in  std_logic;
            clkEn_i                           : in  std_logic;

            reset_i                           : in  std_logic;

            -- Data
            data_i                            : in  std_logic_vector(50 downto 0);
            data_o                            : out std_logic_vector(50 downto 0);

            -- Control
            bypass                            : in  std_logic
       );
    END COMPONENT;

    COMPONENT lpgbt_uplink_scrambler_53bitOrder49
       GENERIC (
            INIT_SEED                         : in std_logic_vector(52 downto 0)    := "0" & x"52495FBA847AF"
       );
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
    END COMPONENT;

BEGIN                 --========####   Architecture Body   ####========--

    fec5_gen: IF FEC = FEC5 GENERATE

        -- 5.12Gbps and 10.24Gbps
        lpgbt_uplink_scrambler_58bitOrder58_l0_inst: lpgbt_uplink_scrambler_58bitOrder58
           PORT MAP (
                -- Clocks & reset
                clk_i                             => clk_i,
                clkEn_i                           => clkEn_i,

                reset_i                           => reset_i,

                -- Data
                data_i                            => fec5_data_i(57 downto 0),
                data_o                            => fec5_data_o(57 downto 0),

                -- Control
                bypass                            => bypass
           );

        lpgbt_uplink_scrambler_58bitOrder58_l1_inst: lpgbt_uplink_scrambler_58bitOrder58
           PORT MAP (
                -- Clocks & reset
                clk_i                             => clk_i,
                clkEn_i                           => clkEn_i,

                reset_i                           => reset_i,

                -- Data
                data_i                            => fec5_data_i(115 downto 58),
                data_o                            => fec5_data_o(115 downto 58),

                -- Control
                bypass                            => bypass
           );

        -- 10.24Gbps only
        lpgbt_uplink_scrambler_58bitOrder58_h0_inst: lpgbt_uplink_scrambler_58bitOrder58
           PORT MAP (
                -- Clocks & reset
                clk_i                             => clk_i,
                clkEn_i                           => clkEn_i,

                reset_i                           => reset_i,

                -- Data
                data_i                            => fec5_data_i(173 downto 116),
                data_o                            => fec5_data_o(173 downto 116),

                -- Control
                bypass                            => bypass
           );

        lpgbt_uplink_scrambler_60bitOrder58_h1_inst: lpgbt_uplink_scrambler_60bitOrder58
           PORT MAP (
                -- Clocks & reset
                clk_i                             => clk_i,
                clkEn_i                           => clkEn_i,

                reset_i                           => reset_i,

                -- Data
                data_i                            => fec5_data_i(233 downto 174),
                data_o                            => fec5_data_o(233 downto 174),

                -- Control
                bypass                            => bypass
           );

    END GENERATE;

    fec12_gen: IF FEC = FEC12 GENERATE

        -- 5.12Gbps and 10.24Gbps
        lpgbt_uplink_scrambler_51bitOrder49_l0_inst: lpgbt_uplink_scrambler_51bitOrder49
           PORT MAP (
                -- Clocks & reset
                clk_i                             => clk_i,
                clkEn_i                           => clkEn_i,

                reset_i                           => reset_i,

                -- Data
                data_i                            => fec12_data_i(50 downto 0),
                data_o                            => fec12_data_o(50 downto 0),

                -- Control
                bypass                            => bypass
           );

        lpgbt_uplink_scrambler_51bitOrder49_l1_inst: lpgbt_uplink_scrambler_51bitOrder49
           PORT MAP (
                -- Clocks & reset
                clk_i                             => clk_i,
                clkEn_i                           => clkEn_i,

                reset_i                           => reset_i,

                -- Data
                data_i                            => fec12_data_i(101 downto 51),
                data_o                            => fec12_data_o(101 downto 51),

                -- Control
                bypass                            => bypass
           );

        -- 10.24Gbps only
        lpgbt_uplink_scrambler_51bitOrder49_h0_inst: lpgbt_uplink_scrambler_51bitOrder49
           PORT MAP (
                -- Clocks & reset
                clk_i                             => clk_i,
                clkEn_i                           => clkEn_i,

                reset_i                           => reset_i,

                -- Data
                data_i                            => fec12_data_i(152 downto 102),
                data_o                            => fec12_data_o(152 downto 102),

                -- Control
                bypass                            => bypass
           );

        lpgbt_uplink_scrambler_53bitOrder49_h1_inst: lpgbt_uplink_scrambler_53bitOrder49
           PORT MAP (
                -- Clocks & reset
                clk_i                             => clk_i,
                clkEn_i                           => clkEn_i,

                reset_i                           => reset_i,

                -- Data
                data_i                            => fec12_data_i(205 downto 153),
                data_o                            => fec12_data_o(205 downto 153),

                -- Control
                bypass                            => bypass
           );

    END GENERATE;

END behavioral;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--