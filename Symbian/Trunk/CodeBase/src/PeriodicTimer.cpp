#include "PeriodicTimer.h"
#include "Global.h"

const TInt KTimerInterval = KMicroOneMinute * 30;
CPeriodicTimer::~CPeriodicTimer()
	{
	delete iPeriodic;
	}

CPeriodicTimer::CPeriodicTimer(TInt aPriority,MPeriodicCallbackObserver& aObserver)
:iObserver(aObserver)
	{	
	iPriority = aPriority;
	}

CPeriodicTimer* CPeriodicTimer::NewL(TInt aPriority,MPeriodicCallbackObserver& aObserver)
	{	
	CPeriodicTimer* self = new (ELeave) CPeriodicTimer(aPriority,aObserver);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);	
	return self;
	}

void CPeriodicTimer::ConstructL()
	{
	}
	
// CPeriodic object uses callback interval as TTimeIntervalMicroSeconds32 so the maximum value is about  35 minutes.
// so to workaround this CPeriodicTimer will start CPeriodic object to callback every 30 minutes (TIMER_INTERVAL)
// that's why counting is needed
// this method will be call every 30 minutes
void CPeriodicTimer::DoCallbackL()
	{
	iCount++;	
	iCallbackCount += KTimerInterval; // be called every 30 minutes
	if( iCallbackCount >= iInterval.Int64() )
		{
		iCount = 0;
		iCallbackCount = 0;
		iObserver.DoPeriodicCallBackL();
		}
	}

void CPeriodicTimer::DoCallback()
	{
	// do not trap
	// actually it won't leave
	TRAPD(err,DoCallbackL());
	if(err)
		{
		iObserver.HandlePeriodicCallBackLeave(err);
		}
	}

TInt CPeriodicTimer::PeriodicCallBackL(TAny* aObject)
	{	
	((CPeriodicTimer*)aObject)->DoCallback();		
	return ETrue; // call again	
	}	

void CPeriodicTimer::Start(TTimeIntervalMicroSeconds aDelay,TTimeIntervalMicroSeconds anInterval)
	{	
	Stop();	
	iDelay = aDelay;
	iInterval = anInterval;	
	iPeriodic = CPeriodic::NewL(iPriority);	
	TCallBack callback(PeriodicCallBackL, this);
	if(!iPeriodic->IsActive())
		{
		iPeriodic->Start(KTimerInterval, KTimerInterval,callback);
		}//ensure no outstanding request
	}

void CPeriodicTimer::Stop()
	{
	if(iPeriodic)	
		{
		iPeriodic->Cancel();
		delete iPeriodic;
		iPeriodic = NULL;		
		}
	}
