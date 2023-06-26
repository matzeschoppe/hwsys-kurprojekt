library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- REGFILE_TB entity declaration
entity ALGORITHMUS_TB is
end ALGORITHMUS_TB;


architecture TESTBENCH of ALGORITHMUS_TB is
    -- Declare CPU component (Unit Under Test - UUT)
    component ALGORITHMUS is
        port (
            clk:    in    		std_logic;                      -- clock signal
            reset:  in    		std_logic;                      -- reset CPU
            leds_out:    		out   std_logic_vector (5 downto 0); -- leds output
            p1_btn_left_in:  	in    std_logic;
            p1_btn_right_in:  	in    std_logic;
            p2_btn_left_in:  	in    std_logic;
            p2_btn_right_in:  	in    std_logic; 
            start_btn_in:  		in    std_logic;
            );
     end component;

