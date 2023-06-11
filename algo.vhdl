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
declare bus TIME_ELAPSED_IN, --> Signal das angibt ob die zufällige Wartezeit abgelaufen ist
            LED_IN; --> 0 = left led, 1 = right led
declare bus LED_OUT(5:0), --> 5 = unten rechts, 4 = unten links, 3 = oben rechts, 2 = oben links, 1 = rechts, 0 = links
			START_WAIT_OUT; 

declare register COUNTER(1:0), PLAYER_WON;--> 0=Player1, 1=Player2

-->RESET LOOP AND WAIT FOR START SIGNAL
RESET: START_WAIT_OUT <- 0, LED_OUT(5:0) <- 0, COUNTER <- 0, if START_IN = 0 then goto RESET fi;

-->BLINK 3 TIMES
START_BLINK: 
COUNTER(1:0) <- COUNTER(1:0) + 1, LED_OUT(5:0) <- 0;
WAIT(500); -- Wait 0.5s
LED_OUT(5:0) <- !LED_OUT(5:0);
WAIT(500); -- Wait 0.5s
if COUNTER < 3 then 
	goto START_BLINK; 
else
	START_WAIT_OUT <- 1;
fi;
-->NACH START_BLINK BIS LED AN
LED_LOOP: 
-->BUTTON PRESSED TOO EARLY
if TIME_ELAPSED_IN = 0 then
	if PLAYER1_BUTTON_LEFT_IN = 1 or PLAYER1_BUTTON_RIGHT_IN = 1 then
		PLAYER_WON <- 1;
		goto SHOW_RESULT;
	else if PLAYER2_BUTTON_LEFT_IN = 1 or PLAYER2_BUTTON_RIGHT_IN = 1 then
		PLAYER_WON <- 0;
		goto SHOW_RESULT;
	fi;
else if TIME_ELAPSED_IN = 1 then 
	if LED_IN = 1 then
		LED_OUT(1) <- 1;
	else
	 	LED_OUT(0) <- 1;
	fi;
	goto CHECK_RESULT;
fi;

goto LED_LOOP;


-->USER INPUT ÜBERPRÜFEN
CHECK_RESULT:
-->WRONG BUTTONS PRESSED
if LED_IN = 1 then
	if PLAYER1_BUTTON_LEFT_IN then
		PLAYER_WON <- 1, 
		goto SHOW_RESULT;
	else if PLAYER2_BUTTON_LEFT_IN = 1 then
		PLAYER_WON <- 0,
		goto SHOW_RESULT;
	fi;
-->RIGHT BUTTONS PRESSED
else if LED_IN = 0 then
	if PLAYER1_BUTTON_LEFT_IN then
		PLAYER_WON <- 0, 
		goto SHOW_RESULT;
	else if PLAYER2_BUTTON_LEFT_IN = 1 then
		PLAYER_WON <- 1,
		goto SHOW_RESULT;
	fi;
fi;

goto CHECK_RESULT;


SHOW_RESULT:
LED_OUT(5:0) <- 0;
if PLAYER_WON = 0 then
	LED_OUT(3:2) <- 3;
else if PLAYER_WON = 1 then
	LED_OUT(5:4) <- 3;
fi;

WAIT(1000); -- Wait 1s
goto RESET;