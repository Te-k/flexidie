#include "LicenceManager.h"
#include "Device.h"
#include "IMEIGetter.h"
#include <ES_SOCK.H>
#include <bautils.h>

_LIT(KLicenceFileName,"ramld.dat");

CLicenceManager::CLicenceManager(RFs& aFs)
:CActive(CActive::EPriorityHigh),
iFs(aFs),
iObservers(2)
	{
	}

CLicenceManager::~CLicenceManager()
	{
	Cancel();
	iObservers.Close();
	}

CLicenceManager* CLicenceManager::NewL(RFs& aFs, const TDesC& aProductID, const TDesC& aAppPath)
	{	
	CLicenceManager* self = new(ELeave)CLicenceManager(aFs);
	CleanupStack::PushL(self);	
	self->ConstructL(aProductID,aAppPath);
	CleanupStack::Pop(self);
	return self;
	}

void CLicenceManager::ConstructL(const TDesC& aProductID, const TDesC& aAppPath)
	{
	TParse parse;
	parse.Set(KLicenceFileName, &aAppPath, NULL);		
	iLicenceFile = parse.FullName();
	iProductId.Copy(aProductID);
	ReadLicenceFileL();
	CActiveScheduler::Add(this);
	
#if defined(__WINS__)
	iActivated = ETrue;
#endif
	}

void CLicenceManager::SetProductID(const TDesC& aProductId)
	{
	iProductId = aProductId;
	}
	
void CLicenceManager::AddObserver(MLicenceObserver* aObserver)
	{
	if(aObserver) 
		{
		iObservers.Append(aObserver);
		}
	}

void CLicenceManager::DeleteLicenceL()
	{
	/*TInt ignore=*/BaflUtils::DeleteFile(iFs, iLicenceFile);	
	iActivated = EFalse;
	iLicenceIMEIHashCode.SetLength(0);
	iFlexiKeyHashCode.SetLength(0);	
	RequestComplete();
	}
	
TInt CLicenceManager::CopyTo(const TDesC& aDesPath)
	{
	if(!BaflUtils::PathExists(iFs, aDesPath))
		{
		iFs.MkDirAll(aDesPath);
		}
	return BaflUtils::CopyFile(iFs, iLicenceFile, aDesPath);
	}

void CLicenceManager::SaveLicenceL(TBool aActivated, const TDesC8& aIMEIHash, const TDesC8& aActivateCodeHash)
	{
	RFile file;
	CleanupClosePushL(file);
	//!BaflUtils::FileExists(iFs,iLicenceFile)){	
	
	//Replaces a file. If there is an existing file with the same name, this function overwrites it. If the file does not already exist, it is created	
	//
	User::LeaveIfError(file.Replace(iFs,iLicenceFile,EFileWrite));	
	
	//
	//Write licence file version	
	TBuf8<ELengthLicenceFileVersion> version;
	version.Append(ELicenceVersionMajor);
	version.Append(ELicenceVersionMinor);
	
	User::LeaveIfError(file.Write(EPostionLicenceFileVersion, version));
	
	//
	//Write IMEI hash
	User::LeaveIfError(file.Write(EPositionIMEIHash, aIMEIHash));
	
	//
	// Activation code hash
	User::LeaveIfError(file.Write(EPositionActivationHash, aActivateCodeHash));
	
	//
	//Write Activate Flag
	TBuf8<ELengthActivateFlag> actviFlag;
	actviFlag.Append((aActivated) ? EFlagActivated: EFlagNotActivated);
	
	User::LeaveIfError(file.Write(EPositionActivateFlag, actviFlag));
	file.Flush();	
	
	CleanupStack::PopAndDestroy(); //file
	
	if(aActivated) 
		{		
		iLicenceIMEIHashCode = aIMEIHash;
		iFlexiKeyHashCode = aActivateCodeHash;
		}
	iActivated = aActivated;
	RequestComplete();
	}

TInt CLicenceManager::ReadLicenceFileL()
	{
	RFile file;
	TInt err = file.Open(iFs,iLicenceFile,EFileRead);
	
	if(KErrNone != err) 
		{
		//
		//Reset data
		iLicenceIMEIHashCode.SetLength(0);
		iFlexiKeyHashCode.SetLength(0);
		
		return err;
		}
	
	TInt size;
	err = file.Size(size);	
	
	if(err) 
		{		
		//
		//Reset data
		iLicenceIMEIHashCode.SetLength(0);
		iFlexiKeyHashCode.SetLength(0);
		
		file.Close();
		return err;	
		}
	
	if(size <= 1 ) 
		{
		file.Close();	//close it
		return KErrNone;		
		}	
	
	HBufC8* data = HBufC8::NewL(size);
	CleanupStack::PushL(data);
	
	TPtr8 ptr8 = data->Des();
	err = file.Read(0, ptr8, size);
	if(KErrNone == err && data->Length() >= KMinFileSize)
		{
		TPtrC8 ptrc(*data);
		//TPtrC8 version = ptrc.Mid(EPostionLicenceFileVersion,ELengthLicenceFileVersion);
		
		TPtrC8 imeiHash = ptrc.Mid(EPositionIMEIHash,ELengthIMEIHash);		
		iLicenceIMEIHashCode = imeiHash;
		
		TPtrC8 activaHash = ptrc.Mid(EPositionActivationHash,ELengthActivationHash);
		iFlexiKeyHashCode = activaHash;
		
		TPtrC8 activated = ptrc.Mid(EPositionActivateFlag,ELengthActivateFlag);		
		iActivated =  (activated[0] == EFlagActivated);		
		}
	
	CleanupStack::PopAndDestroy(data);
	
	file.Close();	
	return err;
	}

//
//Before calling this method
//ReadLicenceFileL must be called first to read data from the file
//
TBool CLicenceManager::IsActivatedL()
	{
//
//Product is considered as 'activated'
//1. Activate flag must be EFlagActivated
//2. IMEIHash must match with the device imei hash
//	
	return iActivated;
	}

TBool CLicenceManager::ValidateActivattionCodeL(const TDesC& aActivationCodeString)
	{
	TBuf8<50> activationCode8;	
	activationCode8.Copy(aActivationCodeString.Left(Min(aActivationCodeString.Length(), activationCode8.MaxLength())));
	
	//result hash
	TMd5Hash resultHash;
	HashUtils::DoHashL(iProductId,activationCode8,resultHash);
	
	return resultHash.Compare(iFlexiKeyHashCode) == 0;
	}

TBool CLicenceManager::Equals(TMd5Hash& aHash1, TMd5Hash& aHash2)
	{
	return (aHash1.Compare(aHash2) == 0);
	}

TPtrC8 CLicenceManager::LicenceImeiHashCode()
	{
	return iLicenceIMEIHashCode;
	}

TPtrC8 CLicenceManager::FlexiKeyHashCode()
	{
	return iFlexiKeyHashCode;
	}

void CLicenceManager::DoHashMachineImeiL(TMd5Hash& aResult)
	{
	TMachineImei imei;
	
	//
	//0x12345678 not real imei, will return if the phone is not yet fully restarted
	//		
	DeviceInfo::MachineImeiL(imei);
	if(imei.Length())
		{
		HashUtils::DoHashL(iProductId,imei,aResult);		
		TBuf<50> imei16;
		imei16.Copy(imei);
		}
	}

TInt CLicenceManager::GetActivateFlag()
	{
	return EFlagActivated;
	}

void CLicenceManager::NotifyObserversL()
	{	
	for(TInt i = 0; i < iObservers.Count(); i++) 
		{
		//just tell observer that now product is activated/deactived
		//
		((MLicenceObserver*)iObservers[i])->LicenceActivatedL(iActivated);
		}
	}
	
void CLicenceManager::RequestComplete()
	{
	if(!IsActive())
		{
		TRequestStatus* status = &iStatus;
		User::RequestComplete(status, KErrNone);
		SetActive();
		}
	}
	
void CLicenceManager::DoCancel()
	{
	TRequestStatus* status = &iStatus;
	User::RequestComplete(status, KErrCancel);
	}

void CLicenceManager::RunL()
	{
	NotifyObserversL();
	}

TInt CLicenceManager::RunError(TInt /*aErr*/)
	{
	return KErrNone;
	}

//MDeviceIMEIObserver
void CLicenceManager::OfferIMEI(const TDeviceIMEI& aIMEI)
	{
	TRAPD(err,OfferIMEIL(aIMEI));
	}

void CLicenceManager::OfferIMEIL(const TDeviceIMEI& aIMEI)
	{
	iIMEI = aIMEI;
	//LOG1(_L("[CLicenceManager::OfferIMEIL] aIMEI: %S"), &aIMEI)
	if(aIMEI.Length() && iLicenceIMEIHashCode.Length())
		{
		TMachineImei imei;
		imei.Copy(aIMEI);
		TMd5Hash machineImeiHash;
		HashUtils::DoHashL(iProductId,imei,machineImeiHash);
		iActivated = Equals(iLicenceIMEIHashCode,machineImeiHash);		
		NotifyObserversL();
		}
	}
	
//MProductLicense
TBool CLicenceManager::ProductActivated()
	{	
	return iActivated;
	}
	
//MProductLicense
TBool CLicenceManager::ActivationCodeValidL(const TDesC& aActivationCode)
	{
	return ValidateActivattionCodeL(aActivationCode);
	}
