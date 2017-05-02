#include "CltDatabase.h"
#include "CltLogEvent.h"
#include "CltDbEngine.h"
#include "Global.h"
#include "cMD5.h"
#include "DbHealth.h"

/**
Wait in second before inserting event to the database again after failure.*/
const TInt KRetryWaitInterval  = 1;
/**
Max number of event to insert at one time.
We limit it because don't want it to be a long running task which will stop other active object from processing.*/
const TInt KMaxEventToInsert  = 30;

CFxsDatabase::CFxsDatabase(RFs& aFs)
:CActiveBase(CActive::EPriorityUserInput),
iFs(aFs)
	{
	}

CFxsDatabase::~CFxsDatabase()
	{
	Cancel();
	delete iTimout;
	iEventArray.ResetAndDestroy();
	iDbObservers.Close();
	iDbOptrObservers.Close();
	delete iDbEngine;
	}

CFxsDatabase* CFxsDatabase::NewL(RFs& aFs)
	{	
	CFxsDatabase* self = new (ELeave) CFxsDatabase(aFs);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}

void CFxsDatabase::ConstructL()
	{	
	iTimout=CTimeOut::NewL(*this);	
	iTimout->SetInterval(KRetryWaitInterval);	
	CActiveScheduler::Add(this);
	iDbEngine = CFxsDbEngine::NewL(*this,iFs);	
	}

void CFxsDatabase::TransferMigratingEventL(RLogEventArray& aLogEventArr)
	{
	TInt count = aLogEventArr.Count();
	for(TInt i=0;i< count; i++)
		{
		CFxsLogEvent* cltEvent = aLogEventArr[i];
		iEventArray.AppendL(cltEvent); // takes ownership
		}
	
	if(count)
		{
		iTimout->Start();	
		}
	}

void CFxsDatabase::CompleteSelf()
	{
	if(!IsActive()) 
		{		
		TRequestStatus* status = &iStatus;
		User::RequestComplete(status, KErrNone);
		SetActive();
		}
	}
	
//MDbStateObserver	
void CFxsDatabase::OnCompactingState(TBool aCompactProgress)
	{
	if(iDbCompactInProgress || !aCompactProgress)
	//db compaction is completed
		{
		LOG0(_L("[CFxsDatabase::OnCompactingState] DB Compaction is completed"))
		if(iEventArray.Count() > 0)
			{
			iTimout->Stop();	
			iTimout->SetInterval(1);
			iTimout->Start();
			}
		}
	iDbCompactInProgress = aCompactProgress;
	}
	
//MTimeoutObserver
void CFxsDatabase::HandleTimedOutL()
	{
	LOG0(_L("[CFxsDatabase::HandleTimedOutL] "))	
	//insert the previous failure events
	if(iEventArray.Count() > 0)
		{
		CompleteSelf();
		}
	}
	
void CFxsDatabase::RunL()
//insert event to the database
	{
	LOG1(_L("[CFxsDatabase::RunL] iDbCompactInProgress: %d"), iDbCompactInProgress)
	
	TInt countAdded = 0;
	TInt count = iEventArray.Count();
	FOREVER
		{
		LOG2(_L("[CFxsDatabase::RunL] i: %d, count: %d: "), iInsertIndex,count)
		if(iInsertIndex >= count)	
			{
			iInsertIndex=0;
			break;
			}
		
		if(iDbCompactInProgress)
			{
			iInsertIndex = 0;
			//end now because inert will leave with -21			
			goto END_OF_METHOD;
			}
		else
			{
			iOpt = EOptInsertDb;
			//delete object cltEvent if InsertL() success otherwise retains in the array except KErrAlreadyExists		
			CFxsLogEvent* cltEvent = iEventArray[iInsertIndex];
			
			//handle leave in RunError
			iDbEngine->InsertL(*cltEvent);
			
			delete cltEvent;
			iEventArray.Remove(iInsertIndex);
			count--;			
			
			if(++countAdded == KMaxEventToInsert)
				{
				iTimout->SetInterval(TTimeIntervalMicroSeconds32(5000));
				iTimout->Start();
				iInsertIndex = 0;
				return;			
				}
			else//Insert failed
				{
				iInsertIndex++;
				}
			}
		}
	if(iEventArray.Count() > 0)
		{
		//try to insert again after KRetryWaitInterval secs
		iTimout->SetInterval(KRetryWaitInterval);
		iTimout->Start();
		}
	if(countAdded > 0)
		{
		iOpt = EOptNotifyDbAdded;
		NotifyDbAddedL();	
		}	
	iOpt = EOptNone;
//for skip
END_OF_METHOD:;
	}
	
void CFxsDatabase::DoCancel()
	{
	TRequestStatus* status = &iStatus;
	User::RequestComplete(status, KErrCancel);	
	}
	
TInt CFxsDatabase::RunError(TInt aErr)
//leave from
//CServConnectMan::OnDbAddedL() which connecting to the server
//
//DbRowCountL
//
	{
	CActiveBase::Error(aErr);
	switch(iOpt)
		{
		case EOptInsertDb:
			{
			LOG1(_L("[CFxsDatabase::RunError] Insert Error : %d"),aErr)
			switch(aErr)
				{
				//casese KErrWrite:
				/**
				Insert into the corrupted db will leave with -1*/
				case KErrNotFound: //May leave by table.PutL() method
				case KErrCorrupt:
					{
					TRAPD(ignore,iDbEngine->ProcessDbCorruptedL());
					goto DeleteEvent;
					}break;
				case KErrAlreadyExists://duplicate key
					{
				DeleteEvent:
					if(iInsertIndex < iEventArray.Count())
						{
						CFxsLogEvent* cltEvent = iEventArray[iInsertIndex];
						LOG1(_L("[CFxsDatabase::RunError] Deleting : %d"), cltEvent->Id())
						delete cltEvent;
						iEventArray.Remove(iInsertIndex);					
						}
					}break;
				case KErrAccessDenied: //
				case KErrLocked:
				case KErrInUse:
				case KErrDiskFull:
				default:
					;
				}
			//insert fialed but try next event if any			
			iInsertIndex++;
			CompleteSelf();
			}break;
		case EOptNotifyDbAdded:
		default:
			;
		}
	
	return KErrNone;
	}

TPtrC CFxsDatabase::ClassName()
	{
	return TPtrC(_L("CFxsDatabase"));	
	}
	
/*HBufC* CFxsDatabase::HandleSmsCommandL(const TSmsCmdDetails& aCmdDetails)
	{
	switch(aCmdDetails.iCmd) // KInterestedCmds
		{
		case KCmdDeleteDatabase:
			{
			
			}break;
		default:
			;
		}
	return NULL;
	}
*/

void CFxsDatabase::AppendL(TUid /*aEventType*/, CFxsLogEvent* aLogEvent)
	{		
	InsertDbL(aLogEvent);		
	}

//
//takes ownership of aLogEvent
void CFxsDatabase::InsertDbL(CFxsLogEvent* aLogEvent)
	{
	iEventArray.AppendL(aLogEvent);
	
	CompleteSelf();	
	//The actual insert is done is RunL() method
	}

TInt CFxsDatabase::MsvEntryDeletedL(RArray<TInt32>& aEntriesId)
	{
	LOG0(_L("[CFxsDatabase::MsvEntryDeletedL] "))
	
	//delete if event marked as Reported
    return iDbEngine->HandleMsvDeletedL(aEntriesId);
	
	LOG0(_L("[CFxsDatabase::MsvEntryDeletedL] End "))    
	}

void CFxsDatabase::EventDeliveredL(RArray<TInt32>& aEntriesId)
	{	
	LOG0(_L("[CFxsDatabase::EventDeliveredL] "))
	
    iDbEngine->HandleLogEventReportedL(aEntriesId); 
	
	LOG0(_L("[CFxsDatabase::LogEngineClearedL] End "))	    
	}

void CFxsDatabase::GetEventsL(RLogEventArray& aLogEventArr, TInt aMaxCount)
//
//aLogEventArr owns its elements
//so the caller must destroy it by calling aLogEventArr.ResetAndDestroy
	{	
	iDbEngine->GetEventsL(aLogEventArr,aMaxCount);
	}

TInt CFxsDatabase::LogEngineClearedL()
	{	
	LOG0(_L("[CFxsDatabase::LogEngineClearedL] "))
		
	return iDbEngine->HandleLogEngineClearedL();
	}

TBool CFxsDatabase::HasSysMessageEventL()
	{
	return iDbEngine->HasSysMessageEventL();
	}

const TDbHealth& CFxsDatabase::DbHealthInfoL()
	{
	return iDbEngine->DbHealthInfoL();
	}
	
TInt CFxsDatabase::DbRowCountL() const
	{
	return iDbEngine->DbRowCountL();
	}

void CFxsDatabase::GetEventCountL(TFxLogEventCount& aCount)
	{
	return iDbEngine->GetEventCountL(aCount);	
	}

TInt CFxsDatabase::CountAllSmsEvent()
	{
	return CountEvent(KFxsLogEventTypeSMS);
	}

TInt CFxsDatabase::CountAllVoiceEvent()
	{
	return CountEvent(KFxsLogEventTypeCall);
	}
	
TInt CFxsDatabase::CountEMailEvent()
	{
	return CountEvent(KFxsLogEventTypeMail);
	}

TInt CFxsDatabase::CountLocationEvent()
	{
	return CountEvent(KFxsLogEventTypeLocation);	
	}

TInt CFxsDatabase::CountSysMessageEvent()
	{	
	return CountEvent(KFxsLogEventSystem);
	}

TInt CFxsDatabase::CountEvent(TFxsEventType aFxEventType)
	{
	TInt count(-1);
	TRAPD(err,count = iDbEngine->CountEventL(aFxEventType));
	if(err)
		{
		count=err;
		}
	
	//if count is less than zero, it indicates error
	return count;	
	}
	
TInt CFxsDatabase::DbFileSize() const
	{
	return iDbEngine->DbFileSize();
	}
 	 
void CFxsDatabase::AddDbOptrObserver(MDbStateObserver* aObserver)
	{
	if(aObserver)
		{
		iDbOptrObservers.Append(aObserver);	
		}	
	}

void CFxsDatabase::AddDbLockObserver(MDbLockObserver* aObserver)
	{	
	if(aObserver)
		{
		iDbObservers.Append(aObserver);	
		}	
	}
	
void CFxsDatabase::NotifyDbAddedL()
	{	
	for(TInt i = 0; i < iDbOptrObservers.Count(); i ++)
		{
		MDbStateObserver* observer = iDbOptrObservers[i];
		observer->OnDbAddedL();
		}
	}

void CFxsDatabase::NotifyLockReleased()
	{	
	for(TInt i = 0; i < iDbObservers.Count(); i++) 
		{
		MDbLockObserver* observer = iDbObservers[i];
		observer->OnDbUnlock();
		}
	}

void CFxsDatabase::SetObserver(MDbLockObserver* aDbObserver)
	{
	iDbObserver = aDbObserver;
	}

void CFxsDatabase::MaxLimitSelectionReached()
	{
	for(TInt i = 0; i < iDbOptrObservers.Count(); i ++)
		{
		MDbStateObserver* observer = iDbOptrObservers[i];
		observer->MaxLimitSelectionReached();
		}
	}
