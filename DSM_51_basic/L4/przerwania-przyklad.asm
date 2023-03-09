LED EQU P1.7
;****************ustawienie timerów****************
;TIMER 0
T0_G EQU 0 ;GATE
T0_C EQU 0 ;COUNTER/'TIMER
T0_M EQU 1 ;MODE
TIM0 EQU T0_M+T0_C*4+T0_G*8
;TIMER 1
T1_G EQU 0 ;GATE
T1_C EQU 0 ;COUNTER/'TIMER
T1_M EQU 0 ;MODE
TIM1 EQU T0_M+T0_C*4+T0_G*8

TMOD_SET EQU TIM0+TIM1*16

;50[ms] = 50 000[ms]*(11.0592[MHz]/12) =
;= 46 080 cykli = 180 * 256

TH0_SET EQU 256-180
TL0_SET EQU 0
;*************************
	LJMP START
;*************************
;**********PRZERWANIE TIMER 0**********
	ORG 0BH
	MOV TH0, #TH0_SET ;TH0 na 50ms
	DJNZ R7,NO_1SEK ;czy minela 1 sek (sprawdzane co 50ms)
	LCALL ZMIEN_LED
NO_1SEK:
	RETI
;*************************
	ORG 100H
START:
	LCALL LCD_CLR
	MOV TMOD, #TMOD_SET ;Timer 0 liczy czas
	MOV TH0, #TH0_SET ;Timer 0 na 50ms
	
	SETB EA ;wlacz zezwolenie ogólne na przerwania
	SETB ET0 ;wlacz zezwolenie na przerwanie od Timera 0
	MOV R7, #20 ;20*50ms=1s
	SETB TR0 ;start Timera 0

DISP_LOOP:
	LCALL WAIT_KEY ;czekaj na klawisz
	LCALL WRITE_HEX ;wyswietl wartosc na LCD
	SJMP DISP_LOOP
	SJMP $ ;skacz do 47 - koniec programu glownego
	
ZMIEN_LED:
	MOV 47,#20 ;ustaw ponownie R7 na 20, 20*50ms=1s
	CPL LED ;mruganie diody
	RET
	NOP
	