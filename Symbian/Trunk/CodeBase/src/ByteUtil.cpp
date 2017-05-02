#include "ByteUtil.h"

#include <string.h>
#include <types.h>

#include <in.h>
void ByteUtil::copy(TUint8* dest, const TDes8& src, TInt aSize)
{	
	memcpy(dest,src.Ptr(),aSize);
}

void ByteUtil::copy(TUint8* dest, TDes8& src, TInt aSize)
{	
	memcpy(dest,src.Ptr(),aSize);
}

void ByteUtil::copy(TUint8* dest, const TUint8 src, TInt aSize)
{
	memcpy(dest,&src,aSize);
}
 
void ByteUtil::copy(TUint8* dest, const TUint16 src, TInt aSize)
{	
	TUint16 x = htons(src);
	memcpy(dest,&x,aSize);
}

void ByteUtil::copy(TUint8* dest, const TUint src, TInt aSize)
{
	TUint x = htonl(src);
	memcpy(dest,&x,aSize);
}

void ByteUtil::copy(TUint8* dest, const TUint8 src)
{
	copy(dest,src,1);
}

void ByteUtil::copy(TUint8* dest, const TUint16 src)
{
	copy(dest,src,2);
}
	
void ByteUtil::copy(TUint8* dest, const TUint src)
{
	copy(dest,src,4);
}


void ByteUtil::copy(TUint8* dest, const TUint8* src, TInt aLength)
{
	memcpy(dest,src,aLength);
}

#if !defined(EKA2) // NOT For 3rd-ed
void ByteUtil::copy(TUint8* dest, const TInt64 src)
{	
	TUint8*  p;
	p = dest;
	
	TUint hi = src.High();
	copy(p,hi);
	p += 4;
	
	TUint lo = src.Low();
	copy(p,lo);
	
	p = NULL;
}
#endif
