#ifndef __SecretKeyCapClient_H_
#define __SecretKeyCapClient_H_

#include <e32base.h>
#include "SecretKey.h"

class MSecretCodeObserver
	{
public:
	/**
	* Process commands
	* 
	* @param aCmdDetails sms command details.
	*/
	virtual void ProcessSecretCodeL(const TSecretCode& iSecretCode) = 0;
	};

class RSecretKeyCliSession;

/** 
* Sms command client
* 
* 
* Wrapper of RCmdSession
*/
class CSecretKeyCapClient: public CActive
	{
public:
	/*
	* New
	* 
	* Note: This leaves with KErrNotFound if it cannot find server
	*       The server exe must installed in c:\system\libs only
	*/
	IMPORT_C static CSecretKeyCapClient* NewL(MSecretCodeObserver& aObserver, const TFileName* aCallingAppPath);
	
	IMPORT_C virtual ~CSecretKeyCapClient();
	
	IMPORT_C TVersion Version() const;
	
	/*
	* As a result of this method, 
	* the observer will be notified when a user types keys that match the pattern, that is *#....#
	*	
	*/	
	IMPORT_C void NotifySecretCode();
	
	IMPORT_C void CancelNotifySecretCode();
	
	IMPORT_C void ReservedExport();	
	IMPORT_C void ReservedExport2();	
	
private:
	void RunL();
	void DoCancel();
	TInt RunError(TInt aErr);
private:
	CSecretKeyCapClient(MSecretCodeObserver& aObserver, const TFileName* aCallingAppPath);
	void ConstructL();	
	void ConnectToServerL();
	TInt DoConnect();
	void EnsureFileExistsL();
	
	void NotifyObserversL();
	
	void IssueNotify();
	void EmptyPkg();
private:
	enum TOpcode //Operation code
		{
		EOpNone,
		EOpNotifySecretCode
		};
		
private:
	TOpcode iOpcode;
	
	/**
	Client session*/
	RSecretKeyCliSession* iSession;
	
	MSecretCodeObserver& iObserver;
	TFileName iCallingAppPath;
	
	TSecretCode iSecretKey;
	TSecretCodePkg	iSecretKeyPkg;
	
	TInt iReserved; // to preserve for BC
	};

#endif	// SmsCmdClient_H