OBJ		= main
OUTDIR		= bin
SRCDIR		= src

AVR		= avrasm2
AFLAGS		= -fI -I /usr/local/include/avr

UPDI		= ~/pymcuprogenv/bin/pymcuprog
UFLAGS		= -t uart
DEVICE		= avr128db28
USBPORT		= /dev/ttyUSB0

DUMP		= avr-objdump
DFLAGS		= -D -s -m avr


all: assemble

assemble:
	$(AVR) $(AFLAGS) -o $(OUTDIR)/$(OBJ).hex $(SRCDIR)/$(OBJ).asm

flash:
	$(UPDI) erase -d $(DEVICE) $(UFLAGS) -u $(USBPORT) -m flash
	$(UPDI) write -d $(DEVICE) $(UFLAGS) -u $(USBPORT) -f $(OUTDIR)/$(OBJ).hex

reflash: assemble flash

read-fuses:
	$(UPDI) read -d $(DEVICE) $(UFLAGS) -u $(USBPORT) -m fuses

clean:
	rm -rf *.hex
	rm -rf $(OUTDIR)/*.hex

dump:
	$(DUMP) $(DFLAGS) $(OUTDIR)/$(OBJ).hex
