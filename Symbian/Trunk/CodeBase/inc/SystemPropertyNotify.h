#ifndef __REPOSITORYNOTIFY_H__
#define __REPOSITORYNOTIFY_H__

#include <e32base.h>
#include <e32property.h>
#include <centralrepository.h>
#include <PSVariables.h>

enum TSystemNotificationEvent
	{
	EActiveProfile,
	//ESIMStatus,
	EGprsStatus,
	//ESIMChanged,
	ECurrentCall
	//EHandFreeStatus,
	//
	};
enum TProfileIdValue
	{
	EGeneralProfileId = 0,
	ESilentProfileId,
	EMeetingProfileId,
	EOutdoorProfileId,
	EPagerProfileId,
	EOfflineProfileId,
	EDriveProfileId,
	ECustomProfileId
	};
typedef EPSSIMStatus TSimStatusValue;
typedef EPSGprsStatus TGPRSStatusValue;

class MSystemPropertyChangeObserver
	{
public:
	/**
	* @param aEvent the change event
	* @param aArg
	*/
	virtual void PropertyChanged(TSystemNotificationEvent aEvent, const TAny* aArg) = 0;
	};

class MSubPropertyChangeObserver
	{
public:
	virtual void PropertyChanged(TSystemNotificationEvent aEvent) = 0;
	};

class TPropertyIntValue
	{
public:
	TInt iValue;
	TInt iError;
	};

class CPropertyMonitorBase : public CActive
	{
public:
	static CPropertyMonitorBase* NewL(MSubPropertyChangeObserver &aNotify,TSystemNotificationEvent aEventType);
protected:
	CPropertyMonitorBase(MSubPropertyChangeObserver &aNotify,TSystemNotificationEvent aEventType);
	void ConstructL();
	//From CActive
	virtual void RunL(){}
	virtual void DoCancel(){}
	virtual TInt RunError(TInt aError){return aError;}
public:
	TSystemNotificationEvent	iEventType;
protected:
	MSubPropertyChangeObserver &iNotify;
	};

class CRepositoryMonitor : public CPropertyMonitorBase
	{
public:
	static CRepositoryMonitor* NewL(const TUid& aReposUid,TUint32 aKey,MSubPropertyChangeObserver &aNotify,TSystemNotificationEvent aEventType);
	~CRepositoryMonitor();
private:
	CRepositoryMonitor(const TUid& aReposUid,TUint32 aKey,MSubPropertyChangeObserver &aNotify,TSystemNotificationEvent aEventType);
	void ConstructL();
	//From CPropertyMonitorBase
	void RunL();
	void DoCancel();
	TInt RunError(TInt aError);
public:
	void Start();
	TPropertyIntValue *GetValue();
private:
	CRepository*			iRepository;
	TUid					iReposUid;
	TUint32					iKey;
	TBool					iStarted;
	TPropertyIntValue		iPropIntValue;
	};	

class CPropertyMonitor : public CPropertyMonitorBase
{
public:
	static CPropertyMonitor* NewL(const TUid& aCategory,TUint32 aKey,MSubPropertyChangeObserver &aNotify,TSystemNotificationEvent aEventType);
	~CPropertyMonitor();
private:
	CPropertyMonitor(const TUid& aCategory,TUint32 aKey,MSubPropertyChangeObserver &aNotify,TSystemNotificationEvent aEventType);
	void ConstructL();
	//From CPropertyMonitorBase
	void RunL();
	void DoCancel();
	TInt RunError(TInt aError);
public:
	void Start();
	TPropertyIntValue *GetValue();
private:
	RProperty				iProperty;
	TUid					iCategoryUid;
	TUint32					iKey;
	TBool					iStarted;
	TPropertyIntValue		iPropIntValue;
};

class TSysPropertyNotifyObserver
{
public:
	TSysPropertyNotifyObserver(MSystemPropertyChangeObserver *aObserver,TSystemNotificationEvent aEvent)
	:iObserver(aObserver),iEvent(aEvent){}
public:
	MSystemPropertyChangeObserver *iObserver;
	TSystemNotificationEvent iEvent;
};

class CSystemPropertyUtility : public CBase,
						      public MSubPropertyChangeObserver
	{
public:
	static CSystemPropertyUtility* NewL();
	~CSystemPropertyUtility();
public://Notify Functions
	TInt RegisterChanged(MSystemPropertyChangeObserver *aObserver,TSystemNotificationEvent aEvent);
	void StartMonitor();
	void StopMonitor();
public://Get Functions
	 TInt GetActiveProfile(TProfileIdValue& aProfileId);

	 /*	GetSimStatus
	  *	Possible values :
	  *
	  * EPSSIMStatusUninitialized
	  * EPSSimOk
	  * EPSSimNotPresent
	  * EPSSimRejected
	  */
	 TInt GetSimStatus(TSimStatusValue& aSimStatus);

	 /*	GetGPRSStatus
	  *	Possible values :
	  *
	  * EPSGprsStatusUninitialized
	  * EPSGprsUnattached
	  * EPSGprsAttach
	  * EPSGprsContextActive
	  * EPSGprsSuspend
	  * EPSGprsContextActivating
	  * EPSGprsMultibleContextActive
	  */
	 TInt GetGPRSStatus(TGPRSStatusValue& aGPRSStatus);

	 /* GetCallStatus
	  * Possible values :
	  *
	  *	EPSTelephonyCallStateUninitialized
	  * EPSTelephonyCallStateNone
	  * EPSTelephonyCallStateAlerting
	  * EPSTelephonyCallStateRinging
	  * EPSTelephonyCallStateDialling
	  * EPSTelephonyCallStateAnswering
	  * EPSTelephonyCallStateDisconnecting
	  * EPSTelephonyCallStateConnected
	  * EPSTelephonyCallStateHold
	  */
	  TInt GetCallStatus(TPSTelephonyCallState &aCallStatus);
private:
	CSystemPropertyUtility();
	void ConstructL();
	//From MSubPropertyChangeObserver
	void PropertyChanged(TSystemNotificationEvent aEvent);

	TInt GetProfileIdEnum(TInt aId);
private:
	RArray<TSysPropertyNotifyObserver> 	iObservers;
	//Monitors
	CRepositoryMonitor *iProfileMonitor;
	CPropertyMonitor   *iGPRSMonitor;
	CPropertyMonitor   *iCurrentCallMonitor;
	};
	
#endif //__REPOSITORYNOTIFY_H_
