LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ALGORITHMUS IS
	PORT(
			clk : IN STD_LOGIC; -- 25 kHz
			rst_n: IN STD_LOGIC;
			uio_in: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			uio_oe: out STD_LOGIC_VECTOR (7 DOWNTO 0);
			uo_out : out STD_LOGIC_VECTOR(7 DOWNTO 0);
			ena : in STD_LOGIC
		);
END ALGORITHMUS;



ARCHITECTURE RTL OF ALGORITHMUS IS

	COMPONENT RANDOM IS
		PORT (
			clk : IN STD_LOGIC;
			rst_n : IN STD_LOGIC;
			rnd_8bit_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) 
		);
	END COMPONENT;

    signal timer_counter: unsigned (16 downto 0);
    
    signal rnd_8bit : STD_LOGIC_VECTOR(7 DOWNTO 0); 
    
	TYPE t_state IS (s_reset, s_blinkOn1, s_blinkChange1, s_blinkOff1, s_blinkChange2, s_blinkOn2, s_blinkChange3,
	s_blinkOff2, s_blinkChange4, s_blinkOn3, s_blinkChange5, s_blinkOff3, s_waitRndInit, s_waitRnd, s_SetLeftLED,
	s_SetRightLED, s_P1Won, s_P2Won);
	SIGNAL state, next_state : t_state;
	
	signal timer_init_500msec, timer_decr, timer_init_rand: STD_LOGIC;
	signal leds_out: STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal p1_btn_left_in, p1_btn_right_in, p2_btn_left_in, p2_btn_right_in, start_btn_in: STD_LOGIC;

	--configuration of random
	for all: RANDOM use entity WORK.RANDOM(RTL);
    
BEGIN

    I_RANDOM: component RANDOM
    port map (
      clk   => clk,
      rst_n => rst_n,
      rnd_8bit_out => rnd_8bit
    );


	-- Timer-Counter-Prozess (taktsynchroner Prozess)
	PROCESS (clk) -- (nur) Taktsignal in Sensitivitätsliste
	BEGIN
		IF rising_edge (clk) THEN
		    if (timer_init_500msec = '1') then
		         timer_counter <= "00011000100000000";
		    end if;

            if (timer_init_rand = '1') then
				timer_counter <= unsigned(rnd_8bit(2 downto 0) & "11000100000000");
			end if;
		        
		    if (timer_decr = '1') then
                timer_counter <= timer_counter - 1;
            end if;
		END IF;
	END PROCESS;

	PROCESS(clk)
	BEGIN
		uio_oe <= "00000000"; --set all as inputs
		p1_btn_left_in 	<= uio_in(0);
		p1_btn_right_in <= uio_in(1); 
		p2_btn_left_in 	<= uio_in(2);
		p2_btn_right_in <= uio_in(3);
		start_btn_in 	<= uio_in(4);
		uo_out <= leds_out;
	END PROCESS;

	-- Zustandsregister (taktsynchroner Prozess)
	PROCESS (clk) -- (nur) Taktsignal in Sensitivitätsliste
	BEGIN
		IF rising_edge (clk) THEN
		    IF (rst_n = '1') then
		        state <= s_reset;
		    ELSE
			    state <= next_state;
			END IF;
		END IF;
	END PROCESS;
	

	-- Prozess für die Uebergangs- und Ausgabefunktion
	PROCESS (state, p1_btn_left_in, p1_btn_right_in, p2_btn_left_in, p2_btn_right_in, start_btn_in, rnd_8bit, timer_counter) -- Zustand und alle Status-Signale in Sensitiviaetsliste 
	BEGIN
	
	    timer_init_500msec <= '0';
	    timer_init_rand <= '0';
	    timer_decr <= '0';
		leds_out <= "00000000";
		--uo_out <= leds_out;
	    
	    
	    next_state <= state;
	    
		CASE state IS
			WHEN s_reset =>
				IF start_btn_in = '1' THEN
					next_state <= s_blinkOn1;
				END IF;
				
				timer_init_500msec <= '1';
				
			WHEN s_blinkOn1 =>
				leds_out <= (others => '1');
				
				if timer_counter = 0 then
					next_state <= s_blinkChange1;
				else
				    timer_decr <= '1';
				end if;
			
			WHEN s_blinkChange1 =>
				timer_init_500msec <= '1';
				next_state <= s_blinkOff1;
			
			WHEN s_blinkOff1 =>
				leds_out <= (others => '0');
				
				if timer_counter = 0 then
					next_state <= s_blinkChange2;
				else
				    timer_decr <= '1';
				end if;
			
			WHEN s_blinkChange2 =>
				timer_init_500msec <= '1';
				next_state <= s_blinkOn2;
			
			WHEN s_blinkOn2 =>
				leds_out <= (others => '1');
				
				if timer_counter = 0 then
					next_state <= s_blinkChange3;
				else
				    timer_decr <= '1';
				end if;
			
			WHEN s_blinkChange3 =>
				timer_init_500msec <= '1';
				next_state <= s_blinkOff2;
			
			WHEN s_blinkOff2 =>
				leds_out <= (others => '0');
				
				if timer_counter = 0 then
					next_state <= s_blinkChange4;
				else
				    timer_decr <= '1';
				end if;
			
			WHEN s_blinkChange4 =>
				timer_init_500msec <= '1';
				next_state <= s_blinkOn3;
			
			WHEN s_blinkOn3 =>
				leds_out <= (others => '1');
				
				if timer_counter = 0 then
					next_state <= s_blinkChange5;
				else
				    timer_decr <= '1';
				end if;
				
			WHEN s_blinkChange5 =>
				timer_init_500msec <= '1';
				next_state <= s_blinkOff3;
				
			WHEN s_blinkOff3 =>
				leds_out <= (others => '0');
				
				if timer_counter = 0 then
					next_state <= s_waitRndInit;
				else
				    timer_decr <= '1';
				end if;

			WHEN s_waitRndInit => 
			    timer_init_rand <= '1';
			    next_state <= s_waitRnd;
			
			WHEN s_waitRnd =>
			    timer_decr <= '1';
			    
				IF timer_counter = 0 THEN
					if rnd_8bit(7) = '1' then
						next_state <= s_SetLeftLED;
					else
						next_state <= s_SetRightLED;
					end if;
				ELSIF p1_btn_left_in = '1' or p1_btn_right_in = '1' then 
					next_state <= s_P2Won;
				ELSIF  p2_btn_left_in = '1' or p2_btn_right_in = '1' then 
					next_state <= s_P1Won;
				END IF;

			WHEN s_SetLeftLED =>
				leds_out(0) <= '1';
				if (p1_btn_left_in = '1' or p2_btn_right_in = '1') then
					next_state <= s_P1Won;
				elsif (p1_btn_right_in = '1' or p2_btn_left_in = '1') then
					next_state <= s_P2Won;
				end if;
					
			WHEN s_SetRightLED =>
				leds_out(3) <= '1';
				if (p1_btn_right_in = '1' or p2_btn_left_in = '1') then
					next_state <= s_P1Won;
				elsif (p1_btn_left_in = '1' or p2_btn_right_in = '1') then
					next_state <= s_P2Won;
				end if;

			WHEN s_P1Won =>
			    leds_out <= "01100011";--segments: a,b,f,g
				timer_init_500msec <= '1';
			    if start_btn_in = '1' then
					next_state <= s_blinkOn1;
				end if;

			WHEN s_P2Won =>
			    leds_out <= "01011100";--segments: c,d,e,g
				timer_init_500msec <= '1';
			    if start_btn_in = '1' then
					next_state <= s_blinkOn1;
				end if;
		END CASE;
	END PROCESS;
END RTL;
