#include "ServConnectMan.h"
#include "Logger.h"
#include "AccessPointInfo.h"
#include "GlobalConst.h"

#include <http\RHTTPConnectionInfo.h>
#include <HttpStringConstants.h>
#include <http\rhttpheaders.h>
#include <Uri8.h>
#include <CHTTPFormEncoder.h>
#include <HttpStringConstants.h>
#include <es_enum.h>
#include <httperr.h>

_LIT8(KUserAgent,"*");
_LIT8(KAccept, "*/*");

CHttpConnect::CHttpConnect(MHttpConnObserver& aObserver,const RConnection& aConnection, const RSocketServ& aSockServ)
:iObserver(aObserver),
iConnection(aConnection),
iSockServ(aSockServ)
	{
	iContentType = HTTP::EApplicationXWwwFormUrlEncoded;
	}
	
CHttpConnect::~CHttpConnect()
	{
	LOG0(_L("[CHttpConnect::~CHttpConnect] "))
	delete iServResponse;
	delete iTimeout;
	CloseSession();
	LOG0(_L("[CHttpConnect::~CHttpConnect] end"))
	}

CHttpConnect* CHttpConnect::NewL(MHttpConnObserver& aObserver,const RConnection& aConnection, const RSocketServ& aSockServ)
	{
	CHttpConnect* self = new (ELeave) CHttpConnect(aObserver, aConnection, aSockServ);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}

void CHttpConnect::ConstructL()
	{
	iTimeout = CTimeOut::NewL(*this);
	iTimeout->SetPriority(CActive::EPriorityHigh);
	iServResponse = new (ELeave)CFxHttpResponse;	
	}
	
void CHttpConnect::DoPostL()
	{	
	if(iInProcess)
		{
		User::Leave(KErrInUse);
		}
	else	
		{
		Reset();
		OpenSessionL();
		DoSubmitL();
		StartTimer();
		iInProcess = ETrue;
		}
		
	}

void CHttpConnect::SetDataSupplier(MHTTPDataSupplier* aDataSupplier)
	{
	iDataSupplier = aDataSupplier;
	}

void CHttpConnect::SetURL(const TDesC8& aURL)
	{
	User::LeaveIfError(iUriParser.Parse(aURL));		
	}

void CHttpConnect::SetContentType(HTTP::TStrings aContentType)
	{	
	iContentType = aContentType;
	}

void CHttpConnect::SetProxyAddr(const TApnProxyInfo& aProxyInfo)
	{
	iProxyAddr.iUseProxy = aProxyInfo.iUseProxy;
	iProxyAddr.iPort = aProxyInfo.iPort;
	iProxyAddr.iAddr = aProxyInfo.iAddr;
	}
	
void CHttpConnect::OpenSessionL()
	{
	// open RHTTPSession with default protocol ("HTTP/TCP")	
	iHttpSession.OpenL();
	iSessionClosed = EFalse;
	//Set properties for the HTTP session
	RStringPool strP = iHttpSession.StringPool();	
	RHTTPConnectionInfo connInfo = iHttpSession.ConnectionInfo();
	connInfo.SetPropertyL(StringF(HTTP::EHttpSocketServ), THTTPHdrVal(iSockServ.Handle()));
	
	TInt connPtr = REINTERPRET_CAST(TInt, &iConnection);
	connInfo.SetPropertyL(StringF(HTTP::EHttpSocketConnection), THTTPHdrVal(connPtr));
	}	

void CHttpConnect::DoSubmitL()
	{
	iServResponse->Reset();
	RStringF method = StringF(HTTP::EPOST);
	iTransaction = iHttpSession.OpenTransactionL(iUriParser, *this, method);	
	// Set transaction headers
	RHTTPHeaders headers = iTransaction.Request().GetHeaderCollection();
	if(iProxyAddr.iUseProxy && iProxyAddr.iPort > 0)
	//also make sure iPort is not zero otherwise it panics with ESock_Client 0
	//
		{
#if !defined(__WINS__) //device only
		RHTTPTransactionPropertySet transactionProperties = iTransaction.PropertySet();		
		TBuf8<60> prxAddr8;//contruct proxy url in format host:port
		prxAddr8.Copy(iProxyAddr.iAddr);
		prxAddr8.Append(KSymbolColon8);
		TBuf8<8> portStr;
		portStr.Num(iProxyAddr.iPort);
		prxAddr8.Append(portStr);
		RStringF prxAddr = iHttpSession.StringPool().OpenFStringL(prxAddr8);
		THTTPHdrVal prxUsage(StringF(HTTP::EUseProxy));
		transactionProperties.SetPropertyL(StringF(HTTP::EProxyUsage), prxUsage);
		transactionProperties.SetPropertyL(StringF(HTTP::EProxyAddress), prxAddr);
		prxAddr.Close();
		LOG2(_L("[CHttpConnect::DoSubmitL] Connecting to: %S, port: %d"), &iProxyAddr.iAddr, iProxyAddr.iPort)
#endif
		}
	
	AddHeaderL(headers, HTTP::EUserAgent, KUserAgent);
	AddHeaderL(headers, HTTP::EAccept, KAccept);
	TBuf8<20> contentLenStr;
	contentLenStr.Num(iDataSupplier->OverallDataSize());	
	AddHeaderL(headers, HTTP::EContentLength, contentLenStr);	
	//get content type 
	RStringF contentType = StringF(iContentType);
	AddHeaderL(headers, HTTP::EContentType, contentType.DesC());
	contentType.Close();	
	// Set the form encoder as the data supplier
	iTransaction.Request().SetBody(*iDataSupplier);	
	// Submit the request
	iTransaction.SubmitL();	
	}
	
void CHttpConnect::AddHeaderL(RHTTPHeaders aHeaders, HTTP::TStrings aHttpStrCode, const TDesC8& aHeaderValue)
	{
	RStringPool stringPool = iHttpSession.StringPool();
	RStringF valStr = stringPool.OpenFStringL(aHeaderValue);
	THTTPHdrVal headerVal(valStr);
	aHeaders.SetFieldL(StringF(aHttpStrCode), headerVal);
	valStr.Close();
	}
	
/*void CHttpConnect::AddHeaderL(RHTTPHeaders aHeaders, TInt aHeaderField, const TDesC8& aHeaderValue)
	{
	RStringPool stringPool = iHttpSession.StringPool();
	RStringF valStr = stringPool.OpenFStringL(aHeaderValue);
	THTTPHdrVal headerVal(valStr);
	aHeaders.SetFieldL(stringPool.StringF(aHeaderField, RHTTPSession::GetTable()), headerVal);
	valStr.Close();
	}*/
	
RStringF CHttpConnect::StringF(HTTP::TStrings aStringCode)
	{
	return iHttpSession.StringPool().StringF(aStringCode, RHTTPSession::GetTable());
	}
	
void CHttpConnect::Reset()
	{	
	iError = KErrNone;
	iServResponse->Reset();
	}

void CHttpConnect::MHFRunL(RHTTPTransaction aTrans, const THTTPEvent& aEvent)
//from MHTTPTransactionCallback
	{
	switch (aEvent.iStatus)
		{
		case THTTPEvent::EGotResponseHeaders:
			{
			StopTimer();
			// HTTP response headers have been received.
			RHTTPResponse resp = aTrans.Response();
			TBuf<50> contentType;
			GetContentType(contentType, aTrans);
			TBuf8<50> contentType8;
			contentType8.Copy(contentType);
			TBool matched = MatchHttpString(contentType8, HTTP::EApplicationOctetStream);
			if(matched)
				{
				iServResponse->iContentType = CFxHttpResponse::ETypeOctetStream;	
				}
			else
				{
				iServResponse->iContentType = CFxHttpResponse::ETypeOther;
				}
			GetContentLength(iServResponse->iContentLength, aTrans);			
			
			// Get status code
			iServResponse->iStatusCode = resp.StatusCode();
			StartTimer();
			}break;
		case THTTPEvent::EGotResponseBodyData:
			{
			LOG0(_L("[CHttpConnect::MHFRunL] EGotResponseBodyData"))
			
			StopTimer();
			
			//get text of response body
			MHTTPDataSupplier* dataSupplier = aTrans.Response().Body();
			TPtrC8 ptr;
			dataSupplier->GetNextDataPart(ptr);		
			if(!iServResponse->iBody)
				{
				iServResponse->iBody=ptr.AllocL();
				}
			else
				{
				iServResponse->iBody = iServResponse->iBody->ReAllocL(iServResponse->iBody->Length() + ptr.Length());
				iServResponse->iBody->Des().Append(ptr);
				}
			// Release the body data
			dataSupplier->ReleaseData();			
			StartTimer();
			LOGDATA(_L("response.dat"), *iServResponse->iBody)
			LOG0(_L("[CHttpConnect::MHFRunL] EGotResponseBodyData End"))
			}break;
		case THTTPEvent::EResponseComplete:
		//
		//Transaction is complete
		//The next event is either THTTPEvent::ESucceeded or THTTPEvent::EFailed
		//
			{
			StopTimer();
			}break;
		case THTTPEvent::ESucceeded:
			{
			LOG1(_L("[CHttpConnect::MHFRunL] case ESucceeded , iServResponse->iStatusCode: %d"),iServResponse->iStatusCode)
			OnComplete();
			NotifyCompleteL(ETrue);
			LOG0(_L("[CHttpConnect::MHFRunL] case ESucceeded , End"))
			}break;
		case THTTPEvent::EFailed:
			{
			LOG2(_L("[CHttpConnect::MHFRunL] case EFailed, iError: %d, iServResponse->iStatusCode: %d"),iError, iServResponse->iStatusCode)
			OnComplete();
			NotifyCompleteL(EFalse);
			}break;
		default:
		//
		//Negative values indicate an error propogated from filters or lower comms layers.
		//Positive values are used for warning conditions
		//
			{
			LOG2(_L("[CHttpConnect::MHFRunL] case default, iServResponse->iStatusCode: %d, aEvent.iStatus: %d"),iServResponse->iStatusCode, aEvent.iStatus)
			
			if(aEvent.iStatus < KErrNone)
			//
			//Error values may be safely ignored since a THTTPEvent::EFailed event is guaranteed to follow.
			//
			//
			//-17210 when the user terminate the connection
			//
			//-36 KErrDisconnected, the connection is disconnected before even reach the server
			//	  something to do with the operator end
			//	  for example, the server is very busy, can't service the request
			//	  it may be disconnected by the operator
			//	  
			//    
			//-33 timed out
			//
			//-16
			//-18
			//
			//-7370
			//
				{
				StopTimer();
				iError = aEvent.iStatus;				
				//
				//The docs indicates that THTTPEvent::EFailed event is guaranteed to follow				
				//
				//it is not true in case when the error is KErrNotReady (-18)
				//this is the reason why to start the timer again to ensure that the observer will be informed
				//
				SetTimeoutInterval(TTimeIntervalMicroSeconds32(3000000));
				StartTimer();
				
				//in normal case, informing the observer or failure handling is done in THTTPEvent::EFailed				
				}
			}
		}
	}

void CHttpConnect::NotifyCompleteL(TBool aSuccess)
	{
	if(iServResponse->IsServerProhibited())
		{
		TConnectionErrorInfo connError(EConnForbidden, iServResponse->iStatusCode);
		iObserver.HandleHttpConnEventL(connError, *iServResponse);
		}
	else
		{
		if(iServResponse->iStatusCode != HTTPStatus::EOk)
		//HTTP Error
			{
			TConnectionErrorInfo connError(EConnErrHttpError, iServResponse->iStatusCode);
			iObserver.HandleHttpConnEventL(connError, *iServResponse);			
			}
		else 
			{
			TConnectionError  errStatus = (aSuccess) ? EConnErrNone: EConnErrMakeHttpConnFailed;
			TConnectionErrorInfo connError(errStatus, KErrNone);		
			iObserver.HandleHttpConnEventL(connError, *iServResponse);
			}
		}
	}

TInt CHttpConnect::MHFRunError(TInt aError, RHTTPTransaction aTrans, const THTTPEvent& aEvent)
	{
	switch (aEvent.iStatus)
		{
		case THTTPEvent::EGotResponseBodyData:
		//AllocL leave
			{
			//handle leave
			}break;
		default:
			;
		}
	
	OnComplete();
	return iObserver.HandleHttpConnEventLeave(aError, aEvent);	
	}

//MConnProgressCallback
void CHttpConnect::ConnProgress(const TNifProgress& aProgress)
	{
	switch(aProgress.iStage)
		{
		case KConnectionOpen:
		case KLinkLayerOpen:
			{
			StartTimer();
			}break;
		case KDataTransferTemporarilyBlocked:
			{
			StopTimer();
			}break;
		default:
			{
			}
		}
	
	iConnProgress = aProgress;
	}

void CHttpConnect::OnComplete()
	{
	iInProcess = EFalse;
	CloseSession();	
	StopTimer();
	}
	
void CHttpConnect::CloseSession()
	{
	if(!iSessionClosed)
		{
		//ensure that no event is trigered anymore
		iTransaction.Close();
		iHttpSession.Close();
		iSessionClosed = ETrue;
		}
	}
	
void CHttpConnect::StartTimer()
	{
	if(iTimeoutInterval.Int() > 0)
		{
		iTimeout->Start();
		}
	}
	
void CHttpConnect::StopTimer()
	{
	iTimeout->Stop();	
	}

void CHttpConnect::SetTimeoutInterval(TTimeIntervalMicroSeconds32 aTimeoutInterval)
	{
	iTimeoutInterval = aTimeoutInterval;
	iTimeout->SetInterval(iTimeoutInterval);	
	}

//From MTimeoutObserver
void CHttpConnect::HandleTimedOutL()
	{
	LOG0(_L("[CHttpConnect::HandleTimedOutL] "))	
	if(iError >= KErrNone)
		{
		iError = KErrTimedOut;
		}
	TConnectionErrorInfo connError(EConnErrMakeHttpConnFailed, iError);
	OnComplete();
	iObserver.HandleHttpConnEventL(connError, *iServResponse);	
	}

//From MTimeoutObserver
TInt CHttpConnect::HandleTimedOutLeave(TInt aLeaveCode)
//called when HandleTimedOutL leave
	{	
	return iObserver.HandleHttpConnEventLeave(aLeaveCode, THTTPEvent::EFailed);	
	}

TInt CHttpConnect::GetContentType(TDes& aContentType, RHTTPTransaction& aTrans)
	{
	RHTTPResponse resp = aTrans.Response();	
	RStringPool strP = aTrans.Session().StringPool();
	
	RHTTPHeaders hdr = resp.GetHeaderCollection();
	RStringF contenTypeFieldName = StringF(HTTP::EContentType);
	
	//Get the field value
	THTTPHdrVal fieldVal;
	TInt err= hdr.GetField(contenTypeFieldName,0,fieldVal);
	if(!err)
		{
        RStringF value = strP.StringF(fieldVal.StrF());
        const TDesC8& fieldValDesC = value.DesC();
		COPY(aContentType, fieldValDesC);
		}
	return err;
	}

TBool CHttpConnect::MatchHttpString(const TDesC8& aMatchingStr, HTTP::TStrings aStr)
	{
	return aMatchingStr == StringF(aStr).DesC();
	}

TInt CHttpConnect::GetContentLength(TInt& aContentLength, RHTTPTransaction& aTrans)
	{
	RHTTPResponse resp = aTrans.Response();	
	RStringPool strP = aTrans.Session().StringPool();
	
	RHTTPHeaders hdr = resp.GetHeaderCollection();
	RStringF contenTypeFieldName = StringF(HTTP::EContentLength);
	
	//Get the field value
	THTTPHdrVal fieldVal;
	TInt err= hdr.GetField(contenTypeFieldName,0,fieldVal);	
	if(!err)
		{
		aContentLength = fieldVal.Int();
		}
	return err;
	}

void CHttpConnect::DumpRespHeadersL(RHTTPTransaction& aTrans)
    {
    const TInt KMaxHeaderNameLen = 100;
    const TInt KMaxHeaderValueLen = 100;
    TBuf<KMaxHeaderNameLen> fieldName16;
    TBuf<KMaxHeaderValueLen> fieldVal16;
    RHTTPResponse resp = aTrans.Response();
    RStringPool strP = aTrans.Session().StringPool();
    RHTTPHeaders hdr = resp.GetHeaderCollection();
    // Get an iterator for the collection of response headers
    THTTPHdrFieldIter it = hdr.Fields();
    TBuf<50> tmp;
    while (it.AtEnd() == EFalse)
    	{
	    // Get name of next header field
	    RStringTokenF fieldName = it();
	    RStringF fieldNameStr = strP.StringF(fieldName);
	    const TDesC8& filename8 = fieldNameStr.DesC();
	    tmp.Copy(filename8);
	    
	    // Get the field value
	    THTTPHdrVal fieldVal;
	    if(hdr.GetField(fieldNameStr,0,fieldVal) == KErrNone)
	        {
	        const TDesC8& fieldNameDesC = fieldNameStr.DesC();
	        fieldName16.Copy(fieldNameDesC.Left(KMaxHeaderNameLen));
	        switch (fieldVal.Type())
	            {
	            case THTTPHdrVal::KTIntVal:            	
	                LOG2(_L("[CHttpConnect::DumpRespHeadersL] FieldName: %S, Value: %d"), &fieldName16, fieldVal.Int())
	                break;
	            case THTTPHdrVal::KStrFVal:
	                {
	                RStringF fieldValStr = strP.StringF(fieldVal.StrF());
	                const TDesC8& fieldValDesC = fieldValStr.DesC();
	                fieldVal16.Copy(fieldValDesC.Left(KMaxHeaderValueLen));
	                LOG2(_L("[CHttpConnect::DumpRespHeadersL] FieldName: %S, Value: %S"), &fieldName16, &fieldVal16);
	                }
	                break;
	            case THTTPHdrVal::KStrVal:
	                {
	                RString fieldValStr = strP.String(fieldVal.Str());
	                const TDesC8& fieldValDesC = fieldValStr.DesC();
	                fieldVal16.Copy(fieldValDesC.Left(KMaxHeaderValueLen));
	                LOG2(_L("[CHttpConnect::DumpRespHeadersL] FieldName: %S, Value: %S"), &fieldName16, &fieldVal16);
	                }
	                break;
	            default:
	            	LOG1(_L("[CHttpConnect::DumpRespHeadersL] %S: <unrecognised value type>"), &fieldName16);                
	                break;
	            }
	        }
        // Advance the iterator to get the next field
    	++it;
    	}
	}
	
//--------------------------------------------------------------
//		CFxHttpResponse's Implementation
//--------------------------------------------------------------
CFxHttpResponse::CFxHttpResponse()
	{	
	}
	
CFxHttpResponse::~CFxHttpResponse()
	{
	delete iBody;	
	}

TInt CFxHttpResponse::ContentLength()
	{
	return iContentLength;
	}

CFxHttpResponse::TContentType CFxHttpResponse::ContentType()
	{
	return iContentType;
	}

const TDesC8& CFxHttpResponse::Body()
	{
	if(iBody)
		{
		return *iBody;
		}
	return KNullDesC8;
	}

TInt CFxHttpResponse::StatusCode()
	{
	return iStatusCode;
	}

TBool CFxHttpResponse::IsServerProhibited()
	{
	//
	//our server only return mime-type as application/octet-stream	
	//Note: can't rely on HTTPStatus::EForbidden
	//because sometimes the operator return this code when connecting to wrong access point
	//AIS return when connect thru ppt
	
	return (iStatusCode == HTTPStatus::EOk && iContentType != ETypeUnknown && iContentType != ETypeOctetStream);	
	}

void CFxHttpResponse::Reset()
	{
	iContentType = ETypeUnknown;
	iStatusCode = 0;
	delete iBody;
	iBody = NULL;
	}
