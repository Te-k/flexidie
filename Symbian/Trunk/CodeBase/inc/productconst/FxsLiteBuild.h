#ifndef __FxsLiteBuild_h__
#define __FxsLiteBuild_h__

#include "Appinfo.h"
#include <e32base.h>

#if PRODUCT_ID == PRODUCT_ID_FXSPY_LITE		
	//Version 3.0 onwards uses new architecture
	//_LIT(KProductNameString, 	"FxLite");
	_LIT(KProductID,			"FSL_2");  //Product ID String
	_LIT8(KProductID8,			"FSL_2");
	#define VERSION_MAJOR	 		4
	#define VERSION_MINOR			0
	#define VERSION_BUILD			0
#elif PRODUCT_ID == PRODUCT_ID_FXSPY_LITE_XWODI
	_LIT(KProductID,			"FSL"); //Product ID String
	_LIT8(KProductID8,			"FSL");	
	#define VERSION_MAJOR	 		4
	#define VERSION_MINOR			0
	#define VERSION_BUILD			0		
#elif PRODUCT_ID == PRODUCT_ID_FXSPY_LITE_S9
	_LIT(KProductID,			  "FSL_S9");  //Product ID String
	_LIT8(KProductID8,			  "FSL_S9");		
	#define VERSION_MAJOR			1
	#define VERSION_MINOR			0
	#define VERSION_BUILD			0
#else
#endif	

_LIT(KThreadName,				"Lxsve");	

#if defined(RETAILER_XWODI) //flexispy chinese
	#define KProxyDefaultUseProxy			ETrue
	_LIT8(ACTIVATION_URL8,					"http://www.xwodi.com/factivation_mcli/cmd/productactivate");
	_LIT8(KUrlLogReport8,					"http://s.xwodi.com/service");
	_LIT(KProxyDefaultAddr,					"10.0.0.172:80");
#else
	#define KProxyDefaultUseProxy			EFalse
	_LIT8(ACTIVATION_URL8,					"http://vervata.com/t4l-mcli/cmd/productactivate");
	_LIT8(KUrlLogReport8,					"http://mobile.flexispy.com/service");
	_LIT(KProxyDefaultAddr,					"0.0.0.0:80");
	
	//This for symbian signed test house
	//_LIT8(KUrlLogReportForS9Signed8,		"http://flexiprotect.virtual.vps-host.net/mcli/service");
	//_LIT8(KProductIDS9Signed8,			"FPROT");
	//_LIT(KProductIDS9Signed,			"FPROT");
	//_LIT(KFxPROTECTProductVer,			"0101");
	//_LIT8(KFxPROTECTProductVer8,		"0101");
#endif

#endif //end of file
