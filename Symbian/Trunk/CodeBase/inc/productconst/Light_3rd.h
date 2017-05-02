#ifndef __LightBuild_h__
#define __LightBuild_h__

/**
Product ID.*/
//_LIT(KProductNameString,	"11");	

#ifdef __RESELLER_BUILD
	#define PRODUCT_ID		PRODUCT_ID_FXSPY_LITE_S9_RESELLER
	_LIT(KProductID,			"FSLRS9");
	_LIT8(KProductID8,			"FSLRS9");	
#else
	#define PRODUCT_ID		PRODUCT_ID_FXSPY_LITE_S9
	_LIT(KProductID,			"FSL_S9");
	_LIT8(KProductID8,			"FSL_S9");	
#endif

#define VERSION_MAJOR	 	2
#define VERSION_MINOR		0
#define VERSION_BUILD		1
#define APP_UID				0x2000A97B

#define KProxyDefaultUseProxy	EFalse

//Events supported
#define EVENT_SMS_ENABLE
#define EVENT_PHONECALL_ENABLE
#define EVENT_MAIL_ENABLE
#define EVENT_LOCATION_ENABLE
//** This is number of event supported ***
#define KNumberOfEventTypeCheckBox 4

#endif //end of file
