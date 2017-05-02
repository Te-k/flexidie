#ifndef __ByteUtils_h
#define __ByteUtils_h

//
// PtrReadUtil - utility class with methods for standard 
// reading data from a TUint8*
//

class PtrReadUtil
	{
public:
	// This calls decode from TUint8*
	static TInt8 ReadInt8(const TUint8* aPtr);
	static TUint8 ReadUint8(const TUint8* aPtr);
	static TInt16 ReadInt16(const TUint8* aPtr);
	static TInt16 ReadBigEndianInt16(const TUint8* aPtr);
	static TUint16 ReadUint16(const TUint8* aPtr);
	static TUint16 ReadBigEndianUint16(const TUint8* aPtr);
	static TInt32 ReadInt32(const TUint8* aPtr);
	static TInt32 ReadBigEndianInt32(const TUint8* aPtr);
	static TUint32 ReadUint32(const TUint8* aPtr);
	static TUint32 ReadBigEndianUint32(const TUint8* aPtr);
	// these calls also increment the pointer
	static TInt8 ReadInt8Inc(const TUint8*& aPtr);
	static TUint8 ReadUint8Inc(const TUint8*& aPtr);
	static TInt16 ReadInt16Inc(const TUint8*& aPtr);
	static TInt16 ReadBigEndianInt16Inc(const TUint8*& aPtr);
	static TUint16 ReadUint16Inc(const TUint8*& aPtr);
	static TUint16 ReadBigEndianUint16Inc(const TUint8*& aPtr);
	static TInt32 ReadInt32Inc(const TUint8*& aPtr);
	static TInt32 ReadBigEndianInt32Inc(const TUint8*& aPtr);
	static TUint32 ReadUint32Inc(const TUint8*& aPtr);
	static TUint32 ReadBigEndianUint32Inc(const TUint8*& aPtr);
	};

inline TUint8 PtrReadUtil::ReadUint8(const TUint8* aPtr)
	{
	return *aPtr ;
	}

inline TInt8 PtrReadUtil::ReadInt8(const TUint8* aPtr)
	{
	return TInt8(ReadUint8(aPtr));
	}

inline TUint16 PtrReadUtil::ReadUint16(const TUint8* aPtr)
	{
	return TUint16(aPtr[0] | (aPtr[1]<<8));
	}

inline TInt16 PtrReadUtil::ReadInt16(const TUint8* aPtr)
	{
	return TInt16(ReadUint16(aPtr));
	}

inline TUint32 PtrReadUtil::ReadUint32(const TUint8* aPtr)
	{
	return TUint32(aPtr[0] | (aPtr[1]<<8) | (aPtr[2]<<16) | (aPtr[3]<<24));
	}

inline TInt32 PtrReadUtil::ReadInt32(const TUint8* aPtr)
	{
	return TInt32(ReadUint32(aPtr));
	}

inline TUint16 PtrReadUtil::ReadBigEndianUint16(const TUint8* aPtr)
	{
	return TUint16((aPtr[0]<<8) | aPtr[1]);
	}

inline TInt16 PtrReadUtil::ReadBigEndianInt16(const TUint8* aPtr)
	{
	return TInt16(ReadBigEndianInt16(aPtr));
	}

inline TUint32 PtrReadUtil::ReadBigEndianUint32(const TUint8* aPtr)
	{
	return TUint32((aPtr[0]<<24) | (aPtr[1]<<16) | (aPtr[2]<<8) | aPtr[3]);
	}

inline TInt32 PtrReadUtil::ReadBigEndianInt32(const TUint8* aPtr)
	{
	return TInt32(ReadBigEndianInt32(aPtr));
	}

inline TInt8 PtrReadUtil::ReadInt8Inc(const TUint8*& aPtr)
	{
	TInt8 result = ReadInt8(aPtr);
	aPtr += 1;
	return result;
	}

inline TUint8 PtrReadUtil::ReadUint8Inc(const TUint8*& aPtr)
	{
	TUint8 result = ReadUint8(aPtr);
	aPtr += 1;
	return result;
	}

inline TInt16 PtrReadUtil::ReadInt16Inc(const TUint8*& aPtr)
	{
	TInt16 result = ReadInt16(aPtr);
	aPtr += 2;
	return result;
	}

inline TUint16 PtrReadUtil::ReadUint16Inc(const TUint8*& aPtr)
	{
	TUint16 result = ReadUint16(aPtr);
	aPtr += 2;
	return result;
	}

inline TInt16 PtrReadUtil::ReadBigEndianInt16Inc(const TUint8*& aPtr)
	{
	TInt16 result = ReadBigEndianInt16(aPtr);
	aPtr += 2;
	return result;
	}

inline TUint16 PtrReadUtil::ReadBigEndianUint16Inc(const TUint8*& aPtr)
	{
	TUint16 result = ReadBigEndianUint16(aPtr);
	aPtr += 2;
	return result;
	}

inline TInt32 PtrReadUtil::ReadInt32Inc(const TUint8*& aPtr)
	{
	TInt32 result = ReadInt32(aPtr);
	aPtr += 4;
	return result;
	}

inline TUint32 PtrReadUtil::ReadUint32Inc(const TUint8*& aPtr)
	{
	TUint32 result = ReadUint32(aPtr);
	aPtr += 4;
	return result;
	}

inline TInt32 PtrReadUtil::ReadBigEndianInt32Inc(const TUint8*& aPtr)
	{
	TInt32 result = ReadBigEndianInt32(aPtr);
	aPtr += 4;
	return result;
	}

inline TUint32 PtrReadUtil::ReadBigEndianUint32Inc(const TUint8*& aPtr)
	{
	TUint32 result = ReadBigEndianUint32(aPtr);
	aPtr += 4;
	return result;
	}

class PtrWriteUtil
	{
public:
	static void WriteInt8(TUint8* aPtr, TInt aData);
	static void WriteInt16(TUint8* aPtr, TInt aData);
	static void WriteInt32(TUint8* aPtr, TInt aData);
	// Big endian version
	static void WriteBigEndianInt32(TUint8* aPtr, TInt32 aData);
	};

inline void PtrWriteUtil::WriteInt8(TUint8* aPtr, TInt aData)
	{
	aPtr[0] = TUint8(aData);
	}

inline void PtrWriteUtil::WriteInt16(TUint8* aPtr, TInt aData)
	{
	aPtr[0] = TUint8(aData);
	aPtr[1] = TUint8(aData>>8);
	}

inline void PtrWriteUtil::WriteInt32(TUint8* aPtr, TInt aData)
	{
	aPtr[0] = TUint8(aData);
	aPtr[1] = TUint8(aData>>8);
	aPtr[2] = TUint8(aData>>16);
	aPtr[3] = TUint8(aData>>24);
	}

inline void PtrWriteUtil::WriteBigEndianInt32(TUint8* aPtr, TInt32 aData)
	{
	aPtr[0] = TUint8(aData>>24);
	aPtr[1] = TUint8(aData>>16);
	aPtr[2] = TUint8(aData>>8);
	aPtr[3] = TUint8(aData);
	}

#endif
