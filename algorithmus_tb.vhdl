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

    --Clock period
    constant period: time:= 25 ms; --25khz Clock frequency

    -- Signals
    signal clk, reset std_logic := '0';
    signal p1_btn_left_in, p1_btn_right_in, p2_btn_left_in, p2_btn_right_in, start_btn_in std_logic :='0';
    signal leds_out: std_logic_vector (5 downto 0);

    begin
        -- port map
        IMPL: ALGORITHMUS port map( clk => clk, reset => reset, leds_out => leds_out, 
                                    p1_btn_left_in => p1_btn_left_in, p1_btn_right_in => p1_btn_right_in,
                                    p2_btn_left_in => p2_btn_left_in, p2_btn_right_in => p2_btn_right_in, 
                                    start_btn_in => start_btn_in);
        process

        -- helper to perform clock cycle
        procedure run_cycle is 
            begin 
                clk <= '0';
            wait for period/2;
                clk <= '1';
            wait for period/2;
        end procedure;

        begin
            start_btn_in <= '1';
            -- run enough cycle for blinking to be over
            -- test what happens on button press during wait
            -- test what happens

        end process;
end TESTBENCH;