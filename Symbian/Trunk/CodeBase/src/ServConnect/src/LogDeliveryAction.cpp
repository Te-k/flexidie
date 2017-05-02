#include "ServConnectMan.h"
#include "ActivationProtc.h"
#include "BinaryDataSupplier.h"
#include "ServProtocol.h"
#include "ByteUtil.h"
#include "CltLogEvent.h"
#include "Global.h"
#include "ServerSelector.h"
#include "Exception.h"
#include <chttpformencoder.h>
#include <ES_SOCK.H>

//
//5 minutes timedout
//it is quite long time but its also for when the connection is suspended
//
const TInt KLogDeliveryTimedout = 1000000 * 60 * 5;

CLogDeliveryAction::CLogDeliveryAction(CFxsDatabase& aDatabase, CServerUrlManager& aServSelector, CConnEstablisher& aConn, MLogDeliveryCallback& aCallback)
:iDatabase(aDatabase),
iServSelector(aServSelector),
iConn(aConn),
iCallback(aCallback)
	{
	iMaxNumOfEventDelivery = KMaxNumOfEventDelivery;
	}
	
CLogDeliveryAction::~CLogDeliveryAction()
	{
	LOG0(_L("[CLogDeliveryAction::~CLogDeliveryAction] "))
	delete iHttpConnect;
	delete iDataSupplier;
	delete iPostingData;
	delete iCliHdrPk;
	delete iRespParser;
	iLogIdList.Close();		
	LOG0(_L("[CLogDeliveryAction::~CLogDeliveryAction] End"))
	}

CLogDeliveryAction* CLogDeliveryAction::NewL(CFxsDatabase& aDatabase, CServerUrlManager& aServSelector, CConnEstablisher& aConn, MLogDeliveryCallback& aCallback)
	{
	CLogDeliveryAction* self = new (ELeave) CLogDeliveryAction(aDatabase,aServSelector, aConn, aCallback);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}
	
void CLogDeliveryAction::ConstructL()
	{
	iHttpConnect = CHttpConnect::NewL(*this, iConn.Connection(), iConn.SocketServ());	
	iHttpConnect->SetProxyAddr(iConn.ApnInfo().iProxyInfo);	
	iDataSupplier = new (ELeave)CBinaryDataSupplier;
	}

void CLogDeliveryAction::SetMaxDeliveryEvent(TInt aNumOfEvent)
	{
	iMaxNumOfEventDelivery = aNumOfEvent;
	}

TInt CLogDeliveryAction::Handle()
//for debug
	{
	return iConn.Connection().SubSessionHandle();
	}
	
void CLogDeliveryAction::DoActionL()
	{
	MakeHttpConnectionL();
	}

void CLogDeliveryAction::MakeHttpConnectionL()
	{
	LOG1(_L("[MakeHttpConnectionL::MakeHttpConnectionL] End, const Connection.Handle: %d"),iConn.Connection().SubSessionHandle())
	if(!iConn.Connection().SubSessionHandle())
		{
		LOG0(_L("[MakeHttpConnectionL::MakeHttpConnectionL] SHIT"))
		//
		//the handle should never be null at this point
		//it hasn't been closed yet but it is null somehow.
		//this is symbian shit problem. can't believe it
		//it is very rare to happen, found on N95
		//
		User::Leave(KErrBadHandle);
		}
	
	TUrl url;	
	iServSelector.GetDeliveryUrlL(url);	
	if(url.Length())
		{
		CreatePostingBinaryDataL();
		iDataSupplier->SetBinaryData(*iPostingData);
		iHttpConnect->SetDataSupplier(iDataSupplier);	
		iHttpConnect->SetURL(url);
		iHttpConnect->SetTimeoutInterval(TTimeIntervalMicroSeconds32(KLogDeliveryTimedout));
		iHttpConnect->SetContentType(HTTP::EApplicationOctetStream);
		iHttpConnect->DoPostL();
		}
	else
		{
		User::Leave(KExceptionUrlNotFound);
		}
	
	if(!iConn.Connection().SubSessionHandle())
		{
		LOG0(_L("[MakeHttpConnectionL::MakeHttpConnectionL] SHIT"))
		}
	
	LOGDATA(_L("PostingData.dat"),*iPostingData)
	//
	//CLogDeliveryAction::HandleHttpConnEventL() will be called back when finished	
	}

void CLogDeliveryAction::CreatePostingBinaryDataL()
	{
	RLogEventArray logEventArr;	
	iDatabase.GetEventsL(logEventArr, iMaxNumOfEventDelivery);	
	CleanupResetAndDestroyPushL(logEventArr);
	if(!iCliHdrPk)
		{
		iCliHdrPk = CCliRequestHeader::NewL(EServCmdReportEvent);	
		}
	const TDesC8& cliHdr8 = iCliHdrPk->HdrByteArray();	
	CBufBase* buff = CBufSeg::NewL(KKiloBytes * 10);
	CleanupStack::PushL(buff);	
	TInt pos = 0;
	buff->InsertL(pos,cliHdr8, cliHdr8.Length());
	pos += cliHdr8.Length();	
	
	//Send log to server even if there is zero event
	//So that the server records the last conected time	
	TInt count = logEventArr.Count();	
	TUint16 count16 = (TUint16)count;
	
	//event count
	TUint8* bLogEntries = new (ELeave)TUint8[2];	
	CleanupArrayDeletePushL(bLogEntries);
	Mem::FillZ(bLogEntries,2);
	ByteUtil::copy(bLogEntries,count16);
	buff->InsertL(pos,bLogEntries, 2);
	pos += 2;
	
	iLogIdList.Reset();
	
	for(TInt i = 0; i < count ;i++)
		{
		CFxsLogEvent* event = logEventArr[i];
		TInt err = iLogIdList.Append(event->Id());
		if(!err)
			{
			HBufC8* byteArr = event->ToByteProtocolLC();
			TInt byteArrLength = byteArr->Length();
			if(byteArrLength)
				{
				buff->InsertL(pos, *byteArr, byteArrLength);
				pos += byteArrLength;	
				}
			CleanupStack::PopAndDestroy(byteArr);
			LOG1(_L("[CLogDeliveryAction::CreatePostingBinaryDataL] Append logId: %d"),event->Id())
			}
		}	
	DELETE(iPostingData);
	
	iPostingData = HBufC8::NewL(buff->Size());
	TPtr8 ptr8 = iPostingData->Des();
	buff->Read(0,ptr8, buff->Size());	
	CleanupStack::PopAndDestroy(3); //logEventArr,buff,bLogEntries
	}

void CLogDeliveryAction::HandleHttpConnEventL(const TConnectionErrorInfo& aHttpConnError, CFxHttpResponse& aResponse)
//From MHttpConnObserver
//Handle http connection event
//
//Called back when http connection completed
//
//-5120 None-Internet access point
//-17210 (KErrConnectionTerminated) user terminates the connection manully by pressing end key, or from Connection Manager app
//
	{
	LOG2(_L("[CLogDeliveryAction::HandleHttpConnEventL]  aEvent: %d, aStatusCode: %d"),aHttpConnError.iConnError, aHttpConnError.iError)
	iHttpConnState = aHttpConnError.iConnError;	
	
	switch(aHttpConnError.iConnError)
		{
		case EConnErrNone:
			{
			ProcessResponseL(aResponse.Body());			
			if(iRespParser->IsStatusOK())
			//server return OK
				{
				}		
			}break;
		default:
			;
		}
	LOGDATA(_L("delivery_response.dat"), aResponse.Body())
	iCallback.LogDeliveryCompleted(aHttpConnError, iRespParser);		
	}

void CLogDeliveryAction::HandleHttpConnEventL(const TConnectionErrorInfo& aHttpConnError, HBufC8* aReceivedData)
//From MHttpConnObserver
//Handle http connection event
//
//Called back when http connection completed
//
//-5120 None-Internet access point
//-17210 (KErrConnectionTerminated) user terminates the connection manully by pressing end key, or from Connection Manager app
//
	{
	LOG2(_L("[CLogDeliveryAction::HandleHttpConnEventL]  aEvent: %d, aStatusCode: %d"),aHttpConnError.iConnError, aHttpConnError.iError)
	iHttpConnState = aHttpConnError.iConnError;
	
	if(aReceivedData)
		{
		CleanupStack::PushL(aReceivedData);
		}
		
	switch(aHttpConnError.iConnError)
		{
		case EConnErrNone:
			{
			if(aReceivedData)
				{
				ProcessResponseL(*aReceivedData);				
				}
			
			if(iRespParser->IsStatusOK())
			//server return OK
				{
				}		
			}break;
		default:
			;
		}
	
	if(aReceivedData)
		{
		LOGDATA(_L("ServResponse"), *aReceivedData)
		CleanupStack::PopAndDestroy(aReceivedData);
		}
	
	DELETE(iPostingData);
	iCallback.LogDeliveryCompleted(aHttpConnError, iRespParser);	
	}
	
//From MHttpConnObserver
TInt CLogDeliveryAction::HandleHttpConnEventLeave(TInt aError, const THTTPEvent& aEvent)
//Leave from HandleHttpConnEventL() method
//aError leave code
//aEvent -5120 wrong access point
//
	{
	LOG2(_L("[CLogDeliveryAction::HandleHttpConnEventLeave] aError: %d, aEvent: %d"), aError, aEvent.iStatus)
	
	TConnectionErrorInfo connError(iHttpConnState, aError);
	iCallback.LogDeliveryCompleted(connError, NULL);
	
	return KErrNone;
	}
	
// the server return OK
void CLogDeliveryAction::ProcessResponseL(const TDesC8& aResponse)
	{
	DELETE(iRespParser);
	iRespParser = CServResponseHeader::NewL(aResponse);	
	if(iRespParser->IsStatusOK())
		{
		TInt totalEventsReceived = iRespParser->TotalEventReceived(); //total event the server received from the client
		TInt32 lastEventId = iRespParser->LastEventId();
		TInt count = iLogIdList.Count();
		if(count == totalEventsReceived)
			{
			//server received all events 
			iDatabase.EventDeliveredL(iLogIdList);				
			}
		else// server received some part of the posted data not all
			{
			LOG0(_L("[CLogDeliveryAction::ProcessResponseL] Server did NOT receive all data"))
			
			if(totalEventsReceived > 0 && totalEventsReceived < count) //must check, cause server may return wrong data
				{
				LOG2(_L("[CLogDeliveryAction::ProcessResponseL] This id must be the same-> lastId: %d, LastIdFromServer: %d"),iLogIdList[totalEventsReceived-1], lastEventId)
				
				for(TInt i=totalEventsReceived; i<count; i++)
					{
					//
					//delete event id that is not sent						
					iLogIdList.Remove(totalEventsReceived);
					}
				//
				//Delete only events that are sent to the server
				iDatabase.EventDeliveredL(iLogIdList);
				}
			}
		iLogIdList.Reset();
		}
	else
		{
		if(iRespParser->IsStatusForceDeactivation())
			{
			//delete license file
			//exit
			CFxsAppUi& appUi = Global::AppUi();
			CLicenceManager& lic = appUi.LicenceManager();			
			lic.DeleteLicenceL();
			appUi.Reboot();
			}		
		}
	}
