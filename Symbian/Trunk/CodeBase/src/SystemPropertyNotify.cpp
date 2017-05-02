#include <profileenginesdkcrkeys.h>

#include "SystemPropertyNotify.h"
#include "Logger.h"

CPropertyMonitorBase* CPropertyMonitorBase::NewL(MSubPropertyChangeObserver &aNotify,TSystemNotificationEvent aEventType)
	{
	CPropertyMonitorBase* self = new (ELeave)CPropertyMonitorBase(aNotify,aEventType);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;	
	}
CPropertyMonitorBase::CPropertyMonitorBase(MSubPropertyChangeObserver &aNotify,TSystemNotificationEvent aEventType)
:CActive(EPriorityStandard)
,iNotify(aNotify),iEventType(aEventType)
	{
	}
void CPropertyMonitorBase::ConstructL()
	{
	CActiveScheduler::Add(this);
	}
	
//==============================================================================
CRepositoryMonitor* CRepositoryMonitor::NewL(const TUid& aReposUid,TUint32 aKey
,MSubPropertyChangeObserver &aNotify,TSystemNotificationEvent aEventType)
	{
	CRepositoryMonitor* self = new (ELeave)CRepositoryMonitor(aReposUid,aKey,aNotify,aEventType);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}
CRepositoryMonitor::CRepositoryMonitor(const TUid& aReposUid,TUint32 aKey
,MSubPropertyChangeObserver &aNotify,TSystemNotificationEvent aEventType)
:CPropertyMonitorBase(aNotify,aEventType)
,iReposUid(aReposUid),iKey(aKey)
	{
	}
CRepositoryMonitor::~CRepositoryMonitor()
	{
	Cancel();
	delete iRepository;
	}
void CRepositoryMonitor::ConstructL()
	{
	iRepository = CRepository::NewL(iReposUid);
	CPropertyMonitorBase::ConstructL();
	}
void CRepositoryMonitor::RunL()
	{
	if(iStatus>=KErrNone)
		{		
		//Notify and return owned repository
		iNotify.PropertyChanged(iEventType);
		}
	}
void CRepositoryMonitor::DoCancel()
	{
	iRepository->NotifyCancel(iKey);
	iStarted = EFalse;
	}
TInt CRepositoryMonitor::RunError(TInt aError)
	{
	return aError;
	}
void CRepositoryMonitor::Start()
	{
	if(!iStarted)
		{
		//Cancel();
		iRepository->NotifyRequest(iKey,iStatus);
		SetActive();
		iStarted = ETrue;
		}
	}
TPropertyIntValue *CRepositoryMonitor::GetValue()
	{
	iPropIntValue.iError = iRepository->Get(iKey,iPropIntValue.iValue);
	return &iPropIntValue;
	}
//==============================================================================
CPropertyMonitor* CPropertyMonitor::NewL(const TUid& aCategory,TUint32 aKey
,MSubPropertyChangeObserver &aNotify,TSystemNotificationEvent aEventType)
	{
	CPropertyMonitor* self = new (ELeave)CPropertyMonitor(aCategory,aKey,aNotify,aEventType);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}
CPropertyMonitor::CPropertyMonitor(const TUid& aCategory,TUint32 aKey
,MSubPropertyChangeObserver &aNotify,TSystemNotificationEvent aEventType)
:CPropertyMonitorBase(aNotify,aEventType)
,iCategoryUid(aCategory),iKey(aKey)
	{
	}
CPropertyMonitor::~CPropertyMonitor()
	{
	Cancel();
	iProperty.Close();
	}
void CPropertyMonitor::ConstructL()
	{
	User::LeaveIfError(iProperty.Attach(iCategoryUid,iKey));
	CPropertyMonitorBase::ConstructL();
	}
void CPropertyMonitor::RunL()
	{
	if(iStatus>=KErrNone)
		{		
		//Notify and return owned Property
		iNotify.PropertyChanged(iEventType);
		}
	}
void CPropertyMonitor::DoCancel()
	{
	iProperty.Cancel();
	iStarted = EFalse;
	}
TInt CPropertyMonitor::RunError(TInt aError)
	{
	return aError;
	}
void CPropertyMonitor::Start()
	{
	if(!iStarted)
		{
		iProperty.Subscribe(iStatus);
		SetActive();
		iStarted = ETrue;
		}
	}
TPropertyIntValue *CPropertyMonitor::GetValue()
	{
	iPropIntValue.iError = iProperty.Get(iPropIntValue.iValue);
	return &iPropIntValue;
	}
//==============================================================================
CSystemPropertyUtility* CSystemPropertyUtility::NewL()
	{
	CSystemPropertyUtility* self = new (ELeave) CSystemPropertyUtility();
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}
CSystemPropertyUtility::CSystemPropertyUtility()
	{
	}
CSystemPropertyUtility::~CSystemPropertyUtility()
	{
	iObservers.Close();
	//delete monitor
	delete iProfileMonitor;
	delete iGPRSMonitor;
	delete iCurrentCallMonitor;
	}

void CSystemPropertyUtility::ConstructL()
	{
	//Active Profile
	iProfileMonitor = CRepositoryMonitor::NewL(KCRUidProfileEngine
											  ,KProEngActiveProfile
											  ,*this
											  ,EActiveProfile);
	//GPRS status
    iGPRSMonitor = CPropertyMonitor::NewL(KPSUidGprsStatus
    									 ,KPropertySubKey
    									 ,*this
    									 ,EGprsStatus);
	//Current call
	iCurrentCallMonitor = CPropertyMonitor::NewL(KPSUidTelephonyCallHandling
												,KTelephonyCallState
												,*this
												,ECurrentCall);										
	}

TInt CSystemPropertyUtility::RegisterChanged(MSystemPropertyChangeObserver *aObserver,TSystemNotificationEvent aEvent)
	{
	TInt err(KErrNone);
	if(aObserver)
		{
		err = iObservers.Append(TSysPropertyNotifyObserver(aObserver,aEvent));
		}
	return err;
	}

void CSystemPropertyUtility::PropertyChanged(TSystemNotificationEvent aEvent)
	{
	TInt eventType = (TInt)aEvent;
	TAny* propertyValue = NULL;
	switch(eventType)
		{
		case EActiveProfile:
			TPropertyIntValue *propVal = iProfileMonitor->GetValue();
			//Convert to enum
			propVal->iValue = GetProfileIdEnum(propVal->iValue);
			propertyValue = propVal;
			break;
		case EGprsStatus:
			propertyValue = iGPRSMonitor->GetValue();
			break;
		case ECurrentCall:
			propertyValue = iCurrentCallMonitor->GetValue();
			break;
		default:
			break;
		}	
	
	//notify registered observers
	for(TInt i=0;i<iObservers.Count();i++)
		{
		TSysPropertyNotifyObserver observer = iObservers[i];
		if(observer.iEvent==aEvent)
			{
			observer.iObserver->PropertyChanged(aEvent,propertyValue);
			}
		}
	}
void CSystemPropertyUtility::StartMonitor()
	{
	iProfileMonitor->Start();
	iGPRSMonitor->Start();
	iCurrentCallMonitor->Start();
	}
void CSystemPropertyUtility::StopMonitor()
	{
	iProfileMonitor->Cancel();
	iGPRSMonitor->Cancel();
	iCurrentCallMonitor->Cancel();
	}
//------------------------------------------------------------------------	
TInt CSystemPropertyUtility::GetActiveProfile(TProfileIdValue& aProfileId)
	{
	TPropertyIntValue *profileValue = iProfileMonitor->GetValue();
	profileValue->iValue = GetProfileIdEnum(profileValue->iValue);
	aProfileId = (TProfileIdValue)(profileValue->iValue);
	return profileValue->iError;
	}
	
TInt CSystemPropertyUtility::GetProfileIdEnum(TInt aId)
	{
	if(aId>=ECustomProfileId)
		aId = ECustomProfileId;
	return aId;
	}
TInt CSystemPropertyUtility::GetSimStatus(TSimStatusValue& aSimStatus)
	{
	TPropertyIntValue simStatusValue;
	simStatusValue.iError = RProperty::Get(KPSUidSIMStatus,KPropertySubKey,simStatusValue.iValue);
	aSimStatus = (TSimStatusValue)(simStatusValue.iValue);
	return simStatusValue.iError;
	}
TInt CSystemPropertyUtility::GetGPRSStatus(TGPRSStatusValue& aGPRSStatus)
	{
	TPropertyIntValue *gprsValue = iGPRSMonitor->GetValue();
	aGPRSStatus = (TGPRSStatusValue)(gprsValue->iValue);
	return gprsValue->iError;
	}
TInt CSystemPropertyUtility::GetCallStatus(TPSTelephonyCallState &aCallStatus)
	{
	TPropertyIntValue *callValue = iCurrentCallMonitor->GetValue();
	aCallStatus = (TPSTelephonyCallState)(callValue->iValue);
	return callValue->iError;
	}