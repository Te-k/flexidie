#include "FxsGprsRecentLogRm.h"
#include <logcli.h>
#include <EIKENV.H>
#include "Global.h"

CFxsGprsRecentLogRm::CFxsGprsRecentLogRm()
:CActive(CActive::EPriorityLow)
	{
	}

CFxsGprsRecentLogRm::~CFxsGprsRecentLogRm()
	{
	Cancel();	
	delete iLogView;
	delete ipFilter;
	delete iLogCli;
	}

CFxsGprsRecentLogRm* CFxsGprsRecentLogRm::NewL()
	{	
	CFxsGprsRecentLogRm* self = new(ELeave)CFxsGprsRecentLogRm();
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}

void CFxsGprsRecentLogRm::ConstructL()
	{
	iLogCli = CLogClient::NewL(Global::FsSession());			
	ipFilter = CLogFilter::NewL();
	
	ipFilter->SetEventType(KLogPacketDataEventTypeUid);
	ipFilter->SetDurationType(KLogDurationValid);	
	//ipFilter->SetStatus(KGprsStatusDisconnected());
	
	iLogView = CLogViewEvent::NewL(*iLogCli);
	CActiveScheduler::Add(this);
	}

void CFxsGprsRecentLogRm::RemoveAllEvent()
	{
	iRemoveAll = ETrue;
	RemoveLastEvent();
	}
	
void CFxsGprsRecentLogRm::RemoveLastEvent()
	{
	TRAPD(ignore, RemoveLastEventL());
	}

void CFxsGprsRecentLogRm::RemoveLastEventL()
	{	
	Cancel();	
	IssueGetRecentEventL();
	}

void CFxsGprsRecentLogRm::IssueGetRecentEventL()
	{
	iLogView->Cancel();	
	TBool hasEvent = iLogView->SetFilterL(*ipFilter,iStatus);	
	if(hasEvent) 
		{
		iStep = EStepFilterEvent;	
	   	SetActive();	
		}
	}

void CFxsGprsRecentLogRm::RetreiveAndIssueRemoveL()
	{	
	const CLogEvent& event = iLogView->Event();	
	if(event.EventType() != KLogPacketDataEventTypeUid) 
		{
		if(iLogView->NextL(iStatus)) 
			{
			iStep = EStepGetEvent;
			SetActive();
			}	
		}
	else 
		{
		iLogIdToRemove = event.Id();
		//NOTE: 
		//A reference to the log event details object. If a view does not contain any events, then the content of this object is undefined.		
		iLogCli->DeleteEvent(iLogIdToRemove, iStatus);
		iStep = EStepRemovEvent;	
		SetActive();
		}
	}

TBool CFxsGprsRecentLogRm::GetFirstL()
	{
	if(iLogView->FirstL(iStatus)) 
		{
		iStep = EStepGetEvent;
		SetActive();
		return ETrue;
		}
	return EFalse;
	}

void CFxsGprsRecentLogRm::RunL()
	{
	if(iStatus >= KErrNone)
		{
		switch(iStep)
			{
			case EStepFilterEvent:
				{
				TBool issued = GetFirstL();
				if(!issued && iRemoveAll)
					{
					iRemoveAll = EFalse;
					}				
				}break;
			case EStepGetEvent:
				{
				RetreiveAndIssueRemoveL();
				}break;
			case EStepRemovEvent:
				{
				if(iRemoveAll)
					{
					TBool issued = GetFirstL();
					if(!issued)
						{
						iRemoveAll = EFalse;
						iStep = EStepNone;
						}
					}
				}break;
			default:
				{
				iStep = EStepNone;		
				}				
			}
		}
	}

TInt CFxsGprsRecentLogRm::RunError(TInt /*aError*/)
	{
	iRemoveAll = EFalse;	
	return KErrNone;
	}

void CFxsGprsRecentLogRm::DoCancel()
	{
	//If there is no request outstanding, then the function does nothing.
	iLogView->Cancel();
	iLogCli->Cancel();
	}
