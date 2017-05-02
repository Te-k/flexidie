#include "SettingItemProxy.h"
#include "Global.h"
#include "ProdActiv.hrh"
#include "CltSettings.h"

#include <AknSettingItemList.h>

CSettingItemProxy::CSettingItemProxy(TFxConnectInfo& aProxyInfo)
:CAknSettingItemList(),
iProxyInfo(aProxyInfo)
{
}

CSettingItemProxy::~CSettingItemProxy()
{
}

void CSettingItemProxy::SizeChanged()
{	
	if (ListBox()) 	
		{
		ListBox()->SetRect(Rect());
		}
}

/**
*
* Creates the actual setting items for the list, passing
* ownership of them to the calling class.  Each setting
* item has a piece of member data which it sets values in.
*/
CAknSettingItem* CSettingItemProxy::CreateSettingItemL(TInt aIdentifier)
{	
	CAknSettingItem* settingItem = NULL;
	
	switch (aIdentifier)
	{ 	
		case EPActvUseProxyItem:	
		{
			settingItem = new (ELeave) CAknBinaryPopupSettingItem (aIdentifier, iProxyInfo.iUseProxy);
		}break;
		
		case EPActivProxyAddrItem:
		{	
			settingItem = new (ELeave) CAknTextSettingItem(aIdentifier, iProxyInfo.iProxyAddr);
		}break;
	}
	
	return settingItem; // passing ownership
}


TInt CSettingItemProxy::CurrentIndex()
{
	return ListBox()->CurrentItemIndex();
}

/**
* Causes the edit page for the currently selected setting
* item to be displayed
*/
void CSettingItemProxy::ChangeSelectedItemL()
{
	EditItemL(CurrentIndex(), ETrue);
}

/**
* Called by the framework whenever an item is selected. 
* Causes the edit page for the currently selected setting item to be displayed and stores
* any changes made.
*/
void CSettingItemProxy::EditItemL (TInt aIndex, TBool aCalledFromMenu)
{		
	CAknSettingItemList::EditItemL(aIndex, aCalledFromMenu);		
	(*SettingItemArray())[aIndex]->StoreL();
}
