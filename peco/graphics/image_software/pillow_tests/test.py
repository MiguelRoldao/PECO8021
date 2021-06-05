import os, sys
from PIL import Image
import argparse

### bit operations ###
def conc(msnibble, lsnibble):
	byte = msnibble*16 + lsnibble
	return byte 


### image functions ###
def rgb2rbgg(red, green, blue):
	color = 0
	if red >= 128:
		color += 8
	if blue >= 128:
		color += 4
	if green >= 192:
		color += 3
	elif green >= 128:
		color += 2
	elif green >= 64:
		color += 1
	return color


def raw2rbgg(raw, width, height):
	image = raw.copy()
	for iy in range(height):
		for ix in range(width):
			rbgg = rgb2rbgg( \
				raw[ix + iy*width][0], \
				raw[ix + iy*width][1], \
				raw[ix + iy*width][2] \
			)
			image[ix + iy*width] = rbgg
	return image


def getRaw(image):
	pixels = image.load()
	image_raw = []
	if image.mode == "P":
		print("Image has a color palette.")
		_palette_list = image.getpalette()
		palette = []
		for i in range(256):
			color = [0,0,0]
			color[0] = _palette_list[i*3 + 0]
			color[1] = _palette_list[i*3 + 1]
			color[2] = _palette_list[i*3 + 2]
			if color[0] == i and color[1] == i and color[2] == i and i != 0:
				break
			palette.append(color)
		print(palette, f"i = {len(palette)}")
		
		quantized_pal = []
		for i in range(len(palette)):
			color = rgb2rbgg(palette[i][0], palette[i][1], palette[i][2])
			quantized_pal.append(color)

		ncolors = len(palette)

		for iy in range(image.height):
			for ix in range(image.width):
				pixel = palette[pixels[ix, iy]]
				image_raw.append(pixel)

	else:	# not indexed
		print(f"Image doesn't have a color palette ({image.mode}).")

		for iy in range(image.height):
			for ix in range(image.width):
				pixel = pixels[ix, iy]
				image_raw.append(pixel)

	return image_raw


# reorganize image so that it is organized by single tiles and not the whole image
def makeTileset(image, image_w, image_h, tile_w, tile_h):
	tileset = []

	tileset_w = int(image_w/tile_w)
	tileset_h = int(image_h/tile_h)
	n_tiles = tileset_w * tileset_h
	
	for iytile in range(tileset_h):
		for ixtile in range(tileset_w):
			for iy in range(tile_h):
				for ix in range(tile_w):
					tileset.append(image[ \
						ix + \
						iy * image_w + \
						ixtile * tile_w + \
						iytile * tile_h * image_w \
					])
	
	return tileset


#
# palettize image to reduce size
# palette should be 4 or 2 colors
#
def reducePalette(image, width, height):
	used_colors = set()
	for iy in range(height):
		for ix in range(width):
			used_colors.add(image[ix + iy*width])

	print(f"Used colors are {used_colors}, n = {len(used_colors)}")

	palette = []
	for i in used_colors:
		palette.append(i)
		print(i)
	print(palette)

	return palette


def makeHeader(image, width, height, isCompressed, isTileset):
	if isCompressed and isTileset:
		raise Exception("Image cannot be compressed and a tileset at the same time")
	palette = reducePalette(image, width, height)
	if len(palette) > 4:
		header = bytearray(3)
		if isTileset:
			pass



def main(argv):

	# deal with arguments

	#print("Number of arguments", len(sys.argv))
	#print("Argument list:", sys.argv)

	text = "This program allows to convert images to PECO-8021 compatible image formats."
	parser = argparse.ArgumentParser(description=text)
	parser.add_argument("-t", "--tileset", help="If image is a tileset, specify how many tiles are there.")
	parser.add_argument("-W", "--width", help="If image is a tileset, specify the width of a single tile.")
	parser.add_argument("-H", "--height", help="If image is a tileset, specify the height of a single tile.")
	parser.add_argument("-i", "--input", help="Path to input image.")
	parser.add_argument("-c", "--compress", help="Compress image. Not compatible with tilesets!", action="store_true")
	parser.add_argument("-p", "--palette", help="Specify what colour palette to use on the conversion, in format: \"0x0123\"")
	args = parser.parse_args()
	
	print("The image is a tilesetwith %s tiles!" % args.tileset)
	print(args.tileset, args.width, args.height, args.input, args.compress)

	assert (args.tileset and args.width and args.height) or (not args.tileset), "Specify tileset width and height."
	
	
	
	
	
	#infilename = sys.argv[1]
	infilename = args.input

	f, e = os.path.splitext(infilename)
	outfilename = f + ".pimg"

	img = Image.open(infilename)
	out_file = open(outfilename, "wb")


	#
	# create a list of the colors of the image independent of format
	# img_data format is rbgg
	#
	img_data = getRaw(img)


	# quantify to rbgg
	img_rbgg = raw2rbgg(img_data, img.width, img.height)


	# img_data contains list of colors formatted to rbgg
	print(img_rbgg, f"i = {len(img_data)}\n")


	# create header of image file
	header = bytearray(3)
	header[0] = 0x00
	header[1] = img.width
	header[2] = img.height

	# if image is a tileset, reorganize it so that img_rbgg is organized by tiles and not lines
	#if len(sys.argv) > 4 and sys.argv[2] == "tileset":
	#	img_rbgg = makeTileset(img_rbgg, img.width, img.height, int(sys.argv[3]), int(sys.argv[4]))
	if args.tileset:
		tile_w = int(args.width)
		tile_h = int(args.height)
		n_tiles = int(args.tileset)
		tile_size = int(tile_w * tile_h / 8)
		tile_size += 0 if tile_w * tile_h % 8 == 0 else 1	# haven't tested this
		
		img_rbgg = makeTileset(img_rbgg, img.width, img.height, tile_w, tile_h)
		header[0] |= 0x04
		header[1] = tile_w
		header[2] = tile_h
		header.append(n_tiles)
		header.append(tile_size)
	elif args.compress:
		pass
	
	
	colors = reducePalette(img_rbgg, img.width, img.height)
	if args.palette:
		numpal = int(args.palette, 16)
		pal = [ int(numpal/0x1000) % 16, int(numpal/0x100) % 16, int(numpal/0x10) % 16, numpal % 16 ]
		print(numpal, pal)
		for i in range(len(colors)):
			colors[i] = pal[i]
	
	print(colors)
	
	
	
	
	if len(colors) > 4:
		#header = bytearray(3)
		#header[0] = 0x00
		#header[1] = img.width
		#header[2] = img.height
		out_file.write(header)

		for iy in range(img.height):
			for ix in range(int(img.width/2)):
				byte = bytes([conc( \
					img_rbgg[ix*2 + iy*img.width], \
					img_rbgg[1 + ix*2 + iy*img.width] \
				)])
				out_file.write(byte)


	elif len(colors) > 2:
		while len(colors) < 4:
			colors.append(0)
		#header = bytearray(3)
		#header[0] = 0x20
		#header[1] = img.width
		#header[2] = img.height
		#header[3] = conc(colors[0], colors[1])
		#header[4] = conc(colors[2], colors[3])
		header[0] |= 0x01
		out_file.write(header)

		data_indexed = []
		for i in range(len(img_rbgg)):
			for ic in range(len(colors)):
				if colors[ic] == img_rbgg[i]:
					data_indexed.append(ic)
					
		print(data_indexed)
		for iy in range(img.height):
			for ix in range(int(img.width/4)):
				byte = bytes([ \
					data_indexed[ix*4 + iy*img.width]*64 + \
					data_indexed[1 + ix*4 + iy*img.width]*16 + \
					data_indexed[2 + ix*4 + iy*img.width]*4 + \
					data_indexed[3 + ix*4 + iy*img.width] \
				])
				out_file.write(byte)

	else:
		while len(colors) < 2:
			colors.append(0)
		#header = bytearray(3)
		#header[0] = 0x40
		#header[1] = img.width
		#header[2] = img.height
		#header[3] = conc(colors[0], colors[1])
		header[0] |= 0x02
		out_file.write(header)

		data_indexed = []
		for i in range(len(img_rbgg)):
			for ic in range(len(colors)):
				if colors[ic] == img_rbgg[i]:
					data_indexed.append(ic)
					
		print("b4 write")
		print(data_indexed)
		print("gon write", img.height, int(img.width/8))
		
		for i in range(int(len(data_indexed)/8)):
			byte = bytes([ \
				data_indexed[0 + i*8]*128 + \
				data_indexed[1 + i*8]*64 + \
				data_indexed[2 + i*8]*32 + \
				data_indexed[3 + i*8]*16 + \
				data_indexed[4 + i*8]*8 + \
				data_indexed[5 + i*8]*4 + \
				data_indexed[6 + i*8]*2 + \
				data_indexed[7 + i*8] \
			])
			out_file.write(byte)
			
		#for iy in range(img.height):
		#	for ix in range(int(img.width/8)):
		#		byte = bytes([ \
		#			data_indexed[0 + ix*8 + iy*img.width]*128 + \
		#			data_indexed[1 + ix*8 + iy*img.width]*64 + \
		#			data_indexed[2 + ix*8 + iy*img.width]*32 + \
		#			data_indexed[3 + ix*8 + iy*img.width]*16 + \
		#			data_indexed[4 + ix*8 + iy*img.width]*8 + \
		#			data_indexed[5 + ix*8 + iy*img.width]*4 + \
		#			data_indexed[6 + ix*8 + iy*img.width]*2 + \
		#			data_indexed[7 + ix*8 + iy*img.width] \
		#		])
		#		out_file.write(byte)


if __name__ == "__main__":
	main(sys.argv[1:])






