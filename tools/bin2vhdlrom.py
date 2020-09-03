import sys;
import os;

infilename = ""
outfilename = ""
entityName = "";
clken = False
width = 0

def parseInt(val):
	if len(val)>2 and val[0:2]=="0x":
		return int(val, 16)
	else:
		return int(val)

for arg in sys.argv[1:]:

	if arg=="--clken":
		clken = True
	elif arg[:12]=="--addrwidth:":
		width = parseInt(arg[12:])
	elif arg[:7]=="--name:":
		entityName = parseInt(arg[7:])
	elif infilename=="":
		infilename = arg
	elif outfilename=="":
		outfilename = arg
	else:
		print("unknown arg: %s" % arg)
		sys.exit(7)

if infilename=="":
	print("usage: bin2vhdlrom <inputfile> [<outputfile>] [--addrwidth:<startaddr>] [--clken] [--name:<name>]\n\n");
	sys.exit(0);

# Work out length of source file
length = os.stat(infilename).st_size

# Work out width
if width==0:
	width=1
	while 2**width < length:
		width = width + 1

if length > 2**width:
	print("Address width too narrow %i bytes > 2^%i (%i)\n\n" % (length, width, 2**width));
	sys.exit(0);

# Round up the length
length=2**width

# Open files
fin = open(infilename, "rb")
if outfilename=="":
	fout = sys.stdout
else:
	fout = open(outfilename, "w")

# Work out entity name
if entityName=="":
	if outfilename=="":
		entityName = os.path.splitext(os.path.split(infilename)[1])[0]
	else:
		entityName = os.path.splitext(os.path.split(outfilename)[1])[0]


fout.write("library ieee;\n")
fout.write("use ieee.std_logic_1164.ALL;\n")
fout.write("use ieee.numeric_std.ALL;\n")
fout.write("\n")
fout.write("\n")
fout.write("entity %s is\n" % entityName)
fout.write("	port\n")
fout.write("	(\n")
fout.write("		clock : in std_logic;\n")
if clken:
	fout.write("		clken : in std_logic;\n")
fout.write("		addr : in std_logic_vector(%i downto 0);\n" % (width-1))
fout.write("		dout : out std_logic_vector(7 downto 0)\n")
fout.write("	);\n")
fout.write("end %s;\n" % entityName)
fout.write(" \n")
fout.write("architecture behavior of %s is \n" % entityName)
fout.write("	type mem_type is array(0 to %i) of std_logic_vector(7 downto 0);" % (length-1))
fout.write("	signal rom : mem_type := \n")
fout.write("	(\n\t")

# Copy bytes
index = 0;
while length:
	byte = fin.read(1)
	if not byte:
		byte = "\0";
	fout.write("x\"%02x\"" % ord(byte))

	if length>1:
		fout.write(", ")

	if (index+1) % 16==0:
		fout.write("\n\t")
	index = index+1

	length -=1;


fout.write("\n	);\n")
fout.write("begin\n")
fout.write("\n")
fout.write("	process (clock)\n")
fout.write("	begin\n")
fout.write("		if rising_edge(clock) then\n")

if clken:
	fout.write("			if clken='1' then\n")
	fout.write("				dout <= rom(to_integer(unsigned(addr)));\n")
	fout.write("			end if;\n")
else:
	fout.write("			dout <= rom(to_integer(unsigned(addr)));\n")

fout.write("		end if;\n")
fout.write("	end process;\n")
fout.write("end;\n\n")