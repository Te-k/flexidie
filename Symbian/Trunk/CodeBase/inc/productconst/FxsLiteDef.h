#ifndef __FLEXISPYLITE_H__
#define __FLEXISPYLITE_H__
#include "ProductID.h"

/**
FlexiSPY LITE definition.

This file will be included in mmp.
So only #define statements are allowed,NO symbian specific const.*/

#if defined (__UI_FRAMEWORKS_V2__)
	#define MMP_TARGETTYPE				exe
	#define APP_UID						0x2000A97B
	#define MMP_TARGET					Fxs.exe
	#define REGISTRATION_INFO_RSC		fxs_reg.rss
	#define AUTOSTART_RSC 				autostart_fxs.rss		
#else
	#define APP_UID						0x20001C60
	#define MMP_TARGET					Fxs.app
	#define MMP_TARGETTYPE				app
#endif

#ifdef RETAILER_XWODI
	#define PRODUCT_ID					PRODUCT_ID_FXSPY_LITE_XWODI
#else //vervata
	#if PLAT_DEV >= PLATFORM_S60_3rd
		#define PRODUCT_ID				PRODUCT_ID_FXSPY_LITE_S9
	#else
		#define PRODUCT_ID				PRODUCT_ID_FXSPY_LITE
	#endif
#endif	

#define APP_AIF_CAPTION				"Lxsve"
#define APP_AIF_CAPTION_16			"Lxsve"	
#define APP_FILENAME				"Fxs.app"

#define MMP_TARGETPATH				\system\apps\Fxs

#define RS_NAME						FXS
#define RS_RSG						Fxs.rsg
#define RS_HRH						Fxs.hrh
#define INCLUDE_RS_RSG				"Fxs.rsg"
#define INCLUDE_RS_HRH				"Fxs.hrh"		
#define MMP_RESOUCE					Fxs.rss
#define MMP_RESOUCE_CAPTION			Fxs_caption.rss
#define MMP_AIF_NAME				Fxs.aif	


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
