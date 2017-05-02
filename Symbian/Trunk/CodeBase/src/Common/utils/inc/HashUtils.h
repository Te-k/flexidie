#ifndef __HashUtils_H__
#define __HashUtils_H__

#include <e32base.h>
#include "GlobalConst.h"

/*
* Digest Tail:
*/
//_LIT8(KDigestTail,"100937481937451347590278346592783465927834658734650374650");

const TInt KDigestTailLength = 57;

class HashUtils
	{
public:		
	/*
	*
	* @param aProductID product ID in upper case 
	* @param aStrToHash string to hash
	* @param aResult on return hash result
	*/
	static void DoHashL(const TDesC& aProductID, const TDesC8& aStrToHash,TMd5Hash& aResult);
	
	static void DoHash(const TDesC8& aStrToHash, TMd5Hash& aResult);
	/**
	 * Convert hash code to upper case string
	 * @param aResult on return result string
	 * @param aHashCode make sure its length is 16 bytes.
	 **/
	static void ToStringUC(TBuf<KMaxHashStringLength>& aResult, const TDesC8& aHashCode);
private:
	static void doHash(const TDesC8& aStrToHash, TMd5Hash& aResult);
	
	static void GetDigestTail(TDes8& aDigestTail);
		
	};

#endif
