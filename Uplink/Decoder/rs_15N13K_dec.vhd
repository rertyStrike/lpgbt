----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.08.2020 23:02:09
-- Design Name: 
-- Module Name: rs_15N13K_dec - Behavioral
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

entity rs_15N13K_dec is
    GENERIC (
        N                                : integer := 15;
        K                                : integer := 13;
        SYMB_BITWIDTH                    : integer := 4
    );
    PORT (
        payloadData_i                   : in  std_logic_vector((K*SYMB_BITWIDTH)-1 downto 0);       --! Message to be decoded
        fecData_i                       : in  std_logic_vector(((N-K)*SYMB_BITWIDTH)-1 downto 0);   --! FEC USEd to decode

        data_o                          : out std_logic_vector((K*SYMB_BITWIDTH)-1 downto 0)        --! Decoded / corrected data
    );
end rs_15N13K_dec;

--! @brief rs_15N13K_dec ARCHITECTURE - N15K13 Reed-Solomon encoder
ARCHITECTURE behavioral OF rs_15N13K_dec IS

    -- Functions
    -- Functions
    FUNCTION gf_mult_4 (
        op1 : in std_logic_vector(3 downto 0);
        op2 : in std_logic_vector(3 downto 0)
    )
    RETURN std_logic_vector IS
        VARIABLE tmp: std_logic_vector(3 downto 0);
    BEGIN
        tmp(0) := ((((op1(0) and op2(0)) xor (op1(1) and op2(3))) xor (op1(3) and op2(1))) xor (op1(2) and op2(2)));
        tmp(1) := (((((((op1(0) and op2(1)) xor (op1(1) and op2(0))) xor (op1(1) and op2(3))) xor (op1(3) and op2(1))) xor (op1(2) and op2(2))) xor (op1(3) and op2(2))) xor (op1(2) and op2(3)));
        tmp(2) := ((((((op1(0) and op2(2)) xor (op1(2) and op2(0))) xor (op1(1) and op2(1))) xor (op1(3) and op2(2))) xor (op1(2) and op2(3))) xor (op1(3) and op2(3)));
        tmp(3) := (((((op1(0) and op2(3)) xor (op1(3) and op2(0))) xor (op1(1) and op2(2))) xor (op1(2) and op2(1))) xor (op1(3) and op2(3)));      
        RETURN tmp;
    END;

    FUNCTION gf_inv_4 (
        op : in std_logic_vector(3 downto 0)
    )
    RETURN std_logic_vector IS
        VARIABLE tmp: std_logic_vector(3 downto 0);
    BEGIN

        CASE op IS
            WHEN "0000"  => tmp := "0000"; -- 0
            WHEN "0001"  => tmp := "0001"; -- 1
            WHEN "0010"  => tmp := "1001"; -- 9
            WHEN "0011"  => tmp := "1110"; -- 14
            WHEN "0100"  => tmp := "1101"; -- 13
            WHEN "0101"  => tmp := "1011"; -- 11
            WHEN "0110"  => tmp := "0111"; -- 7
            WHEN "0111"  => tmp := "0110"; -- 6
            WHEN "1000"  => tmp := "1111"; -- 15
            WHEN "1001"  => tmp := "0010"; -- 2
            WHEN "1010"  => tmp := "1100"; -- 12
            WHEN "1011"  => tmp := "0101"; -- 5
            WHEN "1100"  => tmp := "1010"; -- 10
            WHEN "1101"  => tmp := "0100"; -- 4
            WHEN "1110"  => tmp := "0011"; -- 3
            WHEN "1111"  => tmp := "1000"; -- 8
            WHEN OTHERS  => tmp := "0000"; -- 0
        END CASE;

        RETURN tmp;
    END;

    FUNCTION gf_log_4 (
        op : in std_logic_vector(3 downto 0)
    )
    RETURN std_logic_vector IS
        VARIABLE tmp: std_logic_vector(3 downto 0);
    BEGIN

        CASE op IS

            WHEN "0000"  => tmp := "0000"; -- 0
            WHEN "0001"  => tmp := "0000"; -- 0
            WHEN "0010"  => tmp := "0001"; -- 1
            WHEN "0011"  => tmp := "0100"; -- 4
            WHEN "0100"  => tmp := "0010"; -- 2
            WHEN "0101"  => tmp := "1000"; -- 8
            WHEN "0110"  => tmp := "0101"; -- 5
            WHEN "0111"  => tmp := "1010"; -- 10
            WHEN "1000"  => tmp := "0011"; -- 3
            WHEN "1001"  => tmp := "1110"; -- 14
            WHEN "1010"  => tmp := "1001"; -- 9
            WHEN "1011"  => tmp := "0111"; -- 7
            WHEN "1100"  => tmp := "0110"; -- 6
            WHEN "1101"  => tmp := "1101"; -- 13
            WHEN "1110"  => tmp := "1011"; -- 11
            WHEN "1111"  => tmp := "1100"; -- 12
            WHEN OTHERS  => tmp := "0000"; -- 0
        END CASE;

        RETURN tmp;
    END;

    -- Signals
    SIGNAL msg              : std_logic_vector((N*SYMB_BITWIDTH)-1 downto 0);
    SIGNAL decMsg           : std_logic_vector((K*SYMB_BITWIDTH)-1 downto 0);

    SIGNAL outSt1           : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt2           : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt3           : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt4           : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt5           : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt6           : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt7           : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt8           : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt9           : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt10          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt11          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt12          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt13          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd0          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd1          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd2          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd3          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd4          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd5          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd6          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd7          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd8          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd9          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd10         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd11         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd12         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult0         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult1         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult2         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult3         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult4         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult5         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult6         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult7         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult8         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult9         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult10        : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult11        : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult12        : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult13        : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL syndr0           : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL syndr1           : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL syndr0_inv       : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL syndrProd        : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL errorPos         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);

BEGIN                 --========####   Architecture Body   ####========--

	-- ---------------- The Parallel LFSR HDL description  ---------------- --

    -- MSG mapping
    msg     <=  payloadData_i & fecData_i;

	-- Evaluates the first syndrom
    outSt1  <=  msg((15*SYMB_BITWIDTH)-1 downto 14*SYMB_BITWIDTH) xor msg((14*SYMB_BITWIDTH)-1 downto 13*SYMB_BITWIDTH);
    outSt2  <=  msg((13*SYMB_BITWIDTH)-1 downto 12*SYMB_BITWIDTH) xor outSt1;
    outSt3  <=  msg((12*SYMB_BITWIDTH)-1 downto 11*SYMB_BITWIDTH) xor outSt2;
    outSt4  <=  msg((11*SYMB_BITWIDTH)-1 downto 10*SYMB_BITWIDTH) xor outSt3;
    outSt5  <=  msg((10*SYMB_BITWIDTH)-1 downto 9 *SYMB_BITWIDTH) xor outSt4;
    outSt6  <=  msg((9 *SYMB_BITWIDTH)-1 downto 8 *SYMB_BITWIDTH) xor outSt5;
    outSt7  <=  msg((8 *SYMB_BITWIDTH)-1 downto 7 *SYMB_BITWIDTH) xor outSt6;
    outSt8  <=  msg((7 *SYMB_BITWIDTH)-1 downto 6 *SYMB_BITWIDTH) xor outSt7;
    outSt9  <=  msg((6 *SYMB_BITWIDTH)-1 downto 5 *SYMB_BITWIDTH) xor outSt8;
    outSt10 <=  msg((5 *SYMB_BITWIDTH)-1 downto 4 *SYMB_BITWIDTH) xor outSt9;
    outSt11 <=  msg((4 *SYMB_BITWIDTH)-1 downto 3 *SYMB_BITWIDTH) xor outSt10;
    outSt12 <=  msg((3 *SYMB_BITWIDTH)-1 downto 2 *SYMB_BITWIDTH) xor outSt11;
    outSt13 <=  msg((2 *SYMB_BITWIDTH)-1 downto 1 *SYMB_BITWIDTH) xor outSt12;
    syndr0  <=  msg((1 *SYMB_BITWIDTH)-1 downto 0 *SYMB_BITWIDTH) xor outSt13;

    -- Evaluates the second syndrom
    outMult0   <= gf_mult_4("0010",msg((15*SYMB_BITWIDTH)-1 downto (14*SYMB_BITWIDTH)));
	outMult1   <= gf_mult_4("0010",outAdd0);
	outMult2   <= gf_mult_4("0010",outAdd1);
	outMult3   <= gf_mult_4("0010",outAdd2);
	outMult4   <= gf_mult_4("0010",outAdd3);
	outMult5   <= gf_mult_4("0010",outAdd4);
	outMult6   <= gf_mult_4("0010",outAdd5);
	outMult7   <= gf_mult_4("0010",outAdd6);
	outMult8   <= gf_mult_4("0010",outAdd7);
	outMult9   <= gf_mult_4("0010",outAdd8);
	outMult10  <= gf_mult_4("0010",outAdd9);
	outMult11  <= gf_mult_4("0010",outAdd10);
	outMult12  <= gf_mult_4("0010",outAdd11);
	outMult13  <= gf_mult_4("0010",outAdd12);
    
    outAdd0  <=  msg((14*SYMB_BITWIDTH)-1 downto 13*SYMB_BITWIDTH) xor outMult0;
    outAdd1  <=  msg((13*SYMB_BITWIDTH)-1 downto 12*SYMB_BITWIDTH) xor outMult1;
    outAdd2  <=  msg((12*SYMB_BITWIDTH)-1 downto 11*SYMB_BITWIDTH) xor outMult2;
    outAdd3  <=  msg((11*SYMB_BITWIDTH)-1 downto 10*SYMB_BITWIDTH) xor outMult3;
    outAdd4  <=  msg((10*SYMB_BITWIDTH)-1 downto 9 *SYMB_BITWIDTH) xor outMult4;
    outAdd5  <=  msg((9 *SYMB_BITWIDTH)-1 downto 8 *SYMB_BITWIDTH) xor outMult5;
    outAdd6  <=  msg((8 *SYMB_BITWIDTH)-1 downto 7 *SYMB_BITWIDTH) xor outMult6;
    outAdd7  <=  msg((7 *SYMB_BITWIDTH)-1 downto 6 *SYMB_BITWIDTH) xor outMult7;
    outAdd8  <=  msg((6 *SYMB_BITWIDTH)-1 downto 5 *SYMB_BITWIDTH) xor outMult8;
    outAdd9  <=  msg((5 *SYMB_BITWIDTH)-1 downto 4 *SYMB_BITWIDTH) xor outMult9;
    outAdd10 <=  msg((4 *SYMB_BITWIDTH)-1 downto 3 *SYMB_BITWIDTH) xor outMult10;
    outAdd11 <=  msg((3 *SYMB_BITWIDTH)-1 downto 2 *SYMB_BITWIDTH) xor outMult11;
    outAdd12 <=  msg((2 *SYMB_BITWIDTH)-1 downto 1 *SYMB_BITWIDTH) xor outMult12;
    syndr1   <=  msg((1 *SYMB_BITWIDTH)-1 downto 0 *SYMB_BITWIDTH) xor outMult13;
    
	-- Evaluates position of error
    syndr0_inv   <= gf_inv_4(syndr0);
    syndrProd    <= gf_mult_4(syndr0_inv, syndr1);
    errorPos     <= gf_log_4(syndrProd);

    -- Correct message.. Correction on parity bits is ignored!
     decMsg((13*SYMB_BITWIDTH)-1 downto (12*SYMB_BITWIDTH))   <= msg((15*SYMB_BITWIDTH)-1 downto (14*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "1110" ELSE
                                                                 msg((15*SYMB_BITWIDTH)-1 downto (14*SYMB_BITWIDTH));
 
     decMsg((12*SYMB_BITWIDTH)-1 downto (11*SYMB_BITWIDTH))   <= msg((14*SYMB_BITWIDTH)-1 downto (13*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "1101" ELSE
                                                                 msg((14*SYMB_BITWIDTH)-1 downto (13*SYMB_BITWIDTH));
 
     decMsg((11*SYMB_BITWIDTH)-1 downto (10*SYMB_BITWIDTH))   <= msg((13*SYMB_BITWIDTH)-1 downto (12*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "1100" ELSE
                                                                 msg((13*SYMB_BITWIDTH)-1 downto (12*SYMB_BITWIDTH));
 
     decMsg((10*SYMB_BITWIDTH)-1 downto (9 *SYMB_BITWIDTH))   <= msg((12*SYMB_BITWIDTH)-1 downto (11*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "1011" ELSE
                                                                 msg((12*SYMB_BITWIDTH)-1 downto (11*SYMB_BITWIDTH));
 
     decMsg((9 *SYMB_BITWIDTH)-1 downto (8 *SYMB_BITWIDTH))   <= msg((11*SYMB_BITWIDTH)-1 downto (10*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "1010" ELSE
                                                                 msg((11*SYMB_BITWIDTH)-1 downto (10*SYMB_BITWIDTH));
 
     decMsg((8 *SYMB_BITWIDTH)-1 downto (7 *SYMB_BITWIDTH))   <= msg((10*SYMB_BITWIDTH)-1 downto (9*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "1001" ELSE
                                                                 msg((10*SYMB_BITWIDTH)-1 downto (9*SYMB_BITWIDTH));
 
     decMsg((7 *SYMB_BITWIDTH)-1 downto (6 *SYMB_BITWIDTH))   <= msg((9*SYMB_BITWIDTH)-1  downto (8*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "1000" ELSE
                                                                 msg((9*SYMB_BITWIDTH)-1  downto (8*SYMB_BITWIDTH));
 
     decMsg((6 *SYMB_BITWIDTH)-1 downto (5 *SYMB_BITWIDTH))   <= msg((8*SYMB_BITWIDTH)-1  downto (7*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "0111" ELSE
                                                                 msg((8*SYMB_BITWIDTH)-1  downto (7*SYMB_BITWIDTH));
 
     decMsg((5 *SYMB_BITWIDTH)-1 downto (4 *SYMB_BITWIDTH))   <= msg((7*SYMB_BITWIDTH)-1  downto (6*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "0110" ELSE
                                                                 msg((7*SYMB_BITWIDTH)-1  downto (6*SYMB_BITWIDTH));
 
     decMsg((4 *SYMB_BITWIDTH)-1 downto (3 *SYMB_BITWIDTH))   <= msg((6*SYMB_BITWIDTH)-1  downto (5*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "0101" ELSE
                                                                 msg((6*SYMB_BITWIDTH)-1  downto (5*SYMB_BITWIDTH));
 
     decMsg((3 *SYMB_BITWIDTH)-1 downto (2 *SYMB_BITWIDTH))   <= msg((5*SYMB_BITWIDTH)-1  downto (4*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "0100" ELSE
                                                                 msg((5*SYMB_BITWIDTH)-1  downto (4*SYMB_BITWIDTH));
 
     decMsg((2 *SYMB_BITWIDTH)-1 downto (1 *SYMB_BITWIDTH))   <= msg((4*SYMB_BITWIDTH)-1  downto (3*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "0011" ELSE
                                                                 msg((4*SYMB_BITWIDTH)-1  downto (3*SYMB_BITWIDTH));
 
     decMsg((1 *SYMB_BITWIDTH)-1 downto (0 *SYMB_BITWIDTH))   <= msg((3*SYMB_BITWIDTH)-1  downto (2*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "0010" ELSE
                                                                 msg((3*SYMB_BITWIDTH)-1  downto (2*SYMB_BITWIDTH));

    data_o <= decMsg;

END behavioral;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--

