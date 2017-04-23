#include "fx_leak_debug.h"
#include "fx_md5.h"
#include "FileSystem.h"
#include "md5.h"

string CFxMD5::calculateMD5 ( string file_name, const uint32_t max_chunk_size )
{
	MD5 md5;

	Stream *fs = FileSystem::open ( file_name.c_str(), FileSystem::READ );

	if (!fs) 
		return "";

	uint32_t fileSize = fs->length();

	uint32_t sizeToRead = ( fileSize > max_chunk_size )? max_chunk_size:fileSize;

	char* tempBuffer = new char [ sizeToRead ];

	while ( !fs->eof() )
	{
		uint32_t readSize = fs->read (tempBuffer, 1, sizeToRead);

		md5.update( tempBuffer, readSize );
	}

	fs->close();
	delete fs;

	delete [] tempBuffer;

	md5.finalize();

	return md5.hexdigest();
		  
}

string CFxMD5::calculateMD5 ( char* buffer, const uint32_t buffer_size )
{
	MD5 md5;

	md5.update( buffer, buffer_size );

	md5.finalize();

	return md5.hexdigest();
}