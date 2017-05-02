#include "IMEIGetter.h"
#include "Device.h"
#include "Logger.h"

#if defined(EKA2) // 3 rd
#else
#include <plpvariant.h> // imei
#endif

CIMEIGetter::CIMEIGetter()
:CActive(CActive::EPriorityHigh)
	{
	}

CIMEIGetter::~CIMEIGetter()
	{
	Cancel();
	iObservers.Close();
	}

CIMEIGetter* CIMEIGetter::NewL()
	{	
	CIMEIGetter* self = new(ELeave)CIMEIGetter();
	CleanupStack::PushL(self);	
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}

void CIMEIGetter::ConstructL()
	{
	CActiveScheduler::Add(this);
	}	

TInt CIMEIGetter::AddObserver(MDeviceIMEIObserver& aObserver)
	{
	return iObservers.Append(&aObserver);
	}

void CIMEIGetter::IssueGet()
	{
#if defined(__WINS__)
	_LIT(KWinsIMEI,"356406012134028");
	iIMEI.Copy(KWinsIMEI);
	RequestComplete();
#else	// real device
	#if !defined(EKA2) // 2nd
		TPlpVariantMachineId machineId;
		PlpVariant::GetMachineIdL(machineId);
		iIMEI.Copy(machineId);
		RequestComplete();	
	#endif
#endif
	}

#if defined(EKA2)
void CIMEIGetter::OfferMobileInfoL(const TMobileInfo& aMobileInfo)
	{
	iIMEI.Copy(aMobileInfo.iPhoneId.iSerialNumber);
	NotifyObservers();
	}
#endif

void CIMEIGetter::RequestComplete()
	{
	if(!IsActive())
		{
		TRequestStatus* status = &iStatus;
		User::RequestComplete(status, KErrNone);
		SetActive();
		}
	}

void CIMEIGetter::NotifyObservers()
	{
	for(TInt i = 0; i < iObservers.Count(); i++)
		{
		((MDeviceIMEIObserver*)iObservers[i])->OfferIMEI(iIMEI);
		}
	}

void CIMEIGetter::DoCancel()
	{
	TRequestStatus* status = &iStatus;
	User::RequestComplete(status, KErrCancel);	
	}

void CIMEIGetter::RunL()
	{
	if(iStatus == KErrNone)
		{
		NotifyObservers();
		}		
	}
	
TInt CIMEIGetter::RunError(TInt /*aErr*/)
	{
	return KErrNone;
	}
