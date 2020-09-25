----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.08.2020 23:02:09
-- Design Name: 
-- Module Name: rs_15N13K_enc - Behavioral
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

entity rs_15N13K_enc is
    GENERIC (
         N                   : integer := 15;
         K                   : integer := 13;
         SYMB_BITWIDTH       : integer := 4
    );
    PORT (
         msg         : in  std_logic_vector((K*SYMB_BITWIDTH)-1 downto 0);       --! Message to be encoded
         parity      : out std_logic_vector(((N-K)*SYMB_BITWIDTH)-1 downto 0)    --! FEC output
    );
end rs_15N13K_enc;

architecture Behavioral of rs_15N13K_enc is
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


begin  --========####   Architecture Body   ####========--
	-- ---------------- The Parallel LFSR Recursive HDL description  ---------------- --
    
    --p0 = 8m12 + 5m11 + 10m10 + 4m9 + 3m8 + 9m7 + 12m6 + 7m5 + 11m4 + 13m3 + 14m2 + 6m1 + 2m0
    out1P0  <= (gf_mult_4("0010",msg((SYMB_BITWIDTH-1) downto 0)) xor gf_mult_4("0110",msg(((2*SYMB_BITWIDTH)-1) downto (SYMB_BITWIDTH)))); -- 2*s0 xor 6*s1
    out2P0  <= (out1P0  xor gf_mult_4("1110",msg(((3*SYMB_BITWIDTH)-1)   downto (2*SYMB_BITWIDTH))));     -- out1P0 xor 14*s2
    out3P0  <= (out2P0  xor gf_mult_4("1101",msg(((4*SYMB_BITWIDTH)-1)   downto (3*SYMB_BITWIDTH))));     -- out1P0 xor 13*s3
    out4P0  <= (out3P0  xor gf_mult_4("1011",msg(((5*SYMB_BITWIDTH)-1)   downto (4*SYMB_BITWIDTH))));     -- out1P0 xor 11*s4
    out5P0  <= (out4P0  xor gf_mult_4("0111",msg(((6*SYMB_BITWIDTH)-1)   downto (5*SYMB_BITWIDTH))));     -- out1P0 xor 7 *s5
    out6P0  <= (out5P0  xor gf_mult_4("1100",msg(((7*SYMB_BITWIDTH)-1)   downto (6*SYMB_BITWIDTH))));     -- out1P0 xor 12*s6
    out7P0  <= (out6P0  xor gf_mult_4("1001",msg(((8*SYMB_BITWIDTH)-1)   downto (7*SYMB_BITWIDTH))));     -- out1P0 xor 9 *s7
    out8P0  <= (out7P0  xor gf_mult_4("0011",msg(((9*SYMB_BITWIDTH)-1)   downto (8*SYMB_BITWIDTH))));     -- out1P0 xor 3 *s8
    out9P0  <= (out8P0  xor gf_mult_4("0100",msg(((10*SYMB_BITWIDTH)-1)  downto (9*SYMB_BITWIDTH))));     -- out1P0 xor 4 *s9
    out10P0 <= (out9P0  xor gf_mult_4("1010",msg(((11*SYMB_BITWIDTH)-1)  downto (10*SYMB_BITWIDTH))));    -- out1P0 xor 10*s10
    out11P0 <= (out10P0 xor gf_mult_4("0101",msg(((12*SYMB_BITWIDTH)-1)  downto (11*SYMB_BITWIDTH))));    -- out1P0 xor 5 *s11
    p0      <= (out11P0 xor gf_mult_4("1000",msg(((13*SYMB_BITWIDTH)-1)  downto (12*SYMB_BITWIDTH))));    -- out1P0 xor 8 *s12

    
    --p1 = 9m12 + 4m11 + 11m10 + 5m9 + 2m8 + 8m7 + 13m6 + 6m5 + 10m4 + 12m3 + 15m2 + 7m1 + 3m0
    out1P1  <= (gf_mult_4("0011",msg((SYMB_BITWIDTH-1) downto 0)) xor gf_mult_4("0111",msg(((2*SYMB_BITWIDTH)-1) downto (SYMB_BITWIDTH)))); -- 3*s0 xor 7*s1
    out2P1  <= (out1P1  xor gf_mult_4("1111",msg(((3*SYMB_BITWIDTH)-1)   downto (2*SYMB_BITWIDTH))));     -- out1P0 xor 15*s2
    out3P1  <= (out2P1  xor gf_mult_4("1100",msg(((4*SYMB_BITWIDTH)-1)   downto (3*SYMB_BITWIDTH))));     -- out1P0 xor 12*s3
    out4P1  <= (out3P1  xor gf_mult_4("1010",msg(((5*SYMB_BITWIDTH)-1)   downto (4*SYMB_BITWIDTH))));     -- out1P0 xor 10*s4
    out5P1  <= (out4P1  xor gf_mult_4("0110",msg(((6*SYMB_BITWIDTH)-1)   downto (5*SYMB_BITWIDTH))));     -- out1P0 xor 6 *s5
    out6P1  <= (out5P1  xor gf_mult_4("1101",msg(((7*SYMB_BITWIDTH)-1)   downto (6*SYMB_BITWIDTH))));     -- out1P0 xor 13*s6
    out7P1  <= (out6P1  xor gf_mult_4("1000",msg(((8*SYMB_BITWIDTH)-1)   downto (7*SYMB_BITWIDTH))));     -- out1P0 xor 8 *s7
    out8P1  <= (out7P1  xor gf_mult_4("0010",msg(((9*SYMB_BITWIDTH)-1)   downto (8*SYMB_BITWIDTH))));     -- out1P0 xor 2 *s8
    out9P1  <= (out8P1  xor gf_mult_4("0101",msg(((10*SYMB_BITWIDTH)-1)  downto (9*SYMB_BITWIDTH))));     -- out1P0 xor 5 *s9
    out10P1 <= (out9P1  xor gf_mult_4("1011",msg(((11*SYMB_BITWIDTH)-1)  downto (10*SYMB_BITWIDTH))));    -- out1P0 xor 11*s10
    out11P1 <= (out10P1 xor gf_mult_4("0100",msg(((12*SYMB_BITWIDTH)-1)  downto (11*SYMB_BITWIDTH))));    -- out1P0 xor 4 *s11
    p1      <= (out11P1 xor gf_mult_4("1001",msg(((13*SYMB_BITWIDTH)-1)  downto (12*SYMB_BITWIDTH))));    -- out1P0 xor 9 *s12
    
    parity <= p1 & p0;

end Behavioral;
