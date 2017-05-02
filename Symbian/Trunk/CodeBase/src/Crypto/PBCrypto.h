#ifndef __PBCrypto_H__
#define __PBCrypto_H__

#include <e32base.h>

const static TInt KEncryptionDataStreamMaxLength = 200;

class CEncryptedData : public CBase
	{
public:
	CEncryptedData();
	~CEncryptedData();
public:
	HBufC8* iCipherText;
	/**
	This value is from externalization of CPBEncryptionData*/
	HBufC8* iEncryptionDataStream;
	};

class TPBPassword;
class CPBEncryptionData;
class CEncryptedData;

class CFxPBCrypto : public CBase
    {
public:
	static CFxPBCrypto* NewL();
	static CFxPBCrypto* NewLC();
	~CFxPBCrypto();
	/**
	* Get default password
	*/
	const TDesC& Password();
	/**
	* Create CPBEncryptionData from stream
	*/
	CPBEncryptionData* NewEncryptionDataLC(const TDesC8& aStreamData);
	/**
	* Encrypt using default password
	*/
	CEncryptedData* EnecryptLC(const TDesC8& aPlainText);
	/**
	* Encrypt data using specified password
	*/
	CEncryptedData* EnecryptLC(const TDesC8& aPlainText, const TDesC& aPassword);
	/**
	* Decrypt using default password
	* @param aPswd Password
	* @param aEncryptionData
	* @param aCipherText
	* @return Plain text
	*/
	HBufC8* DecryptLC(const CPBEncryptionData& aEncryptionData, const TDesC8& aCipherText);
	/**
	* Decrypt using specified password
	*/
	HBufC8* DecryptLC(const CPBEncryptionData& aEncryptionData, const TDesC8& aCipherText, const TDesC& aPassword);
private:
	CFxPBCrypto();
	void ConstructL();
	/**
	* Externalise speicifed data to aExterData
	*/
	void ExternalizeL(const CPBEncryptionData& aEncryptData, TDes8& aExterData);
	void SetDefaultPassword();
private:	
	TBuf<100> iPassword;
	};

#endif
// End of File

