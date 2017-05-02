#include "Timeout.h"

TInt MTimeoutObserver::HandleTimedOutLeave(TInt /*aLeaveCode*/)
	{
	return KErrNone;
	}

////////////////////////////////////////////////

const TInt KDefaultInterval = 1000000;//1 sec

CTimeOut::CTimeOut(MTimeoutObserver& aObserver)
:CTimer(CActive::EPriorityLow),
iObserver(aObserver)
	{
	iInterval = KDefaultInterval;
	}

CTimeOut::~CTimeOut()
	{
	 Cancel();
	}

CTimeOut* CTimeOut::NewL(MTimeoutObserver& aObserver)
	{
	CTimeOut* self = new (ELeave) CTimeOut(aObserver);
  	CleanupStack::PushL(self);
  	self->ConstructL();  	
  	CleanupStack::Pop(self);
  	return self;
	}

void CTimeOut::ConstructL()
	{
	CTimer::ConstructL();	
	CActiveScheduler::Add(this);
	}

void CTimeOut::RunL()
	{
	if(iStatus == KErrNone)
		{
		iObserver.HandleTimedOutL();
		}
	}

TInt CTimeOut::RunError(TInt aError)
	{
	return iObserver.HandleTimedOutLeave(aError);
	}

void CTimeOut::DoCancel()
	{	
	CTimer::DoCancel();
	}

void CTimeOut::Start()
	{	
	if(!IsActive()) 
		{
		After(iInterval);
		}
	}

void CTimeOut::Stop()
	{
	Cancel();
	}

void CTimeOut::SetInterval(TTimeIntervalMicroSeconds32 aIntervalMicro)
	{	
	iInterval = aIntervalMicro;
	}
	
void CTimeOut::SetInterval(TInt aIntervalInSec)
	{
	iInterval = aIntervalInSec * 1000000;
	}
