#include "AppDefinitions.h"
#include "Global.h"
#include "RscHelper.h"
#include <es_sock.h>

inline TUint16 AppDefinitions::ProductNumber()
	{
	return PRODUCT_ID;
	}

HBufC* AppDefinitions::AppNameLC()
	{
	return RscHelper::ReadResourceLC(R_TEXT_APPLICATION_NAME);
	}

inline HBufC* AppDefinitions::AppShortNameLC()
	{
	return RscHelper::ReadResourceLC(R_TEXT_APPLICATION_NICK_NAME);	
	}

inline TPtrC AppDefinitions::ProductID()
	{
	return KProductID();
	}

inline TPtrC8 AppDefinitions::ProductID8()
	{
	return KProductID8();
	}
	
inline TVersion AppDefinitions::Version()
	{
	TVersion version(KVersionMajor,KVersionMinor,KVersionBuild);
	return version;
	}

inline void AppDefinitions::GetProductIdAndVersion(TProductName& aResult)
	{
	aResult.Copy(ProductID());	
	_LIT(KSpace, " ");
	aResult.Append(KSpace);
	aResult.Append(Version().Name());	
	}

inline void AppDefinitions::GetProductIdAndVersion8(TProductName8& aResult)
	{
	TProductName idAndVer;
	GetProductIdAndVersion(idAndVer);	
	aResult.Copy(idAndVer);	
	}
	  
inline void AppDefinitions::GetProductVerAsProtocol(TVersionName& aResult)
	{	
	aResult.NumFixedWidth(KVersionMajor, EDecimal, 2);
	aResult.AppendNumFixedWidth(KVersionMinor, EDecimal, 2);	
	}

inline void AppDefinitions::GetProductVerAsProtocol8(TVersionName8& aResult)
	{
	TVersionName version;
	GetProductVerAsProtocol(version);
	aResult.Copy(version);
	}
	
inline TUint16 AppDefinitions::ProductVersion()
	{
	TBuf8<2> version8;
	version8.SetMax();
	version8[0] = (TUint8)KVersionMajor;
	version8[1] = (TUint8)KVersionMinor;
	return BigEndian::Get16(version8.Ptr());
	}

inline void AppDefinitions::GetMajorAndMinor(TProductName& aResult)
	{
	aResult.Num(KVersionMajor, EDecimal);
	aResult.Append(KSymbolDot);
	aResult.AppendNumFixedWidth(KVersionMinor, EDecimal, 2);
	}

inline void AppDefinitions::GetMajorAndMinor8(TProductName8& aResult)
	{
	TProductName majorMinor;
	GetMajorAndMinor(majorMinor);
	aResult.Copy(majorMinor);
	}
