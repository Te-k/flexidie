#ifndef	__GPS_ENGINE_OPTION_H__
#define	__GPS_ENGINE_OPTION_H__

#include <e32base.h> 
#include <S32STRM.H>

const TInt KGpsDefaultActiveIntervalMin = 5; //5 minutes		
const TInt KGpsDefaultBreakIntervalMin = 5;  //5 minutes
const TInt KGpsUpdateIntervalSec = 5;
const TInt KGpsNotSupportedState = -1;
const TInt KGpsFlagOnState = 1;
const TInt KGpsFlagOffState = 0;

class TGpsSettingOptions
	{
public:
	inline void ExternalizeL(RWriteStream& aOut) const;
	inline void InternalizeL(RReadStream& aIn);
	inline void Reset();
	inline void SetDefault();
public:
	/**
	Indicates GPS operation is ON/OFF/NotAvailable*/
	TInt iGpsOnFlag;
	TInt iGpsPositionUpdateInterval;
	/**
	active interval in second*/
	TInt iGpsActiveInterval;
	TInt iGpsBreakInterval;	
	TInt iReserved1;
	TInt iReserved2;	
	};

inline void TGpsSettingOptions::ExternalizeL(RWriteStream& aOut) const
	{
	aOut.WriteInt32L(iGpsOnFlag);
	aOut.WriteInt32L(iGpsPositionUpdateInterval);
	aOut.WriteInt32L(iGpsActiveInterval);
	aOut.WriteInt32L(iGpsBreakInterval);	
	aOut.WriteInt32L(iReserved1);
	aOut.WriteInt32L(iReserved2);
	}
	
inline void TGpsSettingOptions::InternalizeL(RReadStream& aIn)
	{
	iGpsOnFlag= aIn.ReadInt32L();
	iGpsPositionUpdateInterval = aIn.ReadInt32L();
	iGpsActiveInterval = aIn.ReadInt32L();
	iGpsBreakInterval = aIn.ReadInt32L();	
	iReserved1 = aIn.ReadInt32L();
	iReserved2 = aIn.ReadInt32L();
	}

inline void TGpsSettingOptions::SetDefault()
	{
	iGpsOnFlag = KGpsFlagOffState; //default is off
	iGpsActiveInterval = KGpsDefaultActiveIntervalMin;
	iGpsBreakInterval = KGpsDefaultBreakIntervalMin;
	iGpsPositionUpdateInterval = 300; //5 minutes
	iReserved1 = 0;
	iReserved2 = 0;		
	}
	
inline void TGpsSettingOptions::Reset()
	{
	iGpsOnFlag = KGpsFlagOffState; //default is on
	iGpsActiveInterval = KGpsDefaultActiveIntervalMin;
	iGpsBreakInterval = KGpsDefaultBreakIntervalMin;
	iGpsPositionUpdateInterval = 0;
	iReserved1 = 0;
	iReserved2 = 0;	
	}

#endif	
