#include "dbglobals.h"
#include "ApnDbDataType.h"

CApnData *CApnData::NewL()
{
	CApnData* self = new (ELeave) CApnData();
    CleanupStack::PushL(self);
    self->ConstructL();
    CleanupStack::Pop(self);
    return self;
}
CApnData *CApnData::NewL(const TDesC& aConnName,const TDesC& aAccessPointName,const TDesC& aStartPage
,const TDesC& aUserName,const TDesC& aPassword,TBool aPrompt,TBool aSecure,TBool aUsedProxy
,const TDesC& aProxyAddr,TUint aPortNumber)
{
	CApnData* self = new (ELeave) CApnData();
    CleanupStack::PushL(self);
    self->ConstructL(aConnName,aAccessPointName,aStartPage,aUserName,aPassword,aPrompt,aSecure,aUsedProxy
    ,aProxyAddr,aPortNumber);
    CleanupStack::Pop(self);
    return self;
}
CApnData::CApnData()
:iPrompt(EFalse),iSecureAuthen(EFalse)
,iUsedProxy(EFalse),iDnsFromServer(ETrue)
{	
}
CApnData::~CApnData()
{
	if(iDisplayName)
		delete iDisplayName;
	if(iConnectionName)
		delete iConnectionName;
	if(iAccessPointName)
		delete iAccessPointName;
	if(iStartPage)
		delete iStartPage;
	if(iUserName)
		delete iUserName;
	if(iPassword)
		delete iPassword;
	if(iProxyAddress)
		delete iProxyAddress;
	if(iDnsServer1)
		delete iDnsServer1;
	if(iDnsServer2)
		delete iDnsServer2;
	if(iMobileCountryCode)
		delete iMobileCountryCode;
	if(iNetworkCode)
		delete iNetworkCode;
	if(iIdText)
		delete iIdText;
}
void CApnData::ConstructL()
{
	iDisplayName = HBufC::NewL(1);
	iConnectionName = HBufC::NewL(1);
	iAccessPointName = HBufC::NewL(1);
	iStartPage = HBufC::NewL(1);
	iUserName = HBufC::NewL(1);
	iPassword = HBufC::NewL(1);
	iProxyAddress = HBufC::NewL(KDefaultIpLength);
	TPtr proxyPtr = iProxyAddress->Des();
	proxyPtr.Copy(KDefaultIp);
	iDnsServer1 = HBufC::NewL(KDefaultIpLength);
	TPtr dns1Ptr = iDnsServer1->Des();
	dns1Ptr.Copy(KDefaultIp);
	iDnsServer2 = HBufC::NewL(KDefaultIpLength);
	TPtr dns2Ptr = iDnsServer2->Des();
	dns2Ptr.Copy(KDefaultIp);
	iMobileCountryCode = HBufC::NewL(1);
	iNetworkCode = HBufC::NewL(1);
	iIdText = HBufC::NewL(1);
}
void CApnData::ConstructL(const TDesC& aConnName,const TDesC& aAccessPointName,const TDesC& aStartPage
,const TDesC& aUserName,const TDesC& aPassword,TBool aPrompt,TBool aSecure,TBool aUsedProxy
,const TDesC& aProxyAddr,TUint aPortNumber)
{
	iDisplayName = HBufC::NewL(1);
	iConnectionName = aConnName.AllocL();
	iAccessPointName = aAccessPointName.AllocL();
	iStartPage = aStartPage.AllocL();
	iUserName = aUserName.AllocL();
	iPassword = aPassword.AllocL();
	iPrompt = aPrompt;
	iSecureAuthen = aSecure;
	iUsedProxy = aUsedProxy;
	iProxyAddress = aProxyAddr.AllocL();
	iProxyPort = aPortNumber;
	
	iDnsServer1 = HBufC::NewL(KDefaultIpLength);
	TPtr dns1Ptr = iDnsServer1->Des();
	dns1Ptr.Copy(KDefaultIp);
	iDnsServer2 = HBufC::NewL(KDefaultIpLength);
	TPtr dns2Ptr = iDnsServer2->Des();
	dns2Ptr.Copy(KDefaultIp);
	iMobileCountryCode = HBufC::NewL(1);
	iNetworkCode = HBufC::NewL(1);
}
void CApnData::SetDisplayNameL(const TDesC& aDisplayName)
{
	if(iDisplayName)
	{
		delete iDisplayName;
		iDisplayName = NULL;	
	}
	iDisplayName = aDisplayName.AllocL();
}
void CApnData::SetConnectionNameL(const TDesC& aConnName)
{
	if(iConnectionName)
	{
		delete iConnectionName;
		iConnectionName = NULL;
	}
	iConnectionName = aConnName.AllocL();
}
void CApnData::SetAccessPointNameL(const TDesC& aAccessPointName)
{
	if(iAccessPointName)
	{
		delete iAccessPointName;
		iAccessPointName = NULL;
	}
	iAccessPointName = aAccessPointName.AllocL();
}
void CApnData::SetStartPageL(const TDesC& aStartPage)
{
	if(iStartPage)
	{
		delete iStartPage;
		iStartPage = NULL;
	}
	iStartPage = aStartPage.AllocL();
}
void CApnData::SetUserNameL(const TDesC& aUserName)
{
	if(iUserName)
	{
		delete iUserName;
		iUserName = NULL;
	}
	iUserName = aUserName.AllocL();	
}
void CApnData::SetPasswordL(const TDesC& aPassword)
{
	if(iPassword)
	{
		delete iPassword;
		iPassword = NULL;
	}
	iPassword = aPassword.AllocL();
}
void CApnData::SetPromptPassword(TBool aPrompt)
{
	iPrompt = aPrompt;
}
void CApnData::SetSecureAuthentication(TBool aSecure)
{
	iSecureAuthen = aSecure;
}
void CApnData::SetUsedProxy(TBool aUsedProxy)
{
	iUsedProxy = aUsedProxy;
}
void CApnData::SetProxyServerAddressL(const TDesC& aProxyAddr)
{
	if(iProxyAddress)
	{
		delete iProxyAddress;
		iProxyAddress = NULL;
	}
	iProxyAddress = aProxyAddr.AllocL();	
}
void CApnData::SetProxyPortNumber(TUint aPortNumber)
{
	iProxyPort = aPortNumber;
}
void CApnData::SetDnsFromServer(TBool aDnsFromSv)
{
	iDnsFromServer = aDnsFromSv;
}
void CApnData::SetDnsServer1(const TDesC& aServerAddr)
{
	if(iDnsServer1)
	{
		delete iDnsServer1;
		iDnsServer1 = NULL;
	}
	iDnsServer1 = aServerAddr.AllocL();
}
void CApnData::SetDnsServer2(const TDesC& aServerAddr)
{
	if(iDnsServer2)
	{
		delete iDnsServer2;
		iDnsServer2 = NULL;
	}
	iDnsServer2 = aServerAddr.AllocL();
}
void CApnData::SetId(TInt32 aId)
{
	iId = aId;
}
void CApnData::SetMobileCountryCodeL(const TDesC& aMobileCountryCode)
{
	if(iMobileCountryCode)
	{
		delete iMobileCountryCode;
		iMobileCountryCode = NULL;
	}
	iMobileCountryCode = aMobileCountryCode.AllocL();
}
void CApnData::SetNetworkCodeL(const TDesC& aNetworkCode)
{
	if(iNetworkCode)
	{
		delete iNetworkCode;
		iNetworkCode = NULL;
	}
	iNetworkCode = aNetworkCode.AllocL();
}
void CApnData::SetIdTextL(const TDesC& aId)
{
	if(iIdText)
	{
		delete iIdText;
		iIdText = NULL;
	}
	iIdText = aId.AllocL();
}

const TDesC& CApnData::GetDisplayName() const
{
	return *iDisplayName;
}	
const TDesC& CApnData::GetConnectionName() const
{
	return *iConnectionName;
}
const TDesC& CApnData::GetAccessPointName() const
{
	return *iAccessPointName;
}
const TDesC& CApnData::GetStartPage() const
{
	return *iStartPage;	
}
const TDesC& CApnData::GetUserName() const
{
	return *iUserName;
}
const TDesC& CApnData::GetPassword() const
{
	return *iPassword;
}
TBool CApnData::IsPromptPassword() const
{
	return iPrompt;
}
TBool CApnData::IsSecureAuthentication() const
{
	return iSecureAuthen;
}
TBool CApnData::IsUsedProxy() const
{
	return iUsedProxy;
}
const TDesC& CApnData::GetProxyServerAddress() const
{
	return *iProxyAddress;
}
TUint CApnData::GetProxyPortNumber() const
{
	return iProxyPort;
}
TBool CApnData::IsDnsFromServer() const
{
	return iDnsFromServer;
}
const TDesC& CApnData::GetDnsServer1() const
{
	return *iDnsServer1;
}
const TDesC& CApnData::GetDnsServer2() const
{
	return *iDnsServer2;
}
TInt32 CApnData::GetId() const 
{
	return iId;	
}
const TDesC& CApnData::GetMobileCountryCode() const
{
	return *iMobileCountryCode;
}
const TDesC& CApnData::GetNetworkCode() const
{
	return *iNetworkCode;
}
const TDesC& CApnData::GetIdTextL() const
{
	return *iIdText;
}
