#ifndef __DeviceIMEIObserver_H__
#define __DeviceIMEIObserver_H__

#include "GlobalConst.h"

/**
* Used for both 2nd and 3rd
*/
class MDeviceIMEIObserver
	{
public:
	virtual void OfferIMEI(const TDeviceIMEI& aIMEI) = 0;
	};

#endif
