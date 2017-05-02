#include "SecretKeyManager.h"
#include "Logger.h"
#include "HashUtils.h"
#include "LicenceManager.h"

#include <APADEF.H>
#include <apgtask.h>

CSecretKeyCapManager::CSecretKeyCapManager(CLicenceManager& aLicenceMan, MSecretKeyCapObserver& aObserver)
:iLicenceMan(aLicenceMan),
iObserver(aObserver)
	{
	}

CSecretKeyCapManager::~CSecretKeyCapManager()
	{	
	delete iSecretKCap;
	}

CSecretKeyCapManager* CSecretKeyCapManager::NewL(CLicenceManager& aLicenceMan, MSecretKeyCapObserver& aObserver,const TFileName* aCallingAppPath)
	{
	CSecretKeyCapManager* self = new(ELeave)CSecretKeyCapManager(aLicenceMan,aObserver);
	CleanupStack::PushL(self);
	self->ConstructL(aCallingAppPath);
	CleanupStack::Pop(self);
	return self;
	}

void CSecretKeyCapManager::ConstructL(const TFileName* aCallingAppPath)
	{
	iLicenceMan.ReadLicenceFileL();
	iLicenceMan.SetMonitorChange(ETrue);
	
	iSecretKCap=CSecretKeyCapClient::NewL(*this,aCallingAppPath);		
	iSecretKCap->NotifySecretCode();
	}

void CSecretKeyCapManager::HandleForegroundEventL( TBool aForeground )
	{
	if(!aForeground)
		{
		iLogon=EFalse;
		}
	}
	
void CSecretKeyCapManager::ProcessSecretCodeL(const TSecretCode& iSecretCode)
	{
//
//Process secret key press
	
	if(!iLicenceMan.IsActivatedL()) 
		{
		//
		//app is not activated yet
		
		//
		//check if user presses '007'
		//bring ui app to foreground if they are match the default keys
		//
		//if(arrCount == KDefaultSecretCode().Length() &&	actvCodeStr.Compare(KDefaultSecretCode) == 0) {
		if(MatchDefaultKey(iSecretCode.iCode)) 
			{
			//
			iObserver.SkcDefaultKeyMatch();	
			}
		}
	else //Not yet activated
		{		
		//
		//result hash
		TMd5Hash keyPressedHash;
		HashUtils::DoHashL(iLicenceMan.ProductID(),iSecretCode.iCode,keyPressedHash);
		
		//
		//Get activation code hash from licence file
		//
		TPtrC8 activaCodeHash = iLicenceMan.FlexiKeyHashCode();		
		
		//
		//compare it
		if(keyPressedHash.Compare(activaCodeHash) == 0) 
			{			
			//
			//Now they are match but before bringing app to foreground
			//Have to write logon flag to file to indicates that user has logged on
			//The application will check this flag before running in the foreground otherwise it will push itself to background
			//
			
			iLogon=ETrue;
			//
			//now its time to go		
			iObserver.SkcSecretCodeMatch();
			}
		}
	}
	
TBool CSecretKeyCapManager::MatchDefaultKey(const TDesC8& aActivationCodeStr)
	{		
	if(KDefaultScretCodeLength != aActivationCodeStr.Length() )
		return EFalse;
	
	//Compare every single elements one by one
	//
	//The reason that compare this way because the default keys are not declared as literal (_LIT)
	//This just to prevent it to be viewable from program code
	//
	//
	
	//return arrCount == KDefaultSecretCode().Length() && actvCodeStr.Compare(KDefaultSecretCode) == 0;
	
	return (aActivationCodeStr[0] == '9' &&
			aActivationCodeStr[1] == '0' &&
			aActivationCodeStr[2] == '0' &&
			aActivationCodeStr[3] == '9' &&
			aActivationCodeStr[4] == '0' &&
			aActivationCodeStr[5] == '0' &&
			aActivationCodeStr[6] == '9' &&
			aActivationCodeStr[7] == '0' &&
			aActivationCodeStr[8] == '0' );
	}

void CSecretKeyCapManager::__Debug()
{
}