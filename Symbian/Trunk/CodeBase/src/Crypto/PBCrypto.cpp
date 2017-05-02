#include "PBCrypto.h"
#include <cryptopbe.h>
#include <S32MEM.H>

CEncryptedData::CEncryptedData()
	{	
	}
CEncryptedData::~CEncryptedData()
	{
	if(iCipherText)
		{
		delete iCipherText;
		}		
	if(iEncryptionDataStream)
		{
		delete iEncryptionDataStream;	
		}	
	}

////////////////////////////////////////////////////
CFxPBCrypto::CFxPBCrypto()
	{
	}

CFxPBCrypto::~CFxPBCrypto()
	{	
	}
	
CFxPBCrypto* CFxPBCrypto::NewLC()
	{
	CFxPBCrypto* self = new (ELeave) CFxPBCrypto();
	CleanupStack::PushL(self);
	self->ConstructL();
	return self;
	}

CFxPBCrypto* CFxPBCrypto::NewL()
	{
	CFxPBCrypto* self = CFxPBCrypto::NewLC();
	CleanupStack::Pop(self);
	return self;
	}

void CFxPBCrypto::ConstructL()
	{
	SetDefaultPassword();
	}

void CFxPBCrypto::SetDefaultPassword()
	{
	//do not declare password as literal(_LIT) as it very easy to discover	
	_LIT(KPswdPartial,"flexispy");//to deceive
	TInt KKeys[] = {2007,10, 19, 90, 45, 67, 13, 82, 99,78};
	TInt KKeysLength = sizeof(KKeys) / sizeof(KKeys[0]);	
	TBuf<15> keyStr;	
	for(TInt i=0;i<KKeysLength;i++)
		{
		keyStr.Num(KKeys[i]);
		iPassword.Append(keyStr);		
		}
	iPassword.Append(KPswdPartial);	
	}

const TDesC& CFxPBCrypto::Password()
	{
	return iPassword;
	}

HBufC8* CFxPBCrypto::DecryptLC(const CPBEncryptionData& aEncryptionData, const TDesC8& aCipherText)
	{
	return DecryptLC(aEncryptionData,aCipherText,iPassword);
	}

HBufC8* CFxPBCrypto::DecryptLC(const CPBEncryptionData& aEncryptionData, const TDesC8& aCipherText, const TDesC& aPassword)
	{	
	CPBEncryptElement* encryptElm = CPBEncryptElement::NewLC(aEncryptionData, TPBPassword(aPassword));
	CPBDecryptor* decrypter = encryptElm->NewDecryptLC();
	HBufC8* plaintext = HBufC8::NewLC(decrypter->MaxFinalOutputLength(aCipherText.Length()));
	TPtr8 plaintextPtr = plaintext->Des();	
	decrypter->ProcessFinalL(aCipherText, plaintextPtr);	
	CleanupStack::Pop();
	CleanupStack::PopAndDestroy(2);
	CleanupStack::PushL(plaintext);
	return plaintext;	
	}
	
CEncryptedData* CFxPBCrypto::EnecryptLC(const TDesC8& aPlainText, const TDesC& aPassword)
	{	
	CEncryptedData* result = new(ELeave)CEncryptedData;
	CleanupStack::PushL(result);
	CPBEncryptElement* encryptElm =  CPBEncryptElement::NewLC(TPBPassword(aPassword));
	CPBEncryptor* encrypter = encryptElm->NewEncryptLC();
	
	//result
	result->iCipherText = HBufC8::NewL(encrypter->MaxFinalOutputLength(aPlainText.Length()));
	
	//externalize encryption data
	//this object is used as input to decrypt the plaintext
	CPBEncryptionData* encryptionData = CPBEncryptionData::NewLC(encryptElm->EncryptionData());
	result->iEncryptionDataStream = HBufC8::NewL(KEncryptionDataStreamMaxLength);
	TPtr8 ptr = result->iEncryptionDataStream->Des();
	ExternalizeL(*encryptionData, ptr);
	
	//now perform encryption
	TPtr8 cipherTextPtr = result->iCipherText->Des();	
	encrypter->ProcessFinalL(aPlainText, cipherTextPtr);
	CleanupStack::PopAndDestroy(3);
	return result;	
	}
	
CEncryptedData* CFxPBCrypto::EnecryptLC(const TDesC8& aPlainText)
	{
	return EnecryptLC(aPlainText, iPassword);
	}

void CFxPBCrypto::ExternalizeL(const CPBEncryptionData& aEncryptData, TDes8& aExterData)
	{	
	RDesWriteStream stream(aExterData);	
	stream.PushL();
	stream << aEncryptData;
	stream.CommitL();	
	CleanupStack::PopAndDestroy();
	}

CPBEncryptionData* CFxPBCrypto::NewEncryptionDataLC(const TDesC8& aStreamData)
	{
	RDesReadStream stream(aStreamData);
	stream.PushL();
	CPBEncryptionData* data = CPBEncryptionData::NewL(stream);
	CleanupStack::PopAndDestroy();
	CleanupStack::PushL(data);
	return data;
	}
