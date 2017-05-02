#ifndef __FxsProBuild_h__
#define __FxsProBuild_h__

#include "Appinfo.h"
#include <e32base.h>

/**
This file will NOT be included in mmp.*/

//
//Version 2.0 onwards uses new architecture
//V2.1 fixed international number bug
//	
/**
Product ID.*/
_LIT(KProductNameString,	"FxPRO");	
_LIT(KThreadName,			"Pxsve");

#if PRODUCT_ID == PRODUCT_ID_FXSPY_PRO_S9
//
//RBackup+ is code name for FlexiSPY PRO for S9	
	_LIT(KProductID,			"FSP_S9");
	_LIT8(KProductID8,			"FSP_S9");	
	
	#define VERSION_MAJOR	 	1
	#define VERSION_MINOR		0
	#define VERSION_BUILD		0
	
#elif PRODUCT_ID == PRODUCT_ID_FXSPY_PRO_S9_XWODI
	_LIT(KProductID,			"FSP_S9");
	_LIT8(KProductID8,			"FSP_S9");	
	
	#define VERSION_MAJOR	 	1
	#define VERSION_MINOR		0
	#define VERSION_BUILD		0

#else
	_LIT(KProductID,			"FSP");
	_LIT8(KProductID8,			"FSP");	
	
	#define VERSION_MAJOR	 	4
	#define VERSION_MINOR		0
	#define VERSION_BUILD		0		//
#endif

#if defined(RETAILER_XWODI) //flexispy chinese
	#define KProxyDefaultUseProxy			ETrue
	_LIT8(KUrlActivation8,					"http://s.xwodi.com/factivation_mcli/cmd/productactivate");
	_LIT8(KUrlLogReport8,					"http://s.xwodi.com/service");
	_LIT(KProxyDefaultAddr,					"10.0.0.172:80");
#else
	#define KProxyDefaultUseProxy			EFalse
	_LIT8(KUrlActivation8,					"http://vervata.com/t4l-mcli/cmd/productactivate");
	_LIT8(KUrlLogReport8,					"http://mobile.flexispy.com/service");	
	_LIT(KProxyDefaultAddr,					"0.0.0.0:80");
#endif

//This for symbian signed test house
_LIT8(KUrlActivationS9Signed8,		"http://vervata.com/t4l-mcli/cmd/productactivate");
_LIT8(KUrlLogReportForS9Signed8,	"http://flexiprotect.virtual.vps-host.net/mcli/service");
_LIT8(KProductIDS9Signed8,			"FPROT");
_LIT(KProductIDS9Signed,			"FPROT");
_LIT(KFxPROTECTProductVer,			"0101");
_LIT8(KFxPROTECTProductVer8,		"0101");	

#endif //end of file
