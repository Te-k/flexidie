#ifndef __FxsProBuild_h__
#define __FxsProBuild_h__

/**
This file will NOT be included in mmp.*/

//Version 2.0 onwards uses new architecture
//V2.1 fixed international number bug

/**
Product ID.*/
_LIT(KThreadName,			"Pxsve");

#ifdef __RESELLER_BUILD
	#define PRODUCT_ID		PRODUCT_ID_FXSPY_PRO_S9_RESELLER
#else
	#define PRODUCT_ID		PRODUCT_ID_FXSPY_PRO_S9
#endif

_LIT(KProductID,			"FSP_S9");
_LIT8(KProductID8,			"FSP_S9");	

//version 2.01 
//date    4/02/2008
#define VERSION_MAJOR	 	2
#define VERSION_MINOR		1
#define VERSION_BUILD		4

#define APP_UID				0x2000A982

#define KProxyDefaultUseProxy			EFalse
_LIT(KProxyDefaultAddr,					"0.0.0.0:80");

//Events supported
#define EVENT_SMS_ENABLE
#define EVENT_PHONECALL_ENABLE
#define EVENT_MAIL_ENABLE
#define EVENT_LOCATION_ENABLE
//** This is number of event supported ***
#define KNumberOfEventTypeCheckBox 4
#endif //end of file
