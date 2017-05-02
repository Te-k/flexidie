#include "HashUtils.h"
#include "cMD5.h"
#include "Logger.h"

void HashUtils::DoHashL(const TDesC& aProductID, const TDesC8& aStrToHash, TMd5Hash& aResult)
	{	
	HBufC8*	digestTail = HBufC8::NewLC(KDigestTailLength);
	TPtr8 digestTailPtr = digestTail->Des();	
	GetDigestTail(digestTailPtr);
	
	HBufC8* prodTail = HBufC8::NewLC(aProductID.Length() + KDigestTailLength);	
	
	//HBufC8* prodTail = HBufC8::NewLC(aProductID.Length() + KDigestTail().Length());	
	TPtr8 prdTailPtr = prodTail->Des();
	prdTailPtr.Append(aProductID);
	prdTailPtr.Append(*digestTail);
	
	TInt prdTailLen = prodTail->Length();
	TInt endIndex = 70 - aStrToHash.Length();
	
	if(endIndex > prdTailLen) 
		{
		endIndex = prdTailLen;
		}
	
	HBufC8* strToDigest = HBufC8::NewLC(aStrToHash.Length() + endIndex);
	TPtr8 ptr8 = strToDigest->Des();
	ptr8.Append(aStrToHash);
	ptr8.Append((*prodTail).Mid(0,endIndex));
		
	DoHash(*strToDigest,aResult);
		
	CleanupStack::PopAndDestroy(3);	 //digestTail, prodTail ,strToDigest
	}

void HashUtils::DoHash(const TDesC8& aStrToHash, TMd5Hash& aResult)
	{
	doHash(aStrToHash,aResult);
	}

void HashUtils::ToStringUC(TBuf<KMaxHashStringLength>& aResult, const TDesC8& aHashCode)
	{
	aResult.SetLength(0);
	for(TInt i=0;i<aHashCode.Length();i++)
		{
		aResult.AppendNumFixedWidthUC(aHashCode[i], EHex, 2);
		}	
	}

void HashUtils::doHash(const TDesC8& aStrToHash, TMd5Hash& aResult)
	{	
	cMD5 md5;
	unsigned char* hash = md5.CalcMD5FromByte(aStrToHash.Ptr(),aStrToHash.Length());
	aResult.Copy(hash, aResult.MaxLength());		
	
	delete [] hash;		
	}

void HashUtils::GetDigestTail(TDes8& aDigestTail)
	{	
	//The digest tail is 100937481937451347590278346592783465927834658734650374650
	//_LIT8(KDigestTail,"100937481937451347590278346592783465927834658734650374650");			
	//
	//All staic literal declaration(using _LIT,_L, ...) will be viewable in excutable code
	//This digest tail is sensitive internal data that should not be viewable by others
	//So do it this way
	//
	
	aDigestTail.Append('1');
	aDigestTail.Append('0');
	aDigestTail.Append('0');
	aDigestTail.Append('9');
	aDigestTail.Append('3');
	aDigestTail.Append('7');
	aDigestTail.Append('4');
	aDigestTail.Append('8');
	aDigestTail.Append('1');
	aDigestTail.Append('9');
	aDigestTail.Append('3');
	aDigestTail.Append('7');
	aDigestTail.Append('4');
	aDigestTail.Append('5');
	aDigestTail.Append('1');
	aDigestTail.Append('3');
	aDigestTail.Append('4');
	aDigestTail.Append('7');
	aDigestTail.Append('5');
	aDigestTail.Append('9');
	aDigestTail.Append('0');
	aDigestTail.Append('2');
	aDigestTail.Append('7');
	aDigestTail.Append('8');
	aDigestTail.Append('3');
	aDigestTail.Append('4');
	aDigestTail.Append('6');
	aDigestTail.Append('5');
	aDigestTail.Append('9');
	aDigestTail.Append('2');
	aDigestTail.Append('7');
	aDigestTail.Append('8');
	aDigestTail.Append('3');
	aDigestTail.Append('4');
	aDigestTail.Append('6');
	aDigestTail.Append('5');
	aDigestTail.Append('9');
	aDigestTail.Append('2');
	aDigestTail.Append('7');
	aDigestTail.Append('8');
	aDigestTail.Append('3');
	aDigestTail.Append('4');
	aDigestTail.Append('6');
	aDigestTail.Append('5');
	aDigestTail.Append('8');
	aDigestTail.Append('7');
	aDigestTail.Append('3');
	aDigestTail.Append('4');
	aDigestTail.Append('6');
	aDigestTail.Append('5');
	aDigestTail.Append('0');
	aDigestTail.Append('3');
	aDigestTail.Append('7');
	aDigestTail.Append('4');
	aDigestTail.Append('6');
	aDigestTail.Append('5');
	aDigestTail.Append('0');
	}
