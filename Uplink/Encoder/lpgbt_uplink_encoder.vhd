----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.08.2020 23:41:00
-- Design Name: 
-- Module Name: lpgbt_uplink_encoder - Behavioral
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library xil_defaultlib;
use xil_defaultlib.lpgbtfpga_package.all;
----------------------------------------------------------------------------------
--! @brief lpgbt_uplink_encoder - Uplink FEC decoder
--! @details Decodes the received data and corrects error WHEN possible. The decoding
--! is based on the N=31, K=29 and SymbWidth=5 or the N=15, K=13 and SymbWidth=4
--! implementation of the Reed-Solomon scheme depending on the configuration (FEC5 or FEC12).
ENTITY lpgbt_uplink_encoder IS
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
END lpgbt_uplink_encoder;

--! @brief lpgbt_uplink_encoder - Uplink FEC decoder
--! @details The lpgbt_uplink_encoder module instantiates the Reed-Solomon N31K29 and N15K13
--! modules to correct errors for both FEC5 and FEC12 configuration. Only the required logic is USEd WHEN
--! the DATARATE is configured to run at 5.12gbps.
ARCHITECTURE behavioral OF lpgbt_uplink_encoder IS

    -- N31K29 decoder component
    COMPONENT rs_31N29K_enc
       GENERIC (
            N								: integer := 31;
            K 								: integer := 29;
            SYMB_BITWIDTH					: integer := 5
       );
       PORT (
            msg         : in  std_logic_vector((K*SYMB_BITWIDTH)-1 downto 0);
            
            parity      : out std_logic_vector(((N-K)*SYMB_BITWIDTH)-1 downto 0)    --! FEC output
       );
    END COMPONENT;

    -- N15K13 decoder component
    COMPONENT rs_15N13K_enc
       GENERIC (
            N								: integer := 15;
            K 								: integer := 13;
            SYMB_BITWIDTH					: integer := 4
       );
       PORT (
            msg     : in  std_logic_vector((K*SYMB_BITWIDTH)-1 downto 0);
            
            parity  : out std_logic_vector(((N-K)*SYMB_BITWIDTH)-1 downto 0)    --! FEC output
       );
    END COMPONENT;

    -- Signals
    SIGNAL fec5_encoded_code0_s           : std_logic_vector(144 downto 0);   --! FEC5 encoded data (code 0)
    SIGNAL fec5_encoded_code1_s           : std_logic_vector(144 downto 0);   --! FEC5 encoded data (code 1)

    SIGNAL fec5_decoded_code0_s           : std_logic_vector(9 downto 0);   --! FEC5 decoded data (code 0)
    SIGNAL fec5_decoded_code1_s           : std_logic_vector(9 downto 0);   --! FEC5 decoded data (code 1)

    SIGNAL fec12_encoded_code0_s          : std_logic_vector(51 downto 0);    --! FEC12 encoded data (code 0)
    SIGNAL fec12_encoded_code1_s          : std_logic_vector(51 downto 0);    --! FEC12 encoded data (code 1)
    SIGNAL fec12_encoded_code2_s          : std_logic_vector(51 downto 0);    --! FEC12 encoded data (code 2)
    SIGNAL fec12_encoded_code3_s          : std_logic_vector(51 downto 0);    --! FEC12 encoded data (code 3)
    SIGNAL fec12_encoded_code4_s          : std_logic_vector(51 downto 0);    --! FEC12 encoded data (code 4)
    SIGNAL fec12_encoded_code5_s          : std_logic_vector(51 downto 0);    --! FEC12 encoded data (code 5)

    SIGNAL fec12_decoded_code0_s          : std_logic_vector(7 downto 0);    --! FEC12 decoded data (code 0)
    SIGNAL fec12_decoded_code1_s          : std_logic_vector(7 downto 0);    --! FEC12 decoded data (code 1)
    SIGNAL fec12_decoded_code2_s          : std_logic_vector(7 downto 0);    --! FEC12 decoded data (code 2)
    SIGNAL fec12_decoded_code3_s          : std_logic_vector(7 downto 0);    --! FEC12 decoded data (code 3)
    SIGNAL fec12_decoded_code4_s          : std_logic_vector(7 downto 0);    --! FEC12 decoded data (code 4)
    SIGNAL fec12_decoded_code5_s          : std_logic_vector(7 downto 0);    --! FEC12 decoded data (code 5)

    SIGNAL fec5_data_s                    : std_logic_vector(19 downto 0);     --! Data output for FEC5 decoding (redundant on upper/lower part of the bus @5.12Gbps)
--    SIGNAL fec5_toenc_data_s              : std_logic_vector(233 downto 0);     --! Data output for FEC5 decoding (redundant on upper/lower part of the bus @5.12Gbps)
--    SIGNAL fec5_data_output_synch_s       : std_logic_vector(233 downto 0);     --! Data output for FEC5 decoding (redundant on upper/lower part of the bus @5.12Gbps)
--    SIGNAL fec5_data_input_synch_s        : std_logic_vector(233 downto 0);     --! Data output for FEC5 decoding (redundant on upper/lower part of the bus @5.12Gbps)
    SIGNAL fec12_data_s                   : std_logic_vector(47 downto 0);     --! Data output for FEC12 decoding (redundant on upper/lower part of the bus @5.12Gbps)
--    SIGNAL fec12_toenc_data_s             : std_logic_vector(205 downto 0);     --! Data output for FEC12 decoding (redundant on upper/lower part of the bus @5.12Gbps)
--    SIGNAL fec12_data_output_synch_s      : std_logic_vector(205 downto 0);     --! Data output for FEC12 decoding (redundant on upper/lower part of the bus @5.12Gbps)
--    SIGNAL fec12_data_input_synch_s       : std_logic_vector(205 downto 0);     --! Data output for FEC12 decoding (redundant on upper/lower part of the bus @5.12Gbps)

    SIGNAL uplinkClkInEn_pipe_s           : std_logic;

BEGIN                 --========####   Architecture Body   ####========--

    -- FEC5 decoders
    fec5_enc_gen: IF FEC = FEC5 GENERATE

        fec5_encoded_code0_s   <= "00000000000000000000000000" &
                                  fec5_data_i(233 downto 232) &
                                  fec5_data_i(116 downto 0)       WHEN (DATARATE = DATARATE_10G24) ELSE
                                  "00000000000000000000000000000" &
                                  fec5_data_i(115 downto 0);

        rs_31N29K_enc_c0_inst: rs_31N29K_enc
            PORT MAP (
                msg             => fec5_encoded_code0_s,

                parity          => fec5_decoded_code0_s
            );

        dec10g24_fec5_gen: IF DATARATE = DATARATE_10G24 GENERATE

            fec5_encoded_code1_s   <= "000000000000000000000000000000" & fec5_data_i(231 downto 117) WHEN (DATARATE = DATARATE_10G24) ELSE
                                      "00000000000000000000000000000" & fec5_data_i(231 downto 116);

            rs_31N29K_enc_c1_inst: rs_31N29K_enc
                PORT MAP (
                    msg         => fec5_encoded_code1_s,

                    parity      => fec5_decoded_code1_s
                );

        END GENERATE;

        dec5g12_fec5_gen: IF DATARATE = DATARATE_5G12 GENERATE
            fec5_decoded_code1_s <= (OTHERS =>  '0');
        END GENERATE;

    END GENERATE;

    -- FEC12 decoders
    fec12_enc_gen: IF FEC = FEC12 GENERATE

        fec12_encoded_code0_s   <= "0000000000000000" & fec12_data_i(135 downto 134) & fec12_data_i(33 downto 0) WHEN (DATARATE = DATARATE_10G24) ELSE
                                   "0000000000000000" & fec12_data_i(67 downto 66) & fec12_data_i(33 downto 0);

        fec12_encoded_code1_s   <= "0000000000000000" & fec12_data_i(169 downto 168) & fec12_data_i(67 downto 34) WHEN (DATARATE = DATARATE_10G24) ELSE
                                   "000000000000000000" & fec12_data_i(101 downto 100) & fec12_data_i(65 downto 34);

        fec12_encoded_code2_s   <= "0000000000000000" & fec12_data_i(203 downto 202) & fec12_data_i(101 downto 68) WHEN (DATARATE = DATARATE_10G24) ELSE
                                   "00000000000000000000" & fec12_data_i(99 downto 68);

        rs_15N13K_enc_c0_inst: rs_15N13K_enc
            PORT MAP (
                msg       => fec12_encoded_code0_s,

                parity    => fec12_decoded_code0_s
            );

        rs_15N13K_enc_c1_inst: rs_15N13K_enc
            PORT MAP (
                msg         => fec12_encoded_code1_s,

                parity      => fec12_decoded_code1_s
            );

        rs_15N13K_enc_c2_inst: rs_15N13K_enc
            PORT MAP (
                msg         => fec12_encoded_code2_s,

                parity      => fec12_decoded_code2_s
            );

        dec5g12_fec12_gen: IF DATARATE = DATARATE_5G12 GENERATE
            fec12_decoded_code3_s <= (OTHERS => '0');
            fec12_decoded_code4_s <= (OTHERS => '0');
            fec12_decoded_code5_s <= (OTHERS => '0');
        END GENERATE;

        dec10g24_fec12_gen: IF DATARATE = DATARATE_10G24 GENERATE

            fec12_encoded_code3_s   <= "000000000000000000" & fec12_data_i(205 downto 204) & fec12_data_i(133 downto 102)  WHEN (DATARATE = DATARATE_10G24) ELSE
                                       "0000000000000000" & fec12_data_i(169 downto 168) & fec12_data_i(135 downto 102);

            fec12_encoded_code4_s   <= "00000000000000000000" & fec12_data_i(167 downto 136)  WHEN (DATARATE = DATARATE_10G24) ELSE
                                       "000000000000000000" & fec12_data_i(203 downto 202) & fec12_data_i(167 downto 136);

            fec12_encoded_code5_s   <= "00000000000000000000" & fec12_data_i(201 downto 170)  WHEN (DATARATE = DATARATE_10G24) ELSE
                                       "00000000000000000000" & fec12_data_i(201 downto 170);

            rs_15N13K_enc_c3_inst: rs_15N13K_enc
                PORT MAP (
                    msg         => fec12_encoded_code3_s,

                    parity      => fec12_decoded_code3_s
                );

            rs_15N13K_enc_c4_inst: rs_15N13K_enc
                PORT MAP (
                    msg        => fec12_encoded_code4_s,                    

                    parity     => fec12_decoded_code4_s
                );

            rs_15N13K_enc_c5_inst: rs_15N13K_enc
                PORT MAP (
                    msg        => fec12_encoded_code5_s,

                    parity     => fec12_decoded_code5_s
                );
        END GENERATE;

    END GENERATE;

    -- If FEC5 is disabled, force value to 0
    fec5_enc_dis_gen: IF FEC = FEC12 GENERATE
        fec5_decoded_code0_s <= (OTHERS => '0');
        fec5_decoded_code1_s <= (OTHERS => '0');
    END GENERATE;

    -- If FEC12 is disabled, force value to 0
    fec12_enc_dis_gen: IF FEC = FEC5 GENERATE
        fec12_decoded_code0_s <= (OTHERS => '0');
        fec12_decoded_code1_s <= (OTHERS => '0');
        fec12_decoded_code2_s <= (OTHERS => '0');
        fec12_decoded_code3_s <= (OTHERS => '0');
        fec12_decoded_code4_s <= (OTHERS => '0');
        fec12_decoded_code5_s <= (OTHERS => '0');
    END GENERATE;

--    PROCESS(uplinkClk_i)
--    BEGIN
--        IF rising_edge(uplinkClk_i) THEN
--            IF uplinkClkOutEn_i = '1' THEN
--                fec5_data_input_synch_s    <= fec5_toenc_data_s;
--                fec12_data_input_synch_s   <= fec12_toenc_data_s;
--                fec5_correction_pattern_o  <= fec5_toenc_data_s xor fec5_data_s;
--                fec12_correction_pattern_o <= fec12_toenc_data_s xor fec12_data_s;
--            END IF;
--        END IF;
--    END PROCESS;

--    PROCESS(uplinkClk_i)
--    BEGIN
--        IF rising_edge(uplinkClk_i) THEN
--            uplinkClkInEn_pipe_s <= uplinkClkInEn_i;
--            IF uplinkClkInEn_pipe_s = '1' THEN
--            END IF;
--        END IF;
--    END PROCESS;


    fec5_fec_o    <= fec5_data_s;
    fec12_fec_o   <= fec12_data_s;

    fec5_data_s    <= (OTHERS => '0')                        WHEN bypass = '1' ELSE
                      fec5_decoded_code1_s      &
                      fec5_decoded_code0_s;
                      
    fec12_data_s   <= (OTHERS => '0')                        WHEN bypass = '1' ELSE
                      fec12_decoded_code5_s     &
                      fec12_decoded_code4_s     &
                      fec12_decoded_code3_s     &
                      fec12_decoded_code2_s     &
                      fec12_decoded_code1_s     &
                      fec12_decoded_code0_s;  


END behavioral;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--