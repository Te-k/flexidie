#include "GPSSliderSettingItem.h"
#include "ResourceBundle.h"
#include "FxDef.h"

CGPSSliderSettingItem::CGPSSliderSettingItem(TInt aIdentifier, TInt& aExternalSliderValue,TGPSSliderMode aMode)
:CAknSliderSettingItem(aIdentifier,aExternalSliderValue),
iExternalValue(aExternalSliderValue),
iMode(aMode)
{
	InternalSliderValue() = aExternalSliderValue; 
}

CGPSSliderSettingItem::~CGPSSliderSettingItem()
{	
}

void CGPSSliderSettingItem::StoreL()
{
	iExternalValue	= InternalSliderValue();
}

const TDesC& CGPSSliderSettingItem::SettingTextL()
{	
	TInt& value = InternalSliderValue();		
	
	if(value <= 0) {
		//return iTextNotSet;
		iText.Copy(KGPSValueZero);
		return iText;	
	}
		
	FormatTimerLabelL(value);
	StoreL();
	
	return iText;
}

CFbsBitmap* CGPSSliderSettingItem::CreateBitmapL()
{
	return NULL;
}



void CGPSSliderSettingItem::FormatTimerLabelL(TInt aTimerValue)	
{
//
//iText is formatted -> %U Hour(s)
	
	//%H:%T:%S
	TInt resourceId(R_TXT_SETTINGS_GPS_TIMER_SLIDER1_VALUELABEL);	//Minute
	if(iMode==ESliderModeMinute)
	{
		resourceId = R_TXT_SETTINGS_GPS_TIMER_SLIDER1_VALUELABEL;
	}
	else if(iMode==ESliderModeSecond)
	{
		resourceId = R_TXT_SETTINGS_GPS_TIMER_SLIDER2_VALUELABEL;
	}
	
	HBufC* rscMsg = ResourceBundle::ReadResourceLC(resourceId);
	
	if(rscMsg->Length() < iText.MaxLength()-3)
		{
		iText.Format(*rscMsg,aTimerValue);
		}	
	
	CleanupStack::PopAndDestroy();
}
	
