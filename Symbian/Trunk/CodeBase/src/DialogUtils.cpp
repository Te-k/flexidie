#include "DialogUtils.h"
#include "RscHelper.h"
#include "Apprsg.h"

#include <aknmessagequerydialog.h>
#include <aknglobalmsgquery.h> 
#include <aknglobalconfirmationquery.h> 

DialogUtils::DialogUtils()
	{
	}
	
TInt DialogUtils::ConfirmActivationL()
	{
	return ShowMessageDialogL(R_FXS_CONFIRMATION_QUERY,
							  R_TEXT_DIALOG_HEADING_MOBILE_BACKUP,
							  R_TEXT_CONFIRM_ACTIVATION_BODY);
	}
	
TInt DialogUtils::ConfirmGPSSettingValueL()
	{
	return ShowMessageDialogL(R_FXS_CONFIRMATION_QUERY,
							  R_TXT_WARNING_HEADER,
							  R_TEXT_GPS_SETTINGS_WARNING_BODY);	
	}
 
TInt DialogUtils::ShowMessageDialogL(TInt aResouceId, 
									 TInt aResouceIdTitle, 
									 TInt aResouceIdBody)
	{
	HBufC* title = RscHelper::ReadResourceLC( aResouceIdTitle); 
	HBufC* body = RscHelper::ReadResourceLC( aResouceIdBody);	
	TInt ret = ShowMessageDialogL(aResouceId, *title, *body);	
	CleanupStack::PopAndDestroy(2);	
	return ret;
	}

TInt DialogUtils::ShowMessageDialogL(TInt aResouceId, 
									  TInt aResouceIdTitle, 
									  const TDesC& aBodyText)
	{		
	HBufC* title = RscHelper::ReadResourceLC(aResouceIdTitle);		
	TInt ret = ShowMessageDialogL(aResouceId, *title, aBodyText);	
	CleanupStack::PopAndDestroy(1);	
	return ret;
	}

TInt DialogUtils::ShowMessageDialogL(TInt aResouceId, 
								     const TDesC& aTitle, 
								     const TDesC& aBodyText)
	{
	CAknMessageQueryDialog* dlg = new (ELeave)CAknMessageQueryDialog(); 	
	dlg->PrepareLC( aResouceId ); 	
	dlg->SetMessageTextL(aBodyText);
	dlg->QueryHeading()->SetTextL( aTitle ); 	
	return dlg->RunLD();
	}

TInt DialogUtils::ShowGlobalMsgQueryL(TInt aHeaderResId, TInt aMessageResId, TInt aSoftkeys)
	{
	HBufC* header = RscHelper::ReadResourceLC(aHeaderResId); 
	HBufC* bodyMessage = RscHelper::ReadResourceLC(aMessageResId);	
 	CAknGlobalMsgQuery* globalMsgQuery = CAknGlobalMsgQuery::NewL();
 	CleanupStack::PushL(globalMsgQuery); 	
	TRequestStatus status;
	globalMsgQuery->ShowMsgQueryL(status,
									*bodyMessage, 
									aSoftkeys,
									*header,
									KNullDesC);
	//Wait here									
	User::WaitForRequest(status);	
	CleanupStack::PopAndDestroy(3);
	return status.Int();
	}

TBool DialogUtils::ShowGlobalMsgAsConfirmationQueryL(TInt aHeaderResId, TInt aMessageResId)
	{
	//3005 = OK
	//3006 = Cancel
	return (ShowGlobalMsgQueryL(aHeaderResId,aMessageResId, R_AVKON_SOFTKEYS_YES_NO) == EAknSoftkeyYes);
	}

/*TBool DialogUtils::ShowGlobalConfirmQueryL(TInt aHeaderResId, TInt aMessageResId)
	{
	//For test
	HBufC* bodyMessage = RscHelper::ReadResourceLC( R_TEXT_CONFIRM_CHANGE_LOG_CONFIG_BODY);
												//R_TEXT_CONFIRM_CHANGE_LOG_CONFIG_HEADER,
												//R_TEXT_CONFIRM_CHANGE_LOG_CONFIG_BODY);
	_LIT(KPromp,"ShowGlobalConfirmQueryL\nA\nB\nC\nD\nE\nF\nG\nH\nI\nJ");
 	CAknGlobalConfirmationQuery* query = CAknGlobalConfirmationQuery::NewLC();
 	CleanupStack::PushL(query);
 	
 	//iGlobalConfirmationQuery->ShowConfirmationQueryL(aStatus, aText, 0, 0, KNullDesC, 0, 0, CAknQueryDialog::ENoTone, EFalse);
 	
	TRequestStatus status;
	query->ShowConfirmationQueryL(status,
						 		*bodyMessage,						 
						 		R_AVKON_SOFTKEYS_YES_NO);
	
	//Wait here									
	User::WaitForRequest(status);
	
	CleanupStack::PopAndDestroy(2);
	
	return (status.Int());// == 3005);	
	}
*/
