#include "precomp.h"
#include "fbfs.h"

void show_usage()
{
	printf("fbfs v1.0 - FPGABee File System Utility\n");
	printf("Copyright (C) 2013 Topten Software.  All Rights Reserved\n\n");
	printf("Usage: fbfs <fsimage> <command> [args]\n\n");
	printf("    fsimage            image of the fbfs file system to work with\n");
	printf("    command            see commands below\n");
	printf("    args               additional command argument\n");
	printf("\n");
	printf("Commands:\n");
	printf("\n");
	printf("    format                          create a new fbfs file system\n");
	printf("    ls [<spec>]                     list files in fsimage\n");
	printf("    add <file> [newname]            add file to fsimage\n");
	printf("    extract <file> [<diskimage>]    extract file from fsimage\n");
	printf("    mv <oldfile> <newfile>          rename file in fsimage\n");
	printf("    rm <file>                       remove file from fsimage\n");
	printf("    select system <file>            specify file containing PCU sys image\n");
	printf("    select disk <drive> <file>      insert disk image into drive\n");
	printf("    select rom <pak> <file>         insert rom into pak slot\n");
	printf("    select                          display selected system, rom and disks\n");
	printf("    transfer <newimage>             transfer entire file system to newimage\n");
	printf("\n");
	printf("eg:\n");
	printf("\n");
	printf("    fbfs myfs.fbfs format\n");
	printf("    fbfs myfs.fbfs add fpgabee_system.bin\n");
	printf("    fbfs myfs.fbfs add hd.hd0\n");
	printf("    fbfs myfs.fbfs add hd18.rom\n");
	printf("    fbfs myfs.fbfs add blank.ds40\n");
	printf("    fbfs myfs.fbfs select system fbgabee_system.bin\n");
	printf("    fbfs myfs.fbfs select rom 0 hd18.rom\n");
	printf("    fbfs myfs.fbfs select disk 1 hd.hd0\n");
	printf("    fbfs myfs.fbfs select disk 4 blank.ds40\n");
	printf("    fbfs myfs.fbfs ls\n");
	printf("    fbfs myfs.fbfs select\n");
	printf("    fbfs myfs.fbfs transfer k:\n");
	printf("\n");
}

int show_error(int error, const char* action)
{
	if (error==0)
		return 0;

	fprintf(stderr, "\nFailed to %s - error %i\n", action, error);
	return error;
}

#define RIF(x, msg) { int _res=x; if (_res!=0) return show_error(_res, msg); }

int invoke_format(int argc, char* argv[])
{
	FbfsImage fs;
	RIF(fs.Create(argv[1]), "create image");
	RIF(fs.Close(), "flush changes");

	printf("\nFormatted: %s\n", argv[1]);

	return 0;
}

int invoke_ls(int argc, char* argv[])
{
	FbfsImage fs;
	RIF(fs.Open(argv[1], true), "open image");

	CVector<FbfsDirEntry*> matches;
	fs.ls(argc>3 ? argv[3] : NULL, matches);
	printf("%8s %8s %8s %-30s\n", "blk#", "blks", "size", "filename");
	printf("----------------------------------------------------\n");
	for (int i=0; i<matches.GetSize(); i++)
	{
		FbfsDirEntry* dir = matches[i];

		printf("%8u %8u %8u %-30s\n", dir->block, dir->block_count, BLOCK_SIZE * dir->block_count, dir->filename);
	}
	
	printf("\nTotal %i files\n", matches.GetSize());

	return 0;
}

int invoke_add(int argc, char* argv[])
{
	if (argc<4)
	{
		fprintf(stderr, "Insufficient arguments for add command\n");
		return 7;
	}

	FbfsImage fs;
	RIF(fs.Open(argv[1], false), "open image");
	RIF(fs.add(argv[3],argc>=5 ? argv[4] : argv[3]), "add file");
	RIF(fs.Close(), "flush changes");

	printf("\nAdded: %s\n", argv[3]);
	return 0;
}

int invoke_extract(int argc, char* argv[])
{
	if (argc<4)
	{
		fprintf(stderr, "Insufficient arguments for add command\n");
		return 7;
	}

	FbfsImage fs;
	RIF(fs.Open(argv[1], true), "open image");
	RIF(fs.extract(argv[3],argc>=5 ? argv[4] : argv[3]), "extract file");
	fs.Close();

	printf("\nExtracted: %s\n", argv[3]);
	return 0;
}

int invoke_rm(int argc, char* argv[])
{
	if (argc<4)
	{
		fprintf(stderr, "Insufficient arguments for rm command\n");
		return 7;
	}

	FbfsImage fs;
	RIF(fs.Open(argv[1], false), "open image");
	RIF(fs.rm(argv[3]), "remove file");
	RIF(fs.Close(), "flush changes");

	printf("\nRemoved: %s\n", argv[3]);
	return 0;
}

void show_selections(FbfsImage& fs)
{
	printf("System:  %s\n", fs.get_selected_system().sz());

	for (int i=0; i<NUM_ROM_SLOTS; i++)
	{
		printf("ROM %i:   %s\n", i, fs.get_selected_rom(i).sz());
	}

	for (int i=0; i<NUM_DRIVE_SLOTS; i++)
	{
		printf("Drive %i: %s\n", i, fs.get_selected_disk(i).sz());
	}
}

int invoke_select(int argc, char* argv[])
{
	// Open image
	FbfsImage fs;
	RIF(fs.Open(argv[1], false), "open image");

	if (argc>=4)
	{
		if (IsEqualStringI(argv[3], "rom"))
		{
			if (argc<6)
			{
				fprintf(stderr, "Command 'select rom' requires pack index and filename\n");
				return 7;
			}

			int index = atoi(argv[4]);
			const char* filename = IsEqualStringI(argv[5], "none") ? NULL : argv[5];
			RIF(fs.select_rom(index, filename), "select rom image");
		}
		else if (IsEqualStringI(argv[3], "disk"))
		{
			if (argc<6)
			{
				fprintf(stderr, "Command 'select disk' requires drive index and filename\n");
				return 7;
			}

			int index = atoi(argv[4]);
			const char* filename = IsEqualStringI(argv[5], "none") ? NULL : argv[5];
			RIF(fs.select_disk(index, filename), "select disk image");
		}
		else if (IsEqualStringI(argv[3], "system"))
		{
			if (argc<5)
			{
				fprintf(stderr, "Command 'select disk' requires filename\n");
				return 7;
			}

			const char* filename = IsEqualStringI(argv[4], "none") ? NULL : argv[4];
			RIF(fs.select_system(filename), "select system image");
		}
		else
		{
			fprintf(stderr, "Invalid command 'select %s'\n", argv[3]);
			return 7;
		}
	}

	show_selections(fs);

	RIF(fs.Close(), "flush changes");
	return 0;

}

int invoke_transfer(int argc, char* argv[])
{
	// Check args
	if (argc<4)
	{
		fprintf(stderr, "Insufficient arguments for transfer command\n");
		return 7;
	}

	// Open the source image
	FbfsImage fsSource;
	RIF(fsSource.Open(argv[1], true), "open source image");

	// Create the target image
	FbfsImage fsDest;
	RIF(fsDest.Create(argv[3]), "create target image");

	// Copy all files
	CVector<FbfsDirEntry*> matches;
	fsSource.ls(NULL, matches);
	for (int i=0; i<matches.GetSize(); i++)
	{
		FbfsDirEntry* dirSource = matches[i];

		FbfsDirEntry* dirTarget;
		RIF(fsDest.add(dirSource->filename, dirSource->block_count, &dirTarget), "create target file");

		fcopy(fsDest.SeekBlock(dirTarget->block), fsSource.SeekBlock(dirSource->block), dirTarget->block_count);		
		printf("Copied %s\n", dirTarget->filename);
	}

	printf("\nCopied %i files\n\n", matches.GetSize());
	
	// Copy selections
	printf("Copying configuration data...\n\n");
	fsDest.select_system(fsSource.get_selected_system());
	for (int i=0; i<NUM_ROM_SLOTS; i++)
		fsDest.select_rom(i, fsSource.get_selected_rom(i));
	for (int i=0; i<NUM_DRIVE_SLOTS; i++)
		fsDest.select_disk(i, fsSource.get_selected_disk(i));

	show_selections(fsDest);

	printf("\nFile system transferred\n");

	return 0;

}

int main(int argc, char* argv[])
{
	if (argc<3)
	{
		show_usage();
		return 7;
	}

	if (IsEqualString(argv[2], "format"))
	{
		return invoke_format(argc, argv);
	}
	if (IsEqualStringI(argv[2], "ls"))
	{						 
		return invoke_ls(argc,argv);
	}
	if (IsEqualStringI(argv[2], "add"))
	{
		return invoke_add(argc, argv);
	}
	if (IsEqualStringI(argv[2], "extract"))
	{
		return invoke_extract(argc, argv);
	}
	if (IsEqualStringI(argv[2], "rm"))
	{
		return invoke_rm(argc, argv);
	}
	if (IsEqualStringI(argv[2], "select"))
	{
		return invoke_select(argc, argv);
	}

	if (IsEqualStringI(argv[2], "transfer"))
	{
		return invoke_transfer(argc, argv);
	}

	return 0;
}
				
