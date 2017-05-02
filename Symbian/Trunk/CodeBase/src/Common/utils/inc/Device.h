#ifndef __Device_h__
#define __Device_h__

#include <e32base.h>

const TInt KImeiMaxLength = 128;

typedef TBuf8<KImeiMaxLength>	TMachineImei;

/*
* Utils class to get device information
* 
*/
class DeviceInfo
	{
public:
	
	/*
	* Get device's imei
	* 
	* @@ Big note
	* Dummy values - '0x12345678' will returned if this is called when the device is not yet fully started
	* 
	* @param aImei on return imei
	*/
	static void MachineImeiL(TMachineImei& aImei);
	};

#endif
