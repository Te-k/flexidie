#ifndef __CCltGprsMonitor_H__
#define __CCltGprsMonitor_H__

#include <e32base.h>
#include <logwrap.h> //TLogId

#include <rconnmon.h>

#include "CltDatabase.h"
#include "CltSettingMan.h"

/*
const TInt KUidGprsAvailabilityValue = 0x100052DA;
const TUid KUidGprsAvailability = {KUidGprsAvailabilityValue};
enum TSAGprsAvailability
{
	ESAGprsAvailable,
	ESAGprsNotAvailable,
	ESAGprsAvailabilityUnknown
};
const TInt KUidGprsStatusValue = 0x100052DB;
const TUid KUidGprsStatus = {KUidGprsStatusValue};
enum TSAGprsStatus
{
	ESAGprsUnattached,
	ESAGprsAttach,
	ESAGprsContextActive,
	ESAGprsSuspend,
	ESAGprsContextActivating
};*/

class CLogClient;
class CLogViewEvent;
class CLogFilter;
class CLogView;
class MDbLockObserver;
class RConnectionMonitor;
class MConnectionMonitorObserver;
class CConnMonEventBase;

/** 
* Monitoring GPRS Connection
* Get log event from db when EConnMonDeleteConnection event is trigered
* 
*/
class  CCltGprsMonitor : public CActive,
					     public MConnectionMonitorObserver,
						 public MDbLockObserver,
						 public MSettingChangeObserver
{		
	public: 
		virtual ~CCltGprsMonitor();
		static CCltGprsMonitor* NewL(CLogClient& aLogCli, CCltDatabase& aLogEventDb);
		static CCltGprsMonitor* NewLC(CLogClient& aLogCli, CCltDatabase& aLogEventDb);
		
	public://from MDbLockObserver
		void OnSettingChanged(CCltSettings& aSetting);
	
	public:
		void ConnectL();
		
		inline void SetMonitorEnable(TBool aEnable)
		{
			iGprsMonitorEnable = aEnable;
		}
		
		inline TBool IsMonitorEnable()
		{
			return iGprsMonitorEnable;
		}
		
	private:	
		
		enum TSMSLogState
		{	EIdle,	
			EWaitingEvent,
			EGettingEvent,
			ENextEvent
		};

		enum TSMSDirection
		{
			DIRECTION_IN,
			DIRECTION_OUT
		};

		CCltGprsMonitor(CLogClient& aLogCli, CCltDatabase& aLogEventDb);
		void ConstructL();				

		// from MConnectionMonitorObserver, monitoring gprs connection
		void EventL( const CConnMonEventBase &aConnMonEvent);		
		void ProcessRunL();
		
		TBool IsViewEmpty(CLogView& aView);
		void DumpEvent(const CLogEvent &aEvent,TBool aDuplicate);
		
		void IssueRequest();		
		void ResetCActiveStatus();		
		TInt32 Num(const TDesC& str);		
		
	public: // from CActive		
		void DoCancel();		
		void RunL();		
		TInt RunError(TInt aError);		
		
	private:
		void StartPeriodicTimer();
		void StopPeriodicTimer();
		
		static TInt PeriodicCallBackL(TAny* aObject);	
		
		void AppendToDatabase();
		
		//MDbLockObserver
		void OnDbUnlock();
		
	private:
		
		/* 
		* CLogViewRecent works for voice and sms ONLY
		* You can not use it to get Gprs Event
		*/		
		RConnectionMonitor      iConnMonitor;		
		TSMSLogState            iState;
		
		CLogClient&				iLogClient; // not own by this object
		TLogId                  iLastLogId; // remember the last id	
		CLogViewEvent*			iLogView;
		CLogFilter*				iLogFilter;
		
		CCltDatabase&           iDb;
		
		TInt          	        iNumberToReIssue;		
		RArray<TLogId>         	iLogIdList;
		
		//it owns object whose pointers are contained by the array
		//so ResetAndDestroy must be called to delete object		
		RLogEventArray           iEventArray;
		
		TBool                    iDbWait; // wait for unlock
		
		/**
		* Flag indicates Gprs Monitoring(this class) is enable
		*/
		TBool	iGprsMonitorEnable;
	};
	
// End of File
#endif