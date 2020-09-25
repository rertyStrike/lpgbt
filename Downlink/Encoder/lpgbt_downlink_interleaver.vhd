----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.08.2020 14:19:19
-- Design Name: 
-- Module Name: lpgbt_downlink_interleaver - Behavioral
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

--! @brief lpgbt_downlink_interleaver - Downlink data interleaver
--! @details Interleaves the data to mix THEN encoded symbols and improve
--! the decoding efficiency by increasing the number of consecutive bits
--! with errors accepted.
ENTITY lpgbt_downlink_interleaver IS
   GENERIC (
        HEADER_c                        : in  std_logic_vector(3 downto 0) := "1001"
   );
   PORT (
		-- Data
		data_i							: in  std_logic_vector(35 downto 0);
		FEC_i							: in  std_logic_vector(23 downto 0);

		data_o							: out std_logic_vector(63 downto 0);

		-- Control
		bypass							: in  std_logic
   );
END lpgbt_downlink_interleaver;

--! @brief lpgbt_downlink_interleaver - Downlink data interleaver
--! @details The lpgbt_downlink_interleaver routes the data from the scrambler and the
--! FEC to mix the symbol (C0/C1/C2/C3/C0/C1...). Therefore the protocol USEd
--! is able to correct up to 4 times 3bit, meaning up to 12 consecutive errors.
--! The interleaver add also the header in the frame, USEd by the receiver to
--! align the frame.
ARCHITECTURE behavioral OF lpgbt_downlink_interleaver IS

	SIGNAL interleaved_data		: std_logic_vector(63 downto 0);

BEGIN                 --========####   Architecture Body   ####========--

	-- Data & Header
	interleaved_data(63 downto 24)	<=	HEADER_c(3) 			&
										data_i(35) 				& 
										HEADER_c(2) 			&
										data_i(34) 				& 
										HEADER_c(1) 			&
										data_i(33) 				& 
										HEADER_c(0) 			&
										data_i(32 downto 30) 	& 
										data_i(20 downto 18) 	& 
										data_i(8 downto 6) 		& 
										data_i(23 downto 21)  	&  
										data_i(29 downto 27)	& 
										data_i(17 downto 15)	& 
										data_i(5 downto 3)		& 
										data_i(11 downto 9)  	& 
										data_i(26 downto 24)	& 
										data_i(14 downto 12)	& 
										data_i(2 downto 0);        

	-- FEC
	interleaved_data(23 downto 0)	<=	FEC_i(23 downto 21)		&
										FEC_i(17 downto 15)		&
										FEC_i(11 downto 9)		&
										FEC_i(5 downto 3)		&
										FEC_i(20 downto 18)		&
										FEC_i(14 downto 12)		&
										FEC_i(8 downto 6)		&
										FEC_i(2 downto 0);

	data_o(63)	<= 	interleaved_data(63) WHEN bypass = '0' ELSE
					HEADER_c(3);

	data_o(62)	<= 	interleaved_data(62) WHEN bypass = '0' ELSE
					data_i(35);

	data_o(61)	<= 	interleaved_data(61) WHEN bypass = '0' ELSE
					HEADER_c(2);

	data_o(60)	<= 	interleaved_data(60) WHEN bypass = '0' ELSE
					data_i(34);

	data_o(59)	<= 	interleaved_data(59) WHEN bypass = '0' ELSE
					HEADER_c(1);

	data_o(58)	<= 	interleaved_data(58) WHEN bypass = '0' ELSE
					data_i(33);

	data_o(57)	<= 	interleaved_data(57) WHEN bypass = '0' ELSE
					HEADER_c(0);

	data_o(56 downto 24)	<= 	interleaved_data(56 downto 24) WHEN bypass = '0' ELSE
								data_i(32 downto 0);

	data_o(23 downto 0)		<= 	interleaved_data(23 downto 0) WHEN bypass = '0' ELSE
								FEC_i(23 downto 0);

END behavioral;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--