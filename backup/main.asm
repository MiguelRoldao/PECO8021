; made by: MIRO
; 2021 April 5th

	.include "AVR128DB28def.inc"
	.include "standard.inc"

; cpu register attribution
;  0	- accumulator
;  1	- zero register: RZERO
;  2	- 
;  3	- 
;  4	- 
;  5	- 
;  6	- 
;  7	- 
;  8	- 
;  9	- 
; 10	- 
; 11	- 
; 12	- vga: RVGA2
; 13	- vga: RSREG
; 14	- vga: RVGA0
; 15	- vga: RVGA1
;
; 16	- 
; 17	- 
; 18	- 
; 19	- 
; 20	- 
; 21	- 
; 22	- 
; 23	- 
;
; 24	- 
; 25	- 
; 26	- vga: RVGAPTRL
; 27	- vga: RVGAPTRH
; 28	- 
; 29	- 
; 30	- 
; 31	- 
	
	.def	RZERO = r1

	.equ	RAM_START = 0x2800 	; RAM is 6kB
	
	.cseg
	.org	0
	
vectable: 
	jmp	ireset			; RESET vector
	jmp	end			; NMI bad vector
	jmp	end			; BOD bad vector
	jmp	end			; CLKCTRL bad vector
	jmp	end			; MVIO bad vector
	jmp	end			; RTC overflow bad vector
	jmp	end			; RTC periodic bad vector
	jmp	end			; CCL bad vector
	jmp	end			; PORTA bad vector
	jmp	end			; TCA0 bad vector
	jmp	end			; TCA0 bad vector
	jmp	end			; TCA0 bad vector
	jmp	end			; TCA0 bad vector
	jmp	ivgadata		; TCA0 bad vector
	jmp	ivgavsync		; TCB0 bad vector
	jmp	end			; TCB1 bad vector
	jmp	end			; TCD0 bad vector
	jmp	end			; TCD0 bad vector
	jmp	end			; TWI0 bad vector
	jmp	end			; TWI0 bad vector
	jmp	end			; SPI0 bad vector
	jmp	end			; USART0 bad vector
	jmp	end			; USART0 bad vector
	jmp	end			; USART0 bad vector
	jmp	end			; PORTD bad vector
	jmp	end			; AC0 bad vector
	jmp	end			; ADC0 bad vector
	jmp	end			; ADC0 bad vector
	jmp	end			; ZCD0 bad vector
	jmp	end			; AC1 bad vector
	jmp	end			; PORTC bad vector
	jmp	end			; TCB2 bad vector
	jmp	end			; USART1 bad vector
	jmp	end			; USART1 bad vector
	jmp	end			; USART1 bad vector
	jmp	end			; PORTF bad vector
	jmp	end			; NVMCTRL bad vector
	jmp	end			; SPI1 bad vector
	jmp	end			; USART2 bad vector
	jmp	end			; USART2 bad vector
	jmp	end			; USART2 bad vector
	jmp	end			; AC2 bad vector

	.include "vga.asm"
	.include "gfx.asm"

ireset:
	cli
	clr	r1			; set r1 to 0
	out	CPU_SREG, r1		; clear status register
	stackInit RAMEND, r16		; setup stack at the end of SRAM


startup:
	;ldi	r17, 0xD8
	;ldi	r16, 0x09<<2
	;sts	CPU_CCP, r17		; allow protected register access
	;sts	CLKCTRL_OSCHFCTRLA, r16	; set clk freq to 24MHz
	

	; set up external 25.175 MHz clock
	ldi	r16, 0xD8
	ldi	r17, 0b0_000_0011	; select extclk
	ldi	r18, 0b0_0_00_00_1_1	; select External Clock on the XTALHF1 pin and enable it
	out	CPU_CCP, r16
	sts	CLKCTRL_XOSCHFCTRLA, r18	; select External Clock on the XTALHF1 pin and enable it
	out	CPU_CCP, r16
	sts	CLKCTRL_MCLKCTRLA, r17		; select extclk
_waitclk:
	lds	r16, CLKCTRL_MCLKSTATUS
	sbrc	r16, 0
	rjmp	_waitclk

main:	
	; load frame buffer
	ldi	ZL, LOW(vgafb)
	ldi	ZH, HIGH(vgafb)
	ldi	r16, 0
_lfbloop:
	st	Z+, r16
	inc	r16
	cpi	ZL, 0x80
	brne	_lfbloop
	cpi	ZH, 0x65
	brne	_lfbloop

	ldi	r16, 0x07
	mov	r2, r16
	;call	clearscreen

	call	supermario

	call	setupvga
	sei
	
main_loop:

	rjmp	main_loop


end:
	cli				; stop interrupts for good
endloop:
	rjmp	endloop			; infinite loop (THE END)

nil:
	ret


addXtoZ:
	add	ZL, XL
	adc	ZH, XH
	ret


