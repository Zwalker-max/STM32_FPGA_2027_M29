-- ------------------------------------------------------------------------- 
-- Altera DSP Builder Advanced Flow Tools Release Version 14.1
-- Quartus II development tool and MATLAB/Simulink Interface
-- 
-- Legal Notice: Copyright 2014 Altera Corporation.  All rights reserved.
-- Your use of  Altera  Corporation's design tools,  logic functions and other
-- software and tools,  and its AMPP  partner logic functions, and  any output
-- files  any of the  foregoing  device programming or simulation files),  and
-- any associated  documentation or information are expressly subject  to  the
-- terms and conditions  of the Altera Program License Subscription Agreement,
-- Altera  MegaCore  Function  License  Agreement, or other applicable license
-- agreement,  including,  without limitation,  that your use  is for the sole
-- purpose of  programming  logic  devices  manufactured by Altera and sold by
-- Altera or its authorized  distributors.  Please  refer  to  the  applicable
-- agreement for further details.
-- ---------------------------------------------------------------------------

-- VHDL created from FIR1_0002_rtl
-- VHDL created on Wed Jul 29 16:05:55 2026


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.MATH_REAL.all;
use std.TextIO.all;
use work.dspba_library_package.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;
LIBRARY lpm;
USE lpm.lpm_components.all;

entity FIR1_0002_rtl is
    port (
        xIn_v : in std_logic_vector(0 downto 0);  -- sfix1
        xIn_c : in std_logic_vector(7 downto 0);  -- sfix8
        xIn_0 : in std_logic_vector(11 downto 0);  -- sfix12
        xOut_v : out std_logic_vector(0 downto 0);  -- ufix1
        xOut_c : out std_logic_vector(7 downto 0);  -- ufix8
        xOut_0 : out std_logic_vector(34 downto 0);  -- sfix35
        clk : in std_logic;
        areset : in std_logic
    );
end FIR1_0002_rtl;

architecture normal of FIR1_0002_rtl is

    attribute altera_attribute : string;
    attribute altera_attribute of normal : architecture is "-name PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION ON; -name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007";
    
    signal GND_q : STD_LOGIC_VECTOR (0 downto 0);
    signal VCC_q : STD_LOGIC_VECTOR (0 downto 0);
    signal d_xIn_0_13_q : STD_LOGIC_VECTOR (11 downto 0);
    signal d_in0_m0_wi0_wo0_assign_sel_q_13_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_run_count : STD_LOGIC_VECTOR (1 downto 0);
    signal u0_m0_wo0_run_pre_ena_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_run_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_run_out : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_run_enable_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_run_ctrl : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_memread_q : STD_LOGIC_VECTOR (0 downto 0);
    signal d_u0_m0_wo0_memread_q_13_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_compute_q : STD_LOGIC_VECTOR (0 downto 0);
    signal d_u0_m0_wo0_compute_q_19_q : STD_LOGIC_VECTOR (0 downto 0);
    signal d_u0_m0_wo0_compute_q_20_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_ra12_count0_q : STD_LOGIC_VECTOR (4 downto 0);
    signal u0_m0_wo0_wi0_ra12_count0_i : UNSIGNED (4 downto 0);
    signal u0_m0_wo0_wi0_ra12_count0_eq : std_logic;
    signal u0_m0_wo0_wi0_ra12_count0_lutreg_q : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_ra25_count0_q : STD_LOGIC_VECTOR (3 downto 0);
    signal u0_m0_wo0_wi0_ra25_count0_i : UNSIGNED (2 downto 0);
    signal u0_m0_wo0_wi0_ra25_count0_sc : SIGNED (2 downto 0);
    signal u0_m0_wo0_wi0_ra25_count1_q : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_ra25_count1_i : UNSIGNED (2 downto 0);
    signal u0_m0_wo0_wi0_ra25_count1_eq : std_logic;
    signal u0_m0_wo0_wi0_ra25_count1_lutreg_q : STD_LOGIC_VECTOR (3 downto 0);
    signal u0_m0_wo0_wi0_ra25_add_0_0_a : STD_LOGIC_VECTOR (4 downto 0);
    signal u0_m0_wo0_wi0_ra25_add_0_0_b : STD_LOGIC_VECTOR (4 downto 0);
    signal u0_m0_wo0_wi0_ra25_add_0_0_o : STD_LOGIC_VECTOR (4 downto 0);
    signal u0_m0_wo0_wi0_ra25_add_0_0_q : STD_LOGIC_VECTOR (4 downto 0);
    signal u0_m0_wo0_we14_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_we14_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_we25_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_we25_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_we25_3_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_wa0_q : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_wa0_i : UNSIGNED (2 downto 0);
    signal u0_m0_wo0_wi0_wa0_eq : std_logic;
    signal u0_m0_wo0_wi0_wa12_q : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_wa12_i : UNSIGNED (2 downto 0);
    signal u0_m0_wo0_wi0_wa12_eq : std_logic;
    signal u0_m0_wo0_wi0_wa14_q : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_wa14_i : UNSIGNED (2 downto 0);
    signal u0_m0_wo0_wi0_wa25_q : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_wa25_i : UNSIGNED (2 downto 0);
    signal u0_m0_wo0_wi0_delayr0_reset0 : std_logic;
    signal u0_m0_wo0_wi0_delayr0_ia : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_wi0_delayr0_aa : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_delayr0_ab : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_delayr0_iq : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_wi0_delayr0_q : STD_LOGIC_VECTOR (11 downto 0);
    signal d_u0_m0_wo0_wi0_delayr0_q_15_q : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_wi0_delayr1_reset0 : std_logic;
    signal u0_m0_wo0_wi0_delayr1_ia : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_delayr1_aa : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_delayr1_ab : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_delayr1_iq : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_delayr1_q : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_delayr4_reset0 : std_logic;
    signal u0_m0_wo0_wi0_delayr4_ia : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_delayr4_aa : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_delayr4_ab : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_delayr4_iq : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_delayr4_q : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_delayr7_reset0 : std_logic;
    signal u0_m0_wo0_wi0_delayr7_ia : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_delayr7_aa : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_delayr7_ab : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_delayr7_iq : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_delayr7_q : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_delayr10_reset0 : std_logic;
    signal u0_m0_wo0_wi0_delayr10_ia : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_delayr10_aa : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_delayr10_ab : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_delayr10_iq : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_delayr10_q : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_delayr14_reset0 : std_logic;
    signal u0_m0_wo0_wi0_delayr14_ia : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_wi0_delayr14_aa : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_delayr14_ab : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_delayr14_iq : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_wi0_delayr14_q : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_wi0_delayr15_reset0 : std_logic;
    signal u0_m0_wo0_wi0_delayr15_ia : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_delayr15_aa : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_delayr15_ab : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_delayr15_iq : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_delayr15_q : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_delayr18_reset0 : std_logic;
    signal u0_m0_wo0_wi0_delayr18_ia : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_delayr18_aa : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_delayr18_ab : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_delayr18_iq : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_delayr18_q : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_delayr21_reset0 : std_logic;
    signal u0_m0_wo0_wi0_delayr21_ia : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_delayr21_aa : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_delayr21_ab : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_delayr21_iq : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_delayr21_q : STD_LOGIC_VECTOR (35 downto 0);
    signal d_u0_m0_wo0_wi0_split24_c_15_q : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_wi0_delayr24_reset0 : std_logic;
    signal u0_m0_wo0_wi0_delayr24_ia : STD_LOGIC_VECTOR (23 downto 0);
    signal u0_m0_wo0_wi0_delayr24_aa : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_delayr24_ab : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_delayr24_iq : STD_LOGIC_VECTOR (23 downto 0);
    signal u0_m0_wo0_wi0_delayr24_q : STD_LOGIC_VECTOR (23 downto 0);
    signal u0_m0_wo0_ca12_q : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_ca12_i : UNSIGNED (2 downto 0);
    signal u0_m0_wo0_ca12_eq : std_logic;
    signal d_u0_m0_wo0_ca12_q_15_q : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_cm0_q : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_cm1_q : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_cm2_q : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_cm3_q : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_cm4_q : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_cm5_q : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_cm6_q : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_cm7_q : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_cm8_q : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_cm9_q : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_cm10_q : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_cm11_q : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_cm12_q : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_sym_add0_a : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add0_b : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add0_o : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add0_q : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add1_a : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add1_b : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add1_o : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add1_q : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add2_a : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add2_b : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add2_o : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add2_q : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add3_a : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add3_b : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add3_o : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add3_q : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add4_a : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add4_b : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add4_o : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add4_q : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add5_a : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add5_b : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add5_o : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add5_q : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add6_a : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add6_b : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add6_o : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add6_q : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add7_a : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add7_b : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add7_o : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add7_q : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add8_a : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add8_b : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add8_o : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add8_q : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add9_a : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add9_b : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add9_o : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add9_q : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add10_a : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add10_b : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add10_o : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add10_q : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add11_a : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add11_b : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add11_o : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add11_q : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add12_a : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add12_b : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add12_i : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add12_o : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_sym_add12_q : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_mtree_mult1_12_a0 : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_mtree_mult1_12_b0 : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_mtree_mult1_12_s1 : STD_LOGIC_VECTOR (28 downto 0);
    signal u0_m0_wo0_mtree_mult1_12_reset : std_logic;
    signal u0_m0_wo0_mtree_mult1_12_q : STD_LOGIC_VECTOR (28 downto 0);
    signal u0_m0_wo0_mtree_mult1_11_a0 : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_mtree_mult1_11_b0 : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_mtree_mult1_11_s1 : STD_LOGIC_VECTOR (28 downto 0);
    signal u0_m0_wo0_mtree_mult1_11_reset : std_logic;
    signal u0_m0_wo0_mtree_mult1_11_q : STD_LOGIC_VECTOR (28 downto 0);
    signal u0_m0_wo0_mtree_mult1_10_a0 : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_mtree_mult1_10_b0 : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_mtree_mult1_10_s1 : STD_LOGIC_VECTOR (28 downto 0);
    signal u0_m0_wo0_mtree_mult1_10_reset : std_logic;
    signal u0_m0_wo0_mtree_mult1_10_q : STD_LOGIC_VECTOR (28 downto 0);
    signal u0_m0_wo0_mtree_mult1_9_a0 : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_mtree_mult1_9_b0 : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_mtree_mult1_9_s1 : STD_LOGIC_VECTOR (28 downto 0);
    signal u0_m0_wo0_mtree_mult1_9_reset : std_logic;
    signal u0_m0_wo0_mtree_mult1_9_q : STD_LOGIC_VECTOR (28 downto 0);
    signal u0_m0_wo0_mtree_mult1_8_a0 : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_mtree_mult1_8_b0 : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_mtree_mult1_8_s1 : STD_LOGIC_VECTOR (28 downto 0);
    signal u0_m0_wo0_mtree_mult1_8_reset : std_logic;
    signal u0_m0_wo0_mtree_mult1_8_q : STD_LOGIC_VECTOR (28 downto 0);
    signal u0_m0_wo0_mtree_mult1_7_a0 : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_mtree_mult1_7_b0 : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_mtree_mult1_7_s1 : STD_LOGIC_VECTOR (28 downto 0);
    signal u0_m0_wo0_mtree_mult1_7_reset : std_logic;
    signal u0_m0_wo0_mtree_mult1_7_q : STD_LOGIC_VECTOR (28 downto 0);
    signal u0_m0_wo0_mtree_mult1_6_a0 : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_mtree_mult1_6_b0 : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_mtree_mult1_6_s1 : STD_LOGIC_VECTOR (28 downto 0);
    signal u0_m0_wo0_mtree_mult1_6_reset : std_logic;
    signal u0_m0_wo0_mtree_mult1_6_q : STD_LOGIC_VECTOR (28 downto 0);
    signal u0_m0_wo0_mtree_mult1_5_a0 : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_mtree_mult1_5_b0 : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_mtree_mult1_5_s1 : STD_LOGIC_VECTOR (28 downto 0);
    signal u0_m0_wo0_mtree_mult1_5_reset : std_logic;
    signal u0_m0_wo0_mtree_mult1_5_q : STD_LOGIC_VECTOR (28 downto 0);
    signal u0_m0_wo0_mtree_mult1_4_a0 : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_mtree_mult1_4_b0 : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_mtree_mult1_4_s1 : STD_LOGIC_VECTOR (28 downto 0);
    signal u0_m0_wo0_mtree_mult1_4_reset : std_logic;
    signal u0_m0_wo0_mtree_mult1_4_q : STD_LOGIC_VECTOR (28 downto 0);
    signal u0_m0_wo0_mtree_mult1_3_a0 : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_mtree_mult1_3_b0 : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_mtree_mult1_3_s1 : STD_LOGIC_VECTOR (28 downto 0);
    signal u0_m0_wo0_mtree_mult1_3_reset : std_logic;
    signal u0_m0_wo0_mtree_mult1_3_q : STD_LOGIC_VECTOR (28 downto 0);
    signal u0_m0_wo0_mtree_mult1_2_a0 : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_mtree_mult1_2_b0 : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_mtree_mult1_2_s1 : STD_LOGIC_VECTOR (28 downto 0);
    signal u0_m0_wo0_mtree_mult1_2_reset : std_logic;
    signal u0_m0_wo0_mtree_mult1_2_q : STD_LOGIC_VECTOR (28 downto 0);
    signal u0_m0_wo0_mtree_mult1_1_a0 : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_mtree_mult1_1_b0 : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_mtree_mult1_1_s1 : STD_LOGIC_VECTOR (28 downto 0);
    signal u0_m0_wo0_mtree_mult1_1_reset : std_logic;
    signal u0_m0_wo0_mtree_mult1_1_q : STD_LOGIC_VECTOR (28 downto 0);
    signal u0_m0_wo0_mtree_mult1_0_a0 : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_mtree_mult1_0_b0 : STD_LOGIC_VECTOR (12 downto 0);
    signal u0_m0_wo0_mtree_mult1_0_s1 : STD_LOGIC_VECTOR (28 downto 0);
    signal u0_m0_wo0_mtree_mult1_0_reset : std_logic;
    signal u0_m0_wo0_mtree_mult1_0_q : STD_LOGIC_VECTOR (28 downto 0);
    signal u0_m0_wo0_mtree_add0_0_a : STD_LOGIC_VECTOR (29 downto 0);
    signal u0_m0_wo0_mtree_add0_0_b : STD_LOGIC_VECTOR (29 downto 0);
    signal u0_m0_wo0_mtree_add0_0_o : STD_LOGIC_VECTOR (29 downto 0);
    signal u0_m0_wo0_mtree_add0_0_q : STD_LOGIC_VECTOR (29 downto 0);
    signal u0_m0_wo0_mtree_add0_1_a : STD_LOGIC_VECTOR (29 downto 0);
    signal u0_m0_wo0_mtree_add0_1_b : STD_LOGIC_VECTOR (29 downto 0);
    signal u0_m0_wo0_mtree_add0_1_o : STD_LOGIC_VECTOR (29 downto 0);
    signal u0_m0_wo0_mtree_add0_1_q : STD_LOGIC_VECTOR (29 downto 0);
    signal u0_m0_wo0_mtree_add0_2_a : STD_LOGIC_VECTOR (29 downto 0);
    signal u0_m0_wo0_mtree_add0_2_b : STD_LOGIC_VECTOR (29 downto 0);
    signal u0_m0_wo0_mtree_add0_2_o : STD_LOGIC_VECTOR (29 downto 0);
    signal u0_m0_wo0_mtree_add0_2_q : STD_LOGIC_VECTOR (29 downto 0);
    signal u0_m0_wo0_mtree_add0_3_a : STD_LOGIC_VECTOR (29 downto 0);
    signal u0_m0_wo0_mtree_add0_3_b : STD_LOGIC_VECTOR (29 downto 0);
    signal u0_m0_wo0_mtree_add0_3_o : STD_LOGIC_VECTOR (29 downto 0);
    signal u0_m0_wo0_mtree_add0_3_q : STD_LOGIC_VECTOR (29 downto 0);
    signal u0_m0_wo0_mtree_add0_4_a : STD_LOGIC_VECTOR (29 downto 0);
    signal u0_m0_wo0_mtree_add0_4_b : STD_LOGIC_VECTOR (29 downto 0);
    signal u0_m0_wo0_mtree_add0_4_o : STD_LOGIC_VECTOR (29 downto 0);
    signal u0_m0_wo0_mtree_add0_4_q : STD_LOGIC_VECTOR (29 downto 0);
    signal u0_m0_wo0_mtree_add0_5_a : STD_LOGIC_VECTOR (29 downto 0);
    signal u0_m0_wo0_mtree_add0_5_b : STD_LOGIC_VECTOR (29 downto 0);
    signal u0_m0_wo0_mtree_add0_5_o : STD_LOGIC_VECTOR (29 downto 0);
    signal u0_m0_wo0_mtree_add0_5_q : STD_LOGIC_VECTOR (29 downto 0);
    signal u0_m0_wo0_mtree_add1_0_a : STD_LOGIC_VECTOR (30 downto 0);
    signal u0_m0_wo0_mtree_add1_0_b : STD_LOGIC_VECTOR (30 downto 0);
    signal u0_m0_wo0_mtree_add1_0_o : STD_LOGIC_VECTOR (30 downto 0);
    signal u0_m0_wo0_mtree_add1_0_q : STD_LOGIC_VECTOR (30 downto 0);
    signal u0_m0_wo0_mtree_add1_1_a : STD_LOGIC_VECTOR (30 downto 0);
    signal u0_m0_wo0_mtree_add1_1_b : STD_LOGIC_VECTOR (30 downto 0);
    signal u0_m0_wo0_mtree_add1_1_o : STD_LOGIC_VECTOR (30 downto 0);
    signal u0_m0_wo0_mtree_add1_1_q : STD_LOGIC_VECTOR (30 downto 0);
    signal u0_m0_wo0_mtree_add1_2_a : STD_LOGIC_VECTOR (30 downto 0);
    signal u0_m0_wo0_mtree_add1_2_b : STD_LOGIC_VECTOR (30 downto 0);
    signal u0_m0_wo0_mtree_add1_2_o : STD_LOGIC_VECTOR (30 downto 0);
    signal u0_m0_wo0_mtree_add1_2_q : STD_LOGIC_VECTOR (30 downto 0);
    signal u0_m0_wo0_mtree_add2_0_a : STD_LOGIC_VECTOR (31 downto 0);
    signal u0_m0_wo0_mtree_add2_0_b : STD_LOGIC_VECTOR (31 downto 0);
    signal u0_m0_wo0_mtree_add2_0_o : STD_LOGIC_VECTOR (31 downto 0);
    signal u0_m0_wo0_mtree_add2_0_q : STD_LOGIC_VECTOR (31 downto 0);
    signal u0_m0_wo0_mtree_add2_1_a : STD_LOGIC_VECTOR (31 downto 0);
    signal u0_m0_wo0_mtree_add2_1_b : STD_LOGIC_VECTOR (31 downto 0);
    signal u0_m0_wo0_mtree_add2_1_o : STD_LOGIC_VECTOR (31 downto 0);
    signal u0_m0_wo0_mtree_add2_1_q : STD_LOGIC_VECTOR (31 downto 0);
    signal u0_m0_wo0_mtree_add3_0_a : STD_LOGIC_VECTOR (32 downto 0);
    signal u0_m0_wo0_mtree_add3_0_b : STD_LOGIC_VECTOR (32 downto 0);
    signal u0_m0_wo0_mtree_add3_0_o : STD_LOGIC_VECTOR (32 downto 0);
    signal u0_m0_wo0_mtree_add3_0_q : STD_LOGIC_VECTOR (32 downto 0);
    signal u0_m0_wo0_aseq_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_aseq_eq : std_logic;
    signal u0_m0_wo0_accum_a : STD_LOGIC_VECTOR (34 downto 0);
    signal u0_m0_wo0_accum_b : STD_LOGIC_VECTOR (34 downto 0);
    signal u0_m0_wo0_accum_i : STD_LOGIC_VECTOR (34 downto 0);
    signal u0_m0_wo0_accum_o : STD_LOGIC_VECTOR (34 downto 0);
    signal u0_m0_wo0_accum_q : STD_LOGIC_VECTOR (34 downto 0);
    signal u0_m0_wo0_oseq_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_oseq_eq : std_logic;
    signal u0_m0_wo0_oseq_gated_reg_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_we14_a : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_we14_b : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_we14_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_we25_a : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_we25_b : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_we25_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_oseq_gated_a : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_oseq_gated_b : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_oseq_gated_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_ra12_count0_lut_q : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_ra25_count1_lut_q : STD_LOGIC_VECTOR (3 downto 0);
    signal u0_m0_wo0_wi0_ra25_resize_in : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_ra25_resize_b : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_split1_in : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_split1_b : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_wi0_split1_c : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_wi0_split1_d : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_wi0_split4_in : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_split4_b : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_wi0_split4_c : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_wi0_split4_d : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_wi0_split7_in : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_split7_b : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_wi0_split7_c : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_wi0_split7_d : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_wi0_split10_in : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_split10_b : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_wi0_split10_c : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_wi0_split10_d : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_wi0_split15_in : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_split15_b : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_wi0_split15_c : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_wi0_split15_d : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_wi0_split18_in : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_split18_b : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_wi0_split18_c : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_wi0_split18_d : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_wi0_split21_in : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_split21_b : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_wi0_split21_c : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_wi0_split21_d : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_wi0_split24_in : STD_LOGIC_VECTOR (23 downto 0);
    signal u0_m0_wo0_wi0_split24_b : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_wi0_split24_c : STD_LOGIC_VECTOR (11 downto 0);
    signal u0_m0_wo0_wi0_join1_q : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_join4_q : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_join7_q : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_join10_q : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_join15_q : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_join18_q : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_join21_q : STD_LOGIC_VECTOR (35 downto 0);
    signal u0_m0_wo0_wi0_join24_q : STD_LOGIC_VECTOR (23 downto 0);

begin


    -- VCC(CONSTANT,1)@0
    VCC_q <= "1";

    -- xIn(PORTIN,2)@10

    -- u0_m0_wo0_run(ENABLEGENERATOR,5)@10
    u0_m0_wo0_run_ctrl <= u0_m0_wo0_run_out & xIn_v & u0_m0_wo0_run_enable_q;
    u0_m0_wo0_run: PROCESS (clk, areset)
        variable u0_m0_wo0_run_enable_c : SIGNED(2 downto 0);
        variable u0_m0_wo0_run_inc : SIGNED(1 downto 0);
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_run_q <= "0";
            u0_m0_wo0_run_enable_c := TO_SIGNED(3, 3);
            u0_m0_wo0_run_enable_q <= "0";
            u0_m0_wo0_run_count <= "00";
            u0_m0_wo0_run_inc := (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_run_out = "1") THEN
                IF (u0_m0_wo0_run_enable_c(2) = '1') THEN
                    u0_m0_wo0_run_enable_c := u0_m0_wo0_run_enable_c - (-4);
                ELSE
                    u0_m0_wo0_run_enable_c := u0_m0_wo0_run_enable_c + (-1);
                END IF;
                u0_m0_wo0_run_enable_q <= STD_LOGIC_VECTOR(u0_m0_wo0_run_enable_c(2 downto 2));
            ELSE
                u0_m0_wo0_run_enable_q <= "0";
            END IF;
            CASE (u0_m0_wo0_run_ctrl) IS
                WHEN "000" | "001" => u0_m0_wo0_run_inc := "00";
                WHEN "010" | "011" => u0_m0_wo0_run_inc := "11";
                WHEN "100" => u0_m0_wo0_run_inc := "00";
                WHEN "101" => u0_m0_wo0_run_inc := "01";
                WHEN "110" => u0_m0_wo0_run_inc := "11";
                WHEN "111" => u0_m0_wo0_run_inc := "00";
                WHEN OTHERS => 
            END CASE;
            u0_m0_wo0_run_count <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_run_count) + SIGNED(u0_m0_wo0_run_inc));
            u0_m0_wo0_run_q <= u0_m0_wo0_run_out;
        END IF;
    END PROCESS;
    u0_m0_wo0_run_pre_ena_q <= u0_m0_wo0_run_count(1 downto 1);
    u0_m0_wo0_run_out <= u0_m0_wo0_run_pre_ena_q and VCC_q;

    -- u0_m0_wo0_memread(DELAY,6)@12
    u0_m0_wo0_memread : dspba_delay
    GENERIC MAP ( width => 1, depth => 1 )
    PORT MAP ( xin => u0_m0_wo0_run_q, xout => u0_m0_wo0_memread_q, clk => clk, aclr => areset );

    -- d_u0_m0_wo0_memread_q_13(DELAY,127)@12
    d_u0_m0_wo0_memread_q_13 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1 )
    PORT MAP ( xin => u0_m0_wo0_memread_q, xout => d_u0_m0_wo0_memread_q_13_q, clk => clk, aclr => areset );

    -- u0_m0_wo0_compute(DELAY,7)@13
    u0_m0_wo0_compute : dspba_delay
    GENERIC MAP ( width => 1, depth => 2 )
    PORT MAP ( xin => d_u0_m0_wo0_memread_q_13_q, xout => u0_m0_wo0_compute_q, clk => clk, aclr => areset );

    -- d_u0_m0_wo0_compute_q_19(DELAY,128)@13
    d_u0_m0_wo0_compute_q_19 : dspba_delay
    GENERIC MAP ( width => 1, depth => 6 )
    PORT MAP ( xin => u0_m0_wo0_compute_q, xout => d_u0_m0_wo0_compute_q_19_q, clk => clk, aclr => areset );

    -- u0_m0_wo0_aseq(SEQUENCE,117)@19
    u0_m0_wo0_aseq: PROCESS (clk, areset)
        variable u0_m0_wo0_aseq_c : SIGNED(4 downto 0);
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_aseq_c := "00000";
            u0_m0_wo0_aseq_q <= "0";
            u0_m0_wo0_aseq_eq <= '0';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (d_u0_m0_wo0_compute_q_19_q = "1") THEN
                IF (u0_m0_wo0_aseq_c = "00000") THEN
                    u0_m0_wo0_aseq_eq <= '1';
                ELSE
                    u0_m0_wo0_aseq_eq <= '0';
                END IF;
                IF (u0_m0_wo0_aseq_eq = '1') THEN
                    u0_m0_wo0_aseq_c := u0_m0_wo0_aseq_c + 4;
                ELSE
                    u0_m0_wo0_aseq_c := u0_m0_wo0_aseq_c - 1;
                END IF;
                u0_m0_wo0_aseq_q <= STD_LOGIC_VECTOR(u0_m0_wo0_aseq_c(4 downto 4));
            END IF;
        END IF;
    END PROCESS;

    -- d_u0_m0_wo0_compute_q_20(DELAY,129)@19
    d_u0_m0_wo0_compute_q_20 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1 )
    PORT MAP ( xin => d_u0_m0_wo0_compute_q_19_q, xout => d_u0_m0_wo0_compute_q_20_q, clk => clk, aclr => areset );

    -- u0_m0_wo0_wi0_ra25_count1(COUNTER,12)@12
    -- every=1, low=0, high=4, step=1, init=1
    u0_m0_wo0_wi0_ra25_count1: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_ra25_count1_i <= TO_UNSIGNED(1, 3);
            u0_m0_wo0_wi0_ra25_count1_eq <= '0';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_memread_q = "1") THEN
                IF (u0_m0_wo0_wi0_ra25_count1_i = TO_UNSIGNED(3, 3)) THEN
                    u0_m0_wo0_wi0_ra25_count1_eq <= '1';
                ELSE
                    u0_m0_wo0_wi0_ra25_count1_eq <= '0';
                END IF;
                IF (u0_m0_wo0_wi0_ra25_count1_eq = '1') THEN
                    u0_m0_wo0_wi0_ra25_count1_i <= u0_m0_wo0_wi0_ra25_count1_i - 4;
                ELSE
                    u0_m0_wo0_wi0_ra25_count1_i <= u0_m0_wo0_wi0_ra25_count1_i + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;
    u0_m0_wo0_wi0_ra25_count1_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(u0_m0_wo0_wi0_ra25_count1_i, 3)));

    -- u0_m0_wo0_wi0_ra25_count1_lut(LOOKUP,13)@12
    u0_m0_wo0_wi0_ra25_count1_lut: PROCESS (u0_m0_wo0_wi0_ra25_count1_q)
    BEGIN
        -- Begin reserved scope level
        CASE (u0_m0_wo0_wi0_ra25_count1_q) IS
            WHEN "000" => u0_m0_wo0_wi0_ra25_count1_lut_q <= "0011";
            WHEN "001" => u0_m0_wo0_wi0_ra25_count1_lut_q <= "0010";
            WHEN "010" => u0_m0_wo0_wi0_ra25_count1_lut_q <= "0001";
            WHEN "011" => u0_m0_wo0_wi0_ra25_count1_lut_q <= "0000";
            WHEN "100" => u0_m0_wo0_wi0_ra25_count1_lut_q <= "0111";
            WHEN OTHERS => -- unreachable
                           u0_m0_wo0_wi0_ra25_count1_lut_q <= (others => '-');
        END CASE;
        -- End reserved scope level
    END PROCESS;

    -- u0_m0_wo0_wi0_ra25_count1_lutreg(REG,14)@12
    u0_m0_wo0_wi0_ra25_count1_lutreg: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_ra25_count1_lutreg_q <= "0011";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_memread_q = "1") THEN
                u0_m0_wo0_wi0_ra25_count1_lutreg_q <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_ra25_count1_lut_q);
            END IF;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_wi0_ra25_count0(COUNTER,11)@12
    -- every=5, low=0, high=7, step=1, init=0
    u0_m0_wo0_wi0_ra25_count0: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_ra25_count0_i <= TO_UNSIGNED(0, 3);
            u0_m0_wo0_wi0_ra25_count0_sc <= TO_SIGNED(3, 3);
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_memread_q = "1") THEN
                IF (u0_m0_wo0_wi0_ra25_count0_sc(2) = '1') THEN
                    u0_m0_wo0_wi0_ra25_count0_sc <= u0_m0_wo0_wi0_ra25_count0_sc - (-4);
                ELSE
                    u0_m0_wo0_wi0_ra25_count0_sc <= u0_m0_wo0_wi0_ra25_count0_sc + (-1);
                END IF;
                IF (u0_m0_wo0_wi0_ra25_count0_sc(2) = '1') THEN
                    u0_m0_wo0_wi0_ra25_count0_i <= u0_m0_wo0_wi0_ra25_count0_i + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;
    u0_m0_wo0_wi0_ra25_count0_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(u0_m0_wo0_wi0_ra25_count0_i, 4)));

    -- u0_m0_wo0_wi0_ra25_add_0_0(ADD,15)@12
    u0_m0_wo0_wi0_ra25_add_0_0_a <= STD_LOGIC_VECTOR("0" & u0_m0_wo0_wi0_ra25_count0_q);
    u0_m0_wo0_wi0_ra25_add_0_0_b <= STD_LOGIC_VECTOR("0" & u0_m0_wo0_wi0_ra25_count1_lutreg_q);
    u0_m0_wo0_wi0_ra25_add_0_0: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_ra25_add_0_0_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_wi0_ra25_add_0_0_o <= STD_LOGIC_VECTOR(UNSIGNED(u0_m0_wo0_wi0_ra25_add_0_0_a) + UNSIGNED(u0_m0_wo0_wi0_ra25_add_0_0_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_wi0_ra25_add_0_0_q <= u0_m0_wo0_wi0_ra25_add_0_0_o(4 downto 0);

    -- u0_m0_wo0_wi0_ra25_resize(BITSELECT,16)@13
    u0_m0_wo0_wi0_ra25_resize_in <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_ra25_add_0_0_q(2 downto 0));
    u0_m0_wo0_wi0_ra25_resize_b <= u0_m0_wo0_wi0_ra25_resize_in(2 downto 0);

    -- u0_m0_wo0_wi0_ra12_count0(COUNTER,8)@13
    -- every=1, low=0, high=24, step=1, init=1
    u0_m0_wo0_wi0_ra12_count0: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_ra12_count0_i <= TO_UNSIGNED(1, 5);
            u0_m0_wo0_wi0_ra12_count0_eq <= '0';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (d_u0_m0_wo0_memread_q_13_q = "1") THEN
                IF (u0_m0_wo0_wi0_ra12_count0_i = TO_UNSIGNED(23, 5)) THEN
                    u0_m0_wo0_wi0_ra12_count0_eq <= '1';
                ELSE
                    u0_m0_wo0_wi0_ra12_count0_eq <= '0';
                END IF;
                IF (u0_m0_wo0_wi0_ra12_count0_eq = '1') THEN
                    u0_m0_wo0_wi0_ra12_count0_i <= u0_m0_wo0_wi0_ra12_count0_i - 24;
                ELSE
                    u0_m0_wo0_wi0_ra12_count0_i <= u0_m0_wo0_wi0_ra12_count0_i + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;
    u0_m0_wo0_wi0_ra12_count0_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(u0_m0_wo0_wi0_ra12_count0_i, 5)));

    -- u0_m0_wo0_wi0_ra12_count0_lut(LOOKUP,9)@13
    u0_m0_wo0_wi0_ra12_count0_lut: PROCESS (u0_m0_wo0_wi0_ra12_count0_q)
    BEGIN
        -- Begin reserved scope level
        CASE (u0_m0_wo0_wi0_ra12_count0_q) IS
            WHEN "00000" => u0_m0_wo0_wi0_ra12_count0_lut_q <= "000";
            WHEN "00001" => u0_m0_wo0_wi0_ra12_count0_lut_q <= "001";
            WHEN "00010" => u0_m0_wo0_wi0_ra12_count0_lut_q <= "010";
            WHEN "00011" => u0_m0_wo0_wi0_ra12_count0_lut_q <= "011";
            WHEN "00100" => u0_m0_wo0_wi0_ra12_count0_lut_q <= "100";
            WHEN "00101" => u0_m0_wo0_wi0_ra12_count0_lut_q <= "001";
            WHEN "00110" => u0_m0_wo0_wi0_ra12_count0_lut_q <= "010";
            WHEN "00111" => u0_m0_wo0_wi0_ra12_count0_lut_q <= "011";
            WHEN "01000" => u0_m0_wo0_wi0_ra12_count0_lut_q <= "100";
            WHEN "01001" => u0_m0_wo0_wi0_ra12_count0_lut_q <= "000";
            WHEN "01010" => u0_m0_wo0_wi0_ra12_count0_lut_q <= "010";
            WHEN "01011" => u0_m0_wo0_wi0_ra12_count0_lut_q <= "011";
            WHEN "01100" => u0_m0_wo0_wi0_ra12_count0_lut_q <= "100";
            WHEN "01101" => u0_m0_wo0_wi0_ra12_count0_lut_q <= "000";
            WHEN "01110" => u0_m0_wo0_wi0_ra12_count0_lut_q <= "001";
            WHEN "01111" => u0_m0_wo0_wi0_ra12_count0_lut_q <= "011";
            WHEN "10000" => u0_m0_wo0_wi0_ra12_count0_lut_q <= "100";
            WHEN "10001" => u0_m0_wo0_wi0_ra12_count0_lut_q <= "000";
            WHEN "10010" => u0_m0_wo0_wi0_ra12_count0_lut_q <= "001";
            WHEN "10011" => u0_m0_wo0_wi0_ra12_count0_lut_q <= "010";
            WHEN "10100" => u0_m0_wo0_wi0_ra12_count0_lut_q <= "100";
            WHEN "10101" => u0_m0_wo0_wi0_ra12_count0_lut_q <= "000";
            WHEN "10110" => u0_m0_wo0_wi0_ra12_count0_lut_q <= "001";
            WHEN "10111" => u0_m0_wo0_wi0_ra12_count0_lut_q <= "010";
            WHEN "11000" => u0_m0_wo0_wi0_ra12_count0_lut_q <= "011";
            WHEN OTHERS => -- unreachable
                           u0_m0_wo0_wi0_ra12_count0_lut_q <= (others => '-');
        END CASE;
        -- End reserved scope level
    END PROCESS;

    -- u0_m0_wo0_wi0_ra12_count0_lutreg(REG,10)@13
    u0_m0_wo0_wi0_ra12_count0_lutreg: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_ra12_count0_lutreg_q <= "000";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (d_u0_m0_wo0_memread_q_13_q = "1") THEN
                u0_m0_wo0_wi0_ra12_count0_lutreg_q <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_ra12_count0_lut_q);
            END IF;
        END IF;
    END PROCESS;

    -- d_xIn_0_13(DELAY,125)@10
    d_xIn_0_13 : dspba_delay
    GENERIC MAP ( width => 12, depth => 3 )
    PORT MAP ( xin => xIn_0, xout => d_xIn_0_13_q, clk => clk, aclr => areset );

    -- d_in0_m0_wi0_wo0_assign_sel_q_13(DELAY,126)@10
    d_in0_m0_wi0_wo0_assign_sel_q_13 : dspba_delay
    GENERIC MAP ( width => 1, depth => 3 )
    PORT MAP ( xin => xIn_v, xout => d_in0_m0_wi0_wo0_assign_sel_q_13_q, clk => clk, aclr => areset );

    -- u0_m0_wo0_wi0_wa0(COUNTER,24)@13
    -- every=1, low=0, high=4, step=1, init=4
    u0_m0_wo0_wi0_wa0: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_wa0_i <= TO_UNSIGNED(4, 3);
            u0_m0_wo0_wi0_wa0_eq <= '1';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (d_in0_m0_wi0_wo0_assign_sel_q_13_q = "1") THEN
                IF (u0_m0_wo0_wi0_wa0_i = TO_UNSIGNED(3, 3)) THEN
                    u0_m0_wo0_wi0_wa0_eq <= '1';
                ELSE
                    u0_m0_wo0_wi0_wa0_eq <= '0';
                END IF;
                IF (u0_m0_wo0_wi0_wa0_eq = '1') THEN
                    u0_m0_wo0_wi0_wa0_i <= u0_m0_wo0_wi0_wa0_i - 4;
                ELSE
                    u0_m0_wo0_wi0_wa0_i <= u0_m0_wo0_wi0_wa0_i + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;
    u0_m0_wo0_wi0_wa0_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(u0_m0_wo0_wi0_wa0_i, 3)));

    -- u0_m0_wo0_wi0_delayr0(DUALMEM,28)@13
    u0_m0_wo0_wi0_delayr0_ia <= STD_LOGIC_VECTOR(d_xIn_0_13_q);
    u0_m0_wo0_wi0_delayr0_aa <= u0_m0_wo0_wi0_wa0_q;
    u0_m0_wo0_wi0_delayr0_ab <= u0_m0_wo0_wi0_ra12_count0_lutreg_q;
    u0_m0_wo0_wi0_delayr0_reset0 <= areset;
    u0_m0_wo0_wi0_delayr0_dmem : altsyncram
    GENERIC MAP (
        ram_block_type => "M9K",
        operation_mode => "DUAL_PORT",
        width_a => 12,
        widthad_a => 3,
        numwords_a => 5,
        width_b => 12,
        widthad_b => 3,
        numwords_b => 5,
        lpm_type => "altsyncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        wrcontrol_wraddress_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK0",
        outdata_aclr_b => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "OLD_DATA",
        power_up_uninitialized => "FALSE",
        init_file => "UNUSED",
        intended_device_family => "Cyclone IV E"
    )
    PORT MAP (
        clocken0 => '1',
        aclr0 => u0_m0_wo0_wi0_delayr0_reset0,
        clock0 => clk,
        address_a => u0_m0_wo0_wi0_delayr0_aa,
        data_a => u0_m0_wo0_wi0_delayr0_ia,
        wren_a => d_in0_m0_wi0_wo0_assign_sel_q_13_q(0),
        address_b => u0_m0_wo0_wi0_delayr0_ab,
        q_b => u0_m0_wo0_wi0_delayr0_iq
    );
    u0_m0_wo0_wi0_delayr0_q <= u0_m0_wo0_wi0_delayr0_iq(11 downto 0);

    -- u0_m0_wo0_wi0_join1(BITJOIN,30)@13
    u0_m0_wo0_wi0_join1_q <= u0_m0_wo0_wi0_split1_c & u0_m0_wo0_wi0_split1_b & u0_m0_wo0_wi0_delayr0_q;

    -- u0_m0_wo0_wi0_delayr1(DUALMEM,32)@13
    u0_m0_wo0_wi0_delayr1_ia <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_join1_q);
    u0_m0_wo0_wi0_delayr1_aa <= u0_m0_wo0_wi0_wa12_q;
    u0_m0_wo0_wi0_delayr1_ab <= u0_m0_wo0_wi0_ra12_count0_lutreg_q;
    u0_m0_wo0_wi0_delayr1_reset0 <= areset;
    u0_m0_wo0_wi0_delayr1_dmem : altsyncram
    GENERIC MAP (
        ram_block_type => "M9K",
        operation_mode => "DUAL_PORT",
        width_a => 36,
        widthad_a => 3,
        numwords_a => 5,
        width_b => 36,
        widthad_b => 3,
        numwords_b => 5,
        lpm_type => "altsyncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        wrcontrol_wraddress_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK0",
        outdata_aclr_b => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "OLD_DATA",
        power_up_uninitialized => "FALSE",
        init_file => "UNUSED",
        intended_device_family => "Cyclone IV E"
    )
    PORT MAP (
        clocken0 => '1',
        aclr0 => u0_m0_wo0_wi0_delayr1_reset0,
        clock0 => clk,
        address_a => u0_m0_wo0_wi0_delayr1_aa,
        data_a => u0_m0_wo0_wi0_delayr1_ia,
        wren_a => u0_m0_wo0_we14_q(0),
        address_b => u0_m0_wo0_wi0_delayr1_ab,
        q_b => u0_m0_wo0_wi0_delayr1_iq
    );
    u0_m0_wo0_wi0_delayr1_q <= u0_m0_wo0_wi0_delayr1_iq(35 downto 0);

    -- u0_m0_wo0_wi0_split1(BITSELECT,31)@13
    u0_m0_wo0_wi0_split1_in <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_delayr1_q);
    u0_m0_wo0_wi0_split1_b <= u0_m0_wo0_wi0_split1_in(11 downto 0);
    u0_m0_wo0_wi0_split1_c <= u0_m0_wo0_wi0_split1_in(23 downto 12);
    u0_m0_wo0_wi0_split1_d <= u0_m0_wo0_wi0_split1_in(35 downto 24);

    -- u0_m0_wo0_wi0_join4(BITJOIN,34)@13
    u0_m0_wo0_wi0_join4_q <= u0_m0_wo0_wi0_split4_c & u0_m0_wo0_wi0_split4_b & u0_m0_wo0_wi0_split1_d;

    -- u0_m0_wo0_wi0_delayr4(DUALMEM,36)@13
    u0_m0_wo0_wi0_delayr4_ia <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_join4_q);
    u0_m0_wo0_wi0_delayr4_aa <= u0_m0_wo0_wi0_wa12_q;
    u0_m0_wo0_wi0_delayr4_ab <= u0_m0_wo0_wi0_ra12_count0_lutreg_q;
    u0_m0_wo0_wi0_delayr4_reset0 <= areset;
    u0_m0_wo0_wi0_delayr4_dmem : altsyncram
    GENERIC MAP (
        ram_block_type => "M9K",
        operation_mode => "DUAL_PORT",
        width_a => 36,
        widthad_a => 3,
        numwords_a => 5,
        width_b => 36,
        widthad_b => 3,
        numwords_b => 5,
        lpm_type => "altsyncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        wrcontrol_wraddress_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK0",
        outdata_aclr_b => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "OLD_DATA",
        power_up_uninitialized => "FALSE",
        init_file => "UNUSED",
        intended_device_family => "Cyclone IV E"
    )
    PORT MAP (
        clocken0 => '1',
        aclr0 => u0_m0_wo0_wi0_delayr4_reset0,
        clock0 => clk,
        address_a => u0_m0_wo0_wi0_delayr4_aa,
        data_a => u0_m0_wo0_wi0_delayr4_ia,
        wren_a => u0_m0_wo0_we14_q(0),
        address_b => u0_m0_wo0_wi0_delayr4_ab,
        q_b => u0_m0_wo0_wi0_delayr4_iq
    );
    u0_m0_wo0_wi0_delayr4_q <= u0_m0_wo0_wi0_delayr4_iq(35 downto 0);

    -- u0_m0_wo0_wi0_split4(BITSELECT,35)@13
    u0_m0_wo0_wi0_split4_in <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_delayr4_q);
    u0_m0_wo0_wi0_split4_b <= u0_m0_wo0_wi0_split4_in(11 downto 0);
    u0_m0_wo0_wi0_split4_c <= u0_m0_wo0_wi0_split4_in(23 downto 12);
    u0_m0_wo0_wi0_split4_d <= u0_m0_wo0_wi0_split4_in(35 downto 24);

    -- u0_m0_wo0_wi0_join7(BITJOIN,38)@13
    u0_m0_wo0_wi0_join7_q <= u0_m0_wo0_wi0_split7_c & u0_m0_wo0_wi0_split7_b & u0_m0_wo0_wi0_split4_d;

    -- u0_m0_wo0_wi0_delayr7(DUALMEM,40)@13
    u0_m0_wo0_wi0_delayr7_ia <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_join7_q);
    u0_m0_wo0_wi0_delayr7_aa <= u0_m0_wo0_wi0_wa12_q;
    u0_m0_wo0_wi0_delayr7_ab <= u0_m0_wo0_wi0_ra12_count0_lutreg_q;
    u0_m0_wo0_wi0_delayr7_reset0 <= areset;
    u0_m0_wo0_wi0_delayr7_dmem : altsyncram
    GENERIC MAP (
        ram_block_type => "M9K",
        operation_mode => "DUAL_PORT",
        width_a => 36,
        widthad_a => 3,
        numwords_a => 5,
        width_b => 36,
        widthad_b => 3,
        numwords_b => 5,
        lpm_type => "altsyncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        wrcontrol_wraddress_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK0",
        outdata_aclr_b => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "OLD_DATA",
        power_up_uninitialized => "FALSE",
        init_file => "UNUSED",
        intended_device_family => "Cyclone IV E"
    )
    PORT MAP (
        clocken0 => '1',
        aclr0 => u0_m0_wo0_wi0_delayr7_reset0,
        clock0 => clk,
        address_a => u0_m0_wo0_wi0_delayr7_aa,
        data_a => u0_m0_wo0_wi0_delayr7_ia,
        wren_a => u0_m0_wo0_we14_q(0),
        address_b => u0_m0_wo0_wi0_delayr7_ab,
        q_b => u0_m0_wo0_wi0_delayr7_iq
    );
    u0_m0_wo0_wi0_delayr7_q <= u0_m0_wo0_wi0_delayr7_iq(35 downto 0);

    -- u0_m0_wo0_wi0_split7(BITSELECT,39)@13
    u0_m0_wo0_wi0_split7_in <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_delayr7_q);
    u0_m0_wo0_wi0_split7_b <= u0_m0_wo0_wi0_split7_in(11 downto 0);
    u0_m0_wo0_wi0_split7_c <= u0_m0_wo0_wi0_split7_in(23 downto 12);
    u0_m0_wo0_wi0_split7_d <= u0_m0_wo0_wi0_split7_in(35 downto 24);

    -- u0_m0_wo0_wi0_join10(BITJOIN,42)@13
    u0_m0_wo0_wi0_join10_q <= u0_m0_wo0_wi0_split10_c & u0_m0_wo0_wi0_split10_b & u0_m0_wo0_wi0_split7_d;

    -- u0_m0_wo0_wi0_wa12(COUNTER,25)@13
    -- every=1, low=0, high=4, step=1, init=0
    u0_m0_wo0_wi0_wa12: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_wa12_i <= TO_UNSIGNED(0, 3);
            u0_m0_wo0_wi0_wa12_eq <= '0';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_we14_q = "1") THEN
                IF (u0_m0_wo0_wi0_wa12_i = TO_UNSIGNED(3, 3)) THEN
                    u0_m0_wo0_wi0_wa12_eq <= '1';
                ELSE
                    u0_m0_wo0_wi0_wa12_eq <= '0';
                END IF;
                IF (u0_m0_wo0_wi0_wa12_eq = '1') THEN
                    u0_m0_wo0_wi0_wa12_i <= u0_m0_wo0_wi0_wa12_i - 4;
                ELSE
                    u0_m0_wo0_wi0_wa12_i <= u0_m0_wo0_wi0_wa12_i + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;
    u0_m0_wo0_wi0_wa12_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(u0_m0_wo0_wi0_wa12_i, 3)));

    -- u0_m0_wo0_wi0_delayr10(DUALMEM,44)@13
    u0_m0_wo0_wi0_delayr10_ia <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_join10_q);
    u0_m0_wo0_wi0_delayr10_aa <= u0_m0_wo0_wi0_wa12_q;
    u0_m0_wo0_wi0_delayr10_ab <= u0_m0_wo0_wi0_ra12_count0_lutreg_q;
    u0_m0_wo0_wi0_delayr10_reset0 <= areset;
    u0_m0_wo0_wi0_delayr10_dmem : altsyncram
    GENERIC MAP (
        ram_block_type => "M9K",
        operation_mode => "DUAL_PORT",
        width_a => 36,
        widthad_a => 3,
        numwords_a => 5,
        width_b => 36,
        widthad_b => 3,
        numwords_b => 5,
        lpm_type => "altsyncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        wrcontrol_wraddress_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK0",
        outdata_aclr_b => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "OLD_DATA",
        power_up_uninitialized => "FALSE",
        init_file => "UNUSED",
        intended_device_family => "Cyclone IV E"
    )
    PORT MAP (
        clocken0 => '1',
        aclr0 => u0_m0_wo0_wi0_delayr10_reset0,
        clock0 => clk,
        address_a => u0_m0_wo0_wi0_delayr10_aa,
        data_a => u0_m0_wo0_wi0_delayr10_ia,
        wren_a => u0_m0_wo0_we14_q(0),
        address_b => u0_m0_wo0_wi0_delayr10_ab,
        q_b => u0_m0_wo0_wi0_delayr10_iq
    );
    u0_m0_wo0_wi0_delayr10_q <= u0_m0_wo0_wi0_delayr10_iq(35 downto 0);

    -- u0_m0_wo0_wi0_split10(BITSELECT,43)@13
    u0_m0_wo0_wi0_split10_in <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_delayr10_q);
    u0_m0_wo0_wi0_split10_b <= u0_m0_wo0_wi0_split10_in(11 downto 0);
    u0_m0_wo0_wi0_split10_c <= u0_m0_wo0_wi0_split10_in(23 downto 12);
    u0_m0_wo0_wi0_split10_d <= u0_m0_wo0_wi0_split10_in(35 downto 24);

    -- u0_m0_wo0_we25_1(REG,20)@13
    u0_m0_wo0_we25_1: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_we25_1_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_compute_q = "1") THEN
                u0_m0_wo0_we25_1_q <= u0_m0_wo0_we14_2_q;
            END IF;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_we25_2(REG,21)@13
    u0_m0_wo0_we25_2: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_we25_2_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_compute_q = "1") THEN
                u0_m0_wo0_we25_2_q <= u0_m0_wo0_we25_1_q;
            END IF;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_we25_3(REG,22)@13
    u0_m0_wo0_we25_3: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_we25_3_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_compute_q = "1") THEN
                u0_m0_wo0_we25_3_q <= u0_m0_wo0_we25_2_q;
            END IF;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_we14_1(REG,17)@13
    u0_m0_wo0_we14_1: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_we14_1_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_compute_q = "1") THEN
                u0_m0_wo0_we14_1_q <= u0_m0_wo0_we25_3_q;
            END IF;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_we14_2(REG,18)@13
    u0_m0_wo0_we14_2: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_we14_2_q <= "1";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_compute_q = "1") THEN
                u0_m0_wo0_we14_2_q <= u0_m0_wo0_we14_1_q;
            END IF;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_we14(LOGICAL,19)@13
    u0_m0_wo0_we14_a <= u0_m0_wo0_we14_2_q;
    u0_m0_wo0_we14_b <= u0_m0_wo0_compute_q;
    u0_m0_wo0_we14_q <= u0_m0_wo0_we14_a and u0_m0_wo0_we14_b;

    -- u0_m0_wo0_wi0_wa14(COUNTER,26)@13
    -- every=1, low=0, high=7, step=1, init=5
    u0_m0_wo0_wi0_wa14: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_wa14_i <= TO_UNSIGNED(5, 3);
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_we14_q = "1") THEN
                u0_m0_wo0_wi0_wa14_i <= u0_m0_wo0_wi0_wa14_i + 1;
            END IF;
        END IF;
    END PROCESS;
    u0_m0_wo0_wi0_wa14_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(u0_m0_wo0_wi0_wa14_i, 3)));

    -- u0_m0_wo0_wi0_delayr14(DUALMEM,46)@13
    u0_m0_wo0_wi0_delayr14_ia <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_split10_c);
    u0_m0_wo0_wi0_delayr14_aa <= u0_m0_wo0_wi0_wa14_q;
    u0_m0_wo0_wi0_delayr14_ab <= u0_m0_wo0_wi0_ra25_resize_b;
    u0_m0_wo0_wi0_delayr14_reset0 <= areset;
    u0_m0_wo0_wi0_delayr14_dmem : altsyncram
    GENERIC MAP (
        ram_block_type => "M9K",
        operation_mode => "DUAL_PORT",
        width_a => 12,
        widthad_a => 3,
        numwords_a => 8,
        width_b => 12,
        widthad_b => 3,
        numwords_b => 8,
        lpm_type => "altsyncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        wrcontrol_wraddress_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK0",
        outdata_aclr_b => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "OLD_DATA",
        power_up_uninitialized => "FALSE",
        init_file => "UNUSED",
        intended_device_family => "Cyclone IV E"
    )
    PORT MAP (
        clocken0 => '1',
        aclr0 => u0_m0_wo0_wi0_delayr14_reset0,
        clock0 => clk,
        address_a => u0_m0_wo0_wi0_delayr14_aa,
        data_a => u0_m0_wo0_wi0_delayr14_ia,
        wren_a => u0_m0_wo0_we14_q(0),
        address_b => u0_m0_wo0_wi0_delayr14_ab,
        q_b => u0_m0_wo0_wi0_delayr14_iq
    );
    u0_m0_wo0_wi0_delayr14_q <= u0_m0_wo0_wi0_delayr14_iq(11 downto 0);

    -- u0_m0_wo0_wi0_join15(BITJOIN,48)@13
    u0_m0_wo0_wi0_join15_q <= u0_m0_wo0_wi0_split15_c & u0_m0_wo0_wi0_split15_b & u0_m0_wo0_wi0_delayr14_q;

    -- u0_m0_wo0_wi0_delayr15(DUALMEM,50)@13
    u0_m0_wo0_wi0_delayr15_ia <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_join15_q);
    u0_m0_wo0_wi0_delayr15_aa <= u0_m0_wo0_wi0_wa25_q;
    u0_m0_wo0_wi0_delayr15_ab <= u0_m0_wo0_wi0_ra25_resize_b;
    u0_m0_wo0_wi0_delayr15_reset0 <= areset;
    u0_m0_wo0_wi0_delayr15_dmem : altsyncram
    GENERIC MAP (
        ram_block_type => "M9K",
        operation_mode => "DUAL_PORT",
        width_a => 36,
        widthad_a => 3,
        numwords_a => 8,
        width_b => 36,
        widthad_b => 3,
        numwords_b => 8,
        lpm_type => "altsyncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        wrcontrol_wraddress_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK0",
        outdata_aclr_b => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "OLD_DATA",
        power_up_uninitialized => "FALSE",
        init_file => "UNUSED",
        intended_device_family => "Cyclone IV E"
    )
    PORT MAP (
        clocken0 => '1',
        aclr0 => u0_m0_wo0_wi0_delayr15_reset0,
        clock0 => clk,
        address_a => u0_m0_wo0_wi0_delayr15_aa,
        data_a => u0_m0_wo0_wi0_delayr15_ia,
        wren_a => u0_m0_wo0_we25_q(0),
        address_b => u0_m0_wo0_wi0_delayr15_ab,
        q_b => u0_m0_wo0_wi0_delayr15_iq
    );
    u0_m0_wo0_wi0_delayr15_q <= u0_m0_wo0_wi0_delayr15_iq(35 downto 0);

    -- u0_m0_wo0_wi0_split15(BITSELECT,49)@13
    u0_m0_wo0_wi0_split15_in <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_delayr15_q);
    u0_m0_wo0_wi0_split15_b <= u0_m0_wo0_wi0_split15_in(11 downto 0);
    u0_m0_wo0_wi0_split15_c <= u0_m0_wo0_wi0_split15_in(23 downto 12);
    u0_m0_wo0_wi0_split15_d <= u0_m0_wo0_wi0_split15_in(35 downto 24);

    -- u0_m0_wo0_wi0_join18(BITJOIN,52)@13
    u0_m0_wo0_wi0_join18_q <= u0_m0_wo0_wi0_split18_c & u0_m0_wo0_wi0_split18_b & u0_m0_wo0_wi0_split15_d;

    -- u0_m0_wo0_wi0_delayr18(DUALMEM,54)@13
    u0_m0_wo0_wi0_delayr18_ia <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_join18_q);
    u0_m0_wo0_wi0_delayr18_aa <= u0_m0_wo0_wi0_wa25_q;
    u0_m0_wo0_wi0_delayr18_ab <= u0_m0_wo0_wi0_ra25_resize_b;
    u0_m0_wo0_wi0_delayr18_reset0 <= areset;
    u0_m0_wo0_wi0_delayr18_dmem : altsyncram
    GENERIC MAP (
        ram_block_type => "M9K",
        operation_mode => "DUAL_PORT",
        width_a => 36,
        widthad_a => 3,
        numwords_a => 8,
        width_b => 36,
        widthad_b => 3,
        numwords_b => 8,
        lpm_type => "altsyncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        wrcontrol_wraddress_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK0",
        outdata_aclr_b => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "OLD_DATA",
        power_up_uninitialized => "FALSE",
        init_file => "UNUSED",
        intended_device_family => "Cyclone IV E"
    )
    PORT MAP (
        clocken0 => '1',
        aclr0 => u0_m0_wo0_wi0_delayr18_reset0,
        clock0 => clk,
        address_a => u0_m0_wo0_wi0_delayr18_aa,
        data_a => u0_m0_wo0_wi0_delayr18_ia,
        wren_a => u0_m0_wo0_we25_q(0),
        address_b => u0_m0_wo0_wi0_delayr18_ab,
        q_b => u0_m0_wo0_wi0_delayr18_iq
    );
    u0_m0_wo0_wi0_delayr18_q <= u0_m0_wo0_wi0_delayr18_iq(35 downto 0);

    -- u0_m0_wo0_wi0_split18(BITSELECT,53)@13
    u0_m0_wo0_wi0_split18_in <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_delayr18_q);
    u0_m0_wo0_wi0_split18_b <= u0_m0_wo0_wi0_split18_in(11 downto 0);
    u0_m0_wo0_wi0_split18_c <= u0_m0_wo0_wi0_split18_in(23 downto 12);
    u0_m0_wo0_wi0_split18_d <= u0_m0_wo0_wi0_split18_in(35 downto 24);

    -- u0_m0_wo0_wi0_join21(BITJOIN,56)@13
    u0_m0_wo0_wi0_join21_q <= u0_m0_wo0_wi0_split21_c & u0_m0_wo0_wi0_split21_b & u0_m0_wo0_wi0_split18_d;

    -- u0_m0_wo0_wi0_delayr21(DUALMEM,58)@13
    u0_m0_wo0_wi0_delayr21_ia <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_join21_q);
    u0_m0_wo0_wi0_delayr21_aa <= u0_m0_wo0_wi0_wa25_q;
    u0_m0_wo0_wi0_delayr21_ab <= u0_m0_wo0_wi0_ra25_resize_b;
    u0_m0_wo0_wi0_delayr21_reset0 <= areset;
    u0_m0_wo0_wi0_delayr21_dmem : altsyncram
    GENERIC MAP (
        ram_block_type => "M9K",
        operation_mode => "DUAL_PORT",
        width_a => 36,
        widthad_a => 3,
        numwords_a => 8,
        width_b => 36,
        widthad_b => 3,
        numwords_b => 8,
        lpm_type => "altsyncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        wrcontrol_wraddress_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK0",
        outdata_aclr_b => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "OLD_DATA",
        power_up_uninitialized => "FALSE",
        init_file => "UNUSED",
        intended_device_family => "Cyclone IV E"
    )
    PORT MAP (
        clocken0 => '1',
        aclr0 => u0_m0_wo0_wi0_delayr21_reset0,
        clock0 => clk,
        address_a => u0_m0_wo0_wi0_delayr21_aa,
        data_a => u0_m0_wo0_wi0_delayr21_ia,
        wren_a => u0_m0_wo0_we25_q(0),
        address_b => u0_m0_wo0_wi0_delayr21_ab,
        q_b => u0_m0_wo0_wi0_delayr21_iq
    );
    u0_m0_wo0_wi0_delayr21_q <= u0_m0_wo0_wi0_delayr21_iq(35 downto 0);

    -- u0_m0_wo0_wi0_split21(BITSELECT,57)@13
    u0_m0_wo0_wi0_split21_in <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_delayr21_q);
    u0_m0_wo0_wi0_split21_b <= u0_m0_wo0_wi0_split21_in(11 downto 0);
    u0_m0_wo0_wi0_split21_c <= u0_m0_wo0_wi0_split21_in(23 downto 12);
    u0_m0_wo0_wi0_split21_d <= u0_m0_wo0_wi0_split21_in(35 downto 24);

    -- u0_m0_wo0_wi0_join24(BITJOIN,60)@13
    u0_m0_wo0_wi0_join24_q <= u0_m0_wo0_wi0_split24_b & u0_m0_wo0_wi0_split21_d;

    -- u0_m0_wo0_we25(LOGICAL,23)@13
    u0_m0_wo0_we25_a <= u0_m0_wo0_we25_3_q;
    u0_m0_wo0_we25_b <= u0_m0_wo0_compute_q;
    u0_m0_wo0_we25_q <= u0_m0_wo0_we25_a and u0_m0_wo0_we25_b;

    -- u0_m0_wo0_wi0_wa25(COUNTER,27)@13
    -- every=1, low=0, high=7, step=1, init=5
    u0_m0_wo0_wi0_wa25: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_wa25_i <= TO_UNSIGNED(5, 3);
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_we25_q = "1") THEN
                u0_m0_wo0_wi0_wa25_i <= u0_m0_wo0_wi0_wa25_i + 1;
            END IF;
        END IF;
    END PROCESS;
    u0_m0_wo0_wi0_wa25_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(u0_m0_wo0_wi0_wa25_i, 3)));

    -- u0_m0_wo0_wi0_delayr24(DUALMEM,62)@13
    u0_m0_wo0_wi0_delayr24_ia <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_join24_q);
    u0_m0_wo0_wi0_delayr24_aa <= u0_m0_wo0_wi0_wa25_q;
    u0_m0_wo0_wi0_delayr24_ab <= u0_m0_wo0_wi0_ra25_resize_b;
    u0_m0_wo0_wi0_delayr24_reset0 <= areset;
    u0_m0_wo0_wi0_delayr24_dmem : altsyncram
    GENERIC MAP (
        ram_block_type => "M9K",
        operation_mode => "DUAL_PORT",
        width_a => 24,
        widthad_a => 3,
        numwords_a => 8,
        width_b => 24,
        widthad_b => 3,
        numwords_b => 8,
        lpm_type => "altsyncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        wrcontrol_wraddress_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK0",
        outdata_aclr_b => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "OLD_DATA",
        power_up_uninitialized => "FALSE",
        init_file => "UNUSED",
        intended_device_family => "Cyclone IV E"
    )
    PORT MAP (
        clocken0 => '1',
        aclr0 => u0_m0_wo0_wi0_delayr24_reset0,
        clock0 => clk,
        address_a => u0_m0_wo0_wi0_delayr24_aa,
        data_a => u0_m0_wo0_wi0_delayr24_ia,
        wren_a => u0_m0_wo0_we25_q(0),
        address_b => u0_m0_wo0_wi0_delayr24_ab,
        q_b => u0_m0_wo0_wi0_delayr24_iq
    );
    u0_m0_wo0_wi0_delayr24_q <= u0_m0_wo0_wi0_delayr24_iq(23 downto 0);

    -- u0_m0_wo0_wi0_split24(BITSELECT,61)@13
    u0_m0_wo0_wi0_split24_in <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_delayr24_q);
    u0_m0_wo0_wi0_split24_b <= u0_m0_wo0_wi0_split24_in(11 downto 0);
    u0_m0_wo0_wi0_split24_c <= u0_m0_wo0_wi0_split24_in(23 downto 12);

    -- d_u0_m0_wo0_wi0_split24_c_15(DELAY,131)@13
    d_u0_m0_wo0_wi0_split24_c_15 : dspba_delay
    GENERIC MAP ( width => 12, depth => 2 )
    PORT MAP ( xin => u0_m0_wo0_wi0_split24_c, xout => d_u0_m0_wo0_wi0_split24_c_15_q, clk => clk, aclr => areset );

    -- d_u0_m0_wo0_wi0_delayr0_q_15(DELAY,130)@13
    d_u0_m0_wo0_wi0_delayr0_q_15 : dspba_delay
    GENERIC MAP ( width => 12, depth => 2 )
    PORT MAP ( xin => u0_m0_wo0_wi0_delayr0_q, xout => d_u0_m0_wo0_wi0_delayr0_q_15_q, clk => clk, aclr => areset );

    -- u0_m0_wo0_sym_add0(ADD,79)@15
    u0_m0_wo0_sym_add0_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 12 => d_u0_m0_wo0_wi0_delayr0_q_15_q(11)) & d_u0_m0_wo0_wi0_delayr0_q_15_q));
    u0_m0_wo0_sym_add0_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 12 => d_u0_m0_wo0_wi0_split24_c_15_q(11)) & d_u0_m0_wo0_wi0_split24_c_15_q));
    u0_m0_wo0_sym_add0: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add0_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add0_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add0_a) + SIGNED(u0_m0_wo0_sym_add0_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add0_q <= u0_m0_wo0_sym_add0_o(12 downto 0);

    -- u0_m0_wo0_ca12(COUNTER,65)@13
    -- every=1, low=0, high=4, step=1, init=0
    u0_m0_wo0_ca12: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_ca12_i <= TO_UNSIGNED(0, 3);
            u0_m0_wo0_ca12_eq <= '0';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_compute_q = "1") THEN
                IF (u0_m0_wo0_ca12_i = TO_UNSIGNED(3, 3)) THEN
                    u0_m0_wo0_ca12_eq <= '1';
                ELSE
                    u0_m0_wo0_ca12_eq <= '0';
                END IF;
                IF (u0_m0_wo0_ca12_eq = '1') THEN
                    u0_m0_wo0_ca12_i <= u0_m0_wo0_ca12_i - 4;
                ELSE
                    u0_m0_wo0_ca12_i <= u0_m0_wo0_ca12_i + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;
    u0_m0_wo0_ca12_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(u0_m0_wo0_ca12_i, 3)));

    -- d_u0_m0_wo0_ca12_q_15(DELAY,132)@13
    d_u0_m0_wo0_ca12_q_15 : dspba_delay
    GENERIC MAP ( width => 3, depth => 2 )
    PORT MAP ( xin => u0_m0_wo0_ca12_q, xout => d_u0_m0_wo0_ca12_q_15_q, clk => clk, aclr => areset );

    -- u0_m0_wo0_cm0(LOOKUP,66)@15
    u0_m0_wo0_cm0: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_cm0_q <= "0000000000000111";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (d_u0_m0_wo0_ca12_q_15_q) IS
                WHEN "000" => u0_m0_wo0_cm0_q <= "0000000000000111";
                WHEN "001" => u0_m0_wo0_cm0_q <= "0000000000000101";
                WHEN "010" => u0_m0_wo0_cm0_q <= "0000000000000011";
                WHEN "011" => u0_m0_wo0_cm0_q <= "0000000000000001";
                WHEN "100" => u0_m0_wo0_cm0_q <= "0000000000000000";
                WHEN OTHERS => u0_m0_wo0_cm0_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_mtree_mult1_12(MULT,92)@16
    u0_m0_wo0_mtree_mult1_12_a0 <= STD_LOGIC_VECTOR(u0_m0_wo0_cm0_q);
    u0_m0_wo0_mtree_mult1_12_b0 <= STD_LOGIC_VECTOR(u0_m0_wo0_sym_add0_q);
    u0_m0_wo0_mtree_mult1_12_reset <= areset;
    u0_m0_wo0_mtree_mult1_12_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 16,
        lpm_widthb => 13,
        lpm_widthp => 29,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "SIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => u0_m0_wo0_mtree_mult1_12_a0,
        datab => u0_m0_wo0_mtree_mult1_12_b0,
        clken => VCC_q(0),
        aclr => u0_m0_wo0_mtree_mult1_12_reset,
        clock => clk,
        result => u0_m0_wo0_mtree_mult1_12_s1
    );
    u0_m0_wo0_mtree_mult1_12_q <= u0_m0_wo0_mtree_mult1_12_s1;

    -- u0_m0_wo0_sym_add1(ADD,80)@13
    u0_m0_wo0_sym_add1_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 12 => u0_m0_wo0_wi0_split1_b(11)) & u0_m0_wo0_wi0_split1_b));
    u0_m0_wo0_sym_add1_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 12 => u0_m0_wo0_wi0_split24_b(11)) & u0_m0_wo0_wi0_split24_b));
    u0_m0_wo0_sym_add1: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add1_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add1_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add1_a) + SIGNED(u0_m0_wo0_sym_add1_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add1_q <= u0_m0_wo0_sym_add1_o(12 downto 0);

    -- u0_m0_wo0_cm1(LOOKUP,67)@13
    u0_m0_wo0_cm1: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_cm1_q <= "1111111111100110";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (u0_m0_wo0_ca12_q) IS
                WHEN "000" => u0_m0_wo0_cm1_q <= "1111111111100110";
                WHEN "001" => u0_m0_wo0_cm1_q <= "1111111111110010";
                WHEN "010" => u0_m0_wo0_cm1_q <= "1111111111111101";
                WHEN "011" => u0_m0_wo0_cm1_q <= "0000000000000011";
                WHEN "100" => u0_m0_wo0_cm1_q <= "0000000000000111";
                WHEN OTHERS => -- unreachable
                               u0_m0_wo0_cm1_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_mtree_mult1_11(MULT,93)@14
    u0_m0_wo0_mtree_mult1_11_a0 <= STD_LOGIC_VECTOR(u0_m0_wo0_cm1_q);
    u0_m0_wo0_mtree_mult1_11_b0 <= STD_LOGIC_VECTOR(u0_m0_wo0_sym_add1_q);
    u0_m0_wo0_mtree_mult1_11_reset <= areset;
    u0_m0_wo0_mtree_mult1_11_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 16,
        lpm_widthb => 13,
        lpm_widthp => 29,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "SIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => u0_m0_wo0_mtree_mult1_11_a0,
        datab => u0_m0_wo0_mtree_mult1_11_b0,
        clken => VCC_q(0),
        aclr => u0_m0_wo0_mtree_mult1_11_reset,
        clock => clk,
        result => u0_m0_wo0_mtree_mult1_11_s1
    );
    u0_m0_wo0_mtree_mult1_11_q <= u0_m0_wo0_mtree_mult1_11_s1;

    -- u0_m0_wo0_sym_add2(ADD,81)@13
    u0_m0_wo0_sym_add2_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 12 => u0_m0_wo0_wi0_split1_c(11)) & u0_m0_wo0_wi0_split1_c));
    u0_m0_wo0_sym_add2_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 12 => u0_m0_wo0_wi0_split21_d(11)) & u0_m0_wo0_wi0_split21_d));
    u0_m0_wo0_sym_add2: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add2_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add2_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add2_a) + SIGNED(u0_m0_wo0_sym_add2_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add2_q <= u0_m0_wo0_sym_add2_o(12 downto 0);

    -- u0_m0_wo0_cm2(LOOKUP,68)@13
    u0_m0_wo0_cm2: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_cm2_q <= "0000000000011010";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (u0_m0_wo0_ca12_q) IS
                WHEN "000" => u0_m0_wo0_cm2_q <= "0000000000011010";
                WHEN "001" => u0_m0_wo0_cm2_q <= "1111111111111000";
                WHEN "010" => u0_m0_wo0_cm2_q <= "1111111111100010";
                WHEN "011" => u0_m0_wo0_cm2_q <= "1111111111011001";
                WHEN "100" => u0_m0_wo0_cm2_q <= "1111111111011100";
                WHEN OTHERS => -- unreachable
                               u0_m0_wo0_cm2_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_mtree_mult1_10(MULT,94)@14
    u0_m0_wo0_mtree_mult1_10_a0 <= STD_LOGIC_VECTOR(u0_m0_wo0_cm2_q);
    u0_m0_wo0_mtree_mult1_10_b0 <= STD_LOGIC_VECTOR(u0_m0_wo0_sym_add2_q);
    u0_m0_wo0_mtree_mult1_10_reset <= areset;
    u0_m0_wo0_mtree_mult1_10_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 16,
        lpm_widthb => 13,
        lpm_widthp => 29,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "SIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => u0_m0_wo0_mtree_mult1_10_a0,
        datab => u0_m0_wo0_mtree_mult1_10_b0,
        clken => VCC_q(0),
        aclr => u0_m0_wo0_mtree_mult1_10_reset,
        clock => clk,
        result => u0_m0_wo0_mtree_mult1_10_s1
    );
    u0_m0_wo0_mtree_mult1_10_q <= u0_m0_wo0_mtree_mult1_10_s1;

    -- u0_m0_wo0_mtree_add0_5(ADD,110)@16
    u0_m0_wo0_mtree_add0_5_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((29 downto 29 => u0_m0_wo0_mtree_mult1_10_q(28)) & u0_m0_wo0_mtree_mult1_10_q));
    u0_m0_wo0_mtree_add0_5_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((29 downto 29 => u0_m0_wo0_mtree_mult1_11_q(28)) & u0_m0_wo0_mtree_mult1_11_q));
    u0_m0_wo0_mtree_add0_5: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_add0_5_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_add0_5_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_add0_5_a) + SIGNED(u0_m0_wo0_mtree_add0_5_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_add0_5_q <= u0_m0_wo0_mtree_add0_5_o(29 downto 0);

    -- u0_m0_wo0_sym_add3(ADD,82)@13
    u0_m0_wo0_sym_add3_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 12 => u0_m0_wo0_wi0_split1_d(11)) & u0_m0_wo0_wi0_split1_d));
    u0_m0_wo0_sym_add3_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 12 => u0_m0_wo0_wi0_split21_c(11)) & u0_m0_wo0_wi0_split21_c));
    u0_m0_wo0_sym_add3: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add3_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add3_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add3_a) + SIGNED(u0_m0_wo0_sym_add3_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add3_q <= u0_m0_wo0_sym_add3_o(12 downto 0);

    -- u0_m0_wo0_cm3(LOOKUP,69)@13
    u0_m0_wo0_cm3: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_cm3_q <= "0000000001001101";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (u0_m0_wo0_ca12_q) IS
                WHEN "000" => u0_m0_wo0_cm3_q <= "0000000001001101";
                WHEN "001" => u0_m0_wo0_cm3_q <= "0000000001111010";
                WHEN "010" => u0_m0_wo0_cm3_q <= "0000000010000001";
                WHEN "011" => u0_m0_wo0_cm3_q <= "0000000001101011";
                WHEN "100" => u0_m0_wo0_cm3_q <= "0000000001000100";
                WHEN OTHERS => -- unreachable
                               u0_m0_wo0_cm3_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_mtree_mult1_9(MULT,95)@14
    u0_m0_wo0_mtree_mult1_9_a0 <= STD_LOGIC_VECTOR(u0_m0_wo0_cm3_q);
    u0_m0_wo0_mtree_mult1_9_b0 <= STD_LOGIC_VECTOR(u0_m0_wo0_sym_add3_q);
    u0_m0_wo0_mtree_mult1_9_reset <= areset;
    u0_m0_wo0_mtree_mult1_9_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 16,
        lpm_widthb => 13,
        lpm_widthp => 29,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "SIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => u0_m0_wo0_mtree_mult1_9_a0,
        datab => u0_m0_wo0_mtree_mult1_9_b0,
        clken => VCC_q(0),
        aclr => u0_m0_wo0_mtree_mult1_9_reset,
        clock => clk,
        result => u0_m0_wo0_mtree_mult1_9_s1
    );
    u0_m0_wo0_mtree_mult1_9_q <= u0_m0_wo0_mtree_mult1_9_s1;

    -- u0_m0_wo0_sym_add4(ADD,83)@13
    u0_m0_wo0_sym_add4_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 12 => u0_m0_wo0_wi0_split4_b(11)) & u0_m0_wo0_wi0_split4_b));
    u0_m0_wo0_sym_add4_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 12 => u0_m0_wo0_wi0_split21_b(11)) & u0_m0_wo0_wi0_split21_b));
    u0_m0_wo0_sym_add4: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add4_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add4_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add4_a) + SIGNED(u0_m0_wo0_sym_add4_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add4_q <= u0_m0_wo0_sym_add4_o(12 downto 0);

    -- u0_m0_wo0_cm4(LOOKUP,70)@13
    u0_m0_wo0_cm4: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_cm4_q <= "1111111010101010";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (u0_m0_wo0_ca12_q) IS
                WHEN "000" => u0_m0_wo0_cm4_q <= "1111111010101010";
                WHEN "001" => u0_m0_wo0_cm4_q <= "1111111011000110";
                WHEN "010" => u0_m0_wo0_cm4_q <= "1111111100011101";
                WHEN "011" => u0_m0_wo0_cm4_q <= "1111111110001110";
                WHEN "100" => u0_m0_wo0_cm4_q <= "1111111111111100";
                WHEN OTHERS => -- unreachable
                               u0_m0_wo0_cm4_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_mtree_mult1_8(MULT,96)@14
    u0_m0_wo0_mtree_mult1_8_a0 <= STD_LOGIC_VECTOR(u0_m0_wo0_cm4_q);
    u0_m0_wo0_mtree_mult1_8_b0 <= STD_LOGIC_VECTOR(u0_m0_wo0_sym_add4_q);
    u0_m0_wo0_mtree_mult1_8_reset <= areset;
    u0_m0_wo0_mtree_mult1_8_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 16,
        lpm_widthb => 13,
        lpm_widthp => 29,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "SIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => u0_m0_wo0_mtree_mult1_8_a0,
        datab => u0_m0_wo0_mtree_mult1_8_b0,
        clken => VCC_q(0),
        aclr => u0_m0_wo0_mtree_mult1_8_reset,
        clock => clk,
        result => u0_m0_wo0_mtree_mult1_8_s1
    );
    u0_m0_wo0_mtree_mult1_8_q <= u0_m0_wo0_mtree_mult1_8_s1;

    -- u0_m0_wo0_mtree_add0_4(ADD,109)@16
    u0_m0_wo0_mtree_add0_4_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((29 downto 29 => u0_m0_wo0_mtree_mult1_8_q(28)) & u0_m0_wo0_mtree_mult1_8_q));
    u0_m0_wo0_mtree_add0_4_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((29 downto 29 => u0_m0_wo0_mtree_mult1_9_q(28)) & u0_m0_wo0_mtree_mult1_9_q));
    u0_m0_wo0_mtree_add0_4: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_add0_4_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_add0_4_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_add0_4_a) + SIGNED(u0_m0_wo0_mtree_add0_4_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_add0_4_q <= u0_m0_wo0_mtree_add0_4_o(29 downto 0);

    -- u0_m0_wo0_mtree_add1_2(ADD,113)@17
    u0_m0_wo0_mtree_add1_2_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((30 downto 30 => u0_m0_wo0_mtree_add0_4_q(29)) & u0_m0_wo0_mtree_add0_4_q));
    u0_m0_wo0_mtree_add1_2_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((30 downto 30 => u0_m0_wo0_mtree_add0_5_q(29)) & u0_m0_wo0_mtree_add0_5_q));
    u0_m0_wo0_mtree_add1_2: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_add1_2_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_add1_2_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_add1_2_a) + SIGNED(u0_m0_wo0_mtree_add1_2_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_add1_2_q <= u0_m0_wo0_mtree_add1_2_o(30 downto 0);

    -- u0_m0_wo0_mtree_add2_1(ADD,115)@18
    u0_m0_wo0_mtree_add2_1_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((31 downto 31 => u0_m0_wo0_mtree_add1_2_q(30)) & u0_m0_wo0_mtree_add1_2_q));
    u0_m0_wo0_mtree_add2_1_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((31 downto 29 => u0_m0_wo0_mtree_mult1_12_q(28)) & u0_m0_wo0_mtree_mult1_12_q));
    u0_m0_wo0_mtree_add2_1: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_add2_1_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_add2_1_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_add2_1_a) + SIGNED(u0_m0_wo0_mtree_add2_1_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_add2_1_q <= u0_m0_wo0_mtree_add2_1_o(31 downto 0);

    -- u0_m0_wo0_sym_add5(ADD,84)@13
    u0_m0_wo0_sym_add5_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 12 => u0_m0_wo0_wi0_split4_c(11)) & u0_m0_wo0_wi0_split4_c));
    u0_m0_wo0_sym_add5_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 12 => u0_m0_wo0_wi0_split18_d(11)) & u0_m0_wo0_wi0_split18_d));
    u0_m0_wo0_sym_add5: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add5_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add5_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add5_a) + SIGNED(u0_m0_wo0_sym_add5_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add5_q <= u0_m0_wo0_sym_add5_o(12 downto 0);

    -- u0_m0_wo0_cm5(LOOKUP,71)@13
    u0_m0_wo0_cm5: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_cm5_q <= "0000001001011001";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (u0_m0_wo0_ca12_q) IS
                WHEN "000" => u0_m0_wo0_cm5_q <= "0000001001011001";
                WHEN "001" => u0_m0_wo0_cm5_q <= "0000000101100101";
                WHEN "010" => u0_m0_wo0_cm5_q <= "0000000001011011";
                WHEN "011" => u0_m0_wo0_cm5_q <= "1111111101111000";
                WHEN "100" => u0_m0_wo0_cm5_q <= "1111111011100010";
                WHEN OTHERS => -- unreachable
                               u0_m0_wo0_cm5_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_mtree_mult1_7(MULT,97)@14
    u0_m0_wo0_mtree_mult1_7_a0 <= STD_LOGIC_VECTOR(u0_m0_wo0_cm5_q);
    u0_m0_wo0_mtree_mult1_7_b0 <= STD_LOGIC_VECTOR(u0_m0_wo0_sym_add5_q);
    u0_m0_wo0_mtree_mult1_7_reset <= areset;
    u0_m0_wo0_mtree_mult1_7_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 16,
        lpm_widthb => 13,
        lpm_widthp => 29,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "SIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => u0_m0_wo0_mtree_mult1_7_a0,
        datab => u0_m0_wo0_mtree_mult1_7_b0,
        clken => VCC_q(0),
        aclr => u0_m0_wo0_mtree_mult1_7_reset,
        clock => clk,
        result => u0_m0_wo0_mtree_mult1_7_s1
    );
    u0_m0_wo0_mtree_mult1_7_q <= u0_m0_wo0_mtree_mult1_7_s1;

    -- u0_m0_wo0_sym_add6(ADD,85)@13
    u0_m0_wo0_sym_add6_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 12 => u0_m0_wo0_wi0_split4_d(11)) & u0_m0_wo0_wi0_split4_d));
    u0_m0_wo0_sym_add6_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 12 => u0_m0_wo0_wi0_split18_c(11)) & u0_m0_wo0_wi0_split18_c));
    u0_m0_wo0_sym_add6: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add6_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add6_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add6_a) + SIGNED(u0_m0_wo0_sym_add6_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add6_q <= u0_m0_wo0_sym_add6_o(12 downto 0);

    -- u0_m0_wo0_cm6(LOOKUP,72)@13
    u0_m0_wo0_cm6: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_cm6_q <= "1111111010001101";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (u0_m0_wo0_ca12_q) IS
                WHEN "000" => u0_m0_wo0_cm6_q <= "1111111010001101";
                WHEN "001" => u0_m0_wo0_cm6_q <= "0000000010010111";
                WHEN "010" => u0_m0_wo0_cm6_q <= "0000001000011101";
                WHEN "011" => u0_m0_wo0_cm6_q <= "0000001011100111";
                WHEN "100" => u0_m0_wo0_cm6_q <= "0000001011101110";
                WHEN OTHERS => -- unreachable
                               u0_m0_wo0_cm6_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_mtree_mult1_6(MULT,98)@14
    u0_m0_wo0_mtree_mult1_6_a0 <= STD_LOGIC_VECTOR(u0_m0_wo0_cm6_q);
    u0_m0_wo0_mtree_mult1_6_b0 <= STD_LOGIC_VECTOR(u0_m0_wo0_sym_add6_q);
    u0_m0_wo0_mtree_mult1_6_reset <= areset;
    u0_m0_wo0_mtree_mult1_6_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 16,
        lpm_widthb => 13,
        lpm_widthp => 29,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "SIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => u0_m0_wo0_mtree_mult1_6_a0,
        datab => u0_m0_wo0_mtree_mult1_6_b0,
        clken => VCC_q(0),
        aclr => u0_m0_wo0_mtree_mult1_6_reset,
        clock => clk,
        result => u0_m0_wo0_mtree_mult1_6_s1
    );
    u0_m0_wo0_mtree_mult1_6_q <= u0_m0_wo0_mtree_mult1_6_s1;

    -- u0_m0_wo0_mtree_add0_3(ADD,108)@16
    u0_m0_wo0_mtree_add0_3_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((29 downto 29 => u0_m0_wo0_mtree_mult1_6_q(28)) & u0_m0_wo0_mtree_mult1_6_q));
    u0_m0_wo0_mtree_add0_3_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((29 downto 29 => u0_m0_wo0_mtree_mult1_7_q(28)) & u0_m0_wo0_mtree_mult1_7_q));
    u0_m0_wo0_mtree_add0_3: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_add0_3_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_add0_3_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_add0_3_a) + SIGNED(u0_m0_wo0_mtree_add0_3_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_add0_3_q <= u0_m0_wo0_mtree_add0_3_o(29 downto 0);

    -- u0_m0_wo0_sym_add7(ADD,86)@13
    u0_m0_wo0_sym_add7_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 12 => u0_m0_wo0_wi0_split7_b(11)) & u0_m0_wo0_wi0_split7_b));
    u0_m0_wo0_sym_add7_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 12 => u0_m0_wo0_wi0_split18_b(11)) & u0_m0_wo0_wi0_split18_b));
    u0_m0_wo0_sym_add7: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add7_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add7_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add7_a) + SIGNED(u0_m0_wo0_sym_add7_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add7_q <= u0_m0_wo0_sym_add7_o(12 downto 0);

    -- u0_m0_wo0_cm7(LOOKUP,73)@13
    u0_m0_wo0_cm7: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_cm7_q <= "1111110010011111";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (u0_m0_wo0_ca12_q) IS
                WHEN "000" => u0_m0_wo0_cm7_q <= "1111110010011111";
                WHEN "001" => u0_m0_wo0_cm7_q <= "1111101001111110";
                WHEN "010" => u0_m0_wo0_cm7_q <= "1111100111100100";
                WHEN "011" => u0_m0_wo0_cm7_q <= "1111101010101010";
                WHEN "100" => u0_m0_wo0_cm7_q <= "1111110001100110";
                WHEN OTHERS => -- unreachable
                               u0_m0_wo0_cm7_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_mtree_mult1_5(MULT,99)@14
    u0_m0_wo0_mtree_mult1_5_a0 <= STD_LOGIC_VECTOR(u0_m0_wo0_cm7_q);
    u0_m0_wo0_mtree_mult1_5_b0 <= STD_LOGIC_VECTOR(u0_m0_wo0_sym_add7_q);
    u0_m0_wo0_mtree_mult1_5_reset <= areset;
    u0_m0_wo0_mtree_mult1_5_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 16,
        lpm_widthb => 13,
        lpm_widthp => 29,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "SIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => u0_m0_wo0_mtree_mult1_5_a0,
        datab => u0_m0_wo0_mtree_mult1_5_b0,
        clken => VCC_q(0),
        aclr => u0_m0_wo0_mtree_mult1_5_reset,
        clock => clk,
        result => u0_m0_wo0_mtree_mult1_5_s1
    );
    u0_m0_wo0_mtree_mult1_5_q <= u0_m0_wo0_mtree_mult1_5_s1;

    -- u0_m0_wo0_sym_add8(ADD,87)@13
    u0_m0_wo0_sym_add8_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 12 => u0_m0_wo0_wi0_split7_c(11)) & u0_m0_wo0_wi0_split7_c));
    u0_m0_wo0_sym_add8_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 12 => u0_m0_wo0_wi0_split15_d(11)) & u0_m0_wo0_wi0_split15_d));
    u0_m0_wo0_sym_add8: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add8_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add8_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add8_a) + SIGNED(u0_m0_wo0_sym_add8_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add8_q <= u0_m0_wo0_sym_add8_o(12 downto 0);

    -- u0_m0_wo0_cm8(LOOKUP,74)@13
    u0_m0_wo0_cm8: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_cm8_q <= "0000101111011100";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (u0_m0_wo0_ca12_q) IS
                WHEN "000" => u0_m0_wo0_cm8_q <= "0000101111011100";
                WHEN "001" => u0_m0_wo0_cm8_q <= "0000101100101011";
                WHEN "010" => u0_m0_wo0_cm8_q <= "0000100001010000";
                WHEN "011" => u0_m0_wo0_cm8_q <= "0000010001000011";
                WHEN "100" => u0_m0_wo0_cm8_q <= "0000000000010001";
                WHEN OTHERS => -- unreachable
                               u0_m0_wo0_cm8_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_mtree_mult1_4(MULT,100)@14
    u0_m0_wo0_mtree_mult1_4_a0 <= STD_LOGIC_VECTOR(u0_m0_wo0_cm8_q);
    u0_m0_wo0_mtree_mult1_4_b0 <= STD_LOGIC_VECTOR(u0_m0_wo0_sym_add8_q);
    u0_m0_wo0_mtree_mult1_4_reset <= areset;
    u0_m0_wo0_mtree_mult1_4_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 16,
        lpm_widthb => 13,
        lpm_widthp => 29,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "SIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => u0_m0_wo0_mtree_mult1_4_a0,
        datab => u0_m0_wo0_mtree_mult1_4_b0,
        clken => VCC_q(0),
        aclr => u0_m0_wo0_mtree_mult1_4_reset,
        clock => clk,
        result => u0_m0_wo0_mtree_mult1_4_s1
    );
    u0_m0_wo0_mtree_mult1_4_q <= u0_m0_wo0_mtree_mult1_4_s1;

    -- u0_m0_wo0_mtree_add0_2(ADD,107)@16
    u0_m0_wo0_mtree_add0_2_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((29 downto 29 => u0_m0_wo0_mtree_mult1_4_q(28)) & u0_m0_wo0_mtree_mult1_4_q));
    u0_m0_wo0_mtree_add0_2_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((29 downto 29 => u0_m0_wo0_mtree_mult1_5_q(28)) & u0_m0_wo0_mtree_mult1_5_q));
    u0_m0_wo0_mtree_add0_2: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_add0_2_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_add0_2_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_add0_2_a) + SIGNED(u0_m0_wo0_mtree_add0_2_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_add0_2_q <= u0_m0_wo0_mtree_add0_2_o(29 downto 0);

    -- u0_m0_wo0_mtree_add1_1(ADD,112)@17
    u0_m0_wo0_mtree_add1_1_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((30 downto 30 => u0_m0_wo0_mtree_add0_2_q(29)) & u0_m0_wo0_mtree_add0_2_q));
    u0_m0_wo0_mtree_add1_1_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((30 downto 30 => u0_m0_wo0_mtree_add0_3_q(29)) & u0_m0_wo0_mtree_add0_3_q));
    u0_m0_wo0_mtree_add1_1: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_add1_1_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_add1_1_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_add1_1_a) + SIGNED(u0_m0_wo0_mtree_add1_1_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_add1_1_q <= u0_m0_wo0_mtree_add1_1_o(30 downto 0);

    -- u0_m0_wo0_sym_add9(ADD,88)@13
    u0_m0_wo0_sym_add9_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 12 => u0_m0_wo0_wi0_split7_d(11)) & u0_m0_wo0_wi0_split7_d));
    u0_m0_wo0_sym_add9_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 12 => u0_m0_wo0_wi0_split15_c(11)) & u0_m0_wo0_wi0_split15_c));
    u0_m0_wo0_sym_add9: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add9_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add9_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add9_a) + SIGNED(u0_m0_wo0_sym_add9_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add9_q <= u0_m0_wo0_sym_add9_o(12 downto 0);

    -- u0_m0_wo0_cm9(LOOKUP,75)@13
    u0_m0_wo0_cm9: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_cm9_q <= "1110110011100101";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (u0_m0_wo0_ca12_q) IS
                WHEN "000" => u0_m0_wo0_cm9_q <= "1110110011100101";
                WHEN "001" => u0_m0_wo0_cm9_q <= "1111010010110111";
                WHEN "010" => u0_m0_wo0_cm9_q <= "1111110100111110";
                WHEN "011" => u0_m0_wo0_cm9_q <= "0000010010101010";
                WHEN "100" => u0_m0_wo0_cm9_q <= "0000100110111011";
                WHEN OTHERS => -- unreachable
                               u0_m0_wo0_cm9_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_mtree_mult1_3(MULT,101)@14
    u0_m0_wo0_mtree_mult1_3_a0 <= STD_LOGIC_VECTOR(u0_m0_wo0_cm9_q);
    u0_m0_wo0_mtree_mult1_3_b0 <= STD_LOGIC_VECTOR(u0_m0_wo0_sym_add9_q);
    u0_m0_wo0_mtree_mult1_3_reset <= areset;
    u0_m0_wo0_mtree_mult1_3_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 16,
        lpm_widthb => 13,
        lpm_widthp => 29,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "SIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => u0_m0_wo0_mtree_mult1_3_a0,
        datab => u0_m0_wo0_mtree_mult1_3_b0,
        clken => VCC_q(0),
        aclr => u0_m0_wo0_mtree_mult1_3_reset,
        clock => clk,
        result => u0_m0_wo0_mtree_mult1_3_s1
    );
    u0_m0_wo0_mtree_mult1_3_q <= u0_m0_wo0_mtree_mult1_3_s1;

    -- u0_m0_wo0_sym_add10(ADD,89)@13
    u0_m0_wo0_sym_add10_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 12 => u0_m0_wo0_wi0_split10_b(11)) & u0_m0_wo0_wi0_split10_b));
    u0_m0_wo0_sym_add10_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 12 => u0_m0_wo0_wi0_split15_b(11)) & u0_m0_wo0_wi0_split15_b));
    u0_m0_wo0_sym_add10: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add10_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add10_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add10_a) + SIGNED(u0_m0_wo0_sym_add10_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add10_q <= u0_m0_wo0_sym_add10_o(12 downto 0);

    -- u0_m0_wo0_cm10(LOOKUP,76)@13
    u0_m0_wo0_cm10: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_cm10_q <= "0000110110000010";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (u0_m0_wo0_ca12_q) IS
                WHEN "000" => u0_m0_wo0_cm10_q <= "0000110110000010";
                WHEN "001" => u0_m0_wo0_cm10_q <= "1111101001011110";
                WHEN "010" => u0_m0_wo0_cm10_q <= "1110110110010001";
                WHEN "011" => u0_m0_wo0_cm10_q <= "1110011110011001";
                WHEN "100" => u0_m0_wo0_cm10_q <= "1110011111011101";
                WHEN OTHERS => -- unreachable
                               u0_m0_wo0_cm10_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_mtree_mult1_2(MULT,102)@14
    u0_m0_wo0_mtree_mult1_2_a0 <= STD_LOGIC_VECTOR(u0_m0_wo0_cm10_q);
    u0_m0_wo0_mtree_mult1_2_b0 <= STD_LOGIC_VECTOR(u0_m0_wo0_sym_add10_q);
    u0_m0_wo0_mtree_mult1_2_reset <= areset;
    u0_m0_wo0_mtree_mult1_2_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 16,
        lpm_widthb => 13,
        lpm_widthp => 29,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "SIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => u0_m0_wo0_mtree_mult1_2_a0,
        datab => u0_m0_wo0_mtree_mult1_2_b0,
        clken => VCC_q(0),
        aclr => u0_m0_wo0_mtree_mult1_2_reset,
        clock => clk,
        result => u0_m0_wo0_mtree_mult1_2_s1
    );
    u0_m0_wo0_mtree_mult1_2_q <= u0_m0_wo0_mtree_mult1_2_s1;

    -- u0_m0_wo0_mtree_add0_1(ADD,106)@16
    u0_m0_wo0_mtree_add0_1_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((29 downto 29 => u0_m0_wo0_mtree_mult1_2_q(28)) & u0_m0_wo0_mtree_mult1_2_q));
    u0_m0_wo0_mtree_add0_1_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((29 downto 29 => u0_m0_wo0_mtree_mult1_3_q(28)) & u0_m0_wo0_mtree_mult1_3_q));
    u0_m0_wo0_mtree_add0_1: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_add0_1_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_add0_1_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_add0_1_a) + SIGNED(u0_m0_wo0_mtree_add0_1_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_add0_1_q <= u0_m0_wo0_mtree_add0_1_o(29 downto 0);

    -- u0_m0_wo0_sym_add11(ADD,90)@13
    u0_m0_wo0_sym_add11_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 12 => u0_m0_wo0_wi0_split10_c(11)) & u0_m0_wo0_wi0_split10_c));
    u0_m0_wo0_sym_add11_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 12 => u0_m0_wo0_wi0_delayr14_q(11)) & u0_m0_wo0_wi0_delayr14_q));
    u0_m0_wo0_sym_add11: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add11_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add11_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add11_a) + SIGNED(u0_m0_wo0_sym_add11_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add11_q <= u0_m0_wo0_sym_add11_o(12 downto 0);

    -- u0_m0_wo0_cm11(LOOKUP,77)@13
    u0_m0_wo0_cm11: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_cm11_q <= "0111101100101100";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (u0_m0_wo0_ca12_q) IS
                WHEN "000" => u0_m0_wo0_cm11_q <= "0111101100101100";
                WHEN "001" => u0_m0_wo0_cm11_q <= "0110110101100001";
                WHEN "010" => u0_m0_wo0_cm11_q <= "0101100010001000";
                WHEN "011" => u0_m0_wo0_cm11_q <= "0011111101110011";
                WHEN "100" => u0_m0_wo0_cm11_q <= "0010010101100100";
                WHEN OTHERS => -- unreachable
                               u0_m0_wo0_cm11_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_mtree_mult1_1(MULT,103)@14
    u0_m0_wo0_mtree_mult1_1_a0 <= STD_LOGIC_VECTOR(u0_m0_wo0_cm11_q);
    u0_m0_wo0_mtree_mult1_1_b0 <= STD_LOGIC_VECTOR(u0_m0_wo0_sym_add11_q);
    u0_m0_wo0_mtree_mult1_1_reset <= areset;
    u0_m0_wo0_mtree_mult1_1_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 16,
        lpm_widthb => 13,
        lpm_widthp => 29,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "SIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => u0_m0_wo0_mtree_mult1_1_a0,
        datab => u0_m0_wo0_mtree_mult1_1_b0,
        clken => VCC_q(0),
        aclr => u0_m0_wo0_mtree_mult1_1_reset,
        clock => clk,
        result => u0_m0_wo0_mtree_mult1_1_s1
    );
    u0_m0_wo0_mtree_mult1_1_q <= u0_m0_wo0_mtree_mult1_1_s1;

    -- u0_m0_wo0_sym_add12(ADD,91)@13
    u0_m0_wo0_sym_add12_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 12 => u0_m0_wo0_wi0_split10_d(11)) & u0_m0_wo0_wi0_split10_d));
    u0_m0_wo0_sym_add12_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 12 => u0_m0_wo0_wi0_split10_d(11)) & u0_m0_wo0_wi0_split10_d));
    u0_m0_wo0_sym_add12_i <= u0_m0_wo0_sym_add12_a;
    u0_m0_wo0_sym_add12: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add12_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_compute_q = "1") THEN
                u0_m0_wo0_sym_add12_o <= u0_m0_wo0_sym_add12_i;
            ELSE
                u0_m0_wo0_sym_add12_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add12_a) + SIGNED(u0_m0_wo0_sym_add12_b));
            END IF;
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add12_q <= u0_m0_wo0_sym_add12_o(12 downto 0);

    -- u0_m0_wo0_cm12(LOOKUP,78)@13
    u0_m0_wo0_cm12: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_cm12_q <= "0000000000000000";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (u0_m0_wo0_ca12_q) IS
                WHEN "000" => u0_m0_wo0_cm12_q <= "0000000000000000";
                WHEN "001" => u0_m0_wo0_cm12_q <= "0000000000000000";
                WHEN "010" => u0_m0_wo0_cm12_q <= "0000000000000000";
                WHEN "011" => u0_m0_wo0_cm12_q <= "0000000000000000";
                WHEN "100" => u0_m0_wo0_cm12_q <= "0111111111111111";
                WHEN OTHERS => -- unreachable
                               u0_m0_wo0_cm12_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_mtree_mult1_0(MULT,104)@14
    u0_m0_wo0_mtree_mult1_0_a0 <= STD_LOGIC_VECTOR(u0_m0_wo0_cm12_q);
    u0_m0_wo0_mtree_mult1_0_b0 <= STD_LOGIC_VECTOR(u0_m0_wo0_sym_add12_q);
    u0_m0_wo0_mtree_mult1_0_reset <= areset;
    u0_m0_wo0_mtree_mult1_0_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 16,
        lpm_widthb => 13,
        lpm_widthp => 29,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "SIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => u0_m0_wo0_mtree_mult1_0_a0,
        datab => u0_m0_wo0_mtree_mult1_0_b0,
        clken => VCC_q(0),
        aclr => u0_m0_wo0_mtree_mult1_0_reset,
        clock => clk,
        result => u0_m0_wo0_mtree_mult1_0_s1
    );
    u0_m0_wo0_mtree_mult1_0_q <= u0_m0_wo0_mtree_mult1_0_s1;

    -- u0_m0_wo0_mtree_add0_0(ADD,105)@16
    u0_m0_wo0_mtree_add0_0_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((29 downto 29 => u0_m0_wo0_mtree_mult1_0_q(28)) & u0_m0_wo0_mtree_mult1_0_q));
    u0_m0_wo0_mtree_add0_0_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((29 downto 29 => u0_m0_wo0_mtree_mult1_1_q(28)) & u0_m0_wo0_mtree_mult1_1_q));
    u0_m0_wo0_mtree_add0_0: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_add0_0_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_add0_0_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_add0_0_a) + SIGNED(u0_m0_wo0_mtree_add0_0_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_add0_0_q <= u0_m0_wo0_mtree_add0_0_o(29 downto 0);

    -- u0_m0_wo0_mtree_add1_0(ADD,111)@17
    u0_m0_wo0_mtree_add1_0_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((30 downto 30 => u0_m0_wo0_mtree_add0_0_q(29)) & u0_m0_wo0_mtree_add0_0_q));
    u0_m0_wo0_mtree_add1_0_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((30 downto 30 => u0_m0_wo0_mtree_add0_1_q(29)) & u0_m0_wo0_mtree_add0_1_q));
    u0_m0_wo0_mtree_add1_0: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_add1_0_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_add1_0_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_add1_0_a) + SIGNED(u0_m0_wo0_mtree_add1_0_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_add1_0_q <= u0_m0_wo0_mtree_add1_0_o(30 downto 0);

    -- u0_m0_wo0_mtree_add2_0(ADD,114)@18
    u0_m0_wo0_mtree_add2_0_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((31 downto 31 => u0_m0_wo0_mtree_add1_0_q(30)) & u0_m0_wo0_mtree_add1_0_q));
    u0_m0_wo0_mtree_add2_0_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((31 downto 31 => u0_m0_wo0_mtree_add1_1_q(30)) & u0_m0_wo0_mtree_add1_1_q));
    u0_m0_wo0_mtree_add2_0: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_add2_0_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_add2_0_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_add2_0_a) + SIGNED(u0_m0_wo0_mtree_add2_0_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_add2_0_q <= u0_m0_wo0_mtree_add2_0_o(31 downto 0);

    -- u0_m0_wo0_mtree_add3_0(ADD,116)@19
    u0_m0_wo0_mtree_add3_0_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((32 downto 32 => u0_m0_wo0_mtree_add2_0_q(31)) & u0_m0_wo0_mtree_add2_0_q));
    u0_m0_wo0_mtree_add3_0_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((32 downto 32 => u0_m0_wo0_mtree_add2_1_q(31)) & u0_m0_wo0_mtree_add2_1_q));
    u0_m0_wo0_mtree_add3_0: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_add3_0_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_add3_0_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_add3_0_a) + SIGNED(u0_m0_wo0_mtree_add3_0_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_add3_0_q <= u0_m0_wo0_mtree_add3_0_o(32 downto 0);

    -- u0_m0_wo0_accum(ADD,118)@20
    u0_m0_wo0_accum_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((34 downto 33 => u0_m0_wo0_mtree_add3_0_q(32)) & u0_m0_wo0_mtree_add3_0_q));
    u0_m0_wo0_accum_b <= STD_LOGIC_VECTOR(u0_m0_wo0_accum_q);
    u0_m0_wo0_accum_i <= u0_m0_wo0_accum_a;
    u0_m0_wo0_accum: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_accum_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (d_u0_m0_wo0_compute_q_20_q = "1") THEN
                IF (u0_m0_wo0_aseq_q = "1") THEN
                    u0_m0_wo0_accum_o <= u0_m0_wo0_accum_i;
                ELSE
                    u0_m0_wo0_accum_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_accum_a) + SIGNED(u0_m0_wo0_accum_b));
                END IF;
            END IF;
        END IF;
    END PROCESS;
    u0_m0_wo0_accum_q <= u0_m0_wo0_accum_o(34 downto 0);

    -- GND(CONSTANT,0)@0
    GND_q <= "0";

    -- u0_m0_wo0_oseq(SEQUENCE,119)@19
    u0_m0_wo0_oseq: PROCESS (clk, areset)
        variable u0_m0_wo0_oseq_c : SIGNED(4 downto 0);
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_oseq_c := "00100";
            u0_m0_wo0_oseq_q <= "0";
            u0_m0_wo0_oseq_eq <= '0';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (d_u0_m0_wo0_compute_q_19_q = "1") THEN
                IF (u0_m0_wo0_oseq_c = "00000") THEN
                    u0_m0_wo0_oseq_eq <= '1';
                ELSE
                    u0_m0_wo0_oseq_eq <= '0';
                END IF;
                IF (u0_m0_wo0_oseq_eq = '1') THEN
                    u0_m0_wo0_oseq_c := u0_m0_wo0_oseq_c + 4;
                ELSE
                    u0_m0_wo0_oseq_c := u0_m0_wo0_oseq_c - 1;
                END IF;
                u0_m0_wo0_oseq_q <= STD_LOGIC_VECTOR(u0_m0_wo0_oseq_c(4 downto 4));
            END IF;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_oseq_gated(LOGICAL,120)@20
    u0_m0_wo0_oseq_gated_a <= u0_m0_wo0_oseq_q;
    u0_m0_wo0_oseq_gated_b <= d_u0_m0_wo0_compute_q_20_q;
    u0_m0_wo0_oseq_gated_q <= u0_m0_wo0_oseq_gated_a and u0_m0_wo0_oseq_gated_b;

    -- u0_m0_wo0_oseq_gated_reg(REG,121)@20
    u0_m0_wo0_oseq_gated_reg: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_oseq_gated_reg_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_oseq_gated_reg_q <= STD_LOGIC_VECTOR(u0_m0_wo0_oseq_gated_q);
        END IF;
    END PROCESS;

    -- xOut(PORTOUT,124)@21
    xOut_v <= u0_m0_wo0_oseq_gated_reg_q;
    xOut_c <= STD_LOGIC_VECTOR("0000000" & GND_q);
    xOut_0 <= u0_m0_wo0_accum_q;

END normal;
