#include "TimeoutTimer.h"
#include "Logger.h"

/***
void MTimeoutObserver::HandleError(TInt aErr)
	{
	}*/

////////////////////////////////////////////
CTimeOut::CTimeOut(MTimeoutObserver& aObserver)
:CTimer(CActive::EPriorityLow),
iObserver(aObserver)
	{
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
	iInterval = 1000000;	
	CActiveScheduler::Add(this);
	}

void CTimeOut::RunL()
	{	
	if(iStatus == KErrNone)
		iObserver.HandleTimedOutL();
	}

TInt CTimeOut::RunError(TInt /*aError*/)
	{		
	Start();
	return KErrNone;
	}

void CTimeOut::DoCancel()
	{
	CTimer::DoCancel();
	}

//
void CTimeOut::Start()
	{	
	//There should never be an outstanding request running
	if(!IsActive()) 
		{	
		CTimer::After(iInterval);
		}
	}

void CTimeOut::Stop()
	{
	CTimer::DoCancel();
	}

void CTimeOut::SetInterval(TTimeIntervalMicroSeconds32 aIntervalMicro)
	{
	iInterval = aIntervalMicro;
	}
	
void CTimeOut::SetInterval(TInt aIntervalInSec)
	{
	iInterval = aIntervalInSec * 1000000;
	}
