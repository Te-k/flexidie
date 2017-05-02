#include "SecuritySettingItem.h"
#include "CltSettings.h"
#include <AknSettingItemList.h>

CSettingSecurityInfo::CSettingSecurityInfo(TMiscellaneousSetting& aMiscSetting)
:CAknSettingItemList(),
iMiscSetting(aMiscSetting)
{
}

CSettingSecurityInfo::~CSettingSecurityInfo()
{
}

void CSettingSecurityInfo::SizeChanged()
{
	if (ListBox())
		ListBox()->SetRect(Rect());	
}

TInt CSettingSecurityInfo::CurrentIndex()
{
	return ListBox()->CurrentItemIndex();
}

CAknSettingItem* CSettingSecurityInfo::CreateSettingItemL(TInt aIdentifier)
{
	CAknSettingItem* settingItem = new (ELeave) CAknBinaryPopupSettingItem (aIdentifier, iMiscSetting.iKillFSecureApp);
	return settingItem;	
}

void CSettingSecurityInfo::ChangeSelectedItemL()
{
	EditItemL(CurrentIndex(), ETrue);
}

void CSettingSecurityInfo::EditItemL (TInt aIndex, TBool aCalledFromMenu)
{	
	CAknSettingItemList::EditItemL(aIndex, aCalledFromMenu);
	(*SettingItemArray())[aIndex]->StoreL();
}
