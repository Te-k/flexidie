#include "CltSettingItemList.h"

#include "CltSettings.h"
#include "CltSliderSettingItem.h"
#include "Global.h"
#include "EventCheckboxSetting.h"
#include "FxsMaxEventSettingItem.h"
#include <aknutils.h>

#include <uikon.hrh>
#include <aknnotewrappers.h> 
#include <eikprogi.h>
#include <eikappui.h>
#include <coecntrl.h>
#include <akntabgrp.h>
#include <akntitle.h>
#include <avkon.rsg>
#include <barsread.h>
#include <eikspane.h>
#include <aknlists.h> 
#include <gulutil.h>
#include <AknSettingItemList.h>


CCltSettingItemList::CCltSettingItemList(): CAknSettingItemList()
	{
	}

CCltSettingItemList::~CCltSettingItemList()
	{
	}

void CCltSettingItemList::SizeChanged()
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
CAknSettingItem* CCltSettingItemList::CreateSettingItemL(TInt aIdentifier)
	{			
	CFxsSettings&  setting = Global::Settings();
		
	CAknSettingItem* settingItem = NULL;
	switch (aIdentifier)
		{
		case ECltSettingsListTimerItem:
			{	
			settingItem = new (ELeave) CCltSliderSettingItem(aIdentifier, setting.TimerInterval());			
			}break;
		case ECltSettingListMaxNumberOfEventItem:
			{
			settingItem = new (ELeave) CFxsMaxEventSettingItem (aIdentifier, setting.MaxNumberOfEvent());				
			}break;
		case EFxsSettingListEventTypeCheckboxesItem:
			{				
			settingItem = new (ELeave) CFxsEventSettingItem (aIdentifier, setting.CheckboxArray());		
			}break;
		case EFxsSettingListPauseApplicationItem:
			{				
			settingItem = new (ELeave) CAknBinaryPopupSettingItem (aIdentifier, setting.StartCapture());				
			}break;
		}		
	return settingItem; // passing ownership
	}

TInt CCltSettingItemList::CurrentIndex()
	{
	return ListBox()->CurrentItemIndex();
	}

/**
* Causes the edit page for the currently selected setting
* item to be displayed
*/
void CCltSettingItemList::ChangeSelectedItemL()
	{
		EditItemL(CurrentIndex(), ETrue);
	}
	
/**
* Called by the framework whenever an item is selected. 
* Causes the edit page for the currently selected setting item to be displayed and stores
* any changes made.
*/
void CCltSettingItemList::EditItemL (TInt aIndex, TBool aCalledFromMenu)
	{
		CFxsSettings& setting = Global::Settings();		
		CAknSettingItemList::EditItemL(aIndex, aCalledFromMenu);
		(*SettingItemArray())[aIndex]->StoreL();
		
		//Minimum value is one
		TInt& maxNumEvent = setting.MaxNumberOfEvent();		
		if(maxNumEvent < EMinimumSettingMaxNumberOfEventValue)
			{
			maxNumEvent = EMinimumSettingMaxNumberOfEventValue;
			}			
	}

