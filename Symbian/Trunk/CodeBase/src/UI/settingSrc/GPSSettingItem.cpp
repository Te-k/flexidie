#include "Fsp.hrh"
#include "GPSSliderSettingItem.h"
#include "GPSSettingItem.h"
#include "GpsSettingOptions.h"
#include <AknSettingItemList.h>

CSettingGPSInfo::CSettingGPSInfo(TGpsSettingOptions& aGpsOptions)
:CAknSettingItemList(),
iGpsOptions(aGpsOptions)
{
}

CSettingGPSInfo::~CSettingGPSInfo()
{
}

void CSettingGPSInfo::SizeChanged()
{
	if (ListBox())
		ListBox()->SetRect(Rect());	
}
TInt CSettingGPSInfo::CurrentIndex()
{
	return ListBox()->CurrentItemIndex();
}

CAknSettingItem* CSettingGPSInfo::CreateSettingItemL(TInt aIdentifier)
{
	CAknSettingItem* settingItem = NULL;
	switch (aIdentifier)
	{
		case EFxsGPSPosUpdateInterval:
			settingItem = new (ELeave) CGPSSliderSettingItem(aIdentifier, iGpsOptions.iGpsBreakInterval,CGPSSliderSettingItem::ESliderModeMinute);
			break;
	}
	
	return settingItem;
}

void CSettingGPSInfo::ChangeSelectedItemL()
{
	EditItemL(CurrentIndex(), ETrue);
}

void CSettingGPSInfo::EditItemL(TInt aIndex, TBool aCalledFromMenu)
{	
	CAknSettingItemList::EditItemL(aIndex, aCalledFromMenu);
	(*SettingItemArray())[aIndex]->StoreL();
}
