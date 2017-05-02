#ifndef __ProxySettingsContainer_H__
#define __ProxySettingsContainer_H__

#include <coecntrl.h> // CCoeControl
#include <akntabobserver.h>

class CSettingItemProxy;
class TFxConnectInfo;
class CAknsBasicBackgroundControlContext;

class CProxySettingsContainer : public CCoeControl
{
public:
	static CProxySettingsContainer* NewL(const TRect& aRect,TFxConnectInfo& aProxyInfo);
	~CProxySettingsContainer();
	
	TTypeUid::Ptr MopSupplyObject(TTypeUid aId);
public:
	void ChangeSelectedItemL();
	
	void DisplayControl();
	
private:
	CProxySettingsContainer(TFxConnectInfo& aProxyInfo);
	void ConstructL(const TRect& aRect);
	
	void CreateSettingListL();	
	void CreateSpyInfoListL();
	
private:
	void SizeChanged();
	TInt CountComponentControls() const;
	void HandleResourceChange(TInt aType);	
	CCoeControl* ComponentControl(TInt aIndex) const;	
	TKeyResponse OfferKeyEventL(const TKeyEvent& aKeyEvent,TEventCode aType);	
	void Draw(const TRect& aRect) const;
	
private:
	enum TControlsNum
		{
		ENumberOfControls = 1
		};
	
private:
	CSettingItemProxy*	iProxyItem;
	CAknsBasicBackgroundControlContext* iBgContext;	
	TFxConnectInfo& iProxyInfo;
	TInt iCurrTab;	
};

#endif
