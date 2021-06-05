supermario:
	ldi	ZL, LOW(vgafb)
	ldi	ZH, HIGH(vgafb)
	ldi	XL, 161
	ldi	XH, 0
	rcall	addXtoZ

	ldi	r16, 0xFF
	st	Z+, r16
	ldi	r16, 0xFF
	st	Z+, r16
	ldi	r16, 0xF8
	st	Z+, r16
	ldi	r16, 0x88
	st	Z+, r16
	ldi	r16, 0x88
	st	Z+, r16
	ldi	r16, 0xFF
	st	Z+, r16
	ldi	r16, 0xFF
	st	Z+, r16
	ldi	r16, 0xFF
	st	Z+, r16

	ldi	ZL, LOW(vgafb)
	ldi	ZH, HIGH(vgafb)
	ldi	XL, 241
	ldi	XH, 0
	rcall	addXtoZ

	ldi	r16, 0xFF
	st	Z+, r16
	ldi	r16, 0xFF
	st	Z+, r16
	ldi	r16, 0x88
	st	Z+, r16
	ldi	r16, 0x88
	st	Z+, r16
	ldi	r16, 0x88
	st	Z+, r16
	ldi	r16, 0x88
	st	Z+, r16
	ldi	r16, 0x8F
	st	Z+, r16
	ldi	r16, 0xFF
	st	Z+, r16

	ldi	ZL, LOW(vgafb)
	ldi	ZH, HIGH(vgafb)
	ldi	XL, 0x41
	ldi	XH, 0x01
	rcall	addXtoZ

	ldi	r16, 0xFF
	st	Z+, r16
	ldi	r16, 0xFF
	st	Z+, r16
	ldi	r16, 0x11
	st	Z+, r16
	ldi	r16, 0x1A
	st	Z+, r16
	ldi	r16, 0xA1
	st	Z+, r16
	ldi	r16, 0xAF
	st	Z+, r16
	ldi	r16, 0xFF
	st	Z+, r16
	ldi	r16, 0xFF
	st	Z+, r16

	ldi	ZL, LOW(vgafb)
	ldi	ZH, HIGH(vgafb)
	ldi	XL, 0x91
	ldi	XH, 0x01
	rcall	addXtoZ

	ldi	r16, 0xFF
	st	Z+, r16
	ldi	r16, 0xF1
	st	Z+, r16
	ldi	r16, 0xA1
	st	Z+, r16
	ldi	r16, 0xAA
	st	Z+, r16
	ldi	r16, 0xA1
	st	Z+, r16
	ldi	r16, 0xAA
	st	Z+, r16
	ldi	r16, 0xAF
	st	Z+, r16
	ldi	r16, 0xFF
	st	Z+, r16

	ldi	ZL, LOW(vgafb)
	ldi	ZH, HIGH(vgafb)
	ldi	XL, 0xE1
	ldi	XH, 0x01
	rcall	addXtoZ

	ldi	r16, 0xFF
	st	Z+, r16
	ldi	r16, 0xF1
	st	Z+, r16
	ldi	r16, 0xA1
	st	Z+, r16
	ldi	r16, 0x1A
	st	Z+, r16
	ldi	r16, 0xAA
	st	Z+, r16
	ldi	r16, 0x1A
	st	Z+, r16
	ldi	r16, 0xAA
	st	Z+, r16
	ldi	r16, 0xFF
	st	Z+, r16

	ldi	ZL, LOW(vgafb)
	ldi	ZH, HIGH(vgafb)
	ldi	XL, 0x31
	ldi	XH, 0x02
	rcall	addXtoZ

	ldi	r16, 0xFF
	st	Z+, r16
	ldi	r16, 0xF1
	st	Z+, r16
	ldi	r16, 0x1A
	st	Z+, r16
	ldi	r16, 0xAA
	st	Z+, r16
	ldi	r16, 0xA1
	st	Z+, r16
	ldi	r16, 0x11
	st	Z+, r16
	ldi	r16, 0x1F
	st	Z+, r16
	ldi	r16, 0xFF
	st	Z+, r16

	ldi	ZL, LOW(vgafb)
	ldi	ZH, HIGH(vgafb)
	ldi	XL, 0x81
	ldi	XH, 0x02
	rcall	addXtoZ

	ldi	r16, 0xFF
	st	Z+, r16
	ldi	r16, 0xFF
	st	Z+, r16
	ldi	r16, 0xFA
	st	Z+, r16
	ldi	r16, 0xAA
	st	Z+, r16
	ldi	r16, 0xAA
	st	Z+, r16
	ldi	r16, 0xAA
	st	Z+, r16
	ldi	r16, 0xFF
	st	Z+, r16
	ldi	r16, 0xFF
	st	Z+, r16

	ldi	ZL, LOW(vgafb)
	ldi	ZH, HIGH(vgafb)
	ldi	XL, 0xD1
	ldi	XH, 0x02
	rcall	addXtoZ

	ldi	r16, 0xFF
	st	Z+, r16
	ldi	r16, 0xFF
	st	Z+, r16
	ldi	r16, 0x11
	st	Z+, r16
	ldi	r16, 0x81
	st	Z+, r16
	ldi	r16, 0x11
	st	Z+, r16
	ldi	r16, 0xFF
	st	Z+, r16
	ldi	r16, 0xFF
	st	Z+, r16
	ldi	r16, 0xFF
	st	Z+, r16

	ldi	ZL, LOW(vgafb)
	ldi	ZH, HIGH(vgafb)
	ldi	XL, 0x21
	ldi	XH, 0x03
	rcall	addXtoZ

	ldi	r16, 0xFF
	st	Z+, r16
	ldi	r16, 0xF1
	st	Z+, r16
	ldi	r16, 0x11
	st	Z+, r16
	ldi	r16, 0x81
	st	Z+, r16
	ldi	r16, 0x18
	st	Z+, r16
	ldi	r16, 0x11
	st	Z+, r16
	ldi	r16, 0x1F
	st	Z+, r16
	ldi	r16, 0xFF
	st	Z+, r16

	ldi	ZL, LOW(vgafb)
	ldi	ZH, HIGH(vgafb)
	ldi	XL, 0x71
	ldi	XH, 0x03
	rcall	addXtoZ

	ldi	r16, 0xFF
	st	Z+, r16
	ldi	r16, 0x11
	st	Z+, r16
	ldi	r16, 0x11
	st	Z+, r16
	ldi	r16, 0x88
	st	Z+, r16
	ldi	r16, 0x88
	st	Z+, r16
	ldi	r16, 0x11
	st	Z+, r16
	ldi	r16, 0x11
	st	Z+, r16
	ldi	r16, 0xFF
	st	Z+, r16

	ldi	ZL, LOW(vgafb)
	ldi	ZH, HIGH(vgafb)
	ldi	XL, 0xC1
	ldi	XH, 0x03
	rcall	addXtoZ

	ldi	r16, 0xFF
	st	Z+, r16
	ldi	r16, 0xAA
	st	Z+, r16
	ldi	r16, 0x18
	st	Z+, r16
	ldi	r16, 0xA8
	st	Z+, r16
	ldi	r16, 0x8A
	st	Z+, r16
	ldi	r16, 0x81
	st	Z+, r16
	ldi	r16, 0xAA
	st	Z+, r16
	ldi	r16, 0xFF
	st	Z+, r16

	ldi	ZL, LOW(vgafb)
	ldi	ZH, HIGH(vgafb)
	ldi	XL, 0x11
	ldi	XH, 0x04
	rcall	addXtoZ

	ldi	r16, 0xFF
	st	Z+, r16
	ldi	r16, 0xAA
	st	Z+, r16
	ldi	r16, 0xA8
	st	Z+, r16
	ldi	r16, 0x88
	st	Z+, r16
	ldi	r16, 0x88
	st	Z+, r16
	ldi	r16, 0x8A
	st	Z+, r16
	ldi	r16, 0xAA
	st	Z+, r16
	ldi	r16, 0xFF
	st	Z+, r16

	ldi	ZL, LOW(vgafb)
	ldi	ZH, HIGH(vgafb)
	ldi	XL, 0x61
	ldi	XH, 0x04
	rcall	addXtoZ

	ldi	r16, 0xFF
	st	Z+, r16
	ldi	r16, 0xAA
	st	Z+, r16
	ldi	r16, 0x88
	st	Z+, r16
	ldi	r16, 0x88
	st	Z+, r16
	ldi	r16, 0x88
	st	Z+, r16
	ldi	r16, 0x88
	st	Z+, r16
	ldi	r16, 0xAA
	st	Z+, r16
	ldi	r16, 0xFF
	st	Z+, r16

	ldi	ZL, LOW(vgafb)
	ldi	ZH, HIGH(vgafb)
	ldi	XL, 0xB1
	ldi	XH, 0x04
	rcall	addXtoZ

	ldi	r16, 0xFF
	st	Z+, r16
	ldi	r16, 0xFF
	st	Z+, r16
	ldi	r16, 0x88
	st	Z+, r16
	ldi	r16, 0x8F
	st	Z+, r16
	ldi	r16, 0xF8
	st	Z+, r16
	ldi	r16, 0x88
	st	Z+, r16
	ldi	r16, 0xFF
	st	Z+, r16
	ldi	r16, 0xFF
	st	Z+, r16

	ldi	ZL, LOW(vgafb)
	ldi	ZH, HIGH(vgafb)
	ldi	XL, 0x01
	ldi	XH, 0x05
	rcall	addXtoZ

	ldi	r16, 0xFF
	st	Z+, r16
	ldi	r16, 0xF1
	st	Z+, r16
	ldi	r16, 0x11
	st	Z+, r16
	ldi	r16, 0xFF
	st	Z+, r16
	ldi	r16, 0xFF
	st	Z+, r16
	ldi	r16, 0x11
	st	Z+, r16
	ldi	r16, 0x1F
	st	Z+, r16
	ldi	r16, 0xFF
	st	Z+, r16

	ldi	ZL, LOW(vgafb)
	ldi	ZH, HIGH(vgafb)
	ldi	XL, 0x51
	ldi	XH, 0x05
	rcall	addXtoZ

	ldi	r16, 0xFF
	st	Z+, r16
	ldi	r16, 0x11
	st	Z+, r16
	ldi	r16, 0x11
	st	Z+, r16
	ldi	r16, 0xFF
	st	Z+, r16
	ldi	r16, 0xFF
	st	Z+, r16
	ldi	r16, 0x11
	st	Z+, r16
	ldi	r16, 0x11
	st	Z+, r16
	ldi	r16, 0xFF
	st	Z+, r16

	ret


addXtoZ:
	add	ZL, XL
	adc	ZH, XH
	ret


