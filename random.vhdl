-- LRSR (8 bit)
-- --> Zufällige Wartezeit(Bit 0-3)
-- --> Zufällige LED (Bit 7)

-- Überprüfen ob Wartezeit abgelaufen ist
-- --> Output: TIME_ELAPSED(0 = nicht abgelaufen, 1 = abgelaufen), LED_OUT

-- Eingänge: RND_SEED (8-bit), RESET_IN, START_WAIT_IN
-- Ausgänge: LED_OUT, TIME_ELAPSED

declare bus SEED_IN(7:0), RESET_IN, START_WAIT_IN; --RESET --> neuer Seed, START --> Start Time Counting
declare bus LED_OUT, TIME_ELAPSED_OUT

declare register P(7:0), I

INIT:
LED_OUT <- 0, TIME_ELAPSED_OUT <- 0;
if RESET_IN = 0 then goto INIT fi; -- wait for seed to be set
P(7:0)<-SEED_IN(7:0); --Alternativ: $random

START: 
LED_OUT <- 0, TIME_ELAPSED_OUT <- 0; --reset outputs

LRSR:
-- do lrsrs loop
P(1) <- P(0);
P(0) <- P(3) xor (P(4) xor (P(7) xor P(5)));
P(2) <- P(1);
P(3) <- P(2);
P(4) <- P(3);
P(5) <- P(4);
P(6) <- P(5);
P(7) <- P(6);

if START_WAIT_IN = 1 then 
    goto TIME_COUNTER; --if game started, count the time
fi;
goto LRSR -- jump backto beginning

TIME_COUNTER:
LED_OUT <- P(7); -- show random led
if P(0) = 0 then P(0) = 1 fi;
WAIT((P(2:0))*500); -- wait random time: min 0,5s max 3,5s Wartezeit
TIME_ELAPSED_OUT <- 1; -- show that time elapsed
goto START; --continue lrsr loop



