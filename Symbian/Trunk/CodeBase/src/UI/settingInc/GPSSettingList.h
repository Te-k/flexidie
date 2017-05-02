#ifndef __GPS_SETTING_LIST_H__
#define __GPS_SETTING_LIST_H__

#include <aknlists.h> 

enum TFxGPSSettingItemId
{
	EFxGPSOff,
	EFxGPS10Sec,
	EFxGPS30Sec,
	EFxGPS1Min,
	EFxGPS5Min,
	EFxGPS10Min,
	EFxGPS20Min,
	EFxGPS40Min,
	EFxGPS60Min,
	EFxGPSNotAvailable
};

class TGpsSettingOptions;
class CSettingGPSInfo : public CCoeControl
{
public:
	static CSettingGPSInfo * NewL(CCoeControl *aParent,const TRect& aRect,TGpsSettingOptions& aGpsOptions);
	static CSettingGPSInfo * NewLC(CCoeControl *aParent,const TRect& aRect,TGpsSettingOptions& aGpsOptions);
	~CSettingGPSInfo();
	
	TInt CountComponentControls() const;
	CCoeControl * ComponentControl(TInt aIndex) const;
	TKeyResponse OfferKeyEventL(const TKeyEvent& aKeyEvent, TEventCode aType);
	void ChangeSelectedItemL();
private:
	CSettingGPSInfo(TGpsSettingOptions& aGpsOptions);
	void ConstructL(CCoeControl *aParent,const TRect & aRect);
	void InitComponentsL();
	void CleanupComponents();
	void SizeChanged();

	void LoadSettingItemL();
	TInt GetResourceIdFromValue();
	void AddListItemL(CDesCArrayFlat &aArray,TInt aResId);
	void GetListIdFromValue();
	void GetValueFromId();
private:
	TGpsSettingOptions& iGpsOptions;
	RPointerArray<CCoeControl> iCtrlArray;
	CAknSettingStyleListBox* iListbox;
	TFxGPSSettingItemId iGpsSettingId;	
};

#endif//	__GPS_SETTING_LIST_H__
