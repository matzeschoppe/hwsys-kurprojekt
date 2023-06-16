-- - Eingänge: 4 Buttons (2 Pro Spieler) + 1 Button (Start/Reset)
-- - Ausgänge: 6 Einheiten des 7-Seg-Displays
 

-- Programmablauf:
-- 1. Start-Knopf wird gedrückt
-- 	--> Alle 6 Einheiten Blinken - 3 mal
-- 	--> Random Timer wird ausgelöst + LED Auswahl
-- 2. Nach Ablauf des Timers, leuchtet eine der zwei LED auf
-- 3. Input der Buttons wird überprüft (zu früh + falscher Button überprüfen)
	--> Sieger LED aufleuchten
	--> Spiel Reset

-- 7 SEGMENT ANZEIGE BITS:
--    2 3
--    - - (Player 1)
-- 0 |   | 1
--    - - (Player 2)
--    4 5

-- NOTIZEN:
-- Hauptkomponente + 2 Zusatzkomponenten (BUTTON Signal + Zufallszeit(LRSR))

-- Welche funktionale Einheiten werden benötigt?
    -- Inkrementierer, Multiplexer, Multipzierer
-- Wie ist die Wortbreite?
    -- 8-bit, da max 8 Ein- und Ausgänge

-- 0000 0001 = 1s
-- 0100 0010 = 1,5s

declare bus PLAYER1_BUTTON_LEFT_IN, PLAYER1_BUTTON_RIGHT_IN, 
	    PLAYER2_BUTTON_LEFT_IN, PLAYER2_BUTTON_RIGHT_IN, START_IN;
declare bus RND8BIT_IN(7:0); -- 8 bit from LRSR no real input
declare bus LED_OUT(5:0); --> 5 = unten rechts, 4 = unten links, 3 = oben rechts, 2 = oben links, 1 = rechts, 0 = links

declare register BLINK_COUNTER(1:0), TIMER_COUNTER(16:0);

-->RESET LOOP AND WAIT FOR START SIGNAL
RESET: LED_OUT(5:0) <- 0, BLINK_COUNTER <- 3, TIMER_COUNTER <- 0 if START_IN = 0 then goto RESET fi;

-->BLINK 3 TIMES, no button inputs possible
START_BLINK: 
BLINK_COUNTER(1:0) <- BLINK_COUNTER(1:0) - 1, TIMER_COUNTER(16:0) <- '00011000100000000', LED_OUT(5:0) <- 0; -- TIMER_COUNTER =0,5s

500MS_LOOP1:
TIMER_COUNTER(16:0) <- TIMER_COUNTER(16:0) - 1, if TIMER_COUNTER <> 0 then goto 500MS_LOOP1 fi;

LED_OUT(5:0) <- !LED_OUT(5:0), TIMER_COUNTER(16:0) <- '00011000100000000';

500MS_LOOP2:
TIMER_COUNTER(16:0) <- TIMER_COUNTER(16:0) - 1, if TIMER_COUNTER <> 0 then goto 500MS_LOOP2 fi;

if BLINK_COUNTER <> 0 then goto START_BLINK fi; 

TIMER_COUNTER(16:14) <- RND8BIT_IN(2:0), TIMER_COUNTER(13:0) <- '11000100000000';
WAIT_RANDOM:-- WAIT RANDOM TIME and check for button input too early
if PLAYER1_BUTTON_LEFT_IN = 1 or PLAYER1_BUTTON_RIGHT_IN = 1 then goto PLAYER2_WON 
else if PLAYER2_BUTTON_LEFT_IN = 1 or PLAYER2_BUTTON_RIGHT_IN = 1 then PLAYER1_WON fi, -- , for parallel execution is necessary
TIMER_COUNTER(16:0) <- TIMER_COUNTER(16:0) - 1, if TIMER_COUNTER <> 0 then goto WAIT_RANDOM fi;

if RND8BIT_IN(7) = 1 then goto SET_LEFT_LED else goto SET_RIGHT_LED fi;

SET_LEFT_LED:
LED_OUT(0) <- 1, goto CHECK_RESULT;

SET_RIGHT_LED:
LED_OUT(1) <- 1, goto CHECK_RESULT;


-->USER INPUT ÜBERPRÜFEN
CHECK_RESULT:
if (RND8BIT_IN(7) = 1) --> (BIT IS HIGH --> LEFT LED ON --> LEFT BUTTONS NEED TO BE PRESSED)
	if PLAYER1_BUTTON_LEFT_IN = 1 or PLAYER2_BUTTON_RIGHT_IN = 1 then goto PLAYER1_WON --> PLAYER1 WIN CONDITION
	else if PLAYER1_BUTTON_RIGHT_IN = 1 or PLAYER2_BUTTON_LEFT_IN = 1 then goto PLAYER2_WON --> PLAYER2 WIN CONDITION
else -->(BIT IS LOW --> RIGHT LED ON --> RIGHT BUTTONS NEED TO BE PRESSED)
	if PLAYER1_BUTTON_RIGHT_IN = 1 or PLAYER2_BUTTON_LEFT_IN = 1 then goto PLAYER1_WON; --> PLAYER1 WIN CONDITION
	else if PLAYER1_BUTTON_LEFT_IN = 1 or PLAYER2_BUTTON_RIGHT_IN = 1 then goto PLAYER2_WON; --> PLAYER2 WIN CONDITION
fi;
goto CHECK_RESULT; --> stay in loop until button was pressed


PLAYER1_WON: 
LED_OUT(5:0) <- 0;
LED_OUT(3:2) <- 3, goto WAIT_TIME;

PLAYER2_WON:
LED_OUT(5:0) <- 0;
LED_OUT(5:4) <- 3, goto WAIT_TIME;

WAIT_TIME: --init 3s wait counter
TIMER_COUNTER(16:0) <- '10010100000000000';--> ~75.000 --> 3s wait time
3S_LOOP:-- loop until time elapsed
TIMER_COUNTER(16:0) <- TIMER_COUNTER(16:0) - 1, if TIMER_COUNTER <> 0 then goto 3S_LOOP fi;
goto RESET;