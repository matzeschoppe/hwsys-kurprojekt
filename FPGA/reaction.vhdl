------------------------------------------------------------------------
--
-- Top Level Wrapper for Reaction Game
--
-- File: reaction.vhdl
--
-- Author: Michael Schaeferling
--
-- Date: 2023-06-23
--
-- Description: Wrapper to generate appropriate input signals for the
--              game core logic (module ALGORITHMUS).
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity REACTION is
  port ( clk: in std_logic;
         btn: in std_logic_vector (3 downto 0);
         sw: in std_logic_vector (3 downto 0);
         led: out std_logic_vector (3 downto 0);
         jb_p, jb_n: in std_logic_vector (3 downto 0) -- additional imput pins for better usability
       );
end REACTION;


architecture RTL of REACTION is


component ALGORITHMUS IS
  port (
    clk : in std_logic; -- 25 kHz
    rst_n: in std_logic;
    start: in std_logic;
    p1_btn_left_in, p1_btn_right_in, p2_btn_left_in, p2_btn_right_in : in  std_logic;
    p1_led_won, p2_led_won : out std_logic;
    led_left, led_right : out std_logic
    );
END component;

signal clk_gen_counter : unsigned(11 downto 0) := (others => '0');
signal clk_25khz : std_logic := '0';

signal reset_counter : unsigned(2 downto 0) := (others => '1');
signal reset_n : std_logic;

signal start : std_logic;
signal sw_syn_0, sw_syn_1 : std_logic_vector(3 downto 0);
signal btn_syn_0, btn_syn_1 : std_logic_vector(3 downto 0);
signal btn_p1_l, btn_p1_r, btn_p2_l, btn_p2_r: std_logic;
signal p1_led_won, p2_led_won : std_logic;
signal led_left, led_right : std_logic;

begin


I_ALGORITHMUS: component ALGORITHMUS
port map (
  clk   => clk_25khz,
  rst_n => reset_n,
  start => start,
  p1_btn_left_in => btn_p1_l,
  p1_btn_right_in => btn_p1_r,
  p2_btn_left_in => btn_p2_l,
  p2_btn_right_in => btn_p2_r,
  p1_led_won => p1_led_won,
  p2_led_won => p2_led_won,
  led_left => led_left,
  led_right => led_right
);


process (clk)
begin
  if rising_edge(clk) then

    clk_gen_counter <= clk_gen_counter - 1;

    if clk_gen_counter = 0 then
      clk_25khz <= not(clk_25khz);
      clk_gen_counter <= "100111000100";  -- 125MHz/25kHz/2 = 2500
    end if;

  end if;
end process;

process (clk_25khz)
begin
  if rising_edge(clk_25khz) then

    if reset_counter = 0 then
      reset_n <= '1';
    else
      reset_counter <= reset_counter - 1;
      reset_n <= '0';
    end if;

    sw_syn_0 <= sw;
    sw_syn_1 <= sw_syn_0;

    btn_syn_0 <= btn;
    btn_syn_1 <= btn_syn_0;

  end if;
end process;


start <= sw_syn_1(0) or sw_syn_1(1) or sw_syn_1(2) or sw_syn_1(3);

btn_p1_l <= btn_syn_1(3) or not(jb_p(0));
btn_p1_r <= btn_syn_1(2) or not(jb_n(0));
btn_p2_l <= btn_syn_1(1) or not(jb_p(2));
btn_p2_r <= btn_syn_1(0) or not(jb_n(2));

led(3) <= led_left;
led(2) <= p1_led_won;
led(1) <= p2_led_won;
led(0) <= led_right;

end;
