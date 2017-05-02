#ifndef __FXLOCACTIONSERVICEINTERFACE_H__
#define __FXLOCACTIONSERVICEINTERFACE_H__

#include <e32base.h>

class MFxLocationChangeObserver
	{
public:
	enum TChangeEvent
		{
		EEventNone,
		/**
		GPS Position changed*/
		EEventPositionChanged,
		/**
		Cell Id changed*/
		EEventCellIdChanged,
		/**
		Cell Broadcast Message location name*/
		EEventCBMCellName,
		};
	
	/**
	* 
	* @param aEvent Event type
	* @param aArg1 Event type-specific argument value
	*		 aEvent is EEventCellChanged, aArg1 is CTelephony::TNetworkInfoV1
	*/
	virtual void LocationChanged(TChangeEvent aEvent, TAny* aArg1) = 0;
	};

/**
Cell Broadcast Message Observer*/
class MFxCBMObserver
	{
public:
	/**
	* Offer location string
	* @param aCellName
	*/	
	virtual void OfferCellName(const TDesC& aCellName) = 0;
	};

class MFxNetworkChangeObserver
	{
public:
	virtual void NetworkInfoChanged(TAny* aArg1) = 0;
	virtual void CurrentNetworkInfo(TAny* aArg1) = 0;
	};

class MFxCBMCellChangeObserver
	{
public:
	virtual void CBMCellChanged(TAny* aArg1) = 0;
	};

/**
* Interface class for getting Positioning Method info
*/
class MFxPositionMethod
	{
public:
	/**
	* @return EFalse if GPS not supported
	*/
	virtual TBool IsGpsAvailable() = 0;
	/**
	* Get number of gps module that is enabled	
	*/
	virtual TInt CountBuiltInEnabledModule() = 0;
	/**
	* Get built-in module name(s) that is marked as enabled in the phone' settings
	*/
	virtual void GetBuiltInEnabledModule(CDesCArray& aResult) = 0;
	};

#endif
