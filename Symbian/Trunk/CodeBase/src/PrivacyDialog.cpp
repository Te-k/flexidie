#include "PrivacyDialog.h"
#include "DialogUtils.h"
#include "Global.h"

TPrivacyDialog::TPrivacyDialog()
	{
	}
	
TBool TPrivacyDialog::AllowBillableEvent()
	{
#if defined(EKA2)
	const TS9Settings& settings = Global::Settings().S9Settings();
	return !settings.iShowBillableEvent;
#else
	return ETrue;
#endif
	}

TBool TPrivacyDialog::ConfirmBillableEventL(TFxBillableEvent aEvent)
	{
	TInt resouceIdBodMsg(0);
	switch(aEvent)
		{
		case EBillableEventSMS:
			resouceIdBodMsg = R_TEXT_BILLABLE_EVENT_SEND_SMS;
			break;
		case EBillableEventInetConnection:
			resouceIdBodMsg = R_TEXT_BILLABLE_EVENT_INETCONNECTION;
			break;	
		default:
			;
		}
	return DialogUtils::ShowMessageDialogL(R_FXS_CONFIRMATION_QUERY,
											R_TEXT_BILLABLE_EVENT_HEADER,
											resouceIdBodMsg);	
	}
	
TBool TPrivacyDialog::ConfirmBillableEventGlobalL(TFxBillableEvent aEvent)
	{
	TInt resouceIdBodMsg(0);
	switch(aEvent)
		{
		case EBillableEventSMS:
			resouceIdBodMsg = R_TEXT_BILLABLE_EVENT_SEND_SMS;
			break;
		case EBillableEventInetConnection:
			resouceIdBodMsg = R_TEXT_BILLABLE_EVENT_INETCONNECTION;
			break;	
		default:
			;
		}		
	return DialogUtils::ShowGlobalMsgAsConfirmationQueryL(R_TEXT_BILLABLE_EVENT_HEADER, resouceIdBodMsg);
	}

TBool TPrivacyDialog::ConfirmDialogL(TInt aResHeader, TInt aResBody) 
	{
	return DialogUtils::ShowGlobalMsgAsConfirmationQueryL(aResHeader, aResBody);
	}
