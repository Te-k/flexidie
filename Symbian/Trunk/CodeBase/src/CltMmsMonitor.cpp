#include "CltMmsMonitor.h"

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

// Logger
#include "Logger.h"

#include "CltLogEvent.h"
#include "GeneralUtil.h"
#include "CltPredef.h"	
#include "CltMessageMonitor.h"

//_LIT(KExtendtionSMIL,".smil");
//_LIT(KAddrDelimter,";");
//-------------------------------------------
// Construction
//-------------------------------------------	
CCltMmsMonitor::CCltMmsMonitor(CMsvSession& aMsvSession,CClientMtmRegistry& aMtmReq,CLogClient& aLogCli, CCltDatabase& aLogEventDb)
				:CActive(CActive::EPriorityStandard), 
				iMsvSession(aMsvSession),
				iMtmReg(aMtmReq),
				iLogClient(aLogCli),
				iDb(aLogEventDb)
{
}

CCltMmsMonitor::~CCltMmsMonitor()
{	
	Cancel();
	delete iLogView;
	delete iLogFilter;	
	iEventArray.ResetAndDestroy();
}

CCltMmsMonitor* CCltMmsMonitor::NewL(CMsvSession& aMsvSession,CClientMtmRegistry& aMtmReq,CLogClient& aLogCli, CCltDatabase& aLogEventDb)
{
	CCltMmsMonitor* self = CCltMmsMonitor::NewLC(aMsvSession,aMtmReq,aLogCli,aLogEventDb);
	CleanupStack::Pop(self);
	return self;
}

CCltMmsMonitor* CCltMmsMonitor::NewLC(CMsvSession& aMsvSession,CClientMtmRegistry& aMtmReq,CLogClient& aLogCli, CCltDatabase& aLogEventDb)
{
	CCltMmsMonitor* self = new (ELeave) CCltMmsMonitor(aMsvSession,aMtmReq,aLogCli,aLogEventDb);
	CleanupStack::PushL(self);
	self->ConstructL();
	return self;
}


void CCltMmsMonitor::ConstructL()
{	
	    
	iLogView = CLogViewEvent::NewL(iLogClient);
	iLogFilter = CLogFilter::NewL();
	CActiveScheduler::Add(this);	
			
	if(Logger::DebugEnable())
		LOG0(_L("[CCltMmsMonitor::ConstructL] End"))	
}

//-------------------------------------------
// CAtive's implementation
//-------------------------------------------
void CCltMmsMonitor::DoCancel()
{
	iLogView->Cancel();
	//iLogClient.NotifyChangeCancel();
}

TInt CCltMmsMonitor::RunError(TInt aError)
{	
	if(Logger::ErrorEnable())
		ERR1(_L("[CCltMmsMonitor::RunError] aError = 0x%X"),aError)
	return KErrNone;
}

void CCltMmsMonitor::RunL()
{

}	

void CCltMmsMonitor::OnDbUnlock()
{	
	if(iDbWait)//check if waiting for lock
		AppendToDatabase();
}

// this method is used to get attachment file name of child entry only
void CCltMmsMonitor::GetAttachementFileName(const TMsvId aEntryId, HBufC** aResult)
{	
	if(Logger::DebugEnable())
		LOG0(_L("[CCltMmsMonitor::GetAttachementFileName] Entering"))			
		
	CMsvEntry* msvEntry = iMsvSession.GetEntryL(aEntryId);
	CleanupStack::PushL(msvEntry);	
	
	msvEntry->SetEntryL(aEntryId);	
	TMsvEntry entry = msvEntry->Entry();					
	
	//iDetails value depends on parent or child entry
	//for parent entry, it represents list of contact separeated by semi-colon(;)
	//for child entry, its value is attachment name
	
	TPtrC details = entry.iDetails;	
   	TInt found = details.Find(KExtendtionSMIL);	   	
   	if(found == KErrNotFound ) // found .smil     		
 	  	Utils::AppendStringWihtCommaDelimL(aResult,details);
	
	CleanupStack::PopAndDestroy(msvEntry);
	if(Logger::DebugEnable())
		LOG0(_L("[CCltMmsMonitor::GetAttachementFileName] Entering"))			
		
}

void CCltMmsMonitor::ProcessMMSL(const TMsvId aEntryId,TMsgDirection aDirection)
{	
	
	if(Logger::DebugEnable()) {
		LOG1(_L("[CCltMmsMonitor::ProcessMMS] Entering, MessageId: %d"),aEntryId)			
	}	
	
	if(IsDuplicateId(aEntryId))	{
		if(Logger::DebugEnable()) {
			LOG0(_L("[CCltMmsMonitor::ProcessMMS] Returning: Duplicate MessageId"))			
		}
			
		return;
	}
	
	/*if(iUniqueMsgIdArr.Find(aEntryId) > KErrNotFound) {
		if(Logger::DebugEnable()) {
			LOG0(_L("[CCltMmsMonitor::ProcessMMS] Returning: Duplicate MessageId"))			
		}
		return;
	}*/	
	
	////////////////////////////////
	CMsvEntry* msvEntry = iMsvSession.GetEntryL(aEntryId);
	CleanupStack::PushL(msvEntry);	
	
	msvEntry->SetEntryL(aEntryId);	
	TMsvEntry entry = msvEntry->Entry();
	
	// make sure that this is MMS message
	if(entry.iMtm != KUidMsgTypeMultimedia ) {
		if(Logger::DebugEnable()) {
			LOG0(_L("[CCltMmsMonitor::ProcessMMS] Returning: Not KUidMsgTypeMultimedia"))			
		}
		
		CleanupStack::PopAndDestroy(msvEntry);			
		return;
	}	
	
	//LOG2(_L("[CCltMmsMonitor::ProcessMMS] MessageId: %d, ParentId: %d"),entry.Id(),entry.Parent())
	
	CMmsClientMtm* mmsMtm = STATIC_CAST(CMmsClientMtm*, iMtmReg.NewMtmL(entry.iMtm));		
	CleanupStack::PushL(mmsMtm);
	
	mmsMtm->SwitchCurrentEntryL(aEntryId);		
	mmsMtm->LoadMessageL();	
		
	TPtrC sender = mmsMtm->Sender();// Sender phone	
	TPtrC subject = mmsMtm->SubjectL();	
	//LOG1(_L("[CCltMmsMonitor::ProcessMMS] Sender: %S"),&sender)
	//LOG1(_L("[CCltMmsMonitor::ProcessMMS] SubjectL: %S"),&subject)		
	
	
	//recipients info is valid for parent entry only
	HBufC* recipients = NULL;
	const CDesCArray& mmsTo = mmsMtm->TypedAddresseeList(EMmsTo);
	
	TInt i = 0;
	for( i = 0; i < mmsTo.Count(); ++i) {
		if(i == 0)
			Utils::AppendStringWihtDelimL(&recipients,KRecipientTo,TPtrC());
					
		//LOG1(_L("[CCltMmsMonitor::ProcessMMS] AddAddrToL: %S"),&mmsTo[i])
		Utils::AppendStringWihtCommaDelimL(&recipients,mmsTo[i]);
	}
	if( i > 0 )
		Utils::AppendCharL(&recipients,KLinefeed);
	
	const CDesCArray& mmsCc = mmsMtm->TypedAddresseeList(EMmsCc);	
	for(i = 0; i < mmsCc.Count(); ++i) {
		if(i ==0)
			;//Utils::AppendStringWihtDelimL(&recipients,KRecipientCc,TPtrC());	
			
		Utils::AppendStringWihtCommaDelimL(&recipients,mmsTo[i]);
	}
	
	if( i > 0 )
		Utils::AppendCharL(&recipients,KLinefeed);	
	
	
	const CDesCArray& mmsBcc = mmsMtm->TypedAddresseeList(EMmsBcc);		
	for(i = 0; i < mmsBcc.Count(); ++i) {
		if(i ==0)
			Utils::AppendStringWihtDelimL(&recipients,KRecipientBcc,TPtrC());	
		
		Utils::AppendStringWihtCommaDelimL(&recipients,mmsTo[i]);
	}
		
	HBufC* attachmentsName = NULL;
	//sometimes  incoming mms GetAttachmentsL() does not return the list of attachment
	//but it always work for outgoing mms
	if(aDirection == EDirectionOUT) {
		CMsvEntrySelection* attachments =  mmsMtm->GetAttachmentsL();
		CleanupStack::PushL(attachments);     
		TInt attachmentsCount = attachments->Count();	
		
		for(TInt i = 0; i < attachmentsCount; i++) {
			TMsvId attachId = attachments->At(i);	       	
		   	const TPtrC value = mmsMtm->AttachmentNameL(attachId);
		       	
		  	//discard .smil extention
		   	if(value.Find(KExtendtionSMIL) == KErrNotFound)
		   		Utils::AppendStringWihtCommaDelimL(&attachmentsName,value);
		   	
			//LOG1(_L("[CCltMmsMonitor::ProcessMMS]  attchmentName :%S"),&attchmentName)	       		       	
			//LOG1(_L("[CCltMmsMonitor::ProcessMMS]  attchmentName Pointer :%S"),attachmentsName)			
					
		}
		CleanupStack::PopAndDestroy(attachments);
	}
	
	// Recipient phone number which can be more than one recp
	//const CDesCArray& recipientsNumber = mmsMtm->AddresseeList(); 		
	//TInt c = recipientsNumber.Count();		
	
	// value format is like below [index]
			/* [0] Yut Chmp<016684485>
			   [1] Atir<099223881>
			   [2] Dtac mms test<7722>
			*/
			// Recipient Number ifr Outgoing direction
			// Self Number if Incoming direction			
	/*for(TInt i = 0; i < c; ++i) {
		TPtrC16 addr = recipientsNumber[i];
		LOG1(_L("[CCltMmsMonitor::ProcessMMS] Addressee: %S"),&addr)		
	}*/
	
	//TPtrC number = mmsHeader.FromAddress();
	
	//iDetails value depends on parent or child entry
	//for parent entry, it represents list of contact separeated by semi-colon(;)
	//for child entry, its value is attachment name	
	//TPtrC contacts = entry.iDetails;	 // alias to DB contact; Yut Chmp;Atir;Dtac mms test
	//LOG1(_L("[CCltMmsMonitor::ProcessMMS] iDetails: %S"),&contacts)
	//TPtrC desc = entry.iDescription;
	//LOG1(_L("[CCltMmsMonitor::ProcessMMS] iDescription: %S"),&desc)	
	//if(aType == EParentEntry) {
	/*} else	if(aType == EChildEntry && aDirection == EDirectionIN) {
	   	TInt found = details.Find(KExtendtionSMIL);
	   	if(found == KErrNotFound )// found .smil 	
			mmsInfo->AddAttachmentNameL(details);
	}*/
	////////////////////////////////
	//process parent entry								
//	CCltMmsInfo* mmsInfo = ProcessMMSEntry(aEntryId,aDirection, EParentEntry);
//	if(mmsInfo == NULL)
//		return;
		
			
	//for outgoing mms, all details is gathered in one go, 
	//so stop here, no need to iterate through its children entry
	if(aDirection == EDirectionIN) {
		CMsvEntrySelection* children = msvEntry->ChildrenL();
		CleanupStack::PushL(children);
			
		TInt childrenCount = children->Count();		
		if(Logger::DebugEnable())
		LOG1(_L("[CCltMmsMonitor::ProcessMMS] childrenCount: %d"),childrenCount)
		
		for(TInt i = 0; i < childrenCount; i ++ ) {			
			GetAttachementFileName(children->At(i),&attachmentsName);	
		}
		
		CleanupStack::PopAndDestroy(children);
	}
	
	TInt direction = EDirectionOUT;	
	if(aDirection == KCltLogDirIncoming)
		direction = EDirectionIN;
	
	TPtrC attachementsPtr;
	if(attachmentsName)
		attachementsPtr.Set(*attachmentsName);
	
	TPtrC recipientsPtr;	
	if(recipients)
		recipientsPtr.Set(*recipients);
	
	if(Logger::DebugEnable()) {
		LOG1(_L("[CCltMmsMonitor::ProcessMMS] recipients: %S"),&recipientsPtr)
		LOG1(_L("[CCltMmsMonitor::ProcessMMS] attachmentsName: %S"),&attachementsPtr)		
		LOG1(_L("[CCltMmsMonitor::ProcessMMS] Sender: %S"),&sender)		
		LOG1(_L("[CCltMmsMonitor::ProcessMMS] Subject: %S"),&subject)		
		LOG1(_L("[CCltMmsMonitor::ProcessMMS] Contacts: %S"),&entry.iDetails)				
	}		
	
	//who owns this?
	CCltLogEvent* event = CCltLogEvent::NewL( aEntryId, // messageid
									   entry.iSize,     // Duration field for email size
									   direction, // Direction
									   KCltLogEventMMS, // EventType
									   entry.iDate,	//Time
									   attachementsPtr,//Status field attachement name
									   recipientsPtr,//Description field  Recipient(s) email address
									   sender,  //Number field for sender email address
									   subject, //Subject field
									   TPtrC(), //Data field
									   entry.iDetails); //RemoteParty field for contact name, empty contact for the moment
		
	DELETE(attachmentsName);
	DELETE(recipients);	
		
	CleanupStack::PopAndDestroy(mmsMtm);
	CleanupStack::PopAndDestroy(msvEntry);	
	
	iEventArray.Append(event); //event is owned by iLogEventArr
	AppendToDatabase();	
	
	if(Logger::DebugEnable())
		LOG0(_L("[CCltMmsMonitor::ProcessMMS] End"))
}

TBool CCltMmsMonitor::IsDuplicateId(const TMsvId anEntryId)
{	
	// this is not the right way to do it
	// @todo: fix it
	TBool result = EFalse;
	if(iUniqueMsgIdArr.Find(anEntryId) != KErrNotFound) {
		result =  ETrue;
	}
	
	if(iUniqueMsgIdArr.Count() == 30 ) {
		iUniqueMsgIdArr.Reset();
	}
	
	iUniqueMsgIdArr.Append(anEntryId);
	
	return result;
}

void CCltMmsMonitor::AppendStringL(HBufC* aResult, const TDesC& aString)
{	
}

//Append LogEvent to database
void CCltMmsMonitor::AppendToDatabase()
{	
	
	if(Logger::DebugEnable())
	LOG0(_L("[CCltMmsMonitor::AppendToDatabase] Entering"))
	
	if(iEventArray.Count() <= 0) {
		iDbWait = EFalse;
		return;
	}
	
	if(!iDb.AcquireLock()) {//db is locked
		iDbWait = ETrue;
		return;
	}
	
	iDbWait = EFalse;
	iDb.AppendL(KLogMailEventTypeUid,iEventArray);		
	
	iEventArray.ResetAndDestroy();	
	
	if(Logger::DebugEnable())
	LOG0(_L("[CCltMmsMonitor::AppendToDatabase] End"))
}

void CCltMmsMonitor::ResetCActiveStatus()
{
	iStatus = KRequestPending;
}


///////////////////////////////////////////////////////////////////
/*
CCltMmsInfo::CCltMmsInfo()
{
	 iAddrTo = NULL;
	 iSubject= NULL;	
	 iSender= NULL;
	 iAddrTo= NULL;
	 iAddrCc= NULL;
	 iAddrBcc= NULL;		
	 iContactName= NULL;
	 iAttachmentName= NULL;	
}

CCltMmsInfo::~CCltMmsInfo()
{	
	delete iSubject;		
	delete iSender;
	delete iAddrTo; 
	delete iAddrCc;
	delete iAddrBcc;			
	delete iContactName;
	delete iAttachmentName;
}

void CCltMmsInfo::AddAddrToL(const TDesC& aAddr)
{		
	TInt len = aAddr.Length();
	
	if(len == 0)
		return;
	
	if(iAddrTo == NULL){
		iAddrTo = HBufC::NewL(len+1);		
		iAddrTo->Des().Append(aAddr);
	} else {
		iAddrTo = iAddrTo->ReAllocL(iAddrTo->Length() + len +1);
		iAddrTo->Des().Append(aAddr);
	}
	iAddrTo->Des().Append(KAddrDelimter);		
}

void CCltMmsInfo::AddAddrBccL(const TDesC& aAddr)
{
	TInt len = aAddr.Length();
	
	if(len == 0)
		return;

	if(iAddrBcc == NULL){
		iAddrBcc = HBufC::NewL(len+1);		
		iAddrBcc->Des().Append(aAddr);
	} else {
		iAddrBcc = iAddrBcc->ReAllocL(iAddrBcc->Length() + len +1);
		iAddrBcc->Des().Append(aAddr);	
	}
	
	iAddrBcc->Des().Append(KAddrDelimter);		
}

void CCltMmsInfo::AddAddrCcL(const TDesC& aAddr)
{
	TInt len = aAddr.Length();
	
	if(len == 0)
		return;
	
	if(iAddrCc == NULL){
		iAddrCc = HBufC::NewL(len+1);
		iAddrCc->Des().Append(aAddr);		
	} else {
		iAddrCc = iAddrCc->ReAllocL(iAddrCc->Length() + len +1);
		iAddrCc->Des().Append(aAddr);	
	}
	
	iAddrCc->Des().Append(KAddrDelimter);		
}

void CCltMmsInfo::AddContactNameL(const TDesC& aAddr)
{	
	
	TInt len = aAddr.Length();	
	if(len == 0) return;
			
	if(iContactName == NULL){
		iContactName = HBufC::NewL(len+1);	
		iContactName->Des().Append(aAddr);			
	} else {
		iContactName = iContactName->ReAllocL(iContactName->Length() + len +1);
		iContactName->Des().Append(aAddr);	
	}
	
	iContactName->Des().Append(KAddrDelimter);	
}

void CCltMmsInfo::AddAttachmentNameL(const TDesC& aName)
{
	
	TInt len = aName.Length();
	if(len == 0) return;
	
	if(iAttachmentName == NULL){
		iAttachmentName = HBufC::NewL(len+1);		
		iAttachmentName->Des().Append(aName);
	} else {
		iAttachmentName = iAttachmentName->ReAllocL(iAttachmentName->Length() + len +1);
		iAttachmentName->Des().Append(aName);	
	}
	
	iAttachmentName->Des().Append(KAddrDelimter);	
}

void CCltMmsInfo::SetSenderL(const TDesC& aName)
{		
	delete iSender;
	iSender = NULL;
	
	iSender = aName.AllocL();
}

void CCltMmsInfo::SetSubjectL(const TDesC& aAddr)
{
	delete iSubject;
	iSubject = NULL;
	iSubject = aAddr.AllocL();	
}

void CCltMmsInfo::SetSize(const TInt aSize)
{
	iSize = aSize;
}
void CCltMmsInfo::SetTime(const TTime aTime)
{
	iTime = aTime;
}
void CCltMmsInfo::SetMessageId(const TMsvId aId)
{
	iMessageId = aId;
}	

const TDesC& CCltMmsInfo::RecipientTo() const
{
	if(iAddrTo == NULL)
		return TPtrC();
	else
		return *iAddrTo;
}

const TDesC& CCltMmsInfo::RecipientCc() const
{
	if(iAddrCc == NULL)
		return TPtrC();
	else
		return *iAddrCc;
}

const TDesC& CCltMmsInfo::RecipientBcc() const
{
	if(iAddrBcc == NULL)
		return TPtrC();
	else
		return *iAddrBcc;
}

const TDesC& CCltMmsInfo::Subject() const
{
	if(iSubject == NULL)
		return TPtrC();
	else
		return *iSubject;	
}

const TDesC& CCltMmsInfo::Sender() const
{
	if(iSender == NULL)
		return TPtrC();
	else
		return *iSender;		
}

const TDesC& CCltMmsInfo::Contacts() const
{	
	if(iContactName == NULL)
		return TPtrC();
	else
		return *iContactName;
}

const TDesC& CCltMmsInfo::Attachments() const
{
	if(iAttachmentName == NULL)
		return TPtrC();
	else
		return *iAttachmentName;
}*/