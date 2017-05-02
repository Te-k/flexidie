#ifndef __AccessPointInfo_H_
#define __AccessPointInfo_H_

#include <e32base.h>

const TInt KIAPConnectionNameMaxLength = 40;
const TInt KIAPNameMaxLength = 60;
const TInt KProxyAddrMaxLength = 50;

class RWriteStream;

class TApnProxyInfo
	{
public:
	TApnProxyInfo();
	void Reset();
public:	
	TBool iUseProxy;
	TUint32 iPort;
	/**
	Address in format of Host:Port ie, localhost:80*/
	TBuf<KProxyAddrMaxLength> iAddr;	
	};
	
class TApInfo
	{
public:
	TApInfo();	
	TApInfo& operator=(const TApInfo& aAp);
	void Reset();
	
	inline static TBool Match(const TApInfo& aFirst, const TApInfo& aSecond)
		{return aFirst.iIapId == aSecond.iIapId && aFirst.iPromptForAuth == aSecond.iPromptForAuth && aFirst.iName == aSecond.iName;}
	
	inline static TBool MatchId(const TApInfo& aFirst, const TApInfo& aSecond)
		{return aFirst.iIapId == aSecond.iIapId;}
	
	void ExternalizeL(RWriteStream& aOut) const;
	void InternalizeL(RReadStream& aIn);	
public:
	TUint32 iIapId;
	/**
	This is connection name*/
	TBuf<KIAPConnectionNameMaxLength> iDisplayName;
	/**
	Access point name*/
	TBuf<KIAPNameMaxLength> iName;
	/**
	Prompt for authentication*/
	TBool iPromptForAuth;
	/**
	ETrue indicates it is created by the app*/
	TBool iSelfCreated;
	TUint32 iUID;
	/**
	Proxy address.
	This is not externalized to file*/
	TApnProxyInfo iProxyInfo;
	};
	
#endif
