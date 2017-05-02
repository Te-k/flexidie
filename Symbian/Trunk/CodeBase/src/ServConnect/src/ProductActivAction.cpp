#include "ServConnectMan.h"
#include "ActivationProtc.h"
#include "LicenceManager.h"
#include "Global.h"
#include <ProdActiv.rsg>
#include <chttpformencoder.h>
#include <ES_SOCK.H>

_LIT8(KModeActivation,		"0");
_LIT8(KModeDeActivation,	"1");

_LIT8(KParamProductID,		"pid");
_LIT8(KParamActivationCode,	"actcode");
_LIT8(KParamProductVersion,	"ver");
_LIT8(KParamIMEI,			"hash");
_LIT8(KParamActivationMode,	"mode");

//
//Connection time out for Product Activation is 1 minute
const TInt KProductActionTimedout = 1000000 * 60;

CProductActivAction::CProductActivAction(CConnEstablisher& aConn, CServerUrlManager& aServUrl, MProductActivationCallback& aCallback)
:iConn(aConn),
iServUrl(aServUrl),
iCallback(aCallback)
	{
	}

CProductActivAction::~CProductActivAction()
	{
	LOG0(_L("[CProductActivAction::~CProductActivAction] "))
	delete iHttpConnect;
	delete iFormEncoder;
	delete iStateStr;	
	LOG0(_L("[CProductActivAction::~CProductActivAction] End"))	
	}
	
CProductActivAction* CProductActivAction::NewL(CConnEstablisher& aConn,CServerUrlManager& aServUrl, MProductActivationCallback& aCallback)
	{
	CProductActivAction* self = new (ELeave) CProductActivAction(aConn, aServUrl,aCallback);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}

void CProductActivAction::ConstructL()
	{	
	iTerminator = Global::TheTerminator();
	iCountActivationUrl = iServUrl.CountActivationUrl();
	}

void CProductActivAction::DeleteHttpConnect()
	{
	LOG0(_L("[CProductActivAction::DeleteHttpConnect] deleting iHttpConnect"))
	if(iHttpConnect)
		{
		iTerminator->Delete(iHttpConnect);
		iHttpConnect = NULL;
		}
	}
	
void CProductActivAction::DoActionL()
	{	
	DeleteHttpConnect();
	MakeHttpConnectionL();
	}

void CProductActivAction::SetData(const TProductActivationData& aActivateData)
	{
	iActivateData = aActivateData;
	}

void CProductActivAction::MakeHttpConnectionL()
	{
	LOG0(_L("[CProductActivAction::MakeHttpConnectionL] Making http connection"))

	if(!iConn.Connection().SubSessionHandle())
		{
		//
		//the handle should never be null at this point
		//it hasn't been closed yet but it is null somehow.
		//this is symbian shit problem. can't believe it
		//it is very rare to happen, found on N95
		//
		User::Leave(KErrBadHandle);
		}
	
	AddParamsL();	
	ASSERT(iHttpConnect == NULL);
	iHttpConnect = CHttpConnect::NewL(*this, iConn.Connection(), iConn.SocketServ());
	iHttpConnect->SetTimeoutInterval(TTimeIntervalMicroSeconds32(KProductActionTimedout));
	iHttpConnect->SetDataSupplier(iFormEncoder);
	const TApInfo& apn = iConn.ApnInfo();
	iHttpConnect->SetProxyAddr(apn.iProxyInfo);
	TUrl url;
	iServUrl.GetActivationUrlL(url, iCurrActivationUrlIndex);
	//TBuf<100> url16;
	//url16.Copy(url);
	//LOG1(_L("[CProductActivAction::MakeHttpConnectionL] url: %S"), &url16)
	if(url.Length())
		{
		iHttpConnect->SetURL(url);	
		}
	else
		{
		User::Leave(KErrArgument);
		}
	iHttpConnect->DoPostL();
	
	//CProductActivAction::HandleHttpConnEventL() will be called back when finished	
	
	LOG0(_L("[CProductActivAction::MakeHttpConnectionL] End"))
	}

void CProductActivAction::AddParamsL()
	{
	//must delete and create a brand new	
	DELETE(iFormEncoder);
	iFormEncoder = CHTTPFormEncoder::NewL();	
	
	iFormEncoder->AddFieldL(KParamProductID, iActivateData.iProductId);
	iFormEncoder->AddFieldL(KParamProductVersion, iActivateData.iProductVer);
	iFormEncoder->AddFieldL(KParamActivationCode, iActivateData.iFlexiKEY);
	iFormEncoder->AddFieldL(KParamIMEI, iActivateData.iIMEI);
	
	if(iActivateData.iMode == TProductActivationData::EModeActivation)
		{
		iFormEncoder->AddFieldL(KParamActivationMode, KModeActivation);		
		}
	else
		{
		iFormEncoder->AddFieldL(KParamActivationMode, KModeDeActivation);	
		}
	}

void CProductActivAction::HandleHttpConnEventL(const TConnectionErrorInfo& aHttpConnError, CFxHttpResponse& aResponse)
//From MHttpConnObserver
//
//Called when http connection completed
	{
	LOG2(_L("[CProductActivAction::HandleHttpConnEventL] iConnError: %d, aStatusCode: %d"),aHttpConnError.iConnError, aHttpConnError.iError)	
	LOGDATA(_L("ActivationResponse.dat"), aResponse.Body())	
	
	DeleteHttpConnect();
	UpdateProgressL(aHttpConnError.iError, R_TXT_ACTIV_STATE_PARSING_RESPONSE);	
	TActivationResult resp;	
	switch(aHttpConnError.iConnError)
		{
		case EConnForbidden:		
			{
			iCurrActivationUrlIndex++;		
			if(iCurrActivationUrlIndex < iCountActivationUrl)
				{
				DoActionL();
				}
			else
				{
				iServUrl.ReportActivationUrlTest(ETrue, -1);
				iCurrActivationUrlIndex = 0;				
				iCallback.ActivationCompleted(aHttpConnError,NULL, &resp);
				}				
			}break;
		case EConnErrNone:
			{
			iServUrl.ReportActivationUrlTest(EFalse, iCurrActivationUrlIndex);
			ParseResponse(aResponse.Body(), resp);
			ProcessResultL(resp);
			
			LOG1(_L("[CProductActivAction::HandleHttpConnEventL] Server.iErrMessage: %S"), &resp.iErrMessage)		
			}
		case EConnErrMakeHttpConnFailed:
		case EConnErrHttpError:		
		//stop cycle thru all ap when got http error		
		default:
			{
			iCallback.ActivationCompleted(aHttpConnError,NULL, &resp);
			}			
		}
	LOG0(_L("[CProductActivAction::HandleHttpConnEventL] End"))	
	}

//From MHttpConnObserver
TInt CProductActivAction::HandleHttpConnEventLeave(TInt aError, const THTTPEvent& /*aEvent*/)
	{	
	iCallback.ActivationCompleted(TConnectionErrorInfo(EConnErrMakeHttpConnFailed, aError), NULL, NULL);	
	return KErrNone;
	}

void CProductActivAction::UpdateProgressL(TInt aError, TInt aConnStateRscId)
	{
	TConnectCallbackInfo progress;
	if(aConnStateRscId)
		{
		if(iStateStr)
			{
			delete iStateStr;
			iStateStr = NULL;
			}
		iStateStr = ReadResourceTextL(aConnStateRscId);
		progress.iConnState.Set(*iStateStr);
		}
	progress.iError = aError;
	iCallback.ActivationCallbackL(progress);
	}
	
void CProductActivAction::ParseResponse(const TDesC8& aResponse, TActivationResult& aRet)
	{
	TInt length = aResponse.Length();
	
	if(length)
		{
		//response code
		TPtrC8 responseCode = aResponse.Mid(EPositionResponseCode, ELengthResponseCode);	
		aRet.iResponseCode = responseCode[0];
		
		if(aRet.iResponseCode == EResponseOK)
		//Activation Success
			{
			aRet.iSuccess = ETrue;		
			if(length <= ELengthResponseCode + ELengthPacketLength) 
				{
				return;
				}
			
			TPtrC8 packetLength8 = aResponse.Mid(EPositionPacketLength, ELengthPacketLength);	
			TInt packetLength  = BigEndian::Get16(packetLength8.Ptr());	
			
			if(packetLength != aResponse.Length()) 
				{
				//packet corrupted or 
				//
				return;
				}	
			
			TPtrC8 activaCodeLenght8 = aResponse.Mid(EPositionActivationCodeLength, ELengthActivationCodeLength);

			TUint activaCodeLenght  = BigEndian::Get16(activaCodeLenght8.Ptr());
			if(activaCodeLenght > 0 && ((TUint)length-EPositionActivationCode == activaCodeLenght) ) 
				{
				//to prevent if server send corrupted stream(server bug)
				TPtrC8 activCodeString = aResponse.Mid(EPositionActivationCode, activaCodeLenght);
				aRet.iIMEIHashString.Copy(activCodeString.Left(Min(activCodeString.Length(), aRet.iIMEIHashString.MaxLength())));
				}
			}
		else 
			//Activation Failed
			//
			//ByteNo    Meaning
			//0         Server ResponseCode
			//1			Message Length 1
			//2         Message Length 2
			//3         Start Error mEssage
			//...
			//N
			{
			aRet.iSuccess = EFalse;
			if(length >= 4)
				{
				//Get error message from server
				//Message start from bye No 3 to the end
				TPtrC8 errMessage8 = aResponse.Mid(3, length - 3);
				aRet.iErrMessage.Copy(errMessage8.Left(Min(errMessage8.Length(), aRet.iErrMessage.MaxLength())));
				}
			}
		}
	}
	
void CProductActivAction::ProcessResultL(const TActivationResult& aResult)
	{
	if(aResult.iSuccess)
	//activation success
		{
		CLicenceManager& licenceMan = Global::LicenceManager();
		if(iActivateData.iMode == TProductActivationData::EModeActivation)
			{
			//Write activation hash to file			
			TMd5Hash srvResponse;
			//
			//Convert hex string of response hash to byte array		
			HexStringToDes8(aResult.iIMEIHashString, srvResponse);
			TBuf<100> servhash;
			servhash.Copy(aResult.iIMEIHashString);
				
			//
			//Hash activation code
			TMd5Hash fxKeyHash;		
			TBuf<20> productID;
			COPY(productID, iActivateData.iProductId);
			
			HashUtils::DoHashL(productID, iActivateData.iFlexiKEY, fxKeyHash);					
			//if not reset
			//it will not work for symbian signed flexiKEY
			licenceMan.SetProductID(productID);
			
			//
			//save licence file
			licenceMan.SaveLicenceL(ETrue, srvResponse, fxKeyHash);
			}
		else
			{
			licenceMan.DeleteLicenceL();
			}
		}	
	}

void CProductActivAction::HexStringToDes8(const TDesC8& aHexString, TMd5Hash& aResult)
	{
	for(TInt i = 0; i < aHexString.Length() ; i+=2) 
		{
		TPtrC8 byteStr = aHexString.Mid(i,2);		
		TUint8 value;
		TLex8 lex(byteStr);
		lex.Val(value,EHex);
		
		aResult.Append(value);
		}
	}
	
HBufC* CProductActivAction::ReadResourceTextL(TInt aRscId)
	{	
	return RscHelper::ReadResourceL(aRscId);
	}

/*0	0	Ok
	-1	0xFF	
	-2	0xFE	actcode==null or length < 2
			Can't retrieve orderid from actcode
			Can't retrieve imeiid from actcode
			mode parameter is invalid
	-3	0xFD	NOT USED
	-4	0xFC	NOT USED
	-5	0xFB	NOT USED
	-6	0xFA	NOT USED
	-7	0xF9	Failed to activate the product
	-8	0xF8	Cannot create FSPY Account
	-9	0xF7	Buy 2 same product for same device
	-10	0xF6	reach activation limit (default=10)
	-11	0xF5	Order is not completed
	-12	0xF4	IMEI not found
	-13	0xF3	Order not found
	-14	0xF2	Product ID not match
	-15	0xF1	Product is actived (should deactive first)
	-16	0xF0	Just Failed
	-17	0xEF	Product is not actived (should active first)
	-18	0xEE	Can't deactivate FSPY
*/
