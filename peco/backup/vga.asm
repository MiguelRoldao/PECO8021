; It's interasting how at TCA CMP, the minimum voltage of PORTD
;
; Contains all VGA related code
; 2021 March - MIRO
;; use tab width: 8

	; the following declared registers are exclusive to VGA operation
	.def	RSREG = r13	; backs up the status register
	.def	RVGA0 = r14	; constains the pixels to output
	.def	RVGA1 = r15	; holds data loop iterator
	.def	RVGA2 = r12	; variable for vga calculations
	.def	SRVGA0 = r30	; constains the pixels to output (once swaped)
	.def	SRVGA1 = r31	; holds data loop iterator (once swaped)
	;.def	RVGAPTR = R27:R26	; used for word instructions and as a ram pointer
	
	.equ	VGAPORT_OUT = VPORTD_OUT
	.equ	HSYNCPORT_OUT = VPORTD_OUT	; hsync port definitions
	.equ	HSYNCPORT_DIR = VPORTD_DIR
	.equ	HSYNCPORT_PIN = 1
	.equ	VSYNCPORT_OUT = VPORTA_OUT	; vsync port definitions
	.equ	VSYNCPORT_DIR = VPORTA_DIR
	.equ	VSYNCPORT_PIN = 2
	
	.equ	VGADATATS = 48-28	; 48 - (time in isr before first out + 6)
	.equ	VGACNTCONST = VGADATATS+10	; expected clock count by timer read (including lds)
	.equ	VGANLINES = 4


	.dseg
	.org	SRAM_START
vgafb:	.byte	9600			; VGA frame buffer of 9600 bytes (160*120/2) at start of sram

	.cseg


ivgadata:
	in	RSREG, CPU_SREG			; save status register
	movw	RVGA1:RVGA0, SRVGA1:SRVGA0	; backup word acessable registers

	; calculate how mancy clock cycles from interrupt request to start of interrupt
	lds	SRVGA0, TCA0_SINGLE_CNT
	lds	SRVGA1, TCA0_SINGLE_TEMP	; load current value from tca
	sbiw	SRVGA1:SRVGA0, VGACNTCONST
	andi	SRVGA0, 0x3
	mov 	RVGA2, SRVGA0			; save amount of extra clocks
	ldi	SRVGA0, LOW(ivganops)		
	ldi	SRVGA1, HIGH(ivganops)
	add	SRVGA0, RVGA2			
	adc	SRVGA1, RZERO			; add extra clocks to nop table address
ivganopjmp:
	ijmp					; jump to nop table, to waste clk cycles to sync data output
ivganops:
	nop
	nop
	nop


ivgadataloop_start:
	ld	SRVGA0, X+			; load vram byte
	out	VGAPORT_OUT, SRVGA0		; output high nibble
	nop
	ldi	SRVGA1, 80-1	
	swap	SRVGA0
ivgadataloop:
	out	VGAPORT_OUT, SRVGA0		; output low nibble
	ld	SRVGA0, X+			; load vram byte
	dec	SRVGA1				; decrement i
	out	VGAPORT_OUT, SRVGA0		; output high nibble
	swap	SRVGA0		
	brne	ivgadataloop			; loop while i != 0
ivgadataloop_end:
	in	SRVGA1, GPR_GPR2		; here to occupy wasted clk
	out	VGAPORT_OUT, SRVGA0		; output low nibble

	
	; ensure last pixel is output, and clear bus
	dec	SRVGA1				; here to occupy wasted clk
	nop
	ldi	SRVGA0, 0
	out	VGAPORT_OUT, SRVGA0		

	; keep track of amount of repeated lines (up to 5) and adjust X acordingly
	;in	SRVGA0, GPR_GPR2		; placed above
	;dec	SRVGA0				; placed above
	ldi	SRVGA0, 80			
	brne	_ivgastorelinecnt
	ldi	SRVGA1, VGANLINES
	add	XL, SRVGA0
	adc	XH, RZERO
_ivgastorelinecnt:
	sub	XL, SRVGA0
	sbc	XH, RZERO
	out	GPR_GPR2, SRVGA1

	; clear flags, and restore registers
	ldi	SRVGA0, 0b0_100_000_0
	sts	TCA0_SINGLE_INTFLAGS, SRVGA0	; clear interrupt flag

	movw	SRVGA1:SRVGA0, RVGA1:RVGA0	; restore word acessable registers	
	out	CPU_SREG, RSREG			; restore status register
	
	reti



; VGA vertical clock interrupt routine
; This interrupt is called whenever TCB overflows so instead of timing
; it by setting the top value we change the CNT value.
ivgavsync:
	push	r16
	in	r16, CPU_SREG
	push	r16
	push	r30
	push	r31
	
	in	r16, GPR_GPR3
	andi	r16, 0x03		; get v-sync state
	
	ldi	r30, LOW(_ivgavsyncjmptable)
	ldi	r31, HIGH(_ivgavsyncjmptable)
	add	r30, r16
	BRCC	_ivgavsyncijmp		; if not carry skip inc
	inc	r31			; add state to compute which part of the routine to execute
_ivgavsyncijmp:
	ijmp				
	; values in r16, r30 and r31 are no longer relevant
	; 6 + 18 + 0/1/2/3 clocks until here
_ivgavsyncjmptable:
	rjmp	_ivgavsyncs0
	rjmp	_ivgavsyncs1
	rjmp	_ivgavsyncs2
	rjmp	_ivgavsyncs3
	; +2 clocks

	; for some reason the v-sync signal needs to happen 4 vertical lines before the standard spec. TOO BAD
_ivgavsyncs0:	;transition to front porch (TA)
	lds	r16, TCA0_SINGLE_INTCTRL
	andi	r16, 0b1_011_111_1
	sts	TCA0_SINGLE_INTCTRL, r16	; disable interrupt for vga data
	
	sbi	GPR_GPR3, 0
	cbi	GPR_GPR3, 1			; set next state to 1
	; 28 + 1/2/3 clocks until here
	

	ldi	r30, 0x09-4
	ldi	r31, 0x00
	sts	TCB0_TEMP, r30
	sts	TCB0_CCMPH, r31			; set counter to count 1 event (0x10000 - 0x01 = 0xFFFF)
	
	rjmp	_ivgavsyncend

_ivgavsyncs1:	;transition to sync (TB)
	cbi	VSYNCPORT_OUT, VSYNCPORT_PIN	; set output low (PORTA0)

	cbi	GPR_GPR3, 0
	sbi	GPR_GPR3, 1			; set next state to 2

	ldi	r30, 0x01
	ldi	r31, 0x00
	sts	TCB0_TEMP, r30
	sts	TCB0_CCMPH, r31			; set counter to count 4 events (0x10000 - 0x04 = 0xFFFC)
	
	rjmp	_ivgavsyncend

_ivgavsyncs2:	;transition to back porch (TC)
	sbi	VSYNCPORT_OUT, VSYNCPORT_PIN	; set output high (PORTA0)

	sbi	GPR_GPR3, 0
	sbi	GPR_GPR3, 1			; set next state to 3
	
	ldi	r30, 0x20+4			
	ldi	r31, 0x00
	sts	TCB0_TEMP, r30
	sts	TCB0_CCMPH, r31			; set counter to count 23 events (0x10000 - 0x17 = 0xFFE9)
	
	rjmp	_ivgavsyncend

_ivgavsyncs3:	;transition to visible area (TD)
	lds	r16, TCA0_SINGLE_INTCTRL
	ori	r16, 0b0_100_000_0
	sts	TCA0_SINGLE_INTCTRL, r16	; enable interrupt for vga data	
	
	ldi	XL, LOW(vgafb)		; for some reason (+6) works. Should need it tho. TOO BAD
	ldi	XH, HIGH(vgafb)			; reset frame buffer pointer

	cbi	GPR_GPR3, 0
	cbi	GPR_GPR3, 1		; set next state to 0

	ldi	r16, VGANLINES
	out	GPR_GPR2, r16		; reset pixel line counter

	
	ldi	r30, 0xDF
	ldi	r31, 0x01
	sts	TCB0_TEMP, r30
	sts	TCB0_CCMPH, r31			; set counter to count 2 events (0x10000 - 0x258 = 0xFDA8)


	;rjmp	_ivgavsyncend			; fall-through
	
_ivgavsyncend:
	sts	TCB0_TEMP, RZERO
	sts	TCB0_CNTH, RZERO

	ldi	r16, 0b000000_0_1
	sts	TCB0_INTFLAGS, r16

	pop	r31
	pop	r30
	pop	r16
	out	CPU_SREG, r16
	pop	r16
	
	reti
	




setupvga:
	push	r16
	push 	r17

	; vga horizontal sync in TCA0
	; CMP0: inc v_sync timer through event
	; CMP1: use for PWM wave generation (h_sync signal)
	; TODO: CMP2: request vga data output ISR
	ldi	r16, 0x1F
	ldi	r17, 0x03			; 634 - 1
	sts	TCA0_SINGLE_TEMP, r16
	sts	TCA0_SINGLE_PER+1, r17		; set top value for 634 pixels

	; setup CMP0
	ldi	r16, 0x1D
	ldi	r17, 0x00			; 53 - 1 - 20 (CMP0 ISR takes 20 clks until output op) TODO: check new clk cycles of isr
	sts	TCA0_SINGLE_TEMP, r16		; set cmp value for 53 pixels
	sts	TCA0_SINGLE_CMP0+1, r17		; will generate event to increment v_sync
	
	; setup CMP1
	ldi	r16, 0b0_010_0_011			
	sts	TCA0_SINGLE_CTRLB, r16		; CMP1 output waveform, single-slope pwm mode

	ldi	r16, 0xBF
	ldi	r17, 0x02			; 557 - 1
	sts	TCA0_SINGLE_TEMP, r16		; set cmp value for 557 pixels
	sts	TCA0_SINGLE_CMP1+1, r17		; will generate PWM wave for h_sync
	
	ldi	r16, 0x03
	sts	PORTMUX_TCAROUTEA, r16		; output h_sync to PD1
	sbi	HSYNCPORT_DIR, HSYNCPORT_PIN	; set PD1 as output

	; setup CMP2
	ldi	r16, 0b_0_100_000_0
	sts	TCA0_SINGLE_INTCTRL, r16	; enable interrupt for vga data

	ldi	r16, VGADATATS-1
	ldi	r17, 0x00			; 27 - 1
	sts	TCA0_SINGLE_TEMP, r16		; set cmp value for 27 pixels
	sts	TCA0_SINGLE_CMP2+1, r17		; will generate interrupt request for data

	ldi	r16, VGANLINES
	out	GPR_GPR2, r16			; reset pixel line counter

	; vga vertical sync
	ldi	r30, 0xE0
	ldi	r31, 0x01
	sts	TCB0_TEMP, r30
	sts	TCB0_CCMPH, r31			; set counter to count 2 events (0x10000 - 0x258 = 0xFDA8)

	ldi	r16, 0b0_0_0_0_111_1
	sts	TCB0_CTRLA, r16			; TCB0 is clocked from events
	
	ldi	r16, 0b000000_0_1
	sts	TCB0_INTCTRL, r16		; enable capture interrupt
	
	sbi	VSYNCPORT_DIR, VSYNCPORT_PIN	; set PA2 as output


	ldi	XL, LOW(vgafb)
	ldi	XH, HIGH(vgafb)			; reset frame buffer pointer

	cbi	GPR_GPR3, 0
	cbi	GPR_GPR3, 1			; set next state to 0
	


	; setup event channel from tca0 to tcb0
	ldi	r16, 0x84			
	sts	EVSYS_CHANNEL0, r16		; TCA0 CMP0_LCMP0

	ldi	r16, 0x01
	sts	EVSYS_USERTCB0COUNT, r16	; connect ch0 to tcb0count event input
	

	ldi	r16, 1<<TCA_SINGLE_ENABLE_bp
	lds	r17, TCB0_CTRLA
	ori	r17, 0b0_0_0_0_000_1
	sts	TCA0_SINGLE_CTRLA, r16		; enable timer TCA0
	sts	TCB0_CTRLA, r17			; enable timer TCB0


	; setput vga data port
	sbi	VPORTD_DIR, 7			; set PA2 as output
	sbi	VPORTD_DIR, 6			; set PA2 as output
	sbi	VPORTD_DIR, 5			; set PA2 as output
	sbi	VPORTD_DIR, 4			; set PA2 as output

	ldi	r16, 0x0D
	sts	CPUINT_LVL1VEC, r16

	pop	r17
	pop	r16
	ret

	

