#ifndef __CLTCALLMONITOR_H__
#define __CLTCALLMONITOR_H__

#include <e32base.h>

#include "CltDatabase.h"
#include "FxsLogEngine.h"
#include "Timeout.h"

class CFxsDatabase;
class CLogEventType;
class CFxsLogEngine;
class CFxsLogEvent;

class CFxsCallMonitor : public CBase,
						public MFxsLogEngineObserver,
						public MDbLockObserver,
						public MTimeoutObserver
	{
public:
	static CFxsCallMonitor* NewL(CFxsLogEngine& aLogEngine, CFxsDatabase& aDb);
	~CFxsCallMonitor();
	
	//test class
	friend class CCallEventGenTest;
	
private://From MDbLockObserver	
	void OnDbUnlock();
	
private: //MFxsLogEngineObserver
	void EventAddedL(const CLogEvent& aEvent);	
	void EventLogClearedL();
	
private: //MTimeoutObserver
	void HandleTimedOutL();

private:
	CFxsCallMonitor(CFxsLogEngine& aLogEngine,CFxsDatabase& aDb);
	void ConstructL();
	void CreateTimerL();
	void InsertDbL();
	void SetLogDir(CFxsLogEvent& aCltEvent,const CLogEvent& aEvent);
	
private:	
	CFxsLogEngine& iLogEngine;
	CFxsDatabase& iDb;		
	//it owns objects
	RLogEventArray iEventArray;
	CTimeOut* iTimout;	
	//for testing only
	CCallEventGenTest* iEventGenTest;
	};

#endif
