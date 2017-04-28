#include <stream.h>
#include <map>
#include <memory>
#include <sys/types.h>
#include <sys/stat.h>
#include <iostream>
#include "string_helper.h"
#include "fx_leak_debug.h"
#include "filesystem.h"


#ifdef _WIN32
    #include <windows.h>
    #include <tchar.h>
	#include <ctype.h>
	#include <stdio.h>
	#include <direct.h>
	 #define gp_stat _stat
    #define gp_stat_struct struct stat
#else
	#define _OPEN_SYS
	#include <unistd.h>
	#undef _OPEN_SYS
	#include <stdlib.h>
	#include <string.h>
    #include <dirent.h>
    #define gp_stat stat
    #define gp_stat_struct struct stat
#endif

/**
 * 
 * FileStream class
 */
class FileStream : public Stream
{
public:
    friend class FileSystem;
    
    ~FileStream();
    virtual bool canRead();
    virtual bool canWrite();
    virtual bool canSeek();
    virtual void close();
    virtual size_t read(void* ptr, size_t size, size_t count);
    virtual char* readLine(char* str, int num);
    virtual size_t write(const void* ptr, size_t size, size_t count);
    virtual bool eof();
    virtual size_t length();
    virtual long int position();
    virtual bool seek(long int offset, int origin);
    virtual bool rewind();
    static FileStream* create(const char* filePath, const char* mode);
   
private:
    FileStream(FILE* file);

private:
    FILE* _file;
    bool _canRead;
    bool _canWrite;
};



/////////////////////////////

bool FileSystem::listFiles(const char* dirPath, std::vector<std::string>& files)
{
#ifdef WIN32
 /*   std::string path(dirPath);
    path.append("\*");
    // Convert char to wchar
    std::basic_string<TCHAR> wPath;
    wPath.assign(path.begin(), path.end());

    WIN32_FIND_DATA FindFileData;
    HANDLE hFind = FindFirstFile(wPath.c_str(), &FindFileData);
    if (hFind == INVALID_HANDLE_VALUE)
    {
        return false;
    }
    do
    {
        // Add to the list if this is not a directory
        if ((FindFileData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) == 0)
        {
            // Convert wchar to char
            std::basic_string<TCHAR> wfilename(FindFileData.cFileName);
            std::string filename;
            filename.assign(wfilename.begin(), wfilename.end());
            files.push_back(filename);
        }
    } while (FindNextFile(hFind, &FindFileData) != 0);

    FindClose(hFind);*/
    return true;

#else
    std::string path(dirPath);
    path.append("/.");
    struct dirent* dp;
    DIR* dir = opendir(path.c_str());
    if (!dir)
    {
        return false;
    }
    while ((dp = readdir(dir)) != NULL)
    {
        std::string filepath(path);
        filepath.append("/");
        filepath.append(dp->d_name);

        struct stat buf;
        if (!stat(filepath.c_str(), &buf))
        {
            // Add to the list if this is not a directory
            if (!S_ISDIR(buf.st_mode))
            {
                files.push_back(dp->d_name);
            }
        }
    }
    closedir(dir);
    return true;
#endif
}

bool FileSystem::fileExists(const char* filePath)
{
    gp_stat_struct s;
    return stat( filePath, &s ) == 0;
}

size_t FileSystem::fileSize(const char* filePath)
{

    gp_stat_struct s;

    if ( stat( filePath, &s ) == 0 )
		return s.st_size;

	return 0;
}

Stream* FileSystem::open(const char* path, size_t mode)
{
    char modeStr[] = "rb";
    if (( mode & WRITE ) != 0)
        modeStr[0] = 'w';
    if (( mode & APPEND ) != 0)
        modeStr[0] = 'a';

#ifdef _WIN32
    gp_stat_struct s;
    if (stat( path, &s ) != 0 && ( ( mode & WRITE ) == 0 && ( mode & APPEND ) == 0 ) )
    {
        return NULL;
    }
#endif
    FileStream* stream = FileStream::create( path, modeStr );
    return stream;

}

FILE* FileSystem::openFile(const char* filePath, const char* mode)
{
    
    FILE* fp = fopen( filePath, mode );
    
    return fp;
}

char* FileSystem::readAll(const char* filePath, int* fileSize)
{

    // Open file for reading.
    std::auto_ptr<Stream> stream(open(filePath));
    if (stream.get() == NULL)
    {
        return NULL;
    }
    size_t size = stream->length();

    // Read entire file contents.
    char* buffer = new char[size + 1];
    size_t read = stream->read(buffer, 1, size);
    if (read != size)
    {
        SAFE_DELETE_ARRAY(buffer);
        return NULL;
    }

    // Force the character buffer to be NULL-terminated.
    buffer[size] = '\0';

    if (fileSize)
    {
        *fileSize = (int)size; 
    }

	stream->close();

    return buffer;
}

bool FileSystem::isAbsolutePath(const char* filePath)
{
    if (filePath == 0 || filePath[0] == '\0')
        return false;
#ifdef _WIN32
    if (strlen(filePath) >= 2)
    {
        char first = filePath[0];
        if (filePath[1] == ':' && ((first >= 'a' && first <= 'z') || (first >= 'A' && first <= 'Z')))
            return true;
    }
    return false;
#else
    return filePath[0] == '/';
#endif
}


int FileSystem::safeDeleteEmptyFolder ( const char* sDirName )
{
	try
	{
#ifdef _WIN32
		// Delete directory
		if(::RemoveDirectoryA( sDirName) == FALSE)
		{
			if ( !MoveFileExA ( sDirName, NULL, MOVEFILE_DELAY_UNTIL_REBOOT ) )
			{
				return GetLastError();
			}
		}
#else
		return rmdir(sDirName);
#endif
	}
	catch (...)
	{
		return -1;
	}

	return 0;
}


	static string getFileNameFromFullPath ( string FullPath );


int FileSystem::safeDelete ( const char* sFileName )
{
	try
	{
		int err = FileSystem::deleteFile ( sFileName );

#ifdef _WIN32
		if ( err )
		{
			if ( !MoveFileExA ( sFileName, NULL, MOVEFILE_DELAY_UNTIL_REBOOT ) )
			{
				return err;
			}
		}
#else
		return err;
#endif

	}
	catch (...)
	{
		return -1;
	}

	return 0;
}


int FileSystem::deleteFile(const char* path)
{
	return remove( path );
}

int FileSystem::renameFile(const char* oldname, const char* newname)
{
	return rename( oldname, newname );
}

std::string FileSystem::getExtension(const char* path)
{
    const char* str = strrchr(path, '.');
    if (str == NULL)
        return "";

    std::string ext;
    size_t len = strlen(str);

#ifdef _MSC_VER
// Check for virtual studio compiler
	for (size_t i = 0; i < len; ++i)
		ext += toupper(str[i]);
#else
	for (size_t i = 0; i < len; ++i)
		ext += std::toupper(str[i]);
#endif
    return ext;
}

//////////////////

FileStream::FileStream(FILE* file)
    : _file(file), _canRead(false), _canWrite(false)
{
    
}

FileStream::~FileStream()
{
    if (_file)
    {
        close();
    }
}

FileStream* FileStream::create(const char* filePath, const char* mode)
{
    FILE* file = fopen(filePath, mode);
    if (file)
    {
        FileStream* stream = new FileStream(file);
        const char* s = mode;
        while (s != NULL && *s != '\0')
        {
            if (*s == 'r')
                stream->_canRead = true;
            else if (*s == 'w')
                stream->_canWrite = true;
            ++s;
        }

        return stream;
    }
    return NULL;
}

bool FileStream::canRead()
{
    return _file && _canRead;
}

bool FileStream::canWrite()
{
    return _file && _canWrite;
}

bool FileStream::canSeek()
{
    return _file != NULL;
}

void FileStream::close()
{
    if (_file)
        fclose(_file);
    _file = NULL;
}

size_t FileStream::read(void* ptr, size_t size, size_t count)
{
    if (!_file)
        return 0;
    return fread(ptr, size, count, _file);
}

char* FileStream::readLine(char* str, int num)
{
    if (!_file)
        return 0;
    return fgets(str, num, _file);
}

size_t FileStream::write(const void* ptr, size_t size, size_t count)
{
    if (!_file)
        return 0;
    return fwrite(ptr, size, count, _file);
}

bool FileStream::eof()
{
    if (!_file || feof(_file))
        return true;
    return ((size_t)position()) >= length();
}

size_t FileStream::length()
{
    size_t len = 0;
    if (canSeek())
    {
        long int pos = position();
        if (seek(0, SEEK_END))
        {
            len = position();
        }
        seek(pos, SEEK_SET);
    }
    return len;
}

long int FileStream::position()
{
    if (!_file)
        return -1;
    return ftell(_file);
}

bool FileStream::seek(long int offset, int origin)
{
    if (!_file)
        return false;
    return fseek(_file, offset, origin) == 0;
}

bool FileStream::rewind()
{
    if (canSeek())
    {
        ::rewind(_file);
        return true;
    }
    return false;
}

bool FileSystem::folderExists(const char* folderPath)
{
	bool result = false;

#ifdef _WIN32
	DWORD dwAttr = GetFileAttributesA( folderPath );
	
	result = (dwAttr != 0xffffffff && (dwAttr & FILE_ATTRIBUTE_DIRECTORY)); 
#else

	if (folderPath != NULL)
	{
	    DIR *pDir;
	    pDir = opendir (folderPath);

	    if (pDir != NULL)
	    {
	    	result = true;
	        (void) closedir (pDir);
	    }
	}
#endif
	return result;
}

bool FileSystem::createFolder(const char* folderPath)
{
	bool result = false;

#ifdef _WIN32
	if (_mkdir( folderPath ) == 0)
	{
		result = true;
	}
#else
	if (mkdir(folderPath, S_IRWXU) == 0) // Silently fails when the directory already exists.
	{
		result = true;
	}
#endif
	return result;
}


int FileSystem::safeRecursivelyDeleteFolder( const char* refcstrRootDirectory )
{
#if defined (_WIN32) || defined (_WIN64)

  bool            bSubdirectory = false;       // Flag, indicating whether
					                              // subdirectories have been found
  HANDLE          hFile;                       // Handle to directory
  string     strFilePath;                 // Filepath
  string     strPattern;                  // Pattern
  WIN32_FIND_DATAA FileInformation;             // File information
  string	strRootDirectory (refcstrRootDirectory);

  strPattern.assign ( strRootDirectory );
  strPattern.append ( "\\*.*" );

  hFile = ::FindFirstFileA(strPattern.c_str(), &FileInformation);
  if(hFile != INVALID_HANDLE_VALUE)
  {
    do
    {
      if(FileInformation.cFileName[0] != '.')
      {
        strFilePath.erase();
        strFilePath = strRootDirectory + "\\" + FileInformation.cFileName;

        if(FileInformation.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
        {
         
            // Delete subdirectory
			int iRC = safeRecursivelyDeleteFolder(strFilePath.c_str());
            if(iRC)
              return iRC;
         
        }
        else
        {
          // Delete file
		  if( safeDelete(strFilePath.c_str()) == FALSE)
             continue;
        }
      }
    } while(::FindNextFileA(hFile, &FileInformation) == TRUE);

    // Close handle
    ::FindClose(hFile);

    DWORD dwError = ::GetLastError();
    if(dwError != ERROR_NO_MORE_FILES)
		return dwError;
    else
    {
		if(!bSubdirectory)
		{
			safeDeleteEmptyFolder( refcstrRootDirectory );
		}
    }
  }
  
  return 0;
#else

   DIR *pDir = opendir( refcstrRootDirectory );
   size_t iLen = strlen( refcstrRootDirectory );
   int ret = -1;

   if (pDir)
   {
      struct dirent *p;

      ret = 0;

      while (!ret && (p=readdir( pDir )))
      {
          int r2 = -1;
          char *buf;
          size_t len;

          /* Skip the names "." and ".." as we don't want to recurse on them. */
          if (!strcmp(p->d_name, ".") || !strcmp(p->d_name, ".."))
          {
             continue;
          }

          len = iLen + strlen(p->d_name) + 2;
          buf = ( char* )malloc(len);

          if (buf)
          {
             struct stat statbuf;

             snprintf(buf, len, "%s/%s", refcstrRootDirectory, p->d_name);

             if (!stat(buf, &statbuf))
             {
                if (S_ISDIR(statbuf.st_mode))
                {
                   r2 = safeRecursivelyDeleteFolder(buf);
                }
                else
                {
                   r2 = unlink(buf);
                }
             }

             free(buf);
          }

          ret = r2;
      }

      closedir(pDir);
   }

   if (!ret)
   {
      ret = safeDeleteEmptyFolder ( refcstrRootDirectory );
   }

   return ret;
#endif
}


string FileSystem::getFileNameFromFullPath ( const string& sFullPath )
{
#if defined (_WIN32) || defined (_WIN64)
	
	char sModFileExe [MAX_PATH + 1];
	char sModFileName [MAX_PATH + 1];
	_splitpath_s ( sFullPath.c_str(), 0, 0, 0, 0, sModFileName, MAX_PATH, sModFileExe, MAX_PATH );

	string ret ( sModFileName );
	ret.append ( sModFileExe );
	return ret;
#else

	//string ret ( basename ( sFullPath.c_str() ));
    string ret; // Modified for Mac @Makara
	return ret;
#endif
}
