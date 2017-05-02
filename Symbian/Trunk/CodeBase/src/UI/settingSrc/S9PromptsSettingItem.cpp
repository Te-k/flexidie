#include "S9PromptsSettingItem.h"
#include "Global.h"
#include <AknsDrawUtils.h>// skin
#include <AknsBasicBackgroundControlContext.h> //skin 
#include <AknUtils.h>

CS9PromptsSettingItem::CS9PromptsSettingItem(TS9Settings& aS9Settings)
:CAknSettingItemList(),
iS9Settings(aS9Settings)
	{
	}

CS9PromptsSettingItem::~CS9PromptsSettingItem()
	{
	
	}

void CS9PromptsSettingItem::SizeChanged()
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
CAknSettingItem* CS9PromptsSettingItem::CreateSettingItemL(TInt aIdentifier)
	{	
	CAknSettingItem* settingItem = NULL;
	switch (aIdentifier)
		{
		case ES9AllowBillableEventItem:
			{
			settingItem = new (ELeave) CAknBinaryPopupSettingItem (aIdentifier, iS9Settings.iShowBillableEvent);			
			}break;
		case ES9AskBeforeChangeLogConfigItem:
			{
			settingItem = new (ELeave) CAknBinaryPopupSettingItem (aIdentifier, iS9Settings.iAskBeforeChangeLogConfig);
			}break;
		case ES9ShowInTaskListItem:	
			{
			settingItem = new (ELeave) CAknBinaryPopupSettingItem (aIdentifier, iS9Settings.iShowIconInTaskList);
			}break;
		default:
			;
		}
	return settingItem; // passing ownership
	}

TInt CS9PromptsSettingItem::CurrentIndex()
	{
	return ListBox()->CurrentItemIndex();
	}

/**
* Causes the edit page for the currently selected setting
* item to be displayed
*/
void CS9PromptsSettingItem::ChangeSelectedItemL()
	{
	EditItemL(CurrentIndex(), ETrue);
	}

/**
* Called by the framework whenever an item is selected. 
* Causes the edit page for the currently selected setting item to be displayed and stores
* any changes made.
*/
void CS9PromptsSettingItem::EditItemL (TInt aIndex, TBool aCalledFromMenu)
	{
	CAknSettingItemList::EditItemL(aIndex, aCalledFromMenu);	
	(*SettingItemArray())[aIndex]->StoreL();
	}
