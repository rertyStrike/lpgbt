----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.08.2020 14:19:19
-- Design Name: 
-- Module Name: lpgbt_downlink_deinterleaver - Behavioral
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

--! @brief lpgbt_downlink_deinterleaver - Downlink data interleaver
--! @details Interleaves the data to mix THEN encoded symbols and improve
--! the decoding efficiency by increasing the number of consecutive bits
--! with errors accepted.
ENTITY lpgbt_downlink_deinterleaver IS
   GENERIC (
        HEADER_c                        : in  std_logic_vector(3 downto 0) := "1001"
   );
   PORT (
		-- Data
		data_i							: in  std_logic_vector(63 downto 0);

		data_o							: out std_logic_vector(35 downto 0);
		FEC_o							: out std_logic_vector(23 downto 0);
		header_o                        : out std_logic_vector(3 downto 0);  
		-- Control
		bypass							: in  std_logic
   );
END lpgbt_downlink_deinterleaver;

--! @brief lpgbt_downlink_deinterleaver - Downlink data interleaver
--! @details The lpgbt_downlink_deinterleaver routes the data from the scrambler and the
--! FEC to mix the symbol (C0/C1/C2/C3/C0/C1...). Therefore the protocol USEd
--! is able to correct up to 4 times 3bit, meaning up to 12 consecutive errors.
--! The interleaver add also the header in the frame, USEd by the receiver to
--! align the frame.
ARCHITECTURE behavioral OF lpgbt_downlink_deinterleaver IS

	SIGNAL fec_data		: std_logic_vector(35 downto 0);
	SIGNAL fec_fecData  : std_logic_vector(23 downto 0);

BEGIN                 --========####   Architecture Body   ####========--

	-- Data & Header
	fec_data(35 downto 0)     <=   data_i(62)                  &
	                               data_i(60)                  &
	                               data_i(58)                  &
	                               data_i(56 downto 54)        &
	                               data_i(44 downto 42)        &
	                               data_i(32 downto 30)        &
	                               data_i(47 downto 45)        &
	                               data_i(53 downto 51)        &
	                               data_i(41 downto 39)        &
	                               data_i(29 downto 27)        &
	                               data_i(35 downto 33)        &
	                               data_i(50 downto 48)        &
	                               data_i(38 downto 36)        &
	                               data_i(26 downto 24);
	                               
	-- FEC
	fec_fecData(23 downto 0)   <=  data_i(23 downto 21)        &
	                               data_i(11 downto  9)        &
	                               data_i(20 downto 18)        &
	                               data_i(8  downto  6)        &
	                               data_i(17 downto 15)        &
	                               data_i(5  downto  3)        &
	                               data_i(14 downto 12)        &
	                               data_i(2  downto  0);
										

	header_o       <= 	HEADER_c WHEN bypass = '0' ELSE
					            data_i(63) & data_i(61) & data_i(59) & data_i(57);

	data_o         <= 	fec_data(35 downto 0) WHEN bypass = '0' ELSE
					    data_i(62)        &
                        data_i(60)        &
                        data_i(58)        &
                        data_i(56 downto 24); -- Without Header 

	FEC_o          <= 	fec_fecData(23 downto 0) WHEN bypass = '0' ELSE
								data_i(23 downto 0);

END behavioral;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--