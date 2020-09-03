import sys;

fout = open(sys.argv[1], "wb")
len = int(sys.argv[2])
byte = int(sys.argv[3])

print len
print byte

for i in range(len):
	fout.write("%c" % byte)

