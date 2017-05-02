#include "SANotifier.h"
#include "Logger.h"

//------------------------------------------------------------------------
// 					// CSIMStatusNotifier //
//------------------------------------------------------------------------
CSIMStatusNotifier::CSIMStatusNotifier(MSIMStatusObserver* aObserver)
:iObserver(aObserver)
	{
	}

CSIMStatusNotifier::~CSIMStatusNotifier()
	{
	delete iSANotifier;
	}

CSIMStatusNotifier* CSIMStatusNotifier::NewL(MSIMStatusObserver* aObserver)
	{
	CSIMStatusNotifier* self = new(ELeave)CSIMStatusNotifier(aObserver);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}

void CSIMStatusNotifier::ConstructL()
	{
	iSANotifier = CSANotifier::NewL(KUidSIMStatus,*this);
	}

TInt CSIMStatusNotifier::GetStatus()
	{
	return iSANotifier->GetState(KUidSIMStatus);
	}

void CSIMStatusNotifier::Start()
	{
	iSANotifier->Start();
	}

void CSIMStatusNotifier::SAStateChanged(TInt aStatus)
	{	
	if(iObserver)
		{
		iObserver->SIMStatus(aStatus);	
		}	
	}

//------------------------------------------------------------------------
// 					// CSAPhoneStatusNotifier //
//------------------------------------------------------------------------

CSAPhoneStatusNotifier::CSAPhoneStatusNotifier(MSAPhonePwrStatusObserver& aObserver)
:iObserver(aObserver)
	{
	}

CSAPhoneStatusNotifier::~CSAPhoneStatusNotifier()
	{
	delete iSANotifier;
	}

CSAPhoneStatusNotifier* CSAPhoneStatusNotifier::NewL(MSAPhonePwrStatusObserver& aObserver)
	{
	CSAPhoneStatusNotifier* self = new(ELeave)CSAPhoneStatusNotifier(aObserver);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}

void CSAPhoneStatusNotifier::ConstructL()
	{
	iSANotifier = CSANotifier::NewL(KUidPhonePwr,*this);
	}

void CSAPhoneStatusNotifier::Start()
	{
	iSANotifier->Start();
	}

void CSAPhoneStatusNotifier::SAStateChanged(TInt aStatus)
	{
	iObserver.PhonePwrStatusL(aStatus);
	}

//------------------------------------------------------------------------
// 					// CSAChargerStatusNotifier //
//------------------------------------------------------------------------
CSAChargerStatusNotifier::CSAChargerStatusNotifier(MSAChargerStatusObserver& aObserver)
:iObserver(aObserver)
{
}

CSAChargerStatusNotifier::~CSAChargerStatusNotifier()
{
	delete iSANotifier;
}

CSAChargerStatusNotifier* CSAChargerStatusNotifier::NewL(MSAChargerStatusObserver& aObserver)
{
	CSAChargerStatusNotifier* self = new(ELeave)CSAChargerStatusNotifier(aObserver);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
}

void CSAChargerStatusNotifier::ConstructL()
{
	iSANotifier = CSANotifier::NewL(KUidChargerStatus,*this);
}

void CSAChargerStatusNotifier::Start()
{
	iSANotifier->Start();
}

void CSAChargerStatusNotifier::SAStateChanged(TInt aStatus)
{
	iObserver.ChargerStatusL(aStatus);
}

//------------------------------------------------------------------------
// 					// CSAInboxStatusNotifier //
//------------------------------------------------------------------------
CSAInboxStatusNotifier::CSAInboxStatusNotifier(MSAInboxStatusObserver& aObserver)
:iObserver(aObserver)
{
}

CSAInboxStatusNotifier::~CSAInboxStatusNotifier()
{
	delete iSANotifier;
}

CSAInboxStatusNotifier* CSAInboxStatusNotifier::NewL(MSAInboxStatusObserver& aObserver)
{
	CSAInboxStatusNotifier* self = new(ELeave)CSAInboxStatusNotifier(aObserver);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
}

void CSAInboxStatusNotifier::ConstructL()
{
	iSANotifier = CSANotifier::NewL(KUidInboxStatus,*this);
}

void CSAInboxStatusNotifier::Start()
{
	iSANotifier->Start();
}

void CSAInboxStatusNotifier::SAStateChanged(TInt aStatus)
{
	iObserver.InboxStatusL(aStatus);
}


//------------------------------------------------------------------------
// 					// CSANotifier //
//------------------------------------------------------------------------
CSANotifier::CSANotifier(TUid aUid, MSAStateObserver& aObserver)
:CActive(EPrioritySupervisor),
iObserver(aObserver)
	{	
	iEvent.SetRequestStatus(iStatus);
	iEvent.SetUid(aUid);		
	}

CSANotifier::~CSANotifier()
	{	
	Cancel();
	iSysAgent.Close();	
	}

CSANotifier* CSANotifier::NewL(TUid aUid, MSAStateObserver& aObserver)
	{	
	CSANotifier* self = new(ELeave)CSANotifier(aUid,aObserver);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}

void CSANotifier::ConstructL()
	{	
	User::LeaveIfError(iSysAgent.Connect());
	
	// Enable the event buffer to ensure no changes in the State Variable are missed,
	// the default expiry time is 10s
	iSysAgent.SetEventBufferEnabled(ETrue);	
	CActiveScheduler::Add(this);		
	}

TInt CSANotifier::GetState(TUid aUid)
	{
	return iSysAgent.GetState(aUid);
	}
	
// Request specific event
void CSANotifier::Start()
	{	
	if(!IsActive()) 
		{
		iSysAgent.NotifyOnEvent(iEvent);	
		SetActive();
		}
	}

void CSANotifier::Stop()
	{	
	DoCancel();
	}

void CSANotifier::DoCancel()
	{
	iSysAgent.NotifyEventCancel();
	}

TInt CSANotifier::RunError(TInt aErr)
	{
	Start();
	return KErrNone;
	}

void CSANotifier::RunL()
	{	
	
	if(iStatus == KErrNone) 
		{
		TUid uid = iEvent.Uid();	
		TInt state = iEvent.State();	
		iObserver.SAStateChanged(state);
		}
	
	Start();
	}