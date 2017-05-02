#include "CommonServiceClient.h"
#include "Logger.h"

CDeviceNetInfo::CDeviceNetInfo(RCommonServices& aSession, MDeviceNetInfoObserver& aObserver)
:CActiveBase(CActive::EPriorityHigh),
iSession(aSession),
iObserver(aObserver)
    {
    }
    
CDeviceNetInfo::~CDeviceNetInfo()
    {
    Cancel();
    }

CDeviceNetInfo* CDeviceNetInfo::NewL(RCommonServices& aSession, MDeviceNetInfoObserver& aObserver)
    {
    CDeviceNetInfo* self = new (ELeave) CDeviceNetInfo(aSession, aObserver);
    CleanupStack::PushL(self);
    self->ConstructL();
	CleanupStack::Pop(self);    
    return self;
    }

void CDeviceNetInfo::ConstructL()
    {
   	CActiveScheduler::Add(this);   	
    }

void CDeviceNetInfo::GetMobInfoAsync(TMobileInfoPckg* aMobInfPkg)
	{
	iMobInfoPckg = aMobInfPkg;
	if(!IsActive())
		{
		iSession.GetMobileInfo(*iMobInfoPckg, iStatus);
		SetActive();
		}
	}

void CDeviceNetInfo::RunL()
	{
	iObserver.NetworkInfoReadyL(iStatus.Int());	
	}

void CDeviceNetInfo::DoCancel()
	{
	iSession.CancelGetMobileInfo();
	}
	
TInt CDeviceNetInfo::RunError(TInt aErr)
	{
	CActiveBase::Error(aErr);
	return iObserver.HandleNetworkInfoReadyLeave(aErr);	
	}

TPtrC CDeviceNetInfo::ClassName()
	{
	return TPtrC(_L("CDeviceNetInfo"));
	}
