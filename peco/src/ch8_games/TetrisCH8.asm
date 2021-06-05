; v0 - x draw coordinate
; v1 - y draw coordinate
; v2 - key 7 code
; v3 - 
; v4 - 
; v5 - ? time to feed DT
; v6 - 
; v7 - key 5 code
; v8 - key 6 code
; v9 - key 4 code
; va - game score
; vb - 
; vc - 
; vd - 
; ve - 
; vf - flags
	
start:
	ld	I, 0x2B4			; point to wall sprite (1 pixel)
	call	tetris_init	; 0x3E6
	call	tetris_init1	; 0x2B6

draw_frame:					; 0x206
draw_frame_bottom:						; draw bottom frame
	add	v0, 0x01
	drw	v0, v1, 0x01
	se	v0, 0x25
	jmp	drawbottomframe
draw_frame_columns:				; 0x20E		; draw frame colums
	add	v1, 0xFF
	drw	v0, v1, 0x1
	ld	v0, 0x1A
	drw	v0, v1, 0x1
	ld	v0, 0x25
	se	v1, 0x00
	jmp	draw_frame_columns


label2:				; 0x21C
	rnd	v4, 0x70
	sne	v4, 0x70
	jmp	label2

	rnd	v3, 0x03
	ld	v0, 0x1E
	ld	v1, 0x03
	call	func2		; 0x25C
label5				; 0x22A
	st	DT, v5
	drw	v0, v1, 0x4
	se	vf, 0x01
	jmp	buttons_check
	
	drw	v0, v1, 0x4
	add	v1, 0xFF
	drw	v0, v1, 0x4
	call	func3		; 0x340
	jmp	label2
buttons_check:				; 0x23C			; main game loop
	sknp	v7
	call	func7		; 0x272
	sknp	v8
	call	func9		; 0x284
	sknp	v9
	call	funcA		; 0x296
	skp	v2
	jmp	label4
	ld	v6, 0x00
	st	DT, v6
label4:				; 0x250
	ld	v6, DT
	se	v6, 0x00
	jmp	buttons_check
	drw	v0, v1, 0x4
	add	v1, 0x01
	jmp	label5




tetris_init:			; 0x3E6		; prepare draw 
	ld	va, 0x00
	ld	v0, 0x19
	ret

tetris_init1:			; 0x2B6
	ld	v7, 0x05
	ld	v8, 0x06
	ld	v9, 0x04
	ld	v1, 0x1F
	ld	v5, 0x10
	ld	v2, 0x07
	ret

func2:				; 0x25C
	ld	I, 0x2C4
	add	I, v4
	ld	v6, 0x00
	sne	v3, 0x01
	ld	v6, 0x04
	sne	v3, 0x02
	ld	v6, 0x08
	sne	v3, 0x03
	ld	v6, 0x0C
	add	I, v6
	ret

func3:				; 0x340
	ld	I, 0x2B4
	ld	vc, v1
	se	vc, 0x1E
	add	vc, 0x01
	se	vc, 0x1E
	add	vc, 0x01
	se	vc, 0x1E
	add	vc, 0x01
_flabel0:
	call	func4		; 0x35E
	sne	vb, 0x0A
	call	func5		; 0x372
	sne	v1, vc
	ret
	add	v1, 1
	jmp	_flabel0

func4:
	ld	v0, 0x1B
	ld	vb, 0x00
_flabel1:
	drw	v0, v1, 0x1
	se	vf, 00
	add	vb, 0x01
	drw	v0, v1, 0x1
	add	v0, 0x01
	se	v0, 0x25
	jmp	_flabel1
	ret

func5:				; 0x372
	ld	v0, 0x1B
_flabel2:			; 0x374
	drw	v0, v1, 0x1
	add	v0, 0x01
	se	v0, 0x25
	jmp	_flabel2
	ld	ve, v1
	ld	vd, ve
	add	ve, 0xFF
_flabel7:			; 0x382
	ld	v0, 0x1B
	ld	vb, 0x00
_flabel5:			; 0x386
	drw	v0, ve, 0x1
	se	vf, 00
	jmp	_flabel3
	drw	v0, ve, 0x1
	jmp	_flabel4
_flabel3:			; 0x390
	drw	v0, vd, 0x1
	add	vb, 0x01
_flabel4:			; 0x394
	add	v0, 0x01
	se	v0, 0x25
	jmp	_flabel5
	sne	vb, 0x00
	jmp	_flabel6
	add	vd, 0xFF
	add	ve, 0xFF
	se	vd, 0x01
	jmp	_flabel7
_flabel6:			; 0x3A6
	call	func6		; 0x3C0
	se	vf, 0x01
	call	func6		; 0x3C0
	add	va, 0x01
	call	func6		; 0x3C0
	ld	v0, va
	ld	vd, 0x07
	and	v0, vd
	sne	v0, 0x04
	add	v5, 0xFE
	sne	v5, 0x02
	ld	v5, 0x04
	ret

func6:				; 0x3C0			; draw a 3 digit decimal number
	ld	I, 0x700
	str	v2
	ld	I, 0x804
	bcd	va
	ldr	v2
	ldchar	v0
	ld	vd, 0x32
	ld	ve, 0x00
	drw	vd, ve, 0x5
	add	vd, 0x05
	ldchar	v1
	drw	vd, ve, 0x5
	add	vd 0x05
	ldchar	v2
	drw	vd, ve, 0x5
	ld	I, 0x700
	ldr	v2
	ld	I, 0x2B4
	ret

func7:				; 0x272
	drw	v0, v1, 0x4
	add	v0, 0xFF
	call	func8		; 0x334
	se	vf, 0x01
	ret
	drw	v0, v1, 0x4
	add	v0, 0x01
	call	func8		; 0x334
	retv

func8:				; 0x334
	drw	v0, v1, 0x4
	ld	v6, 0x35
_flabel7:			; 0x338
	add	v6, 0xFF
	se	v6, 0x00
	jmp	_flabel7	
	ret

func9:				; 0x284
	drw	v0, v1, 0x4
	add	v0, 0x01
	call	func8		; 0x334
	se	vf, 0x01
	ret

	drw	v0, v1, 0x4
	add	v0, 0xFF
	call	func8
	ret

funcA:				; 0x296
	drw	v0, v1, 0x4
	add	v3, 0x01
	sne	v3, 0x04
	ld	v3, 0x00
	call	func2
	call	func8
	se	vf, 0x01
	ret

	drw	v0, v1, 0x4
	add	v3, 0xFF
	sne	v3, 0xFF
	ld	v3, 0x03
	call	func2
	call	func8
	ret









	ld	v0, 0x69
	ld	v1, 0x88
	ld	v2, 0x12
	ld	v3, 0x42
	ld	v4, 0xFF
	ld	I, 0x20
	str	v3
	bcd	v3
	ld	I, 0x1C
	ldr	v3
end:
	jmp	end







