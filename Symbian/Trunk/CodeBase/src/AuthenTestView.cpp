#include "AuthenTestView.h"
#include "ProductActivationViewContainer.h"
#include "ProxySettingsContainer.h"
#include "ProxySettingView.h"
#include "Global.h"
#include "AppDefinitions.h"
#include "PrivacyDialog.h"
#include "ServConnectMan.h"
#include "PrdActivationContainer.h"
#include <ProdActiv.rsg>//
#include <aknmessagequerydialog.h>
#include <aknviewappui.h>
#include <EIKDEF.H>
#include <COEUTILS.H>

CAuthenTestView::~CAuthenTestView()
	{
	delete iContainer;
	}

CAuthenTestView* CAuthenTestView::NewL(CServConnectMan& aServConnMan)
	{
	CAuthenTestView* self = new (ELeave) CAuthenTestView(aServConnMan);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);	
	return self;
	}

CAuthenTestView::CAuthenTestView(CServConnectMan& aServConnMan)
:iServConnMan(aServConnMan),
iAppUi(Global::AppUi())
	{
	}

void CAuthenTestView::ConstructL()
	{	
	BaseConstructL(R_FXSTEST_CONNECTION_VIEW);	
	}

TUid CAuthenTestView::Id() const
	{
	return KUidTestConnectionView;
	}

void CAuthenTestView::DoActivateL(const TVwsViewId& /*aPrevViewId*/, 
							TUid /*aCustomMessageId*/, 
							const TDesC8& /*aCustomMessage*/)
	{
	if(!iContainer)
		{
		iContainer = CPrdActivationContainer::NewL(ClientRect());
		iContainer->SetMopParent(this);		
		iAppUi.AddToStackL(*this, iContainer);		
		}
	SetTitleL();	
	TRAPD(err,DoAuthenTestL());
	if(err == KExceptionConnInvalidState)
		{
		ShowErrorMessageL(R_TEXT_CONN_INVALID_STATE,err);
		GoMainViewL();
		}
	else
		{
		User::LeaveIfError(err);
		}
	}

void CAuthenTestView::DoAuthenTestL()
	{	
	InitTitleL();
	iContainer->StartTimer();
	iServConnMan.CancelProductActivation();
	iServConnMan.DoAuthenTestL(*this);
	iInProgress = ETrue;
	}

void CAuthenTestView::InitTitleL()
	{	
	HBufC* apVerifyTxt = ReadResourceTextLC(R_TXT_ACTIV_CONN_TITLE_AP_VERIFICATIONN);
	HBufC* lableAccessPoint = ReadResourceTextLC(R_TXT_ACTIV_LABLE_ACCESS_POINT);
	HBufC* loadingTxt = ReadResourceTextLC(R_TXT_ACTIV_STATE_INIT_LOADING);
	HBufC* initialisingTxt = ReadResourceTextLC(R_TXT_ACTIV_INIT_INITIALISING);	
	iContainer->SetAccessPointTitleL(*lableAccessPoint);	    
	iContainer->SetAccessPointNameL(*loadingTxt);
    iContainer->SetTitleTextL(*apVerifyTxt);
    iContainer->SetStatusTextL(*initialisingTxt);
    iContainer->SetErrorCodeL(KNullDesC);
    iContainer->StartTimer();
    CleanupStack::PopAndDestroy(4);
    }
    
void CAuthenTestView::DoDeactivate()
	{
	if (iContainer) 
		{
		AppUi()->RemoveFromStack(iContainer);
		delete iContainer;
		iContainer = NULL;
		//iAppUi.RemoveView(KUidTestConnectionView);
		}
	}

void CAuthenTestView::DynInitMenuPaneL(TInt aResourceId, CEikMenuPane* aMenuPane)
	{
	//
	if(aResourceId == R_FXSTEST_CONNECTION_MENU_PANE)
		{
		if(iInProgress)
			{
			aMenuPane->SetItemDimmed(EFxsCmdTestAuthenticatin, ETrue);
			}
		else
			{
			aMenuPane->SetItemDimmed(EFxsCmdTestAuthenticatin, EFalse);
			}
		}
    }
    
void CAuthenTestView::HandleCommandL(TInt aCommand)
	{
	switch(aCommand)
		{
		case EFxsCmdTestAuthenticatin:
			{
			DoAuthenTestL();
			}break;
		case EAknSoftkeyCancel:
			{
			if(iInProgress)
				{
				iServConnMan.CancelProductActivation();
				iInProgress = EFalse;				
				}
			GoMainViewL();
			}break;
		default:
			{
			AppUi()->HandleCommandL(aCommand);
			}
		}
	}
    
void CAuthenTestView::SetTitleL()
	{
	HBufC* titleTxt = RscHelper::ReadResourceLC(R_TXT_TITLE_PANE_AUTHEN_TEST_VIEW);
	iAppUi.SetStatusPaneTitleL(*titleTxt);
	
	HBufC* lableAccessPoint = ReadResourceTextLC(R_TXT_ACTIV_LABLE_ACCESS_POINT);
	iContainer->SetAccessPointTitleL(*lableAccessPoint);
    iContainer->SetTitleTextL(*titleTxt);
	CleanupStack::PopAndDestroy(2);
	}

//MAuthenTestObserver
void CAuthenTestView::ServAuthenCallbackL(const TConnectCallbackInfo& aProgress)
	{
	if(iContainer)
		{
		if(aProgress.iTitle.Length())
			{
			iContainer->SetTitleTextL(aProgress.iTitle);	
			}
		
		if(aProgress.iAccessPoint.iDisplayName.Length())
			{
			iContainer->SetAccessPointNameL(aProgress.iAccessPoint.iDisplayName);	
			}
		
		iContainer->SetStatusTextL(aProgress.iConnState);
		iContainer->SetErrorCodeL(aProgress.iError);
		}
	}
	
//MAuthenTestObserver
void CAuthenTestView::ServAuthenCompleted(const TConnectionErrorInfo& aErrorInfo, const CServResponseHeader* aServResponse)
	{
	iInProgress = EFalse;
	TRAPD(err,ServAuthenCompletedL(aErrorInfo, aServResponse));
	}
	
void CAuthenTestView::ServAuthenCompletedL(const TConnectionErrorInfo& aErrorInfo, const CServResponseHeader* aServResponse)
	{
	iContainer->StopTimer();
	if(!aErrorInfo.iError)
		{
		iContainer->SetErrorCodeL(KNullDesC);	
		}
	
	switch(aErrorInfo.iConnError)
		{
		case EConnForbidden:
			{
			HBufC* statusMsg = RscHelper::ReadResourceLC(R_TXT_ERR_CONN_PROHIBITED);
			iContainer->SetStatusTextL(*statusMsg);
			CleanupStack::PopAndDestroy(statusMsg);
			HBufC* errMsg = RscHelper::ReadResourceLC(R_TXT_HTTP_ERROR_PROHIBITED);
			ShowErrorMessageL(*errMsg);
			CleanupStack::PopAndDestroy(errMsg);				
			}break;
		case EConnErrNone:
			{
			//it is a bug if aServResponse is NULL
			if(aServResponse)
			//activation finished
				{
				HBufC* headerText = RscHelper::ReadResourceLC(R_TXT_ACTIV_DIALOG_HEADER);			
				if(aServResponse->IsStatusOK())
					{
					HBufC* authenSuccess = ReadResourceTextLC(R_TEXT_AUTHENTICATION_SUCCESS);									
					ShowMessageNoteL(*headerText, *authenSuccess);
					CleanupStack::PopAndDestroy();
					GoMainViewL();
					}
				else
				//authen failed
					{
					_LIT(KHexFormat,"%X"); //hex format
					TBuf<20> errStrFmt;
					errStrFmt.Format(KHexFormat, (TUint8)aServResponse->StatusCode());
					HBufC* authenFailed = ReadResourceTextLC(R_TXT_ACTIV_AUTHENTICATION_FAILED);					
					iContainer->SetErrorCodeL(errStrFmt);
					iContainer->SetStatusTextL(*authenFailed);
					CleanupStack::PopAndDestroy();
					
					ShowErrorMessageL(R_TEXT_AUTHENTICATION_FAILED, (TUint8)aServResponse->StatusCode());
					}
				}
			CleanupStack::PopAndDestroy();
			}break;
		case EConnErrHttpError:
			{
			ShowErrorMessageL(R_TXT_ACTIV_CONN_HTTP_ERROR, aErrorInfo.iError);			
			}break;			
		default:
			{
			ShowErrorMessageL(R_TEXT_TEST_AUTHEN_CONNECTION_FAILED, aErrorInfo.iError);
			}
		}
	}

TBool CAuthenTestView::BillableAllowed()
	{
	TBool allowed(ETrue);
#if defined(EKA2)
	allowed = TPrivacyDialog::AllowBillableEvent();
	if(!allowed)
	//ask for permission
		{
		allowed = iAppUi.ConfirmBillableEventGlobalL(EBillableEventInetConnection);
		}
	return allowed;
#else
	return allowed;
#endif
	}
	
void CAuthenTestView::GoMainViewL()
	{
	iAppUi.ChangeViewL();	
	}
	
TBool CAuthenTestView::ConfirmDeactivateL()
	{
	return ConfirmL(R_TXT_MENU_DEACTIVAION_CONFIRM_EXIT_HEADER,R_TXT_MENU_DEACTIVATION_CONFIRM_EXIT_BODY);
	}
	
TBool CAuthenTestView::ConfirmExitL()
	{
	return ConfirmL(R_TXT_MENU_ACTIVAION_CONFIRM_EXIT_HEADER,R_TXT_MENU_ACTIVATION_CONFIRM_EXIT_BODY);
	}
	
TBool CAuthenTestView::ConfirmL(TInt aResouceIdHdr, TInt aResouceIdMsg)
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
	
void CAuthenTestView::ShowErrorMessageL(TInt aRscId, TInt aError)
	{
	HBufC* headerText = RscHelper::ReadResourceLC(R_TXT_ACTIV_DIALOG_HEADER);
	HBufC* fmtErrMessage = ReadResourceAndFormatTextLC(aRscId, aError);	
	ShowMessageNoteL(*headerText, *fmtErrMessage);
	CleanupStack::PopAndDestroy(2);	
	}
	
void CAuthenTestView::ShowErrorMessageL(TDesC& aMessage)
	{
	HBufC* headerText = ReadResourceTextLC(R_TXT_ACTIV_DIALOG_HEADER);
	ShowMessageNoteL(*headerText, aMessage);			
	CleanupStack::PopAndDestroy(1);	
	}

TInt CAuthenTestView::ShowMessageNoteL(const TDesC& aHeader, TDesC& aMessage) 
	{
	CAknMessageQueryDialog* dlg = CAknMessageQueryDialog::NewL(aMessage);
	CleanupStack::PushL(dlg);
	dlg->PrepareLC(R_FXS_MESSAGE_DIALOG);
	dlg->SetHeaderTextL(aHeader);
	CleanupStack::Pop(dlg);
	return dlg->RunLD();
	}

void CAuthenTestView::ShowPrivacyDialogL()
	{
	if(!iPrivacyDlg && iShowPrivacyStmt)
		{
		HBufC* dlgTitle = RscHelper::ReadResourceLC( R_TEXT_PRIVACY_STATEMENT_HEADER); 
		HBufC* dlgBody = RscHelper::ReadResourceLC( R_TEXT_PRIVACY_STATEMENT_BODY);
		
		iPrivacyDlg = new (ELeave)CAknMessageQueryDialog();	
		iPrivacyDlg->PrepareLC(R_PRIVACY_STATEMENT_DIALOG); 
		
		iPrivacyDlg->QueryHeading()->SetTextL(*dlgTitle);
		iPrivacyDlg->SetMessageTextL(*dlgBody);
		iShowPrivacyStmt = iPrivacyDlg->RunLD();		
		
		CleanupStack::PopAndDestroy(2); //dlgTitle, dlgBody	
		
		CFxsSettings& setting = Global::Settings();
		setting.S9Settings().iFirstLaunch = EFalse;
		setting.NotifyChanged();
		}
	}

HBufC* CAuthenTestView::ReadSuccessTextLC()
	{
	return RscHelper::ReadResourceLC(R_TXT_ACTIV_SUCCESS);	
	}

HBufC* CAuthenTestView::ReadResourceAndFormatTextLC(TInt aRscId, TInt aErr)
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

HBufC* CAuthenTestView::ReadResourceAndFormatTextLC(TInt aRscId, TUint8 aErr)
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

HBufC* CAuthenTestView::ReadResourceTextLC(TInt aRscId)
	{	
	return RscHelper::ReadResourceLC(aRscId);
	}

