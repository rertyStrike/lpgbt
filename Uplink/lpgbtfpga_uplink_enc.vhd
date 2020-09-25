----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.08.2020 19:15:46
-- Design Name: 
-- Module Name: lpgbtfpga_uplink_enc - Behavioral
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

--! @brief lpgbtfpga_uplink_enc - Uplink wrapper (top level)
--! @details
--! The lpgbtfpga_uplink_enc wrapper implements the logic required
--! for the frame alignement, the frame construction and the
--! decoding/descrambling of the data.
ENTITY lpgbtfpga_uplink_enc IS
   GENERIC(
        -- General configuration
        DATARATE                        : integer RANGE 0 to 2;                               --! Datarate selection can be: DATARATE_10G24 or DATARATE_5G12
        FEC                             : integer RANGE 0 to 2;                               --! FEC selection can be: FEC5 or FEC12

        -- Expert parameters
        c_multicyleDelay                : integer RANGE 0 to 7 := 3                          --! Multicycle delay: USEd to relax the timing constraints
--        c_clockRatio                    : integer;                                            --! Clock ratio is mgt_USErclk / 40 (shall be an integer)
--        c_mgtWordWidth                  : integer;                                            --! Bus size of the input word
--        c_allowedFalseHeader            : integer;                                            --! Number of false header allowed to avoid unlock on frame error
--        c_allowedFalseHeaderOverN       : integer;                                            --! Number of header checked to know wether the lock is lost or not
--        c_requiredTrueHeader            : integer;                                            --! Number of true header required to go in locked state
--        c_bitslip_mindly                : integer := 1;                                       --! Number of clock cycle required WHEN asserting the bitslip SIGNAL
--        c_bitslip_waitdly               : integer := 40                                       --! Number of clock cycle required before being back in a stable state
   );
   PORT (
        -- Clock and reset
--        clk_freeRunningClk_i            : in  std_logic;
        uplinkClk_i                     : in  std_logic;                                      --! Input clock (Rx USEr clock from transceiver)
        uplinkClkOutEn_o                : out std_logic;                                      --! Clock enable to be USEd in the USEr's logic
        uplinkRst_n_i                   : in  std_logic;                                      --! Uplink reset SIGNAL (Rx ready from the transceiver)

        -- Input
--        mgt_word_o                      : in  std_logic_vector((c_mgtWordWidth-1) downto 0);  --! Input frame coming from the MGT
--        word_o                           : out  std_logic_vector((c_mgtWordWidth-1) downto 0);  --! Input frame coming from the MGT
        word_o                          : out  std_logic_vector(255 downto 0);
        -- Data
        USErData_i                      : in std_logic_vector(229 downto 0);                 --! User output (decoded data). The payload size varies depENDing on the
                                                                                                    --! datarate/FEC configuration:
                                                                                                    --!     * *FEC5 / 5.12 Gbps*: 112bit
                                                                                                    --!     * *FEC12 / 5.12 Gbps*: 98bit
                                                                                                    --!     * *FEC5 / 10.24 Gbps*: 230bit
                                                                                                    --!     * *FEC12 / 10.24 Gbps*: 202bit
        EcData_i                        : in std_logic_vector(1 downto 0);                   --! EC field value received from the LpGBT
        IcData_i                        : in std_logic_vector(1 downto 0);                   --! IC field value received from the LpGBT

        -- Control
        bypassInterleaver_i             : in  std_logic;                                      --! Bypass uplink interleaver (test purpose only)
        bypassFECEncoder_i              : in  std_logic;                                      --! Bypass uplink FEC (test purpose only)
        bypassScrambler_i               : in  std_logic;                                      --! Bypass uplink scrambler (test purpose only)

        -- Transceiver control
        --mgt_bitslipCtrl_o               : out std_logic;                                      --! Control the Bitslib/RxSlide PORT of the Mgt

        -- Status
--        dataCorrected_o                 : out std_logic_vector(229 downto 0);                 --! Flag allowing to know which bit(s) were toggled by the FEC
--        IcCorrected_o                   : out std_logic_vector(1 downto 0);                   --! Flag allowing to know which bit(s) of the IC field were toggled by the FEC
--        EcCorrected_o                   : out std_logic_vector(1 downto 0);                   --! Flag allowing to know which bit(s) of the EC field  were toggled by the FEC
        rdy_o                           : out std_logic                                       --! Ready SIGNAL from the uplink decoder
   );
END lpgbtfpga_uplink_enc;

--! @brief lpgbtfpga_uplink_enc - Uplink wrapper (top level)
--! @details
--! The lpgbtfpga_uplink_enc module receives the data from the transceiver
--! and decode them to GENERATE the USEr frame. It supPORTs the 4
--! following configurations:
--!     * *(FEC5 / 5.12 Gbps)*: User data output is 112bit (can correct up to 5 consecutives bits)
--!     * *(FEC12 / 5.12 Gbps)*: User data output is 98bit (can correct up to 12 consecutives bits)
--!     * *(FEC5 / 10.24 Gbps)*: User data output is 230bit (can correct up to 10 consecutives bits)
--!     * *(FEC12 / 10.24 Gbps)*: User data output is 202bit (can correct up to 24 consecutives bits)
ARCHITECTURE behavioral OF lpgbtfpga_uplink_enc IS

--    COMPONENT lpgbtfpga_framealigner
--        GENERIC (
--            c_wordRatio                      : integer;             --! Word ration: frameclock / mgt_wordclock
--            c_wordSize                       : integer;             --! Size of the mgt word
--            c_headerPattern                  : std_logic_vector;    --! Header pattern specIFied by the standard
--            c_allowedFalseHeader             : integer;             --! Number of false header allowed to avoid unlock on frame error
--            c_allowedFalseHeaderOverN        : integer;             --! Number of header checked to know wether the lock is lost or not
--            c_requiredTrueHeader             : integer;             --! Number of true header required to go in locked state

--            c_resetOnEven                    : integer := 0;        --! Reset on even bitslip (1: Enabled/ 0: disabled)
--            c_resetDuration                  : integer := 10;       --! Reset duration (in clk_freeRunningClk_i periods)
--            c_bitslip_mindly                 : integer := 1;        --! Number of clock cycle required WHEN asserting the bitslip SIGNAL
--            c_bitslip_waitdly                : integer := 40        --! Number of clock cycle required before being back in a stable state
--        );
--        PORT (
--            -- Clock(s)
--            clk_pcsRx_i                      : in  std_logic;       --! MGT Wordclock
--            clk_freeRunningClk_i             : in  std_logic;       --! Free running clock for MGT reset (reset on even feature)

--            -- Reset(s)
--            rst_pattsearch_i                 : in  std_logic;       --! Rst the pattern search state machines
--            rst_mgtctrler_i                  : in  std_logic;       --! Rst the "reset on even" controller
--            rst_rstoneven_o                  : out std_logic;       --! Output reset asserted WHEN reset is even or odd depENDing on cmd_rstonevenoroddsel_i

--            -- Control
--            cmd_bitslipCtrl_o                : out std_logic;       --! Bitslip SIGNAL to shIFt the parrallel word
--            cmd_rstonevenoroddsel_i          : in  std_logic;       --! Select how to reset the MGT (even or odd bitslip)

--            -- Status
--            sta_headerLocked_o               : out std_logic;       --! Status: header is locked
--            sta_headerFlag_o                 : out std_logic;       --! Status: header flag (1 pulse over c_wordRatio)

--            -- Data
--            dat_word_i                       : in  std_logic_vector(c_headerPattern'length-1 downto 0)  --! Header bits from the MGT word (compared with c_headerPattern)
--       );
--    END COMPONENT;

--    COMPONENT lpgbtfpga_rxGearbox
--        GENERIC (
--            c_clockRatio                  : integer;                                                         --! Clock ratio is clock_out / clock_in (shall be an integer)
--            c_inputWidth                  : integer;                                                         --! Bus size of the input word
--            c_outputWidth                 : integer;                                                         --! Bus size of the output word (Warning: c_clockRatio/(c_inputWidth/c_outputWidth) shall be an integer)
--            c_counterInitValue            : integer := 2                                                     --! Initialization value of the gearbox counter (3 for simulation / 2 for real HW)
--        );
--        PORT (
--            -- Clock and reset
--            clk_inClk_i                   : in  std_logic;                                                   --! Input clock (from MGT)
--            clk_outClk_i                  : in  std_logic;                                                   --! Output clock (from MGT)
--            clk_clkEn_i                   : in  std_logic;                                                   --! Clock enable (e.g.: header flag)
--            clk_dataFlag_o                : out std_logic;

--            rst_gearbox_i                 : in  std_logic;                                                   --! Reset SIGNAL

--            -- Data
--            dat_inFrame_i                 : in  std_logic_vector((c_inputWidth-1) downto 0);                 --! Input data from MGT
--            dat_outFrame_o                : out std_logic_vector((c_inputWidth*c_clockRatio)-1 downto 0);    --! Output data, concatenation of word WHEN the word ratio is lower than clock ration (e.g.: out <= word & word;)

--            -- Status
--            sta_gbRdy_o                   : out std_logic                                                    --! Ready SIGNAL
--        );
--    END COMPONENT;

    --! Uplink de-interleaver component
    COMPONENT lpgbt_uplink_interleaver
        GENERIC(
            DATARATE                        : integer RANGE 0 to 2;                 --! Datarate selection can be: DATARATE_10G24 or DATARATE_5G12
            FEC                             : integer RANGE 0 to 2                  --! FEC selection can be: FEC5 or FEC12
        );
        PORT (
            -- Data
            fec5_data_i                     : in std_logic_vector(233 downto 0);   --! Input data from FEC5 encoding (data is duplicated in upper/lower part of the frame @5.12Gbps)
            fec5_fec_i                      : in std_logic_vector(19 downto 0);    --! Input FEC from FEC5 encoding (data is duplicated in upper/lower part of the frame @5.12Gbps)
            fec12_data_i                    : in std_logic_vector(205 downto 0);   --! Input data from FEC12 encoding (data is duplicated in upper/lower part of the frame @5.12Gbps)
            fec12_fec_i                     : in std_logic_vector(47 downto 0);    --! Input FEC from FEC12 encoding (data is duplicated in upper/lower part of the frame @5.12Gbps)
            
            fec_data_o                     : out  std_logic_vector(255 downto 0);   --! Input frame from the Rx gearbox (data shall be duplicated in upper/lower part of the frame @5.12Gbps)
--            fec12_data_o                    : out  std_logic_vector(255 downto 0);   --! Input frame from the Rx gearbox (data shall be duplicated in upper/lower part of the frame @5.12Gbps)
            -- Control
            bypass                          : in  std_logic                         --! Bypass uplink interleaver (test purpose only)
        );
    END COMPONENT;

    --! Uplink decoder component
    COMPONENT lpgbt_uplink_encoder
   GENERIC(
         DATARATE                        : integer RANGE 0 TO 2;                   --! Datarate selection can be: DATARATE_10G24 or DATARATE_5G12
         FEC                             : integer RANGE 0 TO 2                    --! FEC selection can be: FEC5 or FEC12
    );
    PORT (
         -- Clock
 --        uplinkClk_i                     : in  std_logic;
 --        uplinkClkInEn_i                 : in  std_logic;
 --        uplinkClkOutEn_i                : in  std_logic;
 
         -- Data
         fec5_data_i                     : in  std_logic_vector(233 downto 0);     --! Data input from de-interleaver for FEC5 decoding (redundant on upper/lower part of the bus @5.12Gbps) 
         fec12_data_i                    : in  std_logic_vector(205 downto 0);     --! Data input from de-interleaver for FEC12 decoding (redundant on upper/lower part of the bus @5.12Gbps)
 
         fec5_fec_o                      : out std_logic_vector(19 downto 0);     --! FEC output for FEC5 decoding (redundant on upper/lower part of the bus @5.12Gbps)
         fec12_fec_o                    : out std_logic_vector(47 downto 0);     --! FEC output for FEC12 decoding (redundant on upper/lower part of the bus @5.12Gbps)
  
         -- Control
         bypass                          : in  std_logic                           --! Bypass uplink FEC (test purpose only)       
    );
    END COMPONENT;

    --! Uplink datapath
    COMPONENT lpgbt_uplink_scrambler
       GENERIC(
            FEC                             : integer RANGE 0 to 2
       );
       PORT (
            -- Clock and reset
            clk_i                           : in  std_logic;
            clkEn_i                         : in  std_logic;

            reset_i                         : in  std_logic;

            -- Data
            fec5_data_i                     : in  std_logic_vector(233 downto 0);
            fec12_data_i                    : in  std_logic_vector(205 downto 0);

            fec5_data_o                     : out std_logic_vector(233 downto 0);
            fec12_data_o                    : out std_logic_vector(205 downto 0);

            -- Control
            bypass                          : in  std_logic
       );
    END COMPONENT;


--    SIGNAL sta_headerFlag_s                 : std_logic;
--    SIGNAL sta_dataflag_s                   : std_logic;
--    SIGNAL rst_gearbox_s                    : std_logic;
--    SIGNAL sta_headerLocked_s               : std_logic;

--    SIGNAL gbxFrame_s                       : std_logic_vector(255 downto 0);
--    SIGNAL gbxFrame_5g12_s                  : std_logic_vector(127 downto 0);

--    SIGNAL sta_gbRdy_s                      : std_logic;
    SIGNAL rst_pattsearch_s                 : std_logic;
--    SIGNAL datapath_rst_s                   : std_logic;

    SIGNAL fec5_data_from_deinterleaver_s   : std_logic_vector(235 downto 0);    --! Data from de-interleaver (FEC5)
    SIGNAL fec5_fec_from_deinterleaver_s    : std_logic_vector(19 downto 0);     --! FEC from de-interleaver (FEC5)
    SIGNAL fec12_data_from_deinterleaver_s  : std_logic_vector(205 downto 0);    --! Data from de-interleaver (FEC12)
    SIGNAL fec12_fec_from_deinterleaver_s   : std_logic_vector(47 downto 0);     --! FEC from de-interleaver (FEC12)

    SIGNAL fec5_data_from_decoder_s         : std_logic_vector(19 downto 0);    --! Data from decoder (FEC5)
    SIGNAL fec12_data_from_decoder_s        : std_logic_vector(47 downto 0);    --! Data from decoder (FEC12)

    SIGNAL fec5_data_from_descrambler_s     : std_logic_vector(233 downto 0);    --! Data from descrambler (FEC5)
    SIGNAL fec12_data_from_descrambler_s    : std_logic_vector(205 downto 0);    --! Data from descrambler (FEC12)

    SIGNAL fec5_correction_s                : std_logic_vector(233 downto 0);    --! Correction flag (FEC5)
    SIGNAL fec12_correction_s               : std_logic_vector(205 downto 0);    --! Correction flag (FEC12)

    SIGNAL rdy_0_s                          : std_logic;                         --! Ready register to delay the ready SIGNAL
    SIGNAL rdy_1_s                          : std_logic;                         --! Ready register to delay the ready SIGNAL

    SIGNAL fec5_data_to_scrambler_s         : std_logic_vector(233 downto 0);    --! Uplink output for FEC5 datarate configuration (IC + EC + User data)
    SIGNAL fec12_data_to_scrambler_s        : std_logic_vector(205 downto 0);    --! Uplink output for FEC12 datarate configuration (IC + EC + User data)
    
    SIGNAL uplinkCorrData_10g24_s           : std_logic_vector(229 downto 0);    --! Uplink correction flag output for 10g24 datarate configuration (User data)
    SIGNAL uplinkCorrEc_10g24_s             : std_logic_vector(1 downto 0);      --! Uplink correction flag output for 10g24 datarate configuration (EC)
    SIGNAL uplinkCorrIc_10g24_s             : std_logic_vector(1 downto 0);      --! Uplink correction flag output for 10g24 datarate configuration (IC)

    SIGNAL uplinkCorrData_5g12_s            : std_logic_vector(229 downto 0);    --! Uplink correction flag output for 5g12 datarate configuration (User data)
    SIGNAL uplinkCorrEc_5g12_s              : std_logic_vector(1 downto 0);      --! Uplink correction flag output for 5g12 datarate configuration (EC)
    SIGNAL uplinkCorrIc_5g12_s              : std_logic_vector(1 downto 0);      --! Uplink correction flag output for 5g12 datarate configuration (IC)

    SIGNAL frame_pipelined_s                : std_logic_vector(255 downto 0);    --! Store input data in register to ensure stability
    SIGNAL clkEnOut_s                       : std_logic;
    SIGNAL rst_synch_s                      : std_logic;

BEGIN                 --========####   Architecture Body   ####========--

    rst_pattsearch_s         <= not(uplinkRst_n_i);

--    -- lpgbtfpga_framealigner is used to align the input frame using the
--    -- lpGBT header.
--    lpgbtfpga_framealigner_inst: lpgbtfpga_framealigner
--        GENERIC MAP(
--            c_wordRatio                      => c_clockRatio,
--            c_wordSize                       => c_mgtWordWidth,
--            c_headerPattern                  => "01",
--            c_allowedFalseHeader             => c_allowedFalseHeader,
--            c_allowedFalseHeaderOverN        => c_allowedFalseHeaderOverN,
--            c_requiredTrueHeader             => c_requiredTrueHeader,

--            c_resetOnEven                    => 0,
--            c_resetDuration                  => 0,
--            c_bitslip_mindly                 => c_bitslip_mindly,
--            c_bitslip_waitdly                => c_bitslip_waitdly
--        )
--        PORT MAP(
--            -- Clock(s)
--            clk_pcsRx_i                      => uplinkClk_i,
--            clk_freeRunningClk_i             => clk_freeRunningClk_i,

--            -- Reset(s)
--            rst_pattsearch_i                 => rst_pattsearch_s,
--            rst_mgtctrler_i                  => '1',          -- Current wrapper supPORTs only standard mode
--            rst_rstoneven_o                  => open,

--            -- Control
--            cmd_bitslipCtrl_o                => mgt_bitslipCtrl_o,
--            cmd_rstonevenoroddsel_i          => '0',

--            -- Status
--            sta_headerLocked_o               => sta_headerLocked_s,
--            sta_headerFlag_o                 => sta_headerFlag_s,

--            -- Data
--            dat_word_i                       => mgt_word_o(1 downto 0)
--        );

--    rst_gearbox_s <= not(sta_headerLocked_s);

--    -- lpgbtfpga_rxGearbox is used to pass from mgt word size (e.g.: 32b @ 320MHz)
--    -- to lpgbt frame size (e.g.: 256b at 40MHz)
--    rxgearbox_10g_gen: IF DATARATE = DATARATE_10G24 GENERATE
--        rxGearbox_10g24_inst: lpgbtfpga_rxGearbox
--            GENERIC MAP(
--                c_clockRatio                  => c_clockRatio,
--                c_inputWidth                  => c_mgtWordWidth,
--                c_outputWidth                 => 256,
--                c_counterInitValue            => 2
--            )
--            PORT MAP(
--                -- Clock and reset
--                clk_inClk_i                   => uplinkClk_i,
--                clk_outClk_i                  => uplinkClk_i,
--                clk_clkEn_i                   => sta_headerFlag_s,
--                clk_dataFlag_o                => sta_dataflag_s,

--                rst_gearbox_i                 => rst_gearbox_s,

--                -- Data
--                dat_inFrame_i                 => mgt_word_o,
--                dat_outFrame_o                => gbxFrame_s,

--                -- Status
--                sta_gbRdy_o                   => sta_gbRdy_s
--            );
--    END GENERATE;

--    rxgearbox_5g_gen: IF DATARATE = DATARATE_5G12 GENERATE
--        rxGearbox_5g12_inst: lpgbtfpga_rxGearbox
--            GENERIC MAP(
--                c_clockRatio                  => c_clockRatio,
--                c_inputWidth                  => c_mgtWordWidth,
--                c_outputWidth                 => 128,
--                c_counterInitValue            => 2
--            )
--            PORT MAP(
--                -- Clock and reset
--                clk_inClk_i                   => uplinkClk_i,
--                clk_outClk_i                  => uplinkClk_i,
--                clk_clkEn_i                   => sta_headerFlag_s,
--                clk_dataFlag_o                => sta_dataflag_s,

--                rst_gearbox_i                 => rst_gearbox_s,

--                -- Data
--                dat_inFrame_i                 => mgt_word_o,
--                dat_outFrame_o                => gbxFrame_5g12_s,

--                -- Status
--                sta_gbRdy_o                   => sta_gbRdy_s
--            );

--        gbxFrame_s(127 downto 0)   <= gbxFrame_5g12_s;
--        gbxFrame_s(255 downto 128) <= (OTHERS => '0');

--    END GENERATE;

--    datapath_rst_s    <= not(sta_gbRdy_s);

--    --! Data input pipeline
--    dataInPipeliner_proc: PROCESS(uplinkClk_i, datapath_rst_s)
--    BEGIN
--        IF datapath_rst_s = '1' THEN
--            frame_pipelined_s      <= (OTHERS => '0');
--        ELSIF rising_edge(uplinkClk_i) THEN
--            IF sta_dataflag_s = '1' THEN
--                frame_pipelined_s  <= gbxFrame_s;
--            END IF;
--        END IF;
--    END PROCESS;


    --! Multicycle path configuration
--    syncShIFtReg_proc: PROCESS(rst_pattsearch_s, uplinkClk_i)
--        VARIABLE cnter  : integer RANGE 0 TO 7;
--    BEGIN

--        IF rst_pattsearch_s = '1' THEN
--              cnter              := 0;
--              clkEnOut_s   <= '0';

--        ELSIF rising_edge(uplinkClk_i) THEN
--            IF sta_dataflag_s = '1' THEN
--                cnter                 := 0;
--                rst_synch_s  <= '1';
--            ELSIF rst_synch_s = '1' THEN
--                cnter            := cnter + 1;
--            END IF;

--            clkEnOut_s       <= '0';
--            IF cnter = c_multicyleDelay THEN
--                clkEnOut_s   <= '1';
--            END IF;
--        END IF;
--    END PROCESS;
    clkEnOut_s   <= '1';
    uplinkClkOutEn_o  <= clkEnOut_s;

    -- lpgbt_uplink_scrambler descrambles the input frame
    lpgbt_uplink_scrambler_inst: lpgbt_uplink_scrambler
        GENERIC MAP(
            FEC                 => FEC
        )
        PORT MAP(
            -- Clock and reset
            clk_i               => uplinkClk_i,
            --clkEn_i             => clkEnOut_s,
            clkEn_i             => '1',

            reset_i             => rst_pattsearch_s,

            -- Data
            fec5_data_i         => fec5_data_to_scrambler_s,
            fec12_data_i        => fec12_data_to_scrambler_s,

            fec5_data_o         => fec5_data_from_descrambler_s,
            fec12_data_o        => fec12_data_from_descrambler_s,

            -- Control
            bypass              => bypassScrambler_i
        );

    -- lpgbt_uplink_encoder decodes the input frame and corrects the error(s) using the FEC part
    -- of the frame
    lpgbt_uplink_encoder_inst: lpgbt_uplink_encoder
        GENERIC MAP(
            DATARATE                        => DATARATE,
            FEC                             => FEC
        )
        PORT MAP (
--            uplinkClk_i                     => uplinkClk_i,
--            uplinkClkInEn_i                 => sta_dataflag_s,
--            uplinkClkOutEn_i                => clkEnOut_s,

            -- Data
            fec5_data_i                    => fec5_data_from_descrambler_s,
            fec12_data_i                   => fec12_data_from_descrambler_s,
            

            fec5_fec_o                     => fec5_data_from_decoder_s,
            fec12_fec_o                    => fec12_data_from_decoder_s,

--            fec5_correction_pattern_o       => fec5_correction_s,
--            fec12_correction_pattern_o      => fec12_correction_s,

            -- Control
            bypass                          => bypassFECEncoder_i
        );

    -- lpgbt_uplink_interleaver deinterleaves the input frame
    lpgbt_uplink_interleaver_inst: lpgbt_uplink_interleaver
       GENERIC MAP(
            DATARATE        => DATARATE,
            FEC             => FEC
       )
       PORT MAP (
            -- Data            
            fec5_data_i     => fec5_data_from_descrambler_s,
            fec5_fec_i      => fec5_data_from_decoder_s,
            fec12_data_i    => fec12_data_from_descrambler_s,
            fec12_fec_i     => fec12_data_from_decoder_s,

            fec_data_o      => word_o,

            -- Control
            bypass          => bypassInterleaver_i
       );

--    --! Generate ready SIGNAL from the reset (2 clock cycle delay)
--    readySync_proc: PROCESS(uplinkClk_i, rst_pattsearch_s)
--    BEGIN

--        IF rst_pattsearch_s = '1' THEN
--            rdy_1_s  <= '0';
--            rdy_0_s  <= '0';
--            rdy_o    <= '0';

--        ELSIF rising_edge(uplinkClk_i) THEN

--            IF clkEnOut_s = '1' THEN
--                rdy_o    <= rdy_1_s;
--                rdy_1_s  <= rdy_0_s;
--                rdy_0_s  <= '1';
--            END IF;

--        END IF;
--    END PROCESS;

    -- Routes data depending on the datarate and FEC configurations
    
    fec5_data_to_scrambler_s    <= (OTHERS => '0') WHEN rst_pattsearch_s = '1' ELSE
                                   IcData_i   & EcData_i     & USErData_i(229 downto 0) WHEN (DATARATE = DATARATE_10G24) ELSE
                                   x"00000000000000000000000000000" & "00" & IcData_i    & EcData_i   & USErData_i(111 downto 0);                           
    
    fec12_data_to_scrambler_s    <= (OTHERS => '0') WHEN rst_pattsearch_s = '1' ELSE
                                    IcData_i   & EcData_i     & USErData_i(201 downto 0) WHEN (DATARATE = DATARATE_10G24) ELSE
                                    x"00000000000000000000000000" & IcData_i    & EcData_i   & USErData_i(97 downto 0);

--    uplinkCorrData_10g24_s  <= (OTHERS => '0') WHEN rdy_1_s = '0' ELSE
--                               fec5_correction_s(229 downto 0) WHEN (FEC = FEC5) ELSE
--                               "0000000000000000000000000000" & fec12_correction_s(201 downto 0);

--    uplinkCorrEc_10g24_s    <= (OTHERS => '0') WHEN rdy_1_s = '0' ELSE
--                               fec5_correction_s(231 downto 230) WHEN (FEC = FEC5) ELSE
--                               fec12_correction_s(203 downto 202);

--    uplinkCorrIc_10g24_s    <= (OTHERS => '0') WHEN rdy_1_s = '0' ELSE
--                               fec5_correction_s(233 downto 232) WHEN (FEC = FEC5) ELSE
--                               fec12_correction_s(205 downto 204);

--    uplinkCorrData_5g12_s   <= (OTHERS => '0') WHEN rdy_1_s = '0' ELSE
--                               x"00000000000000000000000000000" & "00" & fec5_correction_s(111 downto 0) WHEN (FEC = FEC5) ELSE
--                               x"000000000000000000000000000000000" & fec12_correction_s(97 downto 0);

--    uplinkCorrEc_5g12_s     <= (OTHERS => '0') WHEN rdy_1_s = '0' ELSE
--                               fec5_correction_s(113 downto 112) WHEN (FEC = FEC5) ELSE
--                               fec12_correction_s(99 downto 98);

--    uplinkCorrIc_5g12_s     <= (OTHERS => '0') WHEN rdy_1_s = '0' ELSE
--                               fec5_correction_s(115 downto 114) WHEN (FEC = FEC5) ELSE
--                               fec12_correction_s(101 downto 100);

--    dataCorrected_o         <= uplinkCorrData_10g24_s WHEN (DATARATE = DATARATE_10G24) ELSE
--                               uplinkCorrData_5g12_s;

--    EcCorrected_o           <= uplinkCorrEc_10g24_s WHEN (DATARATE = DATARATE_10G24) ELSE
--                               uplinkCorrEc_5g12_s;

--    IcCorrected_o           <= uplinkCorrIc_10g24_s WHEN (DATARATE = DATARATE_10G24) ELSE
--                               uplinkCorrIc_5g12_s;
END behavioral;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--