	LJMP	START
	ORG	100H
START:
	MOV R0,#0 ;10 komorek pamieci RAM
	MOV R1,40H
LOOP:
	MOV @R1, #0
	INC R1
	
	INC R0
	CJNE R0, #10, LOOP
	
	LJMP START
	NOP

