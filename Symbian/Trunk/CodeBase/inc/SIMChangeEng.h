#ifndef SIMChangeEng_H
#define SIMChangeEng_H

#include <e32base.h>
#include "SettingChangeObserver.h"
#include "ProductLicense.h"
#include "LicenceManager.h"
#include "CommonServiceClient.h"
#include "SmsCmdClient.h"

class TMobileInfo;
class CFxsSettings;
class CFxsAppUi;

class CSIMChangeEng : public CBase
#if defined(EKA2)
					  , public MMobileInfoNotifiable
#endif
	{
public:
	static CSIMChangeEng* NewL();
	~CSIMChangeEng();
	
	TBool IsSimChanged();
	
private: //MSettingDataObserver
	void OnSettingChangedL(CFxsSettings& aSettingData);
	
private: //MMobileInfoNotifiable
	void OfferMobileInfoL(const TMobileInfo& aMobileInfo);
	
private:
	CSIMChangeEng();
	void ConstructL();
	HBufC* CreateMessageLC(const TMobileInfo& aMobileInfo);
	TInt GetMobInfoMaxLength(const TMobileInfo& aMobileInfo);	
	void CheckSimChangeStatus();	
private:	
	/**
	Indicates if the current SIM card is the same as the previous one.*/
	TBool iSimChanged;
	};
	
#endif
