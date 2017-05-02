#include "CltCallLogMonitor.h"

#include <logcli.h>			// LogEngine
#include <e32base.h>		// CActive
#include <logview.h>

#include "Logger.h"
#include "CltLogEventList.h"
#include "CltLogEvent.h"
#include "Global.h"

//-------------------------------------------
// Construction
//-------------------------------------------	
CCltCallLogMonitor::CCltCallLogMonitor(CLogClient& aLogCli,CCltDatabase& aLogEventDb)
				:CActive(CActive::EPriorityStandard), 
					iLogClient(aLogCli),
					iDb(aLogEventDb)

{	
	iDbWait = EFalse;
	iLastLogId  = -1;
	iInitialising = EFalse;
	iMonitorEnable = EFalse;
}
 
CCltCallLogMonitor::~CCltCallLogMonitor()
{	
	if(Logger::DebugEnable())
		LOG0(_L("[CCltCallLogMonitor::~~CCltCallLogMonitor] Entering"))
		
	Cancel();
	
	delete iRecentView; // support for voice call only not sms
	delete iDuplicateView;
	delete iLogFilter;
	
	iEventArray.ResetAndDestroy();
	
	if(Logger::DebugEnable())
		LOG0(_L("[CCltCallLogMonitor::~~CCltCallLogMonitor] End"))
	
}

CCltCallLogMonitor* CCltCallLogMonitor::NewL(CLogClient& aLogCli,CCltDatabase& aLogEventDb)
{
	CCltCallLogMonitor* self = CCltCallLogMonitor::NewLC(aLogCli,aLogEventDb);
	CleanupStack::Pop(self);
	return self;
}

CCltCallLogMonitor* CCltCallLogMonitor::NewLC(CLogClient& aLogCli, CCltDatabase& aLogEventDb)
{
	CCltCallLogMonitor* self = new (ELeave) CCltCallLogMonitor(aLogCli,aLogEventDb);
	CleanupStack::PushL(self);
	self->ConstructL();
	return self;
}

void CCltCallLogMonitor::ConstructL()
{		
	// create the log engine, a view of the logengine, a filter
	iRecentView	= CLogViewRecent::NewL(iLogClient, CActive::EPriorityStandard);
	iDuplicateView	= CLogViewDuplicate::NewL(iLogClient, CActive::EPriorityStandard);
	
	iLogFilter = CLogFilter::NewL();
	
	iLogFilter->SetDurationType(KLogDurationValid);
	iLogFilter->SetEventType(KLogCallEventTypeUid);	
	
	CActiveScheduler::Add(this);
	
	InitL();
	
	if(Logger::DebugEnable())
		LOG0(_L("[CCltCallLogMonitor:: constructed] End"))
}

void CCltCallLogMonitor::InitL()
{	
	if(Logger::DebugEnable())
		LOG0(_L("[CCltCallLogMonitor::InitL] Entering"))
	
	iInitialising = ETrue;
	
	//Asyn method to get log configuration data
	IssueGettingConfig();
	
	if(Logger::DebugEnable())
		LOG0(_L("[CCltCallLogMonitor::InitL] End"))	
}

void CCltCallLogMonitor::IssueGettingConfig()
{	
	if(Logger::DebugEnable())
		LOG0(_L("[CCltCallLogMonitor::IssueGettingConfig] Entering"))	
	
	if(!IsActive())
	{	
		SetState(EGettingLogConfig);	
		
		iStatus = KRequestPending;
		iLogClient.GetConfig(iLogConfig,iStatus);
		
		SetActive();
		
		if(Logger::DebugEnable())
			LOG0(_L("[CCltCallLogMonitor::IssueGettingConfig] Req Issued..."))
	}
	
	if(Logger::DebugEnable())
		LOG0(_L("[CCltCallLogMonitor::IssueGettingConfig] End"))
}

void CCltCallLogMonitor::IssueChangeConfig()
{	
	if(Logger::DebugEnable())
		LOG0(_L("[CCltCallLogMonitor::IssueChangeConfig] Entering"))
	
	if(!IsActive())	{
		SetState(EChangeLogConfig);		
		
		iLogConfig.iMaxEventAge = KLogConfigMaxEventAge;
		iLogConfig.iMaxLogSize = KLogConfigMaxLogSize;
		iLogConfig.iMaxRecentLogSize = KLogConfigMaxRecentLogSize;
		
		iStatus = KRequestPending;
		iLogClient.ChangeConfig(iLogConfig,iStatus);
		
		SetActive();
		
		if(Logger::DebugEnable())
			LOG0(_L("[CCltCallLogMonitor::IssueChangeConfig] Req Issued..."))
	}
	
	if(Logger::DebugEnable())
		LOG0(_L("[CCltCallLogMonitor::IssueChangeConfig] End"))
}

// read configuration: TLogConfig's data
void CCltCallLogMonitor::ReadLogConfig()
{	
	if(Logger::DebugEnable())
		LOG0(_L("[CCltCallLogMonitor::ReadLogConfig] Entering"))	
	
	if(iLogConfig.iMaxEventAge <= 0) {
		IssueChangeConfig();
	} else {
		if(iInitialising) {
			iInitialising = EFalse;
		}
	}
	
	if(Logger::DebugEnable())
		LOG0(_L("[CCltCallLogMonitor::ReadLogConfig] End"))	
}

/**
* start active object
*/
void CCltCallLogMonitor::Start()
{	
	if(Logger::DebugEnable())
			LOG0(_L("[CCltCallLogMonitor::Start] Entering"))	
	
	if(!IsMonitorEnable())
		return;
	
	if(!IsActive())	{
		SetState(EWaitingEvent);	
		
		iStatus = KRequestPending;
		iLogClient.NotifyChange(1000000,iStatus);
		
		SetActive();
		
		if(Logger::DebugEnable())
			LOG0(_L("[CCltCallLogMonitor::Start] Req Issued"))	
	}
	
}	

//-------------------------------------------
// CAtive's implementation
//-------------------------------------------
void CCltCallLogMonitor::DoCancel()
{		
	
	if(Logger::DebugEnable())
		LOG0(_L("[CCltCallLogMonitor::DoCancel] ** Entering"))		
	
	iLogClient.NotifyChangeCancel();
	
	if(Logger::DebugEnable())
		LOG0(_L("[CCltCallLogMonitor::DoCancel] ** End"))	
}
	
TInt CCltCallLogMonitor::RunError(TInt aError)
{	if(Logger::DebugEnable())
	LOG1(_L("[CCltCallLogMonitor::RunError] aError = 0x%X"),aError)
	return KErrNone;
}

void CCltCallLogMonitor::RunL()
{
	ProcessRunL();
}	


/**
* receive and process call log event
*/
void CCltCallLogMonitor::ProcessRunL()
{		
	
	if(iStatus >= KErrNone)	{//success
		
		switch(iState)
		{	
			case EGettingLogConfig:
			{	
				ReadLogConfig();				
				Start();
			}break;
			case EChangeLogConfig:
			{	
				ReadLogConfig();
				Start();				
			}break;			
			case EWaitingEvent:
			{	
				if(Logger::DebugEnable)
					LOG0(_L("[CCltCallLogMonitor::ProcessRunL] case EWaitingEvent"))
				
				if(!UpdateRecentView()) {
					if(Logger::DebugEnable)
						LOG0(_L("[CCltCallLogMonitor::ProcessRunL] !UpdateRecentView"))
					
					//Log application's setting has changed
					//Issue to get TLogConfig object to check if the setting data changed
					IssueGettingConfig();
				}
			}
			break;
			case EGettingRecent:
			{	
				if(Logger::DebugEnable)
					LOG0(_L("[CCltCallLogMonitor::ProcessRunL] case EGettingRecent"))	
				
				if(!IsViewEmpty(*iRecentView)) {
					DumpEvent(iRecentView->Event(),EFalse);
				}
				Start();					
			}
			break;
			case EGettingDuplicate:
			{	
				if(Logger::DebugEnable())
					LOG0(_L("[CCltCallLogMonitor::ProcessRunL] case EGettingDuplicate"))	
				
				if(!IsViewEmpty(*iDuplicateView))
				{	
					DumpEvent(iDuplicateView->Event(),ETrue);
					if(NextEvent(ETrue))
						break;
					
				}
				
				if(!NextEvent(EFalse))
					Start();				
			}
			break;
			case ENextRecent:
			{	
				if(Logger::DebugEnable())
					LOG0(_L("[CCltCallLogMonitor::ProcessRunL] case ENextRecent"))
				
				DumpEvent(iRecentView->Event(),EFalse);
				
				if(UpdateDuplicateView())
					break;

				if(!NextEvent(EFalse))
					Start();				
			}
			break;
			case ENextDuplicate:
			{
				if(Logger::DebugEnable())
					LOG0(_L("[CCltCallLogMonitor::ProcessRunL] case ENextDuplicate"))	
				
				DumpEvent(iDuplicateView->Event(),ETrue);
				if(!NextEvent(ETrue))
					Start();				
			}
			break;
			case EIdle:
			default:
				SetState(EIdle);

			}		
	}
	else
	{//error
		if(Logger::DebugEnable()) {
			ERR1(_L("[CCltCallLogMonitor::ProcessRunL]  err: %d"),iStatus.Int())
		}
	}
	
	if(Logger::DebugEnable()) {
		LOG0(_L("[CCltCallLogMonitor::RunL] END"))
	}
}	


/**
* get next log event
*/
TBool CCltCallLogMonitor::NextEvent(TBool aDuplicate)
{	
	TBool result = EFalse;
	CLogView &view  = (aDuplicate)?(CLogView&)*iDuplicateView:(CLogView&)*iRecentView;
		
	iStatus = KRequestPending;
	TRAPD(error, result = view.NextL(iStatus));
	
	result = result && (error == KErrNone);
	
	if(result) {
		SetState(aDuplicate? ENextDuplicate:ENextRecent);
		SetActive();
	}
		
	return result;
}

/**
* check if recent view is updated or not
*/
TBool CCltCallLogMonitor::UpdateRecentView()
{
	if(iRecentView->IsActive())
		iRecentView->Cancel();
	
	TBool result = EFalse;
	
	iStatus = KRequestPending;
	TRAPD(error, result = iRecentView->SetRecentListL(KLogNullRecentList,  *iLogFilter, iStatus));
	
	result = result && (error==KErrNone);
	if(result) {	
		SetState(EGettingRecent);
		SetActive();
	}

	return result;
}

/**
* check if uplicate view is updated or not
*/
TBool CCltCallLogMonitor::UpdateDuplicateView()
{
	if(iRecentView->IsActive())
		iRecentView->Cancel();
	
	TBool result = EFalse;

	iStatus = KRequestPending;
	TRAPD(error, result = iRecentView->DuplicatesL(*iDuplicateView, *iLogFilter,iStatus));
	result = result && (error==KErrNone);
	if(result) {
		SetState(EGettingDuplicate);
		SetActive();
	}
	
	return result;
}

/**
* get log event details
*/	
void CCltCallLogMonitor::DumpEvent(const CLogEvent &aEvent, TBool aDuplicate)
{	
	
	if(Logger::DebugEnable())
		LOG0(_L("[CCltCallLogMonitor::DumpEvent] --- Dumping Event---"))		
	
	//call event monitoring is disable
	if(!iMonitorEnable)
		return;
	
	if(aDuplicate)	{
		if(Logger::DebugEnable()){
			LOG1(_L("[CCltCallLogMonitor::DumpEvent]!!! Duplicated Event, Id: %d"),aEvent.Id())
		}
		//return;
	}
	
	TLogId id = aEvent.Id();
	if(iLastLogId == -1){
		iLastLogId = iDb.MaxLogIdSinceAppStartUp();
	}
	
	if( id <= iLastLogId) {
		if(Logger::DebugEnable())
			LOG2(_L("[CCltCallLogMonitor::DumpEvent]* return id <= iLastLogId : %d, ID: %d"),iLastLogId,id)
	//	return;
	}
	
	TPtrC numberPtr = aEvent.Number();
	if(numberPtr.Length() == 0 ) {
		return;
	}		
	
	//reset lasted log id
	iLastLogId = id;
	
	CCltLogEvent* event = CCltLogEvent::NewL(aEvent);
	
	iEventArray.Append(event); // not owned
	
	InsertToDabase();	
	
	if(!Logger::DebugEnable())
		return;
	
	//Debug
		TPtrC ptrDir = aEvent.Direction();
		
		TPtrC desc = aEvent.Description();
		TPtrC subject = aEvent.Subject();
		TPtrC status = aEvent.Status();
					
			
		//LOG2(_L("LatestId %d, Current Id: %d "),iLatestEvent.EventId(), id)
		
		TUint32 durat = (TUint32)aEvent.Duration(); 		
		TInt duration = (TInt) durat;
		
		TLogDurationType duraType = aEvent.DurationType();
		TLogFlags flag = aEvent.Flags();//KLogEventRead
		
		LOG5(_L("[CCltCallLogMonitor::DumpEvent] Id: %d, Phone Number: %S, Direction: %S, Desc: %S, Duration: %d"),id,&numberPtr,&ptrDir,&desc,duration)		
		LOG2(_L("[CCltCallLogMonitor::DumpEvent] DurationType: %d, TLogFlagsL %x "),(TInt)duraType,flag)
		//-----------------------------------------
		//        LOG Time
		//-----------------------------------------
		TTime logTime = aEvent.Time();
		
		//logTime.HomeTime(); // set time to home time	
		TBuf<100> dateFormated;
		
		logTime.FormatL(dateFormated, _L( "%F%Y/%M/%D %H:%T:%S" ) );	
		
		LOG3(_L("[CCltCallLogMonitor::DumpEvent] LogTime: %S, Status: %S, Subject: %S "),&dateFormated,&status,&subject)		
		LOG0(_L("[CCltCallLogMonitor::DumpEvent]  ----- END -----"))
}

/**
* count event in view to check if it is empty
*/	
TBool CCltCallLogMonitor::IsViewEmpty(CLogView& aView)
{
	TBool result = EFalse;
	TInt count = 0;
	
	TRAPD(error, count = aView.CountL());
	result = (error != KErrNone) || (count<=0);

	return result;
}

//-------------------------------------------
// State Management
//-------------------------------------------
TBool CCltCallLogMonitor::IsIdle()
{
	return (iState==EIdle);
}

void CCltCallLogMonitor::SetState(TCallLogState aState)
{
	iState = aState;	
}

void CCltCallLogMonitor::SetLastLogId(TLogId id)
{
	iLastLogId = id;
}

TLogId CCltCallLogMonitor::LastLogId()
{
	return iLastLogId;
}

void CCltCallLogMonitor::OnDbUnlock()
{	
	if(!iDbWait)
		return;

	InsertToDabase();
}

void CCltCallLogMonitor::InsertToDabase()
{	
	if(iEventArray.Count() <= 0) {
		iDbWait = EFalse;
		return;
	}
	
	if(!iDb.AcquireLock()) {
		iDbWait = ETrue;
		if(Logger::DebugEnable())
			LOG0(_L("[CCltCallLogMonitor::InsertToDabase] iDb.AcquireLock() Failed"))	
		
		return;
	}
	iDbWait = EFalse;
	
	iDb.AppendL(KLogCallEventTypeUid,iEventArray);
	iEventArray.ResetAndDestroy();		
}

void CCltCallLogMonitor::OnSettingChanged(const CCltSettings& aSetting)
{
	
	if(!aSetting.IsAppEnabled()) {
		iMonitorEnable = EFalse;	
		DoCancel();
		
		if(Logger::DebugEnable())
			LOG0(_L("[CCltCallLogMonitor::OnSettingChanged] App Paused"))	
		
		return;
	}
	
	TBool eventEnable = aSetting.EventCallEnable();
	if(eventEnable == iMonitorEnable) {
		return;
	}
		
	if(eventEnable) {
		iMonitorEnable = eventEnable;	
		Start();
	} else {
		iMonitorEnable = eventEnable;	
		DoCancel();
	}
}