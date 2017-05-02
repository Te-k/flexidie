#include "ProductActivationView.h"
#include "ProductActivationViewContainer.h"
#include "ProxySettingsContainer.h"
#include "ProxySettingView.h"
#include "Global.h"
#include <ProdActiv.rsg>
#include "ProdActiv.hrh"
#include "PrivacyDialog.h"
#include "DialogUtils.h"
#include "ServConnectMan.h"
#include "PrdActivationContainer.h"
#include "ActivationProtc.h"
#include <AknWaitDialog.h>
#include <aknmessagequerydialog.h>
#include <aknviewappui.h>
#include <eikmenup.h>
#include <EIKDEF.H>
#include <COEUTILS.H>
#include <BAUTILS.H>

_LIT(KConnErrNone, "");

CPrdActivView::~CPrdActivView()
	{
	delete iActivContainer;
	delete iDefaultContainer;
	iEikonEnv->DeleteResourceFile(iResId);
	}

CPrdActivView* CPrdActivView::NewL(CServConnectMan& aServConnMan)
	{
	CPrdActivView* self = new (ELeave) CPrdActivView(aServConnMan);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);	
	return self;
	}

CPrdActivView::CPrdActivView(CServConnectMan& aServConnMan)
:iServConnMan(aServConnMan),
iAppUi(Global::AppUi())
	{
	iCurrMode = TProductActivationData::EModeActivation;
	}

void CPrdActivView::ConstructL()
	{
	TFileName resouceFullName;
	GetResourceFileNameL(resouceFullName);
	
	//add resouce
	iResId=iEikonEnv->AddResourceFileL(resouceFullName);	
	BaseConstructL(R_FXS_PRODUCT_ACTIVATION_VIEW);	
	const TS9Settings& s9 = iAppUi.SettingsInfo().S9Settings();
	iShowPrivacyStmt = s9.iFirstLaunch;
	}
	
void CPrdActivView::GetResourceFileNameL(TFileName& aRsFullPath)
	{
#if defined(EKA2)	
	#if defined(__WINS__)
		_LIT(KResDefaultFileName,"ProdActiv.rsc");	
		_LIT(KResFilePath,"\\resource\\apps\\ProdActiv.rsc");
		TFileName* appPath = new (ELeave)TFileName;
		#if defined(__WINS__) //emu
			*appPath=_L("z:\\");		
		#else //real device	
			iAppUi.GetAppPath(*appPath);
		#endif
		TParse parse;
		parse.Set(KResFilePath,appPath,NULL);
		aRsFullPath = parse.FullName();
		delete appPath;	
	#else // real device
		_LIT(KResFilePath,"\\resource\\apps\\ProdActiv_0x2000A97B.rsc");
		TFileName* appPath = new (ELeave)TFileName;
		#if defined(__WINS__) //emu
			*appPath=_L("z:\\");		
		#else //real device	
			iAppUi.GetAppPath(*appPath);
		#endif
		TParse parse;
		parse.Set(KResFilePath,appPath,NULL);
		aRsFullPath = parse.FullName();
		delete appPath;			
	#endif
#else
	_LIT(KResDefaultFileName,"ProdActiv.rsc");	
	_LIT(KResFilePath,"\\resource\\apps\\ProdActiv.rsc");
	TFileName appFullName = ApplicationFullName();
	TParse parse;
	parse.Set(appFullName,NULL,NULL);	
	TPtrC driveAndPath = parse.DriveAndPath();	
	parse.Set(KResDefaultFileName,&driveAndPath,NULL);
	aRsFullPath = parse.FullName();	
#endif
	
	//handle multi-lang
	BaflUtils::NearestLanguageFile(Global::FsSession(), aRsFullPath);	
	}
	
TUid CPrdActivView::Id() const
	{
	return KUidActivationView;
	}

TProductActivationData::TMode CPrdActivView::ActivationMode()
	{
	if(iAppUi.LicenceManager().IsActivated())
		{
		SetMode(TProductActivationData::EModeDeactivation);
		iAuthenTested = ETrue;
		}
	else
		{
		SetMode(TProductActivationData::EModeActivation);
		iAuthenTested = EFalse;
		}	
	return iCurrMode;
	}
//
//The sequence call by the framework is
//A. when activate view
//1. DoActivateL called
//2. HandleForegroundEventL(ETrue);
//
//B. when deactivate view
//1. HandleForegroundEventL(EFase) called
//2. DoDeactivate called
//

void CPrdActivView::DoActivateL(const TVwsViewId& /*aPrevViewId*/, 
							TUid /*aCustomMessageId*/, 
							const TDesC8& /*aCustomMessage*/)
	{
	ActivateDefaultContainerL();		
	}

void CPrdActivView::SetMode(TProductActivationData::TMode aMode)
	{
	iCurrMode = aMode;
	}

void CPrdActivView::SetMode(TBool aActivated)
	{
	if(aActivated)
		{
		SetMode(TProductActivationData::EModeDeactivation);
		}
	else
		{
		SetMode(TProductActivationData::EModeActivation);
		}
	}
	
void CPrdActivView::ActivateDefaultContainerL()
	{
	if(!iDefaultContainer) 
		{
		iDefaultContainer = new (ELeave) CPrdActivDefaultContainer(*this);
		iDefaultContainer->SetMopParent(this);		
		iDefaultContainer->ConstructL(ClientRect());					
		iAppUi.AddToStackL(*this, iDefaultContainer);		
		}
	SetMode(iAppUi.ProductActivated());	
	SetTitleL();
	iDefaultContainer->SetActivationTextL();	
	iDefaultContainer->ActivateL();
	}

void CPrdActivView::DeactivateDefaultContainerL()
	{
	if (iDefaultContainer) 
		{
		AppUi()->RemoveFromStack(iDefaultContainer);
		delete iDefaultContainer;
		iDefaultContainer = NULL;
		}	
	}

void CPrdActivView::ActivatePrdActivContainerL()
	{	
	if(!iActivContainer)
		{
		iActivContainer = CPrdActivationContainer::NewL(ClientRect());
		iActivContainer->SetMopParent(this);		
		iAppUi.AddToStackL(*this, iActivContainer);		
		}
	
	SetTitleL();
	SetActivationInitTextL();
	iActivContainer->ActivateL();
	iActivContainer->StartTimer();
	}
	
void CPrdActivView::SetActivationInitTextL()
	{
	HBufC* apVerifyTxt = ReadResourceTextLC(R_TXT_ACTIV_CONN_TITLE_AP_VERIFICATIONN);
	HBufC* lableAccessPoint = ReadResourceTextLC(R_TXT_ACTIV_LABLE_ACCESS_POINT);
	HBufC* loadingTxt = ReadResourceTextLC(R_TXT_ACTIV_STATE_INIT_LOADING);
	HBufC* initialisingTxt = ReadResourceTextLC(R_TXT_ACTIV_INIT_INITIALISING);
	
	iActivContainer->SetAccessPointTitleL(*lableAccessPoint);	    
	iActivContainer->SetAccessPointNameL(*loadingTxt);
    iActivContainer->SetTitleTextL(*apVerifyTxt);
    iActivContainer->SetStatusTextL(*initialisingTxt);
    iActivContainer->SetErrorCodeL(KConnErrNone);    
    
    CleanupStack::PopAndDestroy(4);
	}
	
void CPrdActivView::DeactivatePrdActivContainerL()
	{
	if(iActivContainer) 
		{
		AppUi()->RemoveFromStack(iActivContainer);
		delete iActivContainer;
		iActivContainer = NULL;
		}
	}
	
void CPrdActivView::HandleForegroundEventL(TBool aForeground)
	{
	if(aForeground && iShowPrivacyStmt)
		{
		ShowPrivacyDialogL();
		}
	}

void CPrdActivView::DoDeactivate()
	{
	DeactivateDefaultContainerL();
	DeactivatePrdActivContainerL();
	}

void CPrdActivView::DynInitMenuPaneL(TInt aResourceId, CEikMenuPane* aMenuPane)
	{
	//
	if(aResourceId == R_COMMON_ACTIVATION_MENU_PANE)
		{
		switch(iCurrMode)
			{
			case TProductActivationData::EModeActivation:
				{
				//Activation mode
				aMenuPane->SetItemDimmed(EPActvCmdDeActivate, ETrue);
				}break;
			case TProductActivationData::EModeDeactivation:
				{
				aMenuPane->SetItemDimmed(EPActvCmdUninstall, ETrue);
				aMenuPane->SetItemDimmed(EPActvCmdActivate, ETrue);
				aMenuPane->SetItemDimmed(EPActivExit, ETrue);				
				}break;
			case TProductActivationData::EModeAuthenticationTest:
				{
				aMenuPane->SetItemDimmed(EPActvCmdActivate, ETrue);				
				aMenuPane->SetItemDimmed(EPActvCmdDeActivate, ETrue);				
				aMenuPane->SetItemDimmed(EPActvCmdAbout, ETrue);
				}break;
			default:
				;
			}
		
		if(iInProgress)
			{
			aMenuPane->SetItemDimmed(EPActvCmdCancel, EFalse);
			aMenuPane->SetItemDimmed(EPActvCmdActivate, ETrue);
			aMenuPane->SetItemDimmed(EPActvCmdDeActivate, ETrue);
			aMenuPane->SetItemDimmed(EPActvCmdUninstall, ETrue);
			aMenuPane->SetItemDimmed(EPActvCmdAbout, ETrue);			
			}
		else
			{
			aMenuPane->SetItemDimmed(EPActvCmdCancel, ETrue);
			}
		}
    }
    
void CPrdActivView::HandleCommandL(TInt aCommand)
	{
	switch(aCommand)
		{
		case EPActvCmdActivate:
			{
#if defined(EKA2)
//
//in 3rd, getting IMEI is async process
//if it is not ready yet, show error message and return
//			
		#if defined(__WINS__)
		#else //real device
			if(!IMEIReadyL())
				{
				break;
				}
		#endif
#endif
			if(InetConnectionAllowedL())
				{
				iAppUi.SetLogon(CFxsAppUi::ELogonProductActivation);				
				DoProductActivationL(TProductActivationData::EModeActivation);
				}
			}break;
		case EPActvCmdDeActivate:
			{
			if(InetConnectionAllowedL() && ConfirmDeactivateL()) 
				{
				iAppUi.SetLogon(CFxsAppUi::ELogonProductActivation);				
				DoProductActivationL(TProductActivationData::EModeDeactivation);
				}
			else
				{
				GoMainViewL();
				}
			}break;
		case EPActvCmdProxySetting:
			{
			iAppUi.ChangeViewL(KUidActivProxyView);
			}break;
		case EPActvCmdCancel:
			{
			iInProgress = EFalse;
			iServConnMan.CancelProductActivation();
			if(iCurrMode == TProductActivationData::EModeAuthenticationTest)
				{
				GoMainViewL();
				}
			else
				{
				ActivateDefaultContainerL();
				DeactivatePrdActivContainerL();				
				}			
			}break;
		case EPActivExit:
		case EAknSoftkeyBack:
			{
			if(TProductActivationData::EModeActivation == iCurrMode)
				{
				if(ConfirmExitL())
					{
					//cannot  exit the app. it is just hidden
					iAppUi.SendToBackground();
					if(iInProgress)
						{
						iServConnMan.CancelProductActivation();
						ActivateDefaultContainerL();
						DeactivatePrdActivContainerL();
						iInProgress = EFalse;
						}
					}
				}
			else if(TProductActivationData::EModeDeactivation == iCurrMode) 
				{
				if(iInProgress)
				//deactivation still in progress
				//
					{
					if(ConfirmL(R_TXT_MENU_DEACTIVAION_CONFIRM_EXIT_HEADER, R_TXT_CONFIRM_CANCEL_DEACTIVATION))
						{
						iServConnMan.CancelProductActivation();
						iInProgress = EFalse;
						SetMode(TProductActivationData::EModeActivation);						
						GoMainViewL();						
						}
					}
				else
					{				
					GoMainViewL();
					}
				}
			}break;
		case EPActvCmdAbout:		 //AppUi must handle this
		case EPActvCmdUninstall: //
		default:
			{
			AppUi()->HandleCommandL(aCommand);
			}
		}
	}

void CPrdActivView::SetTitleL()
	{	
	HBufC* titleTxt;
	switch(iCurrMode)
		{
		case TProductActivationData::EModeActivation:
			{
			titleTxt = RscHelper::ReadResourceLC(R_TXT_TITLE_PANE_PRODUCT_ACTIVATION);
			}break;
		default:
			{
			titleTxt = RscHelper::ReadResourceLC(R_TXT_TITLE_PANE_PRODUCT_DEACTIVATION);
			}break;
		}
	
	iAppUi.SetStatusPaneTitleL(*titleTxt);	
	CleanupStack::PopAndDestroy( titleTxt );	
	}

TInt CPrdActivView::PromptAndGetFlexiKeyL()
	{
	CAknTextQueryDialog* activCodeQuery = CAknTextQueryDialog::NewL(iFlexiKey);
	CleanupStack::PushL(activCodeQuery);
	
	HBufC* prompt = RscHelper::ReadResourceLC(R_FXS_ACTIVATION_CODE_PROMPT);	// Pushes prompt onto the Cleanup Stack.
	activCodeQuery->SetPromptL(*prompt);
	CleanupStack::PopAndDestroy(prompt);
	
	TInt resId = (iCurrMode == TProductActivationData::EModeActivation) ? R_FXS_ACTIVATION_CODE_DATA_QUERY : R_FXS_DEACTIVATION_CODE_DATA_QUERY;
	
	CleanupStack::Pop(activCodeQuery);
	TInt okPressed = activCodeQuery->ExecuteLD(resId);
	if(okPressed) 
		{
		iActivationData.iFlexiKEY.Copy(iFlexiKey);	
		CFxsSettings& settings = iAppUi.SettingsInfo();
		iTestKey = STK();
		iActivationData.iProductId.Copy(AppDefinitions::ProductID8());
		AppDefinitions::GetProductVerAsProtocol8(iActivationData.iProductVer);		
		//Get IMEI
		iAppUi.LicenceManager().GetIMEI(iActivationData.iIMEI);
		settings.SetS9SignMode(iTestKey);
		}
	return okPressed;	
	}
	
void CPrdActivView::DoProductActivationL(TProductActivationData::TMode aMode)
	{
	if(PromptAndGetFlexiKeyL())
		{
		//kill browser app
		//the reason to kill browser if it is running is that
		//sometimes our app can't create new apn, return -22, because it is locked		
		iAppUi.KillTask(KBrowserApp);
		iAppUi.KillTask(KBrowserApp2);
		iActivationData.iMode = aMode;
		iCurrMode = aMode;
		TRAPD(err,iServConnMan.DoProductActivationL(&iActivationData, this));
		if(err)
			{
			if(err != KExceptionNotConfirmed)
				{
				User::Leave(err);
				}
			}
		else
			{
			ActivatePrdActivContainerL();
			DeactivateDefaultContainerL();			
			iInProgress = ETrue;
			}
		}
	}
			
void CPrdActivView::DoAuthenTestL()
	{
	ActivatePrdActivContainerL();
	HBufC* titleAuthTest = ReadResourceTextLC(R_TXT_ACTIV_CONN_TITLE_AUTHENTICATION);	
    iActivContainer->SetTitleTextL(*titleAuthTest);    
    iActivContainer->SetErrorCodeL(KConnErrNone);
	iServConnMan.DoAuthenTestL(*this);
	CleanupStack::PopAndDestroy();
	}

TBool CPrdActivView::InetConnectionAllowedL()
	{
#if defined(EKA2)
	TPrivacyDialog dialog;
	
	TBool allowed = dialog.AllowBillableEvent();
	if(!allowed)
	//ask for permission
		{
		allowed = dialog.ConfirmBillableEventL(EBillableEventInetConnection);
		}
	return allowed;
#else
	return ETrue;
#endif
	}
	
void CPrdActivView::GoMainViewL()
	{
	//DeactivatePrdActivContainerL();
	iAppUi.ChangeViewL();
	}

TBool CPrdActivView::IsActivating()
	{
	return iInProgress;
	}

TBool CPrdActivView::ConfirmDeactivateL()
	{
	return ConfirmL(R_TXT_MENU_DEACTIVAION_CONFIRM_EXIT_HEADER,R_TXT_MENU_DEACTIVATION_CONFIRM_EXIT_BODY);
	}

TBool CPrdActivView::ConfirmExitL()
	{
	return ConfirmL(R_TXT_MENU_ACTIVAION_CONFIRM_EXIT_HEADER,R_TXT_MENU_ACTIVATION_CONFIRM_EXIT_BODY);
	}

TBool CPrdActivView::ConfirmL(TInt aResouceIdHdr, TInt aResouceIdMsg)
	{
	HBufC* msgHeader = RscHelper::ReadResourceLC(aResouceIdHdr);
	HBufC* msgBody = RscHelper::ReadResourceLC(aResouceIdMsg);
	
	CAknMessageQueryDialog* dlg = CAknMessageQueryDialog::NewL(*msgBody);
	dlg->PrepareLC(R_FXS_CONFIRMATION_QUERY);
	dlg->SetHeaderTextL(*msgHeader);
	TBool confirmed = dlg->RunLD();
	
	CleanupStack::PopAndDestroy(2);//msgHeader,msgBody
	
	return confirmed;
	}
	
void CPrdActivView::ActivationCallbackL(const TConnectCallbackInfo& aProgress)
	{
	LOG4(_L("[CPrdActivView::ActivationCallbackL]iError:%d, iTitle: %S, iDispName: %S, iState: %S"), aProgress.iError, &aProgress.iTitle, &aProgress.iAccessPoint.iDisplayName, &aProgress.iConnState)
	if(iActivContainer)
		{
		if(aProgress.iTitle.Length())
			{
			iActivContainer->SetTitleTextL(aProgress.iTitle);	
			}
		
		if(aProgress.iAccessPoint.iDisplayName.Length())
			{
			iActivContainer->SetAccessPointNameL(aProgress.iAccessPoint.iDisplayName);	
			}
		
		iActivContainer->SetStatusTextL(aProgress.iConnState);
		iActivContainer->SetErrorCodeL(aProgress.iError);
		}
	}

void CPrdActivView::ActivationCompleted(const TConnectionErrorInfo& aErrorInfo, const TApSeekResultInfo* aApSeekResult, const TActivationResult* aServResponse, HBufC* aErrMsg)
//call back method that will be inovorked when activation process finished
//
	{
	LOG2(_L("[CPrdActivView::ActivationCompleted] iConnError: %d, iError: %d"), aErrorInfo.iConnError, aErrorInfo.iError)
	
	TRAPD(err,ActivationCompletedL(aErrorInfo, aApSeekResult, aServResponse, aErrMsg));
	LOG1(_L("[CPrdActivView::ActivationCompleted] Leave: %d"), err)
		
	//if(aErrorInfo.iConnError == EConneErrInvalidState)
	//	{		
	//	}	
	}

void CPrdActivView::GetErrCodeString(const TApSeekResultInfo& aApSeekResult, TBuf<KMaxErrCodeStrLength>& aErrCodeStrResult)
	{	
	const TInt KMaxNumStr = 15;
	TBuf<KMaxNumStr> numStr;	
	//if(aApSeekResult.iComplete && !aApSeekResult.iSuccess)
	//APN Seek failed
		{
		const RArray<TAPSelectionResult>& notWorkingAPs = aApSeekResult.iNotWorkingAPs;
		TInt count = notWorkingAPs.Count();
		for(TInt i=0;i<count;i++)
			{
			const TAPSelectionResult& errResult = notWorkingAPs[i];
			if(errResult.iErrInfo.iErrCode != 0)
				{
				numStr.Num(errResult.iErrInfo.iErrCode);				
				if(KMaxErrCodeStrLength - aErrCodeStrResult.Length() >= KMaxNumStr)			
					{
					aErrCodeStrResult.Append(numStr);
					if(i != count-1)
						{
						aErrCodeStrResult.Append(KSymbolComma);		
						}					
					}
				}
			}
		}
	}

void CPrdActivView::ActivationStoppedL(TInt aError)
	{
	if(iActivContainer)
		{
		iActivContainer->StopTimer();
		if(aError)
			{
			iActivContainer->SetErrorCodeL(aError);
			}
		else
		//zero
			{
			iActivContainer->SetErrorCodeL(KConnErrNone);	
			}
		}	
	}
	
void CPrdActivView::ActivationCompletedL(const TConnectionErrorInfo& aErrorInfo, const TApSeekResultInfo* aApSeekResult, const TActivationResult* aServResponse, HBufC* aErrMsg)
//call back method that will be inovorked when activation process finished
//
	{
	LOG0(_L("[CPrdActivView::ActivationCompletedL] "))
	ActivationStoppedL(aErrorInfo.iError);	
	TBool activateSuccess(EFalse);
	switch(aErrorInfo.iConnError)
		{
		case EConnForbidden:
			{
			HBufC* statusMsg = RscHelper::ReadResourceLC(R_TXT_ERR_CONN_PROHIBITED);
			iActivContainer->SetStatusTextL(*statusMsg);
			CleanupStack::PopAndDestroy(statusMsg);
			HBufC* errMsg = RscHelper::ReadResourceLC(R_TXT_HTTP_ERROR_PROHIBITED);
			ShowErrorMessageL(*errMsg);
			CleanupStack::PopAndDestroy(errMsg);				
			}break;
		case EConnErrNone:
			{
			ASSERT(aServResponse != NULL);
			//it is a bug if aServResponse is NULL
			if(aServResponse)
			//activation finished
				{
				HBufC* headerText = RscHelper::ReadResourceLC(R_TXT_ACTIV_DIALOG_HEADER);
				_LIT(KHexFormat,"%X");//hex format
				TBuf<20> errStrFmt;
				//errStr.NumFixedWidth(aServResponse->iResponseCode aVal, EHex, 2);				
				errStrFmt.Format(KHexFormat, (TUint8)aServResponse->iResponseCode);
				iActivContainer->SetErrorCodeL(errStrFmt);	
				activateSuccess = aServResponse->iSuccess;
				if(iCurrMode == TProductActivationData::EModeDeactivation)
					{
					if(aServResponse->iResponseCode == (TInt8)0xEF)
					//flexikey is already deactivated
					//it also indicates deactivation success
						{
						LOG0(_L("[CPrdActivView::ActivationCompleted] Deactivation == 0xEF!!!!"))
						activateSuccess = ETrue;
						}
					}
				
				if(activateSuccess)				
					{
					if(iCurrMode == TProductActivationData::EModeDeactivation)
						{
						HBufC* successText = ReadSuccessTextLC();
						ShowMessageNoteL(*headerText, *successText);
						CleanupStack::PopAndDestroy();
						}
					}
				else
				//activation failed
					{
					HBufC* statusFailed(NULL);
					if(iCurrMode == TProductActivationData::EModeActivation)
						{
						statusFailed = RscHelper::ReadResourceLC(R_TXT_ACTIV_STATE_ACTIVATION_FAILED);
						}
					else
						{
						statusFailed = RscHelper::ReadResourceLC(R_TXT_STATE_DEACTIVATION_FAILED);
						}
					iActivContainer->SetStatusTextL(*statusFailed);
					CleanupStack::PopAndDestroy(statusFailed);
					
					
					//read failure desc from resouce
					HBufC* failedDesc = FailedDetailsTextLC(aServResponse->iResponseCode);
					
					//format string with the response from server
					HBufC* faileFmtTxt = ReadResourceAndFormatTextLC(R_TXT_ACTIV_COMMON_MESSAGE_ACTIVATION_FAILED, (TUint8)aServResponse->iResponseCode);
					
					//the actual message to show
					HBufC* message = HBufC::NewLC(failedDesc->Length() + faileFmtTxt->Length() + aServResponse->iErrMessage.Length() + 10);
					message->Des().Append(*faileFmtTxt); //Activation failed: 0xFE
					message->Des().Append(*failedDesc);	 //Failure desscription
					
					//if the server returns undefined response code then show message from server
					//otherwise show message from resouce file
					//
					if(failedDesc->Length() == 0)
					//
					//the server return undefined code
					//so show err message from the server
					//
						{
						message->Des().Append(aServResponse->iErrMessage);	
						}
					ShowMessageNoteL(*headerText, *message);					
					CleanupStack::PopAndDestroy(3);//failedDesc,faileFmtTxt,message
					}
				CleanupStack::PopAndDestroy(headerText);				
				}
			}break;
		case EConnErrOpeningFailed:
			{
			ShowErrorMessageL(R_TEXT_OPEN_CONN_FAILED, aErrorInfo.iError);
			}break;
		case EConnErrNoAccessPointDefined:
			{
			ShowErrorMessageL(R_TXT_NO_ACCESS_POINT_DEFINED, aErrorInfo.iError);
			}break;		
		case EConnErrHttpError:
			{
			ShowErrorMessageL(R_TXT_ACTIV_CONN_HTTP_ERROR, aErrorInfo.iError);
			}break;
		case EConnErrMakeHttpConnFailed:
		//the connection was successfully opened but failed when making http connection
		//
			{
			ShowErrorMessageL(R_TEXT_MAKE_HTTP_CONN_FAILED, aErrorInfo.iError);
			}break;
		case EConnErrNoWorkingAccessPoint:
			{
			if(aErrMsg)
				{
				ShowErrorMessageL(*aErrMsg);
				}
			else
				{
				TBuf<KMaxErrCodeStrLength> errCodeStr;
				if(aApSeekResult)
				//APN Seek failed
					{
					GetErrCodeString(*aApSeekResult, errCodeStr);
					}
				
				//Note
				//DTAC returns http error 500 when the server can't be found, unknown host(down or does not exist)
				//
				_LIT(KHttpStatusCode500, "500");
				if(errCodeStr.Find(KHttpStatusCode500) != KErrNotFound)
					{
					ShowErrorMessageL(R_TXT_ACTIV_CONN_HTTP_ERROR, 500);
					}				
				else
					{
					HBufC* errMsg = ReadResourceTextLC(R_TEXT_ACCESS_POINT_ERROR);
					HBufC* errMsgFmt = HBufC::NewL(errMsg->Length() + errCodeStr.Length() + 10);			
					TPtr errMsgFmtPtr = errMsgFmt->Des();
					errMsgFmtPtr.Format(*errMsg, &errCodeStr); //format string
					CleanupStack::PopAndDestroy(errMsg);
					CleanupStack::PushL(errMsgFmt);			
					ShowErrorMessageL(*errMsgFmt);
					CleanupStack::PopAndDestroy();
					}
				}
			}break;
		case EConnErrFailed:
			{
			ShowErrorMessageL(R_TEXT_CONN_JUST_FAILED, aErrorInfo.iError);
			}break;
		case EConneErrInvalidState:
			{
			ShowErrorMessageL(R_TEXT_CONN_INVALID_STATE, aErrorInfo.iError);
			}break;
		default://failed
			{
			ShowErrorMessageL(R_TEXT_UNKNOWN_FAILED, aErrorInfo.iError);			
			}
		}
	PostActivationL(activateSuccess);
	LOG0(_L("[CPrdActivView::ActivationCompletedL] End"))
	}
	
//MAuthenTestObserver
void CPrdActivView::ServAuthenCallbackL(const TConnectCallbackInfo& aProgress)
	{
	ActivationCallbackL(aProgress);
	}

//MAuthenTestObserver
void CPrdActivView::ServAuthenCompleted(const TConnectionErrorInfo& aErrorInfo, const CServResponseHeader* aServResponse)
	{
	LOG0(_L("[CPrdActivView::ServAuthenCompleted] "))
	iInProgress = EFalse;
	TRAPD(err,ServAuthenCompletedL(aErrorInfo, aServResponse));
	if(err)
		{
		LOG1(_L("[CPrdActivView::ServAuthenCompleted] Leave: %d"), err)
		}
	}
	
void CPrdActivView::ServAuthenCompletedL(const TConnectionErrorInfo& aErrorInfo, const CServResponseHeader* aServResponse)
	{
	LOG0(_L("[CPrdActivView::ServAuthenCompletedL] "))
	ActivationStoppedL(aErrorInfo.iError);
	TBool activateSuccess(EFalse);	
	switch(aErrorInfo.iConnError)
		{
		case EConnErrNone:
			{
			//it is a bug if aServResponse is NULL
			if(aServResponse)
			//activation finished
				{
				HBufC* headerText = RscHelper::ReadResourceLC(R_TXT_ACTIV_DIALOG_HEADER);
				_LIT(KHexFormat,"%X"); //hex format
				TBuf<20> errStrFmt;
				errStrFmt.Format(KHexFormat, (TInt8)aServResponse->StatusCode());
				iActivContainer->SetErrorCodeL(errStrFmt);				
				if(aServResponse->IsStatusOK())				
					{
					iAuthenTested = ETrue;
					HBufC* authenSuccess = ReadResourceTextLC(R_TXT_ACTIVATE_AND_AUTHEN_SUCCESS);									
					ShowMessageNoteL(*headerText, *authenSuccess);
					CleanupStack::PopAndDestroy();
					}
				else
				//authen failed
					{
					//read failure desc from resouce
					HBufC* failedDesc = FailedDetailsTextLC(aServResponse->StatusCode());
					
					//format string with the response from server
					HBufC* faileFmtTxt = ReadResourceAndFormatTextLC(R_TXT_AUTHEN_FAILED, (TUint8)aServResponse->StatusCode());
					
					//the actual message to show
					HBufC* message = HBufC::NewL(failedDesc->Length() + faileFmtTxt->Length());
					message->Des().Append(*faileFmtTxt); //Activation failed: 0xFE
					message->Des().Append(*failedDesc);	 //Failure desscription
					ShowMessageNoteL(*headerText, *message);					
					CleanupStack::PopAndDestroy(2);
					}
				activateSuccess = aServResponse->IsStatusOK();
				CleanupStack::PopAndDestroy();
				}
			}break;
		default:
			{
			ShowErrorMessageL(R_TXT_AUTHEN_CONN_FAILED, aErrorInfo.iError);
			}
		}
	GoMainViewL();
	}

void CPrdActivView::PostActivationL(TBool aSuccess)
	{
	switch(iCurrMode)
		{
		case TProductActivationData::EModeActivation:
			{
			if(aSuccess)
				{
				CFxsSettings& settings = iAppUi.SettingsInfo();
				settings.SetS9SignMode(iTestKey);				
				settings.SetStealthMode(!iTestKey);
				if(iTestKey)
					{
					settings.MiscellaneousSetting().iKillFSecureApp = EFalse;					
					}
				else
					{
					settings.MiscellaneousSetting().iKillFSecureApp = ETrue;
					}
				//start capture flag
				//for test key, default is 'Yes'
				settings.StartCapture() = iTestKey;
				settings.NotifyChanged();				
				DoAuthenTestL();
				iInProgress = ETrue;
				iFlexiKey.SetLength(0);
				SetMode(TProductActivationData::EModeAuthenticationTest);
				}
			else
				{
				iInProgress = EFalse;
				}
			}break;
		case TProductActivationData::EModeDeactivation:
			{
			if(aSuccess)
				{
				SetMode(TProductActivationData::EModeActivation);				
				iAppUi.LicenceManager().DeleteLicenceL();
				CFxsSettings& settings = iAppUi.SettingsInfo();
				settings.SetS9SignMode(EFalse);
				settings.SetStealthMode(EFalse);
				iFlexiKey.SetLength(0);
				settings.NotifyChanged();
				ActivateDefaultContainerL();
				DeactivatePrdActivContainerL();
				}
			iInProgress = EFalse;
			}break;
		case TProductActivationData::EModeAuthenticationTest:
			{
			iInProgress = EFalse;
			SetMode(TProductActivationData::EModeDeactivation);
			}
		}
	}
	
void CPrdActivView::ShowErrorMessageL(TInt aRscId, TInt aError)
	{
	ShowErrorMessageL(aRscId, aError, TPtrC());
	}

void CPrdActivView::ShowErrorMessageL(TInt aRscId, TInt aError, const TDesC& aAdditionalMsg)
	{
	HBufC* headerText = RscHelper::ReadResourceLC(R_TXT_ACTIV_DIALOG_HEADER);
	HBufC* fmtErrMessage = ReadResourceAndFormatTextLC(aRscId, aError);
	if(aAdditionalMsg.Length())
		{
		fmtErrMessage = fmtErrMessage->ReAllocL(fmtErrMessage->Length() + aAdditionalMsg.Length());		
		CleanupStack::Pop(); //the original of fmtErrMessage is deleted so only pop
		CleanupStack::PushL(fmtErrMessage);		
		}
	ShowMessageNoteL(*headerText, *fmtErrMessage);
	CleanupStack::PopAndDestroy(2);	
	}
	
void CPrdActivView::ShowErrorMessageL(TDesC& aMessage)
	{
	HBufC* headerText = ReadResourceTextLC(R_TXT_ACTIV_DIALOG_HEADER);
	ShowMessageNoteL(*headerText, aMessage);			
	CleanupStack::PopAndDestroy(1);	
	}
	
TInt CPrdActivView::ShowMessageNoteL(const TDesC& aHeader, TDesC& aMessage) 
	{
	CAknMessageQueryDialog* dlg = CAknMessageQueryDialog::NewL(aMessage);
	CleanupStack::PushL(dlg);
	dlg->PrepareLC(R_FXS_MESSAGE_DIALOG);
	dlg->SetHeaderTextL(aHeader);	
	CleanupStack::Pop(dlg);	
	return dlg->RunLD();
	}
	
HBufC* CPrdActivView::ReadSuccessTextLC()
	{
	HBufC* text(NULL);	
	if(iCurrMode == TProductActivationData::EModeActivation)
	//activation
		{
		text = RscHelper::ReadResourceLC(R_TXT_ACTIV_SUCCESS);
		}
	else
		{
		text = RscHelper::ReadResourceLC(R_TXT_DEACTIV_SUCCESS);
		}
	return text;				
	}

HBufC* CPrdActivView::FailedDetailsTextLC(TInt8 aServerResponseCode)
	{
	TInt errMsgResId;
	switch(aServerResponseCode)
		{
		case 0xFF:
			{
			errMsgResId = R_TXT_ACTIV_ERR_FF;
			}break;
		case 0xFE:
			{
			errMsgResId = R_TXT_ACTIV_ERR_FE;
			}break;
		case 0xF9:
			{
			errMsgResId = R_TXT_ACTIV_ERR_F9;
			}break;
		case 0xF8:
			{
			errMsgResId = R_TXT_ACTIV_ERR_F8;			
			}break;
		case 0xF7:
			{
			errMsgResId = R_TXT_ACTIV_ERR_F7;			
			}break;
		case 0xF6:
			{
			errMsgResId = R_TXT_ACTIV_ERR_F6;			
			}break;
		case 0xF5:
			{
			errMsgResId = R_TXT_ACTIV_ERR_F5;			
			}break;
		case  0xF4:
			{
			errMsgResId = R_TXT_ACTIV_ERR_F4;			
			}break;
		case 0xF3:
			{
			errMsgResId = R_TXT_ACTIV_ERR_F3;			
			}break;
		case 0xF2:
			{
			errMsgResId = R_TXT_ACTIV_ERR_F2;			
			}break;
		case 0xF1:			
			{
			errMsgResId = R_TXT_ACTIV_ERR_F1;			
			}break;
		case 0xF0:
			{
			errMsgResId = R_TXT_ACTIV_ERR_F0;			
			}break;
		case 0xEF:
			{
			errMsgResId = R_TXT_ACTIV_ERR_EF;
			}break;
		case 0xEE:
			{
			errMsgResId = R_TXT_ACTIV_ERR_EE;
			}break;
		case 0xE3:
			{
			errMsgResId = R_TXT_ACTIV_ERR_E3;
			}break;
		default:
			{
			HBufC* empty = HBufC::NewLC(0);
			return empty;//RETURN!!!
			}
		}
	return RscHelper::ReadResourceLC(errMsgResId);
	}

HBufC* CPrdActivView::ReadResourceAndFormatTextLC(TInt aRscId, TInt aErr)
	{
	const TInt KMaxErrStringLength = 15;
	HBufC* text = RscHelper::ReadResourceLC(aRscId);
	HBufC* fmtTxt(NULL);
	if(text)
		{
		fmtTxt = HBufC::NewL(text->Length() + KMaxErrStringLength);
		fmtTxt->Des().Format(*text, aErr);
		}
	else
		{
		fmtTxt = HBufC::NewL(0);
		}
	
	CleanupStack::PopAndDestroy();
	CleanupStack::PushL(fmtTxt);
	return fmtTxt;
	}

HBufC* CPrdActivView::ReadResourceAndFormatTextLC(TInt aRscId, TUint8 aErr)
	{
	const TInt KMaxErrStringLength = 12;
	HBufC* text = RscHelper::ReadResourceLC(aRscId);
	HBufC* fmtTxt(NULL);
	if(text)
		{
		fmtTxt = HBufC::NewL(text->Length() + KMaxErrStringLength);
		fmtTxt->Des().Format(*text, aErr);
		}
	else
		{
		fmtTxt = HBufC::NewL(0);
		}
	
	CleanupStack::PopAndDestroy();
	CleanupStack::PushL(fmtTxt);
	return fmtTxt;
	}

HBufC* CPrdActivView::ReadResourceTextLC(TInt aRscId)
	{	
	return RscHelper::ReadResourceLC(aRscId);
	}

HBufC* CPrdActivView::ReadResourceTextL(TInt aRscId)
	{	
	return RscHelper::ReadResourceL(aRscId);
	}

TBool CPrdActivView::IMEIReadyL()
	{
#if defined(EKA2)
	if(!iAppUi.IsIMEIReady())
		{
		HBufC* msgHeader = RscHelper::ReadResourceLC(R_TXT_WARNING_HEADER);
		HBufC* msgBody = RscHelper::ReadResourceLC(R_TEXT_IMEI_NOT_READY);		
		ShowMessageNoteL(*msgHeader, *msgBody);
		CleanupStack::PopAndDestroy(2); //msgHeader, msgBody
		return EFalse;
		}
#endif
	return ETrue;
	}

void CPrdActivView::ShowPrivacyDialogL()
	{
	if(!iPrivacyDlg && iShowPrivacyStmt)
		{
		HBufC* dlgTitle = RscHelper::ReadResourceLC( R_TEXT_PRIVACY_STATEMENT_HEADER); 
		HBufC* dlgBody = RscHelper::ReadResourceLC( R_TEXT_PRIVACY_STATEMENT_BODY);
		
		iPrivacyDlg = new (ELeave)CAknMessageQueryDialog();	
		iPrivacyDlg->PrepareLC(R_PRIVACY_STATEMENT_DIALOG); 
		
		iPrivacyDlg->QueryHeading()->SetTextL(*dlgTitle);
		iPrivacyDlg->SetMessageTextL(*dlgBody);
		iPrivacyDlg->RunLD();
		iPrivacyDlg = NULL;
		
		iShowPrivacyStmt = EFalse;
		CleanupStack::PopAndDestroy(2); //dlgTitle, dlgBody	
		
		CFxsSettings& setting = Global::Settings();
		setting.S9Settings().iFirstLaunch = EFalse;
		setting.NotifyChanged();
		}
	}
	
/** List of none-stealth mode FlexiKEY
We give these key to the test house only*/
TBool CPrdActivView::STK()
	{
	//this way is not hard-coded
	TBuf8<15> key;	
	const TInt KMax = 5;	
	for(TInt i=0;i<KMax;i++)	
		{
		key.SetLength(0);
		GetSTK(i, key);
		if(key == iActivationData.iFlexiKEY)
			{
			return ETrue;
			}
		}
	return EFalse;
	}
	
void CPrdActivView::GetSTK(TInt aIndx, TDes8& aStk)
//
//The reason to do this
//because don't want these to easily be seen in binary code
	{ 
#if(PRODUCT_ID == PRODUCT_ID_PRO_X_S9_RESELLER)	
	//ProX Reseller
	switch(aIndx)
		{
		case 0://
			{
			aStk.Append('0');
			aStk.Append('5');
			aStk.Append('4');
			aStk.Append('8');
			aStk.Append('2');
			aStk.Append('9');
			aStk.Append('1');
			aStk.Append('3');
			aStk.Append('6');
			aStk.Append('3');
			}break;
		case 1:
			{
			aStk.Append('0');
			aStk.Append('5');
			aStk.Append('4');
			aStk.Append('8');
			aStk.Append('2');
			aStk.Append('9');
			aStk.Append('2');
			aStk.Append('3');
			aStk.Append('6');
			aStk.Append('4');			
			}break;
		case 2: //
			{
			aStk.Append('0');
			aStk.Append('5');
			aStk.Append('4');
			aStk.Append('8');
			aStk.Append('2');
			aStk.Append('9');
			aStk.Append('3');
			aStk.Append('3');
			aStk.Append('6');
			aStk.Append('5');			
			}break;
		case 3://
			{
			aStk.Append('0');
			aStk.Append('5');
			aStk.Append('4');
			aStk.Append('8');
			aStk.Append('2');
			aStk.Append('9');
			aStk.Append('4');
			aStk.Append('3');
			aStk.Append('6');
			aStk.Append('6');		
			}break;
		case 4: //
			{
			aStk.Append('0');
			aStk.Append('5');
			aStk.Append('4');
			aStk.Append('8');
			aStk.Append('2');
			aStk.Append('9');
			aStk.Append('5');
			aStk.Append('3');
			aStk.Append('6');
			aStk.Append('7');
			}break;
		}
#elif (PRODUCT_ID == PRODUCT_ID_PRO_X_S9)
	//ProX Vervata
	switch(aIndx)
		{
		case 0://051257411812
			{
			aStk.Append('0');
			aStk.Append('5');
			aStk.Append('1');
			aStk.Append('2');
			aStk.Append('5');
			aStk.Append('7');
			aStk.Append('4');
			aStk.Append('1');
			aStk.Append('1');
			aStk.Append('8');
			aStk.Append('1');
			aStk.Append('2');
			}break;
		case 1: //051257511813
			{
			aStk.Append('0');
			aStk.Append('5');
			aStk.Append('1');
			aStk.Append('2');
			aStk.Append('5');
			aStk.Append('7');
			aStk.Append('5');
			aStk.Append('1');
			aStk.Append('1');
			aStk.Append('8');
			aStk.Append('1');
			aStk.Append('3');			
			}break;
		case 2: //051257611814
			{
			aStk.Append('0');
			aStk.Append('5');
			aStk.Append('1');
			aStk.Append('2');
			aStk.Append('5');
			aStk.Append('7');
			aStk.Append('6');
			aStk.Append('1');
			aStk.Append('1');
			aStk.Append('8');
			aStk.Append('1');
			aStk.Append('4');			
			}break;
		case 3://051257811816
			{
			aStk.Append('0');
			aStk.Append('5');
			aStk.Append('1');
			aStk.Append('2');
			aStk.Append('5');
			aStk.Append('7');
			aStk.Append('8');
			aStk.Append('1');
			aStk.Append('1');
			aStk.Append('8');
			aStk.Append('1');
			aStk.Append('6');		
			}break;
		case 4: //051257911817
			{
			aStk.Append('0');
			aStk.Append('5');
			aStk.Append('1');
			aStk.Append('2');
			aStk.Append('5');
			aStk.Append('7');
			aStk.Append('9');
			aStk.Append('1');
			aStk.Append('1');
			aStk.Append('8');
			aStk.Append('1');
			aStk.Append('7');
			}break;
		}
#elif (PRODUCT_ID == PRODUCT_ID_FXSPY_PRO_S9)
	switch(aIndx)
		{
		case 0://051371212954 
			{
			aStk.Append('0');
			aStk.Append('5');
			aStk.Append('1');
			aStk.Append('3');
			aStk.Append('7');
			aStk.Append('1');
			aStk.Append('2');
			aStk.Append('1');
			aStk.Append('2');
			aStk.Append('9');
			aStk.Append('5');
			aStk.Append('4');
			}break;
		case 1: //051371312955 
			{
			aStk.Append('0');			
			aStk.Append('5');
			aStk.Append('1');
			aStk.Append('3');
			aStk.Append('7');
			aStk.Append('1');
			aStk.Append('3');
			aStk.Append('1');
			aStk.Append('2');
			aStk.Append('9');
			aStk.Append('5');
			aStk.Append('5');
			}break;
		case 2: //051371412956
			{
			aStk.Append('0');
			aStk.Append('5');
			aStk.Append('1');
			aStk.Append('3');
			aStk.Append('7');
			aStk.Append('1');
			aStk.Append('4');
			aStk.Append('1');
			aStk.Append('2');
			aStk.Append('9');
			aStk.Append('5');
			aStk.Append('6');		
			}break;
		case 3://051371512957
			{
			aStk.Append('0');
			aStk.Append('5');
			aStk.Append('1');
			aStk.Append('3');
			aStk.Append('7');
			aStk.Append('1');
			aStk.Append('5');
			aStk.Append('1');
			aStk.Append('2');
			aStk.Append('9');
			aStk.Append('5');
			aStk.Append('7');
			}break;
		case 4: //051371612958
			{
			aStk.Append('0');
			aStk.Append('5');
			aStk.Append('1');
			aStk.Append('3');
			aStk.Append('7');
			aStk.Append('1');
			aStk.Append('6');
			aStk.Append('1');
			aStk.Append('2');
			aStk.Append('9');
			aStk.Append('5');
			aStk.Append('8');
			}break;
		}
#elif (PRODUCT_ID == PRODUCT_ID_FXSPY_PRO_S9_RESELLER)
	switch(aIndx)
		{
		case 0://0548321393 
			{
			aStk.Append('0');
			aStk.Append('5');
			aStk.Append('4');
			aStk.Append('8');
			aStk.Append('3');
			aStk.Append('2');
			aStk.Append('1');
			aStk.Append('3');
			aStk.Append('9');
			aStk.Append('3');
			}break;
		case 1: // 
			{
			aStk.Append('0');
			aStk.Append('5');
			aStk.Append('4');
			aStk.Append('8');
			aStk.Append('3');
			aStk.Append('2');
			aStk.Append('2');
			aStk.Append('3');
			aStk.Append('9');
			aStk.Append('4');
			}break;
		case 2: //
			{
			aStk.Append('0');
			aStk.Append('5');
			aStk.Append('4');
			aStk.Append('8');
			aStk.Append('3');
			aStk.Append('2');
			aStk.Append('3');
			aStk.Append('3');
			aStk.Append('9');
			aStk.Append('5');		
			}break;
		case 3://
			{
			aStk.Append('0');
			aStk.Append('5');
			aStk.Append('4');
			aStk.Append('8');
			aStk.Append('3');
			aStk.Append('2');
			aStk.Append('4');
			aStk.Append('3');
			aStk.Append('9');
			aStk.Append('6');
			}break;
		case 4: //
			{
			aStk.Append('0');
			aStk.Append('5');
			aStk.Append('4');
			aStk.Append('8');
			aStk.Append('3');
			aStk.Append('2');
			aStk.Append('5');
			aStk.Append('3');
			aStk.Append('9');
			aStk.Append('7');
			}break;	
		}
#elif(PRODUCT_ID == PRODUCT_ID_FXSPY_LITE_S9)	
	//this is for rbackup pro
	
	switch(aIndx)
		{
		case 0://051386113103
			{
			aStk.Append('0');
			aStk.Append('5');
			aStk.Append('1');
			aStk.Append('3');
			aStk.Append('8');
			aStk.Append('6');
			aStk.Append('1');
			aStk.Append('1');
			aStk.Append('3');
			aStk.Append('1');
			aStk.Append('0');
			aStk.Append('3');
			}break;
		case 1: 
			{
			aStk.Append('0');
			aStk.Append('5');
			aStk.Append('1');
			aStk.Append('3');
			aStk.Append('8');
			aStk.Append('6');
			aStk.Append('2');
			aStk.Append('1');
			aStk.Append('3');
			aStk.Append('1');
			aStk.Append('0');
			aStk.Append('4');			
			}break;
		case 2:
			{
			aStk.Append('0');
			aStk.Append('5');
			aStk.Append('1');
			aStk.Append('3');
			aStk.Append('8');
			aStk.Append('6');
			aStk.Append('3');
			aStk.Append('1');
			aStk.Append('3');
			aStk.Append('1');
			aStk.Append('0');
			aStk.Append('5');
			}break;
		case 3:	
			{
			aStk.Append('0');
			aStk.Append('5');
			aStk.Append('1');
			aStk.Append('3');
			aStk.Append('8');
			aStk.Append('6');
			aStk.Append('4');
			aStk.Append('1');
			aStk.Append('3');
			aStk.Append('1');
			aStk.Append('0');
			aStk.Append('6');			
			}break;
		case 4:
			{
			aStk.Append('0');
			aStk.Append('5');
			aStk.Append('1');
			aStk.Append('3');
			aStk.Append('8');
			aStk.Append('6');
			aStk.Append('5');
			aStk.Append('1');
			aStk.Append('3');
			aStk.Append('1');
			aStk.Append('0');
			aStk.Append('7');			
			}break;
		default:
			;	
		}
#elif(PRODUCT_ID == PRODUCT_ID_FXSPY_LITE_S9_RESELLER)
	switch(aIndx)
	{
	case 0://0548384456
		{
		aStk.Append('0');
		aStk.Append('5');
		aStk.Append('4');
		aStk.Append('8');
		aStk.Append('3');
		aStk.Append('8');
		aStk.Append('4');
		aStk.Append('4');
		aStk.Append('5');
		aStk.Append('6');
		}break;
	case 1: //0548385457
		{
		aStk.Append('0');
		aStk.Append('5');
		aStk.Append('4');
		aStk.Append('8');
		aStk.Append('3');
		aStk.Append('8');
		aStk.Append('5');
		aStk.Append('4');
		aStk.Append('5');
		aStk.Append('7');
		}break;
	case 2://0548386458
		{
		aStk.Append('0');
		aStk.Append('5');
		aStk.Append('4');
		aStk.Append('8');
		aStk.Append('3');
		aStk.Append('8');
		aStk.Append('6');
		aStk.Append('4');
		aStk.Append('5');
		aStk.Append('8');
		}break;
	case 3:	//0548387459
		{
		aStk.Append('0');
		aStk.Append('5');
		aStk.Append('4');
		aStk.Append('8');
		aStk.Append('3');
		aStk.Append('8');
		aStk.Append('7');
		aStk.Append('4');
		aStk.Append('5');
		aStk.Append('9');	
		}break;
	case 4://0548388460
		{
		aStk.Append('0');
		aStk.Append('5');
		aStk.Append('4');
		aStk.Append('8');
		aStk.Append('3');
		aStk.Append('8');
		aStk.Append('8');
		aStk.Append('4');
		aStk.Append('6');
		aStk.Append('0');
		}break;
	default:
		;	
	}	
#else
	//do not delete this line
	This error indicates that test house keys are not specified yet
	//
#endif
	}
