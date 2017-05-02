#ifndef __OperatorInfo_H_
#define __OperatorInfo_H_

#include <e32base.h>


class TNetOperatorInfo;

/**
A class that wants to get current network operator info must implement this interface*/
class MNetOperatorInfoListener
	{
public:
	/**
	* To be informed the current network operator info
	*/
	virtual void CurrentOperatorInfo(const TNetOperatorInfo& aOperatorInfo) = 0;
	};

/**
Network Operator Change Observer*/
class MNetOperatorChangeObserver
	{
public:
	/**
	* To be informed when network operator changed
	*/
	virtual void NetworkOperatorChanged(const TNetOperatorInfo& aOperatorInfo) = 0;	
	};

const TInt KNetworkCCMaxLength   = 4;
const TInt KNetworkIdMaxLength   = 8;
const TInt KSortNameMaxLength    = 8;
const TInt KLongNameMaxLength    = 20;
const TInt KDisplayTagMaxLength  = 32;

class RWriteStream;
class RReadStream;

/**
* Network Operator Info
* Use for both 3rd and 2nd
*/
class TNetOperatorInfo
	{
public:
	TNetOperatorInfo();
	TBool IsEmpty();
public:
	void ExternalizeL(RWriteStream& aOut) const;
	void InternalizeL(RReadStream& aIn);
public:
	/**
	The MCC of the network.
	*/
	TBuf<KNetworkCCMaxLength> 	iCountryCode;
	/**
	The network identity (NID in CDMA and MNC in GSM).
	*/
	TBuf<KNetworkIdMaxLength> 	iNetworkId;
	TBuf<KLongNameMaxLength> 	iLongName;	
	};

#endif
