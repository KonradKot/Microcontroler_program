
.nolist
.include "m16def.inc"
.list
.listmac
.device ATmega16
.cseg
.org 0x0000
jmp START
;wektory przerwañ
.org 0x0030
START:
;ustawienie stosu
ldi r16, high(RAMEND) ;0x04
out SPH, r16
ldi r16, low(RAMEND) ;0x5f
out SPL, r16
;ustawienie portu B jako wyjœcia
ldi r16, 0b11111111
out DDRB, r16
//sec - ustawia flage carry na 1
MAIN:
ldi r19,4 // przesuniecie binarne z prrzeniesieniem o jedne w prawo
ldi r18,4
/*
MAIN_L:
ror r16
out PORTB, r16
call DELAY
dec r19 // zmniejsz licznik o jeden
brne MAIN_L // jesli r19==0 to przerwij petle
*/
MAIN_R:
call DELAY
//.................
ldi r16,0xE7
out PORTB,r16
call DELAY
//......................
ldi r16,0xC3
out PORTB,r16
call DELAY
//......................
ldi r16,0x81
out PORTB,r16
call DELAY
//.....................
ldi r16,0x00
out PORTB,r16
call DELAY
//......................
ldi r16,0x7E
out PORTB,r16
call DELAY
//......................
ldi r16,0x3C
out PORTB,r16
call DELAY
//......................
ldi r16,0x18
out PORTB,r16
call DELAY
//......................
ldi r16,0x00
out PORTB,r16
call DELAY


/*
out PORTB,r16
ldi r16,0xF0
call DELAY
out PORTB,r16
ldi r16,0x70
call DELAY
out PORTB,r16
ldi r16,0x30
call DELAY
out PORTB,r16
ldi r16,0x10
dec r18
*/
dec r18
brne MAIN_R

jmp MAIN

.org 0x0100
DELAY:
ldi r17, 200
LOOP:
dec r17
brne LOOP
ret
