----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.08.2020 00:08:59
-- Design Name: 
-- Module Name: lpgbt_uplink_interleaver - Behavioral
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

--! Include the lpGBT-FPGA specific package
library xil_defaultlib;
use xil_defaultlib.lpgbtfpga_package.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lpgbt_uplink_interleaver is
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
        
        fec_data_o                      : out  std_logic_vector(255 downto 0);
--        fec5_data_o                     : out  std_logic_vector(255 downto 0);   --! Input frame from the Rx gearbox (data shall be duplicated in upper/lower part of the frame @5.12Gbps)
--        fec12_data_o                    : out  std_logic_vector(255 downto 0);   --! Input frame from the Rx gearbox (data shall be duplicated in upper/lower part of the frame @5.12Gbps)
        -- Control
        bypass                          : in  std_logic                         --! Bypass uplink interleaver (test purpose only)
    );
end lpgbt_uplink_interleaver;


--! @brief lpgbt_uplink_deinterleaver - Uplink data de-interleaver
--! @details The lpgbt_uplink_deinterleaver routes the data from the MGT to recover
--! the message (symbols) and FEC. It implements both FEC5 and FEC12
--! de-interleaver modules to reconstruct the data for both configuration.
architecture Behavioral of lpgbt_uplink_interleaver is


    --! FEC5 de-interleaver component
    COMPONENT upLinkDeinterleaver_fec5
       GENERIC(
            DATARATE                        : integer RANGE 0 TO 2 := DATARATE_5G12
       );
       PORT (
            -- Data
            data_i                          : in  std_logic_vector(255 downto 0);

            data_o                          : out std_logic_vector(233 downto 0);
            fec_o                           : out std_logic_vector(19 downto 0);

            -- Control
            bypass                          : in  std_logic
       );
    END COMPONENT;

    --! FEC12 de-interleaver component
    COMPONENT upLinkDeinterleaver_fec12
       GENERIC(
            DATARATE                        : integer RANGE 0 TO 2 := DATARATE_5G12
       );
       PORT (
            -- Data
            data_i                          : in  std_logic_vector(255 downto 0);

            data_o                          : out std_logic_vector(205 downto 0);
            fec_o                           : out std_logic_vector(47 downto 0);

            -- Control
            bypass                          : in  std_logic
       );
    END COMPONENT;

    SIGNAL fec5_o_5g12_s        : std_logic_vector(255 downto 0);  --! Data output for 5.12Gbps configuration

    SIGNAL fec5_o_10g24_s       : std_logic_vector(255 downto 0);  --! Data output for 10.24Gbps configuration
 
    SIGNAL fec12_o_5g12_s       : std_logic_vector(255 downto 0);  --! Data output for 5.12Gbps configuration

    SIGNAL fec12_o_10g24_s      : std_logic_vector(255 downto 0);  --! Data output for 10.24Gbps configuration


    SIGNAL fec5_data_s             : std_logic_vector(255 downto 0);  --! FEC5 data from de-interleaver
    SIGNAL fec12_data_s            : std_logic_vector(255 downto 0);  --! FEC12 data from de-interleaver
    SIGNAL fec12_fec_s             : std_logic_vector(47 downto 0);   --! FEC12 FEC from de-interleaver

BEGIN                 --========####   Architecture Body   ####========--

    fec5_gen: IF FEC = FEC5 GENERATE

        fec5_5g12: IF DATARATE = DATARATE_5G12 GENERATE

            -- Code 0
            fec5_o_5g12_s(127 downto 126)    <= "10";
            fec5_o_5g12_s(125 downto 10)     <= fec5_data_i(115 downto 0);
            fec5_o_5g12_s(9 downto 0)        <= fec5_fec_i(9 downto 0);            

            -- Code 1 (Not USEd @5.12Gbps - THEN USEs 2nd phase of data)
            fec5_o_5g12_s(255 downto 254)    <= "10";            
            fec5_o_5g12_s(253 downto 138)    <= fec5_data_i(232 downto 117);
            fec5_o_5g12_s(137 downto 128)    <= fec5_fec_i(19 downto 10);                        

        END GENERATE;

        fec5_10g24: IF DATARATE = DATARATE_10G24 GENERATE

            -- Code 0
            fec5_o_10g24_s(253 downto 252)  <= fec5_data_i(233 downto 232);
            fec5_o_10g24_s(251 downto 250)  <= fec5_data_i(116 downto 115);
            fec5_o_10g24_s(244 downto 240)  <= fec5_data_i(114 downto 110);
            fec5_o_10g24_s(234 downto 230)  <= fec5_data_i(109 downto 105);
            fec5_o_10g24_s(224 downto 220)  <= fec5_data_i(104 downto 100);
            fec5_o_10g24_s(214 downto 210)  <= fec5_data_i(99  downto 95);
            fec5_o_10g24_s(204 downto 200)  <= fec5_data_i(94  downto 90);
            fec5_o_10g24_s(194 downto 190)  <= fec5_data_i(89  downto 85);
            fec5_o_10g24_s(184 downto 180)  <= fec5_data_i(84  downto 80);
            fec5_o_10g24_s(174 downto 170)  <= fec5_data_i(79  downto 75);
            fec5_o_10g24_s(164 downto 160)  <= fec5_data_i(74  downto 70);
            fec5_o_10g24_s(154 downto 150)  <= fec5_data_i(69  downto 65);
            fec5_o_10g24_s(144 downto 140)  <= fec5_data_i(64  downto 60);
            fec5_o_10g24_s(134 downto 130)  <= fec5_data_i(59  downto 55);
            fec5_o_10g24_s(124 downto 120)  <= fec5_data_i(54  downto 50);
            fec5_o_10g24_s(114 downto 110)  <= fec5_data_i(49  downto 45);
            fec5_o_10g24_s(104 downto 100)  <= fec5_data_i(44  downto 40);
            fec5_o_10g24_s(94 downto 90)    <= fec5_data_i(39  downto 35);
            fec5_o_10g24_s(84 downto 80)    <= fec5_data_i(34  downto 30);
            fec5_o_10g24_s(74 downto 70)    <= fec5_data_i(29  downto 25);
            fec5_o_10g24_s(64 downto 60)    <= fec5_data_i(24  downto 20);
            fec5_o_10g24_s(54 downto 50)    <= fec5_data_i(19  downto 15);
            fec5_o_10g24_s(44 downto 40)    <= fec5_data_i(14  downto 10);
            fec5_o_10g24_s(34 downto 30)    <= fec5_data_i(9   downto 5 );
            fec5_o_10g24_s(24 downto 20)    <= fec5_data_i(4   downto 0 );


            fec5_o_10g24_s(14 downto 10) <=  fec5_fec_i(9 downto 5);    
            fec5_o_10g24_s(4 downto 0)   <=  fec5_fec_i(4 downto 0);

            -- Code 1
            fec5_o_10g24_s(255 downto 254)  <= "10";
            fec5_o_10g24_s(249 downto 245)  <= fec5_data_i(231 downto 227);
            fec5_o_10g24_s(239 downto 235)  <= fec5_data_i(226 downto 222);
            fec5_o_10g24_s(229 downto 225)  <= fec5_data_i(221 downto 217);
            fec5_o_10g24_s(219 downto 215)  <= fec5_data_i(216 downto 212);
            fec5_o_10g24_s(209 downto 205)  <= fec5_data_i(211 downto 207);
            fec5_o_10g24_s(199 downto 195)  <= fec5_data_i(206 downto 202);
            fec5_o_10g24_s(189 downto 185)  <= fec5_data_i(201 downto 197);
            fec5_o_10g24_s(179 downto 175)  <= fec5_data_i(196 downto 192);
            fec5_o_10g24_s(169 downto 165)  <= fec5_data_i(191 downto 187);
            fec5_o_10g24_s(159 downto 155)  <= fec5_data_i(186 downto 182);
            fec5_o_10g24_s(149 downto 145)  <= fec5_data_i(181 downto 177);
            fec5_o_10g24_s(139 downto 135)  <= fec5_data_i(176 downto 172);
            fec5_o_10g24_s(129 downto 125)  <= fec5_data_i(171 downto 167);
            fec5_o_10g24_s(119 downto 115)  <= fec5_data_i(166 downto 162);
            fec5_o_10g24_s(109 downto 105)  <= fec5_data_i(161 downto 157);
            fec5_o_10g24_s(99  downto 95)   <= fec5_data_i(156 downto 152);
            fec5_o_10g24_s(89  downto 85)   <= fec5_data_i(151 downto 147);
            fec5_o_10g24_s(79  downto 75)   <= fec5_data_i(146 downto 142);
            fec5_o_10g24_s(69  downto 65)   <= fec5_data_i(141 downto 137);
            fec5_o_10g24_s(59  downto 55)   <= fec5_data_i(136 downto 132);
            fec5_o_10g24_s(49  downto 45)   <= fec5_data_i(131 downto 127);
            fec5_o_10g24_s(39  downto 35)   <= fec5_data_i(126 downto 122);
            fec5_o_10g24_s(29  downto 25)   <= fec5_data_i(121 downto 117);

            fec5_o_10g24_s(19 downto 15)     <= fec5_fec_i(19 downto 15);     
            fec5_o_10g24_s(9  downto 5)      <= fec5_fec_i(14 downto 10);

        END GENERATE;

        -- Mux
        fec5_data_s   <= "10" & fec5_data_i & fec5_fec_i WHEN bypass = '1' and (DATARATE = DATARATE_10G24) ELSE
                         fec5_o_5g12_s WHEN bypass = '1' ELSE
                         fec5_o_5g12_s WHEN DATARATE = DATARATE_5G12 ELSE
                         fec5_o_10g24_s;

 

    END GENERATE;

    fec12_gen: IF FEC = FEC12 GENERATE

        fec12_5g12: IF DATARATE = DATARATE_5G12 GENERATE
            fec12_o_5g12_s(127 downto 126)  <= "10"; -- Header
            
            fec12_o_5g12_s(255 downto 254)  <= "10"; -- Duplicate Header (not used)
            
            -- Code 0
            fec12_o_5g12_s(123 downto 122)  <= fec12_data_i(67 downto 66);   
            fec12_o_5g12_s(121 downto 120)  <= fec12_data_i(33 downto 32);
            fec12_o_5g12_s(111 downto 108)  <= fec12_data_i(31 downto 28);
            fec12_o_5g12_s(99 downto 96)    <= fec12_data_i(27 downto 24);
            fec12_o_5g12_s(87 downto 84)    <= fec12_data_i(23 downto 20);
            fec12_o_5g12_s(75 downto 72)    <= fec12_data_i(19 downto 16);
            fec12_o_5g12_s(63 downto 60)    <= fec12_data_i(15 downto 12); 
            fec12_o_5g12_s(51 downto 48)    <= fec12_data_i(11 downto 8);
            fec12_o_5g12_s(39 downto 36)    <= fec12_data_i(7 downto 4);
            fec12_o_5g12_s(27 downto 24)    <= fec12_data_i(3 downto 0);

            -- Code 1
            fec12_o_5g12_s(125 downto 124)  <= fec12_data_i(101 downto 100); 
            fec12_o_5g12_s(115 downto 112)  <= fec12_data_i(65 downto 62); 
            fec12_o_5g12_s(103 downto 100)  <= fec12_data_i(61 downto 58);
            fec12_o_5g12_s(91 downto 88)    <= fec12_data_i(57 downto 54);
            fec12_o_5g12_s(79 downto 76)    <= fec12_data_i(53 downto 50);
            fec12_o_5g12_s(67 downto 64)    <= fec12_data_i(49 downto 46);
            fec12_o_5g12_s(55 downto 52)    <= fec12_data_i(45 downto 42);
            fec12_o_5g12_s(43 downto 40)    <= fec12_data_i(41 downto 38);
            fec12_o_5g12_s(31 downto 28)    <= fec12_data_i(37 downto 34);

            -- Code 2
            fec12_o_5g12_s(119 downto 116)  <= fec12_data_i(99 downto 96);   
            fec12_o_5g12_s(107 downto 104)  <= fec12_data_i(95 downto 92);
            fec12_o_5g12_s(95 downto 92)    <= fec12_data_i(91 downto 88);
            fec12_o_5g12_s(83 downto 80)    <= fec12_data_i(87 downto 84);
            fec12_o_5g12_s(71 downto 68)    <= fec12_data_i(83 downto 80);
            fec12_o_5g12_s(59 downto 56)    <= fec12_data_i(79 downto 76);
            fec12_o_5g12_s(47 downto 44)    <= fec12_data_i(75 downto 72);
            fec12_o_5g12_s(35 downto 32)    <= fec12_data_i(71 downto 68);

            -- "Code 3, 4 & 5" : Duplicates code 0, 1 and 2 with second phase
            fec12_o_5g12_s(251 downto 250)  <= fec12_data_i(169 downto 168);      -- Code 3
            fec12_o_5g12_s(249 downto 248)  <= fec12_data_i(135 downto 134);
            fec12_o_5g12_s(239 downto 236)  <= fec12_data_i(133 downto 130);
            fec12_o_5g12_s(227 downto 224)  <= fec12_data_i(129 downto 126);
            fec12_o_5g12_s(215 downto 212)  <= fec12_data_i(125 downto 122);
            fec12_o_5g12_s(203 downto 200)  <= fec12_data_i(121 downto 118);
            fec12_o_5g12_s(191 downto 188)  <= fec12_data_i(117 downto 114);
            fec12_o_5g12_s(179 downto 176)  <= fec12_data_i(113 downto 110);
            fec12_o_5g12_s(167 downto 164)  <= fec12_data_i(109 downto 106);
            fec12_o_5g12_s(155 downto 152)  <= fec12_data_i(105 downto 102);

            fec12_o_5g12_s(253 downto 252)  <= fec12_data_i(203 downto 202);     -- Code 4
            fec12_o_5g12_s(243 downto 240)  <= fec12_data_i(167 downto 164);
            fec12_o_5g12_s(231 downto 228)  <= fec12_data_i(163 downto 160);
            fec12_o_5g12_s(219 downto 216)  <= fec12_data_i(159 downto 156);
            fec12_o_5g12_s(207 downto 204)  <= fec12_data_i(155 downto 152);
            fec12_o_5g12_s(195 downto 192)  <= fec12_data_i(151 downto 148);
            fec12_o_5g12_s(183 downto 180)  <= fec12_data_i(147 downto 144);
            fec12_o_5g12_s(171 downto 168)  <= fec12_data_i(143 downto 140);
            fec12_o_5g12_s(159 downto 156)  <= fec12_data_i(139 downto 136);

            fec12_o_5g12_s(247 downto 244)  <= fec12_data_i(201 downto 198);    -- Code 5
            fec12_o_5g12_s(235 downto 232)  <= fec12_data_i(197 downto 194);
            fec12_o_5g12_s(223 downto 220)  <= fec12_data_i(193 downto 190);
            fec12_o_5g12_s(211 downto 208)  <= fec12_data_i(189 downto 186);
            fec12_o_5g12_s(199 downto 196)  <= fec12_data_i(185 downto 182);
            fec12_o_5g12_s(187 downto 184)  <= fec12_data_i(181 downto 178);
            fec12_o_5g12_s(175 downto 172)  <= fec12_data_i(177 downto 174);
            fec12_o_5g12_s(163 downto 160)  <= fec12_data_i(173 downto 170);

            -- FEC 0, 1 & 2
            fec12_o_5g12_s(23 downto 20)    <= fec12_fec_i(23 downto 20);
            fec12_o_5g12_s(11 downto 8)     <= fec12_fec_i(19 downto 16);
            fec12_o_5g12_s(19 downto 16)    <= fec12_fec_i(15 downto 12);
            fec12_o_5g12_s(7 downto 4)      <= fec12_fec_i(11 downto 8);
            fec12_o_5g12_s(15 downto 12)    <= fec12_fec_i(7 downto 4);
            fec12_o_5g12_s(3 downto 0)      <= fec12_fec_i(3 downto 0);

            -- FEC 3, 4 & 5: Duplicates FEC 0, 1 and 2 with second phase
            fec12_o_5g12_s(151 downto 148)  <= fec12_fec_i(47 downto 44);    
            fec12_o_5g12_s(139 downto 136)  <= fec12_fec_i(43 downto 40);
            fec12_o_5g12_s(147 downto 144)  <= fec12_fec_i(39 downto 36);
            fec12_o_5g12_s(135 downto 132)  <= fec12_fec_i(35 downto 32);
            fec12_o_5g12_s(143 downto 140)  <= fec12_fec_i(31 downto 28);
            fec12_o_5g12_s(131 downto 128)  <= fec12_fec_i(27 downto 24);

        END GENERATE;

        fec12_10g24: IF DATARATE = DATARATE_10G24 GENERATE
            
            fec12_o_10g24_s(255 downto 254)  <= "10"; -- Header

            -- Code 0
            fec12_o_10g24_s(243 downto 242)  <= fec12_data_i(135 downto 134); 
            fec12_o_10g24_s(241 downto 240)  <= fec12_data_i(33 downto 32);
            fec12_o_10g24_s(219 downto 216)  <= fec12_data_i(31 downto 28);
            fec12_o_10g24_s(195 downto 192)  <= fec12_data_i(27 downto 24);
            fec12_o_10g24_s(171 downto 168)  <= fec12_data_i(23 downto 20);
            fec12_o_10g24_s(147 downto 144)  <= fec12_data_i(19 downto 16);
            fec12_o_10g24_s(123 downto 120)  <= fec12_data_i(15 downto 12);
            fec12_o_10g24_s(99 downto 96)    <= fec12_data_i(11 downto 8);
            fec12_o_10g24_s(75 downto 72)    <= fec12_data_i(7 downto 4);
            fec12_o_10g24_s(51 downto 48)    <= fec12_data_i(3 downto 0);

            -- Code 1
            fec12_o_10g24_s(247 downto 246)  <= fec12_data_i(169 downto 168);
            fec12_o_10g24_s(245 downto 244)  <= fec12_data_i(67 downto 66);
            fec12_o_10g24_s(223 downto 220)  <= fec12_data_i(65 downto 62);
            fec12_o_10g24_s(199 downto 196)  <= fec12_data_i(61 downto 58);
            fec12_o_10g24_s(175 downto 172)  <= fec12_data_i(57 downto 54);
            fec12_o_10g24_s(151 downto 148)  <= fec12_data_i(53 downto 50);
            fec12_o_10g24_s(127 downto 124)  <= fec12_data_i(49 downto 46);
            fec12_o_10g24_s(103 downto 100)  <= fec12_data_i(45 downto 42);
            fec12_o_10g24_s(79 downto 76)    <= fec12_data_i(41 downto 38);
            fec12_o_10g24_s(55 downto 52)    <= fec12_data_i(37 downto 34);

            -- Code 2
            fec12_o_10g24_s(251 downto 250)  <= fec12_data_i(203 downto 202); 
            fec12_o_10g24_s(249 downto 248)  <= fec12_data_i(101 downto 100);
            fec12_o_10g24_s(227 downto 224)  <= fec12_data_i(99 downto 96);
            fec12_o_10g24_s(203 downto 200)  <= fec12_data_i(95 downto 92);
            fec12_o_10g24_s(179 downto 176)  <= fec12_data_i(91 downto 88);
            fec12_o_10g24_s(155 downto 152)  <= fec12_data_i(87 downto 84);
            fec12_o_10g24_s(131 downto 128)  <= fec12_data_i(83 downto 80);
            fec12_o_10g24_s(107 downto 104)  <= fec12_data_i(79 downto 76);
            fec12_o_10g24_s(83 downto 80)    <= fec12_data_i(75 downto 72);
            fec12_o_10g24_s(59 downto 56)    <= fec12_data_i(71 downto 68);

            -- Code 3
            fec12_o_10g24_s(253 downto 252)  <= fec12_data_i(205 downto 204);
            fec12_o_10g24_s(231 downto 228)  <= fec12_data_i(133 downto 130);
            fec12_o_10g24_s(207 downto 204)  <= fec12_data_i(129 downto 126);
            fec12_o_10g24_s(183 downto 180)  <= fec12_data_i(125 downto 122);
            fec12_o_10g24_s(159 downto 156)  <= fec12_data_i(121 downto 118);
            fec12_o_10g24_s(135 downto 132)  <= fec12_data_i(117 downto 114);
            fec12_o_10g24_s(111 downto 108)  <= fec12_data_i(113 downto 110);
            fec12_o_10g24_s(87 downto 84)    <= fec12_data_i(109 downto 106);
            fec12_o_10g24_s(63 downto 60)    <= fec12_data_i(105 downto 102);

            -- Code 4
            fec12_o_10g24_s(235 downto 232)  <= fec12_data_i(167 downto 164);
            fec12_o_10g24_s(211 downto 208)  <= fec12_data_i(163 downto 160);
            fec12_o_10g24_s(187 downto 184)  <= fec12_data_i(159 downto 156);
            fec12_o_10g24_s(163 downto 160)  <= fec12_data_i(155 downto 152);
            fec12_o_10g24_s(139 downto 136)  <= fec12_data_i(151 downto 148);
            fec12_o_10g24_s(115 downto 112)  <= fec12_data_i(147 downto 144);
            fec12_o_10g24_s(91 downto 88)    <= fec12_data_i(143 downto 140);
            fec12_o_10g24_s(67 downto 64)    <= fec12_data_i(139 downto 136);

            -- Code 5
            fec12_o_10g24_s(239 downto 236)  <= fec12_data_i(201 downto 198);
            fec12_o_10g24_s(215 downto 212)  <= fec12_data_i(197 downto 194);
            fec12_o_10g24_s(191 downto 188)  <= fec12_data_i(193 downto 190);
            fec12_o_10g24_s(167 downto 164)  <= fec12_data_i(189 downto 186);
            fec12_o_10g24_s(143 downto 140)  <= fec12_data_i(185 downto 182);
            fec12_o_10g24_s(119 downto 116)  <= fec12_data_i(181 downto 178);
            fec12_o_10g24_s(95 downto 92)    <= fec12_data_i(177 downto 174);
            fec12_o_10g24_s(71 downto 68)    <= fec12_data_i(173 downto 170);
            
            -- FEC
            fec12_o_10g24_s(47 downto 44)    <= fec12_fec_i(47 downto 44);
            fec12_o_10g24_s(23 downto 20)    <= fec12_fec_i(43 downto 40);
            fec12_o_10g24_s(43 downto 40)    <= fec12_fec_i(39 downto 36);
            fec12_o_10g24_s(19 downto 16)    <= fec12_fec_i(35 downto 32);
            fec12_o_10g24_s(39 downto 36)    <= fec12_fec_i(31 downto 28);
            fec12_o_10g24_s(15 downto 12)    <= fec12_fec_i(27 downto 24);
            fec12_o_10g24_s(35 downto 32)    <= fec12_fec_i(23 downto 20);
            fec12_o_10g24_s(11 downto 8)     <= fec12_fec_i(19 downto 16);
            fec12_o_10g24_s(31 downto 28)    <= fec12_fec_i(15 downto 12);
            fec12_o_10g24_s(7 downto 4)      <= fec12_fec_i(11 downto 8);
            fec12_o_10g24_s(27 downto 24)    <= fec12_fec_i(7 downto 4);
            fec12_o_10g24_s(3 downto 0)      <= fec12_fec_i(3 downto 0);

        END GENERATE;

        -- Mux
        fec12_data_s   <= "10" & fec12_data_i & fec12_fec_i WHEN bypass = '1' and (DATARATE = DATARATE_10G24) ELSE
                          "10" & fec12_data_i & fec12_fec_i WHEN bypass = '1' ELSE
                          fec12_o_5g12_s WHEN DATARATE = DATARATE_5G12 ELSE
                          fec12_o_10g24_s;
      

    END GENERATE;

    fec_data_o     <= fec5_data_s WHEN FEC = FEC5 ELSE 
                      fec12_data_s;

END behavioral;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--