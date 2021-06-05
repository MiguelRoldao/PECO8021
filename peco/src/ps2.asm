; All input procedures are handled whithin this file
; No Host to Device communication capabilities
;
; 2021 April - MIRO
;; use tab width: 8	

	.equ	PS2FLAGS = GPR_GPR3
	.equ	PS2FLAG_EXTENDED = 3
	.equ	PS2FLAG_RELEASE = 2
	;.equ	ps2buf = vgafb+120


	; US keyboard definitions
	.equ	KEY_A = 0x1C
	.equ	KEY_B = 0x32
	.equ	KEY_C = 0x21
	.equ	KEY_D = 0x23
	.equ	KEY_E = 0x24
	.equ	KEY_F = 0x2B
	.equ	KEY_G = 0x34
	.equ	KEY_H = 0x33
	.equ	KEY_I = 0x43
	.equ	KEY_J = 0x3B
	.equ	KEY_K = 0x42
	.equ	KEY_L = 0x4B
	.equ	KEY_M = 0x3A
	.equ	KEY_N = 0x31
	.equ	KEY_O = 0x44
	.equ	KEY_P = 0x4D
	.equ	KEY_Q = 0x15
	.equ	KEY_R = 0x2D
	.equ	KEY_S = 0x1B
	.equ	KEY_T = 0x2C
	.equ	KEY_U = 0x3C
	.equ	KEY_V = 0x2A
	.equ	KEY_W = 0x1D
	.equ	KEY_X = 0x22
	.equ	KEY_Y = 0x35
	.equ	KEY_Z = 0x1A

	.equ	KEY_0 = 0x45
	.equ	KEY_1 = 0x16
	.equ	KEY_2 = 0x1E
	.equ	KEY_3 = 0x26
	.equ	KEY_4 = 0x25
	.equ	KEY_5 = 0x2E
	.equ	KEY_6 = 0x36
	.equ	KEY_7 = 0x3D
	.equ	KEY_8 = 0x3E
	.equ	KEY_9 = 0x46

	.equ	KEY_TICK = 0x0E
	.equ	KEY_HYPHEN = 0x4E
	.equ	KEY_EQUALS = 0x55
	.equ	KEY_BRACKETOPEN = 0x54
	.equ	KEY_BRACKETCLOSE = 0x5B
	.equ	KEY_BACKSLASH = 0x5D
	.equ	KEY_SEMICOLON = 0x4C
	.equ	KEY_APOSTROPHE = 0x52
	.equ	KEY_COMMA = 0x41
	.equ	KEY_DOT = 0x49
	.equ	KEY_FORWARDSLASH = 0x4A

	.equ	KEY_SHIFTL = 0x12
	.equ	KEY_SHIFTR = 0x59
	.equ	KEY_ALTL = 0x11
	.equ	KEY_ALTR = 0x91
	.equ	KEY_CTRLL = 0x14
	.equ	KEY_CTRLR = 0x94
	.equ	KEY_GUIL = 0x9F
	.equ	KEY_GUIR = 0xA7
	.equ	KEY_ENTER = 0x5A
	.equ	KEY_BACKSPACE = 0x66
	.equ	KEY_ESCAPE = 0x76
	.equ	KEY_TAB = 0x0D
	.equ	KEY_SPACE = 0x29

	.equ	KEY_LOCKCAPS = 0x58
	.equ	KEY_LOCKNUM = 0x77
	.equ	KEY_LOCKSCROLL = 0x7E

	.equ	KEY_F1 = 0x05
	.equ	KEY_F2 = 0x06
	.equ	KEY_F3 = 0x04
	.equ	KEY_F4 = 0x0C
	.equ	KEY_F5 = 0x03
	.equ	KEY_F6 = 0x0B
	.equ	KEY_F7 = 0x83
	.equ	KEY_F8 = 0x0A
	.equ	KEY_F9 = 0x01
	.equ	KEY_F10 = 0x09
	.equ	KEY_F11 = 0x78
	.equ	KEY_F12 = 0x07
	
	.equ	KEY_BREAK = 0xE1
	.equ	KEY_INSERT = 0xF0
	.equ	KEY_DELETE = 0xF1
	.equ	KEY_HOME = 0xEC
	.equ	KEY_END = 0xE9
	.equ	KEY_PAGEUP = 0xFD
	.equ	KEY_PAGEDOWN = 0xFA
	.equ	KEY_UP = 0xF5
	.equ	KEY_RIGHT = 0xF4
	.equ	KEY_LEFT = 0xEB
	.equ	KEY_DOWN = 0xF2

	.equ	KEY_POWER = 0xB7
	.equ	KEY_SLEEP = 0xBF
	.equ	KEY_WAKEUP = 0xDE
	
	.equ	KEY_NP0 = 0x70
	.equ	KEY_NP1 = 0x69
	.equ	KEY_NP2 = 0x72
	.equ	KEY_NP3 = 0x7A
	.equ	KEY_NP4 = 0x6B
	.equ	KEY_NP5 = 0x73
	.equ	KEY_NP6 = 0x74
	.equ	KEY_NP7 = 0x6C
	.equ	KEY_NP8 = 0x75
	.equ	KEY_NP9 = 0x7D
	.equ	KEY_NPSLASH = 0xCA
	.equ	KEY_NPASTERISC = 0x7C
	.equ	KEY_NPHYPHEN = 0x7B
	.equ	KEY_NPPLUS = 0x79
	.equ	KEY_NPDOT = 0x71
	.equ	KEY_NPENTER = 0xDA

	.equ	KEY_WWWSEARCH = 0x90
	.equ	KEY_WWWFAVOURITES = 0x97
	.equ	KEY_WWWREFRESH = 0xA0
	.equ	KEY_WWWSTOP = 0xA8
	.equ	KEY_WWWFORWARD = 0xB0
	.equ	KEY_WWWBACK = 0xB8
	.equ	KEY_WWWHOME = 0xBA

	.equ	KEY_VOLUMEUP = 0xB2
	.equ	KEY_VOLUMEDOWN = 0xA1
	.equ	KEY_MUTE = 0xA3
	.equ	KEY_CALCULATOR = 0xAB
	.equ	KEY_APPS = 0xAF
	.equ	KEY_PLAYPAUSE = 0xB4
	.equ	KEY_STOP = 0xBB
	.equ	KEY_MYPC = 0xC0
	.equ	KEY_EMAIL = 0xC8
	.equ	KEY_NEXTTRACK = 0xCD
	.equ	KEY_PREVIOUSTRACK = 0x95
	.equ	KEY_MEDIASELECT = 0xD0

	
	; PT keyboard definitions
	.equ	KEY_PTBACKSLASH = 0x0E
	.equ	KEY_PTSMALLER = 0x61
	.equ	KEY_PTHYPHEN = 0x4A
	.equ	KEY_PTCCEDILHA = 0x4C
	.equ	KEY_PTORDINAL = 0x52
	.equ	KEY_PTPLUS = 0x54
	.equ	KEY_PTTICK = 0x5B
	.equ	KEY_PTAPOSTROPHE = 0x4E
	.equ	KEY_PTQUOTE = 0x55
	.equ	KEY_PTTILDE = 0x5D



	.dseg
;ps2ptr:	.byte	2
ps2buf:	.byte	32
	.cseg

ps2init:
	push	r16
	push	ZL
	push	ZH
	
	; setup usart module
	ldi	r16, 0b1000_1_000			; RX Complete ISR and Loop-back Mode
	sts	USART0_CTRLA, r16
	ldi	r16, 0b1000_1_000			; RX enable and open drain
	sts	USART0_CTRLB, r16
	ldi	r16, 0b01_11_0_011		; SYNC, ODD parity, 1 Sp, 8bit
	sts	USART0_CTRLC, r16
	ldi	r16, 0b00_00_00_01		; usart to pins: P4-P7
	sts	PORTMUX_USARTROUTEA, r16
	
	; setup clock pin
	ldi	r16, 0b0_0_00_1_000		; ~invert and enable pullup
	sts	PORTA_PIN6CTRL, r16
	ldi	r16, 0b01000000			; set xck as input
	sts	PORTA_DIRCLR, r16
	; setup data pin
	ldi	r16, 0b0_0_00_1_000		; enable pullup
	sts	PORTA_PIN4CTRL, r16

	; clr ps2buf
	ldi	ZL, LOW(ps2buf)
	ldi	ZH, HIGH(ps2buf)
	ldi	r16, 32
_ps2initclrloop:
	st	Z+, r1
	dec	r16
	brne	_ps2initclrloop
		
	pop	ZH
	pop	ZL
	pop	r16
	ret






ips2rx:
	push	r16
	in	r16, CPU_SREG
	push	r16
	push	r17
	push	ZL
	push	ZH
	push	r1
	clr	r1

	lds	r17, USART0_RXDATAH		; load flags
	lds	r16, USART0_RXDATAL		; load data
	andi	r17, 0x7F
	brne	_ips2rxend			; if error flags are set, end procedure

	cpi	r16, 0x84				; if r16 <= 0x83: dont jmp
	brcc	_ips2rxspecial

_ips2rxdata:
	; process data
	mov	r17, r16
	sbic	PS2FLAGS, PS2FLAG_EXTENDED	; if extended: access 2nd half of ram buffer
	ori	r17, 0b10000000
	lsr	r17
	lsr	r17
	lsr	r17
	andi	r16, 0b00000111			; r17 contains ram offset, r16 the bit position 
	
	ldi	ZL, LOW(maskb<<1)
	ldi	ZH, HIGH(maskb<<1)
	add	ZL, r16
	adc	ZH, r1
	lpm	r16, Z				; compute bitmask
	
	ldi	ZL, LOW(ps2buf)
	ldi	ZH, HIGH(ps2buf)
	add	ZL, r17
	adc	ZH, r1
	ld	r17, Z				; load correct buffer byte

	sbic	PS2FLAGS, PS2FLAG_RELEASE	; if release: clear, else: set
	rjmp	_ips2rxclear
_ips2rxset:
	or	r16, r17
	rjmp	_ips2rxstore
_ips2rxclear:
	com	r16
	and	r16, r17
_ips2rxstore:
	st	Z, r16
	cbi	PS2FLAGS, PS2FLAG_RELEASE
	cbi	PS2FLAGS, PS2FLAG_EXTENDED

_ips2rxend:
	pop	r1
	pop	ZH
	pop	ZL
	pop	r17
	pop	r16
	out	CPU_SREG, r16
	pop	r16
	reti

_ips2rxspecial:
	cpi	r16, 0xF0
	breq	_ips2rxrelease				; if r16 == 0xF0: branch
	cpi	r16, 0xE0				; if r16 == 0xE0: branch
	breq	_ips2rxextended
	cpi	r16, 0xE1				; if r16 == 0xE1: branch
	breq	_ips2rxpausekey

	rjmp	_ips2rxend

_ips2rxpausekey:
	cbi	PS2FLAGS, PS2FLAG_RELEASE
	cbi	PS2FLAGS, PS2FLAG_EXTENDED
	rjmp	_ips2rxdata

_ips2rxrelease:
	sbi	PS2FLAGS, PS2FLAG_RELEASE
	rjmp	_ips2rxend

_ips2rxextended:
	sbi	PS2FLAGS, PS2FLAG_EXTENDED
	cbi	PS2FLAGS, PS2FLAG_RELEASE
	rjmp	_ips2rxend



;; read ps2 buffer
; Arguments:
;	r2 - scancode of key to read
;	r3(0) - if set, clear buffer
; Return;
;	r0 - 0: if not pressed
ps2consumekey:					; sets consume flag before reading buffer
	push	r16
	ldi	r16, 0b00000001
	or	r3, r16				; always clear buffer
	rjmp	_ps2readbuffer
ps2readkey:					; clears consume flag before reading buffer
	push	r16
	ldi	r16, 0b11111110
	and	r3, r16				; dont clear buffer
	rjmp	_ps2readbuffer
ps2readbuffer:
	push	r16
_ps2readbuffer:
	push	ZL
	push	ZH
	
	mov	r16, r2
	mov	r4, r2
	lsr	r4
	lsr	r4
	lsr	r4
	andi	r16, 0b00000111
	
	ldi	ZL, LOW(maskb<<1)
	ldi	ZH, HIGH(maskb<<1)
	add	ZL, r16
	adc	ZH, r1
	lpm	r0, Z				; compute bitmask
	
	ldi	ZL, LOW(ps2buf)
	ldi	ZH, HIGH(ps2buf)
	add	ZL, r4
	adc	ZH, r1
	ld	r4, Z				; load correct buffer byte
	
	and	r0, r4
	
	sbrs	r3, 0
	rjmp	_ps2readbuffer_end		; if r3(0) is clear skip to end
	mov	r16, r0
	com	r16
	and	r4, r16
	st	Z, r4				; clear read key flag
_ps2readbuffer_end:
	pop	ZH
	pop	ZL
	pop	r16
	ret







;	; setup TCB1 to drive the clock line low 
;	ldi	r16, 0x6			; single-shot mode
;	sts	TCB1_CTRLB, r16
;	ldi	r16, 0x57
;	ldi	r17, 0x62
;	sts	TCB1_TEMP, r16
;	sts	TCB1_CCMPH, r17			; set timer for 1000 us
;	sts	TCB1_TEMP, r16
;	sts	TCB1_CNTH, r17			; set cnt to top value to avoid false trigger
;	ldi	r16, 0b0_0_0_0_000_1
;	sts	TCB1_EVCTRL, r16		; no filter, + edge, enable input event
;	ldi	r16, 0b0_0_0_0_000_1
;	sts	TCB1_CTRLA, r16			; clk_per, enable timer
;	ldi	r16, 0b000000_0_1
;	sts	TCB1_INTCTRL, r16		; capture interrupt
;	sts	TCB1_INTFLAGS, r16		; clear false trigger int flag
;	
;	ldi	r16, 1+1
;	sts	EVSYS_USERTCB1CAPT, r16		; event channel 1 to TCB1 start



;ps2preptx:
;	ldi	r16, 0b00_00_00_11		; unroute USART0
;	sts	PORTMUX_USARTROUTEA, r16
;
;	; allow data line high
;	ldi	r16, 0b00010000			; set data as input
;	sts	PORTA_DIRCLR, r16		
;
;	; drive clock line low
;	cbi	VPORTA_OUT, 6
;	ldi	r16, 0b01000000			; set xck as output
;	sts	PORTA_DIRSET, r16
;
;	; send event to start TCB1
;	ldi	r16, 1<<1
;	sts	EVSYS_SWEVENTA, r16
;
;	; 
;	
;	rjmp	_ips2rxend
;
;ips2tx0:
;	push	r16
;	push	ZL
;	push	ZH
;	
;	; drive data line low
;	cbi	VPORTA_OUT, 6
;	ldi	r16, 0b00010000			; set data as output
;	sts	PORTA_DIRSET, r16
;
;	; release clock line
;	ldi	r16, 0b00010000			; set xck as input
;	sts	PORTA_DIRCLR, r16
;	ldi	r16, 0b00_00_00_01		; route USART0 back to P4-P7
;	sts	PORTMUX_USARTROUTEA, r16
;
;	
;	ldi	r16, 0b00000001
;	sts	TCB1_INTFLAGS, r16
;	
;	pop	ZH
;	pop	ZL
;	pop	r16
;	reti

