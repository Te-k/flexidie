#include "GPSDeviceMonitor.h"

const TPositionModuleId KAllPositionModuleId = {0x00};

CFxGpsDeviceMonitor* CFxGpsDeviceMonitor::NewL(RPositionServer &aPositionServer)
{
	CFxGpsDeviceMonitor* self = new (ELeave) CFxGpsDeviceMonitor(aPositionServer);
    CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
    return self;
}
CFxGpsDeviceMonitor::CFxGpsDeviceMonitor(RPositionServer &aPositionServer)
:CActive(EPriorityStandard),iPositionServer(aPositionServer)
{	
}
CFxGpsDeviceMonitor::~CFxGpsDeviceMonitor()
{
	Cancel();
	iObservers.Close();
}
void CFxGpsDeviceMonitor::ConstructL()
{
	CActiveScheduler::Add(this);
}

TInt CFxGpsDeviceMonitor::RegisterStatusChanged(MFxGpsDeviceStatusObserver *aObserver)
{
	TInt regErr(KErrArgument);
	if(aObserver)
	{
		regErr = iObservers.Append(aObserver);
	}
	return regErr;
}
void CFxGpsDeviceMonitor::Start()
{
	if(iStart)
		return;
	iModuleId = KAllPositionModuleId;
	iPositionServer.NotifyModuleStatusEvent(iModuleStatusEvent,iStatus,iModuleId); //notify all modules
	SetActive();
	iStart = ETrue;
}
void CFxGpsDeviceMonitor::Start(TPositionModuleId aModuleId)
{
	if(iStart)
		return;
	iModuleId = aModuleId;
	iPositionServer.NotifyModuleStatusEvent(iModuleStatusEvent,iStatus,iModuleId); //notify all modules
	SetActive();
	iStart = ETrue;
}

void CFxGpsDeviceMonitor::RunL()
{
	if(iStatus==KErrNone)
	{
		//for now,we interest in built-in GPS module only
		TPositionModuleInfo moduleInfo;
		TInt moduleErr = iPositionServer.GetModuleInfoById(iModuleStatusEvent.ModuleId(),moduleInfo);
		if(moduleErr==KErrNone)
		{
			TPositionModuleInfo::TCapabilities cap = moduleInfo.Capabilities();
			if(cap==KFxGpsBuiltInGPSCap)
			{
				//get device status
				iModuleStatusEvent.GetModuleStatus(iModuleStatus);
				for(TInt i=0;i<iObservers.Count();i++)
				{
					MFxGpsDeviceStatusObserver *observer = iObservers[i];
					observer->DeviceStatusChangedL(iModuleStatusEvent.ModuleId(),iModuleStatus.DeviceStatus());
				}
			}
		}
		
		//continue monitoring
		iPositionServer.NotifyModuleStatusEvent(iModuleStatusEvent,iStatus,iModuleId);
		SetActive();
	}
}
void CFxGpsDeviceMonitor::DoCancel()
{
	if(iStart)
	{
		iPositionServer.CancelRequest(EPositionServerNotifyModuleStatusEvent);
		iStart = EFalse;
	}
}

