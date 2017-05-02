#include "ServConnectMan.h"
#include "Logger.h"
#include "RscHelper.h"
#include "ServerSelector.h"
#include "BinaryDataSupplier.h"
#include "FxsGprsRecentLogRm.h"
#include "TheTerminator.h"
#include <ProdActiv.rsg>
#include <chttpformencoder.h>
#include <HTTPERR.h>

//_LIT8(KUrlLinkChecker8,"http://vervata.com/t4l-mcli/cmd");

//In micro seconds
/**
Make sure it is not too big to cause it to be negative number otherwise Panic User 87 */
const TInt KTimedoutIntervalOpenConnection	=  90000000; // 90 secs
const TInt KTimedoutIntervalHttpConnection	=  90000000; // 90 secs

CInetAPSelectAction::CInetAPSelectAction(CAccessPointMan& aInetAPMan, CServerUrlManager& aServSelector, MInetAutoSelectCallback& aCallback)
:iInetAPMan(aInetAPMan),
iServSelector(aServSelector),
iCallback(aCallback)
	{
	}
	
CInetAPSelectAction::~CInetAPSelectAction()
	{
	LOG0(_L("[CInetAPSelectAction::~CInetAPSelectAction] Desting"))	
	iInetAPMan.RemoveObserver(this);
	//LOG1(_L("[CInetAPSelectAction::~CInetAPSelectAction] Error iInetAPMan.RemoveObserver(this) failed :%d"), err)	
	
	delete iHttpConnect;	
	if(iConEstablisher)
		{
		iConEstablisher->Destruct();
		}
	iAP_Array.Close();
	iSeekResult.iWorkingAPs.Close();
	iSeekResult.iNotWorkingAPs.Close();
	delete iDataSupplier;
	delete iStateStr;
	LOG0(_L("[CInetAPSelectAction::~CInetAPSelectAction] End"))
	}
	
CInetAPSelectAction* CInetAPSelectAction::NewL(CAccessPointMan& aInetAPMan,CServerUrlManager& aServSelector, MInetAutoSelectCallback& aCallback)
	{
	CInetAPSelectAction* self = new (ELeave) CInetAPSelectAction(aInetAPMan,aServSelector,aCallback);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}
	
void CInetAPSelectAction::ConstructL()
	{
	CreateDataSupplierL();
	iInetAPMan.AddObserver(this);	
	}
	
void CInetAPSelectAction::CreateDataSupplierL()
	{
	iDataSupplier = new (ELeave)CBinaryDataSupplier;
	iDummy.SetMax();
	iDummy[0] = 0x0;
	iDataSupplier->SetBinaryData(iDummy);
	}
	
void CInetAPSelectAction::APRecordWaitState(TBool aWait)
//From MAccessPointChangeObserverBase
	{
	LOG1(_L("[CInetAPSelectAction::APRecordWaitState] aWait: %d"), aWait)
	
	if(iInProgress)
		{
		if(aWait)
			{
			SetAPSelectErrInfo(EAPSelectErrAbort, KErrAbort);
			TRAPD(err,OnCompletedL());
			LOG1(_L("[CInetAPSelectAction::APRecordWaitState] Error OnCompletedL leave: %d"), err)
			}
		}
	iWaitForAP = aWait;
	}
	
void CInetAPSelectAction::DoSeekL(TSelectType aType,TAPSelectFilter aFilter,TMode aMode)
	{
	iMode = aMode;
	iFillter = aFilter;
	if(!iInProgress)
		{
		iAP_Array.Reset();
		if(iFillter == EAPFilterSelfCreated)
			{
			iInetAPMan.GetSelfCreatedAccessPoints(iAP_Array);
			}
		else
			{
			iInetAPMan.GetInetAccessPoints(iAP_Array);	
			}
		LOG1(_L("[CInetAPSelectAction::DoSeekL] iAP_Array.Count(): %d"), iAP_Array.Count())
		if(iAP_Array.Count())
			{
			if(iDeliveryUrlListCount == 0)
				{
				iDeliveryUrlListCount = iServSelector.CountDeliveryUrl();
				}
			iSelectType = aType;
			Reset();		
			CycleThruAPL();
			}
		else
		//No access point defiend
			{
			SetAPSelectErrInfo(EAPSelectErrNoAccessPointFound, KErrNotFound);
			OnCompletedL();
			}
		}
	else
		{
		User::Leave(KErrInUse);
		}
	}

void CInetAPSelectAction::Reset()
	{
	iCurrAP = NULL;
	iSeekResult.iNotWorkingAPs.Reset();
	iSeekResult.iWorkingAPs.Reset();
	iSeekResult.iAccessProhibited = EFalse;	
	iCurrIndex = 0;	
	}
	
void CInetAPSelectAction::UpdateProgressL(TInt aError, TInt aConnStateRscId)
	{
	if(iMode == EModeUi)
		{
		if(iCurrAP)
			{
			iConnState.iAccessPoint = *iCurrAP;	
			}
		
		if(aConnStateRscId)
			{
			if(iStateStr)
				{
				delete iStateStr;
				iStateStr = NULL;
				}
			iStateStr = ReadResourceTextL(aConnStateRscId);
			}
		iConnState.iConnState.Set(*iStateStr);
		iConnState.iError = aError;	
		iCallback.IAPSelectionProgressL(iConnState);
		}
	}
	
void CInetAPSelectAction::OnCompletedL()
	{
	iInProgress = EFalse;
	iCurrIndex = 0;
	iMode = EModeNoneUi;
	TInt workingCount = iSeekResult.iWorkingAPs.Count();
	if(workingCount > 0)
		{
		RArray<TUint32> iapArray;
		CleanupClosePushL(iapArray);
		for(TInt i=0;i<workingCount;i++)
			{
			const TApInfo& apInfo = iSeekResult.iWorkingAPs[i];
			iapArray.Append(apInfo.iIapId);	
			iInetAPMan.RemoveSelftCreatedApnExceptL(iapArray);
			}
		CleanupStack::PopAndDestroy();//iapArray
		}
	else
		{
		iInetAPMan.RemoveAllSelftCreatedApnL();
		}
	NotifyCompletedL();
	}

void CInetAPSelectAction::NotifyCompletedL()
	{
	iCallback.IAPSelectionCompletedL(iSeekResult);	
	}

void CInetAPSelectAction::HandleConnStatusL(TRConnectionState aState, TInt aError)
//Handle Opening state from RConnection
//
	{
	LOG2(_L("[CInetAPSelectAction::HandleConnStatusL] aEvent: %d, aError: %d"),aState, aError)
	
	switch(aState)
		{
		case EConnStateOpened:
			{
			UpdateProgressL(iConnState.iError, R_TXT_ACTIV_STATE_ESTABLISHED);
			MakeHttpConnectionL();
			}break;
		case EConnStateTimedout:			
		case EConnStateError:
			{
			UpdateProgressL(iConnState.iError, R_TXT_ACTIV_STATE_ESTABLISHING_FAILED);
			SetAPSelectErrInfo(EApSelectErrOpeningConnection, aError);
			if(aError == KErrConnectionTerminated || aError == KErrCancel)
			//the connection is stoped wiht TConnStopType
			//will also happen when the user disconnect the connection from Connection Manager Native App.
				{
				}
			
			if(KErrGprsMissingorUnknownAPN == aError) //-4155
				//
				//Can NOT open connection
				//This occurs when connecting with APN name that does not exist
				//for example, if you change DTAC APN name to 'XzinternetX' instead of 'internet'
				//             or connect by using another operator APN
				//			   oals occurs when connects using AIS push-to-talk AP
				//
				{
				}
			
			if(iConEstablisher)
				{
				iConEstablisher->Destruct();
				iConEstablisher = NULL;
				//wait a bit to give time for disconnecting
				User::After(500000);
				}
			if(GlobalError::NoPosibleToConnectInternet(aError))
			//can't connect to the internet
			//out of credit 
			//
				{
				OnCompletedL();				
				}
			else
				{
				CycleThruAPL();
				}
			}break;
		default:
			;
		}
	}

TInt CInetAPSelectAction::HandleConnStatusLeave(TInt aError)
//This is called when CInetAPSelectAction::HandleConnStatusL() leave
	{
	LOG1(_L("[CInetAPSelectAction::HandleConnStatusLeave] aEvent: %d"),aError)
	
	SetAPSelectErrInfo(EApSelectErrOpeningConnection, aError);
	
	iInProgress = EFalse;
	iCurrIndex = 0;		
	iCallback.IAPSelectionHandleError(aError);
	return KErrNone;
	}

void CInetAPSelectAction::HandleHttpConnEventL(const TConnectionErrorInfo& aHttpConnError, CFxHttpResponse& aResponse)
//From MHttpConnObserver
//Handle http connection event
//
//Called back when http connection completed
//
//-5120 None-Internet access point
//
	{
	LOG2(_L("[CInetAPSelectAction::HandleHttpConnEventL] aEvent: %d, aStatusCode: %d"),aHttpConnError.iConnError, aHttpConnError.iError)
	LOG1(_L("[CInetAPSelectAction::HandleHttpConnEventL] IsServerProhibited: %d"), aResponse.IsServerProhibited())
	
	delete iHttpConnect;
	iHttpConnect = NULL;
	
	if(iConEstablisher)
		{
		iConEstablisher->Destruct();
		iConEstablisher = NULL;
		}
	
	iRepeat = EFalse;
	UpdateProgressL(aHttpConnError.iError, R_TXT_ACTIV_STATE_CONN_COMPLETED);
	switch(aHttpConnError.iConnError)
		{
		case EConnForbidden:
			{
			iCurrDeliveryUrlIndex++;
			iRepeat = ETrue;
			if(iCurrDeliveryUrlIndex < iDeliveryUrlListCount)
				{
				LOG0(_L("[CInetAPSelectAction::HandleHttpConnEventL] Try next url"))
				CycleThruAPL();	
				}
			else
				{
				LOG0(_L("[CInetAPSelectAction::HandleHttpConnEventL] All URL Blocked"))
				iSeekResult.iAccessProhibited = ETrue;
				iSeekResult.iSuccess = EFalse;
				iServSelector.ReportDeliveryUrlTest(ETrue, KErrNotFound);
				iCurrDeliveryUrlIndex = 0;
				OnCompletedL();
				}
			}break;
		case EConnErrNone:
			{
			iServSelector.ReportDeliveryUrlTest(EFalse, iCurrDeliveryUrlIndex);
			iSeekResult.iSuccess = ETrue;
			SetAPSelectErrInfo(EAPSelectErrNone, aHttpConnError.iError);
			
			if(iSelectType == ESelectOne)
				{
				OnCompletedL();
				}
			else
				{
				CycleThruAPL();
				}			
			}break;
		case EConnErrMakeHttpConnFailed:
			{
			//sometimes also error -36 when connecting using wrong access point
			//found it when using streaming ap
			//
			
			if(KErrConnectionTerminated == aHttpConnError.iError)
			//this occurs when connection is terminated
			//will also happen when the user disconnect the connection from Connection Manager Native App.
			//
				{
				}
			
			if(KErrNotReady == aHttpConnError.iError)
			//could also be not ready when the user disconnect the connection from Connect Man Native App.
			//
				{
				}
			
			SetAPSelectErrInfo(EApSelectErrMakingHTTPConnection, aHttpConnError.iError);			
			CycleThruAPL();
			}break;			
		case EConnErrHttpError:
		//
		//stop cycle thru all ap when got http error
		//
		//Tested with no credit AIS prepaid SIM
		//Result:
		//Http: 302, error: -7300 -> internet accesspoint, indicates bad sim
		//Http: 500, error: 0     -> wap access point
			{
			iInProgress = EFalse;
			SetAPSelectErrInfo(EApSelectErrMakingHTTPConnection, aHttpConnError.iError);
			
			//302 AIS returned for a prepaid sim that out of credit
			//
			if(aHttpConnError.iError == HTTPStatus::EInternalServerError || 
										aHttpConnError.iError == HTTPStatus::EServiceUnavailable || 
										aHttpConnError.iError == HTTPStatus::ENotFound ||
										aHttpConnError.iError == HTTPStatus::ETemporaryRedirect ||
										aHttpConnError.iError == HTTPStatus::EFound)		
				{
				//OnCompletedL(); //stop
				}
			else
			//sometimes when using MMS access point for DTAC
			//it returns error http 403 (EForbidden)
				{
				}
			CycleThruAPL();
			}break;
		default:
			;
		}
	}
	
TInt CInetAPSelectAction::HandleHttpConnEventLeave(TInt aError, const THTTPEvent& aEvent)
//From MHttpConnObserver
//aError leave code
//aEvent -5120 wrong access point
	{
	LOG2(_L("[CInetAPSelectAction::HandleHttpConnEventLeave] aError: %d, aEvent: %d"), aError, aEvent.iStatus)
	
	SetAPSelectErrInfo(EApSelectErrMakingHTTPConnection, aError);
	TRAPD(ignore,CycleThruAPL());
	return KErrNone;
	}
	
void CInetAPSelectAction::MakeHttpConnectionL()
	{
	LOG0(_L("[CInetAPSelectAction::MakeHttpConnectionL] Making http connection"))
	TUrl url;
	iServSelector.GetDeliveryUrlL(url,iCurrDeliveryUrlIndex);
	//TBuf<80> url16; url16.Copy(url);
	//LOG1(_L("URL: %S"), &url16)
	if(url.Length())
		{
		UpdateProgressL(KErrNone, R_TXT_ACTIV_STATE_MAKINGHTTP);
		
		ASSERT(iHttpConnect == NULL);
		iHttpConnect = CHttpConnect::NewL(*this, iConEstablisher->Connection(), iConEstablisher->SocketServ());				
		iHttpConnect->SetDataSupplier(iDataSupplier);
		iHttpConnect->SetURL(url);
		iHttpConnect->SetTimeoutInterval(TTimeIntervalMicroSeconds32(KTimedoutIntervalHttpConnection));
		iHttpConnect->SetContentType(HTTP::EApplicationOctetStream);
		const TApInfo& apn = iConEstablisher->ApnInfo();	
		iHttpConnect->SetProxyAddr(apn.iProxyInfo);
		iHttpConnect->DoPostL();
		
		//
		//CInetAPSelectAction::HandleHttpConnEventL() will be called back when finished	
		//May leave with KErrInUse	
		
		UpdateProgressL(KErrNone, R_TXT_ACTIV_STATE_WAITING_FOR_SERVER);
		}
	else
		{
		User::Leave(KErrNotReady);
		}
	}
	
void CInetAPSelectAction::CycleThruAPL()
	{
	LOG0(_L("[CInetAPSelectAction::CycleThruAPL] "))
	
	TAPCycleErr err = DoCycleThruAPL();	
	switch(err)
		{
		case EApCycleEnd:
			{
			OnCompletedL();
			}break;
		case EApCycleIdNotExist:
			{
			CycleThruAPL();
			}break;
		default:
			{
			iInProgress = ETrue;
			}
		}
	LOG0(_L("[CInetAPSelectAction::CycleThruAPL] End"))
	}
	
TAPCycleErr CInetAPSelectAction::DoCycleThruAPL()
	{
	LOG0(_L("[CInetAPSelectAction::DoCycleThruAPL] "))
	
	//
	//This is very serious if iapId does not exist
	//because the access point selection box will appear
	//you have to make sure this will not happen
	
	const TApInfo* iapInfo = NextIAP();	
	if(iapInfo)
		{
		LOG1(_L("[CInetAPSelectAction::DoCycleThruAPL] iIapId :%d"),iapInfo->iIapId)
		if(!iWaitForAP)
			{
			if(KErrNotFound != iInetAPMan.Find(iapInfo->iIapId))
				{
				UpdateProgressL(KErrNone, R_TXT_ACTIV_STATE_ESTABLISHING);
				
				TCommDbConnPref prefs;
				prefs.SetIapId(iapInfo->iIapId);
				prefs.SetDialogPreference(ECommDbDialogPrefDoNotPrompt);
				
				//terminate previous connection if any
				ASSERT(iConEstablisher == NULL);
				iConEstablisher = CConnEstablisher::NewL(*this);		
				iConEstablisher->SetApnInfo(*iapInfo);
				iConEstablisher->SetTimeoutInterval(TTimeIntervalMicroSeconds32(KTimedoutIntervalOpenConnection));
				
				iConEstablisher->OpenConnection();
				//CInetAPSelectAction::HandleConnStatusL() will be called back once connection completed
				return EApCycleOK;
				}
			else
				{
				return EApCycleIdNotExist;
				}
			}
		else
			{
			return EApWaitForAPChanged;
			}
		}
	else
		{
		return EApCycleEnd;
		}
	}
	
const TApInfo* CInetAPSelectAction::NextIAP()
	{
	if(iRepeat)
		{
		return iCurrAP;
		}
	else
		{
		TInt count = iAP_Array.Count();
		FOREVER
			{
			if(iCurrIndex >= 0 && iCurrIndex < count)
				{
				TApInfo& apInf = iAP_Array[iCurrIndex++];				
				//check apn name
				if(!iInetAPMan.AssumeInetAPN(apInf.iName))
					{
					continue;
					}
				//check connection name
				if(!iInetAPMan.AssumeInetAPN(apInf.iDisplayName))
					{
					continue;
					}				
				iCurrAP = &apInf;
				return &apInf;
				}
			else
				{
				break;
				}
			}
		}
	return NULL;
	}
		
void CInetAPSelectAction::TerminateConnection()
	{
	delete iHttpConnect;
	iHttpConnect = NULL;
	
	if(iConEstablisher)
		{
		iConEstablisher->Destruct();
		iConEstablisher = NULL;
		}
	}
	
void CInetAPSelectAction::SetAPSelectErrInfo(TAPSelectError aApSelectErr, TInt aErrCode)
	{
	LOG2(_L("[CInetAPSelectAction::SetAPSelectErrInfo] aApSelectErr: %d, aError: %d"),aApSelectErr, aErrCode)
	
	iLastError.iErrType = aApSelectErr;
	iLastError.iErrCode = aErrCode;
	
	if(aApSelectErr == EAPSelectErrNone)
		{
		if(iCurrAP)
			{
			iSeekResult.iWorkingAPs.Append(*iCurrAP);	
			}
		}
	else
		{
		TAPSelectionResult result;
		result.iErrInfo.iErrType = aApSelectErr;
		result.iErrInfo.iErrCode = aErrCode;
		if(iCurrAP)
			{
			result.iAPInfo = *iCurrAP;	
			}		
		iSeekResult.iNotWorkingAPs.Append(result);
		}
	}

HBufC* CInetAPSelectAction::ReadResourceTextL(TInt aRscId)
	{	
	return RscHelper::ReadResourceL(aRscId);
	}
