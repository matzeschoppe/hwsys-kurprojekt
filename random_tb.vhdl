library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- REGFILE_TB entity declaration
entity RANDOM_TB is
end RANDOM_TB;


architecture TESTBENCH of RANDOM_TB is
    -- Declare CPU component (Unit Under Test - UUT)
    component RANDOM is
        port (
            clk : IN STD_LOGIC;
            rst_n : IN STD_LOGIC;
            rnd_8bit_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    end component;

	-- configuration
	--RTL muss ggf. noch geändert werden
	for IMPL: RANDOM use entity WORK.RANDOM(RTL);

    --Clock period
    constant period: time:= 40 us; --25khz Clock frequency

    --signals
    signal clk, rst_n: STD_LOGIC;
    signal rnd_8bit_out : STD_LOGIC_VECTOR(7 DOWNTO 0);

    begin
        -- port map
        IMPL: RANDOM port map( clk => clk, rst_n => rst_n, rnd_8bit_out => rnd_8bit_out);
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
            --reset <= '1'; 
            --reset <= '0'; 
            -- bitfolge :   "76543210"
            --initial seed: "01110100" -- XOR Rückkopplung: 0
            run_cycle;
            --nach 1 cycle: "11101000" -- XOR Rückkopplung: 1
            assert rnd_8bit_out = "11101000" report "Cycle 1 - fehlgeschlagen";
            run_cycle;
            --nach 1 cycle: "11010001" -- XOR Rückkopplung: 0
            assert rnd_8bit_out = "11010001" report "Cycle 2 - fehlgeschlagen";
            run_cycle;
            --nach 1 cycle: "10100010" -- XOR Rückkopplung: 0
            assert rnd_8bit_out = "10100010" report "Cycle 3 - fehlgeschlagen";
            run_cycle;
            --nach 1 cycle: "01000100" -- XOR Rückkopplung: 0
            assert rnd_8bit_out = "01000100" report "Cycle 4 - fehlgeschlagen";
            run_cycle;
            --nach 1 cycle: "10001000" -- XOR Rückkopplung: 0
            assert rnd_8bit_out = "10001000" report "Cycle 5 - fehlgeschlagen";
            run_cycle;
            --nach 1 cycle: "00010000" -- XOR Rückkopplung: 1
            assert rnd_8bit_out = "00010000" report "Cycle 6 - fehlgeschlagen";
            run_cycle;
            --nach 1 cycle: "00100001" -- XOR Rückkopplung: 1
            assert rnd_8bit_out = "00100001" report "Cycle 7 - fehlgeschlagen";
            run_cycle;
            --nach 1 cycle: "01000011" -- XOR Rückkopplung: 0
            assert rnd_8bit_out = "01000011" report "Cycle 8 - fehlgeschlagen";
            run_cycle;
            --nach 1 cycle: "10000110" -- XOR Rückkopplung: 1
            assert rnd_8bit_out = "10000110" report "Cycle 9 - fehlgeschlagen";
            run_cycle;
            --nach 1 cycle: "00001101" -- XOR Rückkopplung: 1
            assert rnd_8bit_out = "00001101" report "Cycle 10 - fehlgeschlagen";
            run_cycle;
            rst_n<='1';
            run_cycle;
            rst_n<='0';
            assert rnd_8bit_out = "01110100" report "Reset fehlgeschlagen";

            -- Print a note & finish simulation now
		    assert false report "Simulation finished" severity note;
		    wait;               -- end simulation

        end process;
end TESTBENCH;