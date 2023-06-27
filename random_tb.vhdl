library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- REGFILE_TB entity declaration
entity RANDOM_TB is
end RANDOM_TB;


architecture TESTBENCH of ALGORITHMUS_TB is
    -- Declare CPU component (Unit Under Test - UUT)
    component RANDOM is
        port (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            rnd_8bit_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    end component;

    --Clock period
    constant period: time:= 40 ns; --25khz Clock frequency

    --signals
    signal clk, reset: STD_LOGIC;
    signal rnd_8bit_out : STD_LOGIC_VECTOR(7 DOWNTO 0);

    begin
        -- port map
        IMPL: RANDOM port map( clk => clk, reset => reset, rnd_8bit_out => rnd_8bit_out);
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
            reset <= '1'; 
            run_cycle;
            --initial seed: "01110100" -- XOR Rückkopplung: 0
            assert rnd_8bit_out = "01110100" report "Cycle 1 - Reset fehlgeschlagen";
            run_cycle;
            --nach 1 cycle: "00111010" -- XOR Rückkopplung: 0
            assert rnd_8bit_out = "00111010" report "Cycle 2 - fehlgeschlagen";
            run_cycle;
            --nach 2 cycle: "00011101" -- XOR Rückkopplung: 0
            assert rnd_8bit_out = "00011101" report "Cycle 3 - fehlgeschlagen";
            run_cycle;
            --nach 3 cycle: "00001110" -- XOR Rückkopplung: 0
            assert rnd_8bit_out = "00001110" report "Cycle 4 - fehlgeschlagen";
            run_cycle;
            --nach 4 cycle: "00000111" -- XOR Rückkopplung: 0
            assert rnd_8bit_out = "00000111" report "Cycle 5 - fehlgeschlagen";
            run_cycle;
            --nach 5 cycle: "00000011" -- XOR Rückkopplung: 1
            assert rnd_8bit_out = "00000011" report "Cycle 6 - fehlgeschlagen";
            run_cycle;
            --nach 6 cycle: "10000001" -- XOR Rückkopplung: 1
            assert rnd_8bit_out = "10000001" report "Cycle 7 - fehlgeschlagen";
            run_cycle;
            --nach 7 cycle: "11000000" -- XOR Rückkopplung: 0
            assert rnd_8bit_out = "11000000" report "Cycle 8 - fehlgeschlagen";
            run_cycle;
            --nach 8 cycle: "01100000" -- XOR Rückkopplung: 0
            assert rnd_8bit_out = "01100000" report "Cycle 9 - fehlgeschlagen";
            run_cycle;
            --nach 9 cycle: "00110000" -- XOR Rückkopplung: 1
            assert rnd_8bit_out = "00110000" report "Cycle 10 - fehlgeschlagen";
            run_cycle;
            --nach 10 cycle: "10011000" -- XOR Rückkopplung: 0
            assert rnd_8bit_out = "10011000" report "Cycle 11 - fehlgeschlagen";
            run_cycle;

            -- Print a note & finish simulation now
		    assert false report "Simulation finished" severity note;
		    wait;               -- end simulation

            end process;
end TESTBENCH;