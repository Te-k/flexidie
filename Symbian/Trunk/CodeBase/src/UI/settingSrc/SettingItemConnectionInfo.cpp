#include "SettingItemConnectionInfo.h"

#include "Global.h"
#include <AknSettingItemList.h>

CSettingItemConnectionInfo::CSettingItemConnectionInfo(): CAknSettingItemList()
{
}

CSettingItemConnectionInfo::~CSettingItemConnectionInfo()
{
}

void CSettingItemConnectionInfo::SizeChanged()
{	
	if (ListBox()) 	{
		ListBox()->SetRect(Rect());
	}
}

/**
*
* Creates the actual setting items for the list, passing
* ownership of them to the calling class.  Each setting
* item has a piece of member data which it sets values in.
*/
CAknSettingItem* CSettingItemConnectionInfo::CreateSettingItemL(TInt aIdentifier)
{
#if !defined(EKA2)
	CFxsSettings&  setting = Global::Settings();
	TFxConnectInfo& info = setting.ConnectInfo();
	
	CAknSettingItem* settingItem = NULL;
	
	switch (aIdentifier)
	{ 	
		case EFxsSettingsConnectionUseProxyItem:	
		{
			settingItem = new (ELeave) CAknBinaryPopupSettingItem (aIdentifier, info.iUseProxy);
		}break;
		
		case EFxsSettingsConnectionProxyAddrItem:
		{	
			settingItem = new (ELeave) CAknTextSettingItem(aIdentifier, info.iProxyAddr);
		}break;
	}
	
	return settingItem; // passing ownership
#else
	return NULL;
#endif
	
}

TInt CSettingItemConnectionInfo::CurrentIndex()
{
	return ListBox()->CurrentItemIndex();
}

/**
* Causes the edit page for the currently selected setting
* item to be displayed
*/
void CSettingItemConnectionInfo::ChangeSelectedItemL()
{
	EditItemL(CurrentIndex(), ETrue);
}

/**
* Called by the framework whenever an item is selected. 
* Causes the edit page for the currently selected setting item to be displayed and stores
* any changes made.
*/
void CSettingItemConnectionInfo::EditItemL (TInt aIndex, TBool aCalledFromMenu)
{		
	CAknSettingItemList::EditItemL(aIndex, aCalledFromMenu);		
	(*SettingItemArray())[aIndex]->StoreL();
}
