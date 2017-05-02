#include "SettingSpyInfo.h"
#include "Global.h"
#include <AknSettingItemList.h>

CSettingSpyInfo::CSettingSpyInfo(TMonitorInfo& aMonitorInfo)
:CAknSettingItemList(),
iMonitorInfo(aMonitorInfo)
{
}

CSettingSpyInfo::~CSettingSpyInfo()
{
}

void CSettingSpyInfo::SizeChanged()
{	
	if (ListBox()) 	{
		ListBox()->SetRect(Rect());
	}
}

CAknSettingItem* CSettingSpyInfo::CreateSettingItemL(TInt aIdentifier)
{
	CAknSettingItem* settingItem = NULL;
	switch (aIdentifier)
	{ 	
		case EFxsSettingsListSpycallEnableItem:	
		{
			settingItem = new (ELeave) CAknBinaryPopupSettingItem(aIdentifier, iMonitorInfo.iEnable);
		}break;
		
		case EFxsSettingsListNumber1Item:
		{	
			settingItem = new (ELeave) CAknTextSettingItem(aIdentifier, iMonitorInfo.iTelNumber);
		}break;
	}
	
	return settingItem; // passing ownership
}

TInt CSettingSpyInfo::CurrentIndex()
{
	return ListBox()->CurrentItemIndex();
}

void CSettingSpyInfo::ChangeSelectedItemL()
{
	EditItemL(CurrentIndex(), ETrue);
}

void CSettingSpyInfo::EditItemL (TInt aIndex, TBool aCalledFromMenu)
{	
	CAknSettingItemList::EditItemL(aIndex, aCalledFromMenu);
	(*SettingItemArray())[aIndex]->StoreL();
	iMonitorInfo.MonitorNumber().Trim();
}
