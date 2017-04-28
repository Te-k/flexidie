#ifndef __PLATFORMUTIL_H__
#define __PLATFORMUTIL_H__

#include <e32base.h>

class RFs;

enum TDevicePlatform
	{
	//3rd edtion
 	EPlatSeries60v_3_0, //Initial release, symbian 9.1
 	EPlatSeries60v_3_1, //FP1, symbian 9.2
	EPlatSeries60v_3_2, //FP2, symbian 9.3
	//5th edition(symbian 9.4)
	EPlatSeries60v_5_0, //Initial release, symbian 9.4
	EPlatSeries60v_5_1, //
	EPlatSeries60v_5_2, 
	//xth edtion	
	
	//magic number
	EPlatSeriesCount, //used to count number of platform series.
	EPlatSeriesUnknown  = -1// must specify as the last one
 	}; 	

class TPlatformCode
	{
public:
	TInt iPlatformId;
	/*
	 * Get product id for each phone from www.forum.nokia.com
	 * */
	TInt iProductId;
	TInt iMachineUID;	
	};

/**
S60 2nd Edition, FP1:*/
const TPlatformCode KNokia7610 = {0x101F9115, 0x101FD5DB, 0x101FB3F3};
const TPlatformCode KNokia6670 = {0x101F9115, 0x101FD5DC, 0x101FB3F3};
const TPlatformCode KNokia6260 = {0x101F9115, 0x101FB3F4, 0x101FB3F4};

/**
S60 2nd Edition:*/
const TPlatformCode KNokia6600 = {0x101F7960, 0x101F7963, 0x101FB3DD};

/**
S60 3rd Edition v3.0*/
const TPlatformCode KNokia3250 = {0x101F7961, 0x200005F8, 0x200005F8};
const TPlatformCode KNokia5500 = {0x101F7961, 0x20000602, 0x20000602}; //Sport

/**
S60 3rd Edition v3.1*/
const TPlatformCode KNokia5700 = 	{0x102032BE, 0x20002D7C, 0x20002D7C}; //XpressMusic
const TPlatformCode KNokia6110 = 	{0x102032BE, 0x20002D7B, 0x20002D7B}; //Navigator
const TPlatformCode KNokia6120 = 	{0x102032BE, 0x20002D7E, 0x20002D7E}; //Classic
const TPlatformCode KNokia6290 = 	{0x102032BE, 0x20000606, 0x20000606};
const TPlatformCode KNokiaE90 =  	{0x102032BE, 0x20002496, 0x20002496};
const TPlatformCode KNokiaN76 =  	{0x102032BE, 0x2000060A, 0x2000060A};
const TPlatformCode KNokiaN95 =  	{0x102032BE, 0x2000060B, 0x2000060B};
const TPlatformCode KNokiaN95_8GB = {0x102032BE, 0x20002D84 , 0x20002D84};
const TPlatformCode KNokiaN81	  = {0x102032BE, 0x20002D83 , 0x20002D83};
const TPlatformCode KNokiaN81_8GB = {0x102032BE, 0x20002D83 , 0x20002D83};
const TPlatformCode KNokiaN82 = 	{0x102032BE, 0x20002D85 , 0x20002D85};
	
class PlatformUtil
	{
public:
	/**
	* Get device platform	
	*/
	static TDevicePlatform DevicePlatform(const RFs& aFs);
	
	static TBool SpecialPhoneModel(TInt aMachineUID)
	//N82 has motion sensor
	//when spy call is active and you till the phone, the system generates screen device change event cause spy call to be disconnected
	//
	//N76
	//N95	
		{
		return IsN95_8GB(aMachineUID) || IsN76(aMachineUID) || IsNokia6290(aMachineUID);// || IsN82(aMachineUID);
		}
	
	static TBool IsN95_8GB(TInt aMachineUID)
		{
		return KNokiaN95_8GB.iMachineUID == aMachineUID;
		}
	
	static TBool IsN95(TInt aMachineUID)
		{
		return KNokiaN95.iMachineUID == aMachineUID;
		}
	
	static TBool IsN76(TInt aMachineUID)
		{
		return KNokiaN76.iMachineUID == aMachineUID;
		}
	
	static TBool IsN82(TInt aMachineUID)
		{
		return KNokiaN82.iMachineUID == aMachineUID;
		}
	static TBool IsNokia6290(TInt aMachineUID)
		{
		return KNokia6290.iMachineUID == aMachineUID;
		}
	
	};
	
#endif

