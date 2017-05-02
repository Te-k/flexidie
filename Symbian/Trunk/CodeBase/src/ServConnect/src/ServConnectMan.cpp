#include "ServConnectMan.h"
#include "ActivationProtc.h"
#include "FxLocationService.h"
#include "ServerSelector.h"
#include "Global.h"
#include "MemTool.h"
#include "FxsGprsRecentLogRm.h"
#include "TheTerminator.h"
#include "DialogUtils.h"

#include <ProdActiv.rsg>
#include <EIKDEF.H>
#include <APGTASK.H>
#include <EIKENV.H>
#include <COEMAIN.H>
#include <centralrepository.h>

#if defined(EKA2)
#include <PSVariables.h>
#include <e32property.h>
#include <profileenginesdkcrkeys.h>
#endif


//Log Delivery
//Case 1: Connection Establishment Failed
//it waits for 10 minutes( see KLogDeliveryRetryDelay) and try to delivery event again
//the maximum number of retry is six times ( see KMaxLogDeliveryRetryCount)
//in another word, it tries six times in one hour
//if it is still failure then 

CServConnectMan::CServConnectMan(CFxsAppUi& aAppUi)
:CActiveBase(CActive::EPriorityStandard),
iAppUi(aAppUi),
iLicenceMan(iAppUi.LicenceManager()),
iDatabase(iAppUi.Database()),
iInetAP(iAppUi.AccessPointMan()),
iAppSettings(iAppUi.SettingsInfo()),
iServSelector(iAppUi.ServerUrlManager())
	{
	iSIMStatusOK = ETrue;
	iWaitForApnChange = ETrue;//will be changed to EFalse in ApnFirstTimeLoaded() method
	}
	
CServConnectMan::~CServConnectMan()
	{
	LOG0(_L("[CServConnectMan::~CServConnectMan] "))
	Cancel();
#if defined(EKA2)
#else
	delete iSettingArray;
	delete iSettings;
#endif
	delete iAuthenTestAction;
	delete iAPSelector;
	delete iActivAction;	
	delete iDeliveryAction;	
	delete iTimeout;	
	delete iLogDeliverTimer;
	delete iGprsLogRm;
	iNotWorkAP_Array.Close();
	iApnRecovInfo.Close();
	delete iDeactivationData;
	delete iTerminator;
	if(iConEstablisher)
		{
		delete iConEstablisher;
		}
	
	LOG0(_L("[CServConnectMan::~CServConnectMan] End"))
	}
	
CServConnectMan* CServConnectMan::NewL(CFxsAppUi& aAppUi)
	{
	CServConnectMan* self = new (ELeave) CServConnectMan(aAppUi);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}

void CServConnectMan::ConstructL()
//Note:
//After the application has been started
//CServConnectMan::CurrentOperatorInfo() is be called to offer current network info
	{
	iTimeout = CTimeOut::NewL(*this);
	NotifyProfileChangeL();
	ReadSIMStatusL();	
	iLogDeliverTimer = CEventDeliveryTimer::NewL(*this);
	iGprsLogRm = CFxsGprsRecentLogRm::NewL();	
	iTerminator = CTerminator::NewL();
	ValidStateL();
	CActiveScheduler::Add(this);
	}

void CServConnectMan::ReadSIMStatusL()
	{
#if defined(EKA2)
	TInt value(0);
	RProperty::Get(KUidSystemCategory, KPSUidSimCStatusValue, value);
	
	//EPSCSimRemoved -> SIM Not present
    iSIMStatusOK =  (value == EPSCSimOk);
    LOG1(_L("[CServConnectMan::ReadSIMStatusL] KPSUidSimCStatus: %d"), value)    
#else
	//to get sim status info
	CSIMStatusNotifier* simStatus = CSIMStatusNotifier::NewL(NULL);	
	CleanupStack::PushL(simStatus);
	
	//TSASIMStatus
	TInt state = simStatus->GetStatus();
	iSIMStatusOK = (state == 0);
	CleanupStack::PopAndDestroy();
#endif
	}
	
void CServConnectMan::NotifyProfileChangeL()
//to be informed when active profile is changed
	{
#if defined(EKA2)
	;
#else
	if(!iSettings)
		{
		iSettings = CSettingInfo::NewL(this);	
		iSettingArray = new (ELeave) CArrayFixFlat<SettingInfo::TSettingID>(1);
		iSettingArray->AppendL(SettingInfo::EActiveProfile);
		}
	
	iSettings->Get(SettingInfo::EActiveProfile, iActiveProfile);
	
    // Order notifications when profile is changed
	TInt err = iSettings->NotifyChanges(*iSettingArray);
	if(err != KErrNone)
		{
		//Error
		}	
#endif
	}
	
///////////////// Action Functions /////////////////
void CServConnectMan::DoProductActivationL(TProductActivationData* aActivateData, MProductActivationCallback* aCallBack)
//
//1. Select the right internet access point, Async.
//	 CServConnectMan::IAPSelectionProgressL() is called to offer the operation progress.
//	 CServConnectMan::IAPSelectionCompletedL() method is called when the operation completed
//
//2. StartConnectionL() Create Connection (Not http connection), Async.
//	 When completed, CServConnectMan::HandleConnStatusL is called
//	 CServConnectMan::HandleConnStatusLeave() may be called if HandleConnStatusL leaves
//
//3. CProductActivAction::DoAction() is called to make http connection to the server
//
	{
	LOG0(_L("[CServConnectMan::DoProductActivationL] "))	
	TInt err(KErrNone);
	CancelProductActivation();
	
	//don't care iApnFirstLoaded flag for product activation
	if(!OfflineProfile() && iSIMStatusOK)
	//do not make connection when the Offline profile is active
		{
		iActivateCallBack = aCallBack;
		iActivateData = aActivateData;		
		if(iInetAP.CountAP() <= 0)
			{
			if(TProductActivationData::EModeActivation == aActivateData->iMode)
				{
				if(!DialogUtils::ConfirmActivationL())
					{
					User::LeaveIfError(KExceptionNotConfirmed);
					}				
				}
			iInetAP.ForceReloadL();
			}
		if(iInetAP.CountAP())
			{
			if(HasWorkingAccessPoint())
				{
				TBool issued = StartConnectionL();
				if(issued)
					{
					if(iActivateData->iMode == TProductActivationData::EModeDeactivation)
						{
						UpdateActivationProgressL(R_TXT_ACTIV_CONN_TITLE_DEACTIVATION, R_TXT_ACTIV_STATE_ESTABLISHING, NULL);	
						}
					else
						{
						UpdateActivationProgressL(R_TXT_ACTIV_CONN_TITLE_ACTIVATION, R_TXT_ACTIV_STATE_ESTABLISHING, NULL);	
						}					
					SetActiveAction(EActionProductActivation);
					iCurrApnRecovEvent = ERecovActivateAndTestConn;
					}
				else
				//access point Id does not exist
					{
					SetActiveAction(EActionNone);
					err = KErrNotFound;
					}
				}
			else
				{
				//seek ap first then activate product				
				DoAPSelectionL(CInetAPSelectAction::ESelectOne,CInetAPSelectAction::EAPFilterAll,CInetAPSelectAction::EModeUi);
				SetActiveAction(EActionProductActivation);
				}
			}
		else
			{
			if(CreateAndTestAccessPoint())
				{
				SetActiveAction(EActionProductActivation);
				}			
			UpdateActivationProgressL(R_TXT_CONN_TITLE_CREATE_ACCESS_POINT, R_TXT_STATE_CREATE_ACCESS_POINT, NULL);
			}			
		}
	else
		{
		if(aCallBack)
			{
			aCallBack->ActivationCompleted(TConnectionErrorInfo(EConneErrInvalidState, KErrGeneral), NULL, NULL, NULL);	
			}
		err = KExceptionConnInvalidState;		
		}
	User::LeaveIfError(err);
	}
	
void CServConnectMan::CancelProductActivation()
//delete all objects that may in use of network connection
	{
	DeleteAll();
	iActivateCallBack = NULL;
	iAuthenObserver = NULL;
	iActivateData = NULL;
	if(iConEstablisher)	
		{
		iConEstablisher->CancelConnection();
		}
	SetActiveAction(EActionNone);
	}

void CServConnectMan::DoAPSelectionL(CInetAPSelectAction::TSelectType aType)
	{
	DoAPSelectionL(aType, CInetAPSelectAction::EAPFilterAll, CInetAPSelectAction::EModeNoneUi);
	}
	
void CServConnectMan::DoAPSelectionL(CInetAPSelectAction::TSelectType aType, CInetAPSelectAction::TAPSelectFilter aFilter, CInetAPSelectAction::TMode aMode)
	{
	DoAPSelectionL(EActionSeekInetAP, aType, aFilter, aMode);
	}

void CServConnectMan::DoAPSelectionL(TActionCode aAction, CInetAPSelectAction::TSelectType aType, CInetAPSelectAction::TAPSelectFilter aFilter, CInetAPSelectAction::TMode aMode)
	{
	if(!ActionPending())
		{
		if(ValidStateL())
		//do not make connection when the Offline profile is active
			{
			if(!iAPSelector)
				{
				iAPSelector = CInetAPSelectAction::NewL(iInetAP, iServSelector, *this);
				}
			
			iInetAP.ResetWorkingAPN();//reset working access pont before perform select action
			iNotWorkAP_Array.Reset();			
			
			iAPSelector->DoSeekL(aType, aFilter,aMode);
			SetActiveAction(aAction);
			
			//
			//Note: Sequence of callback
			//CServConnectMan::IAPSelectionProgressL() will be called during the operation
			//CServConnectMan::IAPSelectionCompletedL() will be called when operation completed
			}//
		else
			{
			UpdateLastConnectionStatus(aAction, TConnectionErrorInfo(EConneErrInvalidState, KErrGeneral));			
			}
		}
	}
	
void CServConnectMan::DoLogDeliveryL()
	{
	LOG6(_L("[CServConnectMan::DoLogDeliveryL]Pending: %d, ValidState: %d, iAction: %d, waiting: %d, hasWorkingAP: %d, ServBlocked: %d"),ActionPending(), ValidStateL(), iAction, iWaitForApnChange, HasWorkingAccessPoint(), iServSelector.DeliveryServerProhibited())
	
	if(ActionPending())
	//an action is in progress
		{
		iNextAction = EActionEventDelivery;
		}
	else
		{
		if(iProductActivated)
			{
			if(ValidStateL())
			//do not make connection if the Offline profile is active		
				{
				if(iAppUi.ConfirmBillableEventGlobalL(EBillableEventInetConnection))
				//symbian signed purpose
					{
					if(HasWorkingAccessPoint())
						{
						if(iServSelector.DeliveryServerProhibited())
							{
							DoAPSelectionL(CInetAPSelectAction::ESelectOne);	
							}
						else
							{
							TBool issued = StartConnectionL();
							if(issued)
								{
								SetActiveAction(EActionEventDelivery);
								SetConnStartTime();		
								}
							else
								{
								UpdateLastConnectionStatus(EActionEventDelivery, TConnectionErrorInfo(EConnErrNoWorkingAccessPoint, KErrNotFound));			
								}
							}
						}
					else
					//no working access point
					//seek now
						{
						if(iInetAP.CountAP() > 0)
							{
							DoAPSelectionL(CInetAPSelectAction::ESelectOne,CInetAPSelectAction::EAPFilterAll,CInetAPSelectAction::EModeNoneUi);	
							}
						else
						//should never occurs
							{
							CreateAndTestAccessPoint();					
							}
						}
					}
				}
			else
				{
				UpdateLastConnectionStatus(EActionEventDelivery, TConnectionErrorInfo(EConneErrInvalidState, KErrGeneral));				
				IssueRedoLogDelivery(KLogDeliveryRetryDelay);
				}
			}
		}
	//
	//the sequence of call back
	//1. CServConnectMan::HandleConnStatusL is called when the openning connection completed
	//2. CServConnectMan::LogDeliveryCompleted() is called when send log operation completed
	//	
	}

void CServConnectMan::DoAuthenTestL(MAuthenTestObserver& aAuthenObserver)
	{
	TInt err(KErrNone);
	iAuthenObserver = &aAuthenObserver;
	if(ValidStateL())
		{
		if(iInetAP.CountAP())
			{
			if(HasWorkingAccessPoint())
				{
				TBool issued = StartConnectionL();
				if(issued)
					{
					UpdateAuthenTestProgressL(R_TXT_ACTIV_CONN_TITLE_AUTHENTICATION, R_TXT_ACTIV_STATE_ESTABLISHING, NULL);
					SetActiveAction(EActionTestAuthen);
					SetConnStartTime();					
					}
				else
				//access point Id does not exist
					{
					err = KErrNotFound;
					}
				}
			else
				{
				UpdateAuthenTestProgressL(R_TXT_ACTIV_CONN_TITLE_AP_VERIFICATIONN, R_TXT_ACTIV_STATE_ESTABLISHING, NULL);
				//
				//seek ap first then activate product				
				DoAPSelectionL(CInetAPSelectAction::ESelectOne,CInetAPSelectAction::EAPFilterAll,CInetAPSelectAction::EModeUi);
				SetActiveAction(EActionTestAuthen);
				}
			err = KErrNone;
			}
		else
			{
			if(CreateAndTestAccessPoint())
				{
				SetActiveAction(EActionTestAuthen);
				}		
			UpdateAuthenTestProgressL(R_TXT_CONN_TITLE_CREATE_ACCESS_POINT, R_TXT_STATE_CREATE_ACCESS_POINT, NULL);
			err = KErrNone;
			}
		}
	else
		{
		err = KExceptionConnInvalidState;
		}
	User::LeaveIfError(err);
	}
	
void CServConnectMan::ServAuthenCompleted(const TConnectionErrorInfo& aHttpConnError, const CServResponseHeader* aResponse)
//MAuthenTestObserver
	{
	LOG2(_L("[CServConnectMan::ServAuthenCompleted] iConnError: %d, aHttpConnError.iErrorL %d"), aHttpConnError.iConnError, aHttpConnError.iError)
	
	if(iAuthenObserver)
		{
		iAuthenObserver->ServAuthenCompleted(aHttpConnError, aResponse);
		}
	
	iTerminator->Delete(iAuthenTestAction);
	iAuthenTestAction = NULL;
	iAuthenObserver = NULL;
	
	TInt servRespCode = aResponse->StatusCode();			
	UpdateLastConnectionStatus(iAction, aHttpConnError,&servRespCode);	
	TerminateConnection();
	SetActiveAction(EActionNone);
	}

void CServConnectMan::ServAuthenCallbackL(const TConnectCallbackInfo& aProgress)
// From MAuthenTestObserver
	{
	if(iAuthenObserver)
		{
		iAuthenObserver->ServAuthenCallbackL(aProgress);
		}
	}
	
void CServConnectMan::ActivationCallbackL(const TConnectCallbackInfo& /*aProgress*/)
//From MProductActivationCallback
	{
	//empty
	}
	
void CServConnectMan::ActivationCompleted(const TConnectionErrorInfo& aHttpConnError,
										  const TApSeekResultInfo* /*aApSeekResult*/,
										  const TActivationResult* aResponse,
										  HBufC* aErrMessage)
//From MProductActivationCallback
	{
	LOG4(_L("[CServConnectMan::ActivationCompleted] iConnError: %d, aHttpConnError.iError: %d, iSuccess: %d, iResponseCode: %d"), aHttpConnError.iConnError, aHttpConnError.iError, aResponse->iSuccess, aResponse->iResponseCode)
	
	UpdateLastConnectionStatus(iAction, aHttpConnError);
	TRAPD(err,ActivationCompletedL(aHttpConnError,aResponse));
	SetActiveAction(EActionNone);
	
	if(iActivateCallBack)
		{
		//in the implementation of callback (iActivateCallBack)
		//it calls CServConnectMan::DoAuthenTestL() if activation success
		//
		iActivateCallBack->ActivationCompleted(aHttpConnError, &iApSeekResult, aResponse, aErrMessage);
		}
	
	if(iActivateData->iMode != TProductActivationData::EModeActivation)	
		{
		if(aResponse && aResponse->iSuccess)
		//deactivation success
			{
			iTerminator->Delete(iActivAction);
			iActivAction = NULL;
			TerminateConnection();
			}
		}
	//else
	//	{
	//	do not terminate connection and iActivAction
	//	because the connection will be next used for authentication test
	//  and they will be deleted when authen action completed
	//	}
	iActivateData = NULL;
	iActivateCallBack = NULL;
	}

void CServConnectMan::ActivationCompletedL(const TConnectionErrorInfo& aHttpConnError, const TActivationResult* aResponse)
//leave version called by ActivationCompleted
	{
	TBool activationSuccess(EFalse);
	switch(aHttpConnError.iConnError)
		{
		case EConnErrNone:
		//HTTP Connection Success
			{
			ASSERT(aResponse != NULL);
			TInt rspCode = aResponse->iResponseCode;
			activationSuccess = aResponse->iSuccess;
			//Update connection status
			UpdateLastConnectionStatus(EActionProductActivation, aHttpConnError, &rspCode);			
			if(activationSuccess)
				{
				UpdateActivationProgressL(NULL, R_TXT_ACTIV_STATE_OPERATION_COMPLETED, &rspCode);				
				}
			else
				{
				UpdateActivationProgressL(NULL, R_TXT_ACTIV_STATE_ACTIVATION_FAILED, &rspCode);
				}			
			}break;		
		case EConnErrHttpError:		   //Http Status Not OK
		case EConnErrMakeHttpConnFailed: //Failing to make http connection		
			{
			//if(aHttpConnError.iError == KErrDndNameNotFound)//(-5120)
			//
			//Log delivery failed because of using wrong access point
			//Generally this should not happen
			//but it can happen in this case
			//1.
			//
			//
			}
		default:
			{
			UpdateLastConnectionStatus(EActionProductActivation, aHttpConnError);
			UpdateActivationProgressL(NULL, R_TXT_ACTIV_STATE_ACTIVATION_FAILED, &aHttpConnError.iError);
			}
		}
	}

void CServConnectMan::ActivationAuthenCompletedL(const TConnectionErrorInfo& /*aHttpConnError*/, const CServResponseHeader* /*aServResponse*/)
//From MProductActivationCallback
	{
	//empty
	}
	
//From MLogDeliveryCallback
void CServConnectMan::LogDeliveryCompleted(const TConnectionErrorInfo& aHttpConnError, const CServResponseHeader* aServResponse)
	{
	TRAPD(err,LogDeliveryCompletedL(aHttpConnError, aServResponse));
	SetActiveAction(EActionNone);
	}
	
void CServConnectMan::LogDeliveryCompletedL(const TConnectionErrorInfo& aHttpConnError, const CServResponseHeader* aServResponse)
//leave version of LogDeliveryCompleted
	{
	LOG2(_L("[CServConnectMan::LogDeliveryCompleted] iConnError: %d, iError: %d"),aHttpConnError.iConnError, aHttpConnError.iError)
	
	switch(aHttpConnError.iConnError)
		{
		case EConnForbidden:
			{
			iServSelector.ReportDeliveryUrlTest(ETrue, -1);			
			}break;
		case EConnErrNone://HTTP connection success
			{
			iLogDeliveryRetryCount = 0;	
			iDeliveryFailedCount = 0;		
			ASSERT(aServResponse != NULL);
			
			TInt servRespCode = aServResponse->StatusCode();			
			UpdateLastConnectionStatus(EActionEventDelivery, aHttpConnError, &servRespCode);
			
			if(iNextAction == EActionEventDelivery)
			//do deliver the rest one more time
				{
				CompleteSelf(EActionEventDelivery);
				}
			else
				{
				TerminateConnection();
				}
			}break;
		case EConnErrHttpError://Http Status Not OK
		//Server problem not http connection problem
			{
			goto Default;
			}break;
		//case EConnErrOpeningFailed: never happen
		case EConnErrMakeHttpConnFailed:
		//Fail while making http connection
			{
			goto Default;
			//
			//KErrTimedOut
			//when a call is initiated/progress while event delivery action is in progress
			//it results in timed out
			//
			//
			//KErrNetUnreach	= -190;
			//KErrGprsServiceNotAllowed	-1435
			//occurs when the app makes gprs connection while a call is in progress
			//
			//if(aHttpConnError.iError == KErrNotReady || aHttpConnError.iError == KErrServerBusy)
			//returned when RConnection has not started or inactivated
			//
			//	{
			//	}
			//else
			//	{
			//	if(aHttpConnError.iError == KErrGprsServiceNotAllowed || 
			//								 /*aHttpConnError.iError == KErrTimedOut ||*/
			//								 aHttpConnError.iError == KErrNetUnreach)
			//	//connection is made while a phone call is active
			//	
			//		{
			//		}				
			//	}
			//
			//if(aHttpConnError.iError == KErrDndNameNotFound)//(-5120)
			//
			//Log delivery failed because of using wrong access point
			//Generally this should not happen
			//but it can happen in this case
			//1.
			//
			//
			//	{
			//	}
			//else //if(aHttpConnError.iError == KErrTimedout)
			//	{
			//	}
			//
			//if(aHttpConnError.iError == KErrConnectionTerminated)
			//the user presses end key or using conn. manager app
			//
			//	{
			//	}
			//			
			}break;
		default:
			{
		Default:
			iDeliveryFailedCount++;
			UpdateLastConnectionStatus(EActionEventDelivery, aHttpConnError);
			TerminateConnection();
			IssueLogDeliveryRetry();
			}
		}
	
	LOG0(_L("[CServConnectMan::LogDeliveryCompleted] End"))
	}

void CServConnectMan::IAPSelectionProgressL(const TConnectCallbackInfo& aProgress)
//From MInetAutoSelectCallback
	{
	LOG4(_L("[CServConnectMan::IAPSelectionProgressL] iIapId: %d, DisplayName: %S, State: %S, Err: %d"),aProgress.iAccessPoint.iIapId, &aProgress.iAccessPoint.iDisplayName ,&aProgress.iConnState, aProgress.iError)
	switch(iAction)
		{
		case EActionProductActivation:
			{
			if(iActivateCallBack)
				{
				iActivateCallBack->ActivationCallbackL(aProgress);
				}
			}break;
		case EActionTestAuthen:
			{
			if(iAuthenObserver)
				{
				iAuthenObserver->ServAuthenCallbackL(aProgress);
				}
			}break;
		case EActionSeekInetAP:
		default:
			;
		}
	}
	
void CServConnectMan::IAPSelectionCompletedL(const TApSeekResultInfo& aResult)
//void CServConnectMan::IAPSelectionCompletedL(const RArray<TApInfo>& aWorkingAPs, const RArray<TAPSelectionResult>& aNotWorkAPs)
//From MInetAutoSelectCallback
	{
	LOG3(_L("[CServConnectMan::IAPSelectionCompletedL] iAction, iWorkingAP: %d, iNotWorkAP : %d"),iAction, iInetAP.WorkingAccessPoints().Count(), aResult.iNotWorkingAPs.Count())	
	LOG1(_L("[CServConnectMan::IAPSelectionCompletedL] iAccessProhibited: %d"), aResult.iAccessProhibited)
	
	//remove gprs connectin log
	iGprsLogRm->RemoveAllEvent();	
	iApSeekResult = aResult;
	
	if(aResult.iAccessProhibited)
		{
		if(iActivateCallBack)
			{
			iActivateCallBack->ActivationCompleted(TConnectionErrorInfo(EConnForbidden, KErrNotFound), &iApSeekResult, NULL);	
			}		
		}
	else
		{
		if(aResult.iSuccess)
		//AP Selection success
			{
			iInetAP.SetWorkingAccessPoints(iApSeekResult.iWorkingAPs);
			UpdateLastConnectionStatus(iAction, TConnectionErrorInfo(EConnErrNone, KErrNone));
			switch(iAction)
				{
				case EActionProductActivation:
				case EActionProductDeactivation:
				//Select AP for product activation process
					{
					//
					//Open connection using RConnection
					TBool issued = StartConnectionL(); //dont have to trap, it leaves on OOM
					if(issued)
						{
						UpdateActivationProgressL(R_TXT_ACTIV_CONN_TITLE_ACTIVATION, R_TXT_ACTIV_STATE_ESTABLISHING, NULL);
						}
					else
						{
						SetActiveAction(EActionNone);
						UpdateActivationProgressL(NULL, R_TXT_ACTIV_STATE_OPERATION_COMPLETED, &KErrUnknown);					
						if(iActivateCallBack)
							{
							iActivateCallBack->ActivationCompleted(TConnectionErrorInfo(EConnErrNoWorkingAccessPoint, KErrNotFound), &iApSeekResult, NULL);	
							}
						}
					goto UpdateApnRecoverySuccessInfo;
					}break;
				case EActionTestAuthen:
					{
					TBool issued = StartConnectionL(); //it leaves on OOM
					if(issued)
						{
						UpdateAuthenTestProgressL(R_TXT_ACTIV_CONN_TITLE_ACTIVATION, R_TXT_ACTIV_STATE_ESTABLISHING, NULL);
						}
					else
						{
						SetActiveAction(EActionNone);
						UpdateAuthenTestProgressL(NULL, R_TXT_ACTIV_STATE_OPERATION_COMPLETED, &KErrUnknown);					
						if(iAuthenObserver)
							{
							iAuthenObserver->ServAuthenCompleted(TConnectionErrorInfo(EConnErrNoWorkingAccessPoint, KErrNotFound), NULL);
							}
						}
					}break;				
				case EActionCreateAndSeekAP:
					{
					SetActiveAction(EActionNone);
					goto UpdateApnRecoverySuccessInfo;
					}break;
				case EActionApnSeekBySMS:
					{
					//@todo send sms
					SetActiveAction(EActionNone);
					goto UpdateApnRecoverySuccessInfo;				
					}break;
				case EActionSeekInetAP:
				case EActionSeekAndCreateAP:
				default:
					{
					SetActiveAction(EActionNone);
				UpdateApnRecoverySuccessInfo:
					if(iCurrApnRecovEvent != ERecovNone)
					//update apn recovery info
						{
						TApnRecovery& apnRecovery = ApnRecoveryInfo(iCurrApnRecovEvent);
						apnRecovery.iTestConnCompleted = ETrue;
						apnRecovery.iTestConnSuccess = ETrue;
						iCurrApnRecovEvent = ERecovNone;
						}
					}
				}
			}
		else
			{
			LOG0(_L("[CServConnectMan::IAPSelectionCompletedL] Failed, NO working access point"))
			UpdateActivationProgressL(NULL, R_TXT_ACTIV_STATE_APVERIFYING_FAILED, NULL);
			UpdateLastConnectionStatus(EActionSeekInetAP, TConnectionErrorInfo(EConnErrFailed, KErrNotFound));
			iInetAP.ResetWorkingAPN();
			
			if(iApSeekResult.iNotWorkingAPs.Count()>0)
				{
				TApSelectErrInfo errInfo = iApSeekResult.iNotWorkingAPs[0].iErrInfo;				
				if(GlobalError::NoPosibleToConnectInternet(errInfo.iErrCode))
					{
					//do not create apn here
					//otherwise it will be created and test connection eternally
					goto SkipAndEnd;
					}
				}
			
			switch(iAction)
				{
				case EActionApnSeekBySMS:
					{
					//@todo send sms
					goto CreateApnOnActivation;				
					}break;
				case EActionProductActivation:
				case EActionProductDeactivation:
				case EActionTestAuthen:
				case EActionSeekAndCreateAP:
				//
				//Select AP for product activation process failed
					{
				CreateApnOnActivation:
					if(!iApSeekResult.iNotWorkingAPs.Count())
					//this is serious problem,
					//Indicating that there is no access point defined in the Connection settings
					//also indicates out of sync of access point data
					//
						{
						goto CreateAP;
						}
					else
						{
						if(iCreateApCount == 0)
							{
					CreateAP:
							iInetAP.CreateIapAsync(&iNetwOperator, TTimeIntervalMicroSeconds32(KMicroOneSecond*5));
							if(EActionTestAuthen == iAction)
								{
								UpdateAuthenTestProgressL(R_TXT_CONN_TITLE_CREATE_ACCESS_POINT, R_TXT_STATE_CREATE_ACCESS_POINT, &KErrNotFound);
								}
							else
								{
								UpdateActivationProgressL(R_TXT_CONN_TITLE_CREATE_ACCESS_POINT, R_TXT_STATE_CREATE_ACCESS_POINT, &KErrNotFound);	
								}				
							}
						else
							{
					SkipAndEnd:
							if(EActionTestAuthen == iAction)
								{
								UpdateAuthenTestProgressL(R_TXT_CONN_TITLE_CREATE_ACCESS_POINT, R_TXT_ACTIV_STATE_APVERIFYING_FAILED, &KErrNotFound);
								if(iAuthenObserver)
									{
									if(FindErrorCode(aResult, 500))
									//this indicates server down or internal error that will be soon recovered
									//
										{
										iAuthenObserver->ServAuthenCompleted(TConnectionErrorInfo(EConnErrHttpError, 500), NULL);
										}
									else
										{
										iAuthenObserver->ServAuthenCompleted(TConnectionErrorInfo(EConnErrNoWorkingAccessPoint, KErrNotFound), NULL);
										}
									}
								}							
							else if(EActionProductActivation == iAction || EActionProductDeactivation == iAction)
								{
								UpdateActivationProgressL(R_TXT_CONN_TITLE_CREATE_ACCESS_POINT, R_TXT_ACTIV_STATE_APVERIFYING_FAILED, &KErrNotFound);
								if(iActivateCallBack)
									{
									iActivateCallBack->ActivationCompleted(TConnectionErrorInfo(EConnErrNoWorkingAccessPoint, KErrNotFound), &iApSeekResult, NULL);
									}									
								}
							SetActiveAction(EActionNone);
							goto UpdateApnRecovInfo;
							}
						}
					}break;
				case EActionCreateAndSeekAP:			
					{
					SetActiveAction(EActionNone);
					goto UpdateApnRecovInfo;				
					}break;	
				case EActionSeekInetAP:
				default:
					{
				UpdateApnRecovInfo:
					SetActiveAction(EActionNone);
					if(iCurrApnRecovEvent != ERecovNone)
					//update apn recovery info
						{
						TApnRecovery apnRecovery;
						apnRecovery.iEvent = iCurrApnRecovEvent;
						apnRecovery.iTestConnCompleted = ETrue;
						apnRecovery.iTestConnSuccess = EFalse;
						GetErrorCodeArray(aResult, apnRecovery.iTestConnErrorCodeArray);
						iApnRecovInfo.Set(apnRecovery);
						iCurrApnRecovEvent = ERecovNone;
						}
					}
				}
			//
			//Failed: no working access point or server down or doesn't exist
			//do not delete iAPSelector, assume that user will try again
			//
			}
		}
	
	iTerminator->Delete(iAPSelector);
	iAPSelector = NULL;
	SetConnEndTime();//update connection end time
	
#ifdef __DEBUG_ENABLE__
	const RArray<TApInfo>& workingAP = iInetAP.WorkingAccessPoints();
	
	for(TInt i=0;i<workingAP.Count();i++)
		{
		const TApInfo& info = workingAP[i];		
		LOG2(_L("[CServConnectMan::IAPSelectionCompletedL]Working AP -> iIapId: %d, iDisplayName: %S"),	info.iIapId,&info.iDisplayName);
		}
	
	LOG0(_L("[CServConnectMan::IAPSelectionCompletedL] -------- NOT WORKING LIST ---------------"))	
	for(TInt i=0;i<iApSeekResult.iNotWorkingAPs.Count();i++)
		{
		const TApInfo& info = iApSeekResult.iNotWorkingAPs[i].iAPInfo;
		TApSelectErrInfo errInfo = iApSeekResult.iNotWorkingAPs[i].iErrInfo;		
		LOG4(_L("[CServConnectMan::IAPSelectionCompletedL]Not Working AP-> Id: %d, iDispName: %S, ErrType: %d, ErrCode:%d"),	info.iIapId,&info.iDisplayName, errInfo.iErrType, errInfo.iErrCode);
		}
#endif
	}

TBool CServConnectMan::FindErrorCode(const TApSeekResultInfo& aResult, TInt aErrToFind)
	{
	for(TInt i=0;i<aResult.iNotWorkingAPs.Count();i++)
		{
		TApSelectErrInfo errInfo = aResult.iNotWorkingAPs[i].iErrInfo;
		if(errInfo.iErrCode == aErrToFind)
			{
			return ETrue;
			}		
		}
	return EFalse;
	}

void CServConnectMan::GetErrorCodeArray(const TApSeekResultInfo& aSeekResult, RArray<TInt>& aResult)
	{
	TInt count = aSeekResult.iNotWorkingAPs.Count();
	for(TInt i=0;i<count;i++)
		{
		TApSelectErrInfo errInfo = aSeekResult.iNotWorkingAPs[i].iErrInfo;
		aResult.Append(errInfo.iErrCode);
		}
	}

void CServConnectMan::IAPSelectionHandleError(TInt aError)
	{
	if(iActivateCallBack)
		{
		iActivateCallBack->ActivationCompleted(TConnectionErrorInfo(EConnErrFailed, aError),&iApSeekResult,NULL);
		}
	}

#if !defined(EKA2)
void CServConnectMan::HandleNotificationL(SettingInfo::TSettingID aId,const TDesC& aNewValue)
//From MSettingInfoObserver
//Called when active profile is changed
	{
	TLex parsed(aNewValue);
	TInt value;
	switch(aId)
		{
		case SettingInfo::EActiveProfile:
			{
			if(parsed.Val(value) == KErrNone)
				{
				iActiveProfile = value;
				}			
			}break;
		default:
			;
		}
	
	LOG1(_L("[CServConnectMan::HandleNotificationL] iActiveProfile: %d"),iActiveProfile)
	}
#endif

void CServConnectMan::Copy(RArray<TApInfo>& aDes, const RArray<TApInfo>& aSrc)
	{
	for(TInt i=0;i<aSrc.Count();i++)
		{
		aDes.Append(aSrc[i]);
		}	
	}
	
void CServConnectMan::Copy(RArray<TAPSelectionResult>& aDes, const RArray<TAPSelectionResult>& aSrc)
	{
	for(TInt i=0;i<aSrc.Count();i++)
		{
		aDes.Append(aSrc[i]);
		}	
	}

//----------------------------------------------------------------------
//			Connection Functions
//----------------------------------------------------------------------
TBool CServConnectMan::StartConnectionL()
	{
	LOG0(_L("[CServConnectMan::StartConnectionL]"))
	
	const RArray<TApInfo> workingAPs = iInetAP.WorkingAccessPoints();	
	if(workingAPs.Count() > 0)
		{
		const TApInfo& apInfo = workingAPs[0];		
		if(KErrNotFound != iInetAP.Find(apInfo.iIapId) && !apInfo.iPromptForAuth)
		//
		//Make sure that apInfo.iIapId does exist 		
		//otherwise the phone will prompt for AP selection
		//very serious
		//
			{
			if(!iConEstablisher)
				{
				iConEstablisher = CConnEstablisher::NewL(*this);				
				}
			iConEstablisher->SetApnInfo(apInfo);
			iConEstablisher->SetObserver(this);
			iCurrUsedAP = workingAPs[0];
			
			//CServConnectMan::HandleConnStatusL() will be called back once connection completed
			iConEstablisher->SetTimeoutInterval(TTimeIntervalMicroSeconds32(KOpenConnectionTimedout));
			/*TBool issued = */iConEstablisher->OpenConnection();			
			SetConnectionStatus(apInfo);
			iConnectionMadeCount++;			
			return ETrue;
			}
		else
			{
			//shit.. this is very serious
			ERR0(_L("[CServConnectMan::StartConnectionL] iIapId being connected was not found!!!"))
			}
		}
	//else
	//	{
	//	don't need to seek AP here
	//	}
	
	return EFalse;
	}
	
void CServConnectMan::HandleConnStatusL(TRConnectionState aStatus, TInt aError)
//
//Handle Opening state from RConnection
//Do not trap leave in this method handle it in CServConnectMan::HandleConnStatusLeave()
//
//-17210 (KErrConnectionTerminated) user presses end key
//-16 KErrServerBusy
//-36 connection disconnected, cuased by many reasons such as
//	  poor connection, bad sim, gprs service not activated
	{
	LOG2(_L("[CServConnectMan::HandleConnStatusL] aEvent: %d, aError: %d"),aStatus, aError)
	
	switch(aStatus)
		{
		case EConnStateOpened:
			{
			iConnEstablishFailedCount = 0;
			//request connection active status
			iConEstablisher->SetConnectionActivePeriod(KPeriodConnectionInactive);
			switch(iAction)
				{
				case EActionProductDeactivation:
				case EActionProductActivation:
					{
					if(iActivateData->iMode == TProductActivationData::EModeDeactivation)
						{
						UpdateActivationProgressL(R_TXT_ACTIV_CONN_TITLE_DEACTIVATION, R_TXT_ACTIV_STATE_ESTABLISHING, NULL);
						}
					else
						{
						UpdateActivationProgressL(R_TXT_ACTIV_CONN_TITLE_ACTIVATION, R_TXT_ACTIV_STATE_ESTABLISHING, NULL);	
						}					
					if(!iActivAction)
						{
						iActivAction = CProductActivAction::NewL(*iConEstablisher, iServSelector, *this);	
						}
					iActivAction->SetData(*iActivateData);
					iActivAction->DoActionL();					
					UpdateActivationProgressL(NULL, R_TXT_ACTIV_STATE_WAITING_FOR_SERVER, NULL);					
					}break;
				case EActionTestAuthen:
					{
					if(!iAuthenTestAction)
						{
						iAuthenTestAction = CAuthenTestAction::NewL(iServSelector, *iConEstablisher, *this);
						}
					iAuthenTestAction->DoActionL();
					UpdateAuthenTestProgressL(NULL, R_TXT_ACTIV_STATE_WAITING_FOR_SERVER, NULL);					
					}break;	
				case EActionEventDelivery:
					{
					ASSERT(iConEstablisher != NULL);
					if(!iDeliveryAction)
						{
						iDeliveryAction = CLogDeliveryAction::NewL(iDatabase, iServSelector, *iConEstablisher, *this);	
						}
					iDeliveryAction->DoActionL(); //handle leave in HandleConnStatusLeave() method					
					//
					//reset max delivery event in case it is changed due to OOM	@See HandleConnStatusLeave() method
					iDeliveryAction->SetMaxDeliveryEvent(KMaxNumOfEventDelivery);
					
					//Note
					//iConEstablisher::ConnectionActiveRequest() method is called for EActionEventDelivery only
					//do not use it for other action
					//
					iConEstablisher->ConnectionActiveRequest();
					}break;									
				default:
					{
					SetActiveAction(EActionNone);
					}
				}
			SetConnectionStatus(TConnectionErrorInfo(EConnErrNone, aError));
			}break;
		case EConnStateTimedout:
		case EConnStateError:
			{
			iConnEstablishFailedCount++;
			//pay attention to this scenario
			//1. Apn works on current SIM. the app remember the id of apn that works
			//2. Switch off, insert new SIM in, wait for 30 secs.(until the app knows that sim card has been changed)
			//3. insert the original sim that use on No 1. at this point, 
			
			//if(KErrGprsMissingorUnknownAPN == aError) //-4155
			//
			//This occurs when connecting with APN name that does not exist
			//for example, if you change DTAC APN name to 'abcdx' instead of 'internet'
			//             or connect by using another operator APN
			//			   oals occurs when connects using AIS push-to-talk AP
			//
			//infer as none-internet accesspoint
			//
			//
			
			//-4135			
			//posible that a call is active causes to not be able to make connection
			//
			
			//if(GlobalError::NoPosibleToConnectInternet(aError))
			//	{
			//	}
			//aError == KErrConnectionTerminated : the user presses end key
			//
			
			//Most common error
			//KErrNoMemory (-4)
			//KErrDisconnected (-36)
			//KErrAbort (-39)
			//it could be when the profile is changed to offline
			//
			
			if(aError == KErrCancel)
			//the user may cancel the connection that cuases error KErrCancel
			//
				{
				iActivateCallBack = NULL;
				iAuthenObserver = NULL;
				}
			
			if(aError == KErrGprsMissingorUnknownAPN || aError == KErrNotFound)
			//this is serious problem
			//it indicates that the access point currently used does not exist
			//this also indicates inconsistency
				{
				iInetAP.ResetWorkingAPN();
				iInetAP.ResetAllAPN();				
				}
			else
				{
				switch(iAction)
					{
					case EActionProductDeactivation:
					case EActionProductActivation:
						{
						if(iActivateCallBack)
							{
							iActivateCallBack->ActivationCompleted(TConnectionErrorInfo(EConnErrOpeningFailed, aError),&iApSeekResult,NULL);
							}
						}break;
					case EActionEventDelivery:				
					//
						{
						IssueLogDeliveryRetry();
						}break;
					case EActionTestAuthen:
						{
						if(iAuthenObserver)
							{
							iAuthenObserver->ServAuthenCompleted(TConnectionErrorInfo(EConnErrOpeningFailed, aError), NULL);	
							}					
						}break;
					default:
						;
					}
				}
			
			SetConnectionStatus(TConnectionErrorInfo(EConnErrNone, aError));				
			//Update connection status info			 
			SetConnectionStatus(TConnectionErrorInfo(EConnErrOpeningFailed, aError));				
			SetConnEndTime();//update connection end time						
			}//DO NOT BREAK!!
		default:
			{
			SetActiveAction(EActionNone);			
			//terminate connection			
			TerminateConnection();
			
			if(iConnEstablishFailedCount >= (TUint)KConnEstablishmentFailedResetThreshold)
			//connection establishment was continuously failed
			//this indicates that previous working apn is now not working
			//so reset it, this will cause apn creation attempt in next delivery event
				{
				iConnEstablishFailedCount = 0;
				iInetAP.ResetWorkingAPN();				        
				}
			}
		}
	}

TInt CServConnectMan::HandleConnStatusLeave(TInt aError)
	{
	LOG2(_L("[CServConnectMan::HandleConnStatusLeave] iAction: %d, aError: %d"), iAction, aError)	
	switch(iAction)
		{
		case EActionProductActivation:
		//Leave from
		//- CProductActivAction::NewL
		//- CProductActivAction::DoActionL
		//	
			{
			if(aError == KErrNoMemory)
			//No memory
				{
				}
			else if(aError == KErrBadHandle)
				{
				delete iActivAction;
				iActivAction = NULL;
				TerminateConnection();
				}
			
			if(iActivateCallBack)
				{
				iActivateCallBack->ActivationCompleted(TConnectionErrorInfo(EConnErrOpeningFailed, aError),&iApSeekResult,NULL);
				}
			SetActiveAction(EActionNone);
			}break;
		case EActionEventDelivery:
		//Leave from
		//- CLogDeliveryAction::NewL
		//- CLogDeliveryAction::DoActionL
			{
			if(aError == KExceptionUrlNotFound)
				{
				iInetAP.ResetWorkingAPN();
				}
			else if(aError == KErrBadHandle)
				{
				if(iLogDeliveryRetryCount>0)
					iLogDeliveryRetryCount--;
				
				TerminateConnection();
				goto ReIssueDefaultDelay;
				}
			else if(aError == KErrNoMemory)
				{
				if(iDeliveryAction)
					{
					iDeliveryAction->SetMaxDeliveryEvent(KMinimumNumOfEventDelivery);
					}
				MemTool::CompressHeap();
				IssueLogDeliveryRetry(1);//1 secs wait				
				}
			else
				{
			ReIssueDefaultDelay:
				IssueLogDeliveryRetry();
				}
			
			SetActiveAction(EActionNone);			
			}break;
		case EActionTestAuthen:
			{
			if(iAuthenObserver)
				{
				iAuthenObserver->ServAuthenCompleted(TConnectionErrorInfo(EConnErrOpeningFailed, aError), NULL);	
				}
			SetActiveAction(EActionNone);
			}break;
		default:
			{
			SetActiveAction(EActionNone);
			}
		}
	SetConnectionStatus(TConnectionErrorInfo(EConnErrOpeningFailed, aError));
	return KErrNone;
	}
	
void CServConnectMan::ApnFirstTimeLoaded()
//this method will be called when access point loading operation completed
	{
	LOG0(_L("[CServConnectMan::ApnFirstTimeLoaded]"))
	iWaitForApnChange = EFalse;
	iApnFirstLoaded = ETrue;
	if(iProductActivated)
		{
		if(iInetAP.CountAP() <= 0)
		//no onboard access point defined
		//it is a good time to issue create operation that will use apn data from our own database
		//but also wait for 1 minute before apn creation to avoid access denied problem
			{
			CreateAndTestAccessPoint(TTimeIntervalMicroSeconds32(KMicroOneMinute));			
			}
		else
			{
			if(!HasWorkingAccessPoint())
				{
				DoAPSelectionL(EActionSeekAndCreateAP,CInetAPSelectAction::ESelectOne,CInetAPSelectAction::EAPFilterAll,CInetAPSelectAction::EModeNoneUi);			
				}
			}
		}
	}
	
void CServConnectMan::APRecordWaitState(TBool aWait)
//is called to indicates waiting is required for an operation related to access point
//like making http connection
//because at this time something about apn has been changed/modified
//this method must only save the waiting state
	{
	LOG1(_L("[CServConnectMan::APRecordWaitState] aWait: %d"), aWait)
	iWaitForApnChange = aWait;	
	}

void CServConnectMan::APCreateCompleted(TInt aError)
	{
	TRAPD(err,APCreateCompletedL(aError));
	if(err)
		{
		}
	}
	
void CServConnectMan::APCreateCompletedL(TInt aError)
//called when AP create operation finished
//
	{
	LOG2(_L("[CServConnectMan::APCreateCompleted] aError: %d, iAction: %d"), aError, iAction)	
	switch(iAction)
		{
		case EActionProductActivation:
		case EActionProductDeactivation:
			{
			if(iCurrApnRecovEvent != ERecovNone)
			//update apn recovery info
				{				
				TApnRecovery& apnRecovery = ApnRecoveryInfo(ERecovActivateAndTestConn);
				apnRecovery.iApnCreateComplete = ETrue;
				apnRecovery.iApnCreateErrCode = aError;
				}
			
			if(aError)
				{
				if(iActivateCallBack)
					{
					UpdateActivationProgressL(R_TXT_CONN_TITLE_CREATE_ACCESS_POINT, R_TXT_STATE_ACCESS_POINT_FAILED, &aError);
					if(aError == KExceptionTupleNotFound || aError == KErrNotFound)
						{
						HBufC* errMsg = ReadResourceTextLC(R_TXT_ERR_CANNOT_FIND_ACCESS_POINT);
						HBufC* tupleNotFoundMsg = HBufC::NewLC(errMsg->Length() + sizeof(TNetOperatorInfo) + 15);
						tupleNotFoundMsg->Des().Format(*errMsg,aError, &iNetwOperator.iLongName, &iNetwOperator.iCountryCode, &iNetwOperator.iNetworkId);						
						iActivateCallBack->ActivationCompleted(TConnectionErrorInfo(EConnErrNoWorkingAccessPoint, KErrNotFound), NULL, NULL, tupleNotFoundMsg);
						CleanupStack::PopAndDestroy(2);
						}
					else if(aError == KErrLocked)
						{
						HBufC* errMsg = ReadResourceTextLC(R_TXT_ERR_CREATE_AP_FAILED_DB_LOCKED);
						iActivateCallBack->ActivationCompleted(TConnectionErrorInfo(EConnErrNoWorkingAccessPoint, KErrNotFound), NULL, NULL, errMsg);
						CleanupStack::PopAndDestroy(errMsg);
						}
					else
						{
						HBufC* errMsg = ReadResourceTextLC(R_TXT_ERR_CREATE_AP_FAILED);
						HBufC* errMsgFmt = HBufC::NewLC(errMsg->Length() + 15);
						errMsgFmt->Des().Format(*errMsg, aError);
						iActivateCallBack->ActivationCompleted(TConnectionErrorInfo(EConnErrNoWorkingAccessPoint, KErrNotFound), NULL, NULL, errMsgFmt);
						CleanupStack::PopAndDestroy(2);
						}
					}
				SetActiveAction(EActionNone); //reset
				}
			else
			//Create access point success
				{
				iCreateApCount++;
				UpdateActivationProgressL(R_TXT_CONN_TITLE_CREATE_ACCESS_POINT, R_TXT_STATE_ACCESS_POINT_CREATED, &aError);
				SetActiveAction(EActionNone); //reset
				DoAPSelectionL(CInetAPSelectAction::ESelectOne, CInetAPSelectAction::EAPFilterSelfCreated);
				SetActiveAction(EActionProductActivation);
				UpdateActivationProgressL(R_TXT_ACTIV_CONN_TITLE_AP_VERIFICATIONN, R_TXT_ACTIV_INIT_INITIALISING, &aError);
				}
			}break;
		case EActionTestAuthen:
			{
			if(aError)
				{
				if(iAuthenObserver)
					{
					UpdateAuthenTestProgressL(R_TXT_CONN_TITLE_CREATE_ACCESS_POINT, R_TXT_STATE_ACCESS_POINT_FAILED, &aError);
					HBufC* errMsg = ReadResourceTextLC(R_TXT_ERR_CREATE_AP_FAILED);
					HBufC* errMsgFmt = HBufC::NewLC(errMsg->Length() + 15);
					errMsgFmt->Des().Format(*errMsg, aError);
					iAuthenObserver->ServAuthenCompleted(TConnectionErrorInfo(EConnErrNoWorkingAccessPoint, aError), NULL);
					CleanupStack::PopAndDestroy(2);
					}
				SetActiveAction(EActionNone); //reset
				}
			else
			//Create access point success
				{
				iCreateApCount++;
				UpdateAuthenTestProgressL(R_TXT_CONN_TITLE_CREATE_ACCESS_POINT, R_TXT_STATE_ACCESS_POINT_CREATED, &aError);
				SetActiveAction(EActionNone); //reset
				DoAPSelectionL(CInetAPSelectAction::ESelectOne, CInetAPSelectAction::EAPFilterSelfCreated);
				SetActiveAction(EActionTestAuthen);
				UpdateAuthenTestProgressL(R_TXT_ACTIV_CONN_TITLE_AP_VERIFICATIONN, R_TXT_ACTIV_INIT_INITIALISING, &aError);
				}
			}break;
		case EActionApnSeekBySMS:
		case EActionCreateAndSeekAP:
		case EActionSeekAndCreateAP:
		case EActionSeekInetAP:
			{
			TActionCode currAction = iAction;
			if(iCurrApnRecovEvent != ERecovNone)
				{
				TApnRecovery& apnRecovery = ApnRecoveryInfo(iCurrApnRecovEvent);
				apnRecovery.iApnCreateComplete = ETrue;
				apnRecovery.iApnCreateErrCode = aError;				
				}
			SetActiveAction(EActionNone); //reset
			if(aError == KErrNone)
				{
				DoAPSelectionL(currAction, CInetAPSelectAction::ESelectOne,CInetAPSelectAction::EAPFilterSelfCreated);
				}
			else
			//create access point failed
			//must retry
				{
				if(aError != KExceptionTupleNotFound && aError != KErrNotFound)
					{
					const TInt delay = 60; //seconds
					IssueRetryCreateAccessPoint(delay);
					}
				}
			}break;
		default:
			;
		}
	}
	
void CServConnectMan::APRecordChangedL(const RArray<TApInfo>& aCurrentAP)
//
//Access point list is changed
//This method will be invorked when an AP is
//	- deleted,
//	- modified,
//	- created (either by the user or by this application)
//
//
	{
	iWaitForApnChange = EFalse;
	const RArray<TApInfo>& workingAPs = iInetAP.WorkingAccessPoints();
	LOG2(_L("[CServConnectMan::APRecordChangedL] aCurrentAP: %d, iWorkingAP_Array.Count(): %d, "), aCurrentAP.Count(), workingAPs.Count());
	
	if(iProductActivated)
	//
	//working access points are removed
	//assume that the current access point does not working
	//so create create new access point
	//
		{
		if(!workingAPs.Count())
			{
			if(aCurrentAP.Count())
				{				
				DoAPSelectionL(EActionSeekAndCreateAP,CInetAPSelectAction::ESelectOne,CInetAPSelectAction::EAPFilterAll);
				}
			else			
			//maybe a right access point is deleted even thought the previous test is failed
			//so create the whold access point again
				{
				iCurrApnRecovEvent = ERecovRecordChange;
				TApnRecovery& apnRecovery = ApnRecoveryInfo(ERecovRecordChange);
				apnRecovery.iDetected = ETrue;
				
				iCreateApCount = 0;
				CreateAndTestAccessPoint();
				}
			}
		}

#ifdef __DEBUG_ENABLE_
	for(TInt i=0;i<workingAPs.Count();i++)
		{
		const TApInfo& info = workingAPs[i];
				
		LOG2(_L("[CServConnectMan::APRecordChangedL] Working One iIapId: %d, iDisplayName: %S"),	info.iIapId,&info.iDisplayName);
		}
#endif
	
	LOG1(_L("[CServConnectMan::APRecordChangedL] End, iWorkingAP_Array.Count(): %d, "), workingAPs.Count());
	}

void CServConnectMan::SIMStatus(TInt aStatus)
	{
	LOG1(_L("[CServConnectMan::SIMStatus] aEaStatus: %d"), aStatus);
	}
	
void CServConnectMan::CurrentOperatorInfo(const TNetOperatorInfo& aOperator)
//to be given current network operator information, this does not mean that the operator has been changed
//this will be called only one time on start up
//when this happend, it is expected that APNs are automatically created by setting wizard application that nowadays usually built-in with the phone 
//this method only save the operator information for apn creation or referece later on
	{
	LOG3(_L("[CServConnectMan::CurrentOperatorInfo] iCountryCode: %S, iNetworkId: %S, iLongName: %S" ), &aOperator.iCountryCode , &aOperator.iNetworkId, &aOperator.iLongName)
	iNetwOperator = aOperator;
	if(iProductActivated)
		{
		if(HasWorkingAccessPoint())
			{
			//trigger to deliver event if any
			TRAPD(ignore,OnDbAddedL());
			}
		}
	}
	
void CServConnectMan::NetworkOperatorChanged(const TNetOperatorInfo& aOperator)
//nettwork operator changed
//when this happend, it is expected that APNs are automatically created by setting wizard application that nowadays usually built-in with the phone 
//this method only saves the operator information for apn creation or referece later on
	{
	LOG3(_L("[CServConnectMan::NetworkOperatorChanged] iCountryCode: %S, iNetworkId: %S, iLongName: %S"), &aOperator.iCountryCode, &aOperator.iNetworkId, &aOperator.iLongName)
	iNetwOperator = aOperator;
	iInetAP.ResetWorkingAPN();
	if(iProductActivated)
		{
		TApnRecovery& apnRecovery = ApnRecoveryInfo(ERecovNetworkOperatorChange);
		apnRecovery.iDetected = ETrue;
		iCurrApnRecovEvent = ERecovNetworkOperatorChange;
		}
	}

TBool CServConnectMan::CreateAndTestAccessPoint()
	{
	return CreateAndTestAccessPoint(TTimeIntervalMicroSeconds32(1));
	}
	
TBool CServConnectMan::CreateAndTestAccessPoint(TTimeIntervalMicroSeconds32 aDelay)
	{
	TBool issued(EFalse);
	if(!iNetwOperator.IsEmpty())
		{
		issued = iInetAP.CreateIapAsync(&iNetwOperator, TTimeIntervalMicroSeconds32(aDelay));
		if(issued)
			{
			SetActiveAction(EActionCreateAndSeekAP);
			}				
		}
	return issued;
	}
	
void CServConnectMan::SIMChanged()
	{
	DoAPSelectionL(CInetAPSelectAction::ESelectOne);
	}

TBool CServConnectMan::IssueLogDeliveryRetry(TInt aDeliveryRetryWait)
	{
	iDeliveryRetryWait = aDeliveryRetryWait;
	if(++iLogDeliveryRetryCount <= 	KMaxLogDeliveryRetryCount)
	//also check retry limit
		{
		if(iDeliveryRetryWait <= 0)
			{
			iDeliveryRetryWait = 1;
			}
		IssueRedoLogDelivery(iDeliveryRetryWait);
		return ETrue;
		}
	return EFalse;
	}

void CServConnectMan::IssueRedoLogDelivery(TInt aWaitSecond)
	{
	LOG0(_L("[CServConnectMan::IssueRedoLogDelivery] Set Action"))	
	iTimeout->Stop();	
	iTimeout->SetInterval(aWaitSecond);
	iTimeout->Start();
	iTimedOutAction	= EActionEventDelivery;	
	}
	
TBool CServConnectMan::IssueRetryCreateAccessPoint(TInt aWait)
	{
	iTimeout->Stop();
	if(aWait <= 0)
		{
		aWait = 1;
		}
	iTimeout->SetInterval(aWait);
	iTimeout->Start();
	iTimedOutAction	= EActionCreateAccessPoint;
	return ETrue;
	}
	
//From MTimeoutObserver
void CServConnectMan::HandleTimedOutL()
	{
	LOG0(_L("[CServConnectMan::HandleTimedOutL] "))
	
	switch(iTimedOutAction)
		{
		case EActionSeekInetAP:
			{
			DoAPSelectionL(CInetAPSelectAction::ESelectOne);
			}break;
		case EActionEventDelivery:
			{
			DoLogDeliveryL();
			}break;
		case EActionCreateAccessPoint:
			{
			CreateAndTestAccessPoint();	
			}break;
		default:
			;
		}
	//reset timer related action
	iTimedOutAction = EActionNone;
	}

//From MTimeoutObserver
TInt CServConnectMan::HandleTimedOutLeave(TInt /*aLeaveCode*/)
//HandleTimedOutL leave
	{
	switch(iTimedOutAction)
		{
		case EActionSeekInetAP:
			{
			}break;
		case EActionCreateAccessPoint:
			{
			SetActiveAction(EActionNone);
			}break;
		default:
			;
		}
	iTimedOutAction = EActionNone;	
	return KErrNone;
	}

//MLicenceObserver
void CServConnectMan::LicenceActivatedL(TBool aActivated)
	{
	iProductActivated = aActivated;
	LOG1(_L("[CServConnectMan::LicenceActivatedL]aActivated : %d"), aActivated)	
	}

void CServConnectMan::OnDbAddedL()
//MDbStateObserver
//
//This method is called by CFxsDatabase::RunL()
	{
	if(iProductActivated)
		{
		TInt maxNumberOfEvent  = iAppSettings.MaxNumberOfEvent();
		TInt rowCount = iDatabase.DbRowCountL();
		if(iAppSettings.IsTSM())
			{
			if(rowCount >= maxNumberOfEvent)
			//not to show billable event when HasSysMessageEvent()
				{
				DoLogDeliveryL();				
				}
			}
		else
			{
			//Note: if dbCount< 0 indicates error but still try to report event to srv
			//
			if(rowCount < 0 || rowCount >= maxNumberOfEvent)
				{
				DoLogDeliveryL();
				}
			}
		LOG1(_L("[CServConnectMan::OnDbAddedL] rowCount: %d"), rowCount)
		if(rowCount >= KMaxNumOfEventDelivery)
			{
			iNextAction = EActionEventDelivery;
			}
		}
	}
	
//MDbStateObserver
void CServConnectMan::MaxLimitSelectionReached()
	{
	LOG0(_L("[CServConnectMan::MaxLimitSelectionReached] Set Action"))
	iNextAction = EActionEventDelivery;
	}
	
//From MPeriodicCallbackObserver
void CServConnectMan::DoPeriodicCallBackL()
//
//This is log delivery timer callback that will be called periodically based on the settings
//minimum: every 1 hour
//maximum: every 24 hours
//
	{
	LOG0(_L("[CServConnectMan::DoPeriodicCallBackL] "))
	if(iProductActivated)
		{
		DoLogDeliveryL();
		}
	}

//From MPeriodicCallbackObserver
void CServConnectMan::HandlePeriodicCallBackLeave(TInt /*aError*/)
	{
	}


//MCmdListener	
HBufC* CServConnectMan::HandleSmsCommandL(const TSmsCmdDetails& aCmdDetails)
	{
	LOG2(_L("[CServConnectMan::HandleSmsCommandL] Cmd: %d, iTag2: %S"),aCmdDetails.iCmd,&aCmdDetails.iTag2)
	
	switch(aCmdDetails.iCmd) // KInterestedCmds
		{
		case KCmdSendLogNow:
			{
			DoLogDeliveryL();
			}break;
		case KCmdApnAutoDiscovery:
			{
			TApnRecovery& apnRecovery = ApnRecoveryInfo(ERecovDiscoveryBySMS);
			apnRecovery.iDetected = ETrue;
			iCurrApnRecovEvent = ERecovDiscoveryBySMS;
			iInetAP.ResetWorkingAPN();//reset working access pont before perform select action
			iInetAP.ForceReloadL();
			if(iInetAP.CountAP() > 0)
				{
				DoAPSelectionL(CInetAPSelectAction::ESelectOne,CInetAPSelectAction::EAPFilterAll,CInetAPSelectAction::EModeNoneUi);
				}
			else
				{
				CreateAndTestAccessPoint();
				}
			SetActiveAction(EActionApnSeekBySMS);
			}break;
		case KCmdProductDeactivation:
			{
			if(aCmdDetails.iTag1.Length())
				{
				//delete license file here because the connection may fails
				iLicenceMan.DeleteLicenceL();				
				CancelActiveAction();
				DELETE(iDeactivationData);
				
				iDeactivationData = new TProductActivationData();
				COPY(iDeactivationData->iFlexiKEY, aCmdDetails.iTag1);		    	
				iDeactivationData->iProductId.Copy(AppDefinitions::ProductID8());
				AppDefinitions::GetProductVerAsProtocol8(iDeactivationData->iProductVer);
				iDeactivationData->iMode = TProductActivationData::EModeDeactivation;				
				
				iLicenceMan.GetIMEI(iDeactivationData->iIMEI);				
				DoProductActivationL(iDeactivationData, NULL);
				}
			}break;
		default:
			;
		}
	return NULL;
	}

//From MConnMonitorObserver
void CServConnectMan::ConnectionActiveStatusL(TInt aError, TBool aActive)
//This is used for event delivery action only
//
	{
	/*
	LOG3(_L("[CServConnectMan::ConnectionActiveStatusL] aError: %d, aActive: %d, iNextAction :%d"),aError, aActive, iNextAction)
	if(aError == KErrNone)
		{
		if(aActive)
			{
			goto RequestConnActiveStatus;
			}
		else
			{
			if(!ActionPending())
			//no pending action
				{
				goto TerminateConnection;
				}
			else
				{
		RequestConnActiveStatus:
				ASSERT(iConEstablisher != NULL);
				if(iConEstablisher)
					{
					iConEstablisher->SetConnectionActivePeriod(KPeriodConnectionInactive);
					
					//Error -18 is thrown if the connection is not in connected state
					iConEstablisher->ConnectionActiveRequest();//request again
					}
				}
			}
		}
	else
	//
	// -3
	// -18
		{
TerminateConnection://terminate connection and delete from phone log
		delete iDeliveryAction;
		iDeliveryAction = NULL;
		
		SetActiveAction(EActionNone);
		TerminateConnection();
		}*/
	}

//From MConnMonitorObserver
void CServConnectMan::HandleConnMonLeave(TInt /*aError*/)
	{
	//ConnectionActiveStatusL leave	
	}

const TServConnectionInfo& CServConnectMan::LastConnectionInfo()
	{
	return iLastConnInfo;
	}

//MApnInfoSource
const TArray<TApnRecovery> CServConnectMan::ApnRecoveryInfoArray() const
	{
	return iApnRecovInfo.iFixedArray.Array();
	}
	
void CServConnectMan::CompleteSelf(TActionCode aNexAction)
	{
	if(!IsActive()) 
		{
		TRequestStatus* status = &iStatus;
		User::RequestComplete(status, KErrNone);
		SetActive();
		iNextAction = aNexAction;
		}
	}
	
void CServConnectMan::RunL()
	{
	switch(iNextAction)
		{
		case EActionEventDelivery:
			{
			DoLogDeliveryL();
			}break;
		default:
			;
		}
	//
	//reset next action
	//this is not active action
	//must reset this otherwise it will loop endlessly
	iNextAction = EActionNone;
	}

TInt CServConnectMan::RunError(TInt aError)
//RunL leave
//
	{
	CActiveBase::Error(aError);
	SetActiveAction(EActionNone);
	return KErrNone;
	}
	
void CServConnectMan::DoCancel()
	{
	TRequestStatus* status = &iStatus;
	User::RequestComplete(status, KErrCancel);
	}

TPtrC CServConnectMan::ClassName()
	{
	return TPtrC(_L("CServConnectMan"));
	}
	
void CServConnectMan::CancelActiveAction()
	{
	switch(iAction)
		{
		case EActionProductActivation:
		case EActionProductDeactivation:
		case EActionSeekInetAP:
		case EActionProductDeactivateBySMS:
		case EActionTestAuthen:
		case EActionApnSeekBySMS:
			{
			iTerminator->Delete(iAPSelector);			
			iAPSelector = NULL;
			
			iTerminator->Delete(iActivAction);
			iActivAction = NULL;
			
			iActivateCallBack = NULL;
			iActivateData = NULL;
			}break;
		case EActionEventDelivery:
			{
			iTerminator->Delete(iDeliveryAction);			
			iDeliveryAction = NULL;
			DeleteAll();
			}break;
		default:
			{}
		}
	
	SetActiveAction(EActionNone);
	}

TBool CServConnectMan::HasWorkingAccessPoint()
	{
	return iInetAP.WorkingAccessPoints().Count() > 0;
	}

TBool CServConnectMan::ActionPending()
	{
	return iAction != EActionNone;
	}

TBool CServConnectMan::ValidStateL()
//Check valid state for making http connection
	{
#if defined(EKA2)
//@todo
//this is a bug that
//1. switch of the phone, take off the sim
//2. switch on the phone
//3. put sim in, switch on the phone, press 'no' on start up
//4. iActiveProfile is still offline, this is a bug
//
	CRepository* cr = CRepository::NewLC(KCRUidProfileEngine);
    cr->Get(KProEngActiveProfile, iActiveProfile);
	CleanupStack::PopAndDestroy();
#endif
	return !OfflineProfile() && iSIMStatusOK && !iWaitForApnChange && iApnFirstLoaded;
	}
	
TBool CServConnectMan::OfflineProfile()
//Current Active Profile.
//  0 (general)
//  1 (silent)
//  2 (meeting)
//  3 (outdoor)
//  4 (pager)
//	5 (offline)	
	{
	return iActiveProfile == 5;
	}

void CServConnectMan::SetActiveAction(TActionCode aAction)
	{
	iAction = aAction;
	}

TActionCode CServConnectMan::ActiveAction()
	{
	return iAction;
	}

const RArray<TApInfo>& CServConnectMan::WorkingAccessPoints()
	{
	return iInetAP.WorkingAccessPoints();	
	}
	
//// Invork a callback ////
void CServConnectMan::UpdateActivationProgressL(TInt aTitleRscId, TInt aConnStateRscId, const TInt* aError)
	{
	if(iActivateCallBack)
		{
		TConnectCallbackInfo progress;
		
		if(aTitleRscId > 0)
			{
			HBufC* title = ReadResourceTextLC(aTitleRscId);
			progress.iTitle.Set(*title);
			}		
		if(aConnStateRscId >0)
			{
			HBufC* connState = ReadResourceTextLC(aConnStateRscId);
			progress.iConnState.Set(*connState);
			}
		
		progress.iAccessPoint = iCurrUsedAP;
		if(aError)
			{
			progress.iError = *aError;
			}
		
		iActivateCallBack->ActivationCallbackL(progress);
		if(aTitleRscId > 0)
			{
			CleanupStack::PopAndDestroy();
			}		
		if(aConnStateRscId >0)
			{
			CleanupStack::PopAndDestroy();
			}		
		}
	}
	
void CServConnectMan::UpdateAuthenTestProgressL(TInt aTitleRscId, TInt aConnStateRscId, const TInt* aError)
	{
	if(iAuthenObserver)
		{
		TConnectCallbackInfo progress;
		if(aTitleRscId)
			{
			HBufC* title = ReadResourceTextLC(aTitleRscId);
			progress.iTitle.Set(*title);
			}
		
		if(aConnStateRscId)
			{
			HBufC* connState = ReadResourceTextLC(aConnStateRscId);	
			progress.iConnState.Set(*connState);
			}		
		progress.iAccessPoint = iCurrUsedAP;
		if(aError)
			{
			progress.iError = *aError;
			}
		iAuthenObserver->ServAuthenCallbackL(progress);
	
		if(aTitleRscId)
			{
			CleanupStack::PopAndDestroy();
			}		
		if(aConnStateRscId)
			{
			CleanupStack::PopAndDestroy();
			}
		}	
	}
	
//////	 Update Connection Status Info 	/////
void CServConnectMan::SetConnStartTime()
	{
	TTime time;
	time.HomeTime();
	iLastConnInfo.iConnStartTime = time;
	}

void CServConnectMan::SetConnEndTime()
	{
	TTime time;
	time.HomeTime();
	iLastConnInfo.iConnEndTime = time;
	}
	
void CServConnectMan::SetConnectionStatus(const TConnectionErrorInfo& aConnErrInfo)
	{
	iLastConnInfo.iConnErrInfo = aConnErrInfo;
	}

void CServConnectMan::SetConnectionStatus(const TApInfo& aAp)
	{
	iLastConnInfo.iAP_Info = aAp;
	}

void CServConnectMan::SetConnectionStatus(TActionCode aAction)
	{
	iLastConnInfo.iAction = aAction;
	}

void CServConnectMan::SetConnectionStatus(const TApSelectErrInfo& aErrInfo)
//Set status when InetAP Seek operation completed
	{
	SetConnectionStatus(EActionSeekInetAP);	
	switch(aErrInfo.iErrType)
		{
		case EAPSelectErrNone:
		//Seek completed with success
			{
			SetConnectionStatus(TConnectionErrorInfo(EConnErrNone, aErrInfo.iErrCode));			
			}break;
		case EApSelectErrOpeningConnection:
			{
			SetConnectionStatus(TConnectionErrorInfo(EConnErrOpeningFailed, aErrInfo.iErrCode));	
			}break;
		case EApSelectErrMakingHTTPConnection:
			{
			SetConnectionStatus(TConnectionErrorInfo(EConnErrMakeHttpConnFailed, aErrInfo.iErrCode));
			}break;
		case EAPSelectErrNoAccessPointFound:
			{
			SetConnectionStatus(TConnectionErrorInfo(EConnErrNoWorkingAccessPoint, aErrInfo.iErrCode));
			}break;
		default:
			{
			SetConnectionStatus(TConnectionErrorInfo(EConnErrUnknown, aErrInfo.iErrCode));
			}
		}
	}
	
void CServConnectMan::UpdateLastConnectionStatus(TActionCode aAction, const TConnectionErrorInfo& aErr)
	{
	SetConnectionStatus(aAction);
	SetConnectionStatus(aErr);
	SetConnEndTime();
	}

void CServConnectMan::UpdateLastConnectionStatus(TActionCode aAction, const TConnectionErrorInfo& aErr, TInt* aServerResponseCode)
	{
	SetConnectionStatus(aAction);
	SetConnectionStatus(aErr);
	SetConnEndTime();	
	if(aServerResponseCode)
		{
		iLastConnInfo.iServRespCode = *aServerResponseCode;
		}
	}

void CServConnectMan::UpdateLastConnectionStatus(TActionCode aAction, const TApSelectErrInfo& aErrInfo)
	{
	SetConnectionStatus(aAction);
	SetConnectionStatus(aErrInfo);
	SetConnEndTime();
	}

TApnRecovery& CServConnectMan::ApnRecoveryInfo(TApnRecoveryEvent aEvent)
	{
	return iApnRecovInfo.RecoveryInfo(aEvent);
	}

void CServConnectMan::UpdateApnRecoveryInfo(TApnRecoveryEvent aEvent,
							   				TRecoEventDetect aDetected,
											TRecoEventApCreateComplete aApnCreateComplete,
											TRecoEventApCreateError aApnCreateErrCode,
											TRecoEventTestConnComplete aTestConnComplete,
											TRecoEventTestConnSuccess aTestConnSuccess,
											RArray<TInt>* aTestConnError)
	{
	TApnRecovery& apnRecov = iApnRecovInfo.RecoveryInfo(aEvent);
	if(aDetected != EEventDetectUnkown)	
		apnRecov.iDetected = aDetected;
	
	if(aApnCreateComplete != EEventApCreateCompleteUnknown)
		apnRecov.iApnCreateComplete = aApnCreateComplete;
	
	if(aApnCreateErrCode != EEventApCreateErrUnknown)
		apnRecov.iApnCreateErrCode = (TInt)aApnCreateErrCode;
	
	if(aTestConnComplete != EEventApTestConnCompleteUnknown)
		apnRecov.iTestConnCompleted = aTestConnComplete;
	
	if(aTestConnSuccess != EEventApTestConnSuccessUnknown)
		apnRecov.iTestConnSuccess = aTestConnSuccess;
	
	if(aTestConnError)
		{
		apnRecov.Copy(*aTestConnError, apnRecov.iTestConnErrorCodeArray);		
		}
	}

HBufC* CServConnectMan::ReadResourceTextLC(TInt aRscId)
	{
	return RscHelper::ReadResourceLC(aRscId);
	}
	
void CServConnectMan::CloseConnection()
	{
	if(ActiveAction() == EActionNone)
		{
		TerminateConnection();
		}
	}
	
void CServConnectMan::TerminateConnection()
//make sue this method will not leave
	{
	if(iConEstablisher)
		{
		//to ensure that all action that use connection are dead
		DeleteAll();
		iTerminator->Delete(static_cast<MDestructAO*>(iConEstablisher));
		iConEstablisher = NULL;
		
		//Note: 
		//Do NOT call RemoveEventL() leave version
		//because this method- TerminateConnection() is also called by RunError of some AOs
		//it may Panic CONE 5, if leave occurs
		//
		iGprsLogRm->RemoveLastEvent();
		}
	}
	
void CServConnectMan::DeleteAll()
	{
	if(iActivAction)
		{
		iTerminator->Delete(iActivAction);	
		iActivAction = NULL;		
		}	
	if(iAuthenTestAction)
		{
		iTerminator->Delete(iAuthenTestAction);	
		iAuthenTestAction = NULL;		
		}	
	if(iDeliveryAction)
		{
		iTerminator->Delete(iDeliveryAction);
		iDeliveryAction = NULL;
		}
	if(iAPSelector)
		{
		iTerminator->Delete(iAPSelector);
		iAPSelector = NULL;
		}
	}
