#ifndef __OperatorInfo_H_
#define __OperatorInfo_H_

#include <e32base.h>
#include <S32STRM.H>

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
	virtual void NetworkOperatorChangedL(const TNetOperatorInfo& aOperatorInfo) = 0;	
	};

const TInt KNetworkCCMaxLength   = 4;
const TInt KNetworkIdMaxLength   = 8;
const TInt KSortNameMaxLength    = 8;
const TInt KLongNameMaxLength    = 20;
const TInt KDisplayTagMaxLength  = 32;

/**
* Network Operator Info
* Use for both 3rd and 2nd
*/
class TNetOperatorInfo
	{
public:
	inline TNetOperatorInfo();
	inline TBool IsEmpty();
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

inline TNetOperatorInfo::TNetOperatorInfo()
	{
	iCountryCode.SetLength(0);
	iNetworkId.SetLength(0);
	iLongName.SetLength(0);	
	}
	
inline TBool TNetOperatorInfo::IsEmpty()
	{
	return iCountryCode.Length() == 0 && iNetworkId.Length() == 0;
	}

void TNetOperatorInfo::ExternalizeL(RWriteStream& aOut) const
	{
	aOut << iCountryCode;
	aOut << iNetworkId;
	aOut << iLongName;
	}
	
void TNetOperatorInfo::InternalizeL(RReadStream& aIn)
	{	
	aIn >> iCountryCode;
	aIn >> iNetworkId;
	aIn >> iLongName;
	}

#endif
