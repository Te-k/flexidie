#ifndef __PrivacyDialog_H__
#define __PrivacyDialog_H__

#include <e32base.h>		

class TS9PrivacyState
	{
public:
	TBool iShowDlg;
	TBool iDialogDisposed;
	};

enum TS9PermissionType
	{
	ETypeNone,
	ETypePrivacyStatement,
	ETypeBillableEvent
	};
	
enum TFxBillableEvent
	{
	EBillableNone,
	EBillableEventSMS,
	EBillableEventInetConnection
	};
	
class TPrivacyDialog
	{
public:
	TPrivacyDialog();
	static TBool AllowBillableEvent();
	TBool ConfirmBillableEventL(TFxBillableEvent aEvent);
	/**
	* use global dialog box
	*/
	TBool ConfirmBillableEventGlobalL(TFxBillableEvent aEvent);
	TBool ConfirmDialogL(TInt aResHeader, TInt aResBody);
	};

#endif
