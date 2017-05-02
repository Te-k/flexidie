#include "CltSliderSettingItem.h"
#include "RscHelper.h"
#include "Global.h"

CCltSliderSettingItem::CCltSliderSettingItem(TInt aIdentifier, TInt& aExternalSliderValue)
:CAknSliderSettingItem(aIdentifier,aExternalSliderValue),
iExternalValue(aExternalSliderValue)
{
	InternalSliderValue() = aExternalSliderValue; 
}

CCltSliderSettingItem::~CCltSliderSettingItem()
{	
}

void CCltSliderSettingItem::StoreL()
{
	iExternalValue	= InternalSliderValue();
}

const TDesC& CCltSliderSettingItem::SettingTextL()
{	
	TInt& value = InternalSliderValue();		
	
	if(value <= 0) {
		//return iTextNotSet;
		iText.Copy(KValueZero);
		return iText;	
	}
		
	FormatTimerLabelL(value);
	StoreL();
	
	return iText;
}

CFbsBitmap* CCltSliderSettingItem::CreateBitmapL()
{
	return NULL;
}



void CCltSliderSettingItem::FormatTimerLabelL(TInt aTimerValue)	
{
//
//iText is formatted -> %U Hour(s)
	
	//%H:%T:%S
	HBufC* rscMsg = RscHelper::ReadResourceLC(R_TXT_SETTINGS_TIMER_SLIDER_VALUELABEL);
	
	if(rscMsg->Length() < iText.MaxLength()-3)
		{
		iText.Format(*rscMsg,aTimerValue);
		}	
	
	CleanupStack::PopAndDestroy();
}
	
