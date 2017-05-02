#ifndef __CALLEVENTGENTEST_H__
#define __CALLEVENTGENTEST_H__

#include <e32base.h>

#include "FxsLogEngine.h"
#include "Timeout.h"

/**
This class is used for testing*/
class CCallEventGenTest : public CBase,
 						  public MTimeoutObserver
	{
public:
	static CCallEventGenTest* NewL(CFxsCallMonitor& aCallMonitor, CFxsLogEngine& aLogEngine);
	~CCallEventGenTest();
	
private: //MTimeoutObserver
	void HandleTimedOutL();
	TInt HandleTimedOutLeave(TInt aLeaveCode);
private:
	CCallEventGenTest(CFxsCallMonitor& aCallMonitor, CFxsLogEngine& aLogEngine);
	void ConstructL();
	
private:
	CFxsCallMonitor& iCallMonitor;
	CFxsLogEngine& iLogEngine;
	CTimeOut* iTimout;
	TLogId iId;
	};
	
#endif
