----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.08.2020 23:02:09
-- Design Name: 
-- Module Name: rs_31N29K_enc - Behavioral
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

entity rs_31N29K_enc is
    GENERIC (
     N                   : integer := 31;
     K                   : integer := 29;
     SYMB_BITWIDTH       : integer := 5
);
PORT (
     msg         : in  std_logic_vector((K*SYMB_BITWIDTH)-1 downto 0);       --! Message to be encoded
     parity      : out std_logic_vector(((N-K)*SYMB_BITWIDTH)-1 downto 0)    --! FEC output
);
end rs_31N29K_enc;

architecture Behavioral of rs_31N29K_enc is
-- Signals
    signal p0           :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out1P0       :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out2P0       :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out3P0       :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out4P0       :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out5P0       :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out6P0       :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out7P0       :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out8P0       :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out9P0       :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out10P0      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out11P0      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out12P0      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out13P0      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out14P0      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out15P0      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out16P0      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out17P0      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out18P0      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out19P0      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out20P0      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out21P0      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out22P0      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out23P0      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out24P0      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out25P0      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out26P0      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out27P0      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    
    signal p1           :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out1P1       :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out2P1       :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out3P1       :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out4P1       :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out5P1       :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out6P1       :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out7P1       :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out8P1       :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out9P1       :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out10P1      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out11P1      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out12P1      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out13P1      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out14P1      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out15P1      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out16P1      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out17P1      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out18P1      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out19P1      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out20P1      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out21P1      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out22P1      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out23P1      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out24P1      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out25P1      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out26P1      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);
    signal out27P1      :std_logic_vector((((N-K)/2)*SYMB_BITWIDTH)-1 downto 0);    
        
    -- Functions
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
    
begin  --========####   Architecture Body   ####========--
	-- ---------------- The Parallel LFSR Recursive HDL description  ---------------- --
    
    --p0 = 19m28 + 26m27 + 12m26 + 7m25 + 16m24 + 9m23 + 23m22 + 24m21 + 13m20 + 21m19 + 25m18 + 31m17 + 28m16 + 15m15 + 20m14 + 11m13 + 22m12 + 10m11 + 4m10 
    --       + 3m9 + 18m8 + 8m7 + 5m6 + 17m5 + 27m4 + 30m3 + 14m2 + 6m1 + 2m0
    out1P0  <= (gf_mult_5("00010",msg((SYMB_BITWIDTH-1) downto 0)) xor gf_mult_5("00110",msg(((2*SYMB_BITWIDTH)-1) downto (SYMB_BITWIDTH)))); -- 2*s0 xor 6*s1
    out2P0  <= (out1P0  xor gf_mult_5("01110",msg(((3*SYMB_BITWIDTH)-1)   downto (2*SYMB_BITWIDTH))));     -- out1P0 xor 14*s2
    out3P0  <= (out2P0  xor gf_mult_5("11110",msg(((4*SYMB_BITWIDTH)-1)   downto (3*SYMB_BITWIDTH))));     -- out1P0 xor 30*s3
    out4P0  <= (out3P0  xor gf_mult_5("11011",msg(((5*SYMB_BITWIDTH)-1)   downto (4*SYMB_BITWIDTH))));     -- out1P0 xor 27*s4
    out5P0  <= (out4P0  xor gf_mult_5("10001",msg(((6*SYMB_BITWIDTH)-1)   downto (5*SYMB_BITWIDTH))));     -- out1P0 xor 17*s5
    out6P0  <= (out5P0  xor gf_mult_5("00101",msg(((7*SYMB_BITWIDTH)-1)   downto (6*SYMB_BITWIDTH))));     -- out1P0 xor 5*s6
    out7P0  <= (out6P0  xor gf_mult_5("01000",msg(((8*SYMB_BITWIDTH)-1)   downto (7*SYMB_BITWIDTH))));     -- out1P0 xor 8 *s7
    out8P0  <= (out7P0  xor gf_mult_5("10010",msg(((9*SYMB_BITWIDTH)-1)   downto (8*SYMB_BITWIDTH))));     -- out1P0 xor 18 *s8
    out9P0  <= (out8P0  xor gf_mult_5("00011",msg(((10*SYMB_BITWIDTH)-1)  downto (9*SYMB_BITWIDTH))));     -- out1P0 xor 3 *s9
    out10P0 <= (out9P0  xor gf_mult_5("00100",msg(((11*SYMB_BITWIDTH)-1)  downto (10*SYMB_BITWIDTH))));    -- out1P0 xor 4*s10
    out11P0 <= (out10P0 xor gf_mult_5("01010",msg(((12*SYMB_BITWIDTH)-1)  downto (11*SYMB_BITWIDTH))));    -- out1P0 xor 10 *s11
    out12P0 <= (out11P0 xor gf_mult_5("10110",msg(((13*SYMB_BITWIDTH)-1)  downto (12*SYMB_BITWIDTH))));    -- out1P0 xor 22 *s12
    out13P0 <= (out12P0 xor gf_mult_5("01011",msg(((14*SYMB_BITWIDTH)-1)  downto (13*SYMB_BITWIDTH))));    -- out1P0 xor 11 *s13
    out14P0 <= (out13P0 xor gf_mult_5("10100",msg(((15*SYMB_BITWIDTH)-1)  downto (14*SYMB_BITWIDTH))));    -- out1P0 xor 20 *s14
    out15P0 <= (out14P0 xor gf_mult_5("01111",msg(((16*SYMB_BITWIDTH)-1)  downto (15*SYMB_BITWIDTH))));    -- out1P0 xor 15 *s15
    out16P0 <= (out15P0 xor gf_mult_5("11100",msg(((17*SYMB_BITWIDTH)-1)  downto (16*SYMB_BITWIDTH))));    -- out1P0 xor 28 *s16
    out17P0 <= (out16P0 xor gf_mult_5("11111",msg(((18*SYMB_BITWIDTH)-1)  downto (17*SYMB_BITWIDTH))));    -- out1P0 xor 31 *s17
    out18P0 <= (out17P0 xor gf_mult_5("11001",msg(((19*SYMB_BITWIDTH)-1)  downto (18*SYMB_BITWIDTH))));    -- out1P0 xor 25 *s18
    out19P0 <= (out18P0 xor gf_mult_5("10101",msg(((20*SYMB_BITWIDTH)-1)  downto (19*SYMB_BITWIDTH))));    -- out1P0 xor 21 *s19
    out20P0 <= (out19P0 xor gf_mult_5("01101",msg(((21*SYMB_BITWIDTH)-1)  downto (20*SYMB_BITWIDTH))));    -- out1P0 xor 13 *s20
    out21P0 <= (out20P0 xor gf_mult_5("11000",msg(((22*SYMB_BITWIDTH)-1)  downto (21*SYMB_BITWIDTH))));    -- out1P0 xor 24 *s21
    out22P0 <= (out21P0 xor gf_mult_5("10111",msg(((23*SYMB_BITWIDTH)-1)  downto (22*SYMB_BITWIDTH))));    -- out1P0 xor 23 *s22
    out23P0 <= (out22P0 xor gf_mult_5("01001",msg(((24*SYMB_BITWIDTH)-1)  downto (23*SYMB_BITWIDTH))));    -- out1P0 xor 9 *s23
    out24P0 <= (out23P0 xor gf_mult_5("10000",msg(((25*SYMB_BITWIDTH)-1)  downto (24*SYMB_BITWIDTH))));    -- out1P0 xor 16 *s24
    out25P0 <= (out24P0 xor gf_mult_5("00111",msg(((26*SYMB_BITWIDTH)-1)  downto (25*SYMB_BITWIDTH))));    -- out1P0 xor 7 *s25
    out26P0 <= (out25P0 xor gf_mult_5("01100",msg(((27*SYMB_BITWIDTH)-1)  downto (26*SYMB_BITWIDTH))));    -- out1P0 xor 12 *s26
    out27P0 <= (out26P0 xor gf_mult_5("11010",msg(((28*SYMB_BITWIDTH)-1)  downto (27*SYMB_BITWIDTH))));    -- out1P0 xor 26 *s27
    p0      <= (out27P0 xor gf_mult_5("10011",msg(((29*SYMB_BITWIDTH)-1)  downto (28*SYMB_BITWIDTH))));    -- out1P0 xor 19 *s28

    
    --p1 = 18m28 + 27m27 + 13m26 + 6m25 + 17m24 + 8m23 + 22m22 + 25m21 + 12m20 + 20m19 + 24m18 + 30m17 + 29m16 + 14m15 + 21m14 + 10m13 + 23m12 + 11m11 
    --       + 5m10 + 2m9 + 19m8 + 9m7 + 4m6 + 16m5 + 26m4 + 31m3 + 15m2 + 7m1 + 3m0
    out1P1  <= (gf_mult_5("00011",msg((SYMB_BITWIDTH-1) downto 0)) xor gf_mult_5("00111",msg(((2*SYMB_BITWIDTH)-1) downto (SYMB_BITWIDTH)))); -- 3*s0 xor 7*s1
    out2P1  <= (out1P1  xor gf_mult_5("01111",msg(((3*SYMB_BITWIDTH)-1)   downto (2*SYMB_BITWIDTH))));     -- out1P0 xor 15*s2
    out3P1  <= (out2P1  xor gf_mult_5("11111",msg(((4*SYMB_BITWIDTH)-1)   downto (3*SYMB_BITWIDTH))));     -- out1P0 xor 31*s3
    out4P1  <= (out3P1  xor gf_mult_5("11010",msg(((5*SYMB_BITWIDTH)-1)   downto (4*SYMB_BITWIDTH))));     -- out1P0 xor 26*s4
    out5P1  <= (out4P1  xor gf_mult_5("10000",msg(((6*SYMB_BITWIDTH)-1)   downto (5*SYMB_BITWIDTH))));     -- out1P0 xor 16*s5
    out6P1  <= (out5P1  xor gf_mult_5("00100",msg(((7*SYMB_BITWIDTH)-1)   downto (6*SYMB_BITWIDTH))));     -- out1P0 xor 4 *s6
    out7P1  <= (out6P1  xor gf_mult_5("01001",msg(((8*SYMB_BITWIDTH)-1)   downto (7*SYMB_BITWIDTH))));     -- out1P0 xor 9 *s7
    out8P1  <= (out7P1  xor gf_mult_5("10011",msg(((9*SYMB_BITWIDTH)-1)   downto (8*SYMB_BITWIDTH))));     -- out1P0 xor 19 *s8
    out9P1  <= (out8P1  xor gf_mult_5("00010",msg(((10*SYMB_BITWIDTH)-1)  downto (9*SYMB_BITWIDTH))));     -- out1P0 xor 2 *s9
    out10P1 <= (out9P1  xor gf_mult_5("00101",msg(((11*SYMB_BITWIDTH)-1)  downto (10*SYMB_BITWIDTH))));    -- out1P0 xor 5 *s10
    out11P1 <= (out10P1 xor gf_mult_5("01011",msg(((12*SYMB_BITWIDTH)-1)  downto (11*SYMB_BITWIDTH))));    -- out1P0 xor 11 *s11
    out12P1 <= (out11P1 xor gf_mult_5("10111",msg(((13*SYMB_BITWIDTH)-1)  downto (12*SYMB_BITWIDTH))));    -- out1P0 xor 23 *s12
    out13P1 <= (out12P1 xor gf_mult_5("01010",msg(((14*SYMB_BITWIDTH)-1)  downto (13*SYMB_BITWIDTH))));    -- out1P0 xor 10 *s13
    out14P1 <= (out13P1 xor gf_mult_5("10101",msg(((15*SYMB_BITWIDTH)-1)  downto (14*SYMB_BITWIDTH))));    -- out1P0 xor 21 *s14
    out15P1 <= (out14P1 xor gf_mult_5("01110",msg(((16*SYMB_BITWIDTH)-1)  downto (15*SYMB_BITWIDTH))));    -- out1P0 xor 14 *s15
    out16P1 <= (out15P1 xor gf_mult_5("11101",msg(((17*SYMB_BITWIDTH)-1)  downto (16*SYMB_BITWIDTH))));    -- out1P0 xor 29 *s16
    out17P1 <= (out16P1 xor gf_mult_5("11110",msg(((18*SYMB_BITWIDTH)-1)  downto (17*SYMB_BITWIDTH))));    -- out1P0 xor 30 *s17
    out18P1 <= (out17P1 xor gf_mult_5("11000",msg(((19*SYMB_BITWIDTH)-1)  downto (18*SYMB_BITWIDTH))));    -- out1P0 xor 24 *s18
    out19P1 <= (out18P1 xor gf_mult_5("10100",msg(((20*SYMB_BITWIDTH)-1)  downto (19*SYMB_BITWIDTH))));    -- out1P0 xor 20 *s19
    out20P1 <= (out19P1 xor gf_mult_5("01100",msg(((21*SYMB_BITWIDTH)-1)  downto (20*SYMB_BITWIDTH))));    -- out1P0 xor 12 *s20
    out21P1 <= (out20P1 xor gf_mult_5("11001",msg(((22*SYMB_BITWIDTH)-1)  downto (21*SYMB_BITWIDTH))));    -- out1P0 xor 25 *s21
    out22P1 <= (out21P1 xor gf_mult_5("10110",msg(((23*SYMB_BITWIDTH)-1)  downto (22*SYMB_BITWIDTH))));    -- out1P0 xor 22 *s22
    out23P1 <= (out22P1 xor gf_mult_5("01000",msg(((24*SYMB_BITWIDTH)-1)  downto (23*SYMB_BITWIDTH))));    -- out1P0 xor 8 *s23
    out24P1 <= (out23P1 xor gf_mult_5("10001",msg(((25*SYMB_BITWIDTH)-1)  downto (24*SYMB_BITWIDTH))));    -- out1P0 xor 17 *s24
    out25P1 <= (out24P1 xor gf_mult_5("00110",msg(((26*SYMB_BITWIDTH)-1)  downto (25*SYMB_BITWIDTH))));    -- out1P0 xor 6 *s25
    out26P1 <= (out25P1 xor gf_mult_5("01101",msg(((27*SYMB_BITWIDTH)-1)  downto (26*SYMB_BITWIDTH))));    -- out1P0 xor 13 *s26
    out27P1 <= (out26P1 xor gf_mult_5("11011",msg(((28*SYMB_BITWIDTH)-1)  downto (27*SYMB_BITWIDTH))));    -- out1P0 xor 27 *s27
    p1      <= (out27P1 xor gf_mult_5("10010",msg(((29*SYMB_BITWIDTH)-1)  downto (28*SYMB_BITWIDTH))));    -- out1P0 xor 18 *s28

    
    parity <= p1 & p0;

end Behavioral;
