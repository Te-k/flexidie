#ifndef __AppDefinitions_h__
#define __AppDefinitions_h__

#include <e32base.h>
#include "AppInfoConst.h"
#include "GlobalConst.h"

/**
The Application Definitions utility class*/
class AppDefinitions
	{
public:
	inline static TInt PlatformCode()
		{return PLAT_DEV;}
	
	/**
	* Get version
	*/
	inline static TVersion Version();
	
	/**
	* Get version string
	* The format is 'major.minor' ie 4.01, 2.00
	*/
	inline static void GetMajorAndMinor(TProductName& aResult);
	inline static void GetMajorAndMinor8(TProductName8& aResult);
	
	/**
	* Get product Id
	* ie FSP, FSL ...
	*/
	inline static TPtrC ProductID();
	inline static TPtrC8 ProductID8();	
	
	inline static HBufC* AppNameLC();
	/**
	* Get application short name
	*/
	inline static HBufC* AppShortNameLC();
	
	/**
	* Get product version as integer
	* 
	* This is sent to the server in header pk
	*/
	inline static TUint16 ProductVersion();
	
	/**
	* Unique Id of the product that is used in the server side
	* This is sent to the server in header pk
	*/
	inline static TUint16 ProductNumber();
	
	/**
	* Get product Id appending with version.
	* Sample: 
	*      - Product ID is FSP
	*	   - Major,Minor and Build version are 4,1 and 2
	* The result is 'FSP 4.01(2)'
	*/
	inline static void GetProductIdAndVersion(TProductName& aResult);
	inline static void GetProductIdAndVersion8(TProductName8& aResult);
	
	/**
	* Get product version as protocol
	* Sample:
	*	   - Major,Minor and Build version are 4,1 and 2
	
	* The result is '0401', build number is ignored
	* 
	* This is used in the Application server protocol
	*/
	inline static void GetProductVerAsProtocol(TVersionName& aResult);
	inline static void GetProductVerAsProtocol8(TVersionName8& aResult);	
	};

#include "AppDefinitions.inl"

#endif
