#include <e32math.h>
#include <apdatahandler.h>
#include "Logger.h"
#include "PositionModuleRepo.h"
#include "GpsLocationEngine.h"

//The name of the requestor
_LIT(KRequestor,"Flexi Location Application");

// Degrees sign delimeter used in formatting methods
_LIT(KDelimDegree,"\xb0"); // "°" symbol

// Dot delimeter used in formatting methods
_LIT(KDelimDot,"\x2e"); // "." symbol

// Plus sign delimeter used in formatting methods
_LIT(KDelimPlus,"\x2b"); // "+" symbol

// Minus sign delimeter used in formatting methods
_LIT(KDelimMinus,"\x2d"); // "-" symbol

// Quotation sign delimeter used in formatting methods
_LIT(KDelimQuot,"\x22"); // "\"" symbol

// Apostrophe sign delimeter used in formatting methods
_LIT(KApostrophe,"\x27"); // "'" symbol

// Not-a-number string
_LIT(KNan,"NaN");

_LIT(KTimeFormat1,"%D%M%*Y%/0%1%/1%2%/2%3%/3");
_LIT(KTimeFormat2,"-%-B%:0%J%:1%T%:2%S%:3%");

CFxGpsLocationEngine *CFxGpsLocationEngine::NewL()
{
	CFxGpsLocationEngine* self = new (ELeave) CFxGpsLocationEngine();
    CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
    return self;
}
CFxGpsLocationEngine::CFxGpsLocationEngine()
:CActive(EPriorityStandard),iState(ENotStart)
{
	// Set update interval to one second to receive one position data
    iUpdateops.SetUpdateInterval(TTimeIntervalMicroSeconds(KFxGpsUpdateInterval));

    // If position server could not get position
    // In xx minutes it will terminate the position request
    iUpdateops.SetUpdateTimeOut(TTimeIntervalMicroSeconds(KFxGpsUpdateTimeOut));

    // Positions which have time stamp below KMaxAge can be reused
    iUpdateops.SetMaxUpdateAge(TTimeIntervalMicroSeconds(KFxGpsMaxAge));

    // Enables location framework to send partial position data
    iUpdateops.SetAcceptPartialUpdates(ETrue);
}
CFxGpsLocationEngine::~CFxGpsLocationEngine()
{
	Stop();
	delete iPositionTimer;
}
void CFxGpsLocationEngine::ConstructL()
{
	iPositionTimer = CGeneralTimer::NewL(*this);
	
	CActiveScheduler::Add(this);
}

void CFxGpsLocationEngine::SetObserver(MFxGpsLocationObserver &aObserver)
{
	iObserver = &aObserver;
}
void CFxGpsLocationEngine::SetOptions(CFxGpsLocationEngine::TFxLocationEngineOptions aOptions)
{
	//LOG2(_L("[CFxGpsLocationEngine::SetOptions] %d,%d"),aOptions.iActiveInterval.Int(),aOptions.iBreakInterval.Int())
	iOptions = aOptions;	
	if(iOptions.iTimeOutInterval.Int()<1)
	{
		iOptions.iTimeOutInterval = 1;	//active must not be 0
	}
	if(iOptions.iBreakInterval.Int()<0)
	{
		iOptions.iBreakInterval = 0;	//no break
	}
	
	iPositionTimer->Cancel();
	//reset timer to EActive
	switch(iState)
	{
		case EActive:
			StopDevice();	
		case EBreak:
			TRAPD(error,StartDeviceL());
			iState = EActive;
			StartTimer();
			break;
		default:
			break;
	}
}
CFxGpsLocationEngine::TFxLocationEngineOptions CFxGpsLocationEngine::GetOptions()
{
	return iOptions;
}
TInt CFxGpsLocationEngine::IsIntegratedGPSAvailable()
{
	TInt errorCode(KErrNone);
#ifdef	__WINS__
	errorCode = EIntegratedGPSAvailable;
#else
	RPositionServer positionServer;
	errorCode = positionServer.Connect();
	if(errorCode!=KErrNone)
		return errorCode;	
    TUint numModule;
    errorCode = positionServer.GetNumModules(numModule);
	if(errorCode!=KErrNone)
	{
		positionServer.Close();
		return errorCode;
	}		
	errorCode = EIntegratedGPSNotAvailable;
	TBuf<32> moduleName;
	for(TUint i=0;i<numModule;i++)
	{
		TPositionModuleInfo mInfo;
   		TInt modErr = positionServer.GetModuleInfoByIndex(i,mInfo);
   		TPositionModuleStatus moduleStatus;
   		modErr = positionServer.GetModuleStatus(moduleStatus,mInfo.ModuleId());
   		
   		if(modErr==KErrNone)
   		{
   			mInfo.GetModuleName(moduleName);
   			TPositionModuleInfo::TCapabilities cap = mInfo.Capabilities();
   			TPositionModuleInfo::TTechnologyType tech = mInfo.TechnologyType();
   			//LOG2(_L("TPositionModuleStatus %S, DeviceStatus %d"),&moduleName,moduleStatus.DeviceStatus());
   			
   			if((cap==KFxGpsBuiltInGPSCap)&&(tech!=TPositionModuleInfo::ETechnologyAssisted))
   			{
   				errorCode = EIntegratedGPSAvailable;
   				break;
   			}
   		}	
	}
	positionServer.Close();
#endif
	return errorCode;
}
void CFxGpsLocationEngine::GetDegreesString(const TReal64& aDegrees,TBuf<KFxGpsDegreeLength>& aDegreesString)
{
	const TReal KSecondsInMinute = 60.0;
    const TInt KNumWidth = 3;
    
    // If the aDegree is a proper number
    if ( !Math::IsNaN(aDegrees) )
    {
        // Integer part of the degrees
        TInt intDegrees = static_cast<TInt>(aDegrees);
        
        // Positive float of the degrees
        TReal64 realDegrees = aDegrees;
        
        // Convert to positive values
        if ( intDegrees < 0 )
        {
            intDegrees = -intDegrees;
            realDegrees = -realDegrees;
        }

        // Minutes
        TReal64 realMinutes = (realDegrees - intDegrees) * KSecondsInMinute;
          
        // Integer part of the minutes
        TInt intMinutes = static_cast<TInt>(realMinutes);

        // Seconds
        TReal64 realSeconds = (realMinutes - intMinutes) * KSecondsInMinute;
        TInt intSeconds = static_cast<TInt>((realMinutes - intMinutes) * KSecondsInMinute);

        // Check the sign of the result
        if ( aDegrees >= 0 )
        {
            aDegreesString.Append(KDelimPlus); 
        }
        else
        {
            aDegreesString.Append(KDelimMinus);
        }

        // Add the degrees
        TInt64 value = intDegrees;
        aDegreesString.AppendNum(value);

        // Add the separator
        aDegreesString.Append(KDelimDegree);
    
        // Add the minutes
        value = intMinutes;
        aDegreesString.AppendNum(value);

        // Add the separator
        aDegreesString.Append(KApostrophe);
        
        // Add the seconds
        value = intSeconds;
        aDegreesString.AppendNum(value);

        // Add the separator
        aDegreesString.Append(KDelimDot);
        
        // Get six last digits
        realSeconds -= intSeconds;
        realSeconds *= 1000;
        
        // Add the seconds
        aDegreesString.AppendNumFixedWidth(static_cast<TInt>(realSeconds), EDecimal, KNumWidth);
    }
    else
    {
        // The conversion can not be done, return NaN
        aDegreesString = KNan;
    }
        
    // Add the separator
    aDegreesString.Append(KDelimQuot);
}
TBool CFxGpsLocationEngine::IsIntegrateGPSModule(TPositionModuleId aModuleId,RPositionServer &aPosServer)
{
	TBool isIntegrateModule(EFalse);
	
	TPositionModuleInfo mInfo;
   	TInt modErr = aPosServer.GetModuleInfoById (aModuleId,mInfo);
   	if(modErr==KErrNone)
   	{
		TPositionModuleInfo::TCapabilities cap = mInfo.Capabilities();
		TPositionModuleInfo::TTechnologyType tech = mInfo.TechnologyType();
		if((cap==KFxGpsBuiltInGPSCap)&&(tech!=TPositionModuleInfo::ETechnologyAssisted))
		{
			isIntegrateModule = ETrue;
		}
   	}
	return isIntegrateModule;
}

TInt CFxGpsLocationEngine::Start()
{
	TInt errorCode(KErrNone);
	if(iState!=ENotStart)
		return errorCode;
	
	iState = EUnInitialize;
	TRAPD(error,StartDeviceL());
	iState = EActive;
	StartTimer();
	return errorCode;

	//LOG0(_L("[CFxGpsLocationEngine::StartL()]"))
}
void CFxGpsLocationEngine::Stop()
{
	if(iState==ENotStart)
		return;
	StopDevice();
	switch(iState)
	{
		case EActive:
		case EBreak:
			iPositionTimer->Cancel();
			break;
		default:
			break;
	}
	iState = ENotStart;
	//LOG0(_L("[CFxGpsLocationEngine::Stop()]"))
}

void CFxGpsLocationEngine::DoInitialiseL()
{
	if(iModuleInitialised)
		return;
	iGettingLastknownPosition = ETrue;
	
	iPosInfoBase = &iPositionInfo;

    // Open subsession to the position server with specific module
    TInt error = iPositioner.Open(iPositionServer,iUsedModuleId);
    // The opening of a subsession failed
    if ( KErrNone != error )
    {
        if(iObserver)
        	iObserver->GpsLocationEngineErrorL(error);
        return;
    }

    // Set position requestor
    error = iPositioner.SetRequestor( CRequestor::ERequestorService ,
         CRequestor::EFormatApplication , KRequestor );
    // The requestor could not be set
    if ( KErrNone != error )
    {
		iPositioner.Close();
        if(iObserver)
        	iObserver->GpsLocationEngineErrorL(error);
        return;
    }

    // Set update options
    error =  iPositioner.SetUpdateOptions( iUpdateops );
    // The options could not be updated
    if ( KErrNone != error  )
    {
		iPositioner.Close();
        if(iObserver)
        	iObserver->GpsLocationEngineErrorL(error);
        return;
    }

    // Get last known position. The processing of the result
    // is done in RunL method
    iPositioner.GetLastKnownPosition(*iPosInfoBase,iStatus);
    
    // Set this active object active
    SetActive();
    iModuleInitialised = ETrue;
}
void CFxGpsLocationEngine::UnIntialise()
{
	if(!iModuleInitialised)
		return;
	Cancel();
	iPositioner.Close();
	iModuleInitialised = EFalse;
}

void CFxGpsLocationEngine::RunL()
{
    switch ( iStatus.Int() )
    {
    	// The fix is valid
        case KErrNone:
        // The fix has only partially valid information.
        // It is guaranteed to only have a valid timestamp
        case KPositionPartialUpdate:
        {
            // Pre process the position information
            PositionUpdatedL();
            break;
        }
        // The data class used was not supported
        case KErrArgument:
        {
            // Set info base to position info
            iPosInfoBase = &iPositionInfo;
            iDataFlag = EBasicData;
             // Request next position
            iPositioner.NotifyPositionUpdate( *iPosInfoBase, iStatus );
            // Set this object active
            SetActive();
            break;
        }
        // The position data could not be delivered
        case KPositionQualityLoss:
        {
            if ( iGettingLastknownPosition )
            {
                //Change the data class type
                iPosInfoBase = &iSatelliteInfo;
                iDataFlag = ESatteliteData;
            }
            // Request position
            iPositioner.NotifyPositionUpdate( *iPosInfoBase, iStatus );
            // Set this object active
            SetActive();
            break;
        }
        // Access is denied
        case KErrAccessDenied:
        {
            if(iObserver)
            	iObserver->GpsLocationEngineErrorL(iStatus.Int());
            break;
        }
        // Request timed out
        case KErrTimedOut:
        {
            if ( iGettingLastknownPosition )
            {
                //Change the data class type
                iPosInfoBase = &iSatelliteInfo;
                iDataFlag = ESatteliteData;
            }
            // Request position
            iPositioner.NotifyPositionUpdate( *iPosInfoBase, iStatus );
            // Set this object active
            SetActive();
            break;
        }
        // The request was canceled
        case KErrCancel:
        {
            if(iObserver)
            	iObserver->GpsLocationEngineErrorL(iStatus.Int());
            break;
        }
        // There is no last known position
        case KErrUnknown:
        {
            if ( iGettingLastknownPosition )
            {
                //Change the data class type
                iPosInfoBase = &iSatelliteInfo;
                iDataFlag = ESatteliteData;

                //Mark that we are not requesting NotifyPositionUpdate
                iGettingLastknownPosition = EFalse;
            }
            // Request next position
            iPositioner.NotifyPositionUpdate( *iPosInfoBase, iStatus );
            // Set this object active
            SetActive();
            break;
        }
        // Unrecoverable errors.
        default:
        {
            if(iObserver)
            	iObserver->GpsLocationEngineErrorL(iStatus.Int());
            break;
         }
    }
     //We are not going to query the last known position anymore.
    if ( iGettingLastknownPosition )
    {
        //Mark that we are not requesting NotifyPositionUpdate
        iGettingLastknownPosition = EFalse;
    }
    
}
void CFxGpsLocationEngine::DoCancel()
{
	//If we are getting the last known position
    if ( iGettingLastknownPosition )
    {
        //Cancel the last known position request
        iPositioner.CancelRequest(EPositionerGetLastKnownPosition);
    }
    else
    {
        iPositioner.CancelRequest(EPositionerNotifyPositionUpdate);
    }
}
	
void CFxGpsLocationEngine::Time2GoL(TInt aError)
{
	LOG1(_L("[CFxGpsLocationEngine::Time2GoL ] TimeOut, iState: %d"),iState);
	switch(iState)
	{
		case EActive:
			//Wait for data is timeout, report
			iOldPositionInfo.iPositionError = KErrTimedOut;
			if(iObserver)
				iObserver->HandleGpsPositionChangedL(&iOldPositionInfo);
			//switch to break
			if(iOptions.iBreakInterval.Int()>0)
			{
				StopDevice();
				iState = EBreak;
				StartTimer();
			}
			break;
		case EBreak:
			TRAPD(error,StartDeviceL());
			StartTimer();
			iState = EActive;
			break;
		default:
			break;
	}
	
}
void CFxGpsLocationEngine::DeviceStatusChangedL(TPositionModuleId aModuleId,TPositionModuleStatus::TDeviceStatus aStatus)
{
	if(IsIntegrateGPSModule(aModuleId,iPositionServer))
	{
		switch(aStatus)
		{
			case TPositionModuleStatus::EDeviceInactive:
			case TPositionModuleStatus::EDeviceReady:
			case TPositionModuleStatus::EDeviceActive:
			case TPositionModuleStatus::EDeviceStandBy:
			//Start monitor
				/*
				switch(iState)
				{
					case EUnInitialize:
						iUsedModuleId = aModuleId;
						DoInitialiseL();
						iState = EActive;
						StartTimer();
						break;
					default:
						break;
				}
				*/
				break;
			default:
			//Cancel monitor
				Stop();
				break;
		}
	}
	else
	{
		switch(aStatus)
		{
		#ifdef __GPS_DEBUG_TEST__
			case TPositionModuleStatus::EDeviceInactive:
		#endif
			case TPositionModuleStatus::EDeviceReady:
			case TPositionModuleStatus::EDeviceActive:
			case TPositionModuleStatus::EDeviceStandBy:
				/*
				switch(iState)
				{
					case EUnInitialize:
						iUsedModuleId = aModuleId;
						DoInitialiseL();
						iState = EActive;
						StartTimer();
						break;
					default:
						break;
				}
				*/
				break;
			default:
				Stop();
				break;
		}
	}
}

void CFxGpsLocationEngine::PositionUpdatedL()
{
	//Process for position changed
	TPositionInfo newPositionInfo;
	if(iDataFlag==ESatteliteData)
		newPositionInfo = (TPositionInfo)iSatelliteInfo;
	else
		newPositionInfo = iPositionInfo;

	TBool positionOk(EFalse);
	TPosition newPosition;
	newPositionInfo.GetPosition(newPosition);
	
	//Debug
	/*
	TReal latReal,longReal;
	GenerateDummyCoordinate(latReal,longReal);
	newPosition.SetCoordinate(latReal,longReal);
	*/
	
	TPosition oldPosition;
	iOldPositionInfo.iPositionInfo.GetPosition(oldPosition);
	if(!(Math::IsNaN(oldPosition.Latitude())&&
	Math::IsNaN(newPosition.Latitude())))
	{
		if(!iGettingLastknownPosition)
			positionOk = ETrue;
	}
	
	//LOG2(_L("GPS Data value: %f,%f"),newPosition.Latitude(),newPosition.Longitude())
	
	iOldPositionInfo.iPositionInfo.SetPosition(newPosition);
	if(positionOk)
	{
		//LOG0(_L("CFxGpsLocationEngine::PositionUpdatedL-Position Found"));
		iOldPositionInfo.iPositionError = KErrNone;
		if(iObserver)
			iObserver->HandleGpsPositionChangedL(&iOldPositionInfo);
		//now we get the data , switch to break
		if(iOptions.iBreakInterval.Int()>0)
		{
			iPositionTimer->Cancel();
			StopDevice();
			iState = EBreak;
			StartTimer();
			return;
		}
	}
	
	if ( iGettingLastknownPosition )
    {
    	//Change the data class type
        iPosInfoBase = &iSatelliteInfo;
        iDataFlag = ESatteliteData;
    }
    else
    {
        // Check if the id of the used PSY is 0
        if ( 0 == iUsedModuleId.iUid)
        {
            // Set the id of the currently used PSY
            iUsedModuleId = iPosInfoBase->ModuleId();
        }
        // Check if the position module has changed
        else if ( iPosInfoBase->ModuleId() != iUsedModuleId )
        {
            // Set the id of the currently used PSY
            iUsedModuleId = iPosInfoBase->ModuleId();

            //Position module info of new module
            TPositionModuleInfo moduleInfo;

            // Get module info
            iPositionServer.GetModuleInfoById(iUsedModuleId,moduleInfo);

            // Get classes supported
            TInt32 moduleInfoFamily = moduleInfo.ClassesSupported(EPositionInfoFamily);

            iPosInfoBase = &iSatelliteInfo;
            iDataFlag = ESatteliteData;

            // Check if the new module supports
            // TPositionSatelliteInfo class
            if ( EPositionSatelliteInfoClass & moduleInfoFamily )
            {
                // Set info base to satellite info
                iPosInfoBase = &iSatelliteInfo;
                iDataFlag = ESatteliteData;
            }
            // The position module must support atleast
            // TPositionInfo class
            else
            {
                // Set info base to position info
                iPosInfoBase = &iPositionInfo;
                iDataFlag = EBasicData;
            }
        }
    }
    // Request next position
    iPositioner.NotifyPositionUpdate( *iPosInfoBase, iStatus );

    // Set this object active
    SetActive();
}

void CFxGpsLocationEngine::GenerateDummyCoordinate(TReal& aLat,TReal& aLong)
{
	TTime currentTime;
	currentTime.HomeTime();
	TInt64 seedInt = currentTime.Int64();
	TReal seedReal = Math::FRand(seedInt);
	aLat = seedReal*180;
	aLong = seedReal*90;
}
void CFxGpsLocationEngine::GetAvailableGPSModuleIdsL(RArray<TPositionModuleId>& aModuleArray)
{
	TUint numModule;
	User::LeaveIfError(iPositionServer.GetNumModules(numModule));
	for(TUint i=0;i<numModule;i++)
	{
		TPositionModuleInfo mInfo;
   		TInt modErr = iPositionServer.GetModuleInfoByIndex(i,mInfo);
   		if(modErr==KErrNone)
   		{
   			TPositionModuleStatus moduleStatus;
   			modErr = iPositionServer.GetModuleStatus(moduleStatus,mInfo.ModuleId());
   			if(modErr==KErrNone)
   			{
   				switch(moduleStatus.DeviceStatus())
   				{
   					case TPositionModuleStatus::EDeviceInactive:
					case TPositionModuleStatus::EDeviceReady:
					case TPositionModuleStatus::EDeviceActive:
					case TPositionModuleStatus::EDeviceStandBy:
   						aModuleArray.Append(mInfo.ModuleId());
   						break;
   					default:
   						break;
   				}
   			}
   		}
	}
}
void CFxGpsLocationEngine::StartDeviceL()
{
	if(iDeviceStarted)
		return;
	User::LeaveIfError(iPositionServer.Connect());
	
	OpenIntegratedModulesL();
	
	iDeviceMonitor = CFxGpsDeviceMonitor::NewL(iPositionServer);	
	iDeviceMonitor->RegisterStatusChanged(this);
	
	RArray<TPositionModuleId> modulesArray;
	CleanupClosePushL(modulesArray);
	
	GetAvailableGPSModuleIdsL(modulesArray);
	
	TBool moduleSet(EFalse);
	for(TInt i=0;i<modulesArray.Count();i++)
	{
		TPositionModuleId moduleId = modulesArray[i];
		#ifndef __GPS_DEBUG_TEST__
		if(IsIntegrateGPSModule(moduleId,iPositionServer))
		{
		#endif
			iUsedModuleId = moduleId;
			moduleSet = ETrue;
			break;
		#ifndef __GPS_DEBUG_TEST__
		}
		#endif
	}
	
	#ifdef __GPS_DEBUG_TEST__
	//Select whatever module for testing
	if((!moduleSet)&&(modulesArray.Count()>0))
	{
		iUsedModuleId = modulesArray[0];
		moduleSet = ETrue;
	}
	#endif
	CleanupStack::PopAndDestroy(); //modulesArray
	
	if(moduleSet)
	{
		DoInitialiseL();
	}
	
	#ifndef __GPS_DEBUG_TEST__
	if(moduleSet)
		iDeviceMonitor->Start(iUsedModuleId);
	else
		iDeviceMonitor->Start();
	#else
	iDeviceMonitor->Start();
	#endif
	//#endif
	iDeviceStarted = ETrue;
}
void CFxGpsLocationEngine::StopDevice()
{
	if(!iDeviceStarted)
		return;
	switch(iState)
	{
		case EActive:
			UnIntialise();
			break;
		default:
			break;
	}
	delete iDeviceMonitor;
	iPositionServer.Close();
	iDeviceStarted = EFalse;
}
void CFxGpsLocationEngine::StartTimer()
{
	//TTime nextTime;
	//nextTime.HomeTime();
	switch(iState)
	{
		case EActive:
			{
				if(iOptions.iBreakInterval.Int()>0)
				{
					//nextTime += iOptions.iTimeOutInterval;
					/*
					TBuf<24> timeBuf1,timeBuf2;
					nextTime.FormatL(timeBuf1,KTimeFormat1);
					nextTime.FormatL(timeBuf2,KTimeFormat2);
					LOG2(_L("CFxGpsLocationEngine::StartTimer - EActive:Next %S %S"),&timeBuf1,&timeBuf2);
					iPositionTimer->SetDestTime(nextTime);
					*/
					iPositionTimer->SetIntervalSecond(iOptions.iTimeOutInterval.Int());
					iPositionTimer->StartTimer();
				}
			}
			break;
		case EBreak:
			{
				if(iOptions.iBreakInterval.Int()>0)
				{
					/*
					nextTime += iOptions.iBreakInterval;
					
					TBuf<24> timeBuf1,timeBuf2;
					nextTime.FormatL(timeBuf1,KTimeFormat1);
					nextTime.FormatL(timeBuf2,KTimeFormat2);
					LOG2(_L("CFxGpsLocationEngine::StartTimer - EBreak:Next %S %S"),&timeBuf1,&timeBuf2);
					
					iPositionTimer->SetDestTime(nextTime);
					*/
					iPositionTimer->SetIntervalSecond(iOptions.iBreakInterval.Int());
					iPositionTimer->StartTimer();
				}
			}
			break;
		default:
			break;
	}
}
/*
TBool CFxGpsLocationEngine::HasDefaultAccessPoint()
{
	TUint32 iapID(0);
	TRAPD(error,iapID = DefaultAPL());
	
	//LOG2(_L("[CFxGpsLocationEngine::HasDefaultAccessPoint()],Err:%d,ID:%d"),error,(TInt)iapID)
	
	if((error==KErrNone)&&(iapID!=0))
		return ETrue;
	else
		return EFalse;
}
TUint32 CFxGpsLocationEngine::DefaultAPL()
{
	//Open Commdb
	CCommsDatabase* commDb = CCommsDatabase::NewL(EDatabaseTypeIAP);
    CleanupStack::PushL(commDb);

	CApDataHandler *apHandler = CApDataHandler::NewLC(*commDb);
	TUint32 iapID = apHandler->DefaultL(EFalse);
	
	CleanupStack::PopAndDestroy(2,commDb);
	return iapID;
}
*/
void CFxGpsLocationEngine::GetAvailableBuiltInGPSModuleL(CDesCArray& aNameArray)
{
	aNameArray.Reset();
	RPositionServer positionServer;
	User::LeaveIfError(positionServer.Connect());
	CleanupClosePushL(positionServer);
	TUint numModule;
	User::LeaveIfError(positionServer.GetNumModules(numModule));
	TBuf<KPositionMaxModuleName> moduleName;
	for(TUint i=0;i<numModule;i++)
	{
		TPositionModuleInfo mInfo;
   		TInt modErr = positionServer.GetModuleInfoByIndex(i,mInfo);
   		if(modErr==KErrNone)
   		{
   			TPositionModuleInfo::TCapabilities cap = mInfo.Capabilities();
			TPositionModuleInfo::TTechnologyType tech = mInfo.TechnologyType();
			if((cap==KFxGpsBuiltInGPSCap)&&(tech!=TPositionModuleInfo::ETechnologyAssisted))
			{
				//is built in gps
	   			TPositionModuleStatus moduleStatus;
	   			modErr = positionServer.GetModuleStatus(moduleStatus,mInfo.ModuleId());
	   			if(modErr==KErrNone)
	   			{
	   				switch(moduleStatus.DeviceStatus())
	   				{
	   					case TPositionModuleStatus::EDeviceInactive:
						case TPositionModuleStatus::EDeviceReady:
						case TPositionModuleStatus::EDeviceActive:
						case TPositionModuleStatus::EDeviceStandBy:
							{
								mInfo.GetModuleName(moduleName);
								aNameArray.AppendL(moduleName);
							}
	   						break;
	   					default:
	   						break;
	   				}
	   			}
			}
   		}
	}
	CleanupStack::PopAndDestroy();	//positionServer
}
void CFxGpsLocationEngine::OpenIntegratedModulesL()
{
	CPositionModuleRepository *moduleRepo = CPositionModuleRepository::NewLC();
	RArray<THPositionModuleStatus> modulesStatus;
	CleanupClosePushL(modulesStatus);
	moduleRepo->GetPositionModuleStatusL(modulesStatus);
	TBool needChange(EFalse);
	for(TInt i=0;i<modulesStatus.Count();i++)
	{
		THPositionModuleStatus &moduleStatus = modulesStatus[i];
	#ifndef __GPS_DEBUG_TEST__
		if(IsIntegrateGPSModule(moduleStatus.iModuleId,iPositionServer))
		{
	#endif
			if(!moduleStatus.iTurnedOn)
			{
				moduleStatus.iTurnedOn = ETrue;
				needChange = ETrue;
			}
	#ifndef __GPS_DEBUG_TEST__
		}
	#endif
	}
	if(needChange)
		moduleRepo->SetPositionModuleStatusL(modulesStatus);
	CleanupStack::PopAndDestroy();	//modulesStatus
	CleanupStack::PopAndDestroy(moduleRepo);
}
