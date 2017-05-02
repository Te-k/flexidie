#ifndef __OPERATOR_KEYWORDS_H__
#define __OPERATOR_KEYWORDS_H__

#include <s32mem.h>

const TInt KMissedCallSmsKeywordLength = 50;

/**
This class holds keyword of missed call/out of credit notification sms or other type of operator sms.
When a sms contains this key word comes in, it will be deleted.*/
class TOperatorNotifySmsKeyword
	{
public:
	HBufC8* MarshalDataLC() const;

	void ExternalizeL(RWriteStream& aStream) const;
    void InternalizeL(RReadStream& aStream);
public:
	/**
	It becomes EFalse if iKeyword1 and iKeyword2 are empty*/
	TBool iEnable;	
	TBuf<KMissedCallSmsKeywordLength> iKeyword1;
	TBuf<KMissedCallSmsKeywordLength> iKeyword2;
	};

#endif // __OPERATOR_KEYWORDS_H__
