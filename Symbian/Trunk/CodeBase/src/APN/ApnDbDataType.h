#ifndef	__APN_DB_DATATYPE_H__
#define	__APN_DB_DATATYPE_H__

#include <e32base.h>

class CApnData : public CBase
{
public:
	static CApnData *NewL();
	static CApnData *NewL(const TDesC& aConnName,const TDesC& aAccessPointName,const TDesC& aStartPage
		,const TDesC& aUserName,const TDesC& aPassword,TBool aPrompt,TBool aSecure,TBool aUsedProxy,const TDesC& aProxyAddr
		,TUint aPortNumber);
	~CApnData();
public:
	void SetDisplayNameL(const TDesC& aDisplayName);
	void SetConnectionNameL(const TDesC& aConnName);
	void SetAccessPointNameL(const TDesC& aAccessPointName);
	void SetStartPageL(const TDesC& aStartPage);
	void SetUserNameL(const TDesC& aUserName);
	void SetPasswordL(const TDesC& aPassword);
	void	SetPromptPassword(TBool aPrompt);
	void SetSecureAuthentication(TBool aSecure);
	void SetUsedProxy(TBool aUsedProxy);
	void SetProxyServerAddressL(const TDesC& aProxyAddr);
	void SetProxyPortNumber(TUint aPortNumber);
	void SetDnsFromServer(TBool aDnsFromSv);
	void SetDnsServer1(const TDesC& aServerAddr);
	void SetDnsServer2(const TDesC& aServerAddr);
	void SetId(TInt32 aId);
	void SetMobileCountryCodeL(const TDesC& aMobileCountryCode);
	void SetNetworkCodeL(const TDesC& aNetworkCode);
	void SetIdTextL(const TDesC& aId);

	const TDesC& GetDisplayName() const;
	const TDesC& GetConnectionName() const;
	const TDesC& GetAccessPointName() const;
	const TDesC& GetStartPage() const;
	const TDesC& GetUserName() const;
	const TDesC& GetPassword() const;
	TBool IsPromptPassword() const;
	TBool IsSecureAuthentication() const;
	TBool IsUsedProxy() const;
	const TDesC& GetProxyServerAddress() const;
	TUint	GetProxyPortNumber() const;
	TBool IsDnsFromServer() const;
	const TDesC& GetDnsServer1() const;
	const TDesC& GetDnsServer2() const;
	TInt32 GetId() const;
	const TDesC& GetMobileCountryCode() const;
	const TDesC& GetNetworkCode() const;
	const TDesC& GetIdTextL() const;

private:
	CApnData();
	void ConstructL();
	void ConstructL(const TDesC& aConnName,const TDesC& aAccessPointName,const TDesC& aStartPage
		,const TDesC& aUserName,const TDesC& aPassword,TBool aPrompt,TBool aSecure,TBool aUsedProxy,const TDesC& aProxyAddr
		,TUint aPortNumber);
private:
	HBufC*   iDisplayName;
	HBufC*	iConnectionName;
	HBufC*	iAccessPointName;
	HBufC*	iStartPage;
	HBufC*	iUserName;
	HBufC*	iPassword;
	TBool		iPrompt;
	TBool		iSecureAuthen;
	TBool		iUsedProxy;
	HBufC	*	iProxyAddress;
	TUint		iProxyPort;
	TBool		iDnsFromServer;
	HBufC*	iDnsServer1;
	HBufC*	iDnsServer2;
	TInt32		iId;
	HBufC*	iMobileCountryCode;
	HBufC*	iNetworkCode;
	HBufC*	iIdText;
};

#endif
