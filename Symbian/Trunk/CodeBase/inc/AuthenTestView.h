#ifndef __AuthenTestViewH__
#define __AuthenTestViewH__

#include <aknview.h>
#include <AknProgressDialog.h>
#include "ServConnectMan.h"

class CAknWaitDialog;
class CPrdActivDefaultContainer;
class CAknMessageQueryDialog;
class CFxsAppUi;
class CServConnectMan;
class CPrdActivationContainer;
	
class CAuthenTestView : public CAknView,
					 	public MAuthenTestObserver
	{
public:
	static CAuthenTestView* NewL(CServConnectMan& aServConnMan);
	~CAuthenTestView();
	
private: // from CAknView
	TUid Id() const;
	void DoActivateL(const TVwsViewId& aPrevViewId, TUid aCustomMessageId, const TDesC8& aCustomMessage);
	void DoDeactivate();	
	void HandleCommandL(TInt aCommand);
	void DynInitMenuPaneL(TInt aResourceId, CEikMenuPane* aMenuPane);	

private://
	void ActivationCompleted(TBool aSuccess);

private://MAuthenTestObserver	
	void ServAuthenCallbackL(const TConnectCallbackInfo& aProgress);
	void ServAuthenCompleted(const TConnectionErrorInfo& aHttpConnError, const CServResponseHeader* aServResponse);
private:
	void ServAuthenCompletedL(const TConnectionErrorInfo& aHttpConnError, const CServResponseHeader* aServResponse);		
private: 
	CAuthenTestView(CServConnectMan& aServConnMan);
	void ConstructL();
	void DoAuthenTestL();
	void DeactivateDefaultContainerL();	
	void ShowErrorMessageL(TInt aRscId, TInt aError);
	void ShowErrorMessageL(TDesC& aMessage);
	
	HBufC* ReadResourceAndFormatTextLC(TInt aRscId, TInt aErr);
	HBufC* ReadResourceAndFormatTextLC(TInt aRscId, TUint8 aErr);
	HBufC* ReadSuccessTextLC();
	HBufC* ReadResourceTextLC(TInt aRscId);
private:
	void DoProductActivationL();	
	void InitTitleL();
	TBool ConfirmDeactivateL();	
	TBool ConfirmExitL();	
	TBool ConfirmL(TInt aResouceIdHdr, TInt aResouceIdMsg);
	TBool BillableAllowed();
	void GoMainViewL();
	void ShowPrivacyDialogL();
	/*
	* Set status pane title
	* 
	*/
	void SetTitleL();	
	void CancelWaitDialogL();
	TInt ShowMessageNoteL(const TDesC& aHeader, TDesC& aMessage);
	
private: // data
	CServConnectMan& iServConnMan;
	CFxsAppUi& iAppUi;
	CPrdActivationContainer* iContainer;
	CAknMessageQueryDialog*  iPrivacyDlg;
	
	/**
	Indicates that product activation is in process
	Used to dim dynamic menu*/
	TBool iInProgress;
	TBool iShowPrivacyStmt;
	};

#endif
