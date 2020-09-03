import sys;

# Open files
fin = open(sys.argv[1], "rb")
fout = open(sys.argv[2], "w")

# Skip
skip = 0;
if len(sys.argv)>=4:
	skip = int(sys.argv[3], 0);

# Take
take = 0;
if len(sys.argv)>=5:
	take = int(sys.argv[4], 0);
else:
	fin.seek(0,2)
	take = fin.tell() - skip

fin.seek(skip)

# Copy bytes
index = 0;
while take:
	byte = fin.read(1)
	if not byte:
		break;
	fout.write("x\"%02x\", " % ord(byte))

	if (index+1) % 16==0:
		fout.write("\n")
	index = index+1

	take -=1;

# Apply padding
while take>0:
	fout.write("00\n");
	take -= 1;