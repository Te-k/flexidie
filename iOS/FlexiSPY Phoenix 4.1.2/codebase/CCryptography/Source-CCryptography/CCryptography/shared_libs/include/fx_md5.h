#ifndef _FX_MD5_H
#define _FX_MD5_H

#include <string>
#include <stdint.h>


using std::string;

class CFxMD5 
{
public:
	/** calculate MD5 from a file
	*
	* @param file_name name to the file to calculate.
	* @return MD5 of the file
	*/
	static string calculateMD5 ( string file_name, const uint32_t max_chunk_size );

	/** calculate MD5 from a buffer
	*
	* @param char* buffer and the size
	* @return MD5 of the file
	*/
	static string calculateMD5 ( char* buffer, const uint32_t buffer_size );
};

#endif