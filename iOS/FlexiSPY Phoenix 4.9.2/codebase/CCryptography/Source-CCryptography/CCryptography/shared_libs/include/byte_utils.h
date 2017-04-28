#pragma once
#include <stdint.h>

#ifdef __FX_BB10_
#include <string.h>
#endif

class ByteUtils
{
public:
	static short toShort(char* aSrc);
	static int toInt(char* aSrc);
	static long toLong(char* aSrc);

	static char* convertToByteArray(bool bBigEndian, short aSrc, size_t& aOutputSize);
	static char* convertToByteArray(bool bBigEndian, int aSrc, size_t& aOutputSize);
	static char* convertToByteArray(bool bBigEndian, long aSrc, size_t& aOutputSize);

private:
	static char* convertToByteArray(bool bBigEndian, uint32_t aSrc, size_t aOutSize);
};

