import png, array

reader = png.Reader(filename='StatusFont.png')
w, h, pixels, metadata = reader.read_flat()
bytes_per_pixel = 4 if metadata['alpha'] else 3

fout = open('StatusFont.bin', "wb")

for row in range(2):
	for col in range(16):
		for scanline in range(12):
			byte = 0
			for sx in range(8):
				pixel_index = (row * 12 + scanline) * w + col * 8 + sx
				if pixels[pixel_index * bytes_per_pixel]==0:
					byte = byte | (1 << (7-sx))
			fout.write("%c" % (byte & 0xFF))
		fout.write("%c%c%c%c" % (0,0,0,0))


