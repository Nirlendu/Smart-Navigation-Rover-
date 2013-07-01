;Copyright 2013 Nirlendu Saha
; Licensed for Free Distribution and Usage.


;SMART NAVIGATION ROVER

;Hardware Details
;Port A (Input port)    --- PA0, PA1, PA2 inputs from Comparator from Right, Center, Left sensor respectively
;Port B (Output port) --- PB0, PB1, PB2, PB3 output to the negative and positive terminal of Right Motor,
  	       ; negative and positive terminal of Left Motor respectively to the motor driver

data segment
	PA EQU 0740H	;address of Port A
	PB EQU 0842H	;address of Port B
	PC EQU 0744H	;address of Port C
	CWR EQU 0746H	;address of Control Word Register
	flg db 00H, 0
data ends

code segment
		assume cs:code,ds:data
start:		mov ax, data
		mov ds, ax

		mov dx, CWR
		mov al, 90h	;set Control Word Register
				;Mode 0
				;Port A - Input port
				;Port B - Output port
		out dx, al
RPT:		mov dx, PA 
		in al, dx		;input from Port A in al
	
		and al, 00000111b 	;Mask all bits except first 3
		cmp al, 00h	;All sensors low
		jz STOP
		cmp al, 01h	;Left and center low,Right high 
		jz RIGHT
		cmp al, 03h               ;Left low, Right and Center high
		jz RIGHT
		cmp al, 04h                ;Center and Right low, Left high
		jz LEFT
		cmp al, 05h                ;Center low, Left and Right high 
		jz MAKEMOV      
		jmp STRAIGHT
;-------------------------------------------------------------------------------------------------------------------------------------------

STOP:		mov cl,00   	;Stop the motors              
		mov dx, PB
		out dx,cl
		jmp EXIT

RIGHT:		mov cl,09    	;Take a right U turn
		mov dx,PB
		out dx,cl
		jmp RPT

LEFT:          	mov cl,06	;Take a left U turn
		mov dx,PB
		out dx,cl
		jmp RPT

MAKEMOV:	jmp MAKEMOVE

STRAIGHT: 	mov cl,10               	;Move straight
		mov dx,PB
		out dx,cl	 
		jmp RPT

MAKEMOVE:	cmp flg,00h              ;Take alternate left or right U turns
		jz L1
		mov flg, 00h	;Change flag
		jmp LEFT

L1:		mov flg,01h	;Change flag	
		jmp RIGHT

EXIT:		mov ax,4c00h
		int 21h
code ends
end start
	
