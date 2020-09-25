----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.08.2020 23:02:09
-- Design Name: 
-- Module Name: rs_31N29K_dec - Behavioral
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

entity rs_31N29K_dec is
   GENERIC (
        N                                : integer := 31;
        K                                : integer := 29;
        SYMB_BITWIDTH                    : integer := 5
    );
    PORT (
        payloadData_i                   : in  std_logic_vector((K*SYMB_BITWIDTH)-1 downto 0);       --! Message to be decoded
        fecData_i                       : in  std_logic_vector(((N-K)*SYMB_BITWIDTH)-1 downto 0);   --! FEC USEd to decode

        data_o                          : out std_logic_vector((K*SYMB_BITWIDTH)-1 downto 0)        --! Decoded / corrected data
    );
end rs_31N29K_dec;
--! @brief rs_31N29K_dec ARCHITECTURE - N31K29 Reed-Solomon encoder
ARCHITECTURE behavioral OF rs_31N29K_dec IS

    FUNCTION gf_mult_5 (
        op1 : in std_logic_vector(4 downto 0);
        op2 : in std_logic_vector(4 downto 0)
    )
    RETURN std_logic_vector IS
        VARIABLE tmp: std_logic_vector(4 downto 0);
    BEGIN
        tmp(0) := ((((((op1(0) and op2(0)) xor (op1(1) and op2(4))) xor (op1(4) and op2(1))) xor (op1(2) and op2(3))) xor (op1(3) and op2(2))) xor (op1(4) and op2(4)));
        tmp(1) := (((((op1(0) and op2(1)) xor (op1(1) and op2(0))) xor (op1(2) and op2(4))) xor (op1(4) and op2(2))) xor (op1(3) and op2(3)));
        tmp(2) := ((((((((((op1(0) and op2(2)) xor (op1(2) and op2(0))) xor (op1(1) and op2(1))) xor (op1(1) and op2(4))) xor (op1(4) and op2(1))) xor (op1(2) and op2(3))) xor (op1(3) and op2(2))) xor (op1(3) and op2(4))) xor (op1(4) and op2(3))) xor (op1(4) and op2(4)));
        tmp(3) := ((((((((op1(0) and op2(3)) xor (op1(3) and op2(0))) xor (op1(1) and op2(2))) xor (op1(2) and op2(1))) xor (op1(2) and op2(4))) xor (op1(4) and op2(2))) xor (op1(3) and op2(3))) xor (op1(4) and op2(4)));
        tmp(4) := (((((((op1(0) and op2(4)) xor (op1(4) and op2(0))) xor (op1(1) and op2(3))) xor (op1(3) and op2(1))) xor (op1(2) and op2(2))) xor (op1(3) and op2(4))) xor (op1(4) and op2(3)));      
        RETURN tmp;
    END;
    
    FUNCTION gf_inv_5 (
        op : in std_logic_vector(4 downto 0)
    )
    RETURN std_logic_vector IS
        VARIABLE tmp: std_logic_vector(4 downto 0);
    BEGIN

        CASE op IS

            WHEN "00000"  => tmp := "00000"; --0
            WHEN "00001"  => tmp := "00001"; --1
            WHEN "00010"  => tmp := "10010"; --18
            WHEN "00011"  => tmp := "11100"; --28
            WHEN "00100"  => tmp := "01001"; --9
            WHEN "00101"  => tmp := "10111"; --23
            WHEN "00110"  => tmp := "01110"; --14
            WHEN "00111"  => tmp := "01100"; --12
            WHEN "01000"  => tmp := "10110"; --22
            WHEN "01001"  => tmp := "00100"; --4
            WHEN "01010"  => tmp := "11001"; --25
            WHEN "01011"  => tmp := "10000"; --16
            WHEN "01100"  => tmp := "00111"; --7
            WHEN "01101"  => tmp := "01111"; --15
            WHEN "01110"  => tmp := "00110"; --6
            WHEN "01111"  => tmp := "01101"; --13
            WHEN "10000"  => tmp := "01011"; --11
            WHEN "10001"  => tmp := "11000"; --24
            WHEN "10010"  => tmp := "00010"; --2
            WHEN "10011"  => tmp := "11101"; --29
            WHEN "10100"  => tmp := "11110"; --30
            WHEN "10101"  => tmp := "11010"; --26
            WHEN "10110"  => tmp := "01000"; --8
            WHEN "10111"  => tmp := "00101"; --5
            WHEN "11000"  => tmp := "10001"; --17
            WHEN "11001"  => tmp := "01010"; --10
            WHEN "11010"  => tmp := "10101"; --21
            WHEN "11011"  => tmp := "11111"; --31
            WHEN "11100"  => tmp := "00011"; --3
            WHEN "11101"  => tmp := "10011"; --19
            WHEN "11110"  => tmp := "10100"; --20
            WHEN "11111"  => tmp := "11011"; --27
            WHEN OTHERS   => tmp := "00000"; --0
        END CASE;

        RETURN tmp;
    END;

    FUNCTION gf_log_5 (
        op : in std_logic_vector(4 downto 0)
    )
    RETURN std_logic_vector IS
        VARIABLE tmp: std_logic_vector(4 downto 0);
    BEGIN

        CASE op IS

            WHEN "00000"  => tmp := "00000"; -- 0
            WHEN "00001"  => tmp := "00000"; -- 0
            WHEN "00010"  => tmp := "00001"; -- 1
            WHEN "00011"  => tmp := "10010"; -- 18
            WHEN "00100"  => tmp := "00010"; -- 2
            WHEN "00101"  => tmp := "00101"; -- 5
            WHEN "00110"  => tmp := "10011"; -- 19
            WHEN "00111"  => tmp := "01011"; -- 11
            WHEN "01000"  => tmp := "00011"; -- 3
            WHEN "01001"  => tmp := "11101"; -- 29
            WHEN "01010"  => tmp := "00110"; -- 6
            WHEN "01011"  => tmp := "11011"; -- 27
            WHEN "01100"  => tmp := "10100"; -- 20
            WHEN "01101"  => tmp := "01000"; -- 8
            WHEN "01110"  => tmp := "01100"; -- 12
            WHEN "01111"  => tmp := "10111"; -- 23
            WHEN "10000"  => tmp := "00100"; -- 4
            WHEN "10001"  => tmp := "01010"; -- 10
            WHEN "10010"  => tmp := "11110"; -- 30
            WHEN "10011"  => tmp := "10001"; -- 17
            WHEN "10100"  => tmp := "00111"; -- 7
            WHEN "10101"  => tmp := "10110"; -- 22
            WHEN "10110"  => tmp := "11100"; -- 28
            WHEN "10111"  => tmp := "11010"; -- 26
            WHEN "11000"  => tmp := "10101"; -- 21
            WHEN "11001"  => tmp := "11001"; -- 25
            WHEN "11010"  => tmp := "01001"; -- 9
            WHEN "11011"  => tmp := "10000"; -- 16
            WHEN "11100"  => tmp := "01101"; -- 13
            WHEN "11101"  => tmp := "01110"; -- 14
            WHEN "11110"  => tmp := "11000"; -- 24
            WHEN "11111"  => tmp := "01111"; -- 15
            WHEN OTHERS   => tmp := "00000";
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
    SIGNAL outSt14          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt15          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt16          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt17          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt18          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt19          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt20          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt21          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt22          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt23          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt24          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt25          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt26          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt27          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt28          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt29          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
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
    SIGNAL outAdd13         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd14         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd15         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd16         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd17         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd18         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd19         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd20         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd21         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd22         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd23         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd24         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd25         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd26         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd27         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd28         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
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
    SIGNAL outMult14        : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult15        : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult16        : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult17        : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult18        : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult19        : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult20        : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult21        : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult22        : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult23        : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult24        : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult25        : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult26        : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult27        : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult28        : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult29        : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
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
    outSt1  <=  msg((31*SYMB_BITWIDTH)-1 downto 30*SYMB_BITWIDTH) xor msg((30*SYMB_BITWIDTH)-1 downto 29*SYMB_BITWIDTH);
    outSt2  <=  msg((29*SYMB_BITWIDTH)-1 downto 28*SYMB_BITWIDTH) xor outSt1;
    outSt3  <=  msg((28*SYMB_BITWIDTH)-1 downto 27*SYMB_BITWIDTH) xor outSt2;
    outSt4  <=  msg((27*SYMB_BITWIDTH)-1 downto 26*SYMB_BITWIDTH) xor outSt3;
    outSt5  <=  msg((26*SYMB_BITWIDTH)-1 downto 25*SYMB_BITWIDTH) xor outSt4;
    outSt6  <=  msg((25*SYMB_BITWIDTH)-1 downto 24*SYMB_BITWIDTH) xor outSt5;
    outSt7  <=  msg((24*SYMB_BITWIDTH)-1 downto 23*SYMB_BITWIDTH) xor outSt6;
    outSt8  <=  msg((23*SYMB_BITWIDTH)-1 downto 22*SYMB_BITWIDTH) xor outSt7;
    outSt9  <=  msg((22*SYMB_BITWIDTH)-1 downto 21*SYMB_BITWIDTH) xor outSt8;
    outSt10 <=  msg((21*SYMB_BITWIDTH)-1 downto 20*SYMB_BITWIDTH) xor outSt9;
    outSt11 <=  msg((20*SYMB_BITWIDTH)-1 downto 19*SYMB_BITWIDTH) xor outSt10;
    outSt12 <=  msg((19*SYMB_BITWIDTH)-1 downto 18*SYMB_BITWIDTH) xor outSt11;
    outSt13 <=  msg((18*SYMB_BITWIDTH)-1 downto 17*SYMB_BITWIDTH) xor outSt12;
    outSt14 <=  msg((17*SYMB_BITWIDTH)-1 downto 16*SYMB_BITWIDTH) xor outSt13;
    outSt15 <=  msg((16*SYMB_BITWIDTH)-1 downto 15*SYMB_BITWIDTH) xor outSt14;
    outSt16 <=  msg((15*SYMB_BITWIDTH)-1 downto 14*SYMB_BITWIDTH) xor outSt15;
    outSt17 <=  msg((14*SYMB_BITWIDTH)-1 downto 13*SYMB_BITWIDTH) xor outSt16;
    outSt18 <=  msg((13*SYMB_BITWIDTH)-1 downto 12*SYMB_BITWIDTH) xor outSt17;
    outSt19 <=  msg((12*SYMB_BITWIDTH)-1 downto 11*SYMB_BITWIDTH) xor outSt18;
    outSt20 <=  msg((11*SYMB_BITWIDTH)-1 downto 10*SYMB_BITWIDTH) xor outSt19;
    outSt21 <=  msg((10*SYMB_BITWIDTH)-1 downto 9 *SYMB_BITWIDTH) xor outSt20;
    outSt22 <=  msg((9 *SYMB_BITWIDTH)-1 downto 8 *SYMB_BITWIDTH) xor outSt21;
    outSt23 <=  msg((8 *SYMB_BITWIDTH)-1 downto 7 *SYMB_BITWIDTH) xor outSt22;
    outSt24 <=  msg((7 *SYMB_BITWIDTH)-1 downto 6 *SYMB_BITWIDTH) xor outSt23;
    outSt25 <=  msg((6 *SYMB_BITWIDTH)-1 downto 5 *SYMB_BITWIDTH) xor outSt24;
    outSt26 <=  msg((5 *SYMB_BITWIDTH)-1 downto 4 *SYMB_BITWIDTH) xor outSt25;
    outSt27 <=  msg((4 *SYMB_BITWIDTH)-1 downto 3 *SYMB_BITWIDTH) xor outSt26;
    outSt28 <=  msg((3 *SYMB_BITWIDTH)-1 downto 2 *SYMB_BITWIDTH) xor outSt27;
    outSt29 <=  msg((2 *SYMB_BITWIDTH)-1 downto 1 *SYMB_BITWIDTH) xor outSt28;
    syndr0  <=  msg((1 *SYMB_BITWIDTH)-1 downto 0 *SYMB_BITWIDTH) xor outSt29;

    -- Evaluates the second syndrom
    outMult0   <= gf_mult_5("00010",msg((31*SYMB_BITWIDTH)-1 downto (30*SYMB_BITWIDTH)));
	outMult1   <= gf_mult_5("00010",outAdd0);
	outMult2   <= gf_mult_5("00010",outAdd1);
	outMult3   <= gf_mult_5("00010",outAdd2);
	outMult4   <= gf_mult_5("00010",outAdd3);
	outMult5   <= gf_mult_5("00010",outAdd4);
	outMult6   <= gf_mult_5("00010",outAdd5);
	outMult7   <= gf_mult_5("00010",outAdd6);
	outMult8   <= gf_mult_5("00010",outAdd7);
	outMult9   <= gf_mult_5("00010",outAdd8);
	outMult10  <= gf_mult_5("00010",outAdd9);
	outMult11  <= gf_mult_5("00010",outAdd10);
	outMult12  <= gf_mult_5("00010",outAdd11);
	outMult13  <= gf_mult_5("00010",outAdd12);
	outMult14  <= gf_mult_5("00010",outAdd13);
	outMult15  <= gf_mult_5("00010",outAdd14);
	outMult16  <= gf_mult_5("00010",outAdd15);
	outMult17  <= gf_mult_5("00010",outAdd16);
	outMult18  <= gf_mult_5("00010",outAdd17);
	outMult19  <= gf_mult_5("00010",outAdd18);
	outMult20  <= gf_mult_5("00010",outAdd19);
	outMult21  <= gf_mult_5("00010",outAdd20);
	outMult22  <= gf_mult_5("00010",outAdd21);
	outMult23  <= gf_mult_5("00010",outAdd22);
	outMult24  <= gf_mult_5("00010",outAdd23);
	outMult25  <= gf_mult_5("00010",outAdd24);
	outMult26  <= gf_mult_5("00010",outAdd25);
	outMult27  <= gf_mult_5("00010",outAdd26);
	outMult28  <= gf_mult_5("00010",outAdd27);
	outMult29  <= gf_mult_5("00010",outAdd28);

	outAdd0  <=  msg((30*SYMB_BITWIDTH)-1 downto 29*SYMB_BITWIDTH) xor outMult0;
    outAdd1  <=  msg((29*SYMB_BITWIDTH)-1 downto 28*SYMB_BITWIDTH) xor outMult1;
    outAdd2  <=  msg((28*SYMB_BITWIDTH)-1 downto 27*SYMB_BITWIDTH) xor outMult2;
    outAdd3  <=  msg((27*SYMB_BITWIDTH)-1 downto 26*SYMB_BITWIDTH) xor outMult3;
    outAdd4  <=  msg((26*SYMB_BITWIDTH)-1 downto 25*SYMB_BITWIDTH) xor outMult4;
    outAdd5  <=  msg((25*SYMB_BITWIDTH)-1 downto 24*SYMB_BITWIDTH) xor outMult5;
    outAdd6  <=  msg((24*SYMB_BITWIDTH)-1 downto 23*SYMB_BITWIDTH) xor outMult6;
    outAdd7  <=  msg((23*SYMB_BITWIDTH)-1 downto 22*SYMB_BITWIDTH) xor outMult7;
    outAdd8  <=  msg((22*SYMB_BITWIDTH)-1 downto 21*SYMB_BITWIDTH) xor outMult8;
    outAdd9  <=  msg((21*SYMB_BITWIDTH)-1 downto 20*SYMB_BITWIDTH) xor outMult9;
    outAdd10 <=  msg((20*SYMB_BITWIDTH)-1 downto 19*SYMB_BITWIDTH) xor outMult10;
    outAdd11 <=  msg((19*SYMB_BITWIDTH)-1 downto 18*SYMB_BITWIDTH) xor outMult11;
    outAdd12 <=  msg((18*SYMB_BITWIDTH)-1 downto 17*SYMB_BITWIDTH) xor outMult12;
    outAdd13 <=  msg((17*SYMB_BITWIDTH)-1 downto 16*SYMB_BITWIDTH) xor outMult13;
    outAdd14 <=  msg((16*SYMB_BITWIDTH)-1 downto 15*SYMB_BITWIDTH) xor outMult14;
    outAdd15 <=  msg((15*SYMB_BITWIDTH)-1 downto 14*SYMB_BITWIDTH) xor outMult15;
    outAdd16 <=  msg((14*SYMB_BITWIDTH)-1 downto 13*SYMB_BITWIDTH) xor outMult16;
    outAdd17 <=  msg((13*SYMB_BITWIDTH)-1 downto 12*SYMB_BITWIDTH) xor outMult17;
    outAdd18 <=  msg((12*SYMB_BITWIDTH)-1 downto 11*SYMB_BITWIDTH) xor outMult18;
    outAdd19 <=  msg((11*SYMB_BITWIDTH)-1 downto 10*SYMB_BITWIDTH) xor outMult19;
    outAdd20 <=  msg((10*SYMB_BITWIDTH)-1 downto 9 *SYMB_BITWIDTH) xor outMult20;
    outAdd21 <=  msg((9 *SYMB_BITWIDTH)-1 downto 8 *SYMB_BITWIDTH) xor outMult21;
    outAdd22 <=  msg((8 *SYMB_BITWIDTH)-1 downto 7 *SYMB_BITWIDTH) xor outMult22;
    outAdd23 <=  msg((7 *SYMB_BITWIDTH)-1 downto 6 *SYMB_BITWIDTH) xor outMult23;
    outAdd24 <=  msg((6 *SYMB_BITWIDTH)-1 downto 5 *SYMB_BITWIDTH) xor outMult24;
    outAdd25 <=  msg((5 *SYMB_BITWIDTH)-1 downto 4 *SYMB_BITWIDTH) xor outMult25;
    outAdd26 <=  msg((4 *SYMB_BITWIDTH)-1 downto 3 *SYMB_BITWIDTH) xor outMult26;
    outAdd27 <=  msg((3 *SYMB_BITWIDTH)-1 downto 2 *SYMB_BITWIDTH) xor outMult27;
    outAdd28 <=  msg((2 *SYMB_BITWIDTH)-1 downto 1 *SYMB_BITWIDTH) xor outMult28;
    syndr1   <=  msg((1 *SYMB_BITWIDTH)-1 downto 0 *SYMB_BITWIDTH) xor outMult29;
	
	-- Evaluates position of error
    syndr0_inv   <= gf_inv_5(syndr0);
    syndrProd    <= gf_mult_5(syndr0_inv, syndr1);
    errorPos     <= gf_log_5(syndrProd);

    -- Correct message.. Correction on parity bits is ignored!
    decMsg((29*SYMB_BITWIDTH)-1 downto (28*SYMB_BITWIDTH))   <= msg((31*SYMB_BITWIDTH)-1 downto (30*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "11110" ELSE
                                                                msg((31*SYMB_BITWIDTH)-1 downto (30*SYMB_BITWIDTH));
    
    decMsg((28*SYMB_BITWIDTH)-1 downto (27*SYMB_BITWIDTH))   <= msg((30*SYMB_BITWIDTH)-1 downto (29*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "11101" ELSE
                                                                msg((30*SYMB_BITWIDTH)-1 downto (29*SYMB_BITWIDTH));    

    decMsg((27*SYMB_BITWIDTH)-1 downto (26*SYMB_BITWIDTH))   <= msg((29*SYMB_BITWIDTH)-1 downto (28*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "11100" ELSE
                                                                msg((29*SYMB_BITWIDTH)-1 downto (28*SYMB_BITWIDTH));

    decMsg((26*SYMB_BITWIDTH)-1 downto (25*SYMB_BITWIDTH))   <= msg((28*SYMB_BITWIDTH)-1 downto (27*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "11011" ELSE
                                                                msg((28*SYMB_BITWIDTH)-1 downto (27*SYMB_BITWIDTH));

    decMsg((25*SYMB_BITWIDTH)-1 downto (24*SYMB_BITWIDTH))   <= msg((27*SYMB_BITWIDTH)-1 downto (26*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "11010" ELSE
                                                                msg((27*SYMB_BITWIDTH)-1 downto (26*SYMB_BITWIDTH));                                                                                                                                

    decMsg((24*SYMB_BITWIDTH)-1 downto (23*SYMB_BITWIDTH))   <= msg((26*SYMB_BITWIDTH)-1 downto (25*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "11001" ELSE
                                                                msg((26*SYMB_BITWIDTH)-1 downto (25*SYMB_BITWIDTH));

    decMsg((23*SYMB_BITWIDTH)-1 downto (22*SYMB_BITWIDTH))   <= msg((25*SYMB_BITWIDTH)-1 downto (24*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "11000" ELSE
                                                                msg((25*SYMB_BITWIDTH)-1 downto (24*SYMB_BITWIDTH));

    decMsg((22*SYMB_BITWIDTH)-1 downto (21*SYMB_BITWIDTH))   <= msg((24*SYMB_BITWIDTH)-1 downto (23*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "10111" ELSE
                                                                msg((24*SYMB_BITWIDTH)-1 downto (23*SYMB_BITWIDTH));

    decMsg((21*SYMB_BITWIDTH)-1 downto (20*SYMB_BITWIDTH))   <= msg((23*SYMB_BITWIDTH)-1 downto (22*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "10110" ELSE
                                                                msg((23*SYMB_BITWIDTH)-1 downto (22*SYMB_BITWIDTH));

    decMsg((20*SYMB_BITWIDTH)-1 downto (19*SYMB_BITWIDTH))   <= msg((22*SYMB_BITWIDTH)-1 downto (21*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "10101" ELSE
                                                                msg((22*SYMB_BITWIDTH)-1 downto (21*SYMB_BITWIDTH));

    decMsg((19*SYMB_BITWIDTH)-1 downto (18*SYMB_BITWIDTH))   <= msg((21*SYMB_BITWIDTH)-1 downto (20*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "10100" ELSE
                                                                msg((21*SYMB_BITWIDTH)-1 downto (20*SYMB_BITWIDTH));

    decMsg((18*SYMB_BITWIDTH)-1 downto (17*SYMB_BITWIDTH))   <= msg((20*SYMB_BITWIDTH)-1 downto (19*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "10011" ELSE
                                                                msg((20*SYMB_BITWIDTH)-1 downto (19*SYMB_BITWIDTH));

    decMsg((17*SYMB_BITWIDTH)-1 downto (16*SYMB_BITWIDTH))   <= msg((19*SYMB_BITWIDTH)-1 downto (18*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "10010" ELSE
                                                                msg((19*SYMB_BITWIDTH)-1 downto (18*SYMB_BITWIDTH));

    decMsg((16*SYMB_BITWIDTH)-1 downto (15*SYMB_BITWIDTH))   <= msg((18*SYMB_BITWIDTH)-1 downto (17*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "10001" ELSE
                                                                msg((18*SYMB_BITWIDTH)-1 downto (17*SYMB_BITWIDTH));

    decMsg((15*SYMB_BITWIDTH)-1 downto (14*SYMB_BITWIDTH))   <= msg((17*SYMB_BITWIDTH)-1 downto (16*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "10000" ELSE
                                                                msg((17*SYMB_BITWIDTH)-1 downto (16*SYMB_BITWIDTH));

    decMsg((14*SYMB_BITWIDTH)-1 downto (13*SYMB_BITWIDTH))   <= msg((16*SYMB_BITWIDTH)-1 downto (15*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "01111" ELSE
                                                                msg((16*SYMB_BITWIDTH)-1 downto (15*SYMB_BITWIDTH));

    decMsg((13*SYMB_BITWIDTH)-1 downto (12*SYMB_BITWIDTH))   <= msg((15*SYMB_BITWIDTH)-1 downto (14*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "01110" ELSE
                                                                msg((15*SYMB_BITWIDTH)-1 downto (14*SYMB_BITWIDTH));

    decMsg((12*SYMB_BITWIDTH)-1 downto (11*SYMB_BITWIDTH))   <= msg((14*SYMB_BITWIDTH)-1 downto (13*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "01101" ELSE
                                                                msg((14*SYMB_BITWIDTH)-1 downto (13*SYMB_BITWIDTH));

    decMsg((11*SYMB_BITWIDTH)-1 downto (10*SYMB_BITWIDTH))   <= msg((13*SYMB_BITWIDTH)-1 downto (12*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "01100" ELSE
                                                                msg((13*SYMB_BITWIDTH)-1 downto (12*SYMB_BITWIDTH));

    decMsg((10*SYMB_BITWIDTH)-1 downto (9 *SYMB_BITWIDTH))   <= msg((12*SYMB_BITWIDTH)-1 downto (11*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "01011" ELSE
                                                                msg((12*SYMB_BITWIDTH)-1 downto (11*SYMB_BITWIDTH));

    decMsg((9 *SYMB_BITWIDTH)-1 downto (8 *SYMB_BITWIDTH))   <= msg((11*SYMB_BITWIDTH)-1 downto (10*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "01010" ELSE
                                                                msg((11*SYMB_BITWIDTH)-1 downto (10*SYMB_BITWIDTH));

    decMsg((8 *SYMB_BITWIDTH)-1 downto (7 *SYMB_BITWIDTH))   <= msg((10*SYMB_BITWIDTH)-1 downto (9*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "01001" ELSE
                                                                msg((10*SYMB_BITWIDTH)-1 downto (9*SYMB_BITWIDTH));

    decMsg((7 *SYMB_BITWIDTH)-1 downto (6 *SYMB_BITWIDTH))   <= msg((9*SYMB_BITWIDTH)-1  downto (8*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "01000" ELSE
                                                                msg((9*SYMB_BITWIDTH)-1  downto (8*SYMB_BITWIDTH));

    decMsg((6 *SYMB_BITWIDTH)-1 downto (5 *SYMB_BITWIDTH))   <= msg((8*SYMB_BITWIDTH)-1  downto (7*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "00111" ELSE
                                                                msg((8*SYMB_BITWIDTH)-1  downto (7*SYMB_BITWIDTH));

    decMsg((5 *SYMB_BITWIDTH)-1 downto (4 *SYMB_BITWIDTH))   <= msg((7*SYMB_BITWIDTH)-1  downto (6*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "00110" ELSE
                                                                msg((7*SYMB_BITWIDTH)-1  downto (6*SYMB_BITWIDTH));

    decMsg((4 *SYMB_BITWIDTH)-1 downto (3 *SYMB_BITWIDTH))   <= msg((6*SYMB_BITWIDTH)-1  downto (5*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "00101" ELSE
                                                                msg((6*SYMB_BITWIDTH)-1  downto (5*SYMB_BITWIDTH));

    decMsg((3 *SYMB_BITWIDTH)-1 downto (2 *SYMB_BITWIDTH))   <= msg((5*SYMB_BITWIDTH)-1  downto (4*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "00100" ELSE
                                                                msg((5*SYMB_BITWIDTH)-1  downto (4*SYMB_BITWIDTH));

    decMsg((2 *SYMB_BITWIDTH)-1 downto (1 *SYMB_BITWIDTH))   <= msg((4*SYMB_BITWIDTH)-1  downto (3*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "00011" ELSE
                                                                msg((4*SYMB_BITWIDTH)-1  downto (3*SYMB_BITWIDTH));

    decMsg((1 *SYMB_BITWIDTH)-1 downto (0 *SYMB_BITWIDTH))   <= msg((3*SYMB_BITWIDTH)-1  downto (2*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "00010" ELSE
                                                                msg((3*SYMB_BITWIDTH)-1  downto (2*SYMB_BITWIDTH));

    data_o <= decMsg;

END behavioral;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--