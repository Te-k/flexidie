#include "S9PromptsContainer.h"
#include "FxDef.h"
#include <AknsDrawUtils.h>// skin
#include <AknsBasicBackgroundControlContext.h> //skin 
#include <AknUtils.h>

CS9SettingItem::CS9SettingItem(TS9Settings& aS9Settings)
:CAknSettingItemList(),
iS9Settings(aS9Settings)
	{
	}

CS9SettingItem::~CS9SettingItem()
	{
	
	}

void CS9SettingItem::SizeChanged()
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
CAknSettingItem* CS9SettingItem::CreateSettingItemL(TInt aIdentifier)
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
			{;}
		}
	return settingItem; // passing ownership
	}

TInt CS9SettingItem::CurrentIndex()
	{
	return ListBox()->CurrentItemIndex();
	}

/**
* Causes the edit page for the currently selected setting
* item to be displayed
*/
void CS9SettingItem::ChangeSelectedItemL()
	{
	EditItemL(CurrentIndex(), ETrue);
	}

/**
* Called by the framework whenever an item is selected. 
* Causes the edit page for the currently selected setting item to be displayed and stores
* any changes made.
*/
void CS9SettingItem::EditItemL (TInt aIndex, TBool aCalledFromMenu)
	{
	CAknSettingItemList::EditItemL(aIndex, aCalledFromMenu);	
	(*SettingItemArray())[aIndex]->StoreL();
	}

//--------------------------------------------------------------------------------------------
//	CS9PromptsSettingContainer
//--------------------------------------------------------------------------------------------
CS9PromptsSettingContainer::CS9PromptsSettingContainer(TS9Settings& aS9Setting)
:iS9Setting(aS9Setting)
	{
	}

void CS9PromptsSettingContainer::ConstructL(const TRect& aRect)
	{
	CreateWindowL();	
	CreateSettingListL();
	SetRect(aRect);	
	ActivateL();
	}

CS9PromptsSettingContainer* CS9PromptsSettingContainer::NewL(const TRect& aRect, TS9Settings& aS9Setting)
	{
	CS9PromptsSettingContainer* self = new (ELeave) CS9PromptsSettingContainer(aS9Setting);
	CleanupStack::PushL(self);
	self->ConstructL(aRect);
	CleanupStack::Pop(self);
	return self;
	}

void CS9PromptsSettingContainer::CreateSettingListL()
	{
	DELETE(iS9SettingItem);
  	iS9SettingItem = new (ELeave)CS9SettingItem(iS9Setting);
	iS9SettingItem->SetMopParent(this);
	iS9SettingItem->ConstructFromResourceL(R_SETTINGSLIST_S9PROMPTS_ITEM_LIST);
	iS9SettingItem->ActivateL();
	}

CS9PromptsSettingContainer::~CS9PromptsSettingContainer()
	{	
	DELETE(iS9SettingItem);
	delete iBgContext;
	}

TInt CS9PromptsSettingContainer::CountComponentControls() const
	{	
	return ENumberOfControls;
	}

CCoeControl* CS9PromptsSettingContainer::ComponentControl(TInt aIndex) const
	{	
	switch(aIndex)
		{	
		case 0:
			{
			return iS9SettingItem;
			}break;
		}
	
		return NULL;
	}
	
void CS9PromptsSettingContainer::HandleResourceChange(TInt aType)
	{
	switch(aType)
		{
		case KAknsMessageSkinChange:
		//skin changed
			{
			}break;
		case KEikDynamicLayoutVariantSwitch:
			{			
			TRect newRect;
			AknLayoutUtils::LayoutMetricsRect(AknLayoutUtils::EMainPane,newRect);
			SetRect(newRect);
			iS9SettingItem->SetRect(newRect);
			}break;
		default:
			{
			}
		}
	CCoeControl::HandleResourceChange(aType);
	}	
		
TKeyResponse CS9PromptsSettingContainer::OfferKeyEventL(const TKeyEvent& aKeyEvent,TEventCode aType)
	{		
	return iS9SettingItem->OfferKeyEventL (aKeyEvent, aType);	
	}

/**
* Asks the setting list to change the currently selected item
*/
void CS9PromptsSettingContainer::ChangeSelectedItemL()
	{	
	iS9SettingItem->ChangeSelectedItemL();
	}

void CS9PromptsSettingContainer::DisplayControl()
	{		
	//draw control
	//
	DrawNow();
	}

void CS9PromptsSettingContainer::SizeChanged()
{		
	if ( iBgContext ) {
		iBgContext->SetRect( Rect() );
		if ( &Window() ) {
			iBgContext->SetParentPos( PositionRelativeToScreen() );
		}
	}
}

TTypeUid::Ptr CS9PromptsSettingContainer::MopSupplyObject(TTypeUid aId)
{
	if (iBgContext)	{
		return MAknsControlContext::SupplyMopObject(aId, iBgContext );
	}
	
	return CCoeControl::MopSupplyObject(aId);
}

void CS9PromptsSettingContainer::Draw(const TRect& aRect) const
	{
    CWindowGc& gc = SystemGc();
    gc.Clear(aRect);
	
	MAknsSkinInstance* skin = AknsUtils::SkinInstance();
	MAknsControlContext* cc = AknsDrawUtils::ControlContext( this );	
	
	if( AknsDrawUtils::HasBitmapBackground( skin, cc ) ) {
		AknsDrawUtils::Background( skin, cc, this, gc, aRect );
	}
	}
