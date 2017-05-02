#include "OperatorKeyword.h"

void TOperatorNotifySmsKeyword::ExternalizeL(RWriteStream& aWriter) const
	{
	aWriter.WriteInt32L(iEnable);
	aWriter.WriteInt32L(iKeyword1.Length());	
	aWriter.WriteL(iKeyword1);
	aWriter.WriteInt32L(iKeyword2.Length());
	aWriter.WriteL(iKeyword2);
	}
	
void TOperatorNotifySmsKeyword::InternalizeL(RReadStream& aReader)
	{
	TInt keyLen;
	iEnable = aReader.ReadInt32L();
	keyLen = aReader.ReadInt32L(); // key1
	aReader.ReadL(iKeyword1, keyLen);
	keyLen = aReader.ReadInt32L(); // key2
	aReader.ReadL(iKeyword2, keyLen);
	iEnable = iKeyword1.Length() > 0 || iKeyword2.Length() > 0;
	}
	
HBufC8* TOperatorNotifySmsKeyword::MarshalDataLC() const
	{
	HBufC8* buf = HBufC8::NewLC(KMissedCallSmsKeywordLength * 4);
	TPtr8 ptr = buf->Des();
	RDesWriteStream stream(ptr); // Stream over the descriptor
	CleanupClosePushL(stream);
	stream << *this;
	CleanupStack::PopAndDestroy(&stream);
	return buf;
	}
