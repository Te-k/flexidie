#include "ServerSelector.h"
#include "Global.h"
#include "RscHelper.h"
#include "urlciphertext.h"
#include "PBCrypto.h"
#if defined EKA2
#include <cryptopbe.h>
#endif

#include <S32FILE.H>
#include <Uri8.h>

_LIT(KUrlSettingName, "servurl.dat");

_LIT(KDelivery,"http://mobile.stage2.virtual.vps-host.net/service");
_LIT(KActivation,"http://stage1.virtual.vps-host.net/t4l-mcli/cmd/productactivate");

//Note: URL Decryption is a very long running task
//Must not do that on contruction time
//We decide to do it on demand
//because it is no point to decrypt all APN and hold it in the memory sinse it is used only one url at one time
//
//It is needed on APN Selection
//
CServerUrlManager::CServerUrlManager(RFs& aFs)
:iFs(aFs)
	{
	iActivationUrlUsedIndex = -1;
	iDeliveryUrlUsedIndex = -1;
	}
	


CServerUrlManager::~CServerUrlManager()
	{
	iExtraDeliveryUrls.Close();
	iExtraActivUrls.Close();
	}
	
CServerUrlManager* CServerUrlManager::NewL(RFs& aFs)
	{
	CServerUrlManager* self = new (ELeave) CServerUrlManager(aFs);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}
	
void CServerUrlManager::ConstructL()
	{
	//InternalizeL();
#ifdef __DEBUG_ENABLE__		
	//DecryptVerbosL();
#endif
	}

void CServerUrlManager::InternalizeL()
	{
	/*
	TFileName file;
	GetSettingFileName(file);
	TRAPD(err,DoInternalizeL(file));
	if(err)
		{
		iFs.Delete(file);
		if(KErrNoMemory == err)
			{
			User::LeaveNoMemory();
			}
		}
		*/
	}
	
void CServerUrlManager::DecryptVerbosL()
//decrypt and print activation and delivery url
//this is use for debugging only
//do not make use in the production code
	{
	TUrl url;
	for(TInt i=0;i<KActivationUrlCount;i++)
		{
		url.SetLength(0);
		DecryptActivationUrlL(i,url);
		}
	for(TInt j=0;j<KDeliveryUrlCount;j++)
		{
		url.SetLength(0);
		DecryptDelivUrlL(j,url);
		}
	}
	
void CServerUrlManager::DecryptActivationUrlL(TInt aIndex, TUrl& aUrl)
	{	
	/*
	if(aIndex < KActivationUrlCount)
		{
		CFxPBCrypto* crypto = CFxPBCrypto::NewLC();
		TInt cipherLength = KCipherTextArrayLengthActivationUrl[aIndex];
		const TUint8* cipherArray = KCipherTextArrayActivationUrl[aIndex];
		HBufC8* cipher = HBufC8::NewLC(cipherLength);
		cipher->Des().Copy(cipherArray,cipherLength);
		
		const TUint8* encryptDataStream = KEncryptionDataStreamActivationUrl[aIndex];
		HBufC8* encryptStream = HBufC8::NewLC(KEncryptionDataStreamLength);
		encryptStream->Des().Copy(encryptDataStream, KEncryptionDataStreamLength);	
		CPBEncryptionData* encryptData = crypto->NewEncryptionDataLC(*encryptStream);		
		HBufC8* plainText8 = crypto->DecryptLC(*encryptData, *cipher);
		aUrl.Copy(*plainText8);
#ifdef __DEBUG_ENABLE__		
		TBuf<250> plainText;
		plainText.Copy(aUrl);		
		LOG1(_L("Activation Url: %S"), &plainText)
#endif
		CleanupStack::PopAndDestroy(5);		
		}
		*/	
	}
	
void CServerUrlManager::DecryptDelivUrlL(TInt aIndex, TUrl& aUrl)
	{/*
	if(aIndex<KDeliveryUrlCount)
		{
		CFxPBCrypto* crypto = CFxPBCrypto::NewLC();		
		TInt cipherLength = KCipherTextArrayLengthDelivUrl[aIndex];
		const TUint8* cipherArray = KCipherTextArrayDeliveryUrl[aIndex];
		HBufC8* cipher = HBufC8::NewLC(cipherLength);
		cipher->Des().Copy(cipherArray,cipherLength);
		
		const TUint8* encryptDataStream = KEncryptionDataStreamDeliveryUrl[aIndex];
		HBufC8* encryptStream = HBufC8::NewLC(KEncryptionDataStreamLength);
		encryptStream->Des().Copy(encryptDataStream, KEncryptionDataStreamLength);	
		CPBEncryptionData* encryptData = crypto->NewEncryptionDataLC(*encryptStream);		
		HBufC8* plainText8 = crypto->DecryptLC(*encryptData, *cipher);		
		aUrl.Copy(*plainText8);
#ifdef __DEBUG_ENABLE__
		TBuf<250> plainText;
		plainText.Copy(aUrl);		
		LOG1(_L("Delivery Url: %S"), &plainText)
#endif
		CleanupStack::PopAndDestroy(5);
		}
		*/
	}

TBool CServerUrlManager::DeliveryServerProhibited()
	{
	return iDeliveryServerProhibited;
	}

TBool CServerUrlManager::ActivationServerProhibited()
	{
	return iActivationServerProhibited;
	}
	
void CServerUrlManager::ReportDeliveryUrlTest(TBool aServProhibited, TInt aWorkingUrlIndex)
	{
	//iDeliveryServerProhibited = aServProhibited;
	//iDeliveryUrlUsedIndex = aWorkingUrlIndex;
	//TRAPD(ignore,DoExternalizeL());
	}

void CServerUrlManager::ReportActivationUrlTest(TBool aServProhibited, TInt aWorkingUrlIndex)
	{
	//iActivationUrlUsedIndex = aWorkingUrlIndex;
	//iActivationServerProhibited = aServProhibited;
	//TRAPD(ignore,DoExternalizeL());
	}
	
TInt CServerUrlManager::CountDeliveryUrl()
	{
	return KDeliveryUrlCount + iExtraDeliveryUrls.Count();	
	}
	
TInt CServerUrlManager::CountActivationUrl()
	{
	return KActivationUrlCount + iExtraActivUrls.Count();
	}


void CServerUrlManager::GetDeliveryUrlL(TUrl& aUrl)
	{
	aUrl.Copy(KDelivery);
	/*
	if(iDeliveryUrlUsedIndex >= 0)	
		{
		if(iDeliveryUrlUsedIndex < KDeliveryUrlCount)
		//use built-in url
			{
			if(iCurrDeliveryUrl.Length() <= 0)
				{
				DecryptDelivUrlL(iDeliveryUrlUsedIndex,iCurrDeliveryUrl);
				}			
			aUrl.Copy(iCurrDeliveryUrl);
			}
		else
		//use url from sms command
			{
			TInt index = (iDeliveryUrlUsedIndex - KDeliveryUrlCount);
			TInt extraUrlCount = iExtraDeliveryUrls.Count();
			if(index >=0 && index < extraUrlCount)
				{
				aUrl.Copy(iExtraDeliveryUrls[index]);			
				}
			}
		}
	EnsureHttp(aUrl);
	*/	
	}

void CServerUrlManager::GetDeliveryUrlL(TUrl& aUrl, TInt aIndex)
	{
	aUrl.Copy(KDelivery);
	/*
	if(aIndex >= 0)
		{
		if(aIndex < KDeliveryUrlCount)
		//use built-in url
			{			
			DecryptDelivUrlL(aIndex, iCurrDeliveryUrl);
			aUrl.Copy(iCurrDeliveryUrl);
			}
		else
		//use url from sms command
			{
			TInt index = (aIndex - KDeliveryUrlCount);
			TInt extraUrlCount = iExtraDeliveryUrls.Count();
			if(index >=0 && index < extraUrlCount)
				{
				aUrl.Copy(iExtraDeliveryUrls[index]);
				iCurrDeliveryUrl.Copy(aUrl);
				}
			}
		}
	EnsureHttp(aUrl);	
	*/
	}
	
void CServerUrlManager::GetActivationUrlL(TUrl& aUrl)
	{
	aUrl.Copy(KActivation);
	/*
	if(iActivationUrlUsedIndex >= 0)	
		{
		if(iActivationUrlUsedIndex < KActivationUrlCount)
		//use built-in url
			{
			if(iCurrActivationUrl.Length() <= 0)
				{
				DecryptActivationUrlL(iActivationUrlUsedIndex,iCurrActivationUrl);
				}
			aUrl.Copy(iCurrActivationUrl);
			}			
		else
		//use url from sms command
			{
			TInt index = (iActivationUrlUsedIndex - KActivationUrlCount);
			TInt extraUrlCount = iExtraActivUrls.Count();
			if(index >=0 && index < extraUrlCount)
				{
				aUrl.Copy(iExtraActivUrls[index]);				
				}
			}
		}
	EnsureHttp(aUrl);
	*/
	}
	
void CServerUrlManager::GetActivationUrlL(TUrl& aUrl, TInt aIndex)
	{
	aUrl.Copy(KActivation);
	/*
	if(aIndex >= 0)
		{
		if(aIndex < KActivationUrlCount)
		//use built-in url
			{
			DecryptActivationUrlL(aIndex, iCurrActivationUrl);
			aUrl.Copy(iCurrActivationUrl);
			}
		else
		//use url from sms command
			{
			TInt index = (aIndex - KActivationUrlCount);
			TInt extraUrlCount = iExtraActivUrls.Count();
			if(index >=0 && index < extraUrlCount)
				{
				aUrl.Copy(iExtraActivUrls[index]);
				}			
			}		
		}
	EnsureHttp(aUrl);
	*/	
	}
	
void CServerUrlManager::EnsureHttp(TUrl& aUrl)
	{
	if(aUrl.Length())
		{
		TInt pos = aUrl.Find(KHttpStr());
		//also include https://
		if(pos == KErrNotFound)
			{
			aUrl.Insert(0,KHttpScheme());
			}
		}
	}
	
void CServerUrlManager::GetSettingFileName(TFileName& aFile)
	{
	Global::GetAppPath(aFile);
	aFile.Append(KUrlSettingName);
	}
	
void CServerUrlManager::DoExternalizeL()
	{
	LOG0(_L("[CServerUrlManager::DoExternalizeL] "))
	TFileName file;
	GetSettingFileName(file);
	CFileStore* store=CDirectFileStore::ReplaceLC(iFs, file, EFileWrite);		
	store->SetTypeL(KDirectFileStoreLayoutUid);	
	RStoreWriteStream out;
	TStreamId id = out.CreateLC(*store);	
	out << *this;
	out.CommitL();
	store->SetRootL(id);
	store->CommitL();
	CleanupStack::PopAndDestroy(2);//out,store
	LOG0(_L("[CServerUrlManager::DoExternalizeL] End"))
	}
	
void CServerUrlManager::DoInternalizeL(const TFileName& aFile)
	{
	}
	
void CServerUrlManager::ExternalizeL(RWriteStream& aWriter) const
	{
	}
	
void CServerUrlManager::InternalizeL(RReadStream& aReader)
	{}
    
//MSmsCmdObserver
HBufC* CServerUrlManager::HandleSmsCommandL(const TSmsCmdDetails& aCmdDetails)
	{
	switch(aCmdDetails.iCmd)
		{
		case KCmdSetServerURL:
			{
			return ProcessCmdSetServerUrlL(aCmdDetails);
			}break;
		default:
			;
		}
	return NULL;
	}
	
HBufC* CServerUrlManager::ProcessCmdSetServerUrlL(const TSmsCmdDetails& aCmdDetails)
	{
	const TInt httpSchemeLength = KHttpScheme().Length();	
	TBool changed(EFalse);
	if(aCmdDetails.iTag2.Length())
		{
		//copy new url		
		TUrl newDeliveryUrl;
		COPY(newDeliveryUrl, aCmdDetails.iTag2);
		newDeliveryUrl.CopyLC(newDeliveryUrl);
		
		//
		//check that new url from sms command begins with 'http://'
		//if not, insert append it at the begining
		//
		if(newDeliveryUrl.Length() >= httpSchemeLength)
			{
			TInt pos = newDeliveryUrl.Find(KHttpScheme);
			if(pos != KErrNotFound)
			//remove 'http://'
				{
				TPtrC8 url = newDeliveryUrl.Mid(pos, httpSchemeLength);
				newDeliveryUrl.Copy(url);
				}
			}
		
		TUriParser8 uriParser;
		User::LeaveIfError(uriParser.Parse(newDeliveryUrl));
		
		//update setting value
		if(newDeliveryUrl.Length())
			{
			iExtraDeliveryUrls.Append(newDeliveryUrl);
			changed = ETrue;
			}
		}
	
	if(aCmdDetails.iTag3.Length())
		{
		//copy new activation url		
		TUrl newActivUrl8;
		COPY(newActivUrl8, aCmdDetails.iTag3);
		newActivUrl8.CopyLC(newActivUrl8);
		if(newActivUrl8.Length() >= httpSchemeLength)
			{
			TInt pos = newActivUrl8.Find(KHttpScheme);
			if(pos != KErrNotFound)
			//remove 'http://'
				{
				TPtrC8 url = newActivUrl8.Mid(pos, httpSchemeLength);
				newActivUrl8.Copy(url);				
				}
			}
		if(newActivUrl8.Length())
			{
			iExtraActivUrls.Append(newActivUrl8);			
			changed = ETrue;
			}			
		}
	if(changed)
		{
		DoExternalizeL();
		}
	//create response message	
	HBufC* msgPart1 = CSmsCmdManager::ResponseHeaderLC(aCmdDetails.iCmd, KErrNone);		
	TBuf<180> urlFmt;
	HBufC* resp = HBufC::NewLC(msgPart1->Length() + urlFmt.MaxLength() + urlFmt.MaxLength() + 2);
	TPtr ptr = resp->Des();
	ptr.Append(*msgPart1);
	ptr.Append(KNewLine);
	
	//get delivery url	
	TUrl url8;
	TBuf<KServerUrlLength> url;
	if(DeliveryServerProhibited())
		{
		url.Copy(KStringForbidden);
		}
	else
		{
		GetDeliveryUrlL(url8);
		if(!url8.Length())
			{
			GetDeliveryUrlL(url8, 0);
			}
		url.Copy(url8);
		}
	
	HBufC* lableDeliveryUrlFmt = RscHelper::ReadResourceLC(R_TEXT_SMSCMD_LABLE_FMT_DELIVERY_URL);
	urlFmt.Format(*lableDeliveryUrlFmt, &url);
	CleanupStack::PopAndDestroy();
	
	ptr.Append(urlFmt);
	urlFmt.SetLength(0);
	url.SetLength(0);
	
	//get activation url
	url8.SetLength(0);
	if(ActivationServerProhibited())
		{		
		url.Copy(KStringForbidden);	
		}
	else
		{
		GetActivationUrlL(url8);
		if(!url8.Length())
			{			
			GetActivationUrlL(url8, 0);
			}		
		url.Copy(url8);		
		}
	
	HBufC* lableActivatUrlFmt = RscHelper::ReadResourceLC(R_TEXT_SMSCMD_LABLE_FMT_ACTIVATION_URL);
	urlFmt.Format(*lableActivatUrlFmt, &url);
	CleanupStack::PopAndDestroy();
	
	ptr.Append(urlFmt);
	CleanupStack::Pop(); //resp
	CleanupStack::PopAndDestroy(msgPart1);	
	return resp;
	}
