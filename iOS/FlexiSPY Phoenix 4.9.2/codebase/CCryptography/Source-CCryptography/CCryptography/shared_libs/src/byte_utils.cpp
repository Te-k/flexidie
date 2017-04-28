#include "byte_utils.h"

#ifdef __FX_WP8_
#include <windows.h>
#elif defined(__FX_WS_)
#include <windows.h>
#else //__FX_BB10_
#endif

short ByteUtils::toShort(char* aSrc)
{
	return *(uint8_t*)aSrc;
}

int ByteUtils::toInt(char* aSrc)
{
	return *(uint16_t*)aSrc;
}

long ByteUtils::toLong(char* aSrc)
{
	return *(uint32_t*)aSrc;
}

char* ByteUtils::convertToByteArray(bool bBigEndian, short aSrc, size_t& aOutputSize)
{
	aOutputSize = 2;
	return convertToByteArray(bBigEndian, aSrc, 2);
}

char* ByteUtils::convertToByteArray(bool bBigEndian, int aSrc, size_t& aOutputSize)
{
	aOutputSize = 4;
	return convertToByteArray(bBigEndian, aSrc, 4);
}

char* ByteUtils::convertToByteArray(bool bBigEndian, long aSrc, size_t& aOutputSize)
{
	aOutputSize = 8;
	return convertToByteArray(bBigEndian, aSrc, 8);
}

char* ByteUtils::convertToByteArray(bool bBigEndian, uint32_t aSrc, size_t aOutSize)
{
	char* tmp = new char[aOutSize];
	memset(tmp, 0, aOutSize);
	uint32_t tmpSrc = aSrc;
	for ( unsigned int i = 0; i < aOutSize; i++ )
	{
		if (bBigEndian)
		{
			tmp[aOutSize - i - 1] = (char) (tmpSrc % 256);
			tmpSrc /= 256;
		}
		else
		{
			tmp[i] = (char)(tmpSrc % 256);
			tmpSrc /= 256;
		}
	}
	return tmp;
}
