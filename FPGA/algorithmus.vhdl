library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ALGORITHMUS is
  port (
    clk : in std_logic; -- 25 kHz
    rst_n: in std_logic;

    start: in std_logic;
    p1_btn_left_in, p1_btn_right_in, p2_btn_left_in, p2_btn_right_in : in  std_logic;

    p1_led_won, p2_led_won : out std_logic;
    led_left, led_right : out std_logic
    );
end ALGORITHMUS;



architecture RTL of ALGORITHMUS is

  component RANDOM is
    PORT (
      clk : in std_logic;
      reset : in std_logic;
      rnd_8bit_out : out std_logic_vector(7 downto 0)
    );
  end component;


  signal reset : std_logic;

  signal timer_counter: unsigned (16 downto 0);

  signal rnd_8bit : std_logic_vector(7 downto 0);

  type t_state is (s_reset,
                   s_blinkOn1, s_blinkChange1, s_blinkOff1, s_blinkChange2,
                   s_blinkOn2, s_blinkChange3, s_blinkOff2, s_blinkChange4,
                   s_blinkOn3, s_blinkChange5, s_blinkOff3,
                   s_waitRndInit, s_waitRnd,
                   s_SetLeftLED,
                   s_SetRightLED,
                   s_P1Won,
                   s_P2Won
                  );
  signal state, next_state : t_state;

  signal timer_init_500msec, timer_decr, timer_init_rand: std_logic;

begin

    I_RANDOM: component RANDOM
    port map (
      clk => clk,
      reset => reset,
      rnd_8bit_out => rnd_8bit
    );

  reset <= not(rst_n);

  -- Timer-Counter-Prozess (taktsynchroner Prozess)
  process (clk) -- (nur) Taktsignal in Sensitivitätsliste
  begin
    if rising_edge (clk) then

      if (timer_init_500msec = '1') then
       timer_counter <= "00011000100000000";
      end if;

      if (timer_init_rand = '1') then
        timer_counter <= unsigned(rnd_8bit(2 downto 0) & "11000100000000");
      end if;

      if (timer_decr = '1') then
        timer_counter <= timer_counter - 1;
      end if;
    end if;
  end process;

  -- Zustandsregister (taktsynchroner Prozess)
  process (clk) -- (nur) Taktsignal in Sensitivitätsliste
  begin
    if rising_edge (clk) then
        if (reset = '1') then
            state <= s_reset;
        else
          state <= next_state;
      end if;
    end if;
  end process;


  -- Prozess für die Uebergangs- und Ausgabefunktion
  process (state, reset, p1_btn_left_in, p1_btn_right_in, p2_btn_left_in, p2_btn_right_in, rnd_8bit, timer_counter) -- Zustand und alle Status-Signale in Sensitiviaetsliste
  begin

      timer_init_500msec <= '0';
      timer_init_rand <= '0';
      timer_decr <= '0';

      p1_led_won <= '0';
      p2_led_won <= '0';
      led_left  <= '0';
      led_right <= '0';

      next_state <= state;

    case state is
      when s_reset =>
        timer_init_500msec <= '1';

        if ( (p1_btn_left_in = '1') and (p1_btn_right_in = '1') and (p2_btn_left_in = '1') and (p2_btn_right_in = '1') ) or ((start = '1'))  then
          next_state <= s_blinkOn1;
        end if;

      when s_blinkOn1 =>
        timer_decr <= '1';

        p1_led_won <= '1';
        p2_led_won <= '1';
        led_left  <= '1';
        led_right <= '1';

        if timer_counter = 0 then
          next_state <= s_blinkChange1;
        end if;

      when s_blinkChange1 =>
        timer_init_500msec <= '1';
        next_state <= s_blinkOff1;

      when s_blinkOff1 =>
        timer_decr <= '1';

        if timer_counter = 0 then
          next_state <= s_blinkChange2;
        end if;

      when s_blinkChange2 =>
        timer_init_500msec <= '1';
        next_state <= s_blinkOn2;

      when s_blinkOn2 =>
        timer_decr <= '1';

        p1_led_won <= '1';
        p2_led_won <= '1';
        led_left  <= '1';
        led_right <= '1';

        if timer_counter = 0 then
          next_state <= s_blinkChange3;
        end if;

      when s_blinkChange3 =>
        timer_init_500msec <= '1';
        next_state <= s_blinkOff2;

      when s_blinkOff2 =>
        timer_decr <= '1';

        if timer_counter = 0 then
          next_state <= s_blinkChange4;
        end if;

      when s_blinkChange4 =>
        timer_init_500msec <= '1';
        next_state <= s_blinkOn3;

      when s_blinkOn3 =>
        timer_decr <= '1';

        p1_led_won <= '1';
        p2_led_won <= '1';
        led_left  <= '1';
        led_right <= '1';

        if timer_counter = 0 then
          next_state <= s_blinkChange5;
        end if;

      when s_blinkChange5 =>
        timer_init_500msec <= '1';
        next_state <= s_blinkOff3;

      when s_blinkOff3 =>
        timer_decr <= '1';

        if timer_counter = 0 then
          next_state <= s_waitRndInit;
        end if;

      when s_waitRndInit =>
        timer_init_rand <= '1';
        next_state <= s_waitRnd;

      when s_waitRnd =>
        timer_decr <= '1';

        if timer_counter = 0 then
          if rnd_8bit(7) = '1' then
            next_state <= s_SetLeftLED;
          else
            next_state <= s_SetRightLED;
          end if;
        elsif p1_btn_left_in = '1' or p1_btn_right_in = '1' then
          next_state <= s_p2Won;
        elsif p2_btn_left_in = '1' or p2_btn_right_in = '1' then
          next_state <= s_p1Won;
        end if;

      when s_SetLeftLED =>
        led_left  <= '1';

        if (p1_btn_left_in = '1' or p2_btn_right_in = '1') then
          next_state <= s_P1Won;
        elsif (p1_btn_right_in = '1' or p2_btn_left_in = '1') then
          next_state <= s_P2Won;
        end if;

      when s_SetRightLED =>
        led_right <= '1';

        if (p1_btn_right_in = '1' or p2_btn_left_in = '1') then
          next_state <= s_P1Won;
        elsif (p1_btn_left_in = '1' or p2_btn_right_in = '1') then
          next_state <= s_P2Won;
        end if;

      when s_P1Won =>
        timer_init_500msec <= '1';

        p1_led_won <= '1';
        led_left  <= '1';

        if ( (p1_btn_left_in = '1') and (p1_btn_right_in = '1') and (p2_btn_left_in = '1') and (p2_btn_right_in = '1') ) or ((start = '1'))  then
          next_state <= s_blinkOn1;
        end if;

      when s_P2Won =>
        timer_init_500msec <= '1';

        p2_led_won <= '1';
        led_right <= '1';

        if ( (p1_btn_left_in = '1') and (p1_btn_right_in = '1') and (p2_btn_left_in = '1') and (p2_btn_right_in = '1') ) or ((start = '1'))  then
          next_state <= s_blinkOn1;
        end if;

    end case;

  end process;

end RTL;
