	LJMP START
	ORG 100H
START:
	SETB RS0
	SETB RS1 ;wchodze do banku 3
	MOV R0, #19H ;zapisuje komorki od adresu 19H czyli R1
	MOV A, #1 ;wartosc wpisywana bedzie sie zaczynac od 1

LOOP:
	MOV @R0, A
	INC R0
	INC A
	CJNE A, #8, LOOP
	
	LJMP START
	NOP