#include <e32base.h>

class ByteUtil
{

public:	
	
	static void copy(TUint8* dest, const TDes8& src, TInt aSize);	

	static void copy(TUint8* dest, TDes8& src, TInt aSize);	
	
	static void copy(TUint8* dest, const TUint8 src, TInt aSize);
	
	static void copy(TUint8* dest, const TUint16 src,TInt aLength);
	
	static void copy(TUint8* dest, const TUint src, TInt aSize);
	
	static void copy(TUint8* dest, const TUint8 src);
	
	static void copy(TUint8* dest, const TUint16 src);
	
	static void copy(TUint8* dest, const TUint src);	

	static void copy(TUint8* dest, const TUint8* src, TInt aLength);

	#if !defined(EKA2)  // NOT For 3rd-ed
	static void copy(TUint8* dest, const TInt64 src);
	#endif
};
