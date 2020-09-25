----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.08.2020 14:19:19
-- Design Name: 
-- Module Name: lpgbt_downlink_encoder - Behavioral
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
library xil_defaultlib;
use xil_defaultlib.lpgbtfpga_package.all;
--! Include the lpGBT-FPGA specific package
--USE work.lpgbtfpga_package.all;

--! @brief lpgbt_downlink_encoder - Downlink FEC encoder
--! @details computes the FEC bus USEd by the decoder to correct errors. It
--! is based on the N=7, K=5 and SymbWidth=3 implementation of the Reed-Solomon
--! scheme.
ENTITY lpgbt_downlink_encoder IS
   PORT (
		-- Data
		data_i							: in  std_logic_vector(35 downto 0);
		FEC_o							: out std_logic_vector(23 downto 0);

		-- Control
		bypass							: in  std_logic
   );
END lpgbt_downlink_encoder;

--! @brief lpgbt_downlink_encoder - Downlink FEC encoder
--! @details The lpgbt_downlink_encoder module instantiates 4 times the Reed-Solomon
--! N7K5 module WHEN each of them allows correcting a symbol of 3 bits over the
--! 15 of the input message. Additionally, to make the encoding stronger, only
--! 9 bits of each input message are USEd for the lpGBT.
ARCHITECTURE behavioral OF lpgbt_downlink_encoder IS

	SIGNAL virtualFrame_C0		: std_logic_vector(14 downto 0);
	SIGNAL virtualFrame_C1		: std_logic_vector(14 downto 0);
	SIGNAL virtualFrame_C2		: std_logic_vector(14 downto 0);
	SIGNAL virtualFrame_C3		: std_logic_vector(14 downto 0);

	SIGNAL FEC_s				: std_logic_vector(23 downto 0);

	--! Reed-Solomon N7K5 encoding component
	COMPONENT rs_7N5K_enc
	   GENERIC (
			N								: integer := 7;
			K 								: integer := 5;
			SYMB_BITWIDTH					: integer := 3
	   );
	   PORT (
			-- Data
			msg								: in  std_logic_vector((K*SYMB_BITWIDTH)-1 downto 0);
			parity							: out std_logic_vector(((N-K)*SYMB_BITWIDTH)-1 downto 0)
	   );
	END COMPONENT;

BEGIN                 --========####   Architecture Body   ####========--

	virtualFrame_C0	<= "000000" & data_i(8 downto 0);
	virtualFrame_C1	<= "000000" & data_i(17 downto 9);
	virtualFrame_C2	<= "000000" & data_i(26 downto 18);
	virtualFrame_C3	<= "000000" & data_i(35 downto 27);

	--! Reed-Solomon N7K5 encoder (encodes data_i(8 downto 0))
	RSE0_inst: rs_7N5K_enc
	PORT MAP (
		msg				=> virtualFrame_C0,
		parity			=> FEC_s(5 downto 0)
	);

	--! Reed-Solomon N7K5 encoder (encodes data_i(17 downto 9))
	RSE1_inst: rs_7N5K_enc
	PORT MAP (
		msg				=> virtualFrame_C1,
		parity			=> FEC_s(11 downto 6)
	);

	--! Reed-Solomon N7K5 encoder (encodes data_i(26 downto 18))
	RSE2_inst: rs_7N5K_enc
	PORT MAP (
		msg				=> virtualFrame_C2,
		parity			=> FEC_s(17 downto 12)
	);

	--! Reed-Solomon N7K5 encoder (encodes data_i(35 downto 27))
	RSE3_inst: rs_7N5K_enc
	PORT MAP (
		msg				=> virtualFrame_C3,
		parity			=> FEC_s(23 downto 18)
	);

	FEC_o 	<= 	FEC_s WHEN bypass = '0' ELSE (OTHERS => '0');

END behavioral;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--