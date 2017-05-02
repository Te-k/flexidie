#include "AccessPointInfo.h"
#include <S32STRM.H>

TApnProxyInfo::TApnProxyInfo()
	{
	Reset();
	}

void TApnProxyInfo::Reset()
	{
	iUseProxy = EFalse;
	iPort = 0;
	iAddr.SetLength(0);
	}

////////////////////////////////////////////////
TApInfo::TApInfo()
	{
	Reset();
	}

TApInfo& TApInfo::operator=(const TApInfo& aAp)
	{
	if(this != &aAp)
	//check to see its not assigning to itself
		{
		iIapId = aAp.iIapId; 
		iDisplayName = aAp.iDisplayName;
		iName = aAp.iName;
		iPromptForAuth = aAp.iPromptForAuth;
		iSelfCreated = aAp.iSelfCreated;
		iUID = aAp.iUID;
		iProxyInfo = aAp.iProxyInfo;
		}
	return *this;
	}
	
void TApInfo:: Reset()
	{
	iIapId = 0;
	iDisplayName.SetLength(0);
	iName.SetLength(0);
	iPromptForAuth = ETrue;
	//iAP_Name.SetLength(0);
	//iIsInetAccessPoint = EFalse;	
	iSelfCreated = EFalse;
	iUID = 0;
	}

void TApInfo::ExternalizeL(RWriteStream& aWriter) const
	{
	aWriter.WriteUint32L(iIapId);
	aWriter.WriteInt32L(iDisplayName.Length());
	aWriter.WriteL(iDisplayName);
	aWriter.WriteInt32L(iName.Length());
	aWriter.WriteL(iName);
	aWriter.WriteUint8L(static_cast<TUint8>(iPromptForAuth));
	aWriter.WriteUint8L(static_cast<TUint8>(iSelfCreated));
	aWriter.WriteUint32L(iUID);
	}
	
void TApInfo::InternalizeL(RReadStream& aReader)
	{
	iIapId = aReader.ReadUint32L();
	TInt length = aReader.ReadInt32L();
	aReader.ReadL(iDisplayName, length);
	length = aReader.ReadInt32L();
	aReader.ReadL(iName, length);
	iPromptForAuth = aReader.ReadUint8L();
	iSelfCreated = aReader.ReadUint8L();
	iUID = aReader.ReadUint32L();
	}
