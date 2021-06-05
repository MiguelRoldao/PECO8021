
; CHIP8 emulator for AVR
;
; - CH8FLAGS0
; 0: is menu active
; 1: if set, draw screen
; 2: is debug mode active
; 3:
; 4:
; 5:
; 6:
; 7:

	.def	CH8OPL = r24
	.def	CH8OPH = r25
	.def	CH8OPBKL = r22
	.def	CH8OPBKH = r23
	
	; Memory definitions
	.equ	CH8RAMSTART = RAM_START
	.equ	CH8FB = CH8RAMSTART + 0x000
	.equ	CH8V0 = CH8RAMSTART + 0x100
	.equ	CH8V1 = CH8RAMSTART + 0x101
	.equ	CH8V2 = CH8RAMSTART + 0x102
	.equ	CH8V3 = CH8RAMSTART + 0x103
	.equ	CH8V4 = CH8RAMSTART + 0x104
	.equ	CH8V5 = CH8RAMSTART + 0x105
	.equ	CH8V6 = CH8RAMSTART + 0x106
	.equ	CH8V7 = CH8RAMSTART + 0x107
	.equ	CH8V8 = CH8RAMSTART + 0x108
	.equ	CH8V9 = CH8RAMSTART + 0x109
	.equ	CH8VA = CH8RAMSTART + 0x10A
	.equ	CH8VB = CH8RAMSTART + 0x10B
	.equ	CH8VC = CH8RAMSTART + 0x10C
	.equ	CH8VD = CH8RAMSTART + 0x10D
	.equ	CH8VE = CH8RAMSTART + 0x10E
	.equ	CH8VF = CH8RAMSTART + 0x10F
	.equ	CH8IL = CH8RAMSTART + 0x110
	.equ	CH8IH = CH8RAMSTART + 0x111
	.equ	CH8PCL = CH8RAMSTART + 0x112
	.equ	CH8PCH = CH8RAMSTART + 0x113		; contains PC [0x200, 0xFFF]
	.equ	CH8SP = CH8RAMSTART + 0x114
	.equ	CH8DT = CH8RAMSTART + 0x115
	.equ	CH8ST = CH8RAMSTART + 0x116
	.equ	CH8RESERVED0 = CH8RAMSTART + 0x117
	.equ	CH8CHARRAM = CH8RAMSTART + 0x118
	.equ	CH8PALETTE = CH8RAMSTART + 0x168
	.equ	CH8FC = CH8RAMSTART + 0x169		; frame counter not required by chip8 standards
	.equ	CH8IC = CH8RAMSTART + 0x16A		; instruction counter not required by chip8 standards
	.equ	CH8POSX = CH8RAMSTART + 0x16B		; display x position [0..80]
	.equ	CH8POSY = CH8RAMSTART + 0x16C		; display y position [0..120]
	.equ	CH8FLAGS0 = CH8RAMSTART + 0x16D		; emulator flags
	.equ	CH8VAR0 = CH8RAMSTART + 0x16E
	.equ	CH8VAR1 = CH8RAMSTART + 0x16F
	.equ	CH8STACK = CH8RAMSTART + 0x170
	.equ	CH8SPACE = CH8RAMSTART + 0x200

	.equ	CH8LOGO = CH8RAMSTART + 0x1000
	.equ	CH8FONT = CH8LOGO + (ch8_logo_end - ch8_logo)*2



	
	; Menu definitions
	.equ	CH8MENUOPTIONS = 4

	.cseg
ch8_menu_str_emulator:
	.db	"Emulator", 0, PAD0
ch8_menu_str_paused:
	.db	"Paused", 0, PAD0
ch8_menu_str_resume:
	.db	" Resume ", 0, PAD0
ch8_menu_str_load:
	.db	" Load ", 0, PAD0
ch8_menu_str_debug:
	.db	" Debug ", 0
ch8_menu_str_exit:
	.db	" Exit ", 0, PAD0
	
ch8_debug_str_debugger:
	.db	"Debugger", 0, PAD0
ch8_debug_str_help:
	.db	"F5:Reset", '\n', "F6:Continue", '\n', "F7:Pause", '\n', "F8:Step", 0
ch8_debug_str_pc:
	.db	"PC", 0, PAD0
ch8_debug_str_next:
	.db	"Next", 0, PAD0
ch8_debug_str_video:
	.db	"Video", 0
ch8_debug_str_emu:
	.db	"Emu.", 0, PAD0
ch8_debug_str_memory:
	.db	"Memory", 0, PAD0


ch8_logo: .db \
	0x02, 0x24, 0x06, 0x3d, 0xb7, 0xbc, 0x03, 0xc7, 0xdb, 0x7b, 0xe4, 0x66, 0x61, 0xf3, 0x36, 0x77,\
	0xe6, 0x1f, 0x33, 0xee, 0x66, 0x7d, 0xb7, 0xbc, 0x27, 0xe3, 0xdb, 0x7b, 0x00, 0x3c
ch8_logo_end:

ch8_menupal:
	.db	0x05, 0x0F, 0x0B, 0x00

	
ch8div2:
	.db	0b10000000, 0b01000000, 0b00100000, 0b00010000, \
		0b00001000, 0b00000100, 0b00000010, 0b00000001
ch8_charset:
	.db	0xF9, 0x99, 0xF2, 0x62, 0x27, \
		0xF1, 0xF8, 0xFF, 0x1F, 0x1F, \
		0x99, 0xF1, 0x1F, 0x8F, 0x1F, \
		0xF8, 0xF9, 0xFF, 0x12, 0x44, \
		0xF9, 0xF9, 0xFF, 0x9F, 0x1F, \
		0xF9, 0xF9, 0x9E, 0x9E, 0x9E, \
		0xF8, 0x88, 0xFE, 0x99, 0x9E, \
		0xF8, 0xF8, 0xFF, 0x8F, 0x88


;
;	+---+---+---+---+	+---+---+---+---+
;	| 1 | 2 | 3 | 4 |	| 1 | 2 | 3 | C |
;	+---+---+---+---+	+---+---+---+---+
;	| Q | W | E | R |	| 4 | 5 | 6 | D |
;	+---+---+---+---+  <--	+---+---+---+---+
;	| A | S | D | F |	| 7 | 8 | 9 | E |
;	+---+---+---+---+	+---+---+---+---+
;	| Z | X | C | V |	| A | 0 | B | F |
;	+---+---+---+---+	+---+---+---+---+
;
ch8_keyscancodes:
	.db	0x22, 0x16, 0x1E, 0x26, 0x15, 0x1D, 0x24, 0x1C,\
		0x1B, 0x23, 0x1A, 0x21, 0x25, 0x2D, 0x2B, 0x2A


;; Arguments
; r2 - game pointer low
; r3 - game pointer high
; r4 - game size in bytes low
; r5 - game size in bytes high
ch8_init:
	push	r24
	push	r25
	
	rcall	ch8_reset
	
	; clear vga fb
	;clr	r2
	;call	gfx_clearscreen
	
	; use i60ptr to update timers @60Hz
	ldi	r24, LOW(i60ch8)
	ldi	r25, HIGH(i60ch8)
	sts	i60ptr, r24
	sts	i60ptr+1, r25
	
	; initialize screen
	ldi	r24, 0
	ldi	r25, 28
	sts	CH8POSX, r24
	sts	CH8POSY, r25

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

	; load system font
	ldi	r24, LOW(sys_font)
	mov	r2, r24
	ldi	r24, HIGH(sys_font)
	mov	r3, r24
	ldi	r24, LOW(CH8FONT)
	mov	r4, r24
	ldi	r24, HIGH(CH8FONT)
	mov	r5, r24
	ldi	r24, LOW(SYSFONTSIZE)
	mov	r6, r24
	ldi	r24, HIGH(SYSFONTSIZE)
	mov	r7, r24
	call	sys_copyflash
	; set font pointer
	ldi	r24, LOW(CH8FONT)
	mov	r2, r24
	ldi	r24, HIGH(CH8FONT)
	mov	r3, r24
	call	sys_setfont
	
	pop	r25
	pop	r24
	ret


ch8_reset:
	push	r24
	push	r25
	push	ZL
	push	ZH
	push	YL
	push	YH
	
	; clear chip8 ram
	ldi	r24, LOW(4096)
	ldi	r25, HIGH(4096)				; load iterator
	ldi	ZL, LOW(CH8RAMSTART)
	ldi	ZH, HIGH(CH8RAMSTART)			; load pointer to start of ch8 ram
_ch8_reset_clear_loop:
	st	Z+, r1
	sbiw	r24, 1
	brne	_ch8_reset_clear_loop
	
	; load charset sprites to RAM
	ldi	r24, 40					; load iterator (16 * 5 / 2)
	ldi	ZL, LOW(ch8_charset<<1)
	ldi	ZH, HIGH(ch8_charset<<1)		; load pointer to start of char ROM
	ldi	YL, LOW(CH8CHARRAM)
	ldi	YH, HIGH(CH8CHARRAM)			; load pointer to start of char RAM
_ch8_reset_char_loop:
	lpm	r25, Z+
	mov	r0, r25
	andi	r25, 0xF0
	st	Y+, r25
	mov	r25, r0
	swap	r25
	andi	r25, 0xF0
	st	Y+, r25
	dec	r24
	brne	_ch8_reset_char_loop
	
	ldi	r24, LOW(tetris<<1)
	mov	r2, r24
	ldi	r24, HIGH(tetris<<1)
	mov	r3, r24
	ldi	r24, LOW(494)
	mov	r4, r24
	ldi	r24, HIGH(494)
	mov	r5, r24
	; TODO: copy game from SD to ram
	mov	ZL, r2;LOW(tetris)
	mov	ZH, r3;HIGH(tetris)
	ldi	YL, LOW(CH8SPACE)
	ldi	YH, HIGH(CH8SPACE)
	mov	r24, r4;LOW(494)
	mov	r25, r5;HIGH(494)
_ch8_reset_copy_loop:
	lpm	r0, Z+
	st	Y+, r0
	sbiw	r24, 1
	brne	_ch8_reset_copy_loop
	
	; load palette
	ldi	r24, 0x0F				; black and white
	sts	CH8PALETTE, r24
	
	; initialize stack pointer
	ldi	r24, 0x00
	ldi	r25, 0x02
	sts	CH8PCL, r24
	sts	CH8PCH, r25
	
	pop	YH
	pop	YL
	pop	ZH
	pop	ZL
	pop	r25
	pop	r24
	ret




i60ch8:
	push	r16
	lds	r16, CH8FC
	cpi	r16, 0x4
	breq	_i60ch8_dt
	inc	r16
	sts	CH8FC, r16				; increment frame counter
_i60ch8_dt:						; process Delay Timer
	lds	r16, CH8DT
	cpi	r16, 0
	breq	_i60ch8_st				; if dt != 0: dt -= 1
	dec	r16
	sts	CH8DT, r16
_i60ch8_st:						; process Sound Timer
	lds	r16, CH8ST
	cpi	r16, 0
	breq	_i60ch8_end				; if st != 0: st -= 1
	dec	r16
	sts	CH8ST, r16
_i60ch8_end:
	pop	r16
	ret



ch8_draw_line_offset:
	.db	48, 32, 8, 0
ch8_draw:
	push	ZL
	push	ZH
	push	YL
	push	YH
	push	r16					; data from ch8 frame buffer
	push	r17					; data from vga frame buffer
	push	r18					; color 0
	push	r19					; color 1
	push	r20					; pixel iterator
	push	r21					; ch8 frame buffer byte iterator
	push	r22
	push	r23
	
	ldi	ZL, LOW(ch8_draw_line_offset<<1)
	ldi	ZH, HIGH(ch8_draw_line_offset<<1)
	lds	r23, vgamode
	add	ZL, r23
	adc	ZH, r1
	lpm	r23, Z					; r23 has n bytes to inc after drawing 1 line
	
	lds	r2, CH8POSX
	lds	r3, CH8POSY
	
	ldi	ZL, LOW(CH8FB)
	ldi	ZH, HIGH(CH8FB)				; load chip8 frame buffer pointer
	
	ldi	YL, LOW(vgafb)
	ldi	YH, HIGH(vgafb)				; load vga frame buffer pointer
	add	YL, r2
	adc	YH, RZERO
	lds	r16, vgawidth
	mul	r16, r3
	add	YL, r0
	adc	YH, r1					; offset vga frame buffer pointer
	clr	r1
	
	lds	r18, CH8PALETTE
	mov	r19, r18
	swap	r18
	andi	r18, 0x0F
	andi	r19, 0x0F				; color 0 on r18, color 1 on r19

	ldi	r22, 32					; 32 rows
ch8_y_loop:
	
	ldi	r21, 8					; 8*4*2=64 columns
ch8_x_loop:
	ld	r16, Z+
	
	; pixel loop
	ldi	r20, 4
ch8_draw_pixel_loop:
	lsl	r16					; get next bit
	brcs	ch8_draw_loop_px1_c1			; draw color according to palette
ch8_draw_loop_px1_c0:
	mov	r17, r18
	rjmp	ch8_draw_loop_px1_done
ch8_draw_loop_px1_c1:
	mov	r17, r19
ch8_draw_loop_px1_done:
	swap	r17
	lsl	r16					; get next bit
	brcs	ch8_draw_loop_px0_c1			; draw color according to palette
ch8_draw_loop_px0_c0:
	or	r17, r18
	rjmp	ch8_draw_loop_px0_done
ch8_draw_loop_px0_c1:
	or	r17, r19
ch8_draw_loop_px0_done:
	st	Y+, r17					; store 2 pixels to vgafb
	dec	r20
	brne	ch8_draw_pixel_loop

	dec	r21
	brne	ch8_x_loop
	
	;adiw	Y, 48
	add	YL, r23
	adc	YH, r1
	dec	r22
	brne	ch8_y_loop
	

	pop	r23
	pop	r22
	pop	r21
	pop	r20
	pop	r19
	pop	r18
	pop	r17
	pop	r16
	pop	YH
	pop	YL
	pop	ZH
	pop	ZL
	ret

;; No arguments
ch8_draw_zoom:
	push	ZL
	push	ZH
	push	YL
	push	YH
	push	r16					; data from ch8 frame buffer
	push	r17					; data from vga frame buffer
	push	r18					; color 0
	push	r19					; color 1
	push	r20					; pixel iterator
	push	r21					; ch8 frame buffer byte iterator
	push	r22
	push	r23
	
	lds	r23, vgamode
	inc	r23
	andi	r23, 1
	ldi	r22, 16
	mul	r23, r22
	mov	r23, r0
	clr	r1


	lds	r2, CH8POSX
	lds	r3, CH8POSY
	
	ldi	ZL, LOW(CH8FB)
	ldi	ZH, HIGH(CH8FB)				; load chip8 frame buffer pointer
	
	ldi	YL, LOW(vgafb)
	ldi	YH, HIGH(vgafb)				; load vga frame buffer pointer
	add	YL, r2
	adc	YH, RZERO
	lds	r16, vgawidth
	mul	r16, r3
	add	YL, r0
	adc	YH, r1					; offset vga frame buffer pointer
	clr	r1
	
	lds	r18, CH8PALETTE
	mov	r19, r18
	swap	r18
	andi	r18, 0x0F
	andi	r19, 0x0F				; color 0 on r18, color 1 on r19

	ldi	r22, 32*2				; 32 * 2 rows
ch8_zoom_y_loop:
	
	ldi	r21, 8					; 8*8*2=128 columns
ch8_zoom_x_loop:
	ld	r16, Z+
	
	; pixel loop
	ldi	r20, 8
ch8_zoom_pixel_loop:
	lsl	r16					; get next bit
	brcs	ch8_zoom_pixel_c1				; draw color according to palette
ch8_zoom_pixel_c0:
	mov	r17, r18
	swap	r17
	or	r17, r18
	rjmp	ch8_zoom_pixel_done
ch8_zoom_pixel_c1:
	mov	r17, r19
	swap	r17
	or	r17, r19
ch8_zoom_pixel_done:

	st	Y+, r17					; store 2 pixels to vgafb
	dec	r20
	brne	ch8_zoom_pixel_loop

	dec	r21
	brne	ch8_zoom_x_loop
	
	;adiw	Y, 16
	add	YL, r23
	adc	YH, r1
	sbrs	r22, 0
	sbiw	Z, 8
	dec	r22
	brne	ch8_zoom_y_loop
	
	pop	r23
	pop	r22
	pop	r21
	pop	r20
	pop	r19
	pop	r18
	pop	r17
	pop	r16
	pop	YH
	pop	YL
	pop	ZH
	pop	ZL
	ret

;; Arguments
; r2
ch8_game_loop:
	push	r16

	lds	r16, CH8IC
	cpi	r16, 8
	brcc	_ch8_game_loop_draw
	inc	r16
	sts	CH8IC, r16		; do 8 instructions every frame (8 * 60 = 480 Hz)

	rcall	ch8_op

_ch8_game_loop_draw:
	lds	r16, CH8FC
	cpi	r16, 1
	brcs	_ch8_game_loop_end
	sts	CH8FC, RZERO
	sts	CH8IC, RZERO		; cap draw screen @ 60 Hz

	rcall	ch8_draw

_ch8_game_loop_end:
	pop	r16
	ret

	
ch8_prepare_menu_view:
	push	r16
	
	ldi	r16, 0b00000011
	sts	CH8FLAGS0, r16

	; set vga mode 2
	ldi	r16, 2
	mov	r2, r16
	call	vga_setmode
	
	ldi	ZL, LOW(ch8_menupal<<1)
	ldi	ZH, HIGH(ch8_menupal<<1)
	lpm	r2, Z

	call	gfx_clearscreen
	
	; set game play position,
	ldi	r16, 4
	sts	CH8POSX, r16
	ldi	r16, 9
	sts	CH8POSY, r16

	; draw logo
	ldi	r16, LOW(CH8LOGO)
	mov	r2, r16
	ldi	r16, HIGH(CH8LOGO)
	mov	r3, r16
	ldi	r16, 1
	mov	r5, r16
	ldi	r16, 1
	mov	r4, r16
	ldi	r16, 0x5F
	mov	r6, r16
	call	gfx_drawpimg
	
	; print paused
	ldi	r16, LOW(ch8_menu_str_paused<<1)
	mov	r2, r16
	ldi	r16, HIGH(ch8_menu_str_paused<<1)
	mov	r3, r16
	ldi	r16, 1
	mov	r5, r16
	ldi	r16, 24
	mov	r4, r16
	ldi	r16, 0x5F
	mov	r6, r16
	call	sys_print_prog

	rcall	ch8_draw
	
	pop	r16
	ret


ch8_prepare_game_view:
	push	r16
		
	ldi	r16, 0b00000010
	sts	CH8FLAGS0, r16
	mov	r2, r1
	call	gfx_clearscreen
	
	; set vga mode 3
	ldi	r16, 3
	mov	r2, r16
	call	vga_setmode

	
	; set game play position,
	ldi	r16, 0
	sts	CH8POSX, r16
	ldi	r16, 8
	sts	CH8POSY, r16

	rcall	ch8_draw
	
	pop	r16
	ret

	
ch8_main:
	lds	r17, CH8FLAGS0
	; if debug: goto debugger
	sbrc	r17, 2
	rjmp	_ch8_main_debug

	; if inMenu: dont play
	sbrc	r17, 0
	rjmp	_ch8_main_menu
	
	; if Escape pressed toggle menu view
	ldi	r16, KEY_ESCAPE
	mov	r2, r16
	call	ps2consumekey
	mov	r16, r0
	cpi	r16, 0
	breq	_ch8_main_escape_done
	rcall	ch8_prepare_menu_view
	rjmp	ch8_main
_ch8_main_escape_done:
	
	rcall	ch8_game_loop
	rjmp	ch8_main
	
_ch8_main_menu:
	; if Escape pressed toggle menu view
	ldi	r16, KEY_ESCAPE
	mov	r2, r16
	call	ps2consumekey
	mov	r16, r0
	cpi	r16, 0
	breq	_ch8_main_menu_left
	rcall	ch8_prepare_game_view
	rjmp	ch8_main

_ch8_main_menu_left:
	; if Left not pressed skip
	ldi	r16, KEY_LEFT
	mov	r2, r16
	call	ps2consumekey
	mov	r16, r0
	cpi	r16, 0
	breq	_ch8_main_menu_right
	
	lds	r16, CH8FLAGS0
	sbr	r16, 0b00000010
	sts	CH8FLAGS0, r16				; set menu draw flag
	
	lds	r16, CH8VAR0
	subi	r16, 1
	andi	r16, 0x03
	sts	CH8VAR0, r16				; sub 1 and come around
	
_ch8_main_menu_right:
	; if Right not pressed skip
	ldi	r16, KEY_RIGHT
	mov	r2, r16
	call	ps2consumekey
	mov	r16, r0
	cpi	r16, 0
	breq	_ch8_main_menu_up
	
	lds	r16, CH8FLAGS0
	sbr	r16, 0b00000010
	sts	CH8FLAGS0, r16				; set menu draw flag
	
	lds	r16, CH8VAR0
	inc	r16
	andi	r16, 0x03
	sts	CH8VAR0, r16				; add 1 and come around
	
_ch8_main_menu_up:
	; if Up not pressed skip
	ldi	r16, KEY_UP
	mov	r2, r16
	call	ps2consumekey
	mov	r16, r0
	cpi	r16, 0
	breq	_ch8_main_menu_down
	
	lds	r16, CH8FLAGS0
	sbr	r16, 0b00000010
	sts	CH8FLAGS0, r16				; set menu draw flag
	
	lds	r16, CH8VAR0
	subi	r16, 2
	andi	r16, 0x03
	sts	CH8VAR0, r16				; sub 2 and come around
	
_ch8_main_menu_down:
	; if Down not pressed skip
	ldi	r16, KEY_DOWN
	mov	r2, r16
	call	ps2consumekey
	mov	r16, r0
	cpi	r16, 0
	breq	_ch8_main_menu_enter
	
	lds	r16, CH8FLAGS0
	sbr	r16, 0b00000010
	sts	CH8FLAGS0, r16				; set menu draw flag
	
	lds	r16, CH8VAR0
	inc	r16
	inc	r16
	andi	r16, 0x03
	sts	CH8VAR0, r16				; add 2 and come around
	
_ch8_main_menu_enter:
	; if Enter not pressed skip
	ldi	r16, KEY_ENTER
	mov	r2, r16
	call	ps2consumekey
	mov	r16, r0
	cpi	r16, 0
	breq	_ch8_main_menu_draw
	
	lds	r16, CH8VAR0
	ldi	ZL, LOW(_ch8_main_menu_options)
	ldi	ZH, HIGH(_ch8_main_menu_options)
	add	ZL, r16
	adc	ZH, RZERO
	ijmp
	
_ch8_main_menu_draw:
	lds	r16, CH8FLAGS0
	sbrs	r16, 1
	rjmp	ch8_main
	andi	r16, 0b11111101
	sts	CH8FLAGS0, r16
	
	ldi	r17, 0x5F
	
	; print option resume
	ldi	r16, LOW(ch8_menu_str_resume<<1)
	mov	r2, r16
	ldi	r16, HIGH(ch8_menu_str_resume<<1)
	mov	r3, r16
	ldi	r16, 42
	mov	r5, r16
	ldi	r16, 5
	mov	r4, r16
	mov	r6, r17
	lds	r16, CH8VAR0
	cpi	r16, 0
	brne	_ch8_main_menu_draw_resume
	swap	r6
_ch8_main_menu_draw_resume:
	call	sys_print_prog
	
	; print option load game
	ldi	r16, LOW(ch8_menu_str_load<<1)
	mov	r2, r16
	ldi	r16, HIGH(ch8_menu_str_load<<1)
	mov	r3, r16
	ldi	r16, 42
	mov	r5, r16
	ldi	r16, 23
	mov	r4, r16
	mov	r6, r17
	lds	r16, CH8VAR0
	cpi	r16, 1
	brne	_ch8_main_menu_draw_load
	swap	r6
_ch8_main_menu_draw_load:
	call	sys_print_prog
	
	; print option debug
	ldi	r16, LOW(ch8_menu_str_debug<<1)
	mov	r2, r16
	ldi	r16, HIGH(ch8_menu_str_debug<<1)
	mov	r3, r16
	ldi	r16, 51
	mov	r5, r16
	ldi	r16, 5
	mov	r4, r16
	mov	r6, r17
	lds	r16, CH8VAR0
	cpi	r16, 2
	brne	_ch8_main_menu_draw_debug
	swap	r6
_ch8_main_menu_draw_debug:
	call	sys_print_prog
	
	; print option debug
	ldi	r16, LOW(ch8_menu_str_exit<<1)
	mov	r2, r16
	ldi	r16, HIGH(ch8_menu_str_exit<<1)
	mov	r3, r16
	ldi	r16, 51
	mov	r5, r16
	ldi	r16, 23
	mov	r4, r16
	mov	r6, r17
	lds	r16, CH8VAR0
	cpi	r16, 3
	brne	_ch8_main_menu_draw_exit
	swap	r6
_ch8_main_menu_draw_exit:
	call	sys_print_prog
	
	rjmp	ch8_main
	
_ch8_main_menu_options:
	rjmp	_ch8_main_menu_option_resume
	rjmp	_ch8_main_menu_option_load
	rjmp	_ch8_main_menu_option_debug
	rjmp	_ch8_main_menu_option_exit

_ch8_main_menu_option_resume:
	rcall	ch8_prepare_game_view
	rjmp	ch8_main
_ch8_main_menu_option_load:
	rjmp	ch8_main
_ch8_main_menu_option_debug:
	rcall	_ch8_main_debug_init
	rjmp	ch8_main
_ch8_main_menu_option_exit:
	jmp	end


_ch8_main_debug_init:
	push	r16
	
	ldi	r16, 0b00000111
	sts	CH8FLAGS0, r16

	; set vga mode 0
	clr	r2
	call	vga_setmode
	
	ldi	ZL, LOW(ch8_menupal<<1)
	ldi	ZH, HIGH(ch8_menupal<<1)
	lpm	r2, Z

	call	gfx_clearscreen
	
	; set game play position,
	ldi	r16, 1
	sts	CH8POSX, r16
	ldi	r16, 86
	sts	CH8POSY, r16

	; draw logo
	ldi	r16, LOW(CH8LOGO)
	mov	r2, r16
	ldi	r16, HIGH(CH8LOGO)
	mov	r3, r16
	ldi	r16, 1
	mov	r5, r16
	ldi	r16, 1
	mov	r4, r16
	ldi	r16, 0x5F
	mov	r6, r16
	call	gfx_drawpimg
	
	; print "debugger"
	ldi	r16, LOW(ch8_debug_str_debugger<<1)
	mov	r2, r16
	ldi	r16, HIGH(ch8_debug_str_debugger<<1)
	mov	r3, r16
	ldi	r16, 20
	mov	r4, r16
	ldi	r16, 1
	mov	r5, r16
	ldi	r16, 0x5F
	mov	r6, r16
	call	sys_print_prog
	
	; print "video"
	ldi	r16, LOW(ch8_debug_str_video<<1)
	mov	r2, r16
	ldi	r16, HIGH(ch8_debug_str_video<<1)
	mov	r3, r16
	ldi	r16, 12
	mov	r4, r16
	ldi	r16, 78
	mov	r5, r16
	ldi	r16, 0x5F
	mov	r6, r16
	call	sys_print_prog
	
	; print "emu."
	ldi	r16, LOW(ch8_debug_str_emu<<1)
	mov	r2, r16
	ldi	r16, HIGH(ch8_debug_str_emu<<1)
	mov	r3, r16
	ldi	r16, 36
	mov	r4, r16
	ldi	r16, 78
	mov	r5, r16
	ldi	r16, 0x5F
	mov	r6, r16
	call	sys_print_prog
	
	; print "memory"
	ldi	r16, LOW(ch8_debug_str_memory<<1)
	mov	r2, r16
	ldi	r16, HIGH(ch8_debug_str_memory<<1)
	mov	r3, r16
	ldi	r16, 57
	mov	r4, r16
	ldi	r16, 0
	mov	r5, r16
	ldi	r16, 0x5F
	mov	r6, r16
	call	sys_print_prog
	
	; print "help"
	ldi	r16, LOW(ch8_debug_str_help<<1)
	mov	r2, r16
	ldi	r16, HIGH(ch8_debug_str_help<<1)
	mov	r3, r16
	ldi	r16, 2
	mov	r4, r16
	ldi	r16, 16
	mov	r5, r16
	ldi	r16, 0x5F
	mov	r6, r16
	call	sys_print_prog
	
	rcall	ch8_draw
	rcall	_ch8_main_debug_draw_memory
	rcall	_ch8_main_debug_draw_emu
	
	pop	r16
	ret


_ch8_main_debug:
	; if Escape pressed toggle menu view
	ldi	r16, KEY_ESCAPE
	mov	r2, r16
	call	ps2consumekey
	mov	r16, r0
	cpi	r16, 0
	breq	_ch8_main_debug_f5
	rcall	ch8_prepare_game_view
	rjmp	ch8_main

_ch8_main_debug_f5:
	; if F6 not pressed skip
	ldi	r16, KEY_F5
	mov	r2, r16
	call	ps2consumekey
	mov	r16, r0
	cpi	r16, 0
	breq	_ch8_main_debug_f6
	
	lds	r16, CH8FLAGS0
	push	r16
	lds	r16, CH8POSX
	push	r16
	lds	r16, CH8POSY
	rcall	ch8_reset
	sts	CH8POSY, r16
	pop	r16
	sts	CH8POSX, r16
	pop	r16
	sts	CH8FLAGS0, r16
	
_ch8_main_debug_f6:
	; if F6 not pressed skip
	ldi	r16, KEY_F6
	mov	r2, r16
	call	ps2consumekey
	mov	r16, r0
	cpi	r16, 0
	breq	_ch8_main_debug_f7
	
	andi	r17, 0b11111110

_ch8_main_debug_f7:
	; if F7 not pressed skip
	ldi	r16, KEY_F7
	mov	r2, r16
	call	ps2consumekey
	mov	r16, r0
	cpi	r16, 0
	breq	_ch8_main_debug_f8
	
	ori	r17, 0b00000001
	
_ch8_main_debug_f8:
	; if F8 not pressed skip
	ldi	r16, KEY_F8
	mov	r2, r16
	call	ps2consumekey
	mov	r16, r0
	cpi	r16, 0
	breq	_ch8_main_debug_loop
	
	rcall	ch8_op
	rcall	_ch8_main_debug_draw_memory
	rcall	_ch8_main_debug_draw_emu
	ori	r17, 0b00000010


_ch8_main_debug_loop:
	sbrc	r17, 0
	rjmp	_ch8_main_debug_draw
	
	lds	r16, CH8IC
	cpi	r16, 8
	brcc	_ch8_main_debug_draw
	inc	r16
	sts	CH8IC, r16		; do 8 instructions every frame (8 * 60 = 480 Hz)

	rcall	ch8_op
	ori	r17, 0b00000010
	
_ch8_main_debug_draw:
	sbrc	r17, 1
	rjmp	_ch8_main_debug_loop_end
	lds	r16, CH8FC
	cpi	r16, 1
	brcs	_ch8_main_debug_loop_end
	sts	CH8FC, RZERO
	sts	CH8IC, RZERO		; cap draw screen @ 60 Hz

	rcall	ch8_draw
	rcall	_ch8_main_debug_draw_emu
	rcall	_ch8_main_debug_draw_memory
	
_ch8_main_debug_loop_end:
	andi	r17, 0b11111101
	sts	CH8FLAGS0, r17
	rjmp	ch8_main

_ch8_main_debug_draw_memory:
	push	r16
	
	ldi	r16, 47
	mov	r4, r16
	ldi	r16, 8
	mov	r5, r16
	ldi	r16, LOW(CH8SPACE)
	mov	r2, r16
	ldi	r16, HIGH(CH8SPACE)
	mov	r3, r16
	ldi	r16, 32
	mov	r0, r16
	ldi	r16, 112
	mov	r1, r16
	call	gfx_drawraw16
	
	pop	r16
	ret

_ch8_main_debug_draw_emu:
	push	r16
	
	ldi	r16, 36
	mov	r4, r16
	ldi	r16, 86
	mov	r5, r16
	ldi	r16, LOW(CH8V0)
	mov	r2, r16
	ldi	r16, HIGH(CH8V0)
	mov	r3, r16
	ldi	r16, 8
	mov	r0, r16
	ldi	r16, 32
	mov	r1, r16
	call	gfx_drawraw16
	
	pop	r16
	ret





















;; Start of relativity madness


; first half of operations

; 0--- - Sys operation
ch8_op_sys:
	cpi	CH8OPH, 0x00
	brne	ch8_op_sys_end
	cpi	CH8OPL, 0xE0
	breq	ch8_op_cls
	cpi	CH8OPL, 0xEE
	breq	ch8_op_ret
ch8_op_sys_end:
	rjmp	ch8_op_unknown

; 00E0 - CLS
ch8_op_cls:
	ldi	ZL, LOW(CH8FB)
	ldi	ZH, HIGH(CH8FB)
	clr	r0					; set i = 256
_ch8_op_cls_loop:
	st	Y+, r0
	dec	r0
	brne	_ch8_op_cls_loop
	rjmp	ch8_op_end

; 00EE - RET
ch8_op_ret:
	; decrement stack pointer
	lds	r0, CH8SP
	dec	r0
	sts	CH8SP, r0
	lsl	r0
	; retrieve PC from the top of the stack
	ldi	ZL, LOW(CH8STACK)
	ldi	ZH, HIGH(CH8STACK)
	add	ZL, r0
	adc	ZH, RZERO
	ld	r2, Z+
	ld	r1, Z+
	; set new pc
	sts	CH8PCL, r1
	sts	CH8PCH, r2
	rjmp	ch8_op_end


; 1nnn - JP nnn
ch8_op_jp:
	sts	CH8PCL, CH8OPBKL
	sts	CH8PCH, CH8OPBKH
	rjmp	ch8_op_end


; 2nnn - CALL nnn
ch8_op_call:
	; puts the current PC on the top of the stack
	ldi	ZL, LOW(CH8STACK)
	ldi	ZH, HIGH(CH8STACK)
	lds	r0, CH8SP
	lsl	r0					; stack is always 2 bytes wide
	add	ZL, r0
	adc	ZH, RZERO
	lds	r1, CH8PCL
	lds	r2, CH8PCH
	st	Z+, r2
	st	Z+, r1
	; increment stack pointer
	lsr	r0
	inc	r0
	sts	CH8SP, r0
	; set pc to nnn
	sts	CH8PCL, CH8OPBKL
	sts	CH8PCH, CH8OPBKH
	rjmp	ch8_op_end


; 3xkk - SE Vx, kk
ch8_op_sek:
	mov	r2, CH8OPBKH
	rcall	ch8_ld_reg
	cp	r0, CH8OPBKL
	brne	_ch8_op_sek_end
	lds	ZL, CH8PCL
	lds	ZH, CH8PCH
	adiw	Z, 2
	sts	CH8PCL, ZL
	sts	CH8PCH, ZH
_ch8_op_sek_end:
	rjmp	ch8_op_end


; 4xkk - SNE Vx, kk
ch8_op_snek:
	mov	r2, CH8OPBKH
	rcall	ch8_ld_reg
	cp	r0, CH8OPBKL
	breq	_ch8_op_sek_end
	lds	ZL, CH8PCL
	lds	ZH, CH8PCH
	adiw	Z, 2
	sts	CH8PCL, ZL
	sts	CH8PCH, ZH
_ch8_op_snek_end:
	rjmp	ch8_op_end


; 5xy0 - SE Vx, Vy
ch8_op_se:
	mov	r16, CH8OPBKL
	andi	r16, 0x0F			; check if least significant nibble is 0
	brne	_ch8_op_se_unknown		; if not 0, op unknown
	mov	r2, CH8OPBKH
	rcall	ch8_ld_reg			; load Vx
	mov	r1, r0				; save Vx to r1
	mov	r2, CH8OPBKL
	swap	r2
	rcall	ch8_ld_reg			; load Vy
	cp	r0, r1
	brne	_ch8_op_se_end			; if different: inc PC by 2
	lds	ZL, CH8PCL
	lds	ZH, CH8PCH
	adiw	Z, 2
	sts	CH8PCL, ZL
	sts	CH8PCH, ZH
_ch8_op_se_end:
	rjmp	ch8_op_end
_ch8_op_se_unknown:
	rjmp	ch8_op_unknown
	

; 6xkk - LD Vx, kk
ch8_op_ldk:
	mov	r2, CH8OPBKH
	mov	r3, CH8OPBKL
	rcall	ch8_st_reg
	rjmp	ch8_op_end
	
	
; 7xkk - ADD Vx, kk
ch8_op_addk:
	mov	r2, CH8OPBKH
	rcall	ch8_ld_reg
	add	r0, CH8OPBKL
	mov	r3, r0
	rcall	ch8_st_reg
	rjmp	ch8_op_end
	
	
; 8--- - Register ALU
ch8_op_alu:
	mov	r16, CH8OPBKL
	andi	r16, 0b00001111				; get least significant nibble of op
	
	ldi	ZL, LOW(ch8_op_alu_lut)
	ldi	ZH, HIGH(ch8_op_alu_lut)
	add	ZL, r16
	adc	ZH, RZERO				; prepare ch8_op_alu_lut jump
	
	swap	CH8OPBKL
	andi	CH8OPBKL, 0x0F				; prepare y argument of op
	
	ijmp
ch8_op_alu_lut:
	rjmp	ch8_op_alu_ld
	rjmp	ch8_op_alu_or
	rjmp	ch8_op_alu_and
	rjmp	ch8_op_alu_xor
	rjmp	ch8_op_alu_add
	rjmp	ch8_op_alu_sub
	rjmp	ch8_op_alu_shr
	rjmp	ch8_op_alu_subn
	rjmp	ch8_op_unknown
	rjmp	ch8_op_unknown
	rjmp	ch8_op_unknown
	rjmp	ch8_op_unknown
	rjmp	ch8_op_unknown
	rjmp	ch8_op_unknown
	rjmp	ch8_op_alu_shl
	rjmp	ch8_op_unknown

; 8xy0 - LD Vx, Vy	
ch8_op_alu_ld:
	mov	r2, CH8OPBKL
	rcall	ch8_ld_reg
	mov	r3, r0
	mov	r2, CH8OPBKH
	rcall	ch8_st_reg
	rjmp	ch8_op_end

; 8xy1 - OR Vx, Vy
ch8_op_alu_or:
	mov	r2, CH8OPBKL
	rcall	ch8_ld_reg
	mov	r3, r0
	mov	r2, CH8OPBKH
	rcall	ch8_ld_reg
	or	r3, r0
	rcall	ch8_st_reg
	rjmp	ch8_op_end

; 8xy2 - AND Vx, Vy
ch8_op_alu_and:
	mov	r2, CH8OPBKL
	rcall	ch8_ld_reg
	mov	r3, r0
	mov	r2, CH8OPBKH
	rcall	ch8_ld_reg
	and	r3, r0
	rcall	ch8_st_reg
	rjmp	ch8_op_end

; 8xy3 - XOR Vx, Vy
ch8_op_alu_xor:
	mov	r2, CH8OPBKL
	rcall	ch8_ld_reg
	mov	r3, r0
	mov	r2, CH8OPBKH
	rcall	ch8_ld_reg
	eor	r3, r0
	rcall	ch8_st_reg
	rjmp	ch8_op_end

; 8xy4 - ADD Vx, Vy
ch8_op_alu_add:
	mov	r2, CH8OPBKL
	rcall	ch8_ld_reg
	mov	r3, r0
	mov	r2, CH8OPBKH
	rcall	ch8_ld_reg
	clr	r1
	add	r3, r0
	adc	r1, RZERO
	rcall	ch8_st_reg
	ldi	r16, 0xF
	mov	r2, r16
	mov	r3, r1
	rcall	ch8_st_reg
	rjmp	ch8_op_end
	
; 8xy5 - SUB Vx, Vy
ch8_op_alu_sub:
	mov	r2, CH8OPBKH
	rcall	ch8_ld_reg
	mov	r3, r0				; r3 - Vx

	mov	r2, CH8OPBKL
	rcall	ch8_ld_reg			; r0 - Vy

	clr	r1
	sub	r3, r0
	adc	r1, RZERO			; do calculations

	mov	r2, CH8OPBKH
	rcall	ch8_st_reg			; store Vx

	mov	r16, r1
	inc	r16
	andi	r16, 1
	ldi	r16, 0x0F
	mov	r2, r16
	rcall	ch8_st_reg			; store Vf
	rjmp	ch8_op_end
	
; 8xy6 - SHR Vx {, Vy}
ch8_op_alu_shr:
	mov	r2, CH8OPBKH
	rcall	ch8_ld_reg
	clr	r1
	mov	r3, r0
	lsr	r3
	adc	r1, RZERO
	rcall	ch8_st_reg
	mov	r16, r1
	com	r16
	andi	r16, 1
	mov	r3, r16
	ldi	r16, 0xF
	mov	r2, r16
	rcall	ch8_st_reg
	rjmp	ch8_op_end
	
; 8xy7 - SUBN Vx, Vy
ch8_op_alu_subn:
	mov	r2, CH8OPBKL
	rcall	ch8_ld_reg
	mov	r3, r0
	mov	r2, CH8OPBKH
	rcall	ch8_ld_reg
	clr	r1
	sub	r3, r0
	adc	r1, RZERO
	rcall	ch8_st_reg
	mov	r16, r1
	com	r16
	andi	r16, 1
	mov	r3, r16
	ldi	r16, 0xF
	mov	r2, r16
	rcall	ch8_st_reg
	rjmp	ch8_op_end
	
; 8xyE - SHL Vx {, Vy}
ch8_op_alu_shl:
	mov	r2, CH8OPBKH
	rcall	ch8_ld_reg
	clr	r1
	mov	r3, r0
	lsl	r3
	adc	r1, RZERO
	rcall	ch8_st_reg
	mov	r16, r1
	com	r16
	andi	r16, 1
	mov	r3, r16
	ldi	r16, 0xF
	mov	r2, r16
	rcall	ch8_st_reg
	rjmp	ch8_op_end


; 9xy0 - SNE Vx, Vy
ch8_op_sne:
	mov	r16, CH8OPBKL
	andi	r16, 0x0F				; check if least significant nibble is 0
	brne	_ch8_op_sne_unknown			; if not 0, op unknown
	mov	r2, CH8OPBKH
	rcall	ch8_ld_reg				; load Vx
	mov	r1, r0					; save Vx to r1
	mov	r2, CH8OPBKL
	swap	r2
	rcall	ch8_ld_reg				; load Vy
	cp	r0, r1
	breq	_ch8_op_sne_end				; if different: inc PC by 2
	lds	ZL, CH8PCL
	lds	ZH, CH8PCH
	adiw	Z, 2
	sts	CH8PCL, ZL
	sts	CH8PCH, ZH
_ch8_op_sne_end:
	rjmp	ch8_op_end
_ch8_op_sne_unknown:
	rjmp	ch8_op_unknown








; ******* ch8 operation decoder *******
ch8_op:
	push	r16
	push	CH8OPBKL
	push	CH8OPBKH
	push	CH8OPL
	push	CH8OPH
	push	XL
	push	XH
	push	YL
	push	YH
	push	ZL
	push	ZH
	
	ldi	ZL, LOW(CH8RAMSTART)
	ldi	ZH, HIGH(CH8RAMSTART)
	lds	XL, CH8PCL
	lds	XH, CH8PCH
	add	ZL, XL
	adc	ZH, XH					; prepare to load operation from PC
	
	ld	CH8OPH, Z+
	ld	CH8OPL, Z+				; load operation from program counter
	
	adiw	X, 2
	sts	CH8PCL, XL
	sts	CH8PCH, XH				; increment PC
	
	
	
	mov	r16, CH8OPH
	swap	r16
	andi	r16, 0b00001111				; get most significant nibble of op
	
	movw	CH8OPBKH:CH8OPBKL, CH8OPH:CH8OPL
	andi	CH8OPBKH, 0b00001111			; prepare OP backup with arguments
	
	ldi	ZL, LOW(_ch8_op_lut)
	ldi	ZH, HIGH(_ch8_op_lut)
	add	ZL, r16
	adc	ZH, RZERO				; prepare _ch8_op_lut jump
	
	ijmp
_ch8_op_lut:
	rjmp	ch8_op_sys
	rjmp	ch8_op_jp
	rjmp	ch8_op_call
	rjmp	ch8_op_sek
	rjmp	ch8_op_snek
	rjmp	ch8_op_se
	rjmp	ch8_op_ldk
	rjmp	ch8_op_addk
	rjmp	ch8_op_alu
	rjmp	ch8_op_sne
	rjmp	ch8_op_ldi
	rjmp	ch8_op_jpr
	rjmp	ch8_op_rnd
	rjmp	ch8_op_drw
	rjmp	ch8_op_key
	rjmp	ch8_op_misc
	
ch8_op_end:
	clr	r1					; clear RZERO
	pop	ZH
	pop	ZL
	pop	YH
	pop	YL
	pop	XH
	pop	XL
	pop	CH8OPH
	pop	CH8OPL
	pop	CH8OPBKH
	pop	CH8OPBKL
	pop	r16
	
	ret

; TODO: this routine:
; 	- halts program execution;
; 	- dumps emulator state;
;	- requests user to restart machine
ch8_op_unknown:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ldi	r16, 0x69
	sts	CH8FB+1, r16
	rjmp	ch8_op_end
	
	pop	ZH
	pop	ZL
	pop	YH
	pop	YL
	pop	XH
	pop	XL
	pop	CH8OPH
	pop	CH8OPL
	pop	CH8OPBKH
	pop	CH8OPBKL
	pop	r16
	jmp	infinite
	mov	r2, CH8OPBKH
	call	gfx_clearscreen
	rjmp	ch8_op_end
	
	
; r2(0..3) - contains register to load to r0
ch8_ld_reg:
	push	ZL
	push	ZH
	
	mov	ZL, r2
	andi	ZL, 0b00001111
	mov	r0, ZL
	
	ldi	ZL, LOW(CH8V0)
	ldi	ZH, HIGH(CH8V0)
	add	ZL, r0
	adc	ZH, RZERO
	ld	r0, Z
	
	pop	ZH
	pop	ZL
	ret

; r2(0..3) - contains register to store to
; r3 - contains value to store on register
ch8_st_reg:
	push	ZL
	push	ZH
	
	mov	ZL, r2
	andi	ZL, 0b00001111
	mov	r2, ZL
	
	ldi	ZL, LOW(CH8V0)
	ldi	ZH, HIGH(CH8V0)
	add	ZL, r2
	adc	ZH, RZERO
	st	Z, r3
	
	pop	ZH
	pop	ZL
	ret
	
	

; second half of operations

; Annn - LD I, nnn
ch8_op_ldi:
	sts	CH8IL, CH8OPBKL
	sts	CH8IH, CH8OPBKH
	rjmp	ch8_op_end


; Bnnn - JP V0, nnn
ch8_op_jpr:
	mov	r2, RZERO
	rcall	ch8_ld_reg
	add	CH8OPBKL, r0
	adc	CH8OPBKH, RZERO
	sts	CH8PCL, CH8OPBKL
	sts	CH8PCH, CH8OPBKH
	rjmp	ch8_op_end


; Cxkk - RND Vx, byte
; TODO: implement actual random number
ch8_op_rnd:
	lds	r16, TCA0_SINGLE_CNT
	and	r16, CH8OPBKL
	
	mov	r2, CH8OPBKH
	mov	r3, r16
	rcall	ch8_st_reg
	rjmp	ch8_op_end


; Dxyn - DRW Vx, Vy, nibble
ch8_op_drw:
	push	r17
	push	r18					; this op needs two extra register for fmul
	ldi	XL, LOW(CH8RAMSTART)
	ldi	XH, HIGH(CH8RAMSTART)
	lds	r0, CH8IL
	lds	r1, CH8IH
	add	XL, r0
	adc	XH, r1					; load I to X
	
	mov	r16, CH8OPBKL
	andi	r16, 0x0F
	mov	r4, r16					; r4 contains n
	
	mov	r16, CH8OPBKL
	swap	r16
	andi	r16, 0x0F
	mov	r2, r16
	rcall	ch8_ld_reg
	lsl	r0
	lsl	r0
	lsl	r0
	ldi	YL, LOW(CH8FB)
	ldi	YH, HIGH(CH8FB)
	add	YL, r0
	adc	YH, RZERO				; Y has pointer to 1st byte to draw (without x)
	
	mov	r2, CH8OPBKH
	rcall	ch8_ld_reg
	mov	r1, r0					; r0 contains Vx
	lsr	r1
	lsr	r1
	lsr	r1
	add	YL, r1
	adc	YH, RZERO				; Y has pointer to 1st byte to draw
	mov	r16, r0
	andi	r16, 0x07
	mov	r5, r16					; r5 has bit offset
	
	ldi	r16, 0xF
	mov	r2, r16
	mov	r3, RZERO
	rcall	ch8_st_reg				; clear Vf
	ldi	r16, 0
_ch8_op_drw_loop:
	cp	r4, RZERO
	breq	_ch8_op_drw_end

	ld	r17, X+					; load first byte of sprite to draw

	ldi	ZL, LOW(ch8div2<<1)
	ldi	ZH, HIGH(ch8div2<<1)
	add	ZL, r5
	adc	ZH, RZERO				; load multiplier from table in prog mem
	lpm	r18, Z					; r1 now contains the part of the sprite that goes
	fmul	r17, r18				; on the main fb byte and r0 on the auxilary byte

	ld	r3, Y+					; load main byte of the frame buffer
	eor	r3, r1
	
	ld	r2, Y+					; load auxiliary byte of the frame buffer
	eor	r2, r0
	
	sbiw	Y, 2
	st	Y+, r3
	st	Y+, r2					; store changed pixels on ch8fb
	
	adiw	Y, 6
	
	; check collisions
	mov	r6, r1
	and	r6, r3					; r4 == r1, if no r3 bits got cleared on xor
	cp	r6, r1
	brne	_ch8_op_drw_setvf
	mov	r6, r0
	and	r6, r2					; r4 == r0, if no r2 bits got cleared on xor
	cp	r6, r0
	breq	_ch8_op_drw_setvf_done
_ch8_op_drw_setvf:
	ldi	r16, 1
_ch8_op_drw_setvf_done:
	dec	r4
	rjmp	_ch8_op_drw_loop
_ch8_op_drw_end:
	mov	r3, r16
	ldi	r16, 0xF
	mov	r2, r16
	rcall	ch8_st_reg
	pop	r18
	pop	r17
	rjmp	ch8_op_end


; E--- - Keyboard Operations
ch8_op_key:
	cpi	CH8OPBKL, 0x9E
	breq	ch8_op_skp
	cpi	CH8OPBKL, 0xA1
	breq	ch8_op_sknp
	rjmp	ch8_op_unknown
	
; Ex9E - SKP Vx
ch8_op_skp:
	ldi	ZL, LOW(ch8_keyscancodes<<1)
	ldi	ZH, HIGH(ch8_keyscancodes<<1)
	mov	r2, CH8OPBKH
	rcall	ch8_ld_reg
	add	ZL, r0
	adc	ZH, RZERO
	lpm	r2, Z
	call	ps2readkey
	cp	r0, RZERO
	breq	ch8_op_skp_end
	lds	ZL, CH8PCL
	lds	ZH, CH8PCH
	adiw	Z, 2
	sts	CH8PCL, ZL
	sts	CH8PCH, ZH
ch8_op_skp_end:
	rjmp	ch8_op_end
	
; ExA1 - SKNP Vx
ch8_op_sknp:
	ldi	ZL, LOW(ch8_keyscancodes<<1)
	ldi	ZH, HIGH(ch8_keyscancodes<<1)
	mov	r2, CH8OPBKH
	rcall	ch8_ld_reg
	add	ZL, r0
	adc	ZH, RZERO
	lpm	r2, Z
	call	ps2readkey
	cp	r0, RZERO
	brne	ch8_op_sknp_end
	lds	ZL, CH8PCL
	lds	ZH, CH8PCH
	adiw	Z, 2
	sts	CH8PCL, ZL
	sts	CH8PCH, ZH
ch8_op_sknp_end:
	rjmp	ch8_op_end









; F--- - Miscelaneous Operations
ch8_op_misc:
	mov	r16, CH8OPBKL
	swap	r16
	andi	r16, 0b00001111				; get MS nibble of LS byte of op
	
	ldi	ZL, LOW(ch8_op_misc_lut)
	ldi	ZH, HIGH(ch8_op_misc_lut)
	add	ZL, r16
	adc	ZH, RZERO				; prepare ch8_op_alu_lut jump
	
	ijmp
ch8_op_misc_lut:
	rjmp	ch8_op_misc_0
	rjmp	ch8_op_misc_1
	rjmp	ch8_op_misc_2
	rjmp	ch8_op_misc_3
	rjmp	ch8_op_unknown
	rjmp	ch8_op_misc_5
	rjmp	ch8_op_misc_6
	rjmp	ch8_op_unknown
	rjmp	ch8_op_unknown
	rjmp	ch8_op_unknown
	rjmp	ch8_op_unknown
	rjmp	ch8_op_unknown
	rjmp	ch8_op_unknown
	rjmp	ch8_op_unknown
	rjmp	ch8_op_unknown
	rjmp	ch8_op_unknown

; Fx0-
ch8_op_misc_0:
	cpi	CH8OPBKL, 0x07
	breq	ch8_op_misc_lddt
	cpi	CH8OPBKL, 0x0A
	breq	ch8_op_misc_wkp
	rjmp	ch8_op_unknown

; Fx07 - LD Vx, DT
ch8_op_misc_lddt:
	mov	r2, CH8OPBKH
	lds	r3, CH8DT
	rcall	ch8_st_reg
	rjmp	ch8_op_end

; Fx0A - LD Vx, K
ch8_op_misc_wkp:
	ldi	r16, 0
_ch8_op_misc_wkp_loop:				; cycle through all 16 keys until one is pressed
	inc	r16
	andi	r16, 0x0F
	ldi	ZL, LOW(ch8_keyscancodes<<1)
	ldi	ZH, HIGH(ch8_keyscancodes<<1)
	add	ZL, r16
	adc	ZH, RZERO
	lpm	r2, Z				; load r2 with scancode
	call	ps2readkey
	or	r0, RZERO
	breq	_ch8_op_misc_wkp_loop
_ch8_op_misc_wkp_done:
	mov	r2, CH8OPBKH
	mov	r3, r16
	rcall	ch8_st_reg
	rjmp	ch8_op_end

; Fx1-
ch8_op_misc_1:
	cpi	CH8OPBKL, 0x15
	breq	ch8_op_misc_stdt
	cpi	CH8OPBKL, 0x18
	breq	ch8_op_misc_ldst
	cpi	CH8OPBKL, 0x1E
	breq	ch8_op_misc_addi
	rjmp	ch8_op_unknown

; Fx15 - ST DT, Vx
ch8_op_misc_stdt:
	mov	r2, CH8OPBKH
	rcall	ch8_ld_reg
	sts	CH8DT, r0
	rjmp	ch8_op_end	

; Fx18 - LD ST, Vx
ch8_op_misc_ldst:
	mov	r2, CH8OPBKH
	rcall	ch8_ld_reg			; load Vx
	sts	CH8ST, r0			; store Vx in sound timer
	rjmp	ch8_op_end
	
; Fx1E - ADD I, Vx
ch8_op_misc_addi:
	mov	r2, CH8OPBKH
	rcall	ch8_ld_reg			; load Vx
	lds	r1, CH8IL
	lds	r2, CH8IH			; load I
	add	r1, r0
	adc	r2, RZERO			; I + Vx
	sts	CH8IL, r1
	sts	CH8IH, r2			; store I
	rjmp	ch8_op_end

; Fx2-
ch8_op_misc_2:
	cpi	CH8OPBKL, 0x29
	breq	ch8_op_misc_ldichar
	rjmp	ch8_op_unknown

; Fx29 - LD I, pCharSprite(Vx)
ch8_op_misc_ldichar:
	mov	r2, CH8OPBKH
	rcall	ch8_ld_reg			; load Vx
	ldi	r16, 0x0F
	and	r0, r16
	ldi	r16, 5
	mul	r0, r16
	ldi	ZL, LOW(CH8CHARRAM-CH8RAMSTART)
	ldi	ZH, HIGH(CH8CHARRAM-CH8RAMSTART); load char address
	add	r0, ZL
	adc	r1, ZH				; I + Vx
	sts	CH8IL, r0
	sts	CH8IH, r1			; store I
	rjmp	ch8_op_end

; Fx3-
ch8_op_misc_3:
	cpi	CH8OPBKL, 0x33
	breq	ch8_op_misc_bcd
	rjmp	ch8_op_unknown

; Fx33 - LD B, Vx
ch8_op_misc_bcd:
	mov	r2, CH8OPBKH
	rcall	ch8_ld_reg			; load Vx
	mov	r16, r0
	clr	r0
	clr	r1
	clr	r2
_ch8_op_misc_bcd_100:
	cpi	r16, 100
	brcs	_ch8_op_misc_bcd_10
	inc	r0
	subi	r16, 100
	rjmp	_ch8_op_misc_bcd_100
_ch8_op_misc_bcd_10:
	cpi	r16, 10
	brcs	_ch8_op_misc_bcd_1
	inc	r1
	subi	r16, 10
	rjmp	_ch8_op_misc_bcd_10
_ch8_op_misc_bcd_1:
	cpi	r16, 1
	brcs	_ch8_op_misc_bcd_done
	inc	r2
	subi	r16, 1
	rjmp	_ch8_op_misc_bcd_1
_ch8_op_misc_bcd_done:
	ldi	ZL, LOW(CH8RAMSTART)
	ldi	ZH, HIGH(CH8RAMSTART)
	lds	r3, CH8IL
	lds	r4, CH8IH
	add	ZL, r3
	adc	ZH, r4
	st	Z+, r0
	st	Z+, r1
	st	Z+, r2
	rjmp	ch8_op_end

; Fx5-
ch8_op_misc_5:
	cpi	CH8OPBKL, 0x55
	breq	ch8_op_misc_stall
	rjmp	ch8_op_unknown
	
; Fx55 - LD [I], Vx
ch8_op_misc_stall:
	ldi	ZL, LOW(CH8RAMSTART)
	ldi	ZH, HIGH(CH8RAMSTART)
	lds	r4, CH8IL
	lds	r5, CH8IH
	add	ZL, r4
	adc	ZH, r5				; load I
	clr	r2
_ch8_op_misc_stall_loop:
	rcall	ch8_ld_reg			; load Vx
	st	Z+, r0	
	inc	r2
	cp	CH8OPBKH, r2
	brcc	_ch8_op_misc_stall_loop

	add	r4, r2
	adc	r5, RZERO
	sts	CH8IL, r4
	sts	CH8IH, r5			; store incremented I (not SCHIP complient)

	rjmp	ch8_op_end

; Fx6-
ch8_op_misc_6:
	cpi	CH8OPBKL, 0x65
	breq	ch8_op_misc_ldall
	rjmp	ch8_op_unknown

; Fx65 - LD Vx, [I]
ch8_op_misc_ldall:
	ldi	ZL, LOW(CH8RAMSTART)
	ldi	ZH, HIGH(CH8RAMSTART)
	lds	r4, CH8IL
	lds	r5, CH8IH
	add	ZL, r4
	adc	ZH, r5				; load I
	clr	r2
_ch8_op_misc_ldall_loop:
	ld	r3, Z+
	rcall	ch8_st_reg			; load Vx
	inc	r2
	cp	CH8OPBKH, r2
	brcc	_ch8_op_misc_ldall_loop
	
	add	r4, r2
	adc	r5, RZERO
	sts	CH8IL, r4
	sts	CH8IH, r5			; store incremented I (not SCHIP complient)
	
	rjmp	ch8_op_end













