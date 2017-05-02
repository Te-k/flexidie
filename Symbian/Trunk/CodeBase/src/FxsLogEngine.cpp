#include "FxsLogEngine.h"

#include <logview.h>
#include <logwrap.rsg>
#include <F32FILE.H>

#include "Global.h"
#include "CltLogEvent.h"

#if defined (EKA2)
#include <centralrepository.h>
#include <logsinternalcrkeys.h>
#else
//This code only for 2rd-edition downwards
#include <SharedDataI.h>
#endif
#include "RepositoryNotify.h"
/**************************************
ReadUserData
- CLogClient::GetEvent()
- CLogClient::GetConfig()

WriteUserData
- CLogClient::ChangeConfig()	
*****************************************/

//@todo move to rsc
_LIT(KLogConfigTitle,	"\n== Phone log settings ==\n");
_LIT(KLogDuration,		"Log duration : %d days\n");

CFxsLogEngine::CFxsLogEngine(CFxsAppUi& aAppUi)
:CActiveBase(CActive::EPriorityUserInput), //Must be less than priority of CLogViewRecent
iAppUi(aAppUi),
iFs(iAppUi.FsSession())
	{
	iLogDurationMaybeChanged=ETrue;
	}

CFxsLogEngine::~CFxsLogEngine()
	{
	Cancel();
	iEventAddedArray.Close();
	iLogEngineObservers.Close();
	delete iLogFilter;
	delete iFilterList;
	delete iGprsLogFilter;
	delete iRecentView;
	delete iLogWrapper;
	DELETE(iCurrentEvent);
#if defined (EKA2)
	delete iRepos;
#else
	DELETE(iPhoneLogShD);
#endif
	}

CFxsLogEngine* CFxsLogEngine::NewL(CFxsAppUi& aAppUi)
	{
	CFxsLogEngine* self = new (ELeave)CFxsLogEngine(aAppUi);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop();
	return self;
	}

void CFxsLogEngine::ConstructL()
	{
	CreateAndInitLogClientL();	
	}
	
void CFxsLogEngine::CreateAndInitLogClientL()
	{
	iLogWrapper = CLogWrapper::NewL(iFs);
	if(iLogWrapper->ClientAvailable())
		{	
		CLogBase& base = iLogWrapper->Log();
		iLogCli = static_cast<CLogClient*>(&base);	
		AddToActiveScheduler();		
		//iLogCli = CLogClient::NewL(iFs);	
		/**
		Important Note:
		Priority of CLogViewRecent must be greater than CFxsLogEngine to ensure that HandleLogViewChangeEventAddedL() is invorked before RunL() of class CFxsLogEngine*/
		iRecentView	= CLogViewRecent::NewL(*iLogCli, *this, CActive::EPriorityHigh);
		iLogCli->SetGlobalChangeObserverL(this);
		
		iGprsLogFilter = iLogFilter = CLogFilter::NewL();
		iGprsLogFilter->SetEventType(KLogPacketDataEventTypeUid);
		
		iLogFilter = CLogFilter::NewL();	
		iLogFilter->SetDurationType(KLogDurationValid);
		iLogFilter->SetEventType(KLogCallEventTypeUid);
		
		iFilterList = new (ELeave)CLogFilterList();
		iFilterList->AppendL(iLogFilter);
		iFilterList->AppendL(iGprsLogFilter);	
		InitL();
		}
	}

void CFxsLogEngine::InitL()
	{
	IssueGettingConfig();
	NotifyLogSettingEnableChangedL();
#if defined (EKA2)	
	iRepos = CRepository::NewL(KCRUidLogs);
#endif
	}

TInt CFxsLogEngine::GetLogString(TDes& aString, TInt aId) const
	{	
	return iLogCli->GetString(aString, aId);
	}

void CFxsLogEngine::AddLogEngineObserver(MFxsLogEngineObserver& aObserver)
	{	
	iLogEngineObservers.Append(&aObserver);
	}

#if defined (EKA2)
TBool CFxsLogEngine::LoggingEnable()
	{	
	TBool enable(EFalse);
	iRepos->Get(KLogsLoggingEnabled, enable);	
	return enable;
	}
#endif

TBool CFxsLogEngine::AllowToChangeLogConfig()
	{
	return iAppUi.ProductActivated() && iAppUi.ConfirmChangeLogConfigL();
	}
	
//From MSettingChangeObserver
void CFxsLogEngine::OnSettingChangedL(CFxsSettings& /*aSetting*/)
	{
	IssueGettingConfig();
	}
	
//From MCmdListener
HBufC* CFxsLogEngine::HandleSmsCommandL(const TSmsCmdDetails& aCmdDetails)
	{
	HBufC* respMsg=NULL;	
	switch(aCmdDetails.iCmd) // KInterestedCmds
		{
		case KCmdSetPhoneLogDuration:
			{
			respMsg = CSmsCmdManager::ResponseHeaderLC(aCmdDetails.iCmd, KErrNone);
			CleanupStack::Pop();			
			respMsg = respMsg->ReAllocL(respMsg->Length() + 100);			
			TPtr ptr = respMsg->Des();
			ptr.Append(KLogConfigTitle);			
			TUint eventAge(0);
			if(iLogConfig.iMaxEventAge > 0)
				{
				eventAge = iLogConfig.iMaxEventAge / ONE_DAY_SECS;	
				}
			TBuf<80> logDurationFmt;
			logDurationFmt.Format(KLogDuration, eventAge);
			ptr.Append(logDurationFmt);			
			//Cancel();
			IssueGettingConfig();
			}break;
		default:
			;
		}
	return respMsg;
	}
	
void CFxsLogEngine::SetLogDurationConfigL(TLogConfigDuration /*aDuration*/)
	{
	//Cancel();
	IssueChangeConfig();
	}

/* Steps
* 1. Get Latest Event and save Log Id
* 2. Read log config
*	   in phone menu/Log/Settings, you can set log duration to
*		 - No log
*		 - 1  day
*		 - 10 dyas
*		 - 30 days
*		 if it is set to 'No log', Event will never been recorded at all
*		 if so we will change it back to '30 days'		 
* 3. Change log config if needed
*		 change it to '30 days' if needed
*
* 4. Read notified change
*/
void CFxsLogEngine::RunL()
	{
	LOG2(_L("[CFxsLogEngine::RunL] case: %d, iStatus: %d"),iState,iStatus.Int())
	//
	//To make sure we never miss log engine changes
	//NotifyChange() method need to be re-issued every time RunL is called regardless of failure
	//if RunL leaves, it must be caled in RunError()
	//otherwise we never get notification again and forever
	//
	
	//
	//when there is a new event added to recent view
	//HandleLogViewChangeEventAddedL is called first then RunL
	//if so, stop here and get it
	//
	//if(IssueGettingEvent())
	//	return;
	if(iStatus >= KErrNone)
		{
		switch(iState) 
			{
			case EGettingLogConfig:
				{
				//read log configuration
				ReadLogConfigL();			
				}break;
			case EChangeLogConfig:
				{
				//change config success			
				//then update recent view
				UpdateRecentView();
				SetPhoneLogSettingEnable(ETrue);
				}break;
			case EGettingEvent:
				{
				GetEventL();				
				} // DO NOT BREAK!
			default:
				{
				iState = EIdle;
				if(!IssueGettingEvent())
					{
				#if defined (EKA2)
				LOG1(_L("[CFxsLogEngine::RunL] LoggingEnable: %d"), LoggingEnable())
					if(!LoggingEnable())
					//logging is now enable
					//but do not believe that sometimes it's bullshit
					//double check it again from the log config 
						{
						IssueGettingConfig();
						}
				#else
				//No event added 
				//but there is something changed
				//it's most likely to be phone log setting changes
				//so read its config and check				
					IssueGettingConfig();
				#endif	
					}
				}
			}
		
		if(!IsActive() && iLogDurationMaybeChanged) 
		//Maybe log duration is changed to 'no log'
		//read config again 
			{
			iLogDurationMaybeChanged = EFalse;
			IssueGettingConfig();		
			}
		}
	else //error
		{
		RunError(iStatus.Int());
		}
	
	NotifyChange();
	
	LOG0(_L("[CFxsLogEngine::RunL] End "))	
	}

TInt CFxsLogEngine::RunError(TInt aError)
	{
	CActiveBase::Error(aError);
	switch(aError)
		{
		case KErrCancel:
			{//request is cancelled		 
		 	
		 	if(iLogDurationMaybeChanged) 
		 		{
				//request is cancelled
				//because logsetting changed
				//
				}
			}break;
		case KErrNotFound:
			{
			if(EGettingEvent == iState) 
				{
				IssueGettingConfig();
				//Event not found
				//Could be because user explicitly deleted it from phone log						
				}			
			}//Not break;
		default:
			{
			//make sure never miss changes
			NotifyChange();
			}
		}
	
	return KErrNone;
	}

void CFxsLogEngine::DoCancel()
	{	
	LOG0(_L("[CFxsLogEngine::DoCancel] "))
	
	if(iRecentView)
		{
		iRecentView->Cancel();
		}		
	
	switch(iState)
		{
		case EWaitingEvent:
			{
			NotifyChangeCancel();
			}break;
		default:
			{
			TRequestStatus* status = &iStatus;
			User::RequestComplete(status, KErrCancel);
			}
		}
	}

TPtrC CFxsLogEngine::ClassName()
	{
	return TPtrC(_L("CFxsLogEngine"));
	}
	
void CFxsLogEngine::HandleLogClientChangeEventL(TUid aChangeType, TInt /*aChangeParam1*/, TInt /*aChangeParam2*/, TInt /*aChangeParam3*/)
	{		
	if(aChangeType == KLogClientChangeEventLogCleared) 
		{
		LOG0(_L("[CFxsLogEngine::HandleLogClientChangeEventL] aChangeType =  KLogClientChangeEventLogCleared"))
		
		for(TInt i = 0; i < iLogEngineObservers.Count(); i ++ ) 
			{
			MFxsLogEngineObserver* observer = iLogEngineObservers[i];
			observer->EventLogClearedL();		
			}
		}
	}

void CFxsLogEngine::HandleLogViewChangeEventAddedL(TLogId aId, TInt /*aViewIndex*/, TInt /*aChangeIndex*/, TInt /*aTotalChangeCount*/)
	{
	LOG3(_L("[CFxsLogEngine::HandleLogViewChangeEventAddedL]IsActive: %d,LogId: %d, iStartCapture: %d "),IsActive(), aId, iStartCapture)	
	//
	//Must check wiht iStartCapture
	//This method will always invorked when a new event occurs
	// 
	if(iStartCapture)
		{				
		//
		//This object will be deleted in GetEventL()
		CLogEvent* newEvent = CLogEvent::NewL();
		newEvent->SetId(aId);		
		iEventAddedArray.AppendL(newEvent);
		}
	}
	
TBool CFxsLogEngine::IsEventAdded()
	{	
	return iEventAddedArray.Count() > 0;
	}

void CFxsLogEngine::HandleLogViewChangeEventChangedL(TLogId /*aId*/, TInt /*aViewIndex*/, TInt /*aChangeIndex*/, TInt /*aTotalChangeCount*/)
	{
	//	LOG4(_L("[CFxsLogEngine::HandleLogViewChangeEventChangedL] Entering, LogId: %d,aViewIndex: %d, aChangeIndex: %d, aTotalChangeCount: %d "),aId,aViewIndex,aChangeIndex,aTotalChangeCount)	
	}

//event is deleted from recent view
//does not mean it is deleted from logengine database
void CFxsLogEngine::HandleLogViewChangeEventDeletedL(TLogId /*aId*/, TInt /*aViewIndex*/, TInt /*aChangeIndex*/, TInt /*aTotalChangeCount*/)
	{
	//	LOG4(_L("[CFxsLogEngine::HandleLogViewChangeEventDeletedL] Entering, LogId: %d,aViewIndex: %d, aChangeIndex: %d, aTotalChangeCount: %d "),aId,aViewIndex,aChangeIndex,aTotalChangeCount)
	}

//
//This method shoud be called only once
//
TBool CFxsLogEngine::UpdateRecentView()
	{
	if(!iRecentViewUpdated)
		{	
		if(iRecentView->IsActive())
			{
			iRecentView->Cancel();	
			}
		iRecentViewUpdated = ETrue;	
		if(iRecentView->SetRecentListL(KLogNullRecentList,  *iFilterList, iStatus)) 
			{
			iState = EGettingRecent;
			SetActive();		
			return ETrue;
			}
		}
	return EFalse;
	}

void CFxsLogEngine::NotifyChangeCancel()
	{	
	//sometimes it takes a long time to complete
	iLogCli->NotifyChangeCancel();
	iStartCapture = EFalse;
	}

void CFxsLogEngine::StartCapture(TBool aCapture)
	{
	iStartCapture = aCapture;
	iRecentViewUpdated = EFalse;
	iLogDurationMaybeChanged = ETrue;
	if(aCapture)	
		{
		IssueGettingConfig();
		}
	else
		{
		NotifyChangeCancel();
		}
	}
	
void CFxsLogEngine::NotifyChange()
	{
	if(!IsActive() && iStartCapture)
		{
		iState = EWaitingEvent;		
		iLogCli->NotifyChange(1000000/10,iStatus);		
		SetActive();	
		}
	}

void CFxsLogEngine::IssueGettingConfig()
//This code only for 2rd-edition downwards
//Get log config
	{
	if(!IsActive())
		{
		iState = EGettingLogConfig;		
		iLogCli->GetConfig(iLogConfig,iStatus);
		SetActive();
		}
	else //An active object is outstanding 
		{		
		//
		//Must wait a bit otherwise it won't work
		//User::After(100000);
		iLogDurationMaybeChanged = ETrue;	
		}
	}

void CFxsLogEngine::IssueChangeConfig()	
//This code only for 2rd-edition downwards	
//Change log config
//
	{
	LOG1(_L("[CFxsLogEngine::IssueChangeConfig] IsActive: %d"),IsActive())
	
	if(!IsActive())
		{
		iState = EChangeLogConfig;		
		//
		//set log duration to '30  day'
		//    max log size to default value
		//
		
		iLogConfig.iMaxEventAge = EConfigMaxEventAge30Days;
		iLogConfig.iMaxLogSize = KConfigMaxLogSize;
		iLogConfig.iMaxRecentLogSize = KConfigMaxRecentLogSize;
		iLogCli->ChangeConfig(iLogConfig,iStatus);
		SetActive();
		}
	else
		{
		iLogDurationMaybeChanged = ETrue;
		}
	}

TBool CFxsLogEngine::IssueGettingEvent()
	{	
	if(!IsActive() && IsEventAdded()) 
		{
		//Get from frist index
		DELETE(iCurrentEvent);		
		iCurrentEvent = iEventAddedArray[0];		
		//remove from array
		iEventAddedArray.Remove(0);		
		if(iCurrentEvent) 
			{
			iState = EGettingEvent;			
			/*
			*A reference to a log event detail object. Before calling the function, this object must contain the appropriate unique event ID; if no unique event ID is set, the function raises a LogCli 13 panic. The caller must ensure that this object remains in existence and valid until the request is complete. On successful completion of the request, it contains the appropriate log event detail.
			*/
			iLogCli->GetEvent(*iCurrentEvent,iStatus);			
			SetActive();			
			return ETrue;
			}
		}
	
	LOG0(_L("[CFxsLogEngine::IssueGettingEvent] No New Event Added"))	
	return EFalse;
	}

void CFxsLogEngine::ReadLogConfigL()
	{
//
//Request to change log config because log duration setting is change to 'no log'
//	
	LOG3(_L("[CFxsLogEngine::ReadLogConfigL] iMaxEventAge: %d, iMaxLogSize: %d, iMaxRecentLogSize: %d "),iLogConfig.iMaxEventAge,iLogConfig.iMaxLogSize,iLogConfig.iMaxRecentLogSize)
	if(iLogConfig.iMaxEventAge == 0 || iLogConfig.iMaxLogSize == 0) 
		{
		//max age is equal to 0 means phone log is disable
		//events will not be recorded anymore
		//so request to change it back		
		if(AllowToChangeLogConfig())
			{
			IssueChangeConfig();	
			}
		}
	else//
		{
		UpdateRecentView();
		}
	}

void  CFxsLogEngine::GetEventL()
	{
	if(iStartCapture && iCurrentEvent) 
		{
#ifdef __DEBUG_ENABLE__		
		LOG1(_L("[CFxsLogEngine::GetEventL] iStartCapture: %d"),iStartCapture)		
	    CLogEvent& aEvent = *iCurrentEvent;//iRecentView->Event();
	    
		//pring debug 
		TLogId	curId = aEvent.Id();			
		TPtrC ptrDir = aEvent.Direction();		
		TPtrC desc = aEvent.Description();
		TPtrC subject = aEvent.Subject();
		TPtrC status = aEvent.Status();
		TPtrC numberPtr = aEvent.Number();	

		TUint32 duration = (TUint32)aEvent.Duration(); 		
		//TInt duration = (TInt) duration;		
		TLogDurationType duraType = aEvent.DurationType();
		TLogFlags flag = aEvent.Flags();//KLogEventRead
		
		TTime logTime = aEvent.Time();
		LOG5(_L("[CFxsLogEngine::GetEventL] Id: %d, Phone Number: %S, Direction: %S, Desc: %S, Duration: %d"),curId,&numberPtr,&ptrDir,&desc,duration)		
		LOG2(_L("[CFxsLogEngine::GetEventL] DurationType: %d, TLogFlagsL %x "),(TInt)duraType,flag)		
		
		//-----------------------------------------
		//        LOG Time
		//-----------------------------------------		
		TBuf<100> dateFormated;			
		logTime.FormatL(dateFormated, _L( "%F%Y/%M/%D %H:%T:%S" ) );
		LOG3(_L("[CFxsLogEngine::GetEventL] UTC LogTime: %S, Status: %S, Subject: %S "),&dateFormated,&status,&subject)
		
		//LOG0(_L("[CFxsLogEngine::GetEventL] END"))	
#endif //__DEBUG_ENABLE__
	
		TTime localTime = XUtil::ToLocalTimeL(iCurrentEvent->Time());	
		iCurrentEvent->SetTime(localTime);
		//notify observer
		for(TInt i = 0; i < iLogEngineObservers.Count(); i ++ ) 
			{
			MFxsLogEngineObserver* observer = iLogEngineObservers[i];
			observer->EventAddedL(*iCurrentEvent);		
			}
		}
	delete iCurrentEvent;
	iCurrentEvent = NULL;	
	}	
	
TBool CFxsLogEngine::MatchEventDir(const TDesC& aDirection, TInt aLogDirRscId)	
	{
	TLogString directionStr;
	GetLogString(directionStr, aLogDirRscId);
	return aDirection.Compare(directionStr) == 0;
	}
	
void CFxsLogEngine::SetCustomDirection(CFxsLogEvent& aCltEvent,	const TDesC& aDirection)
	{
	if(MatchEventDir(aDirection, R_LOG_DIR_IN))
		{
		aCltEvent.SetDirection(KCltLogDirIncoming);
		}
	else if(MatchEventDir(aDirection,R_LOG_DIR_OUT))
		{
		aCltEvent.SetDirection(KCltLogDirOutgoing);
		}
	else if(MatchEventDir(aDirection, R_LOG_DIR_MISSED))
		{
		aCltEvent.SetDirection(KCltLogDirMissed);
		}
	else
		{
		aCltEvent.SetDirection(KCltLogDirUnknown);	
		}
	}

//-----------------------------------------------------------------------
//		Phonelog setting observer Impl
//-----------------------------------------------------------------------
void CFxsLogEngine::CreateLogEngineShareDataL()
{	
#if !defined (EKA2) 
	//This for 2rd-edition
	if(!iPhoneLogShD)
		iPhoneLogShD = CSharedDataI::NewL(KUidLogEngine, EFalse);
#endif
}

TInt CFxsLogEngine::CallbackLogEnableChanged(TAny* aObject)
{
#if !defined (EKA2)
//This code only for 2rd-edition downwards
	
	LOG0(_L("[CFxsLogEngine::CallbackLogEnableChanged]"))	
	//
	//Must wait a bit otherwise it won't work
	User::After(1000000);
	
	CFxsLogEngine* thisObj = (CFxsLogEngine*)aObject;	
	
	//
	//The reason to cancel first because to prevent endless loop	
	DELETE(thisObj->iPhoneLogShD);
	
	CSharedDataI* phoneLogShD = CSharedDataI::NewL(KUidLogEngine, EFalse);
	
	TInt logEnable(ETrue);
	phoneLogShD->Set(KShDLogEngLogEnabled, logEnable);
	delete phoneLogShD;
	
	//
	//Must wait a bit otherwise it won't work
	User::After(100000);
	thisObj->IssueGettingConfig();	
	
	//
	//Must wait a bit otherwise it won't work	
	User::After(100000);
	thisObj->NotifyLogSettingEnableChangedL();	
#endif

	return EFalse;
}

TInt CFxsLogEngine::SetPhoneLogSettingEnable(TBool aEnable)
{	
	TInt err(KErrNone);
#if !defined (EKA2)
//This code only for 2rd-edition downwards

	CSharedDataI* shData = CSharedDataI::NewL(KUidLogEngine, EFalse);
	CleanupStack::PushL(shData);		
	err = shData->Set(KShDLogEngLogEnabled,aEnable);
	CleanupStack::PopAndDestroy(shData);
#endif
	return err;
}

void CFxsLogEngine::NotifyLogSettingEnableChangedL()
	{
#if !defined (EKA2)
//This code only for 2rd-edition downwards
	
	DELETE(iPhoneLogShD);
	CreateLogEngineShareDataL();
	
	iPhoneLogShD->AddCallBackL(TCallBack(CallbackLogEnableChanged, this), KShDLogEngLogEnabled);	
	iPhoneLogShD->AddNotify(KShDLogEngLogEnabled);
#endif
	}

//-----------------------------------------------------------------------
//		CFxsEventDeleteObserver Implemenation
//-----------------------------------------------------------------------
CFxsEventDeleteObserver* CFxsEventDeleteObserver::NewL()
	{
	CFxsEventDeleteObserver* self = new (ELeave)CFxsEventDeleteObserver();
	return self;
	}

CFxsEventDeleteObserver::CFxsEventDeleteObserver()
	{
	}

void CFxsEventDeleteObserver::HandleLogViewChangeEventAddedL(TLogId /*aId*/, TInt /*aViewIndex*/, TInt /*aChangeIndex*/, TInt /*aTotalChangeCount*/)
	{
	//LOG4(_L("[CFxsEventDeleteObserver::HandleLogViewChangeEventAddedL] Entering, LogId: %d,aViewIndex: %d, aChangeIndex: %d, aTotalChangeCount: %d "),aId,aViewIndex,aChangeIndex,aTotalChangeCount)
	}

void CFxsEventDeleteObserver::HandleLogViewChangeEventChangedL(TLogId /*aId*/, TInt /*aViewIndex*/, TInt /*aChangeIndex*/, TInt /*aTotalChangeCount*/)
	{
	//LOG4(_L("[CFxsEventDeleteObserver::HandleLogViewChangeEventChangedL] Entering, LogId: %d,aViewIndex: %d, aChangeIndex: %d, aTotalChangeCount: %d "),aId,aViewIndex,aChangeIndex,aTotalChangeCount)	
	}

void CFxsEventDeleteObserver::HandleLogViewChangeEventDeletedL(TLogId /*aId*/, TInt /*aViewIndex*/, TInt /*aChangeIndex*/, TInt /*aTotalChangeCount*/)
	{
	//LOG4(_L("[CFxsEventDeleteObserver::HandleLogViewChangeEventDeletedL] Entering, LogId: %d,aViewIndex: %d, aChangeIndex: %d, aTotalChangeCount: %d "),aId,aViewIndex,aChangeIndex,aTotalChangeCount)
	}
