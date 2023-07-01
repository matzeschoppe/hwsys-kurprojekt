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
            rst_n:  in    		std_logic;                      -- reset CPU
			uio_in: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			uio_oe: out STD_LOGIC_VECTOR (7 DOWNTO 0);
			uo_out : out STD_LOGIC_VECTOR(7 DOWNTO 0);
			ena : in STD_LOGIC
        );
    end component;

    --Clock period
    constant period: time:= 40 us; --25kHz Clock frequencyr

    -- Signals
    signal clk, rst_n, ena : std_logic;
    signal uio_in, uio_oe, uo_out: std_logic_vector(7 downto 0);
    signal p1_btn_left_in, p1_btn_right_in, p2_btn_left_in, p2_btn_right_in, start_btn_in :std_logic;
    --signal leds_out: std_logic_vector (7 downto 0);

    begin
        -- port map
        IMPL: ALGORITHMUS port map  ( 
                                        clk => clk, rst_n => rst_n, uo_out => uo_out, uio_in => uio_in, uio_oe => uio_oe, ena => ena
                                    );
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
            -- FIRST TEST: PLAYER 1 CORRECT BUTTON
            uio_in <= "00000000";
            --start_btn_in <= '1';
            uio_in(4) <= '1';
            -- run enough cycle for blinking to be over
            n := 0;
            while n < 75264 loop -- >3second loop to wait for blinking to be over 
                n := n+1;
                run_cycle;
            end loop;
            uio_in(4) <= '0';
            --start_btn_in <= '0';

            -- after exactly 3s random is expected to have value 0x98 or 0x31
            -- after blinking value is expected to be 0x4A --> timer init to 0xb100 (45312) --> left led on
            n:=0;
            while n<127232 loop--wait the maximum waiting time (~5s)
                n:= n+1;
                run_cycle;
            end loop;

            uio_in(0) <= '1'; --player 1 press correct led
            -- signal somehow takes 3 cycles to get output to uo_out
            run_cycle;
            run_cycle;
            run_cycle;
            assert uo_out = "01100011" report "Test p1 correct button press went wrong";
            n := 0;
            while n < 25000 loop --1 second loop to show result
                n := n+1;
                run_cycle;
            end loop;

            -- SECOND TEST: PLAYER 1 WRONG BUTTON
            uio_in <= "00000000";
            --start_btn_in <= '1';
            uio_in(4) <= '1';
            -- run enough cycle for blinking to be over
            n := 0;
            while n < 75264 loop -- >3second loop to wait for blinking to be over 
                n := n+1;
                run_cycle;
            end loop;
            uio_in(4) <= '0';
            --start_btn_in <= '0';

            -- after exactly 3s random is expected to have value 0x98 or 0x31
            -- after blinking value is expected to be 0x4A --> timer init to 0xb100 (45312) --> left led on
            n:=0;
            while n<127300 loop--wait the maximum waiting time (~5s)
                n:= n+1;
                run_cycle;
            end loop;

            uio_in(1) <= '1'; --player 1 press wrong led
            -- signal somehow takes 3 cycles to get output to uo_out
            run_cycle;
            run_cycle;
            run_cycle;
            assert uo_out = "01011100" report "Test p1 wrong button press went wrong";
            n := 0;
            while n < 25000 loop --1 second loop to show result
                n := n+1;
                run_cycle;
            end loop;

            -- THIRD TEST: PLAYER 2 CORRECT BUTTON
            uio_in <= "00000000";
            --start_btn_in <= '1';
            uio_in(4) <= '1';
            -- run enough cycle for blinking to be over
            n := 0;
            while n < 75264 loop -- >3second loop to wait for blinking to be over 
                n := n+1;
                run_cycle;
            end loop;
            uio_in(4) <= '0';
            --start_btn_in <= '0';

            n:=0;
            while n<127232 loop--wait the maximum waiting time (~5s)
                n:= n+1;
                run_cycle;
            end loop;

            uio_in(3) <= '1'; --player 2 press correct led
            -- signal somehow takes 3 cycles to get output to uo_out
            run_cycle;
            run_cycle;
            run_cycle;
            assert uo_out = "01011100" report "Test p2 correct button press went wrong";
            n := 0;
            while n < 25000 loop --1 second loop to show result
                n := n+1;
                run_cycle;
            end loop;

            -- FOURTH TEST: PLAYER 2 WRONG BUTTON
            uio_in <= "00000000";
            --start_btn_in <= '1';
            uio_in(4) <= '1';
            -- run enough cycle for blinking to be over
            n := 0;
            while n < 75264 loop -- >3second loop to wait for blinking to be over 
                n := n+1;
                run_cycle;
            end loop;
            uio_in(4) <= '0';
            --start_btn_in <= '0';

            n:=0;
            while n<127232 loop--wait the maximum waiting time (~5s)
                n:= n+1;
                run_cycle;
            end loop;

            uio_in(2) <= '1'; --player 2 press correct led
            -- signal somehow takes 3 cycles to get output to uo_out
            run_cycle;
            run_cycle;
            run_cycle;
            assert uo_out = "01100011" report "Test p2 wrong button press went wrong";
            n := 0;
            while n < 25000 loop --1 second loop to show result
                n := n+1;
                run_cycle;
            end loop;


            -- FIFTH TEST: PLAYER 1 PRESS TOO EARLY
            uio_in <= "00000000";
            --start_btn_in <= '1';
            uio_in(4) <= '1';
            -- run enough cycle for blinking to be over
            n := 0;
            while n < 75364 loop -- >3second loop to wait for blinking to be over 
                n := n+1;
                run_cycle;
            end loop;
            uio_in(4) <= '0';
            uio_in(0) <= '1';
            -- signal somehow takes 3 cycles to get output to uo_out
            run_cycle;
            run_cycle;
            run_cycle;
            assert uo_out = "01011100" report "Test p1 too early button press went wrong";
            n := 0;
            while n < 25000 loop --1 second loop to show result
                n := n+1;
                run_cycle;
            end loop;



            -- SIXTH TEST: PLAYER 2 PRESS TOO EARLY
            uio_in <= "00000000";
            --start_btn_in <= '1';
            uio_in(4) <= '1';
            -- run enough cycle for blinking to be over
            n := 0;
            while n < 75364 loop -- >3second loop to wait for blinking to be over 
                n := n+1;
                run_cycle;
            end loop;
            uio_in(4) <= '0';
            uio_in(2) <= '1';
            -- signal somehow takes 3 cycles to get output to uo_out
            run_cycle;
            run_cycle;
            run_cycle;
            assert uo_out = "01100011" report "Test p2 too early button press went wrong";
            n := 0;
            while n < 25000 loop --1 second loop to show result
                n := n+1;
                run_cycle;
            end loop;
            assert false report "Simulation finished" severity note;
            wait;
        end process;
end TESTBENCH;