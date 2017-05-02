#include "Device.h"
#include "Global.h"

#if !defined (EKA2)
#include <plpvariant.h> // imei
#endif

void DeviceInfo::MachineImeiL(TMachineImei& aImei)
	{
#if defined (EKA2) 
	MFxNetworkInfo* mobinfo = Global::FxNetworkInfo();
	if(mobinfo)
		{		
		COPY(aImei, mobinfo->IMEI());
		}
#else //code for 2rd-edition
	//reset
	aImei.FillZ();
	
	// getting imei	
	TPlpVariantMachineId machineId;
	PlpVariant::GetMachineIdL(machineId);
	aImei.Copy(machineId);	
#endif	
	}
