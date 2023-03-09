;/////ustawienie timerow/////
;TIMER 0
T0_G EQU 0 ;gate
T0_C EQU 0 ;COUNTER/'TIMER
T0_M EQU 1 ;MODE 
TIM0 EQU T0_M+T0_C*4+T0_G*8
;TIMER 1
T1_G EQU 0 ;GATE
T1_C EQU 0 ;COUNTER/'TIMER
T1_M EQU 0 ;MODE
TIM1 EQU T1_M+T1_C*4+T1_G*8

TMOD_SET EQU TIM0+TIM1*16

TH0_SET EQU 256-180 ;=76
TL0_SET EQU 0
;////////////////////////
	LJMP	START
	ORG	100H
START:
	MOV SP, #30H ;ustawienie stosu na pamiec ram
	LCALL LCD_CLR ;wyczysc wyswietlacz
	;wybor banku 0
	CLR RS0
	CLR RS1
;///////////////NASTAWIANIE ZEGARU
;wprowadzenie i wyswietlenie godzin:
	LCALL WPROWADZ 
	MOV R2, A ;godziny w R2
	LCALL TO_BCD
	LCALL WRITE_HEX
	MOV A, #':'
	LCALL WRITE_DATA ;wypisanie przerwy
;wprowadzenie i wyswietlenie minut:
	LCALL WPROWADZ 
	MOV R3, A ;minuty w R3
	LCALL TO_BCD ;minuty zamin na bcd
	LCALL WRITE_HEX
	MOV A, #':'
	LCALL WRITE_DATA ;wypisanie przerwy
;wprowadzenie i wyswietlenie sekund:
	LCALL WPROWADZ 
	MOV R4, A ;liczba sekund do R4
	LCALL TO_BCD ;zamien sekundy na bcd
	LCALL WRITE_HEX ;wypisz sekundy
;//////////////KONIEC NASTAWY ZEGARU

;/////////////USTAWIANIE ALARMU godziny:sekundy
	LCALL WPROWADZ
	MOV R5, A ;godzina alarmu do R5
	LCALL WPROWADZ 
	MOV R6, A ;minuty alarmu do R6

;/////////////KONIEC NASTAWY ALARMU

	MOV TMOD, #TMOD_SET
	MOV TH0, #TH0_SET
	MOV TL0, #TL0_SET
	SETB TR0
	
LOOP: ;co ma zrobic w kazdej sekundzie
	LCALL STATUS_UPDATE ;wypisz aktualna godzine
	MOV A, R4 ;sekundy do A
	ADD A, #1 ;dodaj 1 do sekund
	MOV R4, A ;nowa ilosc sekund do R4
	

	
	MOV R7, #20
	
TIME_N50:
	JNB TF0, $
	MOV TH0, #TH0_SET
	CLR TF0
	DJNZ R7, TIME_N50
	CJNE R4, #60, LOOP ;licz tylko do 59 sekund
	
	;minelo 59 sekund dodaj 1 minute i wyzeruj sekundy
	MOV R4, #0 ;zeruj sekundy
	MOV A, R3 ;minuty do akumulatora
	ADD A, #1 ;dodaj 1 minute
	MOV R3, A ;nowe minuty do R3
	CJNE R3, #60, LOOP ;jezeli nie ma 60 pelnych minut wroc do liczenia sekund
	
	
	MOV R3, #0 ;zeruj minuty
	MOV A, R2 ;godziny do akumulatora
	ADD A, #1 ;dodaj 1 godzine
	MOV R2, A ;zaladuj nowe godziny do R2
	CJNE R2, #24, LOOP ;jeżeli nie ma pelnych 24godzin wroc do liczenia sekund
	
	MOV R2, #0 ;zeruj godziny
	SJMP  LOOP


TO_BCD:
	MOV B,#10; DZIELNIK
	DIV AB; WYDZIELAMY CYFRE DZIESIATEK
	SWAP A; PRZESUWAMY CYFRĘ DZIESIĄTEK NA WYŻSZY 4 BITY
	ORL A,B; DODAJEMY CYFRĘ JEDNOŚCI
	;ZAMIANA NA BCD -KONIEC
	RET	
WPROWADZ:
	LCALL WAIT_KEY ; Wczytaj liczbę dziesiątek
	MOV B,#10 ; pomnóż
	MUL AB ; przez 10
	MOV R1,A ; zapisz liczbę w R1
	LCALL WAIT_KEY ;wczytaj liczbę jedności
	ADD A,R1 ; dodaj liczbę jedności do R1
	RET ; wyjdź z podprogramu. Wynik w A
STATUS_UPDATE:
	LCALL LCD_CLR
	MOV A, R2 ;godziny do akumulatora
	LCALL TO_BCD ;godziny na bcd 
	LCALL WRITE_HEX
	MOV A, #':'
	LCALL WRITE_DATA ;wypisanie przerwy
	MOV A, R3 ;minuty do akumulatora
	LCALL TO_BCD ;minuty na bcd
	LCALL WRITE_HEX
	MOV A, #':' 
	LCALL WRITE_DATA ;wypisanie przerwy
	MOV A, R4 ;sekundy do akumulatora
	LCALL TO_BCD ;zamien sekundy na bcd
	LCALL WRITE_HEX ;godzina zostala wypisana
	
	MOV A, R5 ;godziny alarmu do A
	CJNE A,02H,WYJDZ ;porownaj aktualne godziny z godzina alarmu jesli rozne skocz do WYJDZ
	MOV A, R6 ;minuty alarmu do A
	CJNE A,03H,WYJDZ ;porownaj aktualne minuty z minutami alarmu jesli rozne to skocz do WYJDZ
	LJMP ALARM
	
ALARM:
	CPL P1.5
	CPL P1.7
	LJMP ALARM
	
WYJDZ:
	RET
	NOP
	
