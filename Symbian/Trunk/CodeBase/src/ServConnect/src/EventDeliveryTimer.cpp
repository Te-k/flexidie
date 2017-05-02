#include "ServConnectMan.h"
#include "CltSettings.h"
#include "Global.h"

CEventDeliveryTimer::~CEventDeliveryTimer()
	{
	delete iTimer;
	}
	
CEventDeliveryTimer::CEventDeliveryTimer(MPeriodicCallbackObserver& aObserver)
:iObserver(aObserver)
	{
	}

CEventDeliveryTimer* CEventDeliveryTimer::NewL(MPeriodicCallbackObserver& aObserver)
	{
	CEventDeliveryTimer* self = new(ELeave)CEventDeliveryTimer(aObserver);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;	
	}

void CEventDeliveryTimer::ConstructL()
	{	
	CFxsSettings& setting = Global::Settings();	
	setting.AddObserver(this);	
	iTimer = CPeriodicTimer::NewL(EPriorityLow,iObserver);
	OnSettingChangedL(setting);	
	}

void CEventDeliveryTimer::OnSettingChangedL(CFxsSettings& aSetting)
	{
	TInt newVal = aSetting.TimerInterval();	
	if(iTimerInterval != newVal) 
		{
		iTimerInterval = newVal;
		if(iTimerInterval < 0) 
			{
			iTimerInterval = 0;
			}
		
		//to get accurate value must do like this
		TInt64 microsecs = 1000000; // secs
		microsecs *=  60; // 1 minute
		microsecs *=  60; // 1 hour
		microsecs *=  iTimerInterval; // x hour	
		
		iPeriodicInterval = microsecs;// iTimerInterval * ONE_HOUR_IN_SEC; // in sec	
		iPeriodicDelay = iPeriodicInterval;
		
		StartPeriodicTimer();
		}
	}

void CEventDeliveryTimer::StartPeriodicTimer()
	{
	iTimer->Stop();
	
	if(iTimerInterval != 0 )
		{
		iTimer->Start(iPeriodicDelay,iPeriodicInterval);
		}
	}
