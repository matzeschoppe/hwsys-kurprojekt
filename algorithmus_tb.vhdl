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
            start_btn_in:  		in    std_logic
        );
    end component;

    --Clock period
    constant period: time:= 40 us; --25kHz Clock frequencyr

    -- Signals
    signal clk, reset : std_logic;
    signal p1_btn_left_in, p1_btn_right_in, p2_btn_left_in, p2_btn_right_in, start_btn_in :std_logic;
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
        
        variable n: integer;

        begin
            start_btn_in <= '1';
            -- run enough cycle for blinking to be over
            n := 0;
            while n < 75300 loop -- >3second loop to wait for blinking to be over +275 for some reason
                n := n+1;
                run_cycle;
            end loop;
            start_btn_in <= '0';

            -- after exactly 3s random is expected to have value 0x98 or 0x31
            -- after blinking value is expected to be 0x4A --> timer init to 0xb100 (45312) --> left led on
            n:=0;
            while n<45312 loop--wait the random time
                n:= n+1;
                run_cycle;
            end loop;

            --left led will be on
            p1_btn_left_in <= '1';
            run_cycle;
            assert leds_out = "001100" report "Test p1 right button press went wrong";
            n := 0;
            while n < 25000 loop --1 second loop to show result
                n := n+1;
                run_cycle;
            end loop;

            assert false report "Simulation finished" severity note;
            wait;
        end process;
end TESTBENCH;