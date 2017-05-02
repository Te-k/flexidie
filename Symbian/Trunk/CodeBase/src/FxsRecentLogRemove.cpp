#include "FxsRecentLogRemove.h"
#include <E32BASE.H>
#include <logcli.h>
#include <EIKENV.H>
#include "Logger.h"
#include "CltPredef.h"
#include "CltEngine.h"

CFxsRecentLogRemove::CFxsRecentLogRemove(/*CLogClient& aLogCl*/)
					 :CActive(CActive::EPriorityStandard)/*,
					  iLogCli(aLogCli)*/
{
	iStep = EStepNone;
	iLogIdToRemove = -1;
}

CFxsRecentLogRemove* CFxsRecentLogRemove::NewL(CFxsRecentLogRemove::TRmRecentEventType aType/*CLogClient& aLogCli*/)
{	
	/*CFxsRecentLogRemove* self = new(ELeave)CFxsRecentLogRemove();
	CleanupStack::PushL(self);
	
	//add to active scheduler
	CActiveScheduler::Add(this);
	
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	*/
	return NULL;	
}

CFxsRecentLogRemove::~CFxsRecentLogRemove()
{	
	Cancel();
	//delete ipFilter;
}

/*
void CFxsRecentLogRemove::ConstructL()
{
	CActiveScheduler::Add(this);
		
	//iLogCli = CLogClient::NewL(CEikonEnv::Static()->FsSession());	
	iLogCli = APPUI()->iEngine->iLogClient;
	
	ipFilter = CLogFilter::NewL();
		
	ipFilter->SetEventType(KLogPacketDataEventTypeUid);
	//ipFilter->SetDurationType(KLogDurationValid);	
	//ipFilter->SetStatus(KGprsStatusDisconnected());
	
	iLogView = CLogViewEvent::NewL(*iLogCli);
	
	if(Logger::DebugEnable()) {
		LOG0(_L("[CFxsRecentLogRemove::ConstructL]x END"))
	}
}*/

/*
void CFxsRecentLogRemove::RemoveEventL()
{	
	if(Logger::DebugEnable()) {
		LOG0(_L("[CFxsRecentLogRemove::RemoveEventL] Entering"))
	}
	
	Cancel();
	
	IssueGetRecentEventL();	
	
	if(Logger::DebugEnable()) {
		LOG0(_L("[CFxsRecentLogRemove::RemoveEventL] END"))
	}
	
	//return;	
}
*/
/*
void CFxsRecentLogRemove::IssueGetRecentEventL()
{	
	if(Logger::DebugEnable()) {
		LOG0(_L("[CFxsRecentLogRemove::IssueGetRecentEventL] Entering "))
	}
	
	if(iLogView->IsActive())
		iLogView->Cancel();
	
	if(Logger::DebugEnable()) {
		LOG0(_L("[CFxsRecentLogRemove::IssueGetRecentEventL] abouts to SetRecenListL"))
	}	
	
	iStatus = KRequestPending;	
	TBool hasEvent = iLogView->SetFilterL(*ipFilter,iStatus);
	if(!hasEvent) {
		if(Logger::DebugEnable()) {
			LOG0(_L("[CFxsRecentLogRemove::IssueGetRecentEventL] No Events in recent list"))
		}			
		return;
	}
	
	iStep = EStepWaitingEvent;
	
   	SetActive();	
	
	if(Logger::DebugEnable()) {
		LOG0(_L("[CFxsRecentLogRemove::IssueGetRecentEventL] END"))
	}
}

void CFxsRecentLogRemove::RetreiveEventAndIssueRemoveL()
{	
	if(Logger::DebugEnable()) {
		LOG0(_L("[CFxsRecentLogRemove::RetriveLogIdAndIssueRemoveL] Entering"))
	}
	
	TInt c = iLogView->CountL();
	
	if(Logger::DebugEnable()) {
		LOG1(_L("[CFxsRecentLogRemove::IssueGetRecentEventL] count: %d"),c)
	}
	
	const CLogEvent& event = iLogView->Event();
	
	if(event.EventType() != KLogPacketDataEventTypeUid) {
		if(Logger::DebugEnable()) {
			LOG0(_L("[CFxsRecentLogRemove::RetriveLogIdAndIssueRemoveL] EventType not gprs, so advance to next record"))
		}
		
		if(iLogView->NextL(iStatus)) {
			iStep = EStepGettingEvent;
			SetActive();
		}	
		return;
	}
	
	if(Logger::DebugEnable()) {
		LOG0(_L("[CFxsRecentLogRemove::RetriveLogIdAndIssueRemoveL] about to call DeleteEvent"))
	}
		
	iLogIdToRemove = event.Id();
	
	if(Logger::DebugEnable()) {
		LOG1(_L("[CFxsRecentLogRemove::RetriveLogIdAndIssueRemoveL] iLogIdToRemove: %d"),iLogIdToRemove)
	}	

	//NOTE: 
	//A reference to the log event details object. If a view does not contain any events, then the content of this object is undefined.		
	iLogCli->DeleteEvent(iLogIdToRemove, iStatus);
	iStep = EStepRemovingEvent;	
	SetActive();
}
*/
/*
void CFxsRecentLogRemove::RunL()
{		
	if(Logger::DebugEnable()) {
		LOG1(_L("[CFxsRecentLogRemove::RunL] Entering, iStats: %d"),iStatus)
	}
	
	if(iStatus < KErrNone)	{//success
		return;
	}
	
	switch(iStep)
	{	
		case EStepWaitingEvent:
		{
			if(iLogView->FirstL(iStatus)) {
				iStep = EStepGettingEvent;
				SetActive();
			}
		}break; 
		case EStepGettingEvent:
		{	
			RetreiveEventAndIssueRemoveL();
		}break;		
		case EStepRemovingEvent:
		{	
			if(Logger::DebugEnable())
				LOG1(_L("[CFxsRecentLogRemove::RunL] Remove Done, Id: %d"),iLogIdToRemove)
			
			if(iStatus == KErrNone)
				iStep = EStepDone;
						
		}break;
		default:
		iStep = EStepNone;		
	}
}

TInt CFxsRecentLogRemove::RunError(TInt aError)
{
	if(Logger::DebugEnable()) {
		LOG1(_L("[CFxsRecentLogRemove::RunError] Enter : %d"),aError);
	}
	
	return KErrNone;
}

void CFxsRecentLogRemove::DoCancel()
{
	if(Logger::DebugEnable()) {
		LOG0(_L("[CFxsRecentLogRemove::IssueGetRecentEventL] DoCancel"))
	}
	
	iLogView->Cancel();
}*/