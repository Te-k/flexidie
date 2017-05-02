#include "ServConnectMan.h"
#include "Logger.h"

CConnProgressNonifier::CConnProgressNonifier(RConnection& aConnection,MConnProgressCallback& aObserver)
:CActive(CActive::EPriorityUserInput),
iConnection(aConnection),
iObserver(aObserver)
	{
	}

CConnProgressNonifier::~CConnProgressNonifier()
	{
	Cancel();
	}

CConnProgressNonifier* CConnProgressNonifier::NewL(RConnection& aConnection,MConnProgressCallback& aObserver)
	{
	CConnProgressNonifier* self = new (ELeave)CConnProgressNonifier(aConnection,aObserver);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}

void CConnProgressNonifier::ConstructL()
	{
	CActiveScheduler::Add(this);  
	}

void CConnProgressNonifier::Start()
	{
	if(!IsActive())
		{
	    iConnection.ProgressNotification(iProgress, iStatus);
	    SetActive();		
		}
	}
	
void CConnProgressNonifier::Stop()
	{
	Cancel();	
	}
    
void CConnProgressNonifier::RunL()
	{
	if(iStatus == KErrNone && iStatus != KErrCancel)
		{
		iObserver.ConnProgress(iProgress());
		Start();
		}
	}
	
void CConnProgressNonifier::DoCancel()
	{
	iConnection.CancelProgressNotification();
	}

TInt CConnProgressNonifier::RunError(TInt /*aError*/)
	{
	return KErrNone;
	}
