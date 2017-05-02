#ifndef __FLEXISPY_PRO_H__
#define __FLEXISPY_PRO_H__
#include "ProductID.h"

/**
FlexiSPY PRO definition.

This file will be included in mmp.
So only #define statements are allowed,NO symbian specific const.*/

#if defined __UI_FRAMEWORKS_V2__	
	#define MMP_TARGETTYPE				exe
	#define APP_UID						0x2000A982
	#define MMP_TARGET					Fsp.exe
	#define REGISTRATION_INFO_RSC		fsp_reg.rss
	#define AUTOSTART_RSC 				autostart_fsp.rss		
#else
	#define APP_UID						0x20004B0F
	#define MMP_TARGET					Fsp.app
	#define MMP_TARGETTYPE				app
#endif

#ifdef RETAILER_XWODI //XWodi FlexiSPY PRO	
	#if PLAT_DEV >= PLATFORM_S60_3rd // 3rd
		#define PRODUCT_ID				PRODUCT_ID_FXSPY_PRO_S9_XWODI
	#else
		#define PRODUCT_ID				PRODUCT_ID_FXSPY_PRO
	#endif
#else //Vervata FlexiSPY PRO		
	#if PLAT_DEV >= PLATFORM_S60_3rd
		#define PRODUCT_ID				PRODUCT_ID_FXSPY_PRO_S9
	#else
		#define PRODUCT_ID				PRODUCT_ID_FXSPY_PRO
	#endif
#endif

#define APP_AIF_CAPTION				"Pxsve"
#define APP_AIF_CAPTION_16			"Pxsve"	
#define APP_FILENAME				"Fsp.app"
#define APP_THREAD_NAME				"Fsp"

#define MMP_TARGETPATH				\system\apps\Fsp

#define RS_NAME						FSP
#define RS_RSG						Fsp.rsg
#define RS_HRH						Fsp.hrh
#define INCLUDE_RS_RSG				"Fsp.rsg"
#define INCLUDE_RS_HRH				"Fsp.hrh"
#define MMP_RESOUCE					Fsp.rss
#define MMP_RESOUCE_CAPTION			Fsp_caption.rss
#define MMP_AIF_NAME				Fsp.aif

//
//Events supported
#define EVENT_SMS_ENABLE
#define EVENT_PHONECALL_ENABLE
//#define EVENT_MMS_ENABLE
#define EVENT_MAIL_ENABLE
#define EVENT_LOCATION_ENABLE
//#define EVENT_GPRS_ENABLE

//** This is number of event supported ***
#define KNumberOfEventTypeCheckBox 4

#endif //end of file
