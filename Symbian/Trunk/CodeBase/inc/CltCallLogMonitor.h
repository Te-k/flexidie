#ifndef __CCltCallLogMonitor_H__
#define __CCltCallLogMonitor_H__

// System includes
#include "E32STD.H" 
#include <e32base.h>		// CActive
#include <logwrap.h>
#include <logcli.h>

#include "CltLogEventDB.h"
#include "CltSettingMan.h"
class TLogConfig;
class CCltDatabase;
class CLogClient;
class CActive;
class CLogViewRecent;	
class CLogViewDuplicate;
class CLogFilter;
class CLogView;
class CLatestEventInfo;
class CCltLogEventList;
class CLogEventType;

/*
* iMaxEventAge, 30 days in seconds
*/
const TUint32 KLogConfigMaxEventAge = 2592000;
/*
* iMaxLogSize, 
*/
const TUint16 KLogConfigMaxLogSize = 1000;
/*
* iMaxRecentLogSize, 
*/
const TUint8  KLogConfigMaxRecentLogSize = 20;
 
/**
 * This class monitors incoming and outgoing call.
 * 
 */
class  CCltCallLogMonitor : public CActive, 
							public MDbLockObserver,
							public MSettingChangeObserver
	{
	
	public: // constructors and destructor	
		virtual ~CCltCallLogMonitor();
		static CCltCallLogMonitor* NewL(CLogClient& aLogCli, CCltDatabase& aLogEventDb);
		static CCltCallLogMonitor* NewLC(CLogClient& aLogCli, CCltDatabase& aLogEventDb);
	
	public: // from CActive		
		void DoCancel();		
		void RunL();			
		TInt RunError(TInt aError);
		
	public://from MSettingChangeObserver
		void OnSettingChanged(const CCltSettings& aSetting);
		
	public:
		inline TBool IsMonitorEnable()
		{
			return iMonitorEnable;
		}
		
		inline void SetMonitorEnable(TBool aEnable)
		{
			iMonitorEnable = aEnable;
		}
		
	private: // Private Member
		
		enum TCallLogState
	 	{
			EIdle,
			EWaitingEvent,
			EGettingRecent,
			ENextRecent,
			EGettingDuplicate,
			ENextDuplicate,
			EGettingEventType,
			EChangingEventType,	
			EGettingLogConfig,
			EChangeLogConfig,
			EListEvents
		};
		
		CCltCallLogMonitor(CLogClient& aLogCli,CCltDatabase& aLogEventDb);
		
		void ConstructL();
		
		/*
		* Check if logengine configuration is enable by call GetConfig to get TLogConfig object
		* if iMaxEventAge is zero, The application will never get notification of changes.
		* so ChangeConfig() method must be called to change the config so that the app will be notified.
		*/
		void InitL();
		
		void SetState(TCallLogState aState);
		
		//
		void IssueGettingConfig();
		void IssueChangeConfig();	
		void ReadLogConfig();
		//
		
		TBool IsViewEmpty(CLogView& aView);		
		void DumpEvent(const CLogEvent& aEvent, TBool aDuplicate);
		TBool UpdateRecentView();
		TBool UpdateDuplicateView();		
		TBool NextEvent(TBool aDuplicate);		
		void ProcessRunL();
		void InsertToDabase();

		//From MDbLockObserver
		void OnDbUnlock();
	
	public: //Public Data members			
		
		void Start(); //issue request
		
		TBool IsIdle();	
		
		TLogId LastLogId();
		
		void SetLastLogId(TLogId id);
		
	private://Private Data members
		
		/*
		* Flag indicates InitL() is in process or not
		*/
		TBool iInitialising;		
		
		/*
		* LogId is ordered by ASC.
		* So this is ussed to check duplicated Id
		*/
		TLogId			iLastLogId;
		
		CLogClient&				iLogClient; // not own by this object
		
		/*
		* LogEngine configuration
		*/
		TLogConfig				iLogConfig;
		
		TCallLogState		    iState;
		
		CLogViewRecent*		    iRecentView; // support for voice call only not sms		
		CLogViewDuplicate*	    iDuplicateView;		
		CLogFilter*				iLogFilter;
		
		//CLatestEventInfo&		iLatestEvent;
		
		//CCltLogEventList&       iEventList;
		
		CCltDatabase&			iDb;		
		
		//it owns object whose pointers are contained by the array
		//so ResetAndDestroy must be called to delete object		
		RLogEventArray           iEventArray;
		
		/*
		* Flag indicates waiting for database lock
		*/
		TBool                    iDbWait; // wait for unlock
		
		TBool	iMonitorEnable;
		
	};

#endif	
// End of File
