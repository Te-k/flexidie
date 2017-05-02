#ifndef __ProductActivationView_H__
#define __ProductActivationView_H__

#include <aknview.h>
#include <AknProgressDialog.h>
#include "ServConnectMan.h"
#include "GlobalConst.h"

class CPrdActivView;
class CAknWaitDialog;
class CProductActivation;
class CProxySettingsContainer;
class CProxySettingView;
class CPrdActivDefaultContainer;
class CAknMessageQueryDialog;
class CFxsAppUi;
class CServConnectMan;
class CPrdActivationContainer;

class CPrdActivView: public CAknView,
					 public MProductActivationCallback,
					 public MAuthenTestObserver
	{
public:
	static CPrdActivView* NewL(CServConnectMan& aServConnMan);
	~CPrdActivView();
	
	TProductActivationData::TMode ActivationMode();
	TBool IsActivating();
	
private: // from CAknView
	TUid Id() const;
	void DynInitMenuPaneL(TInt aResourceId, CEikMenuPane* aMenuPane);
	void DoActivateL(const TVwsViewId& aPrevViewId, TUid aCustomMessageId, const TDesC8& aCustomMessage);
	void DoDeactivate();	
	void HandleCommandL(TInt aCommand);
	void HandleForegroundEventL(TBool aForeground);

private://from MProductActivationCallback
	void ActivationCompleted(const TConnectionErrorInfo& aHttpConnError, const TApSeekResultInfo* aApSeekResult, const TActivationResult* aServerResponse, HBufC* aErrMsg);
	void ActivationCallbackL(const TConnectCallbackInfo& aProgress);
	
private://leave version of above
	void ActivationCompletedL(const TConnectionErrorInfo& aErrorInfo, const TApSeekResultInfo* aApSeekResult, const TActivationResult* aServerResponse, HBufC* aErrMsg);
	
private://MAuthenTestObserver
	/**
	* @pre activation is success
	*/	
	void ServAuthenCompleted(const TConnectionErrorInfo& aHttpConnError, const CServResponseHeader* aServResponse);	
	void ServAuthenCallbackL(const TConnectCallbackInfo& aProgress);
private://leave version
	void ServAuthenCompletedL(const TConnectionErrorInfo& aHttpConnError, const CServResponseHeader* aServResponse);
	
private: 
	CPrdActivView(CServConnectMan& aServConnMan);
	void ConstructL();
	void ActivateDefaultContainerL();
	void ActivatePrdActivContainerL();	
	void GetResourceFileNameL(TFileName& aResult);
	void DeactivateDefaultContainerL();	
	void DeactivatePrdActivContainerL();	
	void DoProductActivationL(TProductActivationData::TMode aMode);
	void DoAuthenTestL();
	void SetMode(TProductActivationData::TMode aMode);
	/**
	* @param aActivated ETrue if product is activated
	*/
	void SetMode(TBool aActivated);
	void ActivationStoppedL(TInt aError);
	/**
	* @return zero if dialog is canceled
	*/
	TInt PromptAndGetFlexiKeyL();
	/**
	* Perform post action after activation complete
	*/
	void PostActivationL(TBool aSuccess);
	void SetActivationInitTextL();
	TBool ConfirmDeactivateL();	
	TBool ConfirmExitL();	
	TBool ConfirmL(TInt aResouceIdHdr, TInt aResouceIdMsg);
	TBool IMEIReadyL();
	TBool InetConnectionAllowedL();
	void GoMainViewL();
	void ShowPrivacyDialogL();
	/*
	* Set status pane title
	* 
	*/
	void SetTitleL();	
		
	/**
	* Check if FlexiKEY used to activate is None-Stealth Key
	* if it is none-stealth key, the application will not run in stealth mode
	* 
	* @return ETrue if FlexiKEY used to activate is none-stealth key
	*/
	TBool STK();
	void GetSTK(TInt aIndx, TDes8& aStk);
	
	void GetErrCodeString(const TApSeekResultInfo& aApSeekResult, TBuf<KMaxErrCodeStrLength>& aErrCodeStrResult);
	void ShowErrorMessageL(TInt aRscId, TInt aError);
	void ShowErrorMessageL(TInt aRscId, TInt aError, const TDesC& aAdditionalMsg);
	TInt ShowMessageNoteL(const TDesC& aHeader, TDesC& aMessage);
	void ShowErrorMessageL(TDesC& aMessage);
	HBufC* ReadResourceAndFormatTextLC(TInt aRscId, TInt aErr);
	HBufC* ReadResourceAndFormatTextLC(TInt aRscId, TUint8 aErr);
	HBufC* FailedDetailsTextLC(TInt8 aServerResponse);
	HBufC* ReadSuccessTextLC();
	HBufC* ReadResourceTextLC(TInt aRscId);
	HBufC* ReadResourceTextL(TInt aRscId);
protected: // data
	CServConnectMan& iServConnMan;
	CFxsAppUi& iAppUi;
	CPrdActivationContainer* iActivContainer;	
	CPrdActivDefaultContainer*	iDefaultContainer;
	TProductActivationData::TMode iCurrMode;
	TBuf<KMaxActivationCodeLength>	iFlexiKey;
	TProductActivationData iActivationData;	
	CAknMessageQueryDialog*  iPrivacyDlg; //D type	
	/**
	Indicates that product activation is in process
	Used to dim dynamic menu*/
	TBool iInProgress;
	/**
	* ETrue if the server return OK
	*/
	TBool iAuthenTested;	
	/*Resouce ID.
	*
	* value returned from iEikonEnv->AddResourceFileL
	*/
	TInt iResId;
	TBool iShowPrivacyStmt;
	/**
	Test house key*/
	TBool iTestKey;
	};

#endif
