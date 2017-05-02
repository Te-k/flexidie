#include "CltSettingsListContainer.h"

#include <aknnavi.h>
#include <akntabgrp.h>
#include <aknnavide.h>
#include <akntitle.h>
#include <EIKSPANE.H>
#include <AknView.h>
#include <aknnavi.h>
#include <akntabgrp.h>
#include <aknnavide.h>
#include <akntitle.h>
#include <eikmenup.h>			// CEikMenuPane

#include "Fxdef.h"
#include INCLUDE_RS_RSG 
#include "CltSettings.h"
#include "CltSettingItemList.h"
#include "FxsSettingPredefinedNumber.h"
#include "CltSettingView.h"
#include "ResourceBundle.h"
#include "SettingItemConnectionInfo.h"

CSettingsMainContainer::CSettingsMainContainer(CCltSettingView& aOwnerView)
:iOwnerView(aOwnerView)
{
}

CSettingsMainContainer::~CSettingsMainContainer()
{	
	iControls.Close();
	delete iDefltSetting;
	delete iConnInfoSetting;
	delete iTitleTextTab1;
	delete iTitleTextTab2;
	delete iTitleTextTab3;
	DeleteTabGroup();	
}

void CSettingsMainContainer::DeleteTabGroup()
{	
	if(iNaviPane && iNaviDecorator) {
		iNaviPane->Pop(iNaviDecorator);
		DELETE(iNaviDecorator);
		
		iNaviPane = NULL; // NOT owned
		iTabGroup = NULL; // NOT owned
	}	
}

CSettingsMainContainer* CSettingsMainContainer::NewL(const TRect& aRect,CCltSettingView& aOwnerView)
{	
	CSettingsMainContainer* self = new (ELeave) CSettingsMainContainer(aOwnerView);
	CleanupStack::PushL(self);
	self->ConstructL(aRect);
	CleanupStack::Pop(self);
	return self;
}

void CSettingsMainContainer::ConstructL(const TRect& aRect)
{
	CreateWindowL();
	CreateTabGroupL();
	CreateSettingControlsL(0);		
	SetRect(aRect);	
	ActivateL();
}

//
void CSettingsMainContainer::CreateSettingControlsL(TInt aTabIndex)
	{
	iControls.Reset();
	
#ifdef FXS_PRO_BUILD
	//Tab1
	if(aTabIndex == 0) //tab 1
		{
		iDefltSetting = new (ELeave)CCltSettingItemList ();	
		iDefltSetting->SetMopParent(this);
	    iDefltSetting->ConstructFromResourceL(R_SETTINGSLIST_SETTING_ITEM_LIST);
		iDefltSetting->ActivateL();
		
		iControls.Append(iDefltSetting);
		}
	else if(aTabIndex == 1) //tab 2
		{
		DELETE(iSpyInfoSetting);
	  	iSpyInfoSetting = new (ELeave)CSettingSpyInfo();
		iSpyInfoSetting->SetMopParent(this);
		iSpyInfoSetting->ConstructFromResourceL(R_SETTINGSLIST_PREDEFINED_NUMBERS_ITEM_LIST);
		iSpyInfoSetting->ActivateL();
		
		iControls.Append(iSpyInfoSetting);		
		}
	else if(aTabIndex == 2) //tab 3{
		{		
			DELETE(iConnInfoSetting);
			iConnInfoSetting = new (ELeave)CSettingItemConnectionInfo();
			iConnInfoSetting->SetMopParent(this);
			iConnInfoSetting->ConstructFromResourceL(R_SETTINGSLIST_CONNECTION_INFO_ITEM_LIST);
			iConnInfoSetting->ActivateL();
			
			iControls.Append(iConnInfoSetting);  //Tab1			
		}
	
	//Tab2
	
#elif defined(FXS_LIGHT_BUILD) //FlexiSPY LIGHT
	
	if(aTabIndex == 0) //tab 1
		{
		DELETE(iDefltSetting);
		iDefltSetting = new (ELeave)CCltSettingItemList ();
		iDefltSetting->SetMopParent(this);
	    iDefltSetting->ConstructFromResourceL(R_SETTINGSLIST_SETTING_ITEM_LIST);
	    iControls.Append(iDefltSetting);  //Tab1
	    
		iDefltSetting->ActivateL();		
		}
		
	if(aTabIndex == 1) //tab 2
		{
		DELETE(iConnInfoSetting);
		iConnInfoSetting = new (ELeave)CSettingItemConnectionInfo();
		iConnInfoSetting->SetMopParent(this);
		iConnInfoSetting->ConstructFromResourceL(R_SETTINGSLIST_CONNECTION_INFO_ITEM_LIST);
		iConnInfoSetting->ActivateL();
		
		iControls.Append(iConnInfoSetting);  //Tab1				
		}	
#endif		
	}

void CSettingsMainContainer::CreateTabGroupL()
{	
	TUid naviPaneUid;
	naviPaneUid.iUid = EEikStatusPaneUidNavi;
	
	CEikStatusPane* statusPane = iOwnerView.StatusPane();
	CEikStatusPaneBase::TPaneCapabilities subPane = statusPane->PaneCapabilities(naviPaneUid);
	
     // if we can access the navigation pane
	if (subPane.IsPresent() && subPane.IsAppOwned()) {
		
		iNaviPane =	(CAknNavigationControlContainer *) statusPane->ControlL(naviPaneUid);
		
        DELETE(iNaviDecorator);
		// ownership is transferred to us here
		iNaviDecorator = iNaviPane->CreateTabGroupL();
		
		// ownership not transferred
		iTabGroup = (CAknTabGroup*)iNaviDecorator->DecoratedControl();
    	
		iTabGroup->SetObserver(this);
   	    TInt tabId(0);
	   	
#ifdef FXS_LIGHT_BUILD //Fxs LIGHT	
			iTitleTextTab1 = ResourceBundle::ReadResourceL(R_TXT_TITLE_TAB_LOG);			
			iTitleTextTab2 = ResourceBundle::ReadResourceL(R_TXT_TITLE_TAB_PROXY);			
			iTabGroup->SetTabFixedWidthL(KTabWidthWithTwoTabs);
			iTabGroup->AddTabL(tabId++, *iTitleTextTab1);
			iTabGroup->AddTabL(tabId++, *iTitleTextTab2);
			iTabGroup->SetActiveTabByIndex(0);
				
#elif defined(FXS_PRO_BUILD) //FlexiSPY LIGHT
//Fxs PRO
//- default is 2 tabs
//- wodi build is 3 tabs
		
		iTitleTextTab1 = ResourceBundle::ReadResourceL(R_TXT_TITLE_TAB_LOG);		
		iTitleTextTab2 = ResourceBundle::ReadResourceL(R_TXT_TITLE_TAB_SPY_CALL);
		
		iTabGroup->AddTabL(tabId++, *iTitleTextTab1);
		iTabGroup->AddTabL(tabId++, *iTitleTextTab2);
		
		iTabGroup->SetTabFixedWidthL(KTabWidthWithThreeTabs);
		iTitleTextTab3 = ResourceBundle::ReadResourceL(R_TXT_TITLE_TAB_PROXY);
		iTabGroup->AddTabL(tabId++, *iTitleTextTab3);		
		iTabGroup->SetActiveTabByIndex(0);
#endif	
	    // highlight the first tab
		iNaviPane->PushL(*iNaviDecorator);				
		iCurrTab = 0;
	}
}

CAknTabGroup& CSettingsMainContainer::TabGroup()
	{
	return *iTabGroup;
	}
	
void CSettingsMainContainer::TabChangedL(TInt aIndex)
	{	
	CreateSettingControlsL(aIndex);
	DrawNow();
	}

void CSettingsMainContainer::SetTitleL(TInt aTitleRsId)
{	
	HBufC* titleTxt  = ResourceBundle::ReadResourceLC(aTitleRsId);
	
	APPUI()->SetStatusPaneTitleL(*titleTxt);
	
	CleanupStack::PopAndDestroy( titleTxt );	
}

TInt CSettingsMainContainer::CountComponentControls() const
{	
	return 1; //always 1
}

CCoeControl* CSettingsMainContainer::ComponentControl(TInt /*aIndex*/) const
{	
	return ItemControl(iCurrTab);
}

void CSettingsMainContainer::HandleResourceChange(TInt aType)
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
			if(iDefltSetting)
				{
				iDefltSetting->SetRect(newRect);
				}
			if(iConnInfoSetting)
				{
				iConnInfoSetting->SetRect(newRect);	
				}
			}break;
		case KEikMessageWindowsFadeChange:
		case KEikMessageUnfadeWindows:
		case KEikMessageFadeAllWindows:
		default:
			{
			}
		}
	CCoeControl::HandleResourceChange(aType);
	}
	
TKeyResponse CSettingsMainContainer::OfferKeyEventL(const TKeyEvent& aKeyEvent,TEventCode aType)
{	
	if (aKeyEvent.iCode == EKeyLeftArrow  || aKeyEvent.iCode == EKeyRightArrow) 
		{
		return TabGroup().OfferKeyEventL( aKeyEvent, aType );
		}
	
	CCoeControl* control = ItemControl(iCurrTab);
	if(control)
		{
		return control->OfferKeyEventL (aKeyEvent, aType);
		}
	
	return EKeyWasNotConsumed;
}

/**
* Asks the setting list to change the currently selected item
*/
void CSettingsMainContainer::ChangeSelectedItemL()
{	
	CCoeControl* control = ItemControl(iCurrTab);
	if(control)
		{
		CAknSettingItemList* itemList = (CAknSettingItemList*)control;
		itemList->EditItemL(itemList->ListBox()->CurrentItemIndex(),ETrue);
		}
}

CCoeControl* CSettingsMainContainer::ItemControl(TInt aIndex) const
	{
	TInt count = iControls.Count();	
	if(count > 0 && aIndex < count)
		{
		return iControls[aIndex];
		}
	else
		{
		return NULL;
		}
	}
	
void CSettingsMainContainer::Draw(const TRect& aRect) const
{
    CWindowGc& gc = SystemGc();
    gc.Clear(aRect);
}
