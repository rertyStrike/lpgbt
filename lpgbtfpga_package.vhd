----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 30.08.2020 14:10:24
-- Design Name: 
-- Module Name: lpgbtfpga_package - Behavioral
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


-- IEEE VHDL standard LIBRARY:
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

PACKAGE lpgbtfpga_package is

   --=============================== Constant Declarations ===============================--
	CONSTANT FEC5						  : integer := 1;
	CONSTANT FEC12						  : integer := 2;
	CONSTANT DATARATE_5G12				  : integer := 1;
	CONSTANT DATARATE_10G24				  : integer := 2;
	CONSTANT PCS         				  : integer := 0;
	CONSTANT PMA         				  : integer := 1;
   --=====================================================================================--
    
   CONSTANT DataRateMode           : integer := DATARATE_10G24;
   --CONSTANT DataRateMode           : integer := DATARATE_10G24;
   CONSTANT FecMode                : integer := FEC12;
   --CONSTANT FecMode                : integer := FEC5;
END lpgbtfpga_package;