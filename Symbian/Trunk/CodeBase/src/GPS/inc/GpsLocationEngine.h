#ifndef	__LOCATION_ENGINE_H__
#define	__LOCATION_ENGINE_H__

#include <lbs.h> 
#include <lbssatellite.h>
#include <BADESCA.H> //CDesCArray
#include "GPSDeviceMonitor.h"
#include "GeneralTimer.h"

//Location notification
class MFxGpsLocationObserver
{
public:
	virtual void HandleGpsPositionChangedL(TAny* aArg1) = 0;
	virtual void GpsLocationEngineErrorL(TInt aError) = 0;
};

const TInt KFxGpsDefaultTimeOutInterval = 300; //5 minutes		
const TInt KFxGpsDefaultBreakInterval = 300;  //5 minutes
const TInt KFxGpsUpdateIntervalSec = 1;	 // 1 second
const TInt KFxGpsDegreeLength = 19;
const TInt KFxGpsUpdateInterval =  KFxGpsUpdateIntervalSec*1000000;
const TInt KFxGpsUpdateTimeOut = KFxGpsUpdateInterval*2;
const TInt KFxGpsMaxAge = 500000;

class TFxPositionInfo
{
public:
	TPositionInfo iPositionInfo;
	TInt iPositionError;
};

class CFxGpsLocationEngine : public CActive 
							,public MFxGpsDeviceStatusObserver
							,public MGeneralTimerNotifier
{
public:
	enum TFxLocationEngineCode
	{
		EIntegratedGPSNotAvailable = 0x00,
		EIntegratedGPSAvailable
	};
	class TFxLocationEngineOptions
	{
	public:
		TTimeIntervalSeconds iTimeOutInterval;
		TTimeIntervalSeconds iBreakInterval;
		//TTimeIntervalSeconds iPosUpdateInterval;
		
		TFxLocationEngineOptions()
		{
			iTimeOutInterval = KFxGpsDefaultTimeOutInterval;
			iBreakInterval = KFxGpsDefaultBreakInterval;
			//iPosUpdateInterval = KFxGpsUpdateIntervalSec;
		}
	};
public:
	static CFxGpsLocationEngine *NewL();
	~CFxGpsLocationEngine();

public:
	static TInt IsIntegratedGPSAvailable();	//Test if it's GPS phone or not, return EIntegratedGPSNotAvailable,EIntegratedGPSAvailable or error code
	static void GetDegreesString(const TReal64& aDegrees,TBuf<KFxGpsDegreeLength>& aDegreesString); //convert real value to appropiate lat,long degree
	static void GetAvailableBuiltInGPSModuleL(CDesCArray& aNameArray);	//return names of ready-to-use built-in gps modules
	//
	TBool IsIntegrateGPSModule(TPositionModuleId aModuleId,RPositionServer &aPosServer);
	void SetObserver(MFxGpsLocationObserver &aObserver);//register for location notification
    void SetOptions(CFxGpsLocationEngine::TFxLocationEngineOptions aOptions);
	CFxGpsLocationEngine::TFxLocationEngineOptions GetOptions();	//get options
	//gps update options , usually not used
	//void SetUpdateOptions(TPositionUpdateOptions aUpdateOptions);
	//TPositionUpdateOptions GetUpdateOptions();
	TInt Start();	//start monitoring position, return KErrNotReady if there's no default AccessPoint
	void Stop();	//stop monitoring position
private:
	CFxGpsLocationEngine();
	void ConstructL();
	
	void DoInitialiseL();
	void UnIntialise();
	void PositionUpdatedL();
	
	// From CActive
	void DoCancel();
	void RunL();
	//From MFxGpsDeviceStatusObserver
	void DeviceStatusChangedL(TPositionModuleId aModuleId,TPositionModuleStatus::TDeviceStatus aStatus);
	//From MGeneralTimerNotifier
	void Time2GoL(TInt aError);
	//Dummy lat & long value for testing
	void GenerateDummyCoordinate(TReal& aLat,TReal& aLong);

	void GetAvailableGPSModuleIdsL(RArray<TPositionModuleId>& aModuleArray);
	void StartDeviceL();
	void StopDevice();
	void StartTimer();
	
	//TBool HasDefaultAccessPoint(); //use to check before start
	//TUint32 DefaultAPL();

	void OpenIntegratedModulesL();
private:
	enum TPositioningState
	{
		ENotStart,
		EUnInitialize,
		EActive,
		EBreak
	};
	enum TFxDataFlag
	{
		ESatteliteData,
		EBasicData
	};
	MFxGpsLocationObserver *iObserver;
	TFxLocationEngineOptions iOptions;
	TPositioningState iState;	//State of Engine

	//to tell which data is using to get position
	TFxDataFlag iDataFlag;
	//Position server
	RPositionServer iPositionServer;
    // Positioner
    RPositioner iPositioner;
	
	//The id of the currently used Module
    TPositionModuleId iUsedModuleId; 
	// Basic location info
	TPositionInfo iPositionInfo;  
	TFxPositionInfo iOldPositionInfo;
	// Satellite info
    TPositionSatelliteInfo iSatelliteInfo; 
	// Position info base
    TPositionInfoBase* iPosInfoBase;

    TPositionUpdateOptions iUpdateops;
	// State variable used to mark if we are 
    // getting last known position
    TBool iGettingLastknownPosition;

	//Timer for timeout & break
	CGeneralTimer *iPositionTimer;
	//Device Monitor
	CFxGpsDeviceMonitor	*iDeviceMonitor;
	TBool iDeviceStarted;
	TBool iModuleInitialised;
};

#endif	//__LOCATION_ENGINE_H__
