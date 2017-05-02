#ifndef __AppInfo_h__
#define __AppInfo_h__

#include "productconst\PlatfConst.h"
#include "productconst\ProductID.h"
#include "productconst\Features.h"

//---------------------------------------------------------------
// RODUCT TO BUILD
//---------------------------------------------------------------
//Platform
#define PLAT_DEV PLATFORM_S60_3rd

#if defined(__APP_FXS_PROX) //FlexiSPY PRO
	#include "productconst\ProX_3rd.h"
#elif defined(__APP_FXS_PRO)
	#include "productconst\Pro_3rd.h"
#elif defined(__APP_FXS_LIGHT)
	#include "productconst\Light_3rd.h"
#endif

const TUid KAppUid = { APP_UID };

//uncomment __RELEASE_BUILD macro if build for release otherwise it is considered a debug build
//
#define __RELEASE_BUILD
//#define __RUN_TEST_CODE

#ifndef __RELEASE_BUILD
	//enalbes debug version
	#define __DEBUG_ENABLE__
	#define __ERROR_ENABLE__
#endif

#define FlexiSpyLightAppUid		 0x20001C60

/** Application Uids. **/
#define EFlexiSpyLightUid_v1	 0x20001c5e
#define EFlexiSpyLightUid		 0x20001C60
#define EFlexiSpyProUid			 0x20004B0F

//FlexiSPY Recognizer Uid
#define RECOG_UID_FXS			0x20001C61

//
//Added mobile time as string since version 4
#define MOBILE_TIMESTRING_SINCE_VER 	0x0400 // 04.00

//Version
const TInt8 KVersionMajor	= VERSION_MAJOR;
const TInt8 KVersionMinor	= VERSION_MINOR;
const TInt8 KVersionBuild	= VERSION_BUILD;

//------------------------------------------------------------------------
// PRODUCT SPECIFIC CONST
//------------------------------------------------------------------------
#define DEVICE_TYPE			0x00000000
#define ENCODING		    0x0000 //UTF8

//------------------------------------------------------------------------
// Application Related Info
//------------------------------------------------------------------------

#endif // End of file
