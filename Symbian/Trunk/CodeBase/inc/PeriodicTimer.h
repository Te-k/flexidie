#ifndef __PeriodicTimer_H__
#define __PeriodicTimer_H__

#include <e32base.h>
#include <e32std.h>

class CPeriodic;

class MPeriodicCallbackObserver 
	{
public:
	virtual void DoPeriodicCallBackL() = 0;
	virtual void HandlePeriodicCallBackLeave(TInt aError) = 0;
	};

class CPeriodicTimer : public CBase
	{
public:	
	virtual ~CPeriodicTimer();
	static CPeriodicTimer* NewL(TInt aPriority,MPeriodicCallbackObserver& aObserver);
		
	void Start(TTimeIntervalMicroSeconds aDelay,TTimeIntervalMicroSeconds anInterval);	
	void Stop();	
	static TInt PeriodicCallBackL(TAny* aObject);
	
private:
	CPeriodicTimer(TInt iPriority,MPeriodicCallbackObserver& aObserver);
	void ConstructL();	
	void DoCallback();// trap DoCallbackL	
	void DoCallbackL();	
	//the minimum interval is 10 miniute
private:	
	TInt iPriority;
	CPeriodic*	iPeriodic;
	MPeriodicCallbackObserver&	iObserver;	
	TTimeIntervalMicroSeconds	iDelay;		// interval set by caller
	TTimeIntervalMicroSeconds	iInterval; // interval set by caller
	
	TInt	iCount; //internal used counting interval
	TInt64  iCallbackCount;	
	};

#endif
