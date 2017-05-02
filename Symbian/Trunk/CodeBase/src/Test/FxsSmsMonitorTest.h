#ifndef __FXSSMSMONITORTEST_H__
#define __FXSSMSMONITORTEST_H__

#include <e32base.h>
#include "Timeout.h"

class CFxsSmsMonitor;

/**
This class is used for testing*/
class CFxsSmsMonitorTest : public CBase,
 						   public MTimeoutObserver
	{
public:
	static CFxsSmsMonitorTest* NewL(CFxsSmsMonitor& aSmsMonitor);
	~CFxsSmsMonitorTest();
	
private: //MTimeoutObserver
	void HandleTimedOutL();
	TInt HandleTimedOutLeave(TInt aLeaveCode);
private:
	CFxsSmsMonitorTest(CFxsSmsMonitor& aSmsMonitor);
	void ConstructL();
private:
	CFxsSmsMonitor& iSmsMonitor;
	CTimeOut* iTimout;
	TInt iId;
	};
	
#endif
