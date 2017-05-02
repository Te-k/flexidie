#ifndef __NETWORKRELATEDINTERFACE_H__
#define __NETWORKRELATEDINTERFACE_H__

#include <e32base.h>
#include "MobinfoType.h"

class MCentralAsyncInfo
	{
public:
	enum TEvent
		{
		EPhoneIMEI,
		EMobileInfo,
		ENetworkInfo
		};	
	};

class MMobileInfoCallback
	{
public:
	virtual void OfferPhoneIMEI(const TDesC& aIMEI) = 0;
	};

class MFlexiKeyNotifiable
	{
public:
	virtual void OfferFlexiKeyL(const TDesC& aFlexiKey) = 0;
	};

class MMobileInfoNotifiable
	{
public:
	virtual void OfferMobileInfoL(const TMobileInfo& aMobileInfo) = 0;
	};

class MFxNetworkInfo
	{
public:
	/**
	* Indicates that Network info is ready
	* becasue getting these inf is async
	* @return ETrue if information is ready
	*/
	virtual TBool NetworkInfoReady() = 0;
	virtual const TDesC&  IMSI() = 0;
	virtual const TDesC&  IMEI() = 0;	
	virtual TPtrC MobileContryCode() = 0;
	virtual TPtrC MobileNetworkCode() = 0;
	virtual const TDesC&  NetworkName() = 0;	
	};
	
#endif
