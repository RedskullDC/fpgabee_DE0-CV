//////////////////////////////////////////////////////////////////////////
// fbfs.h - declaration of fbfs

#ifndef __FBFS_H
#define __FBFS_H

#define FBFS_E_NOERROR			0
#define FBFS_E_NOTIMPL			1		// Feature not implemented
#define FBFS_E_FILEFORMAT		2		// Not an FBFS file
#define FBFS_E_NOTFOUND			3		// File not found
#define FBFS_E_ALREADYEXISTS	4		// File already exists
#define FBFS_E_CANTCREATEFILE	5		// Error creating file
#define FBFS_E_CANTOPENFILE		6		// Can't open file
#define FBFS_E_READ				7		// Error reading file
#define FBFS_E_WRITE			8		// Error writing file
#define FBFS_E_DIRECTORY		9		// Error updating directory
#define FBFS_E_READONLY			10		// File was opened read only
#define FBFS_E_FILENAME			11		// Invalid filename
#define FBFS_E_UNEXPECTED		12		// Image not open
#define FBFS_E_INVALIDARG		13		// Invalid argument value
									

typedef unsigned int	uint32_t;
typedef unsigned short  uint16_t;

#define FBFS_SIGNATURE (('s' << 24) | ('f' << 16) | ('b' << 8) | 'f')
#define FBFS_VERSION 0x100
#define BLOCK_SIZE 512
#define DIR_ENTRIES_PER_BLOCK (BLOCK_SIZE / sizeof(DIRENTRY))
#define MAX_DIR_ENTRIES 128

#define NUM_DRIVE_SLOTS		7
#define NUM_ROM_SLOTS		3


bool does_match_wildcard(const char* w, const char* p);
int fcopy(FILE* fd, FILE* fs, int blocks);

#pragma pack(1)

struct CONFIG
{
	uint32_t	signature;			// Signature identifying file system - "fbfs"
	uint16_t	version;			// fbfs version - 0x0100
	uint32_t	dir_block;			// directory block
	uint16_t	dir_block_count;	// directory block count
	uint16_t	system_image;		// dirid the system image
	uint16_t	rom_images[NUM_ROM_SLOTS];		// dirid to 3 rom images (pak A, B, C)
	uint16_t	disk_images[NUM_DRIVE_SLOTS];	// dirids to selected disk images
};

struct DIRENTRY
{
	uint32_t	block;				// Starting block number
	uint16_t	block_count;		// Block count
	uint32_t	resvd;				// Reserved
	char		filename[22];		// File name, space padded
};			
#pragma pack()

class FbfsDirEntry : public DIRENTRY
{
public:
	static int CompareByBlock(FbfsDirEntry* const& a, FbfsDirEntry* const& b)
	{
		if (a->block < b->block)
			return -1;
		else
			return 1;
	}
	static int CompareByName(FbfsDirEntry* const& a, FbfsDirEntry* const& b)
	{
		return _strcmpi(a->filename, b->filename);
	}
};

class FbfsImage
{
public:
			FbfsImage();
	virtual ~FbfsImage();

	int Create(const char* filename);
	int Open(const char* filename, bool readOnly);
	int WriteChanges();
	int Close();


	int ls(const char* spec, CVector<FbfsDirEntry*>& results);
	int add(const char* fbfs_filename, uint16_t num_blocks, FbfsDirEntry** ppNewEntry);
	int add(const char* fbfs_filename, const char* filename);
	int extract(const char* fbfs_filename, const char* filename);
	int rm(const char* fbfs_filename);
	int mv(const char* fbfs_filename_old, const char* fbfs_filename_new);
	int select_disk(int driveNumber, const char* fbfs_filename);
	int select_rom(int pack, const char* fbfs_filename);
	int select_system(const char* fbfs_filename);
	CAnsiString get_selected_disk(int driveNumber);
	CAnsiString get_selected_rom(int pack);
	CAnsiString get_selected_system();
	int format();

	FILE* SeekBlock(uint32_t block);

protected:
	FbfsDirEntry* FindDirEntry(const char* fbfs_filename);
	FbfsDirEntry* FindDirEntry(uint16_t dirid);
	CAnsiString FindDirEntryName(uint16_t dirid);
	uint16_t MakeDirID(const char* filename);
	void FileRenamed(const char* fbfs_oldname, const char* fbfs_newname);

	void SortDirectoryByBlockNumber();
	void SortDirectoryByName();

	FILE*	_file;
	bool	_readonly;
	bool	_dirty;
	CONFIG _config;
	CVector<FbfsDirEntry*, SOwnedPtr> _directory;
	CAnsiString _filename;

	CAnsiString _systemImage;
	CAnsiString _romImages[NUM_ROM_SLOTS];
	CAnsiString _diskImages[NUM_DRIVE_SLOTS];
};


#endif	// __FBFS_H

