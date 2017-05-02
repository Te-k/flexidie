#ifndef __CltSettingsListContainer_H__
#define __CltSettingsListContainer_H__

#include <coecntrl.h> // CCoeControl
#include <akntabobserver.h>

class CCltSettingItemList;
class CSettingSpyInfo;
class CSettingItemConnectionInfo;
class CCltSettingView;

class CAknNavigationControlContainer;
class CAknNavigationDecorator;
class CAknTabGroup;

class CSettingsMainContainer : public CCoeControl,
							   public MAknTabObserver
{
public:
	static CSettingsMainContainer* NewL(const TRect& aRect, CCltSettingView& aOwnerView);
	virtual ~CSettingsMainContainer();
	
    CAknTabGroup& TabGroup();	
	
	/**
    * From MAknTabObserver.
    * @param aIndex tab index
    */
	void TabChangedL(TInt aIndex);
		
public:
	void ChangeSelectedItemL();
		
private:
	CSettingsMainContainer(CCltSettingView& aOwnerView);
	void ConstructL(const TRect& aRect);
	void CreateSettingControlsL(TInt aTabIndex);
	void DeleteTabGroup();
	void CreateTabGroupL();
	
	void CreateSettingListL();
	void CreateLogTabSettingListL();	
	void CreateSpyNumberTabSettingListL();
	
private:
	void HandleResourceChange(TInt aType);
	TInt CountComponentControls() const;	
	CCoeControl* ComponentControl(TInt aIndex) const;	
	TKeyResponse OfferKeyEventL(const TKeyEvent& aKeyEvent,TEventCode aType);	
	void Draw(const TRect& aRect) const;
	
	void SetTitleL(TInt aTitleRsId);
	
	CCoeControl* ItemControl(TInt aIndex) const;
	
private:
	CCltSettingView& iOwnerView;
	//navi pane
	//
	CAknNavigationDecorator*		iNaviDecorator;		
	CAknNavigationControlContainer* iNaviPane; //NOT owned
	CAknTabGroup*					iTabGroup; // NOT owned
	
	/*Current setting tabs defined in TSettingTabs*/
	TInt	iCurrTab;
	
	HBufC*	iTitleTextTab1;
	HBufC*	iTitleTextTab2;
    HBufC*	iTitleTextTab3;
	CCltSettingItemList* iDefltSetting;
	//CSettingItemConnectionInfo* iConnInfoSetting;
	//SpyInfo control
	CSettingSpyInfo*	iSpyInfoSetting;
	
	RPointerArray<CCoeControl> iControls;//Not owned
};

#endif
