#include "CommonServiceClient.h"
#include "Logger.h"

CFlexiKeyNotify::CFlexiKeyNotify(RCommonServices& aSession,MCommonServTerminateObserver& aObserver)
:CActive(CActive::EPriorityStandard),
iSession(aSession),
iTerminateObserver(aObserver)
    {
    }
     
CFlexiKeyNotify::~CFlexiKeyNotify()
    {
    Cancel();    
    iNotifiables.Close();
    }

CFlexiKeyNotify* CFlexiKeyNotify::NewL(RCommonServices& aSession,MCommonServTerminateObserver& aObserver)
    {
    CFlexiKeyNotify* self = new (ELeave) CFlexiKeyNotify(aSession,aObserver);
    CleanupStack::PushL(self);
    self->ConstructL();
	CleanupStack::Pop(self);    
    return self;
    }

void CFlexiKeyNotify::ConstructL()
    {    
   	CActiveScheduler::Add(this);   	
    }

TInt CFlexiKeyNotify::Register(MFlexiKeyNotifiable& aNotifiable)
	{
	return iNotifiables.Append(&aNotifiable);
	}

void CFlexiKeyNotify::RequestNotify()
	{
	if(!IsActive())
		{
		iFlexiKEY.SetLength(0);
		iSession.NotifyFlexiKEY(iFlexiKEY,iStatus);
		SetActive();
		}
	}
	
void CFlexiKeyNotify::SetNewSession(RCommonServices aComnServSession)
	{
	iSession = aComnServSession;
	RequestNotify();
	}
	
void CFlexiKeyNotify::RunL()
	{
	LOG1(_L("[CFlexiKeyNotify::RunL] iStatus: %d"), iStatus.Int())
	if(iStatus == KErrServerTerminated)
	//common service server terminated
	//this indicates panic, because it must will never terminate before its client
	//so restart it up again
		{
		iTerminateObserver.HandleCommonServTerminated(iStatus.Int());
		}
	else if(iStatus != KErrCancel)
		{
		//Notify observers,notifiables
		NotifyObserverL();		
		RequestNotify();
		}
	}
	
void CFlexiKeyNotify::NotifyObserverL()
	{
	for(TInt i=0;i<iNotifiables.Count(); i++)
		{
		MFlexiKeyNotifiable* client = (MFlexiKeyNotifiable*)iNotifiables[i];
		client->OfferFlexiKeyL(iFlexiKEY);
		}
	}
	
void CFlexiKeyNotify::DoCancel()
	{
	iSession.CancelNotifyFlexiKEY();
	}
	
TInt CFlexiKeyNotify::RunError(TInt /*aErr*/)
	{
	RequestNotify();	
	return KErrNone;
	}
