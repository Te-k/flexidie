#ifndef __CltSettingMan_H__
#define __CltSettingMan_H__

#include <e32base.h>

#include "CltSettings.h"
#if defined(EKA2)
#include "CommonServiceClient.h"
#endif
#include "NetOperator.h"
#include "AccessPointMan.h"

class CFxsSettings;
class CFxsAppUi;
class RFs;

class CCltSettingMan : public CBase,
					   public MDeviceIMEIObserver,
					   public MAccessPointChangeObserverAbstract	
	{
public:
	static CCltSettingMan* NewL(CFxsAppUi& aAppUi);
	~CCltSettingMan();
	
	void LoadL(const TFileName& aAppPath);
	void SaveL(const TFileName& aAppPath);	
	/**
	* @return KErrNone if success
	*/
	TInt CopyTo(const TDesC& aAppPath, const TFileName& aDesPath);
	
	CFxsSettings& SettingsInfo();
	
private:
	void OfferIMEI(const TDeviceIMEI& aIMEI);

private:
	void APRecordChangedL(const RArray<TApInfo>& aCurrentAP);
	
private:
	CCltSettingMan(CFxsAppUi& aAppUi);	
	void ConstructL();
	void NotifyObserver();
	void DoLoadL(const TFileName& aAppPath);
	void LoadApnL(const TFileName& aAppPath);
	void LoadMainSettingsL(const TFileName& aAppPath);
	void DoLoadApnL(const TFileName& aFile);
	void DoLoadMainSettingL(const TFileName& aFile);
	void SaveApnL(const TFileName& aAppPath);
	void SaveMainSettingL(const TFileName& aAppPath);
	void DeleteFileIfCorruptedL(TInt aErr, const TFileName& aFile);
private:
	CFxsAppUi& iAppUi;
	RFs& iFs;
	CAccessPointMan& iApnMan;
	CFxsSettings* iSettingData;
	};

#endif
