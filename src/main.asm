; made by: MIRO
; 2021 April 5th

	.include "AVR128DB28def.inc"
	.include "standard.inc"

;; CPU REGISTER ATTRIBUTION
; r0-7 are not conserved by procedures (except for ISRs, they do conserve them)
; r8-15 are reserved for system functions, and MUST not be written to!
; r16-31 MUST be conserved by all procedures (push/pop), including ISRs
;
;  0	- 
;  1	- 
;  2	- 
;  3	- 
;  4	- 
;  5	- 
;  6	- 
;  7	- 
;  8	- 
;  9	- zero register: RZERO
; 10	- vga: RVGAPTRL
; 11	- vga: RVGAPTRH
; 12	- vga: RVGA0
; 13	- vga: RVGA1
; 14	- vga: RVGA2
; 15	- vga: RSREG
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
; 26	- 
; 27	- 
; 28	- 
; 29	- 
; 30	- 
; 31	- 

;; General purpose registers usage:
; GPR0
; 0
; 1
; 2
; 3
; 4
; 5
; 6
; 7
;
; GPR1
; 0
; 1
; 2
; 3
; 4
; 5
; 6
; 7
;
; GPR2	
; 0	VGA: pixel line counter
; 1	"""
; 2	"""
; 3	"""
; 4	"""
; 5	"""
; 6	"""
; 7	"""
;
; GPR3
; 0	VGA: vertical state
; 1	"""
; 2	PS2: ~pressed/released flag
; 3	PS2: extend scnacode flag
; 4	
; 5	
; 6	
; 7	

;; Event channels usage:
; 0	VGA: clock source of TCB2
; 1	VGA: TCB2 sends a pulse @60Hz
; 2
; 3
; 4
; 5
; 6
; 7

	.def	RZERO = r9

	.equ	RAM_START = 0x2800 	; RAM is 6kB
	
	
	.equ	SYS_TCB0ICRUN = 4
	.equ	SYS_TCB1ICRUN = 5
	.equ	SYS_TCB0ICIGNORE = 6
	.equ	SYS_TCB1ICIGNORE = 7
	
	.dseg
	.org	SRAM_START
itcb0ptr:
	.byte	2
itcb1ptr:
	.byte	2

	
	.cseg
	.org	0
	
vectable: 
	jmp	ireset			; 0x00 RESET vector - reset machine
	jmp	end			; 0x02 NMI bad vector
	jmp	end			; 0x04 BOD bad vector
	jmp	end			; 0x06 CLKCTRL bad vector
	jmp	end			; 0x08 MVIO bad vector
	jmp	end			; 0x0A RTC overflow bad vector
	jmp	end			; 0x0C RTC periodic bad vector
	jmp	end			; 0x0E CCL bad vector
	jmp	end			; 0x10 PORTA bad vector
	jmp	end			; 0x12 TCA0 bad vector
	jmp	end			; 0x14 TCA0 bad vector
	jmp	end			; 0x16 TCA0 bad vector
	jmp	end			; 0x18 TCA0 bad vector
	jmp	ivgadata		; 0x1A TCA0 CMP2 vector - VGA: output vga data
	jmp	end			; 0x1C TCB0 CPT vector
	jmp	end			; 0x1E TCB1 CPT vector
	jmp	end			; 0x20 TCD0 bad vector
	jmp	end			; 0x22 TCD0 bad vector
	jmp	end			; 0x24 TWI0 bad vector
	jmp	end			; 0x26 TWI0 bad vector
	jmp	end			; 0x28 SPI0 bad vector
	jmp	ips2rx			; 0x2A USART0 RX vector - PS2: process received byte
	jmp	end			; 0x2C USART0 bad vector
	jmp	end			; 0x2E USART0 bad vector
	jmp	end			; 0x30 PORTD bad vector
	jmp	end			; 0x32 AC0 bad vector
	jmp	end			; 0x34 ADC0 bad vector
	jmp	end			; 0x36 ADC0 bad vector
	jmp	end			; 0x38 ZCD0 bad vector
	jmp	end			; 0x3A AC1 bad vector
	jmp	end			; 0x3C PORTC bad vector
	jmp	ivgavsync		; 0x3E TCB2 CPT vector - VGA: update vga vertical state
	jmp	end			; 0x40 USART1 bad vector
	jmp	end			; 0x42 USART1 bad vector
	jmp	end			; 0x44 USART1 bad vector
	jmp	end			; 0x46 PORTF bad vector
	jmp	end			; 0x48 NVMCTRL bad vector
	jmp	end			; 0x4A SPI1 bad vector
	jmp	end			; 0x4C USART2 bad vector
	jmp	end			; 0x4E USART2 bad vector
	jmp	end			; 0x50 USART2 bad vector
	jmp	end			; 0x52 AC2 bad vector


; generic interrupt handler for TBC0
itcb0:
	push	ZL
	push	ZH
	
	lds	ZL, LOW(itcb0ptr)
	lds	ZH, HIGH(itcb0ptr)
	
	sbic	GPR_GPR3, SYS_TCB0ICRUN
	rjmp	_itcb0_ignore

_itcb0_run:
	sbi	GPR_GPR3, SYS_TCB0ICRUN
	
	sei
	icall
	sbi	GPR_GPR3, SYS_TCB0ICRUN
	
_itcb0_end:
	pop	ZH
	pop	ZL
	
	ret
	
_itcb0_ignore:
	sbi	GPR_GPR3, SYS_TCB0ICIGNORE
	pop	ZH
	pop	ZL
	
	reti
	

; generic interrupt handler for TBC1
itcb1:
	push	ZL
	push	ZH
	
	lds	ZL, LOW(itcb1ptr)
	lds	ZH, HIGH(itcb1ptr)
	
	sbic	GPR_GPR3, SYS_TCB1ICRUN
	rjmp	_itcb1_ignore

_itcb1_run:
	sbi	GPR_GPR3, SYS_TCB1ICRUN
	
	sei
	icall
	sbi	GPR_GPR3, SYS_TCB1ICRUN
	
_itcb1_end:
	pop	ZH
	pop	ZL
	
	ret
	
_itcb1_ignore:
	sbi	GPR_GPR3, SYS_TCB1ICIGNORE
	pop	ZH
	pop	ZL
	
	reti


; void procedure
void:
	ret



maskb:	.db 1, 2, 4, 8, 16, 32, 64, 128
maskw:	.dw 0x0001, 0x002, 0x004, 0x008, \
	0x0010, 0x0020, 0x0040, 0x0080, \
	0x0100, 0x0200, 0x0400, 0x0800, \
	0x1000, 0x2000, 0x4000, 0x8000

mew:	.db\
	0x00, 0x2e, 0x2e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0xff, 0xff, 0xf0, 0x12, 0x3f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0xff, 0xf4, 0x56, 0x7f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0xf8, 0x9a, 0xbf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfc,\
	0xde, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xf0, 0x0f, 0xff, 0xff, 0xff,\
	0xff, 0xff, 0xff, 0xff, 0x00, 0x06, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x0e, 0xf0, 0xff, 0xff, 0xff, 0xff,\
	0xff, 0xff, 0x60, 0xee, 0xee, 0x6f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0xff, 0xff, 0xff, 0xff, 0x00, 0xee, 0xf0, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0xf6, 0xfe, 0xfe, 0xee, 0x0f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0xff, 0xff, 0xf0, 0xe0, 0xef, 0xfe, 0x0f, 0xff, 0xff, 0xff, 0xff, 0xef,\
	0xef, 0xef, 0xee, 0x0f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0xf0, 0xef, 0xfe, 0xfe, 0xfe, 0x0f, 0xff, 0xff, 0xff, 0xff, 0x6f, 0xfe,\
	0xfe, 0xe6, 0x6f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x0f,\
	0xff, 0xff, 0xef, 0xee, 0x0f, 0xff, 0xff, 0xff, 0xfe, 0xff, 0xff, 0xef,\
	0xe0, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xf0, 0xff, 0xff,\
	0xff, 0xfe, 0xfe, 0xe0, 0xff, 0xff, 0xff, 0xf6, 0xff, 0xff, 0xfe, 0x0f,\
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x6f, 0xff, 0xff, 0xff,\
	0xef, 0xee, 0xe0, 0xff, 0xff, 0xff, 0xf0, 0xff, 0xff, 0xf0, 0xff, 0xff,\
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0xff, 0xff, 0xff, 0xff, 0xfe,\
	0x0e, 0xee, 0x0f, 0xff, 0xff, 0xf0, 0xff, 0xff, 0x0f, 0xff, 0xff, 0xff,\
	0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0xff, 0xff, 0xff, 0xff, 0xe0, 0xf0,\
	0xee, 0x0f, 0xff, 0xff, 0xf0, 0xff, 0xff, 0x0f, 0xff, 0xff, 0xff, 0xff,\
	0xff, 0xff, 0xff, 0x00, 0xee, 0xff, 0xff, 0xff, 0xff, 0x06, 0xff, 0xee,\
	0x0f, 0xff, 0xff, 0xff, 0x0f, 0xf0, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0xff, 0xf0, 0xfe, 0xef, 0xff, 0xff, 0xff, 0xef, 0x06, 0x6f, 0xee, 0xe0,\
	0xff, 0xff, 0xff, 0x0f, 0xf0, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0xf0, 0xff, 0xef, 0xff, 0xff, 0xff, 0xef, 0x0f, 0x6f, 0xee, 0xe0, 0xff,\
	0xff, 0xff, 0x0f, 0xf0, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0x0f, 0xef, 0xff, 0xff, 0xff, 0xfe, 0xf0, 0x6e, 0xe6, 0xee, 0x0f, 0xff,\
	0xff, 0xf0, 0xe6, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xf0,\
	0x0e, 0xff, 0xff, 0xff, 0xff, 0xfe, 0xee, 0x0e, 0xee, 0x0f, 0xff, 0xff,\
	0xf0, 0xee, 0x0f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xf6,\
	0xf0, 0x0f, 0xff, 0xff, 0xff, 0xe0, 0xee, 0xee, 0xe0, 0xff, 0xff, 0xff,\
	0x0e, 0x0f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x6f,\
	0x66, 0xff, 0xff, 0xff, 0xe0, 0xef, 0xfe, 0xe0, 0xff, 0xff, 0xff, 0xf0,\
	0xe0, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x0f,\
	0x6f, 0xff, 0xfe, 0x06, 0xff, 0xff, 0xee, 0x0f, 0xff, 0xff, 0xf6, 0xee,\
	0x6f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x0f,\
	0xff, 0xe0, 0x0f, 0xff, 0xff, 0x0e, 0x0f, 0xff, 0xff, 0xff, 0x0e, 0x0f,\
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xf6, 0x00,\
	0x6f, 0x0f, 0xff, 0x00, 0xfe, 0xe0, 0xff, 0xff, 0xff, 0xf6, 0xe6, 0xff,\
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xf6,\
	0x6f, 0xf0, 0xff, 0xee, 0xe0, 0xff, 0xff, 0xff, 0xf0, 0xe0, 0xff, 0xff,\
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xf0, 0x00, 0xff,\
	0xf0, 0xee, 0x0f, 0xe0, 0xff, 0xff, 0xff, 0xf0, 0xf0, 0xff, 0xff, 0xff,\
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x0f, 0xf0, 0xff, 0xff,\
	0x00, 0xff, 0xfe, 0x0f, 0xff, 0xff, 0xf6, 0xf0, 0xff, 0xff, 0xff, 0xff,\
	0xff, 0xff, 0xf0, 0x00, 0x0f, 0xff, 0xff, 0x0e, 0xe0, 0xff, 0xff, 0xee,\
	0xff, 0xfe, 0x0f, 0xff, 0xff, 0x6f, 0xf6, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0xff, 0x06, 0x6e, 0xe0, 0x00, 0xff, 0xf0, 0x0e, 0x0f, 0xfe, 0xef, 0xff,\
	0xfe, 0x0f, 0xff, 0xff, 0x0f, 0x0f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0x0e, 0xe6, 0xef, 0xff, 0x00, 0x0e, 0xee, 0xee, 0xee, 0x0f, 0xff, 0xfe,\
	0x00, 0xff, 0xf0, 0xff, 0x6f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xf0,\
	0x0e, 0xff, 0xff, 0xff, 0xee, 0xe0, 0x0e, 0xee, 0x0e, 0xff, 0xe0, 0xee,\
	0x00, 0x0e, 0xe0, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xf0,\
	0x0f, 0xff, 0xff, 0xfe, 0x0f, 0xf0, 0x0e, 0x0e, 0xee, 0xe0, 0x0e, 0xee,\
	0xe0, 0x0f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xf0,\
	0x00, 0xff, 0xf0, 0xff, 0xff, 0xf0, 0xe0, 0xee, 0x0f, 0xf0, 0x00, 0x0f,\
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0x00, 0x0f, 0xff, 0xff, 0xff, 0x0f, 0xe0, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0xff, 0xff, 0xff, 0xf0, 0xff, 0xf0, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0xff, 0xf0, 0x0f, 0xff, 0x0f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xf0,\
	0x0e, 0xef, 0xff, 0x0f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x0e, 0xee,\
	0xee, 0xf0, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xf0, 0xee, 0xee, 0xee,\
	0x0f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xf0, 0xe6, 0x6e, 0xe0, 0xff,\
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xf0, 0x6e, 0xe0, 0x0f, 0xff, 0xff,\
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x0f, 0xff, 0xff, 0xff, 0xff,\
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
	0xff, 0xff, 0xff, 0xff, 0xff, PAD0

tetris:	.db \
	0xa2, 0xb4, 0x23, 0xe6, 0x22, 0xb6, 0x70, 0x01, 0xd0, 0x11, 0x30, 0x25, 0x12, 0x06, 0x71, 0xff,\
	0xd0, 0x11, 0x60, 0x1a, 0xd0, 0x11, 0x60, 0x25, 0x31, 0x00, 0x12, 0x0e, 0xc4, 0x70, 0x44, 0x70,\
	0x12, 0x1c, 0xc3, 0x03, 0x60, 0x1e, 0x61, 0x03, 0x22, 0x5c, 0xf5, 0x15, 0xd0, 0x14, 0x3f, 0x01,\
	0x12, 0x3c, 0xd0, 0x14, 0x71, 0xff, 0xd0, 0x14, 0x23, 0x40, 0x12, 0x1c, 0xe7, 0xa1, 0x22, 0x72,\
	0xe8, 0xa1, 0x22, 0x84, 0xe9, 0xa1, 0x22, 0x96, 0xe2, 0x9e, 0x12, 0x50, 0x66, 0x00, 0xf6, 0x15,\
	0xf6, 0x07, 0x36, 0x00, 0x12, 0x3c, 0xd0, 0x14, 0x71, 0x01, 0x12, 0x2a, 0xa2, 0xc4, 0xf4, 0x1e,\
	0x66, 0x00, 0x43, 0x01, 0x66, 0x04, 0x43, 0x02, 0x66, 0x08, 0x43, 0x03, 0x66, 0x0c, 0xf6, 0x1e,\
	0x00, 0xee, 0xd0, 0x14, 0x70, 0xff, 0x23, 0x34, 0x3f, 0x01, 0x00, 0xee, 0xd0, 0x14, 0x70, 0x01,\
	0x23, 0x34, 0x00, 0xee, 0xd0, 0x14, 0x70, 0x01, 0x23, 0x34, 0x3f, 0x01, 0x00, 0xee, 0xd0, 0x14,\
	0x70, 0xff, 0x23, 0x34, 0x00, 0xee, 0xd0, 0x14, 0x73, 0x01, 0x43, 0x04, 0x63, 0x00, 0x22, 0x5c,\
	0x23, 0x34, 0x3f, 0x01, 0x00, 0xee, 0xd0, 0x14, 0x73, 0xff, 0x43, 0xff, 0x63, 0x03, 0x22, 0x5c,\
	0x23, 0x34, 0x00, 0xee, 0x80, 0x00, 0x67, 0x05, 0x68, 0x06, 0x69, 0x04, 0x61, 0x1f, 0x65, 0x10,\
	0x62, 0x07, 0x00, 0xee, 0x40, 0xe0, 0x00, 0x00, 0x40, 0xc0, 0x40, 0x00, 0x00, 0xe0, 0x40, 0x00,\
	0x40, 0x60, 0x40, 0x00, 0x40, 0x40, 0x60, 0x00, 0x20, 0xe0, 0x00, 0x00, 0xc0, 0x40, 0x40, 0x00,\
	0x00, 0xe0, 0x80, 0x00, 0x40, 0x40, 0xc0, 0x00, 0x00, 0xe0, 0x20, 0x00, 0x60, 0x40, 0x40, 0x00,\
	0x80, 0xe0, 0x00, 0x00, 0x40, 0xc0, 0x80, 0x00, 0xc0, 0x60, 0x00, 0x00, 0x40, 0xc0, 0x80, 0x00,\
	0xc0, 0x60, 0x00, 0x00, 0x80, 0xc0, 0x40, 0x00, 0x00, 0x60, 0xc0, 0x00, 0x80, 0xc0, 0x40, 0x00,\
	0x00, 0x60, 0xc0, 0x00, 0xc0, 0xc0, 0x00, 0x00, 0xc0, 0xc0, 0x00, 0x00, 0xc0, 0xc0, 0x00, 0x00,\
	0xc0, 0xc0, 0x00, 0x00, 0x40, 0x40, 0x40, 0x40, 0x00, 0xf0, 0x00, 0x00, 0x40, 0x40, 0x40, 0x40,\
	0x00, 0xf0, 0x00, 0x00, 0xd0, 0x14, 0x66, 0x35, 0x76, 0xff, 0x36, 0x00, 0x13, 0x38, 0x00, 0xee,\
	0xa2, 0xb4, 0x8c, 0x10, 0x3c, 0x1e, 0x7c, 0x01, 0x3c, 0x1e, 0x7c, 0x01, 0x3c, 0x1e, 0x7c, 0x01,\
	0x23, 0x5e, 0x4b, 0x0a, 0x23, 0x72, 0x91, 0xc0, 0x00, 0xee, 0x71, 0x01, 0x13, 0x50, 0x60, 0x1b,\
	0x6b, 0x00, 0xd0, 0x11, 0x3f, 0x00, 0x7b, 0x01, 0xd0, 0x11, 0x70, 0x01, 0x30, 0x25, 0x13, 0x62,\
	0x00, 0xee, 0x60, 0x1b, 0xd0, 0x11, 0x70, 0x01, 0x30, 0x25, 0x13, 0x74, 0x8e, 0x10, 0x8d, 0xe0,\
	0x7e, 0xff, 0x60, 0x1b, 0x6b, 0x00, 0xd0, 0xe1, 0x3f, 0x00, 0x13, 0x90, 0xd0, 0xe1, 0x13, 0x94,\
	0xd0, 0xd1, 0x7b, 0x01, 0x70, 0x01, 0x30, 0x25, 0x13, 0x86, 0x4b, 0x00, 0x13, 0xa6, 0x7d, 0xff,\
	0x7e, 0xff, 0x3d, 0x01, 0x13, 0x82, 0x23, 0xc0, 0x3f, 0x01, 0x23, 0xc0, 0x7a, 0x01, 0x23, 0xc0,\
	0x80, 0xa0, 0x6d, 0x07, 0x80, 0xd2, 0x40, 0x04, 0x75, 0xfe, 0x45, 0x02, 0x65, 0x04, 0x00, 0xee,\
	0xa7, 0x00, 0xf2, 0x55, 0xa8, 0x04, 0xfa, 0x33, 0xf2, 0x65, 0xf0, 0x29, 0x6d, 0x32, 0x6e, 0x00,\
	0xdd, 0xe5, 0x7d, 0x05, 0xf1, 0x29, 0xdd, 0xe5, 0x7d, 0x05, 0xf2, 0x29, 0xdd, 0xe5, 0xa7, 0x00,\
	0xf2, 0x65, 0xa2, 0xb4, 0x00, 0xee, 0x6a, 0x00, 0x60, 0x19, 0x00, 0xee, 0x37, 0x23

test_opcode: .db \
	0x12, 0x4e, 0xea, 0xac, 0xaa, 0xea, 0xce, 0xaa, 0xaa, 0xae, 0xe0, 0xa0, 0xa0, 0xe0, 0xc0, 0x40,\
	0x40, 0xe0, 0xe0, 0x20, 0xc0, 0xe0, 0xe0, 0x60, 0x20, 0xe0, 0xa0, 0xe0, 0x20, 0x20, 0x60, 0x40,\
	0x20, 0x40, 0xe0, 0x80, 0xe0, 0xe0, 0xe0, 0x20, 0x20, 0x20, 0xe0, 0xe0, 0xa0, 0xe0, 0xe0, 0xe0,\
	0x20, 0xe0, 0x40, 0xa0, 0xe0, 0xa0, 0xe0, 0xc0, 0x80, 0xe0, 0xe0, 0x80, 0xc0, 0x80, 0xa0, 0x40,\
	0xa0, 0xa0, 0xa2, 0x02, 0xda, 0xb4, 0x00, 0xee, 0xa2, 0x02, 0xda, 0xb4, 0x13, 0xdc, 0x68, 0x01,\
	0x69, 0x05, 0x6a, 0x0a, 0x6b, 0x01, 0x65, 0x2a, 0x66, 0x2b, 0xa2, 0x16, 0xd8, 0xb4, 0xa2, 0x3e,\
	0xd9, 0xb4, 0xa2, 0x02, 0x36, 0x2b, 0xa2, 0x06, 0xda, 0xb4, 0x6b, 0x06, 0xa2, 0x1a, 0xd8, 0xb4,\
	0xa2, 0x3e, 0xd9, 0xb4, 0xa2, 0x06, 0x45, 0x2a, 0xa2, 0x02, 0xda, 0xb4, 0x6b, 0x0b, 0xa2, 0x1e,\
	0xd8, 0xb4, 0xa2, 0x3e, 0xd9, 0xb4, 0xa2, 0x06, 0x55, 0x60, 0xa2, 0x02, 0xda, 0xb4, 0x6b, 0x10,\
	0xa2, 0x26, 0xd8, 0xb4, 0xa2, 0x3e, 0xd9, 0xb4, 0xa2, 0x06, 0x76, 0xff, 0x46, 0x2a, 0xa2, 0x02,\
	0xda, 0xb4, 0x6b, 0x15, 0xa2, 0x2e, 0xd8, 0xb4, 0xa2, 0x3e, 0xd9, 0xb4, 0xa2, 0x06, 0x95, 0x60,\
	0xa2, 0x02, 0xda, 0xb4, 0x6b, 0x1a, 0xa2, 0x32, 0xd8, 0xb4, 0xa2, 0x3e, 0xd9, 0xb4, 0x22, 0x42,\
	0x68, 0x17, 0x69, 0x1b, 0x6a, 0x20, 0x6b, 0x01, 0xa2, 0x0a, 0xd8, 0xb4, 0xa2, 0x36, 0xd9, 0xb4,\
	0xa2, 0x02, 0xda, 0xb4, 0x6b, 0x06, 0xa2, 0x2a, 0xd8, 0xb4, 0xa2, 0x0a, 0xd9, 0xb4, 0xa2, 0x06,\
	0x87, 0x50, 0x47, 0x2a, 0xa2, 0x02, 0xda, 0xb4, 0x6b, 0x0b, 0xa2, 0x2a, 0xd8, 0xb4, 0xa2, 0x0e,\
	0xd9, 0xb4, 0xa2, 0x06, 0x67, 0x2a, 0x87, 0xb1, 0x47, 0x2b, 0xa2, 0x02, 0xda, 0xb4, 0x6b, 0x10,\
	0xa2, 0x2a, 0xd8, 0xb4, 0xa2, 0x12, 0xd9, 0xb4, 0xa2, 0x06, 0x66, 0x78, 0x67, 0x1f, 0x87, 0x62,\
	0x47, 0x18, 0xa2, 0x02, 0xda, 0xb4, 0x6b, 0x15, 0xa2, 0x2a, 0xd8, 0xb4, 0xa2, 0x16, 0xd9, 0xb4,\
	0xa2, 0x06, 0x66, 0x78, 0x67, 0x1f, 0x87, 0x63, 0x47, 0x67, 0xa2, 0x02, 0xda, 0xb4, 0x6b, 0x1a,\
	0xa2, 0x2a, 0xd8, 0xb4, 0xa2, 0x1a, 0xd9, 0xb4, 0xa2, 0x06, 0x66, 0x8c, 0x67, 0x8c, 0x87, 0x64,\
	0x47, 0x18, 0xa2, 0x02, 0xda, 0xb4, 0x68, 0x2c, 0x69, 0x30, 0x6a, 0x34, 0x6b, 0x01, 0xa2, 0x2a,\
	0xd8, 0xb4, 0xa2, 0x1e, 0xd9, 0xb4, 0xa2, 0x06, 0x66, 0x8c, 0x67, 0x78, 0x87, 0x65, 0x47, 0xec,\
	0xa2, 0x02, 0xda, 0xb4, 0x6b, 0x06, 0xa2, 0x2a, 0xd8, 0xb4, 0xa2, 0x22, 0xd9, 0xb4, 0xa2, 0x06,\
	0x66, 0xe0, 0x86, 0x6e, 0x46, 0xc0, 0xa2, 0x02, 0xda, 0xb4, 0x6b, 0x0b, 0xa2, 0x2a, 0xd8, 0xb4,\
	0xa2, 0x36, 0xd9, 0xb4, 0xa2, 0x06, 0x66, 0x0f, 0x86, 0x66, 0x46, 0x07, 0xa2, 0x02, 0xda, 0xb4,\
	0x6b, 0x10, 0xa2, 0x3a, 0xd8, 0xb4, 0xa2, 0x1e, 0xd9, 0xb4, 0xa3, 0xe8, 0x60, 0x00, 0x61, 0x30,\
	0xf1, 0x55, 0xa3, 0xe9, 0xf0, 0x65, 0xa2, 0x06, 0x40, 0x30, 0xa2, 0x02, 0xda, 0xb4, 0x6b, 0x15,\
	0xa2, 0x3a, 0xd8, 0xb4, 0xa2, 0x16, 0xd9, 0xb4, 0xa3, 0xe8, 0x66, 0x89, 0xf6, 0x33, 0xf2, 0x65,\
	0xa2, 0x02, 0x30, 0x01, 0xa2, 0x06, 0x31, 0x03, 0xa2, 0x06, 0x32, 0x07, 0xa2, 0x06, 0xda, 0xb4,\
	0x6b, 0x1a, 0xa2, 0x0e, 0xd8, 0xb4, 0xa2, 0x3e, 0xd9, 0xb4, 0x12, 0x48, 0x13, 0xdc

test_Fx55: .db \
	0x60, 0x69, 0x61, 0x88, 0x62, 0x12, 0x63, 0x45, 0x64, 0xFF, 0xA2, 0x20, 0xF3, 0x55, 0xF3, 0x33,\
	0xA2, 0x1C, 0xF3, 0x65, 0x12, 0x10
	

	; firmware includes
	.include "system.asm"
	.include "vga.asm"
	;.include "supermario.asm"
	.include "gfx.asm"
	.include "ps2.asm"

	; software includes
	.include "chip8.asm"

ireset:
	cli
	clr	RZERO			; set RZERO to 0
	out	CPU_SREG, RZERO		; clear status register
	stackInit RAMEND, r16		; setup stack at the end of SRAM


startup:
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
	rjmp	_waitclk			; wait for clock to be stable
	
	; set interrupt pointers to void
	ldi	r16, LOW(void)
	ldi	r17, HIGH(void)
	sts	itcb0ptr, r16
	sts	itcb0ptr+1, r17
	sts	itcb1ptr, r16
	sts	itcb1ptr+1, r17

main:	
	call	ps2init
	call	vga_init

	; load frame buffer
	ldi	ZL, LOW(vgafb)
	ldi	ZH, HIGH(vgafb)
	ldi	r16, 0
_lfbloop:
	st	Z+, r16
	inc	r16
	cpi	ZL, LOW(vgafb+9600)
	brne	_lfbloop
	cpi	ZH, HIGH(vgafb+9600)
	brne	_lfbloop


	.if 0
	ldi	r16, 0x00
	mov	r2, r16
	call	clearscreen

	;call	supermario
	call	loadstarters
	ldi	r16, LOW(0x2800+SRAM_START)
	mov	r2, r16
	ldi	r16, HIGH(0x2800+SRAM_START)
	mov	r3, r16
	ldi	r16, 9
	mov	r4, r16
	ldi	r16, 2
	mov	r5, r16
	call	drawstarters
	
	call	loadmew
	ldi	r16, LOW(0x2800+SRAM_START)
	mov	r2, r16
	ldi	r16, HIGH(0x2800+SRAM_START)
	mov	r3, r16
	ldi	r16, 56
	mov	r4, r16
	ldi	r16, 64
	mov	r5, r16
	call	drawstarters
	
	
	call	loadmagicarp
	ldi	r16, LOW(0x2800+SRAM_START)
	mov	r2, r16
	ldi	r16, HIGH(0x2800+SRAM_START)
	mov	r3, r16
	ldi	r16, 1
	mov	r4, r16
	ldi	r16, 64
	mov	r5, r16
	call	drawstarters
	.endif
	
	; load mew
	ldi	r24, LOW(mew)
	mov	r2, r24
	ldi	r24, HIGH(mew)
	mov	r3, r24
	ldi	r24, LOW(RAM_START)
	mov	r4, r24
	ldi	r24, HIGH(RAM_START)
	mov	r5, r24
	ldi	r24, LOW(0x425)
	mov	r6, r24
	ldi	r24, HIGH(0x425)
	mov	r7, r24
	call	sys_copyflash
	; draw mew
	ldi	r24, LOW(RAM_START)
	mov	r2, r24
	ldi	r24, HIGH(RAM_START)
	mov	r3, r24
	ldi	r24, 76
	mov	r5, r24
	ldi	r24, 20
	mov	r4, r24
	call	gfx_drawpimg

	


	ldi	r16, LOW(tetris<<1)
	mov	r2, r16
	ldi	r16, HIGH(tetris<<1)
	mov	r3, r16
	ldi	r16, LOW(494)
	mov	r4, r16
	ldi	r16, HIGH(494)
	mov	r5, r16
	call	ch8_init

	ldi	r16, 8
	mov	r2, r16
	ldi	r16, 28
	mov	r3, r16
	call	ch8_draw_zoom
	sei
	


before_main:
	ldi	r16, 0x29
	mov	r2, r16
	call	ps2consumekey
	mov	r16, r0
	cpi	r16, 0
	breq	before_main

	; load logo
	ldi	r24, LOW(ch8_logo)
	mov	r2, r24
	ldi	r24, HIGH(ch8_logo)
	mov	r3, r24
	ldi	r24, LOW(CH8LOGO)
	mov	r4, r24
	ldi	r24, HIGH(CH8LOGO)
	mov	r5, r24
	ldi	r24, LOW((ch8_logo_end - ch8_logo)*2)
	mov	r6, r24
	ldi	r24, HIGH((ch8_logo_end - ch8_logo)*2)
	mov	r7, r24
	call	sys_copyflash
	; draw logo
	ldi	r16, LOW(CH8LOGO+3)
	mov	r2, r16
	ldi	r16, HIGH(CH8LOGO+3)
	mov	r3, r16
	ldi	r16, 100
	mov	r5, r16
	ldi	r16, 20
	mov	r4, r16
	ldi	r16, 0x5F
	mov	r6, r16
	ldi	r16, 0x12
	mov	r0, r16
	ldi	r16, 0x6
	mov	r1, r16
	call	gfx_drawraw2
	
main_loop:	
	ldi	r16, 0x5A
	mov	r2, r16
	call	ps2readkey
	mov	r16, r0
	cpi	r16, 0
	breq	_main_next

	ldi	r16, 0xE1
	mov	r2, r16
	call	ps2consumekey
	rjmp	_main_next

_main_next:
	jmp	ch8_main
	call	ch8_game_loop

	rjmp	main_loop

end:
	cli				; stop interrupts
	jmp	ireset			; reset machine

infinite:
	rjmp	infinite




