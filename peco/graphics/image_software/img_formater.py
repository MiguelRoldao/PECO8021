from PIL import Image

img = Image.open("2nd_gen_pokemon.png")

w = 20
h = 13

pokemon = {}

for iy in range(h):
	for ix in range(w):
		pokemon[ix + iy*w] = img.crop((ix*56, iy*56, 56 + ix*56, 56 + iy*56))


out_file = open("venusaur.bin", "wb")

pixels = pokemon[2].load()


header = [0x20, 56, 56, 0x03, 0x8f]
out_file.write(bytearray(header))

for iy in range(56):
	for ix in range(56):
		out_file.write(pixels[ix,iy])
