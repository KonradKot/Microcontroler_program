	;krotka instrukcja
	;1. Wprowadz cyfre dziesiatek I liczby (pamietaj by liczby jednocyfrowe poprzedzic zerem)
	;2. Wprowadz cyfre jednosci II liczby
	;3. Wprowadz cyfre dziesiatek II liczby
	;4. Wprowadz cyfre jednosci II liczby
	;5. Wybierz operacje 1-dodawanie, 2-odejmowanie, 3-mnozenie, 4-roznica
	;6. Wcisnij dowolny przycisk by wrocic do poczatku programu
	LJMP	START
	ORG	100H
START:
	MOV SP, #60H ;ustawienie stosu na pamiec ram
	LCALL LCD_CLR ;wyczysc wyswietlacz
	
;wprowadzenie i wyswietlenie w bcd I liczby
	LCALL WAIT_KEY ;wczytaj cyfre dziesiatek
	MOV B, #10  ;zaladuj 10 do B
	MUL AB ;A*B
	PUSH ACC ;cyfraI *10 z akumulatora-> na stos
	LCALL WAIT_KEY ;wczytaj cyfre jednosci
	POP B ;cyfraI*10  ze stosu->do B
	ADD A,B ;dodaj dziesiatki do jednosci
	PUSH ACC ;I liczba na stos
	LCALL TO_BCD ;zamien na bcd wpisana liczbe
	LCALL WRITE_HEX ;wypisz ta liczbe

;wprowadzenie i wyswietlenie w bcd II liczby
	LCALL WAIT_KEY ;wczytaj cyfre dziesiatek
	MOV B, #10  ;zaladuj 10 do B
	MUL AB ;A*B
	PUSH ACC ;cyfraII *10 z akumulatora -> na stos
	LCALL WAIT_KEY ;wczytaj cyfre jednosci
	POP B ;cyfraII*10 ze stosu ->do B
	ADD A,B ;dodaj dziesiatki do jednosci
	PUSH ACC ;II liczba na stos
	LCALL TO_BCD ;zamien na bcd wpisana liczbe
	LCALL WRITE_HEX ;wypisz ta liczbe
	
;wybieranie operacji
	LCALL WAIT_KEY ;czekaj na wybor operacji
	CJNE A, #1, PRZESKOCZ_DODAWANIE ;jezeli nie 1, przeskocz dodawanie
	
	;dodawanie start
	MOV A, #'+'
	LCALL WRITE_DATA ;wypisanie znaku dodawania
	MOV A, #'=' 
	LCALL WRITE_DATA ;wypisanie znaku równości
	POP 11H ;II liczba wprowadzana do R3
	POP ACC ;I liczba wprowadzana do akumulatora
	ADD A, 11H ;wykonaj dodawanie
	LCALL TO_BCD
	LCALL WRITE_HEX ;wyswietl liczbe - koniec dodawania
	LCALL PRZESKOCZ_DZIELENIE ;wyjdz z wybierania operacji
	
PRZESKOCZ_DODAWANIE:
	CJNE A, #2, PRZESKOCZ_ODEJMOWANIE; jeżeli nie 2, przeskocz odejmowanie
	
	;odejmowanie start
	MOV A, #'-'
	LCALL WRITE_DATA
	MOV A, #'='
	LCALL WRITE_DATA
	POP 11H ;II liczba wprowadzana do R3
	POP ACC ;I liczba wprowadzana do akumulatora
	CLR C ;nie uwzgledniaj flagi przeniesienia w odejmowaniu
	SUBB A, 11H ;A-R3-C
	LCALL TO_BCD
	LCALL WRITE_HEX
	LCALL PRZESKOCZ_DZIELENIE ;wyjdz z wybierania operacji
	
PRZESKOCZ_ODEJMOWANIE:
	CJNE A, #3, PRZESKOCZ_MNOZENIE
	
	;mnożenie start wynik w hex
	MOV A, #'*'
	LCALL WRITE_DATA
	MOV A, #'='
	LCALL WRITE_DATA
	POP ACC ;II liczba wprowadzana do akumulatora
	POP B ;I liczba wprowadzana do B 
	MUL AB
	PUSH ACC ;mlodsze bity wyniku na stos
	PUSH B ;starsze bity wyniku na stos
	POP ACC ;starsze bity na akumulator
	LCALL WRITE_HEX 
	POP ACC ;mlodsze bity na akumulator
	LCALL WRITE_HEX 
	LCALL PRZESKOCZ_DZIELENIE ;wyjdz z wybierania operacji
	
PRZESKOCZ_MNOZENIE:
	CJNE A, #4, PRZESKOCZ_DZIELENIE
	;dzielenie start
	MOV A, #'/'
	LCALL WRITE_DATA
	MOV A, #'='
	LCALL WRITE_DATA
	POP B ;II liczba wprowadzana do B
	MOV R3, B ;II liczba bedzie wyswietlana jako  mianownik, stos bedzie sie zmienial i nie moge inaczej dostac sie do tej wartosci
	POP ACC ;I liczba wprowadzana do akumulatora
	DIV AB
	PUSH B ;reszta z dzielenia na stos
	
	LCALL TO_BCD
	LCALL WRITE_HEX ;wypisanie czesc calkowita
	
	MOV A, #'i'
	LCALL WRITE_DATA
	
	POP ACC ;z dzielenia na akumulator
	LCALL TO_BCD
	LCALL WRITE_HEX ;wypisanie licznika
	
	MOV A,#'/'
	LCALL WRITE_DATA
	
	
	MOV A, R3 ;II liczba(mianownik) wpisana na akumulator
	LCALL TO_BCD
	LCALL WRITE_HEX ;wypisanie mianownika
	
PRZESKOCZ_DZIELENIE:

;powrot do poczatku programu gdy uzytkownik potwierdzi
	LCALL WAIT_KEY
	LJMP START
	
	LJMP	$ ;- pozostań w tym miejscu
	
	
;konwersja bcd (bez wyswietlania)
TO_BCD:
	MOV B,#10; DZIELNIK
	DIV AB; WYDZIELAMY CYFRE DZIESIATEK
	SWAP A; PRZESUWAMY CYFRĘ DZIESIĄTEK NA WYŻSZY 4 BITY
	ORL A,B; DODAJEMY CYFRĘ JEDNOŚCI
	;ZAMIANA NA BCD -KONIEC
	RET
	NOP 