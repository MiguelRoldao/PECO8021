

	.macro	stackInit		; @0 - stack pointer address, @1 - register
	.if @0>RAMEND
	.error "Stack pointer can't be higher than RAMEND"
	.else
	ldi	@1, LOW(@0)
	out	CPU_SPL, @1
	ldi	@1, HIGH(@0)
	out	CPU_SPH, @1
	.endif
	.endmacro
