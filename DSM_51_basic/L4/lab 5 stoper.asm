LED EQU P1.7 ;dla latwiejszego opisu
;/////ustawienie timerow/////
;TIMER 0
T0_G EQU 0 ;gate
T0_C EQU 0 ;COUNTER/'TIMER
T0_M EQU 1 ;MODE 
TIM0 EQU T0_M+T0_C*4+T0_G*8 ;tim0 rejestr 4 bitowy
;TIMER 1
T1_G EQU 0 ;GATE
T1_C EQU 0 ;COUNTER/'TIMER
T1_M EQU 1 ;MODE
TIM1 EQU T1_M+T1_C*4+T1_G*8 ;rejestr 4 bitowy
TMOD_SET EQU TIM0+TIM1*16 ;tmod - rejestr 16 bitowy 8 bitow dla TIM0 i 8 bitow dla TIM1

TH0_SET EQU 256-36 ;10[ms] = 10 000[us]*(11.0592[MHz]/12) = 9 216 cykli = 36 * 256
TL0_SET EQU 0

TH1_SET EQU 256-180 ;50[ms] = 50 000[ŠS]*(11.0592[MHz]/12) = 46 080 cykli = 180 * 256//// 200*50ms=10s
TL1_SET EQU 0

;////////////////////////
	LJMP	START
	;///////////////////////PRZERWANIE TIMER 0
	ORG 0BH
	MOV TH0, #TH0_SET ;przestawienie starszych bitow timera0 -nastawa poczatkowa timera
	MOV TL0, #TL0_SET ;przestawienie mlodszych bitow timera0 -nastawa poczatkowa timera
	INC R4 ;zwieksz milisekundy
	LCALL SPRAWDZ_CZY_PRZEKRECIC_STOPER
	LCALL WYPISZ_CZAS ;wypisz aktualny czas	
	RETI
	;/////////////////KONIEC PRZERWANIA TIMERA 0
	
	;///////////////////////PRZERWANIE TIMER 1
	ORG 1BH
	MOV TH1, #TH1_SET ;z powrotem ustaw 50ms
	MOV TL0, #TL1_SET ;mlodsze bity na 0
	CJNE R6, #0, WYJDZ_PRZERWANIE_T1 ;czy 200razy odmierzono 50ms? jeśli nie wyjdź z przerwania
	CJNE R7, #0, SPRAWDZ_ILE_CZASU_SWIECI ;sprawdz czy led w ogole swieci
	CPL LED
	MOV R7, #1 ;LED swieci
	RETI
SPRAWDZ_ILE_CZASU_SWIECI:
	DJNZ R5, WYJDZ_BEZDEKREMENTACJI ;sprawdz czy odmierzono 4*50ms, jesli nie wyjdz z przerwania, ale nie przestawiaj R6
	CPL LED ;odmierzono 4*50ms, wylacz led
	MOV R7, #0 ;zaznacz ze wylaczono led
	MOV R5, #40 ;kolejna sygnalizacja tez ma trwac 2sek (4*50ms)
	MOV R6, #160 ;odmierzono 2 sek po sygnalizacji, wiec na kolejna sygnalizacje trzeba czekac 8 sek (160*50ms)
	RETI ;led wylaczona, mozna juz wyjsc z przerwania
WYJDZ_PRZERWANIE_T1:
	DEC R6
WYJDZ_BEZDEKREMENTACJI:
	RETI
	;/////////////////KONIEC PRZERWANIA TIMERA 1
	ORG	100H
;/////////////////POCZATEK USTAWIEN REJESTROW
START:
	MOV R4, #0 ;niech milisekundy =0
	MOV R3, #0  ;i sekundy =0
	MOV R7, #0 ;R7 = 0 gdy led sie nie swieci, R7 = 1 gdy led sie swieci
	MOV R6, #200 ;200*50ms = 10s, uzyte do timera1
	MOV R5, #40 ;40*50ms = 2s, na tyle bedzie swiecic dioda sygnalizujaca 10s
	LCALL LCD_CLR ;wyczysc wyswietlacz
	SETB EA ;wlacz zezwolenie ogólne na przerwania
	SETB ET0 ;wlacz zezwolenie na przerwanie od Timera 0
	SETB ET1 ;wlacz zezwolenie na przerwanie od Timera 1
	MOV TMOD, #TMOD_SET
	MOV TH1, #TH1_SET ;przestawienie starszych bitow timera1 -nastawa poczatkowa timera
	MOV TL0, #TL1_SET ;przestawienie mlodszych bitow timera 1 -nastawa poczatkowa timera
	MOV TH0, #TH0_SET ;;przestawienie mlodszych bitow timera 0 -nastawa poczatkowa timera
	MOV TL0, #TL0_SET ;przestawienie mlodszych bitow timera 0 -nastawa poczatkowa timera
	SETB TR1 ;start timera 1
	SETB TR0 ;start timera 0
;///////////////KONIEC USTAWIEN - ale Program Counter leci dalej

;///////////////GŁÓWNY PROGRAM
CZEKAJ_NA_KLAWISZ:
	LCALL WAIT_KEY ;/pozostan w tej linijce - czekaj na wcisniecie klaiwsza
	CPL TR0 ;start/STOP Timera 0
	CPL TR1 ; START/STOP TIMERA 1
	SJMP CZEKAJ_NA_KLAWISZ ;wroc do czekania
	SJMP $ ;/koniec petli programu



SPRAWDZ_CZY_PRZEKRECIC_STOPER:
	CJNE R4, #100, WYJDZ ;jezeli nie ma 100milisekund licz dalej, wyjdz z podprogramu
	MOV R4, #0 ;zeruj milisekundy
	INC R3 ;zwieksz sekundy
	CJNE R3, #100, WYJDZ ;jezeli nie ma 100sekund licz dalej, wyjdz z podprogramu
	MOV R3, #0 ;zeruj sek
	MOV R4, #0 ;zeruj ms
WYJDZ:
	RET
	
	
	
TO_BCD:
	MOV B,#10; DZIELNIK
	DIV AB; WYDZIELAMY CYFRE DZIESIATEK
	SWAP A; PRZESUWAMY CYFRĘ DZIESIĄTEK NA WYŻSZY 4 BITY
	ORL A,B; DODAJEMY CYFRĘ JEDNOŚCI
	;ZAMIANA NA BCD -KONIEC
	RET	

	
WYPISZ_CZAS:
	LCALL LCD_CLR
	MOV A, R3 ;sekundy do akumulatora
	LCALL TO_BCD ;sekundy na bcd
	LCALL WRITE_HEX
	MOV A, #',' 
	LCALL WRITE_DATA ;wypisanie przerwy
	MOV A, R4 ;milisekundy do akumulatora
	LCALL TO_BCD ;zamien milisekundy na bcd
	LCALL WRITE_HEX ;milisekundy wypisz
	RET
	
	NOP
	
