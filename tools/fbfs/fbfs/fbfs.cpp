//////////////////////////////////////////////////////////////////////////
// fbfs.cpp - implementation of fbfs

#include "precomp.h"
#include "fbfs.h"

//////////////////////////////////////////////////////////////////////////
// Utility function

bool does_match_wildcard(const char* w, const char* p)
{
	// Compare characters
	while (true)
	{
		// End of both strings?
		if (*w=='\0' && *p=='\0')
			return true;

		// End of one string?
		if (*w=='\0' || *p=='\0')
			return false;

		// Single character wildcard
		if (*w=='?')
		{
			w++;
			p++;
			continue;
		}

		// Multi-character wildcard
		if (*w=='*')
		{
			w++;
			while (*p)
			{
				if (does_match_wildcard(w, p))
					return true;
				p++;
			}
			return false;
		}

		// Same character?
		if (toupper(*w)!=toupper(*p))
			return false;

		// Next
		w++;
		p++;
	}
}

int fcopy(FILE* fd, FILE* fs, int blocks)
{
	char buf[BLOCK_SIZE];
	for (int i=0; i<blocks; i++)
	{
		memset(buf, 0, sizeof(buf));
		fread(buf, BLOCK_SIZE, 1, fs);
		if (fwrite(buf, BLOCK_SIZE, 1, fd)!=1)
			return FBFS_E_WRITE;
	}
	return FBFS_E_NOERROR;
}

bool IsValidFilename(const char* psz)
{
	if (strchr(psz, '/'))
		return false;
	if (strchr(psz, '\\'))
		return false;
	if (strchr(psz, '?'))
		return false;
	if (strchr(psz, '*'))
		return false;
	if (strlen(psz)>sizeof(((DIRENTRY*)NULL)->filename)-1)
		return false;
	return true;
}

//////////////////////////////////////////////////////////////////////////
// FbfsImage

FbfsImage::FbfsImage()
{
	_file = NULL;
	_dirty = false;
}

FbfsImage::~FbfsImage()
{
	if (_file!=NULL)
		Close();
}

int FbfsImage::Create(const char* pszFileName)
{
	if (_file)
		return FBFS_E_UNEXPECTED;


	// Create the file
#ifdef _WIN32
	if (pszFileName && pszFileName[1]==':')
	{
		// Convert to volumne name
		char volname[20];
		sprintf(volname, "\\\\.\\%c:", pszFileName[0]);

		HANDLE vol_handle = CreateFileA(volname, GENERIC_READ | GENERIC_WRITE,
							FILE_SHARE_READ | FILE_SHARE_WRITE, NULL,
							OPEN_EXISTING,
							FILE_FLAG_NO_BUFFERING | FILE_FLAG_RANDOM_ACCESS,
							NULL);

		if (vol_handle == INVALID_HANDLE_VALUE)
		{
			return FBFS_E_CANTCREATEFILE;
		}

		int crt_handle = _open_osfhandle((intptr_t)vol_handle, 0);
		_file = _fdopen(crt_handle, "wb+");
	}
	else
#endif
	{
		_file = fopen(pszFileName, "wb+");
	}

	if (_file==NULL)
		return FBFS_E_CANTCREATEFILE;

	// Setup
	_readonly = false;
	_dirty = true;
	_filename = pszFileName;

	// Setup default config
	memset(&_config, 0, sizeof(_config));
	_config.signature = FBFS_SIGNATURE;
	_config.version = FBFS_VERSION;
	_config.dir_block = 1;
	_config.dir_block_count = (MAX_DIR_ENTRIES * sizeof(DIRENTRY)) / BLOCK_SIZE;

	// Done
	return FBFS_E_NOERROR;
}

int FbfsImage::Open(const char* pszFileName, bool readonly)
{
	if (_file)
		return FBFS_E_UNEXPECTED;

	// Open the file
#ifdef _WIN32
	if (pszFileName && pszFileName[1]==':')
	{
		// Convert to volumne name
		char volname[20];
		sprintf(volname, "\\\\.\\%c:", pszFileName[0]);

		HANDLE vol_handle = CreateFileA(volname, GENERIC_READ | (readonly ? 0 : GENERIC_WRITE),
							FILE_SHARE_READ | (readonly ? 0 : FILE_SHARE_WRITE), NULL,
							OPEN_EXISTING,
							FILE_FLAG_NO_BUFFERING | FILE_FLAG_RANDOM_ACCESS,
							NULL);

		if (vol_handle == INVALID_HANDLE_VALUE)
		{
			return FBFS_E_CANTCREATEFILE;
		}

		int crt_handle = _open_osfhandle((intptr_t)vol_handle, 0);
		_file = _fdopen(crt_handle, readonly ? "rb" : "rb+");
	}
	else
#endif
	{
		_file = fopen(pszFileName, readonly ? "rb" : "rb+");
	}
	if (_file==NULL)
		return FBFS_E_CANTOPENFILE;

	// Setup 
	_filename = pszFileName;
	_readonly = readonly;
	_dirty = false;

	// Create config
	fseek(_file, 0, SEEK_SET);
	if (fread(&_config, sizeof(CONFIG), 1, _file)!=1)
	{
		Close();
		return FBFS_E_READ;
	}

	// Check signature and version
	if (_config.signature != FBFS_SIGNATURE || _config.version!=FBFS_VERSION)
	{
		Close();
		return FBFS_E_FILEFORMAT;
	}

	// Read all directory entries
	for (uint16_t i=_config.dir_block; i<_config.dir_block + _config.dir_block_count; i++)
	{
		// Read a block of directory entries
		DIRENTRY direntries[DIR_ENTRIES_PER_BLOCK];
		fseek(_file, i * BLOCK_SIZE, SEEK_SET);
		if (fread(direntries, BLOCK_SIZE, 1, _file)!=1)
		{
			Close();
			return FBFS_E_READ;
		}

		// Create objects
		for (int j=0; j<DIR_ENTRIES_PER_BLOCK; j++)
		{
			// Blank entry?
			if (direntries[j].block!=0)
			{
				// Create entry
				FbfsDirEntry* entry = new FbfsDirEntry();

				// Copy raw direntry data
				*static_cast<DIRENTRY*>(entry) = direntries[j];

				// Add to directory
				_directory.Add(entry);
			}
		}
	}

	// Load selected items
	_systemImage = FindDirEntryName(_config.system_image);
	for (int i=0; i<_countof(_romImages); i++)
	{
		_romImages[i] = FindDirEntryName(_config.rom_images[i]);
	}
	for (int i=0; i<_countof(_diskImages); i++)
	{
		_diskImages[i] = FindDirEntryName(_config.disk_images[i]);
	}

	// Done!
	return FBFS_E_NOERROR;
}

int FbfsImage::WriteChanges()
{
	// Quit if not modified
	if (!_dirty || !_file)
		return FBFS_E_NOERROR;

	// Sort the directory table by name
	SortDirectoryByName();

	// Write all directory blocks
	for (uint16_t i=_config.dir_block; i<_config.dir_block + _config.dir_block_count; i++)
	{
		// Write one block of directory entries
		DIRENTRY direntries[DIR_ENTRIES_PER_BLOCK];
		memset(direntries, 0, sizeof(direntries));

		// Setup the new block of directory entries
		for (int j=0; j<DIR_ENTRIES_PER_BLOCK; j++)
		{
			int entryNumber = j + (i-_config.dir_block) * DIR_ENTRIES_PER_BLOCK;
			if (entryNumber < _directory.GetSize())
			{
				// Copy in the entry
				direntries[j] = *static_cast<DIRENTRY*>(_directory.GetAt(entryNumber));
			}
			else
			{
				// Mark it empty
				memset(&direntries[j], 0, sizeof(DIRENTRY));
			}
		}

		// Write it
		fseek(_file, i * BLOCK_SIZE, SEEK_SET);
		if (fwrite(direntries, sizeof(direntries), 1, _file)!=1)
			return FBFS_E_WRITE;
	}

	// Setup selected images
	_config.system_image = MakeDirID(_systemImage);
	for (int i=0; i<_countof(_romImages); i++)
	{
		_config.rom_images[i] = MakeDirID(_romImages[i]);
	}
	for (int i=0; i<_countof(_diskImages); i++)
	{
		_config.disk_images[i] = MakeDirID(_diskImages[i]);
	}


	// Write the config record
	fseek(_file, 0, SEEK_SET);
	char buf[512];
	memset(buf, 0, 512);
	memcpy(buf, &_config, sizeof(CONFIG));

	fseek(_file, 0, SEEK_SET);
	if (fwrite(&buf, BLOCK_SIZE, 1, _file)!=1)
		return FBFS_E_WRITE;

	fflush(_file);


	// Clear dirty flag
	_dirty = false;

	return FBFS_E_NOERROR;
}


int FbfsImage::Close()
{
	if (_file!=NULL)
	{
		int retv = WriteChanges();
		if (retv!=0)
			return retv;
		fclose(_file);
		_file = NULL;
	}
	return 0;
}

void FbfsImage::SortDirectoryByBlockNumber()
{
	_directory.QuickSort(FbfsDirEntry::CompareByBlock);
}

void FbfsImage::SortDirectoryByName()
{
	_directory.QuickSort(FbfsDirEntry::CompareByName);
}


int FbfsImage::ls(const char* pszSpec, CVector<FbfsDirEntry*>& results)
{
	if (!_file)
		return FBFS_E_UNEXPECTED;

	for (int i=0; i<_directory.GetSize(); i++)
	{
		// Check matching filename
		if (pszSpec!=NULL && !does_match_wildcard(pszSpec, _directory[i]->filename))
			continue;

		// Add it
		results.Add(_directory[i]);
	}

	results.QuickSort(FbfsDirEntry::CompareByName);

	return FBFS_E_NOERROR;
}

int FbfsImage::add(const char* fbfs_filename, uint16_t num_blocks, FbfsDirEntry** ppNewEntry)
{
	if (!_file)
		return FBFS_E_UNEXPECTED;
	if (_readonly)
		return FBFS_E_READONLY;
	if (!IsValidFilename(fbfs_filename))
		return FBFS_E_FILENAME;

	SortDirectoryByBlockNumber();

	// Remove existing directory entry
	rm(fbfs_filename);

	// Find a contiguous unused range of blocks
	uint32_t b = _config.dir_block + _config.dir_block_count;
	for (int i=0; i<_directory.GetSize(); i++)
	{
		FbfsDirEntry* e = _directory[i];

		if (b + num_blocks <= e->block)
			break;

		b=e->block + e->block_count;
	}

	// Create new directory entry
	FbfsDirEntry* e = new FbfsDirEntry();
	e->block = b;
	e->block_count = num_blocks;
	e->resvd = 0;
	strncpy(e->filename, fbfs_filename, sizeof(e->filename));

	// Add to directory
	_directory.Add(e);
	_dirty = true;

	*ppNewEntry = e;
	
	// Return the file so it can be written to
	return FBFS_E_NOERROR;
}

int FbfsImage::add(const char* fbfs_filename, const char* pszFileName)
{
	if (!_file)
		return FBFS_E_UNEXPECTED;
	if (_readonly)
		return FBFS_E_READONLY;
	if (!IsValidFilename(fbfs_filename))
		return FBFS_E_FILENAME;

	// Open the file
	FILE* fs = fopen(pszFileName, "rb");
	if (fs==NULL)
		return FBFS_E_CANTOPENFILE;

	// Work out how long it is
	fseek(fs, 0, SEEK_END);
	uint32_t length = ftell(fs);
	fseek(fs, 0, SEEK_SET);

	// Convert to blocks
	uint16_t blocks = (uint16_t)((uint32_t)(length + BLOCK_SIZE-1) / BLOCK_SIZE);

	// Create the directory entry
	FbfsDirEntry* newEntry;
	int err = add(fbfs_filename, blocks, &newEntry);
	if (err)
	{
		fclose(fs);
		return err;
	}

	// Copy the data
	fcopy(SeekBlock(newEntry->block), fs, newEntry->block_count);

	// Done
	fclose(fs);
	return FBFS_E_NOERROR;
}

int FbfsImage::extract(const char* fbfs_filename, const char* pszFileName)
{
	if (!_file)
		return FBFS_E_UNEXPECTED;

	// Find the entry
	FbfsDirEntry* entry = FindDirEntry(fbfs_filename);
	if (entry==NULL)
		return FBFS_E_NOTFOUND;

	// Open output file
	FILE* fd=fopen(pszFileName==NULL ? fbfs_filename : pszFileName, "wb");

	// Seek to correct location
	fseek(_file, entry->block * BLOCK_SIZE, SEEK_SET);

	// Copy blocks
	fcopy(fd, _file, entry->block_count);

	// Close output file
	fclose(fd);

	return FBFS_E_NOERROR;
}

int FbfsImage::rm(const char* fbfs_filename)
{
	if (!_file)
		return FBFS_E_UNEXPECTED;
	if (_readonly)
		return FBFS_E_READONLY;

	// Find the directory entry
	FbfsDirEntry* entry = FindDirEntry(fbfs_filename);
	if (entry==NULL)
		return FBFS_E_NOTFOUND;

	// Remove it
	_directory.Remove(entry);
	_dirty = true;

	// Fix up referenced files
	FileRenamed(fbfs_filename, NULL);

	return FBFS_E_NOERROR;
}

int FbfsImage::mv(const char* fbfs_filename_old, const char* fbfs_filename_new)
{
	if (!_file)
		return FBFS_E_UNEXPECTED;
	if (_readonly)
		return FBFS_E_READONLY;
	if (!IsValidFilename(fbfs_filename_new))
		return FBFS_E_FILENAME;

	// Check doesn't already exist
	FbfsDirEntry* entry = FindDirEntry(fbfs_filename_new);
	if (entry!=NULL)
		return FBFS_E_ALREADYEXISTS;

	// Find the entry
	entry = FindDirEntry(fbfs_filename_old);
	if (entry==NULL)
		return FBFS_E_NOTFOUND;

	// Store new name
	strncpy(entry->filename, fbfs_filename_new, sizeof(entry->filename)-1);
	_dirty = true;

	// Fix up referenced files
	FileRenamed(fbfs_filename_old, fbfs_filename_new);

	// Done
	return FBFS_E_NOERROR;
}

int FbfsImage::select_disk(int driveNumber, const char* fbfs_filename)
{
	if (!_file)
		return FBFS_E_UNEXPECTED;
	if (_readonly)
		return FBFS_E_READONLY;
	if (driveNumber<0 || driveNumber>=NUM_DRIVE_SLOTS)
		return FBFS_E_INVALIDARG;
	if (fbfs_filename && !FindDirEntry(fbfs_filename))
		return FBFS_E_NOTFOUND;

	// Make sure not selected elsewhere
	FileRenamed(fbfs_filename, NULL);

	// Store it
	_diskImages[driveNumber] = fbfs_filename;
	_dirty = true;

	return FBFS_E_NOERROR;
}

int FbfsImage::select_rom(int pack, const char* fbfs_filename)
{
	if (!_file)
		return FBFS_E_UNEXPECTED;
	if (_readonly)
		return FBFS_E_READONLY;
	if (pack<0 || pack>=NUM_DRIVE_SLOTS)
		return FBFS_E_INVALIDARG;
	if (fbfs_filename && !FindDirEntry(fbfs_filename))
		return FBFS_E_NOTFOUND;

	// Make sure not selected elsewhere
	FileRenamed(fbfs_filename, NULL);

	// Store it
	_romImages[pack] = fbfs_filename;
	_dirty = true;

	return FBFS_E_NOERROR;
}

int FbfsImage::select_system(const char* fbfs_filename)
{
	if (!_file)
		return FBFS_E_UNEXPECTED;
	if (_readonly)
		return FBFS_E_READONLY;
	if (fbfs_filename &&  !FindDirEntry(fbfs_filename))
		return FBFS_E_NOTFOUND;

	// Make sure not selected elsewhere
	FileRenamed(fbfs_filename, NULL);

	// Store it
	_systemImage = fbfs_filename;
	_dirty = true;

	return FBFS_E_NOERROR;
}

CAnsiString FbfsImage::get_selected_disk(int driveNumber)
{
	if (!_file)
		return NULL;
	if (driveNumber<0 || driveNumber>=NUM_DRIVE_SLOTS)
		return NULL;

	return _diskImages[driveNumber];
}

CAnsiString FbfsImage::get_selected_rom(int pack)
{
	if (!_file)
		return NULL;
	if (pack<0 || pack>=NUM_ROM_SLOTS)
		return NULL;

	return _romImages[pack];
}

CAnsiString FbfsImage::get_selected_system()
{
	if (!_file)
		return NULL;

	return _systemImage;
}

FILE* FbfsImage::SeekBlock(uint32_t block)
{
	fseek(_file, block * BLOCK_SIZE, SEEK_SET);
	return _file;
}


void FbfsImage::FileRenamed(const char* fbfs_oldname, const char* fbfs_newname)
{
	if (IsEqualStringI(_systemImage, fbfs_oldname))
		_systemImage = fbfs_newname;

	for (int i=0; i<NUM_DRIVE_SLOTS; i++)
	{
		if (IsEqualStringI(_diskImages[i], fbfs_oldname))
			_diskImages[i] = fbfs_newname;
	}

	for (int i=0; i<NUM_ROM_SLOTS; i++)
	{
		if (IsEqualStringI(_romImages[i], fbfs_oldname))
			_romImages[i] = fbfs_newname;
	}
}


FbfsDirEntry* FbfsImage::FindDirEntry(const char* fbfs_filename)
{
	for (int i=0; i<_directory.GetSize(); i++)
	{
		if (IsEqualStringI(fbfs_filename, _directory[i]->filename))
			return _directory[i];
	}
	return NULL;
}

FbfsDirEntry* FbfsImage::FindDirEntry(uint16_t dirid)
{
	if (dirid==0xFFFF)
		return NULL;
	/*
	for (int i=0; i<_directory.GetSize(); i++)
	{
		FbfsDirEntry* entry = _directory[i];
		if (entry->block == fileref.block && entry->block_count==fileref.block_count)
			return entry;
	}
	return NULL;
	*/
	return _directory[dirid];
}

CAnsiString FbfsImage::FindDirEntryName(uint16_t dirid)
{
	FbfsDirEntry* e = FindDirEntry(dirid);
	if (e==NULL)
		return NULL;
	else
		return e->filename;
}


uint16_t FbfsImage::MakeDirID(const char* filename)
{
	FbfsDirEntry* e = FindDirEntry(filename);
	int index = _directory.Find(e);
	if (index<0)
		return 0xFFFF;
	return (uint16_t)index;
}

