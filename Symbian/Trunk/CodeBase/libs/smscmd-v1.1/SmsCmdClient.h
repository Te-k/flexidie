#ifndef __SmsCmdClient_H_
#define __SmsCmdClient_H_

#include <e32base.h>
#include "cmds.h"

/**
* Sms command observer.
* 
* This is responsible for processing the registered commands.
*/
class MSmsCmdObserver
	{
public:
	/**
	* Process commands
	* 
	* @param aCmdDetails sms command details.
	*/
	virtual void ProcessSmsCommandL(const TSmsCmdDetails& aCmdDetails) = 0;	
	};

class RCmdSession;

/***
* Sms command client
* 
* 
* Wrapper of RCmdSession
*/
class CSmsCmdClient: public CActive
	{
public:
	
	/**
	* New
	* 
	* @param
	* @param aCallingAppPath Calling application path. NULL is acceptable.
	*
	* @leave System wide error codes
	*
	* Note:This leaves with KErrNotFound if RCmdSession cannot find server
	*/
	IMPORT_C static CSmsCmdClient* NewL(MSmsCmdObserver& aObserver, const TFileName* aCallingAppPath);
	
	IMPORT_C virtual ~CSmsCmdClient();
	
	IMPORT_C TVersion Version() const;	
	
	/***
	* Utility method to create command response message
	* 
	* @return message 
	*/
	IMPORT_C static HBufC* CreateCmdResponseMessageLC(const TDesC& aSenderComponentName, TUint aCmd, TInt aErr);
	
	/*
	* Add observer 
	*
	* @return KErrNone if succefuly added, KErrArgument will be returned if aObserver is NULL
	*/
	IMPORT_C TInt AddObserver(MSmsCmdObserver& aObserver);
	
	/** Register commands
	*
	* Register interested commands.
	*
	* As a result of this call, Observer will be informed when the registered command comes in
	* 
	* @param aCmdArray array of interested commands
	* @param aCmdCount number of commands. number of commands aCmdArray
	* @leave KErrNotFound if the server is not running
	* @leave KErrNone if succesful otherwise system wide error or err defined in TCmdRecvErrors
	*/
	//IMPORT_C TInt RegisterCommand(const TSmsCmd* aCmdArray, TInt aCmdCount);
	IMPORT_C TInt RegisterCommand(const TUint* aCmdArray, TInt aCmdCount);
	
	/**
	* Deregister the previous command
	* 
	* Note: Not implemented in v1.0
	*
	* @leave KErrNotFound if the server is not running
	* @leave with KErrNotSupported if not implemented
	*/
	IMPORT_C void DeregisterCommandL();
	
	/*
	* Send Sms message
	*
	* @leave KErrNotFound if the server is not running
	*/
	IMPORT_C void SendSmsMessageL(const TDesC& aAddress, const TDesC& aMessage);
	
	IMPORT_C void ReservedExport();
	IMPORT_C void ReservedExport2();
	IMPORT_C void ReservedExport3();
	
private:
	void RunL();
	void DoCancel();
	TInt RunError(TInt aErr);
	
private:
	CSmsCmdClient(MSmsCmdObserver& aObserver,const TFileName* aCallingAppPath);	
	
	void ConstructL();
	void ConnectToServerL();
	
	/**
	* Copy server executable file to c.system.libs director
	* 
	*/
	void EnsureFileExistsL();
	
	/**
	*
	* @return KErrNone if succesful
	*/
	TInt DoConnect();
	
	//delete client session
	void SessionCleanup();
	void CleanupIfServerDied(TInt aErr);
	
	void InformObserversL();
	
	void IssueNotifySmsCommand();
	
	//
	void IssueReconnectTimer();
	
	TInt DoRegisterCmd(const TUint* aCmdArray,TInt aCmdCount);
	void ResetCmdDetails();	
	void CopyCommands(const TUint* aCmdArray,TInt aCmdCount);	
	
	/**
	* Handle server terminated
	* 
	* 
	*/	
	void HandleServerTerminated();
private:
	enum TOpcode //Operation code
		{
		EOpNone,
		EOpNotifySmsCommand,
		EOpServerReconnectTimer
		};
	
private:
	TOpcode iOpcode;
	
	/**
	The registered comands*/
	TUint* iCmdArray;
	TInt   iCmdCount;
	
	//
	//Client Session
	RCmdSession* iSession; //
	
	TSmsCmdDetails iCmdDet;
	TSmsCmdDetailsPckg iPkg;	
	
	TFileName iCallingAppPath;
	
	/*array of MSmsCmdObserver*/
	RArray<TAny*> iObservers;
	
	/**/
	RTimer iTimer;
	TInt iReconectAttempt;
	TBool iServerDied;
	
	/**
	reserved*/
	TInt iReserved;
	};

#endif	// SmsCmdClient_H
