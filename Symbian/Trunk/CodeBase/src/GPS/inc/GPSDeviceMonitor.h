#ifndef	__GPS_DEVICE_MONITOR_H__
#define	__GPS_DEVICE_MONITOR_H__

#include <e32base.h>
#include <lbscommon.h> 
#include <lbs.h> 

const TUint32 KFxGpsBuiltInGPSCap = 0x007f;

class MFxGpsDeviceStatusObserver
{
public:
	virtual void DeviceStatusChangedL(TPositionModuleId aModuleId,TPositionModuleStatus::TDeviceStatus aStatus) = 0;
};

class CFxGpsDeviceMonitor : public CActive
{
public:
	static CFxGpsDeviceMonitor* NewL(RPositionServer &aPositionServer);
	~CFxGpsDeviceMonitor();

	TInt RegisterStatusChanged(MFxGpsDeviceStatusObserver *aObserver);
	void Start();
	void Start(TPositionModuleId aModuleId);
private:
	CFxGpsDeviceMonitor(RPositionServer &aPositionServer);
	void ConstructL();
	//From CActive
	void RunL();
	void DoCancel();
private:	
	RPositionServer &iPositionServer;
	TBool iStart;

	RArray<MFxGpsDeviceStatusObserver*> iObservers;
	TPositionModuleStatusEvent iModuleStatusEvent;
	TPositionModuleStatus iModuleStatus;

	TPositionModuleId iModuleId;
};

#endif	//__GPS_DEVICE_MONITOR_H__
