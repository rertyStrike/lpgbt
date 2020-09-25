----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.08.2020 00:40:26
-- Design Name: 
-- Module Name: lpgbtfpga_downlink_enc - Behavioral
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

--! @brief lpgbtfpga_downlink - Downlink wrapper (top level)
--! @details
--! The lpgbtfpga_downlink module implements the logic required
--! for the data encoding as required by the lpGBT for the downlink
--! path (Back-END to Front-END) and split the frame to be compliant
--! with the transceiver interface.
entity lpgbtfpga_downlink_enc is
   GENERIC(
        -- Expert parameters
        c_multicyleDelay              : integer RANGE 0 to 7 := 3;                          --! Multicycle delay: USEd to relax the timing constraints
        c_clockRatio                  : integer := 8;                                       --! Clock ratio is clock_out / 40 (shall be an integer - E.g.: 320/40 = 8)
        c_outputWidth                 : integer                                             --! Transceiver's word size
    );
    
    PORT (
        -- Clocks
        clk_i                         : in  std_logic;                                      --! Downlink datapath clock (either 320 or 40MHz)
        clkEn_i                       : in  std_logic;                                      --! Clock enable (1 over 8 WHEN encoding runs @ 320Mhz, '1' @ 40MHz)
        rst_n_i                       : in  std_logic;                                      --! Downlink reset SIGNAL (Tx ready from the transceiver)

        -- Down link
        USErData_i                    : in  std_logic_vector(31 downto 0);                  --! Downlink data (USEr)
        ECData_i                      : in  std_logic_vector(1 downto 0);                   --! Downlink EC field
        ICData_i                      : in  std_logic_vector(1 downto 0);                   --! Downlink IC field

        -- Output
        --mgt_word_o                    : out std_logic_vector((c_outputWidth-1) downto 0);   --! Downlink encoded frame (IC + EC + User Data + FEC)
        encodedFrame_o                : out std_logic_vector(63 downto 0);                    --! Downlink encoded frame (IC + EC + User Data + FEC)
        -- Configuration
        interleaverBypass_i           : in  std_logic;                                      --! Bypass downlink interleaver (test purpose only)
        encoderBypass_i               : in  std_logic;                                      --! Bypass downlink FEC (test purpose only)
        scramblerBypass_i             : in  std_logic;                                      --! Bypass downlink scrambler (test purpose only)

        -- Status
        rdy_o                         : out std_logic                                       --! Downlink ready status
    );
    
end lpgbtfpga_downlink_enc;

--! @brief lpgbtfpga_downlink - Downlink wrapper (top level)
--! @details
--! The lpgbtfpga_downlink module scrambles, encodes and interleaves the data to provide
--! the encoded bus USEd in the downlink communication with an LpGBT device. The output
--! bus, which is made of 64 bits running at the LHC clock (about 40MHz) is encoded using
--! a Reed-Solomon scheme and shall be sent using a serial link configured at 2.56Gbps.
architecture Behavioral of lpgbtfpga_downlink_enc is

    --! Scrambler module used for the downlink encoding
    COMPONENT lpgbt_downlink_scrambler
       GENERIC (
            INIT_SEED                 : in std_logic_vector(35 downto 0)    := x"1fba847af"
       );
       PORT (
            -- Clocks & reset
            clk_i                     : in  std_logic;
            clkEn_i                   : in  std_logic;

            reset_i                   : in  std_logic;

            -- Data
            data_i                    : in  std_logic_vector(35 downto 0);
            data_o                    : out std_logic_vector(35 downto 0);

            -- Control
            bypass                    : in  std_logic
       );
    END COMPONENT;

    --! FEC calculator used for the downlink encoding
    COMPONENT lpgbt_downlink_encoder IS
       PORT (
            -- Data
            data_i                    : in  std_logic_vector(35 downto 0);
            FEC_o                     : out std_logic_vector(23 downto 0);

            -- Control
            bypass                    : in  std_logic
       );
    END COMPONENT;

    --! Interleaver used to improve the decoding efficiency
    COMPONENT lpgbt_downlink_interleaver IS
       GENERIC(
            HEADER_c                  : in  std_logic_vector(3 downto 0)
       );
       PORT (
            -- Data
            data_i                    : in  std_logic_vector(35 downto 0);
            FEC_i                     : in  std_logic_vector(23 downto 0);

            data_o                    : out std_logic_vector(63 downto 0);

            -- Control
            bypass                    : in  std_logic
       );
    END COMPONENT;

--    COMPONENT lpgbtfpga_txGearbox
--        GENERIC (
--            c_clockRatio                  : integer;                                                --! Clock ratio is clock_out / clock_in (shall be an integer)
--            c_inputWidth                  : integer;                                                --! Bus size of the input word
--            c_outputWidth                 : integer                                                 --! Bus size of the output word (Warning: c_clockRatio/(c_inputWidth/c_outputWidth) shall be an integer)
--        );
--        PORT (
--            -- Clock and reset
--            clk_inClk_i                   : in  std_logic;                                          --! Input clock (frame clock)
--            clk_clkEn_i                   : in  std_logic;                                          --! Input clock enable WHEN multicycle path or '1'
--            clk_outClk_i                  : in  std_logic;                                          --! Output clock (from the MGT)

--            rst_gearbox_i                 : in  std_logic;                                          --! Reset SIGNAL

--            -- Data
--            dat_inFrame_i                 : in  std_logic_vector((c_inputWidth-1) downto 0);        --! Input data
--            dat_outFrame_o                : out std_logic_vector((c_outputWidth-1) downto 0);       --! Output data

--            -- Status
--            sta_gbRdy_o                   : out std_logic                                           --! Ready SIGNAL
--        );
--    END COMPONENT;

    SIGNAL rst_s              : std_logic;
    SIGNAL gbRst_s            : std_logic;
    SIGNAL gbRdy_s            : std_logic;
    --SIGNAL encodedFrame_s     : std_logic_vector(63 downto 0);

    SIGNAL inputData_s        : std_logic_vector(35 downto 0);      --! Data bus made of IC + EC + User Data (USEd to input the scrambler)
    SIGNAL scrambledData_s    : std_logic_vector(35 downto 0);      --! Scrambled data
    SIGNAL FECData_s          : std_logic_vector(23 downto 0);      --! FEC bus
    SIGNAL clkOutEn_s         : std_logic;
    SIGNAL rst_synch_s        : std_logic;
BEGIN                 --========####   Architecture Body   ####========-

    --rst_s          <= not(gbRdy_s);
    rst_s          <= not(rst_n_i);
    gbRst_s        <= not(rst_n_i);

    --! Multicycle path configuration
    syncShiftReg_proc: PROCESS(rst_s, clk_i)
        VARIABLE cnter  : integer RANGE 0 TO 7;
    BEGIN

        IF rst_s = '1' THEN
              cnter              := 0;
              clkOutEn_s         <= '0';
              rst_synch_s        <= '0';

        ELSIF rising_edge(clk_i) THEN
            IF clkEn_i = '1' THEN
                cnter                 := 0;
                rst_synch_s           <= '1';
            ELSIF rst_synch_s = '1' THEN
                cnter                 := cnter + 1;
            END IF;

            clkOutEn_s                <= '0';
            IF cnter = c_multicyleDelay THEN
                clkOutEn_s            <= '1';
            END IF;
        END IF;
    END PROCESS;

    inputData_s(31 downto 0)    <= USErData_i;
    inputData_s(33 downto 32)   <= ECData_i;
    inputData_s(35 downto 34)   <= ICData_i;

    --! Scrambler module USEd for the downlink encoding
    lpgbt_downlink_scrambler_inst: lpgbt_downlink_scrambler
        PORT MAP (
            clk_i                => clk_i,
            --clkEn_i              => clkOutEn_s,
            clkEn_i              => '1',
            
            reset_i              => rst_s,

            data_i               => inputData_s,
            data_o               => scrambledData_s,

            bypass               => scramblerBypass_i
        );

    --! FEC calculator USEd for the downlink encoding
    lpgbt_downlink_encoder_inst: lpgbt_downlink_encoder
        PORT MAP (
            -- Data
            data_i               => scrambledData_s,
            FEC_o                => FECData_s,

            -- Control
            bypass               => encoderBypass_i
        );

    --! Interleaver USEd to improve the decoding efficiency
    lpgbt_downlink_interleaver_inst: lpgbt_downlink_interleaver
        GENERIC MAP (
            HEADER_c             => "1001"
        )
        PORT MAP (
            -- Data
            data_i               => scrambledData_s,
            FEC_i                => FECData_s,

            data_o               => encodedFrame_o,

            -- Control
            bypass               => interleaverBypass_i
        );

    rdy_o      <= rst_synch_s;

--    --! Bridge between frame word and MGT word
--    lpgbtfpga_txGearbox_inst: lpgbtfpga_txGearbox
--        GENERIC MAP(
--            c_clockRatio                  => c_clockRatio,
--            c_inputWidth                  => 64,
--            c_outputWidth                 => c_outputWidth
--        )
--        PORT MAP(
--            -- Clock and reset
--            clk_inClk_i                   => clk_i,
--            clk_clkEn_i                   => clkEn_i,
--            clk_outClk_i                  => clk_i,

--            rst_gearbox_i                 => gbRst_s,

--            -- Data
--            dat_inFrame_i                 => encodedFrame_s,
--            dat_outFrame_o                => mgt_word_o,
--            dat_outFrame_o                => "0",

--            -- Status
--            sta_gbRdy_o                   => gbRdy_s
--        );
END behavioral;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--
