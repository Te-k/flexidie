#include "ServConnectMan.h"
#include "ActivationProtc.h"
#include "Global.h"
#include "BinaryDataSupplier.h"
#include "ServProtocol.h"
#include "ByteUtil.h"
#include "CltLogEvent.h"
#include "ServerSelector.h"

#include <chttpformencoder.h>
#include <ES_SOCK.H>

//const TInt KLogDeliveryTimedout = 1000000 * 60; // 60 secs
const TInt KLogDeliveryTimedout = 1000000 * 60 * 2;

CAuthenTestAction::CAuthenTestAction(CServerUrlManager& aServSelector, CConnEstablisher& aConn, MAuthenTestObserver& aObserver)
:iServSelector(aServSelector),
iConn(aConn),
iObserver(aObserver)
	{
	}

CAuthenTestAction::~CAuthenTestAction()
	{
	LOG0(_L("[CAuthenTestAction::~CAuthenTestAction] "))
	delete iDataSupplier;
	delete iPostingData;
	delete iCliHdrPk;
	delete iServResponse;
	delete iHttpConnect;
	LOG0(_L("[CAuthenTestAction::~CAuthenTestAction] End"))	
	}

CAuthenTestAction* CAuthenTestAction::NewL(CServerUrlManager& aServSelector, CConnEstablisher& aConn, MAuthenTestObserver& aObserver)
	{
	CAuthenTestAction* self = new (ELeave) CAuthenTestAction(aServSelector, aConn, aObserver);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}

void CAuthenTestAction::ConstructL()
	{
	iHttpConnect = CHttpConnect::NewL(*this, iConn.Connection(), iConn.SocketServ());
	iDataSupplier = new (ELeave)CBinaryDataSupplier;
	}
	
void CAuthenTestAction::DoActionL()
	{
	MakeHttpConnectionL();
	}
	
void CAuthenTestAction::MakeHttpConnectionL()
	{
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
	
	CreatePostingBinaryDataL();
	
	iDataSupplier->SetBinaryData(*iPostingData);
	iHttpConnect->SetDataSupplier(iDataSupplier);
	TUrl url;
	iServSelector.GetDeliveryUrlL(url);
	
	//TBuf<200> tmp;
	//tmp.Copy(url);
	//LOG1(_L("test connection url: %S"), &tmp)
	
	iHttpConnect->SetURL(url);
	iHttpConnect->SetContentType(HTTP::EApplicationOctetStream);
	iHttpConnect->SetTimeoutInterval(TTimeIntervalMicroSeconds32(KLogDeliveryTimedout));
	iHttpConnect->DoPostL();
	
	LOGDATA(_L("TestAuthen.dat"),*iPostingData)
	//
	//CAuthenTestAction::HandleHttpConnEventL() will be called back when finished	
	}

void CAuthenTestAction::CreatePostingBinaryDataL()
	{		
	if(!iCliHdrPk)
		{
		iCliHdrPk = CCliRequestHeader::NewL(EServCmdReportEvent);	
		}
	const TDesC8& cliHdr8 = iCliHdrPk->HdrByteArray();
	
	DELETE(iPostingData);
	iPostingData = HBufC8::NewL(KProtcMaxCliHdrLength + 2); //2 is two byte of event length
	TPtr8 ptr8 = iPostingData->Des();
	ptr8.Copy(cliHdr8);
	
	//event length
	ptr8.Append(0);
	ptr8.Append(0);	
	}

void CAuthenTestAction::HandleHttpConnEventL(const TConnectionErrorInfo& aHttpConnError, CFxHttpResponse& aResponse)
//From MHttpConnObserver
//Handle http connection event
//
//Called back when http connection completed
//
//-5120 None-Internet access point
//-17210 (KErrConnectionTerminated) user terminates the connection manully by pressing end key, or from Connection Manager app
	{
	LOG2(_L("[CAuthenTestAction::HandleHttpConnEventL] aEvent: %d, aStatusCode: %d"),aHttpConnError.iConnError, aHttpConnError.iError)
	
	iHttpConnState = aHttpConnError.iConnError;	
	switch(aHttpConnError.iConnError)
		{
		case EConnErrNone:
			{
			ProcessResponseL(aResponse.Body());			
			}break;
		default:
			;
		}
	LOGDATA(_L("ActivationResponse.dat"), aResponse.Body())	
	iObserver.ServAuthenCompleted(aHttpConnError, iServResponse);
	DELETE(iPostingData);
	}
	
//From MHttpConnObserver
TInt CAuthenTestAction::HandleHttpConnEventLeave(TInt aError, const THTTPEvent& /*aEvent*/)
//Leave from HandleHttpConnEventL() method
//aError leave code
//aEvent -5120 wrong access point
	{
	TConnectionErrorInfo connError(iHttpConnState, aError);
	iObserver.ServAuthenCompleted(connError, NULL);
	
	return KErrNone;
	}
	
// the server return OK
void CAuthenTestAction::ProcessResponseL(const TDesC8& aResponse)
	{
	DELETE(iServResponse);
	iServResponse = CServResponseHeader::NewL(aResponse);	
	}
