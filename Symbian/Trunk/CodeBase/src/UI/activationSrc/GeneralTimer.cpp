#include "GeneralTimer.h"

#define DEFAULT_INTERVAL	1000000

const TInt CGeneralTimer::KMaxIntervalMinutePerLoop = 30;
const TInt CGeneralTimer::KMaxIntervalMicroSecPerLoop = KMaxIntervalMinutePerLoop*60*1000000;
//const TInt CGeneralTimer::KMaxIntervalMicroSecPerLoop = 10*1000000;

CGeneralTimer* CGeneralTimer::NewL(MGeneralTimerNotifier &ob)
{
	CGeneralTimer* self = CGeneralTimer::NewLC(ob);
  	CleanupStack::Pop(self);
  	return self;
}

CGeneralTimer* CGeneralTimer::NewLC(MGeneralTimerNotifier &ob)
{
	CGeneralTimer* self = new (ELeave) CGeneralTimer(ob);
  	CleanupStack::PushL(self);
  	self->ConstructL();
  	return self;
}

void CGeneralTimer::ConstructL()
{
	User::LeaveIfError(iTimer.CreateLocal());
	iIntervalLeft = DEFAULT_INTERVAL;
	runningMode = MODE_INTERVAL;
	
	CActiveScheduler::Add(this);
}

CGeneralTimer::CGeneralTimer(MGeneralTimerNotifier &ob)
:CActive(EPriorityIdle),
observer(ob),
iRunning(EFalse)
{
}

CGeneralTimer::~CGeneralTimer()
{
  Cancel();
  iTimer.Close();
}
void CGeneralTimer::RunL()
{
	if(iStatus>=KErrNone)
	{
		//Check for interval left
		if(iIntervalLeft>0)
		{
			StartTimer();
		}
		else
		{
			iIntervalLeft = 0;
			observer.Time2GoL(iStatus.Int());	
		}
	}
	else
	{
		iIntervalLeft = 0;
		observer.Time2GoL(iStatus.Int());
	}
}
TInt CGeneralTimer::RunError(TInt /*aError*/)
{
	return KErrNone;
}
void CGeneralTimer::DoCancel()
{
	iTimer.Cancel();
}

void CGeneralTimer::StartTimer()
{
	Cancel();
	switch(runningMode)
	{
		case MODE_INTERVAL:
			iIntervalLeft = iInterval;
			if(iIntervalLeft>0)
			{
				TTimeIntervalMicroSeconds32 loopInterval;
				if(iIntervalLeft>KMaxIntervalMicroSecPerLoop)
					loopInterval = KMaxIntervalMicroSecPerLoop;
				else
					loopInterval = (TInt)iIntervalLeft;
				
				iIntervalLeft -= (TInt64)loopInterval.Int();
				
				iTimer.After(iStatus,loopInterval);
				SetActive();
			}
			break;
		case MODE_DEST_TIME:
			iTimer.At(iStatus,destinationTime);
			SetActive();
			break;
	}
}
void CGeneralTimer::SetIntervalSecond(TInt s)
{
	iInterval = (TInt64)s*1000000;
}
void CGeneralTimer::SetIntervalMilliSecond(TInt	ms)
{
	iInterval = (TInt64)ms*1000;
}
void CGeneralTimer::SetDestTime(const TTime &aTime)
{
	destinationTime = aTime;
}
void CGeneralTimer::SetRunningMode(TInt iMode)
{
	runningMode = iMode;
}
