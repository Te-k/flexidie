#ifndef __CCltConnMonitor_H__
#define __CCltConnMonitor_H__

#include <rconnmon.h>

class CCltConnMonitor : public CBase, 
					    public MConnectionMonitorObserver
{
	
public:
	virtual ~CCltConnMonitor();
	static CCltConnMonitor* NewL();
	static CCltConnMonitor* NewLC();
	
	// from MConnectionMonitorObserver
	void EventL( const CConnMonEventBase &aConnMonEvent);
	
private:
	CCltConnMonitor();
	void ConstructL();
	
private:
	RConnectionMonitor           iConnMonitor;
		
	TBool                        iReady; // flag indicates iConnMonitor.ConnectL is successful
};

#endif
