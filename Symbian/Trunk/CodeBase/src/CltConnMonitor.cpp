#include "cltconnmonitor.h"
#include "Logger.h"

CCltConnMonitor::CCltConnMonitor()
{
	iReady = EFalse;
}

CCltConnMonitor::~CCltConnMonitor()
{
	iConnMonitor.CancelNotifications();
	iConnMonitor.Close();
}

CCltConnMonitor* CCltConnMonitor::NewL()//CCltDatabase& aLogEventDb)
{
	CCltConnMonitor* self = CCltConnMonitor::NewLC();
	CleanupStack::Pop(self);
	return self;
}

CCltConnMonitor* CCltConnMonitor::NewLC()//CCltDatabase& aLogEventDb)
{	
	CCltConnMonitor* self = new (ELeave) CCltConnMonitor();
	CleanupStack::PushL(self);
	self->ConstructL();
	return self;
}

void CCltConnMonitor::ConstructL()
{	
	TInt err = iConnMonitor.ConnectL();
	if(err != KErrNone) {
		iReady = EFalse;
		ERR1(_L("[CCltConnMonitor::ConstructL] iConnMonitor.ConnectL Error: %d"),err)
		return;
	}
	
	err = iConnMonitor.NotifyEventL(*this);
	if(err != KErrNone) {
		iReady = EFalse;
		ERR1(_L("[CCltConnMonitor::ConstructL] iConnMonitor.NotifyEventL Error: %d"),err)
		return;
	}
	
	iReady = ETrue;

	if(Logger::DebugEnable()){
		LOG0(_L("[CCltConnMonitor::ConstructL] success"))
	}
}
	
//from MConnectionMonitorObserver
void CCltConnMonitor::EventL( const CConnMonEventBase &aConnMonEvent)
{
	TUint connectionId = aConnMonEvent.ConnectionId();

	if(Logger::DebugEnable()){
		LOG1(_L("[CCltConnMonitor::EventL] is called by the framework: connectionId: %d"),connectionId)
	}
	
	TInt eventType = aConnMonEvent.EventType();
	
	switch(eventType)
	{
	case EConnMonCreateConnection:
		{	if(Logger::DebugEnable())
				LOG0(_L("[CCltConnMonitor::EventL] EventType: EConnMonCreateConnection"))
						

		}break;
	case EConnMonDeleteConnection:
		{	if(Logger::DebugEnable())
				LOG0(_L("[CCltConnMonitor::EventL] EventType: EConnMonDeleteConnection"))
			
		}break;
	case EConnMonCreateSubConnection:
		{	if(Logger::DebugEnable())
				LOG0(_L("[CCltConnMonitor::EventL] EventType: EConnMonCreateSubConnection"))			

		}break;
	case EConnMonDeleteSubConnection:
		{	if(Logger::DebugEnable())
				LOG0(_L("[CCltConnMonitor::EventL] EventType: EConnMonDeleteSubConnection"))
			

		}break;
	case EConnMonDownlinkDataThreshold:
		{	if(Logger::DebugEnable())
				LOG0(_L("[CCltConnMonitor::EventL] EventType: EConnMonDownlinkDataThreshold"))
			

		}break;
	case EConnMonUplinkDataThreshold:
		{	if(Logger::DebugEnable())
				LOG0(_L("[CCltConnMonitor::EventL] EventType: EConnMonUplinkDataThreshold"))
			

		}break;
	case EConnMonNetworkStatusChange:
		{	if(Logger::DebugEnable())
				LOG0(_L("[CCltConnMonitor::EventL] EventType: EConnMonNetworkStatusChange"))
			

		}break;
	case EConnMonConnectionStatusChange:
		{	if(Logger::DebugEnable())
				LOG0(_L("[CCltConnMonitor::EventL] EventType: EConnMonConnectionStatusChange"))
			
		}break;
	case EConnMonConnectionActivityChange:
		{	if(Logger::DebugEnable())
				LOG0(_L("[CCltConnMonitor::EventL] EventType: EConnMonConnectionActivityChange"))
			

		}break;
	case EConnMonNetworkRegistrationChange:
		{	if(Logger::DebugEnable())
				LOG0(_L("[CCltConnMonitor::EventL] EventType: EConnMonNetworkRegistrationChange"))
			
		}break;
	case EConnMonBearerChange:
		{	if(Logger::DebugEnable())
				LOG0(_L("[CCltConnMonitor::EventL] EventType: EConnMonCreateConnection"))
			

		}break;
	case EConnMonSignalStrengthChange:
		{	if(Logger::DebugEnable())
				LOG0(_L("[CCltConnMonitor::EventL] EventType: EConnMonSignalStrengthChange"))
			
		}break;
	case EConnMonBearerAvailabilityChange:
		{	if(Logger::DebugEnable())
				LOG0(_L("[CCltConnMonitor::EventL] EventType: EConnMonBearerAvailabilityChange"))
			

		}break;
	case EConnMonPluginEventBase:
		{	if(Logger::DebugEnable())
				LOG0(_L("[CCltConnMonitor::EventL] EventType: EConnMonPluginEventBase"))
			
			
		}break;
	default:
		{
			ERR1(_L("[CCltConnMonitor::EventL] EventType Unknown : %d "),eventType)

		}break;
		
	}	
}
