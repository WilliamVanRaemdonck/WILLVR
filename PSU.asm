org     0000h
mov	    sp,#7fh


Voltage1    equ 20h
Voltage2    equ 21h
Current1    equ 22h
Current2    equ 23h
AccuBU      equ 24h

;init
lcall	    initcolor	;lcd scherm
lcall       initadcs    ;adc
lcall       initleds    ;leds
;startwaardes
mov         Voltage1,#00h
mov         Voltage2,#00h
mov         Current1,#00h
mov         Current2,#00h

main:
;   status led
clr         P3_data.7
;
;------------------------------------------------------- Berekeningen
;div16                devides register pairs (msb,lsb) r3,r2 / r1,r0  Q=r3,r2 R=r1,r0
;mul16                multiplies register pairs (msb,lsb) r1,r0 * r3,r2 = r3,r2,r1,r0
;------------------------------------------ Voltage
mov     a,#00h      ;lees pin P2.0
lcall   getadc0to7  ;accu als 8 msb meting, b als 2 lsb meting (links afgelijnd)

;correction
;   *100
;   * a waarde  (a * 100) 0.94 * 100 = 94
;   /1000
mov     r3,#00h     ;meting
mov     r2,a
mov     r1,#00h     
mov     r0,#100     ;*100
lcall   mul16       ;mul16                multiplies register pairs (msb,lsb) r1,r0 * r3,r2 = r3,r2,r1,r0

mov     r3,#00h     
mov     r2,#87      ;correctionfactor
lcall   mul16       ;multiplies register pairs (msb,lsb) r1,r0 * r3,r2 = r3,r2,r1,r0

mov     r7,#00h
mov     r6,#00h
mov     r5,#03h
mov     r4,#E8h     ;/10000
lcall   div32       ;div32                devides register quadruples (msb,...lsb) r3,r2,r1,r0 / r7,r6,r5,r4 Q=r7,r6,r5,r4 R=r3,r2,r1,r0

mov     a,r5
mov     r1,a
mov     a,r4
mov     r0,a

lcall   hexbcd16        ;msb,lsb r1,r0 --> r2,r1,r0

mov     Voltage1,r1
mov     Voltage2,r0

;------------------------------------------ Current
mov     a,#01h      ;lees pin P2.1
lcall   getadc0to7  ;

mov     AccuBU,a        ;BU

mov     r3,#00h     ;meting
mov     r2,a
mov     r1,#00h     
mov     r0,#100     ;100
lcall   mul16       ;mul16                multiplies register pairs (msb,lsb) r1,r0 * r3,r2 = r3,r2,r1,r0

mov     r3,#00h     ;meting
mov     r2,#105     ;correctiefactor
lcall   mul16       ;mul16                multiplies register pairs (msb,lsb) r1,r0 * r3,r2 = r3,r2,r1,r0

mov     r7,#00h
mov     r6,#00h
mov     r5,#03h
mov     r4,#E8h     ;/10000
lcall   div32       ;div32                devides register quadruples (msb,...lsb) r3,r2,r1,r0 / r7,r6,r5,r4 Q=r7,r6,r5,r4 R=r3,r2,r1,r0

mov     a,r5
mov     r1,a
mov     a,r4
mov     r0,a

lcall   hexbcd16        ;msb,lsb r1,r0 --> r2,r1,r0

mov     Current1,r1
mov     Current2,r0

;------------------------------------------------------- Display
;------------------------------------------ TEKST PSU-1
mov	        r6,#00		;coordinaten zetten
mov	        r5,#25
mov	        r4,#ffh	    ;kleur
mov	        r3,#ffh
mov	        r2,#00h	    ;achtergrond kleur
mov	        r1,#00h
mov	        dptr,#psu1
lcall	    coloroutmsga

;------------------------------------------ Voltage Deel 1
mov	        r6,#32		;coordinaten zetten
mov	        r5,#00
mov	        r4,#07h	    ;kleur
mov	        r3,#e0h
mov	        r2,#00h	    ;achtergrond kleur
mov	        r1,#00h
mov	        a,Voltage1
lcall	    coloroutbyte
;------------------------------------------ Voltage komma
mov	        r6,#32		;coordinaten zetten
mov	        r5,#32
mov	        r4,#07h	    ;kleur
mov	        r3,#e0h
mov	        r2,#00h	    ;achtergrond kleur
mov	        r1,#00h
mov	        a,#','
lcall	    coloroutchar

;------------------------------------------ Voltage Deel 2
mov	        r6,#32		;coordinaten zetten
mov	        r5,#44
mov	        r4,#07h	    ;kleur
mov	        r3,#e0h
mov	        r2,#00h	    ;achtergrond kleur
mov	        r1,#00h
mov	        a,Voltage2
lcall	    coloroutbyte

;------------------------------------------ Voltage V
mov	        r6,#32		;coordinaten zetten
mov	        r5,#76
mov	        r4,#07h	    ;kleur
mov	        r3,#e0h
mov	        r2,#00h	    ;achtergrond kleur
mov	        r1,#00h
mov	        a,#'V'
lcall	    coloroutchar

;------------------------------------------ Current Deel 1
mov	        r6,#64		;coordinaten zetten
mov	        r5,#00
mov	        r4,#00h	    ;kleur
mov	        r3,#1fh
mov	        r2,#00h	    ;achtergrond kleur
mov	        r1,#00h
mov	        a,Current1
lcall	    coloroutbyte

;------------------------------------------ Current Deel 2
mov	        r6,#64		;coordinaten zetten
mov	        r5,#32
mov	        r4,#00h	    ;kleur
mov	        r3,#1fh
mov	        r2,#00h	    ;achtergrond kleur
mov	        r1,#00h
mov	        a,Current2
lcall	    coloroutbyte

;------------------------------------------ Current mA
mov	        r6,#64		;coordinaten zetten
mov	        r5,#64
mov	        r4,#00h	    ;kleur
mov	        r3,#1fh
mov	        r2,#00h	    ;achtergrond kleur
mov	        r1,#00h
mov	        dptr,#mA
lcall	    coloroutmsga

;------------------------------------------ drawWarning
mov     a,AccuBU
cjne    a,#145,CurrentTest
CurrentTest:
jnc     drawWarning
ljmp    drawNoWarning

drawWarning:
mov	        r6,#96		;coordinaten zetten
mov	        r5,#0
mov	        r4,#01h	    ;kleur
mov	        r3,#1fh
mov	        r2,#00h	    ;achtergrond kleur
mov	        r1,#00h
mov	        dptr,#warning
lcall	    coloroutmsga
ljmp        back

drawNoWarning:
mov	        r6,#96		;coordinaten zetten
mov	        r5,#0
mov	        r4,#07h	    ;kleur
mov	        r3,#e0h
mov	        r2,#00h	    ;achtergrond kleur
mov	        r1,#00h
mov	        dptr,#ok
lcall	    coloroutmsga

;------------------------------------------ LOOP
back:
ljmp    main

psu1:		db	"PSU-1",00h
mA:		    db	"mA",00h
ok:         db  "tmp = ok",00h
warning:    db  "tmp = ! ",00h

#include	"c:\colorxc0.inc"
#include	"c:\xcez5.inc"
