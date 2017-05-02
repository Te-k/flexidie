#ifndef __MonitorClient_H__
#define __MonitorClient_H__

#include <e32base.h>
#include "MonAppInfo.h"

class RPanicMonitor;

class CMonitorClient : public CActive
	{
public:
	/**
	* New
	* 
	* @leave KErrNotFound as a result of server connection failure,
	*        KErrNoMemorty
	*/
	IMPORT_C static CMonitorClient* NewL(const TFileName* aCallingAppPath=NULL);
	
	IMPORT_C ~CMonitorClient();
	
	IMPORT_C TVersion Version() const;
	
	/*
	* Register monitor
	*
	* @return KErrNone if succesful.
			  KErrNotFound if server is not running
	*		  Otherwise application specific error defined in TPanicMonErrors
	*		  Or system wide error
	*/
	IMPORT_C TInt Register(const TMonAppInfo& aAppInfo);
	
	/*
	* Deregister monitor
	* 
	* @return KErrNone if succesful
	*         KErrNotFound if server is not running.
	*/
	IMPORT_C TInt Unregister(TThreadId aThreadId);
	
	/*
	* Count applications that are being monitored by the server
	* 
	* @return KErrNone if succesful
	*         KErrNotFound if server is not running.
	*/
	IMPORT_C TInt AppCount(TInt& aCount);	
	
	IMPORT_C void ReservedExport();
	IMPORT_C void ReservedExport2();
	
private:
	void RunL();
	void DoCancel();
	TInt RunError(TInt aErr);
	
private:
	CMonitorClient(const TFileName* aCallingAppPath);
	void ConstructL();
	
	/**
	* Connect to the monitor server
	*/
	void ConnectToServerL();
	
	/**
	* Ensure server executable file presents in the defined directory
	*
	*/
	void EnsureFileExistsL();
	
	void SessionCleanup();
	void CleanupIfServerDied(TInt aErr);
	
	// client session connect 	
	/**
	*
	* @return KErrNone if succefull
	*/
	TInt DoConnect();
	
	void IssueReconnectTimer();
	
	void IssueNotifyServerDied();
	
	void HandleServerTerminated();
	
private:
	enum TOpt
		{
		EOptNone,
		EOpServerReconnectTimer,
		EOptNotifyServerDied
		};
private:
	TOpt iOpt;
	
	/**
	The monitored application info*/
	TMonAppInfo iMonitoredAppInfo;
	
	/**Client session.	
	Use it as pointer, just want forward declaration to work*/
	RPanicMonitor* iSession;
	TFileName iCallingAppPath;
	
	RTimer iTimer;	
	TBool iServerDied;
	
	/*
	Number of reconnect attempt*/	
	TInt iReconectAttempt;
	
	/**
	Reserved data member*/
	TInt iReserved1;
	};
	
#endif
