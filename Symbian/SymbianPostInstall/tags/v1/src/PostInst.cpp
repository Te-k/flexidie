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
#ifdef __BUILD_MOMA__
	_LIT(KPostInstTxtName, "C:\\private\\2002E09B\\postinst.txt");
#else
	_LIT(KPostInstTxtName, "C:\\private\\2000B2C8\\postinst.txt");
#endif

_LIT(KAppUid, "APPUID");
_LIT(KKeyShowIcon, "S");
_LIT(KKeyShowIconUid, "SHUID");
_LIT(KSep, "\\");
_LIT(KPrivate, "private");
//_LIT(KUidShowIcon, "2000B2CA");

const TUint KUidShow = 0x2000B2CA;

const TInt KMaxBuf = 20;

void GetCommandLineTail(TDes8& aEndTail)
    {
    _LIT8(KTail1,"POSTINST:START");
    //_LIT8(KTail2,"54E7A68876CDFD068CFA0EF9013A835A");//fake
    aEndTail.Copy(KTail1);
    }

void MainL()
	{
	LOGENTER
	User::After(2000000);
	
//#if !__WINS__
	CInstallActive* installAct = CInstallActive::NewL();
	CleanupStack::PushL(installAct);
	//LOGPTR(iInstallAct)
//#endif
	
	TBool bClickYes = DialogUtils::ShowGlobalMsgAsConfirmationQueryL(0,0);
	
	// open connection to file server
	RFs fs;
	TInt errConnect = fs.Connect();	
	if (!errConnect)
		{
		LOGS("connection to file server successful.")
		CProperties* prop = CProperties::NewL(fs, KPostInstTxtName);
		CleanupStack::PushL(prop);
		
		HBufC* strUid = prop->ValueLC(KAppUid);
		
		if (strUid)
			{
			LOG("Application uid : %S ", &(*strUid))
			TUint tmpUid(0);
			TLex lex(*strUid);
			User::LeaveIfError(lex.Val(tmpUid, EHex));
			TUid appUid(TUid::Uid(tmpUid));
			
			LOGS("Connect apalsSession.")
			RApaLsSession apaLsSession;
			User::LeaveIfError(apaLsSession.Connect());
			CleanupClosePushL(apaLsSession);
			
			LOGS("ApalsSession connected.")
			
			TApaAppInfo appInfo;
			//Get application information from uid.
			TInt errAppInfo = apaLsSession.GetAppInfo(appInfo, appUid);
			
			LOG("GetAppInfo return error : %d", errAppInfo);
			if(errAppInfo == KErrNone)
		    	{
		    	//Get full path of main application.
		    	TFullName* appName = new (ELeave)TFullName;
		    	CleanupStack::PushL(appName);
		    	appName->Format(appInfo.iFullName);
		    	
//		    	TParse parse;
//		    	parse.Set(*appName, NULL, NULL);
//		    	TBuf<3> drive(parse.Drive());
		    	TBuf<3> drive(appName->Mid(0,2));
		    	
		    	LOG("Path name of application : %S", appName)
		    	LOG("Drive : %S", &drive)
		    	
//		    	TDevicePlatform platForm = PlatformUtil::DevicePlatform(fs);
//		    	LOG("Plat form is %d", platForm)
		    	
		    	HBufC* iconFileName = NULL;
		    	TFullName* iconPathName = new (ELeave)TFullName; //NULL;
		    	CleanupStack::PushL(iconPathName);
		    	if (bClickYes)
		    		{
		    		//Click "Yes"
		    							
		    		CApaCommandLine* cmdLine = CApaCommandLine::NewLC();
					cmdLine->SetExecutableNameL(*appName);
					cmdLine->SetCommandL(EApaCommandOpen); //EApaCommandOpen, EApaCommandRun, EApaCommandBackground
					
					TBuf8<100> tail;
					//set trailling data
					GetCommandLineTail(tail);
					//dummy app.mgr will check this value and starts up if they are match
					cmdLine->SetTailEndL(tail);
					
					User::LeaveIfError(apaLsSession.StartApp(*cmdLine));
					CleanupStack::PopAndDestroy(cmdLine);
					
					User::After(5000000); // To prevent installer busy -30481
					//TUid uidOfShowIcon(TUid::Uid(KUidShow));
					HBufC* shUidStr = NULL;
					shUidStr = prop->ValueLC(KKeyShowIconUid);
					if (shUidStr)
						{
						TUint tmpUid(0);
						TLex lex(*shUidStr);
						User::LeaveIfError(lex.Val(tmpUid, EHex));
						TUid uidOfShowIcon(TUid::Uid(tmpUid));
									
						installAct->UninstallNow(uidOfShowIcon);
						CActiveScheduler::Start();
						}
					CleanupStack::PopAndDestroy(shUidStr);
		    		}
		    	else
		    		{
		    		//Click "No"
    				iconFileName = prop->ValueLC(KKeyShowIcon);
    				
    				if (iconFileName)
    					{
    					iconPathName->Append(drive);
    					iconPathName->Append(KSep);
    					iconPathName->Append(KPrivate);
    					iconPathName->Append(KSep);
    					iconPathName->Append(*strUid);
    					iconPathName->Append(KSep);
    					iconPathName->Append(*iconFileName);
    					//iconPathName->Format(_L("%S%S%S%S%S%S%S"), drive, KSep, KPrivate, KSep, *strUid, KSep, *iconFileName);
    					LOG("Path name of ShowIcon installer : %S", iconPathName);
//#if !__WINS__
    					User::After(5000000); // To prevent installer busy -30481
    					installAct->InstallNow(*iconPathName); // show icon
    					CActiveScheduler::Start();
//#endif
    					}
    				CleanupStack::PopAndDestroy(iconFileName);
		    		}
		    	CleanupStack::PopAndDestroy(iconPathName);
		    	CleanupStack::PopAndDestroy(appName);
		    	}
			CleanupStack::PopAndDestroy(&apaLsSession);
			}
		CleanupStack::PopAndDestroy(strUid);
		CleanupStack::PopAndDestroy(prop);
		fs.Close();
		}
		
//	LOGS("Start scheduler.")
//	CActiveScheduler::Start();

//#if !__WINS__
	CleanupStack::PopAndDestroy(installAct);
//#endif

	LOGEXIT
	}

void DoStartL()
	{
	LOGENTER
	// Create active scheduler (to run active objects)
	CActiveScheduler* scheduler = new (ELeave) CActiveScheduler();
	CleanupStack::PushL(scheduler);
	CActiveScheduler::Install(scheduler);
	
	MainL();
	
	// Delete active scheduler
	CleanupStack::PopAndDestroy(scheduler);
	LOGEXIT
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

