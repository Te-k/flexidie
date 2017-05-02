#ifndef __CGPSSliderSettingItem_H
#define __CGPSSliderSettingItem_H

#include <aknsettingitemlist.h> // CAknSettingItemList

_LIT(KGPSValueZero,"Not Set");

const TInt KGPSTimerIntervalTextLength = 50;

class CGPSSliderSettingItem : public CAknSliderSettingItem
{	
public:
	enum TGPSSliderMode
	{
		ESliderModeMinute,
		ESliderModeSecond
	};
public:
	 virtual ~CGPSSliderSettingItem();
	 CGPSSliderSettingItem(TInt aIdentifier, TInt& aExternalSliderValue,TGPSSliderMode aMode);
	 
public:		
	const TDesC& SettingTextL();
	CFbsBitmap* CreateBitmapL();
	void StoreL();
	void FormatTimerLabelL(TInt aTimerValue);
private:
	
	TBuf<KGPSTimerIntervalTextLength> iText;
	
	TInt& iExternalValue;

	TGPSSliderMode iMode;
};

#endif
