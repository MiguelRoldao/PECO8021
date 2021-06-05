; It's interesting how at TCA CMP, the minimum voltage of PORTD fluctuates
;
; VGA modes:
; 0 - 160x120, 9600 bytes fb
; 1 - 128x96, 6144 bytes fb
; 2 - 80x60, 2400 bytes fb
; 3 - 64x48, 1536 bytes fb
;
; Contains all VGA related code
; 2021 March - MIRO
;; use tab width: 8

	; the following declared registers are exclusive to VGA operation
	.def	RSREG = r11	; backs up the status register
	.def	RVGA0 = r12	; constains the pixels to output
	.def	RVGA1 = r13	; holds data loop iterator
	.def	SRVGA0 = r30	; constains the pixels to output (once swaped)
	.def	SRVGA1 = r31	; holds data loop iterator (once swaped)
	.def	RVGAPTRL = r14
	.def	RVGAPTRH = r15	; used for word instructions and as a ram pointer
	
	.equ	VGAPORT_OUT = VPORTD_OUT
	.equ	HSYNCPORT_OUT = VPORTD_OUT	; hsync port definitions
	.equ	HSYNCPORT_DIR = VPORTD_DIR
	.equ	HSYNCPORT_PIN = 1
	.equ	VSYNCPORT_OUT = VPORTA_OUT	; vsync port definitions
	.equ	VSYNCPORT_DIR = VPORTA_DIR
	.equ	VSYNCPORT_PIN = 2
	
	.equ	VGADATATS = 48-40		; 48 - (time in isr before first out + 6)
	.equ	VGACNTCONST = VGADATATS+14	; expected clock count by timer read (including lds)
	.equ	VGANLINES_0 = 4
	.equ	VGANLINES_1 = 5
	.equ	VGANLINES_2 = 8
	.equ	VGANLINES_3 = 10


	.dseg
i60ptr:	
	.byte	2			; pointer to routine to call @60Hz
vgaisrptr:
	.byte	2			; pointer to current vga mode data isr
vgamode:
	.byte	1			; current mode number
vgawidth:
	.byte	1
vgaheight:
	.byte	1

vgafb:	
	.byte	9600			; VGA frame buffer of 9600 bytes (160*120/2) at start of sram


	.cseg
vgalines:
	.db	4, 5, 8, 10
vgacolumns:
	.db	80, 64, 40, 32
vgarows:
	.db	120, 96, 60, 48
vgaisrs:
	.dw	ivgamode0, ivgamode1, ivgamode2, ivgamode3
vgafbsizes:
	.dw	9600, 6144, 2400, 1536

ivgadata:
	push	XL
	push	XH
	in	RSREG, CPU_SREG			; save status register
	push	r1
	clr	r1
	movw	RVGA1:RVGA0, SRVGA1:SRVGA0	; backup word acessable registers


	; calculate how mancy clock cycles from interrupt request to start of interrupt
	lds	XL, TCA0_SINGLE_CNT
	lds	XH, TCA0_SINGLE_TEMP	; load current value from tca
	sbiw	X, VGACNTCONST
	andi	XL, 0x3
	
	ldi	SRVGA0, LOW(ivganops)		
	ldi	SRVGA1, HIGH(ivganops)
	add	SRVGA0, XL			
	adc	SRVGA1, r1			; add extra clocks to nop table address
ivganopjmp:
	ijmp					; jump to nop table, to waste clk cycles to sync data output
ivganops:
	nop
	nop
	nop
	
	
	lds	SRVGA0, vgaisrptr
	lds	SRVGA1, vgaisrptr+1
	movw	XH:XL, RVGAPTRH:RVGAPTRL
	ijmp
	
; mode-0
ivgamode0:
				ld	r30, X+				; load vram byte
				out	VGAPORT_OUT, r30		; output high nibble
				swap	r30
				ldi	r31, 80-10	
	push	r24
_ivgamode0_loop:
				out	VGAPORT_OUT, r30		; output low nibble
				ld	r30, X+				; load vram byte
				dec	r31				; decrement i
				out	VGAPORT_OUT, r30		; output high nibble
				swap	r30		
				brne	_ivgamode0_loop			; loop while i != 0
_ivgamode0_loop_end:
;;;;;;;;
;				out	VGAPORT_OUT, r30
;				ld	r30, X+
;	nop
;				out	VGAPORT_OUT, r30
;				swap	r30
;	nop
;	nop
;;;;;;;;
	movw	RVGAPTRH:RVGAPTRL, X
				out	VGAPORT_OUT, r30
				ld	r30, X+
	ldi	r24, 9
				out	VGAPORT_OUT, r30
				swap	r30
	add	RVGAPTRL, r24
	adc	RVGAPTRH, r1
				out	VGAPORT_OUT, r30
				ld	r30, X+
	ldi	r24, 0b0_100_000_0
				out	VGAPORT_OUT, r30
				swap	r30
	sts	TCA0_SINGLE_INTFLAGS, r24	; clear interrupt flag
				out	VGAPORT_OUT, r30
				ld	r30, X+
	nop
				out	VGAPORT_OUT, r30
				swap	r30
	in	r31, GPR_GPR2
	ldi	r24, 80
				out	VGAPORT_OUT, r30
				ld	r30, X+
	dec	r31
				out	VGAPORT_OUT, r30
				swap	r30
	breq	_ivgamode0_resetlinecnt
	nop
				out	VGAPORT_OUT, r30
				ld	r30, X+
	nop
				out	VGAPORT_OUT, r30
				swap	r30
	rjmp	_ivgamode0_resetlinedone
_ivgamode0_resetlinecnt:
				out	VGAPORT_OUT, r30
				ld	r30, X+
	ldi	r31, VGANLINES_0
				out	VGAPORT_OUT, r30
				swap	r30
	add	RVGAPTRL, r24
	adc	RVGAPTRH, r1
_ivgamode0_resetlinedone:
				out	VGAPORT_OUT, r30
				ld	r30, X+
	sub	RVGAPTRL, r24
				out	VGAPORT_OUT, r30
				swap	r30
	nop
	nop
				out	VGAPORT_OUT, r30
				ld	r30, X+
	sbc	RVGAPTRH, r1
				out	VGAPORT_OUT, r30
				swap	r30
	pop	r24
				out	VGAPORT_OUT, r30
				ld	r30, X+
	out	GPR_GPR2, r31
				out	VGAPORT_OUT, r30
				swap	r30
	pop	r1
				out	VGAPORT_OUT, r30
				ld	r30, X+
	clr	r31
				out	VGAPORT_OUT, r30
				swap	r30
	pop	XH
				out	VGAPORT_OUT, r30
	out	CPU_SREG, RSREG
	pop	XL
				out	VGAPORT_OUT, r31
	movw	Z, RVGA1:RVGA0
	reti


	
	
	
	
; mode-1
ivgamode1:
				ld	r30, X+
				out	VGAPORT_OUT, r30
				swap	r30
				ldi	r31, 64-6
	push	r24
	ldi	r24, 5
_ivgamode1_loop:
				out	VGAPORT_OUT, r30
				ld	r30, X+
	nop
	nop
				out	VGAPORT_OUT, r30
				swap	r30
				dec	r31
				brne	_ivgamode1_loop
_ivgamode1_loop_end:
	movw	RVGAPTRH:RVGAPTRL, X
				out	VGAPORT_OUT, r30
				ld	r30, X+
	add	RVGAPTRL, r24
	adc	RVGAPTRH, r1
				out	VGAPORT_OUT, r30
				swap	r30
	ldi	r24, 0b0_100_000_0
	sts	TCA0_SINGLE_INTFLAGS, r24	; clear interrupt flag
				out	VGAPORT_OUT, r30
				ld	r30, X+
	in	r31, GPR_GPR2
	ldi	r24, 64
				out	VGAPORT_OUT, r30
				swap	r30
	dec	r31
	breq	_ivgamode1_resetlinecnt
	nop
				out	VGAPORT_OUT, r30
				ld	r30, X+
	nop
	nop
				out	VGAPORT_OUT, r30
				swap	r30
	nop
	nop
	nop
_ivgamode1_resetlinedone:
				out	VGAPORT_OUT, r30
				ld	r30, X+
	sub	RVGAPTRL, r24
	sbc	RVGAPTRH, r1
				out	VGAPORT_OUT, r30
				swap	r30
	out	GPR_GPR2, r31
	mov	r31, r1
	nop
				out	VGAPORT_OUT, r30
				ld	r30, X+
	pop	r24
				out	VGAPORT_OUT, r30
				swap	r30
	pop	r1
	out	CPU_SREG, RSREG
				out	VGAPORT_OUT, r30
	pop	XH
	pop	XL
				out	VGAPORT_OUT, r31
	movw	Z, RVGA1:RVGA0	; restore word acessable registers
	reti


_ivgamode1_resetlinecnt:
				out	VGAPORT_OUT, r30
				ld	r30, X+
	ldi	r31, VGANLINES_1
	add	RVGAPTRL, r24
				out	VGAPORT_OUT, r30
				swap	r30
	adc	RVGAPTRH, r1
	rjmp	_ivgamode1_resetlinedone





; mode-2
ivgamode2:
				ld	r30, X+
				out	VGAPORT_OUT, r30
				swap	r30
				ldi	r31, 40-3
	push	r24
	ldi	r24, 2
_ivgamode2_loop:
	nop
	nop
	nop
				out	VGAPORT_OUT, r30
				ld	r30, X+
	nop
	nop
	nop
	nop
	nop
				out	VGAPORT_OUT, r30
				swap	r30
				dec	r31
				brne	_ivgamode2_loop
_ivgamode2_loop_end:
	movw	RVGAPTRH:RVGAPTRL, X
	add	RVGAPTRL, r24
	adc	RVGAPTRH, r1
	ldi	r24, 0b0_100_000_0
				out	VGAPORT_OUT, r30
				ld	r30, X+
	sts	TCA0_SINGLE_INTFLAGS, r24	; clear interrupt flag
	in	r31, GPR_GPR2
	ldi	r24, 40
	dec	r31
				out	VGAPORT_OUT, r30
				swap	r30
	breq	_ivgamode2_resetlinecnt
	nop
	nop
	nop
	nop
	nop
				out	VGAPORT_OUT, r30
	rjmp	_ivgamode2_resetlinedone
_ivgamode2_resetlinecnt:
	ldi	r31, VGANLINES_2
	add	RVGAPTRL, r24
	adc	RVGAPTRH, r1
	nop
				out	VGAPORT_OUT, r30
	nop
	nop
_ivgamode2_resetlinedone:
				ld	r30, X+
	nop
	nop
	nop
				out	VGAPORT_OUT, r30
				swap	r30
	sub	RVGAPTRL, r24
	sbc	RVGAPTRH, r1
	out	GPR_GPR2, r31
	mov	r31, r1
	pop	r24
				out	VGAPORT_OUT, r30
	pop	r1
	out	CPU_SREG, RSREG
	pop	XH
	pop	XL
				out	VGAPORT_OUT, r31
	movw	Z, RVGA1:RVGA0	; restore word acessable registers
	reti



; mode-3
ivgamode3:
				ld	r30, X+
				out	VGAPORT_OUT, r30
				swap	r30
				ldi	r31, 32-2
	push	r24
	ldi	r24, 1
_ivgamode3_loop:
	nop
	nop
	nop
	nop
	nop
				out	VGAPORT_OUT, r30
				ld	r30, X+
	nop
	nop
	nop
	nop
	nop
	nop
	nop
				out	VGAPORT_OUT, r30
				swap	r30
				dec	r31
				brne	_ivgamode3_loop
_ivgamode3_loop_end:
	movw	RVGAPTRH:RVGAPTRL, X
	add	RVGAPTRL, r24
	adc	RVGAPTRH, r1
	ldi	r24, 0b0_100_000_0
	sts	TCA0_SINGLE_INTFLAGS, r24	; clear interrupt flag
				out	VGAPORT_OUT, r30
				ld	r30, X+
	in	r31, GPR_GPR2
	ldi	r24, 32
	dec	r31
	breq	_ivgamode3_resetlinecnt
	nop
	nop
	nop
				out	VGAPORT_OUT, r30
				swap	r30
	rjmp	_ivgamode3_resetlinedone
_ivgamode3_resetlinecnt:
	ldi	r31, VGANLINES_3
	add	RVGAPTRL, r24
				out	VGAPORT_OUT, r30
				swap	r30
	adc	RVGAPTRH, r1
	nop
_ivgamode3_resetlinedone:
	nop
	nop
	sub	RVGAPTRL, r24
	sbc	RVGAPTRH, r1
	out	GPR_GPR2, r31
	mov	r31, r1
				out	VGAPORT_OUT, r30
	pop	r24
	pop	r1
	out	CPU_SREG, RSREG
	pop	XH
	pop	XL
				out	VGAPORT_OUT, r31
	movw	Z, RVGA1:RVGA0	; restore word acessable registers
	reti






;	.if 0
;ivgadata:
;	push	XL
;	push	XH
;	in	RSREG, CPU_SREG			; save status register
;	movw	RVGA1:RVGA0, SRVGA1:SRVGA0	; backup word acessable registers
;	movw	XH:XL, RVGAPTRH:RVGAPTRL
;
;	; calculate how mancy clock cycles from interrupt request to start of interrupt
;	lds	SRVGA0, TCA0_SINGLE_CNT
;	lds	SRVGA1, TCA0_SINGLE_TEMP	; load current value from tca
;	sbiw	SRVGA1:SRVGA0, VGACNTCONST
;	andi	SRVGA0, 0x3
;	mov 	RVGA2, SRVGA0			; save amount of extra clocks
;	ldi	SRVGA0, LOW(ivganops)		
;	ldi	SRVGA1, HIGH(ivganops)
;	add	SRVGA0, RVGA2			
;	adc	SRVGA1, RZERO			; add extra clocks to nop table address
;ivganopjmp:
;	ijmp					; jump to nop table, to waste clk cycles to sync data output
;ivganops:
;	nop
;	nop
;	nop
;
;
;
;ivgadataloop_start:
;	ld	SRVGA0, X+			; load vram byte
;	out	VGAPORT_OUT, SRVGA0		; output high nibble
;	nop
;	ldi	SRVGA1, 80-1	
;	swap	SRVGA0
;ivgadataloop:
;	out	VGAPORT_OUT, SRVGA0		; output low nibble
;	ld	SRVGA0, X+			; load vram byte
;	dec	SRVGA1				; decrement i
;	out	VGAPORT_OUT, SRVGA0		; output high nibble
;	swap	SRVGA0		
;	brne	ivgadataloop			; loop while i != 0
;ivgadataloop_end:
;	in	SRVGA1, GPR_GPR2		; here to occupy wasted clk
;	out	VGAPORT_OUT, SRVGA0		; output low nibble
;
;	
;	; ensure last pixel is output, and clear bus
;	dec	SRVGA1				; here to occupy wasted clk
;	movw	RVGAPTRH:RVGAPTRL, XH:XL	; here to occupy wasted clk
;	ldi	SRVGA0, 0
;	out	VGAPORT_OUT, SRVGA0		
;
;	; keep track of amount of repeated lines (up to 5) and adjust X acordingly
;	;in	SRVGA0, GPR_GPR2		; placed above
;	;dec	SRVGA0				; placed above
;	ldi	SRVGA0, 80			
;	brne	_ivgastorelinecnt
;	ldi	SRVGA1, VGANLINES
;	add	RVGAPTRL, SRVGA0
;	adc	RVGAPTRH, RZERO
;_ivgastorelinecnt:
;	sub	RVGAPTRL, SRVGA0
;	sbc	RVGAPTRH, RZERO
;	out	GPR_GPR2, SRVGA1
;
;	; clear flags, and restore registers
;	ldi	SRVGA0, 0b0_100_000_0
;	sts	TCA0_SINGLE_INTFLAGS, SRVGA0	; clear interrupt flag
;
;
;	;movw	RVGAPTRH:RVGAPTRL, XH:XL	; placed above
;	movw	SRVGA1:SRVGA0, RVGA1:RVGA0	; restore word acessable registers	
;	out	CPU_SREG, RSREG			; restore status register
;	pop	XH
;	pop	XL
;	reti
;	.endif
;	.if 0
; mode-0
;ivgadataloop_start:
;	ld	SRVGA0, X+			; load vram byte
;	out	VGAPORT_OUT, SRVGA0		; output high nibble
;	nop
;	ldi	SRVGA1, 80-1	
;	swap	SRVGA0
;ivgadataloop:
;	out	VGAPORT_OUT, SRVGA0		; output low nibble
;	ld	SRVGA0, X+			; load vram byte
;	dec	SRVGA1				; decrement i
;	out	VGAPORT_OUT, SRVGA0		; output high nibble
;	swap	SRVGA0		
;	brne	ivgadataloop			; loop while i != 0
;ivgadataloop_end:
;	in	SRVGA1, GPR_GPR2		; here to occupy wasted clk
;	out	VGAPORT_OUT, SRVGA0		; output low nibble
;
;	
;	; ensure last pixel is output, and clear bus
;	dec	SRVGA1				; here to occupy wasted clk
;	movw	RVGAPTRH:RVGAPTRL, XH:XL	; here to occupy wasted clk
;	ldi	SRVGA0, 0
;	out	VGAPORT_OUT, SRVGA0		
;
;	; keep track of amount of repeated lines (up to 5) and adjust X acordingly
;	;in	SRVGA0, GPR_GPR2		; placed above
;	;dec	SRVGA0				; placed above
;	ldi	SRVGA0, 80			
;	brne	_ivgastorelinecnt
;	ldi	SRVGA1, VGANLINES_0
;	add	RVGAPTRL, SRVGA0
;	adc	RVGAPTRH, r1
;_ivgastorelinecnt:
;	sub	RVGAPTRL, SRVGA0
;	sbc	RVGAPTRH, r1
;	out	GPR_GPR2, SRVGA1
;
;	; clear flags, and restore registers
;	ldi	SRVGA0, 0b0_100_000_0
;	sts	TCA0_SINGLE_INTFLAGS, SRVGA0	; clear interrupt flag
;
;
;	;movw	RVGAPTRH:RVGAPTRL, XH:XL	; placed above
;	movw	SRVGA1:SRVGA0, RVGA1:RVGA0	; restore word acessable registers	
;	out	CPU_SREG, RSREG			; restore status register
;	pop	r1
;	pop	XH
;	pop	XL
;	reti
;	.endif



; VGA vertical clock interrupt routine
; This interrupt is called whenever TCB overflows so instead of timing
; it by setting the top value we change the CNT value.
ivgavsync:
	push	r16
	in	r16, CPU_SREG
	push	r16
	push	r30
	push	r31
	push	r1
	clr	r1
	
	in	r16, GPR_GPR3
	andi	r16, 0x03		; get v-sync state
	
	ldi	r30, LOW(_ivgavsyncjmptable)
	ldi	r31, HIGH(_ivgavsyncjmptable)
	add	r30, r16
	brcc	_ivgavsyncijmp		; if not carry skip inc
	inc	r31			; add state to compute which part of the routine to execute
_ivgavsyncijmp:
	ijmp				
	; values in r16, r30 and r31 are no longer relevant
	; 6 + 14 + 0/1/2/3 clocks until here
_ivgavsyncjmptable:
	rjmp	_ivgavsyncs0
	rjmp	_ivgavsyncs1
	rjmp	_ivgavsyncs2
	rjmp	_ivgavsyncs3
	; 22 + 0/1/2/3 clocks

	; for some reason the v-sync signal needs to happen 4 vertical lines before the standard spec. TOO BAD
_ivgavsyncs0:	;transition to front porch (TA)
	lds	r16, TCA0_SINGLE_INTCTRL
	andi	r16, 0b1_011_111_1
	sts	TCA0_SINGLE_INTCTRL, r16	; disable interrupt for vga data
	
	sbi	GPR_GPR3, 0
	cbi	GPR_GPR3, 1			; set next state to 1
	; 30 + 0/1/2/3 clocks until here
	

	ldi	r30, 0x09-4
	ldi	r31, 0x00
	sts	TCB2_TEMP, r30
	sts	TCB2_CCMPH, r31			; set counter to count 1 event (0x10000 - 0x01 = 0xFFFF)

	lds	ZL, i60ptr
	lds	ZH, i60ptr+1
	icall					; call 60 Hz function
	
	rjmp	_ivgavsyncend

_ivgavsyncs1:	;transition to sync (TB)
	cbi	VSYNCPORT_OUT, VSYNCPORT_PIN	; set output low (PORTA0)

	cbi	GPR_GPR3, 0
	sbi	GPR_GPR3, 1			; set next state to 2

	ldi	r30, 0x01
	ldi	r31, 0x00
	sts	TCB2_TEMP, r30
	sts	TCB2_CCMPH, r31			; set counter to count 4 events (0x10000 - 0x04 = 0xFFFC)
	
	rjmp	_ivgavsyncend

_ivgavsyncs2:	;transition to back porch (TC)
	sbi	VSYNCPORT_OUT, VSYNCPORT_PIN	; set output high (PORTA0)

	sbi	GPR_GPR3, 0
	sbi	GPR_GPR3, 1			; set next state to 3
	
	ldi	r30, 0x20+4			
	ldi	r31, 0x00
	sts	TCB2_TEMP, r30
	sts	TCB2_CCMPH, r31			; set counter to count 23 events (0x10000 - 0x17 = 0xFFE9)
	
	rjmp	_ivgavsyncend

_ivgavsyncs3:	;transition to visible area (TD)
	lds	r16, TCA0_SINGLE_INTCTRL
	ori	r16, 0b0_100_000_0
	sts	TCA0_SINGLE_INTCTRL, r16	; enable interrupt for vga data	
	

	; for some reason, showing the flash makes the vga draw routine buggy (first line before buffer is white)
	ldi	r16, LOW(vgafb);+6785-10)
	mov	RVGAPTRL, r16
	ldi	r16, HIGH(vgafb);+6785-10)
	mov	RVGAPTRH, r16			; reset frame buffer pointer

	cbi	GPR_GPR3, 0
	cbi	GPR_GPR3, 1		; set next state to 0
	
	ldi	ZL, LOW(vgalines<<1)
	ldi	ZH, HIGH(vgalines<<1)
	lds	r16, vgamode
	add	ZL, r16
	adc	ZH, r1
	lpm	r16, Z
	out	GPR_GPR2, r16		; reset pixel line counter

	
	ldi	r30, 0xDF
	ldi	r31, 0x01
	sts	TCB2_TEMP, r30
	sts	TCB2_CCMPH, r31			; set counter to count 480 events (0x1E0 - 0x1 = 0x1DF)


	;rjmp	_ivgavsyncend			; fall-through
	
_ivgavsyncend:
	sts	TCB2_TEMP, RZERO
	sts	TCB2_CNTH, RZERO

	ldi	r16, 0b000000_0_1
	sts	TCB2_INTFLAGS, r16

	pop	r1
	pop	r31
	pop	r30
	pop	r16
	out	CPU_SREG, r16
	pop	r16
	
	reti
	




vga_init:
	push	r16
	push 	r17

	; vga horizontal sync in TCA0
	; CMP0: inc v_sync timer through event
	; CMP1: use for PWM wave generation (h_sync signal)
	; CMP2: request vga data output ISR
	ldi	r16, 0x1F
	ldi	r17, 0x03			; 800 - 1
	sts	TCA0_SINGLE_TEMP, r16
	sts	TCA0_SINGLE_PER+1, r17		; set top value for 800 pixels

	; setup CMP0
	ldi	r16, 0x19
	ldi	r17, 0x00			; 48 - 1 - 22 (CMP0 ISR takes at least 22 clks until output op)
	sts	TCA0_SINGLE_TEMP, r16		; set cmp value for 53 pixels
	sts	TCA0_SINGLE_CMP0+1, r17		; will generate event to increment v_sync
	
	; setup CMP1
	ldi	r16, 0b0_010_0_011			
	sts	TCA0_SINGLE_CTRLB, r16		; CMP1 output waveform, single-slope pwm mode

	ldi	r16, 0xBF
	ldi	r17, 0x02			; 704 - 1
	sts	TCA0_SINGLE_TEMP, r16		; set cmp value for 704 pixels
	sts	TCA0_SINGLE_CMP1+1, r17		; will generate PWM wave for h_sync
	
	ldi	r16, 0x03
	sts	PORTMUX_TCAROUTEA, r16		; output h_sync to PD1
	sbi	HSYNCPORT_DIR, HSYNCPORT_PIN	; set PD1 as output

	; setup CMP2
	ldi	r16, 0b_0_100_000_0
	sts	TCA0_SINGLE_INTCTRL, r16	; enable interrupt for vga data

	ldi	r16, VGADATATS-1
	ldi	r17, 0x00			; 17 - 1
	sts	TCA0_SINGLE_TEMP, r16		; set cmp value for 17 pixels
	sts	TCA0_SINGLE_CMP2+1, r17		; will generate interrupt request for data


	; vga vertical sync
	sbi	VSYNCPORT_DIR, VSYNCPORT_PIN	; set PA2 as output


	ldi	r16, LOW(vgafb);+32)
	mov	RVGAPTRL, r16
	ldi	r16, HIGH(vgafb);+32)
	mov	RVGAPTRH, r16			; reset frame buffer pointer

	cbi	GPR_GPR3, 0
	cbi	GPR_GPR3, 1			; set next state to 0

	ldi	r16, LOW(void)
	ldi	r17, HIGH(void)
	sts	i60ptr, r16
	sts	i60ptr+1, r17			; setup pointer to void on i60 call
	
	ldi	r16, 0xE0
	ldi	r17, 0x01
	sts	TCB2_TEMP, r16
	sts	TCB2_CCMPH, r17			; set counter to count 2 events (0x10000 - 0x258 = 0xFDA8)

	ldi	r16, 0b0_0_0_0_111_1
	sts	TCB2_CTRLA, r16			; TCB2 is clocked from events
	
	ldi	r16, 0b000000_0_1
	sts	TCB2_INTCTRL, r16		; enable capture interrupt
	

	


	; setup event channel from tca0 to TCB2
	ldi	r16, 0x84			
	sts	EVSYS_CHANNEL0, r16		; TCA0 CMP0_LCMP0

	ldi	r16, 0x01
	sts	EVSYS_USERTCB2COUNT, r16	; connect ch0 to TCB2count event input
	

	ldi	r16, 1<<TCA_SINGLE_ENABLE_bp
	lds	r17, TCB2_CTRLA
	ori	r17, 0b0_0_0_0_000_1
	sts	TCA0_SINGLE_CTRLA, r16		; enable timer TCA0
	sts	TCB2_CTRLA, r17			; enable timer TCB2


	; setput vga data port
	sbi	VPORTD_DIR, 7			; set PA2 as output
	sbi	VPORTD_DIR, 6			; set PA2 as output
	sbi	VPORTD_DIR, 5			; set PA2 as output
	sbi	VPORTD_DIR, 4			; set PA2 as output

	ldi	r16, 0x0D
	sts	CPUINT_LVL1VEC, r16
	
	; set vga mode 0
	clr	r2
	rcall	vga_setmode
	
	ldi	r16, VGANLINES_0
	out	GPR_GPR2, r16			; reset pixel line counter
	

	pop	r17
	pop	r16
	ret

;; Arguments
; r2: mode
vga_setmode:
	push	ZL
	push	ZH
	push	r16
	push	r17
	push	r18
	push	r19
	
	ldi	r18, 0b00000011
	and	r2, r18				; mask the argument to prevent undefined behaviour
	
	ldi	ZL, LOW(vgacolumns<<1)
	ldi	ZH, HIGH(vgacolumns<<1)
	add	ZL, r2
	adc	ZH, r1				; load Z to point to correct data isr pointer
	
	lpm	r18, Z				; load screen width
	adiw	Z, 4
	
	lpm	r19, Z				; load screen height
	adiw	Z, 4
	
	add	ZL, r2
	adc	ZH, r1				; load Z to point to correct data isr pointer
	
	lpm	r16, Z+
	lpm	r17, Z+				; load corresponding data isr pointer
	
	ldi	ZL, LOW(vgaisrptr)
	ldi	ZH, HIGH(vgaisrptr)		; prepare Z with sram pointer
	
	cli
	st	Z+, r16				; store low byte of data isr pointer
	st	Z+, r17				; store high byte of data isr pointer
	st	Z+, r2				; store vga mode
	st	Z+, r18
	st	Z+, r19
	sei
	
	pop	r19
	pop	r18
	pop	r17
	pop	r16
	pop	ZH
	pop	ZL
	ret












