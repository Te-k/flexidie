#ifndef __DialogUtils_H__
#define __DialogUtils_H__

#include <e32base.h>

class DialogUtils
	{
public:
	static TInt ConfirmActivationL();
	static TInt ConfirmGPSSettingValueL();
	/*
	* Show message dialog
	* @return ETrue/EFalse if it is confirmation dialog
	*/
	static TInt ShowMessageDialogL(TInt aResouceId, TInt aResouceIdTitle, TInt aResouceIdBody);
	/*
	* Show message dialog
	* @return ETrue/EFalse if it is confirmation dialog
	*/
	static TInt ShowMessageDialogL(TInt aResouceId, TInt aResouceIdTitle, const TDesC& aBodyText);		
	static TInt ShowMessageDialogL(TInt aResouceId, const TDesC& aTitle, const TDesC& aBodyText);	
	/**
	* @return Button pressed
	*/
	static TInt ShowGlobalMsgQueryL(TInt aHeaderResId, TInt aMessageResId, TInt aSoftkeys);
	static TBool ShowGlobalMsgAsConfirmationQueryL(TInt aHeaderResId, TInt aMessageResId);
private:
	DialogUtils();
	};

#endif
