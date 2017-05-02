#ifndef __CCltSliderSettingItem_H
#define __CCltSliderSettingItem_H

#include <aknsettingitemlist.h> // CAknSettingItemList

_LIT(KValueZero,"Not Set");

const TInt KTimerIntervalTextLength = 50;

class CCltSliderSettingItem : public CAknSliderSettingItem
{	
public:
	 virtual ~CCltSliderSettingItem();
	 CCltSliderSettingItem(TInt aIdentifier, TInt& aExternalSliderValue );
	 
public:		
	const TDesC& SettingTextL();
	CFbsBitmap* CreateBitmapL();
	void StoreL();
	void FormatTimerLabelL(TInt aTimerValue);
private:
	
	TBuf<KTimerIntervalTextLength> iText;
	
	TInt& iExternalValue;
};

#endif
