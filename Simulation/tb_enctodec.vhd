library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--! Include the lpGBT-FPGA specific package
library xil_defaultlib;
use xil_defaultlib.lpgbtfpga_package.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_enctodec is
--  Port ( );
end tb_enctodec;

architecture Behavioral of tb_enctodec is
--    component lpgbt_scrambler
--        port(clk,rst            : in  std_logic;
--             Din                : in  std_logic_vector(57 downto 0);
--             data_out          	: out std_logic_vector(57 downto 0)                          
--            );
--    end component;
    
--    component lpgbt_descrambler
--	   port(clk,rst            : IN  std_logic;
--    		Din_des                : in  std_logic_vector(57 downto 0);
--            data_out_des              : out std_logic_vector(57 downto 0)
--    		);
--    END COMPONENT;

    component lpgbtfpga_downlink_enc
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
            encodedFrame_o                :out std_logic_vector(63 downto 0);                    --! Downlink encoded frame (IC + EC + User Data + FEC)
        
            -- Configuration
            interleaverBypass_i           : in  std_logic;                                      --! Bypass downlink interleaver (test purpose only)
            encoderBypass_i               : in  std_logic;                                      --! Bypass downlink FEC (test purpose only)
            scramblerBypass_i             : in  std_logic;                                      --! Bypass downlink scrambler (test purpose only)

            -- Status
            rdy_o                         : out std_logic                                       --! Downlink ready status
         );
    end component;
    
    component lpgbtfpga_downlink_dec
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
        encodedFrame_i                : in  std_logic_vector(63 downto 0);                  --! Downlink encoded frame (IC + EC + User Data + FEC)  
 
        -- Output
        --mgt_word_o                    : out std_logic_vector((c_outputWidth-1) downto 0);   --! Downlink encoded frame (IC + EC + User Data + FEC)        
        USErData_o                    : out  std_logic_vector(31 downto 0);                  --! Downlink data (USEr)
        ECData_o                      : out  std_logic_vector(1 downto 0);                   --! Downlink EC field
        ICData_o                      : out  std_logic_vector(1 downto 0);                   --! Downlink IC field
         
        -- Configuration
        interleaverBypass_i           : in  std_logic;                                      --! Bypass downlink interleaver (test purpose only)
        encoderBypass_i               : in  std_logic;                                      --! Bypass downlink FEC (test purpose only)
        scramblerBypass_i             : in  std_logic;                                      --! Bypass downlink scrambler (test purpose only)
 
        -- Status
        rdy_o                         : out std_logic                                       --! Downlink ready status
     );
    END COMPONENT;
    
    component lpgbtfpga_uplink_enc
        GENERIC(
            -- General configuration
            DATARATE                        : integer RANGE 0 to 2;                               --! Datarate selection can be: DATARATE_10G24 or DATARATE_5G12
            FEC                             : integer RANGE 0 to 2;                               --! FEC selection can be: FEC5 or FEC12
 
            -- Expert parameters
            c_multicyleDelay                : integer RANGE 0 to 7 := 3                          --! Multicycle delay: USEd to relax the timing constraints
        );
        PORT (
              -- Clock and reset
--              clk_freeRunningClk_i            : in  std_logic;
              uplinkClk_i                     : in  std_logic;                                      --! Input clock (Rx USEr clock from transceiver)
              uplinkClkOutEn_o                : out std_logic;                                      --! Clock enable to be USEd in the USEr's logic
              uplinkRst_n_i                   : in  std_logic;                                      --! Uplink reset SIGNAL (Rx ready from the transceiver)
      
              -- Input
      --        mgt_word_o                      : in  std_logic_vector((c_mgtWordWidth-1) downto 0);  --! Input frame coming from the MGT
      --        word_o                           : out  std_logic_vector((c_mgtWordWidth-1) downto 0);  --! Input frame coming from the MGT
              word_o                           : out  std_logic_vector(255 downto 0);
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
--              dataCorrected_o                 : out std_logic_vector(229 downto 0);                 --! Flag allowing to know which bit(s) were toggled by the FEC
--              IcCorrected_o                   : out std_logic_vector(1 downto 0);                   --! Flag allowing to know which bit(s) of the IC field were toggled by the FEC
--              EcCorrected_o                   : out std_logic_vector(1 downto 0);                   --! Flag allowing to know which bit(s) of the EC field  were toggled by the FEC
              rdy_o                           : out std_logic                                       --! Ready SIGNAL from the uplink decoder
        );
    END COMPONENT;
    
    component lpgbtfpga_uplink_dec
        GENERIC(
            -- General configuration
            DATARATE                        : integer RANGE 0 to 2;                               --! Datarate selection can be: DATARATE_10G24 or DATARATE_5G12
            FEC                             : integer RANGE 0 to 2;                               --! FEC selection can be: FEC5 or FEC12
 
            -- Expert parameters
            c_multicyleDelay                : integer RANGE 0 to 7 := 3                          --! Multicycle delay: USEd to relax the timing constraints
        );
        PORT (
         -- Clock and reset
--         clk_freeRunningClk_i            : in  std_logic;
         uplinkClk_i                     : in  std_logic;                                      --! Input clock (Rx USEr clock from transceiver)
         uplinkClkOutEn_o                : out std_logic;                                      --! Clock enable to be USEd in the USEr's logic
         uplinkRst_n_i                   : in  std_logic;                                      --! Uplink reset SIGNAL (Rx ready from the transceiver)
 
         -- Input
 --        mgt_word_i                      : in  std_logic_vector((c_mgtWordWidth-1) downto 0);  --! Input frame coming from the MGT
         mgt_word_i                      : in  std_logic_vector(255 downto 0);
         -- Data
         USErData_o                      : out std_logic_vector(229 downto 0);                 --! User output (decoded data). The payload size varies depENDing on the
                                                                                                     --! datarate/FEC configuration:
                                                                                                     --!     * *FEC5 / 5.12 Gbps*: 112bit
                                                                                                     --!     * *FEC12 / 5.12 Gbps*: 98bit
                                                                                                     --!     * *FEC5 / 10.24 Gbps*: 230bit
                                                                                                     --!     * *FEC12 / 10.24 Gbps*: 202bit
         EcData_o                        : out std_logic_vector(1 downto 0);                   --! EC field value received from the LpGBT
         IcData_o                        : out std_logic_vector(1 downto 0);                   --! IC field value received from the LpGBT
 
         -- Control
         bypassInterleaver_i             : in  std_logic;                                      --! Bypass uplink interleaver (test purpose only)
         bypassFECEncoder_i              : in  std_logic;                                      --! Bypass uplink FEC (test purpose only)
         bypassScrambler_i               : in  std_logic;                                      --! Bypass uplink scrambler (test purpose only)
 
         -- Transceiver control
--         mgt_bitslipCtrl_o               : out std_logic;                                      --! Control the Bitslib/RxSlide PORT of the Mgt
 
         -- Status
         dataCorrected_o                 : out std_logic_vector(229 downto 0);                 --! Flag allowing to know which bit(s) were toggled by the FEC
         IcCorrected_o                   : out std_logic_vector(1 downto 0);                   --! Flag allowing to know which bit(s) of the IC field were toggled by the FEC
         EcCorrected_o                   : out std_logic_vector(1 downto 0);                   --! Flag allowing to know which bit(s) of the EC field  were toggled by the FEC
         rdy_o                           : out std_logic                                       --! Ready SIGNAL from the uplink decoder
    );
    END COMPONENT;
    
    ---- Inputs ----
--    SIGNAL clk_slow, clk_system : STD_LOGIC; -- The clk_slow is the clock of the user to insert data
    SIGNAL clk_system,clk_des                   : STD_LOGIC; -- The clk_slow is the clock of the user to insert data
    SIGNAL clk_system_en                        : STD_LOGIC := '1';
    SIGNAL reset,resetDes                       : STD_LOGIC := '0'; -- The clk_system is the clock of the sistem
    SIGNAL reset_s                              : STD_LOGIC;
--    SIGNAL send_en, receive_en      : STD_LOGIC ; 
    SIGNAL lpgbt_downlink_36b_i	                        : STD_LOGIC_VECTOR(35 DOWNTO 0); 
    
    
--    --- Outputs ----
--    SIGNAL ready_enc,ready_dec   : STD_LOGIC;
    SIGNAL lpgbt_downlink_64b_outEnc_s	                        : STD_LOGIC_VECTOR(63 DOWNTO 0); 
    SIGNAL lpgbt_downlink_36b_o                                 : STD_LOGIC_VECTOR(35 DOWNTO 0);
    SIGNAL lpgbt_downlink_64b_chn_s                             : STD_LOGIC_VECTOR(63 DOWNTO 0);
--    SIGNAL error_signal_dec : std_logic;
    
--    --- Internal Signals ----
    SIGNAL error_data                           : STD_LOGIC_VECTOR(63 DOWNTO 0);
    SIGNAL error_enable                         : STD_LOGIC := '0';
    SIGNAL downlink_out_error                   : std_logic;
    SIGNAL uplink_out_error                     : std_logic;   
    SIGNAL interleaverBypass_s                  : std_logic;                                      --! Bypass downlink interleaver (test purpose only)
    SIGNAL encoderBypass_s                      : std_logic;                                      --! Bypass downlink FEC (test purpose only)
    SIGNAL scramblerBypass_s                    : std_logic;                                      --! Bypass downlink scrambler (test purpose only)
    SIGNAL ready_out                            : std_logic;
    SIGNAL lpgbt_downlink_36b_aux_s             : STD_LOGIC_VECTOR(35 DOWNTO 0);
    SIGNAL lpgbt_downlink_36b_aux1_s            : STD_LOGIC_VECTOR(35 DOWNTO 0);    
    SIGNAL lpgbt_uplink_234b_aux_s              : STD_LOGIC_VECTOR(233 DOWNTO 0);
    SIGNAL lpgbt_uplink_234b_aux1_s             : STD_LOGIC_VECTOR(233 DOWNTO 0);
    SIGNAL lpgbt_uplink_116b_FEC5_5G12_in_s     : STD_LOGIC_VECTOR(115 DOWNTO 0);
    SIGNAL lpgbt_uplink_234b_FEC5_10G24_in_s    : STD_LOGIC_VECTOR(233 DOWNTO 0);
    SIGNAL lpgbt_uplink_206b_FEC12_10G24_in_s   : STD_LOGIC_VECTOR(205 DOWNTO 0);
    SIGNAL lpgbt_uplink_102b_FEC12_5G12_in_s    : STD_LOGIC_VECTOR(101 DOWNTO 0);
    SIGNAL lpgbt_uplink_116b_FEC5_5G12_out_s    : STD_LOGIC_VECTOR(115 DOWNTO 0);
    SIGNAL lpgbt_uplink_234b_FEC5_10G24_out_s   : STD_LOGIC_VECTOR(233 DOWNTO 0);
    SIGNAL lpgbt_uplink_206b_FEC12_10G24_out_s  : STD_LOGIC_VECTOR(205 DOWNTO 0);
    SIGNAL lpgbt_uplink_102b_FEC12_5G12_out_s   : STD_LOGIC_VECTOR(101 DOWNTO 0);                
    
    
    -- Uplink Signals
    SIGNAL lpgbt_uplink_234b_in_s             : STD_LOGIC_VECTOR(233 DOWNTO 0);
    SIGNAL lpgbt_uplink_229b_USR_s            : STD_LOGIC_VECTOR(229 DOWNTO 0);
    SIGNAL lpgbt_uplink_2b_EC_s               : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL lpgbt_uplink_2b_IC_s               : STD_LOGIC_VECTOR(1 DOWNTO 0);
    
    SIGNAL lpgbt_uplink_234b_out_s            : STD_LOGIC_VECTOR(233 DOWNTO 0);
    SIGNAL lpgbt_uplink_229b_USR_out_s        : STD_LOGIC_VECTOR(229 DOWNTO 0);
    SIGNAL lpgbt_uplink_2b_EC_out_s           : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL lpgbt_uplink_2b_IC_out_s           : STD_LOGIC_VECTOR(1 DOWNTO 0);  
    
    SIGNAL lpgbt_uplink_255b_outEnc_s	      : STD_LOGIC_VECTOR(255 DOWNTO 0);    
    SIGNAL lpgbt_uplink_255b_chn_s            : STD_LOGIC_VECTOR(255 DOWNTO 0);
    SIGNAL lpgbt_uplink_dataCorr_s            : STD_LOGIC_VECTOR(229 DOWNTO 0);      --! Flag allowing to know which bit(s) were toggled by the FEC
    SIGNAL lpgbt_uplink_IcCorr_s              : STD_LOGIC_VECTOR(1 DOWNTO 0);      --! Flag allowing to know which bit(s) of the IC field were toggled by the FEC
    SIGNAL lpgbt_uplink_EcCorr_s              : STD_LOGIC_VECTOR(1 DOWNTO 0);
    
    SIGNAL error_uplink_data                  :STD_LOGIC_VECTOR(255 DOWNTO 0);
    
    ----- Constants of the periods -----
--    CONSTANT clk_slow_period 		: TIME :=  7 ns; -- The ratio is 7 periods to clk_slow to 1 period to clk_system
    CONSTANT clk_system_period 		: TIME := 50 ns; --  The ratio have to be this ratio because of the FIFO    
    CONSTANT reset_period 			: TIME := 50 ns;
    CONSTANT reset_period_des   	: TIME := 200 ns; -- The reset descrambler period is 2*reset_period
    CONSTANT error_period_inactive	: TIME := 300 ns;
    CONSTANT error_period_active	: TIME := 50 ns;
    
BEGIN

     --Instância da Unit Under test (UUT)
    uut0: lpgbtfpga_downlink_enc 
        GENERIC MAP(
            -- Expert parameters
            c_multicyleDelay              => 0,               --! Multicycle delay: USEd to relax the timing constraints
            c_clockRatio                  => 8,               --! Clock ratio is clock_out / 40 (shall be an integer - E.g.: 320/40 = 8)
            c_outputWidth                 => 64               --! Transceiver's word size
        )         
        PORT MAP(
            -- Clocks
            clk_i                         => clk_system,      --! Downlink datapath clock (either 320 or 40MHz)
            clkEn_i                       => clk_system_en,   --! Clock enable (1 over 8 WHEN encoding runs @ 320Mhz, '1' @ 40MHz)
            rst_n_i                       => reset,           --! Downlink reset SIGNAL (Tx ready from the transceiver)
     
            -- Down link
            USErData_i                    => lpgbt_downlink_36b_i(31 downto 0),      --! Downlink data (USEr)
            ECData_i                      => lpgbt_downlink_36b_i(33 downto 32),     --! Downlink EC field
            ICData_i                      => lpgbt_downlink_36b_i(35 downto 34),     --! Downlink IC field
     
            -- Output
            --mgt_word_o                    : out std_logic_vector((c_outputWidth-1) downto 0);   --! Downlink encoded frame (IC + EC + User Data + FEC)
            encodedFrame_o                => lpgbt_downlink_64b_outEnc_s,                  --! Downlink encoded frame (IC + EC + User Data + FEC)
         
            -- Configuration
            interleaverBypass_i           => interleaverBypass_s,          --! Bypass downlink interleaver (test purpose only)
            encoderBypass_i               => encoderBypass_s,              --! Bypass downlink FEC (test purpose only)
            scramblerBypass_i             => scramblerBypass_s,            --! Bypass downlink scrambler (test purpose only)
    
            -- Status
            rdy_o                        => ready_out                      --! Downlink ready status            
        );
            
     --Instância da Unit Under test (UUT)
     uut1: lpgbtfpga_downlink_dec 
        GENERIC MAP(            
            -- Expert parameters
            c_multicyleDelay              => 0,               --! Multicycle delay: USEd to relax the timing constraints
            c_clockRatio                  => 8,               --! Clock ratio is clock_out / 40 (shall be an integer - E.g.: 320/40 = 8)
            c_outputWidth                 => 64               --! Transceiver's word size
         )   
       
        PORT MAP(
            -- Clocks
            clk_i                         => clk_system,      --! Downlink datapath clock (either 320 or 40MHz)
            clkEn_i                       => clk_system_en,   --! Clock enable (1 over 8 WHEN encoding runs @ 320Mhz, '1' @ 40MHz)
            rst_n_i                       => reset,           --! Downlink reset SIGNAL (Tx ready from the transceiver)
             
            -- Down link
            encodedFrame_i                => lpgbt_downlink_64b_chn_s,         --! Downlink encoded frame (IC + EC + User Data + FEC)  
   
            -- Output
            --mgt_word_o                    : out std_logic_vector((c_outputWidth-1) downto 0);   --! Downlink encoded frame (IC + EC + User Data + FEC)        
            USErData_o                    => lpgbt_downlink_36b_o(31 downto 0),       --! Downlink data (USEr)
            ECData_o                      => lpgbt_downlink_36b_o(33 downto 32),      --! Downlink EC field
            ICData_o                      => lpgbt_downlink_36b_o(35 downto 34),      --! Downlink IC field
           
            -- Configuration
            interleaverBypass_i           => interleaverBypass_s,          --! Bypass downlink interleaver (test purpose only)
            encoderBypass_i               => encoderBypass_s,              --! Bypass downlink FEC (test purpose only)
            scramblerBypass_i             => scramblerBypass_s,            --! Bypass downlink scrambler (test purpose only)
    
            -- Status
            rdy_o                        => ready_out                      --! Downlink ready status            
     );
          --Instância da Unit Under test (UUT)
     uut2: lpgbtfpga_uplink_enc 
        GENERIC MAP(
            DATARATE                      => DataRateMode,
            FEC                           => FecMode,
            -- Expert parameters
            c_multicyleDelay              => 0               --! Multicycle delay: USEd to relax the timing constraints
--            c_clockRatio                  => 8,               --! Clock ratio is clock_out / 40 (shall be an integer - E.g.: 320/40 = 8)
--            c_outputWidth                 => 64               --! Transceiver's word size
         )   
       
        PORT MAP(
            -- Clocks
            uplinkClk_i                    => clk_system,      --! Downlink datapath clock (either 320 or 40MHz)
            uplinkClkOutEn_o               => clk_system_en,   --! Clock enable (1 over 8 WHEN encoding runs @ 320Mhz, '1' @ 40MHz)
            uplinkRst_n_i                  => reset,           --! Downlink reset SIGNAL (Tx ready from the transceiver)
             
            -- Input
            USErData_i                    => lpgbt_uplink_229b_USR_s,      --! Downlink data (USEr)
            ECData_i                      => lpgbt_uplink_2b_EC_s,     --! Downlink EC field
            ICData_i                      => lpgbt_uplink_2b_IC_s,     --! Downlink IC field
      
            -- Output
            --mgt_word_o                    : out std_logic_vector((c_outputWidth-1) downto 0);   --! Downlink encoded frame (IC + EC + User Data + FEC)        
            word_o                         => lpgbt_uplink_255b_outEnc_s,       --! Downlink data (USEr)
 
            -- Configuration
            bypassInterleaver_i           => interleaverBypass_s,          --! Bypass downlink interleaver (test purpose only)
            bypassFECEncoder_i               => encoderBypass_s,              --! Bypass downlink FEC (test purpose only)
            bypassScrambler_i             => scramblerBypass_s,            --! Bypass downlink scrambler (test purpose only)
    
            -- Status
            rdy_o                        => ready_out                      --! Downlink ready status            
     );
     
               --Instância da Unit Under test (UUT)
    uut3: lpgbtfpga_uplink_dec 
        GENERIC MAP(
            DATARATE                      => DataRateMode,
            FEC                           => FecMode,
            -- Expert parameters
            c_multicyleDelay              => 0               --! Multicycle delay: USEd to relax the timing constraints
--            c_clockRatio                  => 8,               --! Clock ratio is clock_out / 40 (shall be an integer - E.g.: 320/40 = 8)
--            c_outputWidth                 => 64               --! Transceiver's word size
        )   
  
        PORT MAP(
            -- Clocks
            uplinkClk_i                   => clk_system,      --! Downlink datapath clock (either 320 or 40MHz)
            uplinkClkOutEn_o              => clk_system_en,   --! Clock enable (1 over 8 WHEN encoding runs @ 320Mhz, '1' @ 40MHz)
            uplinkRst_n_i                 => reset,           --! Downlink reset SIGNAL (Tx ready from the transceiver)
        
            -- Down link
            mgt_word_i                    => lpgbt_uplink_255b_chn_s,         --! Downlink encoded frame (IC + EC + User Data + FEC)  

            -- Output
            --mgt_word_o                    : out std_logic_vector((c_outputWidth-1) downto 0);   --! Downlink encoded frame (IC + EC + User Data + FEC)        
            USErData_o                    => lpgbt_uplink_229b_USR_out_s,     --! Downlink data (USEr)
            ECData_o                      => lpgbt_uplink_2b_EC_out_s,      --! Downlink EC field
            ICData_o                      => lpgbt_uplink_2b_IC_out_s,      --! Downlink IC field
      
            -- Configuration
            bypassInterleaver_i           => interleaverBypass_s,          --! Bypass downlink interleaver (test purpose only)
            bypassFECEncoder_i            => encoderBypass_s,              --! Bypass downlink FEC (test purpose only)
            bypassScrambler_i             => scramblerBypass_s,            --! Bypass downlink scrambler (test purpose only)
                
            dataCorrected_o               => lpgbt_uplink_dataCorr_s,                 --! Flag allowing to know which bit(s) were toggled by the FEC
            IcCorrected_o                 => lpgbt_uplink_IcCorr_s,                   --! Flag allowing to know which bit(s) of the IC field were toggled by the FEC
            EcCorrected_o                 => lpgbt_uplink_EcCorr_s,                   --! Flag allowing to know which bit(s) of the EC field  were toggled by the FEC

                
            -- Status
            rdy_o                        => ready_out                      --! Downlink ready status            
        );              
-- Processo de estímulo
	---------- Generation Input Data (Downlink)  ------------
    stp: PROCESS (clk_system)
    BEGIN
    	IF falling_edge(clk_system) THEN
        	IF reset_s = '1' THEN
            	--lpgbt_downlink_36b_i <= (others => '0');
            	lpgbt_downlink_36b_i <= x"bbbff47af";
        	ELSE   
                lpgbt_downlink_36b_i <= STD_LOGIC_VECTOR(UNSIGNED(lpgbt_downlink_36b_i) + 1);
            END IF;               
        END IF;          
    END PROCESS;
	--------------------------------------------------
	---------- Generation Input Data (Uplink)------------
    UplinkDataGenInput: PROCESS (clk_system)
    BEGIN
        IF falling_edge(clk_system) THEN
            IF reset_s = '1' THEN            
                IF FecMode = FEC5 THEN                                        
                    IF DataRateMode = DATARATE_5G12 THEN
                        -- IcData_i & EcData_i & USErData_i(111 downto 0)
                        -- lpgbt_uplink_234b_in_s <= (others => '0');
                        -- x"0" & "00" & x"0 0000 0000 0000 0000 0000 0000 0009 2ecf 791e 82ba c4f6d 46bb bbff 47af";
                        lpgbt_uplink_234b_in_s <= "00" & x"000000000000000000000000000002ecf791e82bac4f6d46bbbbff47af";
                    ELSE --DataRateMode = DATARATE_10G24
                        -- IcData_i   & EcData_i     & USErData_i(229 downto 0)
                        -- lpgbt_uplink_234b_in_s <= (others => '0');
                        -- x"9" & "10" & x"f 3995 e546 4ecf 1a0f 3a2b c2a7 6fb2 2ecf 791e 82ba c4f6d 46bb bbff 47af";
                        lpgbt_uplink_234b_in_s <= "10" & x"13995e5464ecf1a0f3a2bc2a76fb22ecf791e82bac4f6d46bbbbff47af";        
                    END IF;
                ELSE -- FecMode = FEC12
                    IF DataRateMode = DATARATE_5G12 THEN
                        -- IcData_i   & EcData_i     & USErData_i(201 downto 0)
                        -- lpgbt_uplink_234b_in_s <= (others => '0');
                        -- x"0" & "00" & x"0 0000 0000 0000 0000 0000 0000 0009 0000 0006 82ba c4f6d 46bb bbff 47af";                                                         
                        lpgbt_uplink_234b_in_s <= "00" & x"000000000000000000000000000000002c52682bac4f6d46bbbbff47af";
                    ELSE -- DataRateMode = DATARATE_10G24 
                        -- IcData_i    & EcData_i   & USErData_i(97 downto 0)
                        -- lpgbt_uplink_234b_in_s <= (others => '0');
                        -- x"0" & "00" & x"0 0000 000" & "0" & "111" x"4ecf 1a0f 3a2b c2a7 6fb2 2ecf 791e 82ba c4f6d 46bb bbff 47af";
                        lpgbt_uplink_234b_in_s <= "00" & x"00000000" & "0" & "111" & x"4ecf1a0f3a2bc2a76fb22ecf791e82bac4f6d46bbbbff47af";                              
                    END IF;
                END IF;                
            ELSE   
                lpgbt_uplink_234b_in_s <= STD_LOGIC_VECTOR(UNSIGNED(lpgbt_uplink_234b_in_s) + 1);
            END IF;               
        END IF;          
    END PROCESS;
    --------------------------------------------------
	---------- Comparison Error Data  ----------------
	captureDataForComparison: PROCESS (clk_system)
    BEGIN
        IF rising_edge(clk_system) THEN
            IF reset_s = '1' THEN                
                lpgbt_downlink_36b_aux_s <= x"ea5a847af";
                lpgbt_downlink_36b_aux1_s <= (OTHERS => '0'); 
            ELSE               
                lpgbt_downlink_36b_aux_s <= lpgbt_downlink_36b_i;
                lpgbt_downlink_36b_aux1_s <= lpgbt_downlink_36b_aux_s;
            END IF;
         END IF;          
    END PROCESS;
	stp2: PROCESS (clk_system)
	BEGIN
		IF rising_edge(clk_system) THEN
	    	IF reset_s = '1' THEN	            
	            downlink_out_error <= '0';
	        ELSE	           
	        	IF lpgbt_downlink_36b_aux1_s = lpgbt_downlink_36b_o THEN  -- If the last data is in the output --
	        	    downlink_out_error <= '0';
	            ELSE 
	            	downlink_out_error <= '1';	            
	            END IF;               
	        END IF;
	    END IF;          
	END PROCESS;
	----------------------------------------------------
	------------- Generation of clk_system ---------------
    clk_system_gen: PROCESS
    BEGIN
        clk_system <= '0';
        WAIT FOR clk_system_period/2;
        clk_system <= '1';
        WAIT FOR clk_system_period/2;
    END PROCESS;
    ----------------------------------------------------
    ------------- Generation of reset ------------------
    stp3: PROCESS
    BEGIN
        WAIT FOR reset_period;
        reset <= '1';
    END PROCESS;
    ----------------------------------------------------
    ------------- Generation of reset descrambler ------------------
    stp4: PROCESS
    BEGIN
        WAIT FOR reset_period_des;
        resetDes <= '1';
    END PROCESS;
	-------- Generation of the input Data XOR ----------    
  	dataError: PROCESS (clk_system)
    BEGIN
    	IF rising_edge(clk_system) THEN
    		IF reset_s = '1' THEN
    			error_data <= x"00000003ff000000";
    		ELSE
    			error_data <= std_logic_vector((unsigned(error_data) rol 1));
    		END IF;    
        END IF;    	          
    END PROCESS dataError;
	----------------------------------------------------
	----------- PROCESS XOR / Input Decoder ------------        
--	XOR_input: PROCESS (clk_system)
--    BEGIN
--    	IF rising_edge(clk_system) THEN
--    		IF reset_s = '1' THEN
--    			lpgbt_downlink_64b_chn_s <= lpgbt_downlink_64b_outEnc_s;
--    		ELSE
--    			IF error_enable = '1' THEN
--    				lpgbt_downlink_64b_chn_s <= lpgbt_downlink_64b_outEnc_s XOR error_data;
--    			ELSE
--    				lpgbt_downlink_64b_chn_s <= lpgbt_downlink_64b_outEnc_s;
--    			END IF;
--    		END IF;
--    	END IF;
--    END PROCESS XOR_input;
    lpgbt_downlink_64b_chn_s <= lpgbt_downlink_64b_outEnc_s                  WHEN reset_s ='1' ELSE
                                (lpgbt_downlink_64b_outEnc_s XOR error_data) WHEN error_enable = '1' ELSE
                                lpgbt_downlink_64b_outEnc_s;
    ----------------------------------------------------
    --------- Generation of error ------------------
    generation_error: PROCESS
    BEGIN
    	WAIT FOR error_period_inactive;
    	--error_enable <= '1';
    	error_enable <= '1';
    	WAIT FOR error_period_active;
    	error_enable <= '0';
    END PROCESS generation_error;
    --------------------------------------------------
    --------- Generation of bypass ------------------
    interleaverBypass_s <= '0';
    encoderBypass_s     <= '0';
    scramblerBypass_s   <= '0';              
    --------------------------------------------------
    reset_s <= not(reset); 
    clk_system_en <= '1';

    ---------- Generation Output Data (Uplink)------------ ---------------------------------------                                                                       
    lpgbt_uplink_234b_out_s <= x"00000000000000000000000000000" & "00" & lpgbt_uplink_2b_IC_out_s & lpgbt_uplink_2b_EC_out_s  & lpgbt_uplink_229b_USR_out_s(111 downto 0) WHEN (FecMode = FEC5) and (DataRateMode = DATARATE_5G12) ELSE                               
                               lpgbt_uplink_2b_IC_out_s & lpgbt_uplink_2b_EC_out_s & lpgbt_uplink_229b_USR_out_s(229 downto 0)                                            WHEN (FecMode = FEC5) and (DataRateMode = DATARATE_10G24) ELSE                               
                               x"0000000" & lpgbt_uplink_2b_IC_out_s & lpgbt_uplink_2b_EC_out_s & lpgbt_uplink_229b_USR_out_s(201 downto 0)                               WHEN (FecMode = FEC12) and (DataRateMode = DATARATE_10G24) ELSE                               
                               x"000000000000000000000000000000000" & lpgbt_uplink_2b_IC_out_s & lpgbt_uplink_2b_EC_out_s & lpgbt_uplink_229b_USR_out_s(97 downto 0);
    ---------- Generation Input Data (Uplink)-----------------------------------------------------------------
    lpgbt_uplink_229b_USR_s <= x"0000000000000000000000000000" & "00" & x"0"  & lpgbt_uplink_234b_in_s (111 downto 0) WHEN (FecMode = FEC5) and (DataRateMode = DATARATE_5G12) ELSE
                               lpgbt_uplink_234b_in_s (229 downto 0)                                                  WHEN (FecMode = FEC5) and (DataRateMode = DATARATE_10G24) ELSE
                               x"000000" & x"0" & lpgbt_uplink_234b_in_s (201 downto 0)                               WHEN (FecMode = FEC12) and (DataRateMode = DATARATE_10G24) ELSE
                               x"00000000000000000000000000000000" & x"0" & lpgbt_uplink_234b_in_s(97 downto 0);  -- FecMode = FEC12 / DataRateMode = DATARATE_10G24 
                               
    lpgbt_uplink_2b_EC_s    <= lpgbt_uplink_234b_in_s (113 downto 112) WHEN (FecMode = FEC5) and (DataRateMode = DATARATE_5G12) ELSE
                               lpgbt_uplink_234b_in_s (231 downto 230) WHEN (FecMode = FEC5) and (DataRateMode = DATARATE_10G24) ELSE
                               lpgbt_uplink_234b_in_s (203 downto 202) WHEN (FecMode = FEC12) and (DataRateMode = DATARATE_10G24) ELSE
                               lpgbt_uplink_234b_in_s (99 downto 98);  -- FecMode = FEC12  / DataRateMode = DATARATE_10G24 
    lpgbt_uplink_2b_IC_s    <= lpgbt_uplink_234b_in_s (115 downto 114) WHEN (FecMode = FEC5) and (DataRateMode = DATARATE_5G12) ELSE
                               lpgbt_uplink_234b_in_s (233 downto 232) WHEN (FecMode = FEC5) and (DataRateMode = DATARATE_10G24) ELSE
                               lpgbt_uplink_234b_in_s (205 downto 204) WHEN (FecMode = FEC12) and (DataRateMode = DATARATE_10G24) ELSE
                               lpgbt_uplink_234b_in_s (101 downto 100); -- FecMode = FEC12 / DataRateMode = DATARATE_10G24

    ---------- Generation Output Data (Uplink)------------ ---------------------------------------                                                                       
    lpgbt_uplink_116b_FEC5_5G12_in_s   <= lpgbt_uplink_2b_IC_s & lpgbt_uplink_2b_EC_s  & lpgbt_uplink_229b_USR_s(111 downto 0) WHEN (FecMode = FEC5) and (DataRateMode = DATARATE_5G12) ELSE
                                          (OTHERS => 'Z');                               
    lpgbt_uplink_234b_FEC5_10G24_in_s  <= lpgbt_uplink_2b_IC_s & lpgbt_uplink_2b_EC_s & lpgbt_uplink_229b_USR_s(229 downto 0)  WHEN (FecMode = FEC5) and (DataRateMode = DATARATE_10G24) ELSE
                                          (OTHERS => 'Z');                               
    lpgbt_uplink_206b_FEC12_10G24_in_s  <= lpgbt_uplink_2b_IC_s & lpgbt_uplink_2b_EC_s & lpgbt_uplink_229b_USR_s(201 downto 0) WHEN (FecMode = FEC12) and (DataRateMode = DATARATE_10G24) ELSE
                                          (OTHERS => 'Z');                                
    lpgbt_uplink_102b_FEC12_5G12_in_s <= lpgbt_uplink_2b_IC_s & lpgbt_uplink_2b_EC_s & lpgbt_uplink_229b_USR_s(97 downto 0) WHEN (FecMode = FEC12) and (DataRateMode = DATARATE_5G12) ELSE
                                           (OTHERS => 'Z');
    
    lpgbt_uplink_116b_FEC5_5G12_out_s   <= lpgbt_uplink_2b_IC_out_s & lpgbt_uplink_2b_EC_out_s  & lpgbt_uplink_229b_USR_out_s(111 downto 0) WHEN (FecMode = FEC5) and (DataRateMode = DATARATE_5G12) ELSE
                                           (OTHERS => 'Z');                               
    lpgbt_uplink_234b_FEC5_10G24_out_s  <= lpgbt_uplink_2b_IC_out_s & lpgbt_uplink_2b_EC_out_s & lpgbt_uplink_229b_USR_out_s(229 downto 0)  WHEN (FecMode = FEC5) and (DataRateMode = DATARATE_10G24) ELSE
                                           (OTHERS => 'Z');                               
    lpgbt_uplink_206b_FEC12_10G24_out_s  <= lpgbt_uplink_2b_IC_out_s & lpgbt_uplink_2b_EC_out_s & lpgbt_uplink_229b_USR_out_s(201 downto 0) WHEN (FecMode = FEC12) and (DataRateMode = DATARATE_10G24) ELSE
                                           (OTHERS => 'Z');                                
    lpgbt_uplink_102b_FEC12_5G12_out_s <= lpgbt_uplink_2b_IC_out_s & lpgbt_uplink_2b_EC_out_s & lpgbt_uplink_229b_USR_out_s(97 downto 0) WHEN (FecMode = FEC12) and (DataRateMode = DATARATE_5G12) ELSE
                                            (OTHERS => 'Z');                                         
                                                              
    -------- Generation of the input Data XOR ----------    
    uplinkErrorDataGen: PROCESS (clk_system)
    BEGIN
       IF rising_edge(clk_system) THEN
           IF reset_s = '1' THEN
               --error_uplink_data <= x"000000000000000000000000000000000000000000000000000000f1f000000"; --5G12FEC5WithError
               error_uplink_data <= x"0000000000000000000000000000000000000000000000ffffff000000000000";
           ELSE
               error_uplink_data <= std_logic_vector((unsigned(error_uplink_data) rol 1));
           END IF;    
       END IF;                  
    END PROCESS uplinkErrorDataGen;
    ----------------------------------------------------
    ----------- PROCESS XOR / Input Decoder ------------        
    lpgbt_uplink_255b_chn_s <= lpgbt_uplink_255b_outEnc_s WHEN reset_s ='1' ELSE
              (lpgbt_uplink_255b_outEnc_s XOR error_uplink_data) WHEN error_enable = '1' ELSE
              lpgbt_uplink_255b_outEnc_s;
    ----------------------------------------------------                                                                                                                             

	---------- Comparison Uplink Error Data  ----------------
	captureUplinkDataForComparison: PROCESS (clk_system)
        BEGIN
            IF rising_edge(clk_system) THEN
                IF reset_s = '1' THEN                
                    IF FecMode = FEC5 THEN
                        IF DataRateMode = DATARATE_5G12 THEN                  
                            lpgbt_uplink_234b_aux_s <= x"00000000000000000000000000000" & "00" & x"61bcc57eea11ebd86f315fba847af";
                        ELSE -- DataRateMode = DATARATE_10G24 THEN
                            lpgbt_uplink_234b_aux_s <= "00" & x"3dbcc57eea11ebd86f315fba847af61bcc57eea11ebd86f315fba847af";
                        END IF;
                    ELSE --FecMode = FEC12 THEN
                        IF DataRateMode = DATARATE_10G24 THEN                            
                            lpgbt_uplink_234b_aux_s <= "00" & x"00000039172bf7508f5f22e57eea11ebe45cafdd423d7c8b95fba847af";
                        ELSE -- DataRateMode = DATARATE_10G24 THEN
                                                              
                            lpgbt_uplink_234b_aux_s <= "00" & x"00000000000000000000000000000000245cafdd423d7c8b95fba847af";
                        END IF;
                    END IF;
                    lpgbt_uplink_234b_aux1_s <= (OTHERS => '0');
                ELSE               
                   lpgbt_uplink_234b_aux_s <= lpgbt_uplink_234b_in_s;
                   lpgbt_uplink_234b_aux1_s <= lpgbt_uplink_234b_aux_s;
                END IF;
            END IF;          
    END PROCESS;
	errorUplink: PROCESS (clk_system)
	BEGIN
		IF rising_edge(clk_system) THEN
	    	IF reset_s = '1' THEN	            
	            uplink_out_error <= '0';
	        ELSE	           
	        	IF lpgbt_uplink_234b_aux1_s = lpgbt_uplink_234b_out_s THEN  -- If the last data is in the output --
	        	    uplink_out_error <= '0';
	            ELSE 
	            	uplink_out_error <= '1';	            
	            END IF;               
	        END IF;
	    END IF;          
	END PROCESS;
         
end Behavioral;
