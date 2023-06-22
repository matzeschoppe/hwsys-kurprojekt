LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY RANDOM IS
	PORT (
		clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		rnd_8bit_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END RANDOM;



ARCHITECTURE RTL OF RANDOM IS

    signal lrsr: std_logic_vector(7 downto 0);
BEGIN

	
	-- Prozess für die Uebergangs- und Ausgabefunktion
	PROCESS (clk) -- Zustand und alle Status-Signale in Sensitiviaetsliste 
	BEGIN
		IF rising_edge (clk) THEN
			IF reset = '1' THEN
				lrsr <= "01110100";  --seed = 74 (Zufallszahl)
			ELSE
				lrsr(1) <= lrsr(0);
				lrsr(0) <= lrsr(3) xor (lrsr(4) xor (lrsr(7) xor lrsr(5)));
				lrsr(2) <= lrsr(1);
				lrsr(3) <= lrsr(2);
				lrsr(4) <= lrsr(3);
				lrsr(5) <= lrsr(4);
				lrsr(6) <= lrsr(5);
				lrsr(7) <= lrsr(6);
			END IF;
		END IF;
	END PROCESS;
	
	rnd_8bit_out <= lrsr;
	
END RTL;
