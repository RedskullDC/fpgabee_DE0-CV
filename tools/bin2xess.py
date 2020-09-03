import sys;
import os;

infilename = ""
outfilename = ""
interleave = False
addr = 0

def parseInt(val):
	if len(val)>2 and val[0:2]=="0x":
		return int(val, 16)
	else:
		return int(val)

for arg in sys.argv[1:]:

	if arg=="--interleave":
		interleave = True
	elif arg[:7]=="--addr:":
		addr = parseInt(arg[7:])
	elif infilename=="":
		infilename = arg
	elif outfilename=="":
		outfilename = arg
	else:
		print("unknown arg: %s" % arg)
		sys.exit(7)

if infilename=="":
	print("usage: bin2xess <inputfile> [<outputfile>] [--addr:<startaddr>] [--interleave]\n\n");
	sys.exit(0);

# work out length of source file
length = os.stat(infilename).st_size

# Open files
fin = open(infilename, "rb")
if outfilename=="":
	fout = sys.stdout
else:
	fout = open(outfilename, "w")

# Generate output
if interleave:

	while length:

		line_length = min(8,length)

		fout.write("+ %02x %08x" % (line_length * 2, addr))

		for i in range(line_length):
			byte = fin.read(1)
			fout.write(" 00 %02x" % ord(byte))

		fout.write("\n");

		length = length - line_length
		addr = addr + line_length*2

else:

	while length:

		line_length = min(16,length)

		fout.write("+ %02x %08x" % (line_length, addr))

		for i in range(line_length):
			byte = fin.read(1)
			fout.write(" %02x" % ord(byte))

		fout.write("\n");

		length = length - line_length
		addr = addr + line_length	
