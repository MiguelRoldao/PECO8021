




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; real functions

;; Arguments
;	r2 - image ptr low
;	r3 - image ptr high
;	r4 - x position
;	r5 - y position
_drawstarters:
	push	ZL
	push	ZH				; pointer to image
	push	YL
	push	YH				; pointer to framebuffer
	push	r16
	push	r17
	push	r18
	push	r19
	push	r20
	push	r21

	;ldi	ZL, LOW(0x2800+SRAM_START)
	;ldi	ZH, HIGH(0x2800+SRAM_START)		; load image pointer
	
	mov	ZL, r2
	mov	ZH, r3					; load image pointer
	
	ldi	YL, LOW(vgafb)
	ldi	YH, HIGH(vgafb)		
	add	YL, r4
	adc	YH, RZERO
	ldi	r16, 64
	mul	r16, r5
	add	YL, r0
	adc	YH, r1					; load destiny pointer
	clr	r1				; clear RZERO
	
	ld	r16, Z+				; load header
	ld	r17, Z+				; load width
	lsr	r17				; divide width by 2
	ld	r18, Z+				; load height

	mov	r20, r18			; iy
_drawstarters_yloop:
	mov	r19, r17			; ix
_drawstarters_xloop:
	ld	r21, Z+
	st	Y+, r21
	dec	r19
	brne	_drawstarters_xloop
	sub	YL, r17
	sbc	YH, RZERO
	adiw	Y, 63
	adiw	Y, 1
	dec	r20
	brne	_drawstarters_yloop
	
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




; args: r2 - contains color to clear screen (0x00-0x0F)
gfx_clearscreen:
	push	r16
	push	ZH
	push	ZL
	push	XH
	push	XL
	
	ldi	ZL, LOW(vgafbsizes<<1)
	ldi	ZH, HIGH(vgafbsizes<<1)
	lds	r16, vgamode
	lsl	r16
	add	ZL, r16
	adc	ZH, r1
	lpm	XL, Z+
	lpm	XH, Z+

	mov	r16, r2		
	swap	r16
	or	r2, r16			; both nibbles contain the color

	ldi	ZL, LOW(vgafb)
	ldi	ZH, HIGH(vgafb)
	
	add	XL, ZL
	adc	XH, ZH
_gfx_clearscreen_loop:
	st	Z+, r2
	
	cp	ZL, XL
	brne	_gfx_clearscreen_loop
	cp	ZH, XH
	brne	_gfx_clearscreen_loop
	;sbiw	X, 1
	;brne	_gfx_clearscreen_loop
	;cpi	ZL, LOW(vgafb+0x2580)
	;brne	_gfx_clearscreen_loop
	;cpi	ZH, HIGH(vgafb+0x2580)
	;brne	_gfx_clearscreen_loop
	
	pop	XL
	pop	XH
	pop	ZL
	pop	ZH
	pop	r16
	ret


;; Arguments
;	r3:r2 - image ptr
;	r4 - x position
;	r5 - y position
;	r6 - pal 0
;	r7 - pal 1
gfx_drawpimg:
	push	r17
	push	ZL
	push	ZH
	push	r16
	
	movw	Z, r3:r2
	ld	r17, Z+
	
	ld	r16, Z+
	mov	r0, r16
	lsr	r0
	ld	r16, Z+
	mov	r1, r16
	movw	r3:r2, Z				; prepare arguments
	
	pop	r16
	pop	ZH
	pop	ZL
	
	rjmp	_gfx_draw_demux_palette

;; Arguments
;	r3:r2 - image ptr
;	r4 - x position
;	r5 - y position
;	r6 - pal 0
;	r7 - pal 1
;	r0 - tile id
gfx_drawtile:
	push	r17
	push	ZL
	push	ZH
	push	r16
	push	r18

	
	movw	Z, r3:r2
	ld	r16, Z+
	push	r16					; push tileset header
	
	ld	r16, Z+
	lsr	r16					; contains tile width
	ld	r17, Z+					; contains tile height
	
	ld	r18, Z+
	;cp	r0, r18
	;brcc	_gfx_drawtile_exit			; if tile id is out of bounds exit
	
	ld	r18, Z+
	mul	r0, r18					; multiply tilze size by tile id
	add	ZL, r0
	adc	ZH, r1					; move pointer to desired tile
	
	movw	r3:r2, Z				; prepare arguments
	movw	r1:r0, r17:r16
	
	pop	r17					; retrieve tileset header
	

	pop	r18
	pop	r16
	pop	ZH
	pop	ZL
	
_gfx_draw_demux_palette:
	andi	r17, 0b00000011
	breq	_gfx_drawpimg_16color
	cpi	r17, 1
	breq	_gfx_drawpimg_4color
_gfx_drawpimg_2color:
	pop	r17
	rjmp	gfx_drawraw2
_gfx_drawpimg_4color:
	; TODO
_gfx_drawpimg_16color:
	pop	r17
	rjmp	gfx_drawraw16

_gfx_drawtile_exit:
	pop	r16					; pop tileset header
	pop	r19
	pop	r18
	pop	r17
	pop	r16
	pop	ZH
	pop	ZL
	cli	
	jmp	infinite
	ret

;; Arguments
;	r3:r2 - raw image ptr
;	r4 - x position
;	r5 - y position
;	r0 - image width
;	r1 - image height
gfx_drawraw16:
	push	ZL
	push	ZH				; pointer to image
	push	YL
	push	YH				; pointer to framebuffer
	push	r16
	push	r17
	push	r18
	push	r19
	
	lds	r19, vgawidth
	movw	Z, r3:r2			; load image pointer
	movw	r3:r2, r1:r0
	clr	r1
	
	ldi	YL, LOW(vgafb)
	ldi	YH, HIGH(vgafb)		
	add	YL, r4
	adc	YH, r1
	mul	r19, r5
	add	YL, r0
	adc	YH, r1				; load destiny pointer
	clr	r1				; clear RZERO

	mov	r16, r3				; iy
_gfx_drawraw16_yloop:
	mov	r17, r2				; ix
_gfx_drawraw16_xloop:
	ld	r18, Z+
	st	Y+, r18
	dec	r17
	brne	_gfx_drawraw16_xloop
	sub	YL, r2
	sbc	YH, r1
	add	YL, r19
	adc	YH, r1
	dec	r16
	brne	_gfx_drawraw16_yloop
	
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
;	r3:r2 - image ptr
;	r4 - x position
;	r5 - y position
;	r6 - pal
;	r0 - image width
;	r1 - image height
gfx_drawraw2:
	push	ZL
	push	ZH				; pointer to image
	push	YL
	push	YH				; pointer to framebuffer
	push	r16				; image width
	push	r17				; image height
	push	r19				; horizontal iterator
	push	r20				; vertical iterator
	push	r21				; loaded image byte
	push	r22				; image bit counter (1 bit / pixel)
	push	r23				; general purpose
	push	r24				; screen columns
	
	movw	r17:r16, r1:r0
	clr	r1				; clear RZERO
	lds	r24, vgawidth
	movw	Z, r3:r2

	ldi	YL, LOW(vgafb)
	ldi	YH, HIGH(vgafb)		
	add	YL, r4
	adc	YH, r1
	mul	r24, r5
	add	YL, r0
	adc	YH, r1				; load destiny pointer
	clr	r1				; clear RZERO
	
	ldi	r22, 8 /2
	ld	r21, Z+

	; loops
	mov	r20, r17			; iy
_gfx_drawraw2_yloop:
	mov	r19, r16			; ix
_gfx_drawraw2_xloop:

	; process pixel1
	lsl	r21
	brcs	_gfx_drawraw2_pixel1_pal1
_gfx_drawraw2_pixel1_pal0:
	mov	r23, r6
	andi	r23, 0xF0
	mov	r7, r23
	rjmp	_gfx_drawraw2_pixel1_done
_gfx_drawraw2_pixel1_pal1:
	mov	r23, r6
	andi	r23, 0x0F
	swap	r23
	mov	r7, r23
_gfx_drawraw2_pixel1_done:
	; process pixel2
	lsl	r21
	brcs	_gfx_drawraw2_pixel2_pal1
_gfx_drawraw2_pixel2_pal0:
	mov	r23, r6
	andi	r23, 0xF0
	swap	r23
	or	r7, r23
	rjmp	_gfx_drawraw2_pixel2_done
_gfx_drawraw2_pixel2_pal1:
	mov	r23, r6
	andi	r23, 0x0F
	or	r7, r23
_gfx_drawraw2_pixel2_done:
	st	Y+, r7
	
	dec	r22
	brne	_gfx_drawraw2_afterload
	ldi	r22, 8 /2
	ld	r21, Z+
_gfx_drawraw2_afterload:
	
	; loops' checks
	dec	r19
	brne	_gfx_drawraw2_xloop
	sub	YL, r16
	sbc	YH, RZERO
	add	YL, r24
	adc	YH, r1
	dec	r20
	brne	_gfx_drawraw2_yloop
	
	pop	r24
	pop	r23
	pop	r22
	pop	r21
	pop	r20
	pop	r19
	pop	r17
	pop	r16
	pop	YH
	pop	YL
	pop	ZH
	pop	ZL
	ret












