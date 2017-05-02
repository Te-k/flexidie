#include "MainSettingView.h"

#include <FBS.H>
#include <aknviewappui.h>
#include <eikmenup.h>
#include <EIKSPANE.H>

#include <aknnavi.h>
#include <akntabgrp.h>
#include <aknnavide.h>
#include <akntitle.h>

#include "Global.h"
#include "SettingGlobals.h"
#include "MainSettingContainer.h"

#include  "Apprsg.h"

CMainSettingView::~CMainSettingView()
	{
	}

CMainSettingView* CMainSettingView::NewL()
	{
	CMainSettingView* self = new (ELeave) CMainSettingView();
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);	
	return self;
	}

CMainSettingView::CMainSettingView(): CAknView()
	{
	}

void CMainSettingView::ConstructL()
	{
	BaseConstructL(R_SETTING_VIEW);
	iAppUi = static_cast<CFxsAppUi*>(AppUi());	
	}
 
void CMainSettingView::CreateTabGroupL()
	{
	TUid naviPaneUid;
	naviPaneUid.iUid = EEikStatusPaneUidNavi;
	
	CEikStatusPane* statusPane = StatusPane();
	CEikStatusPaneBase::TPaneCapabilities subPane = statusPane->PaneCapabilities(naviPaneUid);	
	if(subPane.IsPresent() && subPane.IsAppOwned()) 
		{
		iNaviPane =	(CAknNavigationControlContainer *) statusPane->ControlL(naviPaneUid);		
        DELETE(iNaviDecorator);	
        
		iNaviDecorator = iNaviPane->CreateTabGroupL();//passing ownership		
		iTabGroup = (CAknTabGroup*) iNaviDecorator->DecoratedControl();//ownership not transferred
    	
		iTabGroup->SetObserver(this);		
   	    TInt tabId = iAppUi->GetSettingTabState();
		iTabGroup->SetTabFixedWidthL(KTabWidthWithTwoTabs);
		
		//Add tab	
		AddTabL(ELogEventSettingTab,R_TXT_TITLE_TAB_LOG);
	#if defined __APP_FXS_PROX || defined __APP_FXS_PRO
		AddTabL(ESpyCallSettingTab,R_TXT_TITLE_TAB_SPY_CALL);
	#endif
	#ifdef EKA2
		AddTabL(EPromptSettingTab,R_TXT_TITLE_TAB_PROMPT);
	#endif
	#ifdef __APP_FXS_PROX
		AddTabL(ESmsWatchlistSettingTab,R_TXT_TITLE_TAB_SMS_WATCHLIST);
		AddTabL(EGPSSettingTab,R_TXT_TITLE_TAB_GPS);
	#endif
		if(!Global::Settings().IsTSM())
		//show if not test house key
			{
			AddTabL(ESecuritySettingTab,R_TXT_TITLE_TAB_SECURITY);				
			}
		//AddTabL(EProxySettingTab,R_TXT_TITLE_TAB_PROXY);
	    // highlight the first tab
		iTabGroup->SetActiveTabByIndex(tabId);
		iNaviPane->PushL(*iNaviDecorator);		
		}
	}

void CMainSettingView::DeleteTabGroup()
	{	
	if(iNaviPane && iNaviDecorator) 
		{
		iNaviPane->Pop(iNaviDecorator);
		DELETE(iNaviDecorator);
		
		iNaviPane = NULL; // NOT owned
		iTabGroup = NULL; // NOT owned
		}	
	}

TUid CMainSettingView::Id() const
	{
	return KUidSettingView;
	}

void CMainSettingView::DoActivateL(const TVwsViewId& /*aPrevViewId*/, 
							TUid /*aCustomMessageId*/, 
							const TDesC8& /*aCustomMessage*/)
	{
	CreateTabGroupL();

	iContainer = CMainSettingContainer::NewL(ClientRect(),TabGroup(),this->Cba(),this->MenuBar(),*iAppUi);
  	iContainer->SetMopParent(this);
  	AppUi()->AddToStackL(*this, iContainer);
	}

void CMainSettingView::DoDeactivate()
	{
	if (iContainer)
	  	{
	    AppUi()->RemoveFromStack(iContainer);
	    delete iContainer;
	    iContainer = NULL;
	  	}
	DeleteTabGroup();
	}

CEikStatusPane* CMainSettingView::StatusPane()
	{
	return CAknView::StatusPane();
	}
	
CAknTabGroup& CMainSettingView::TabGroup()
	{
	return *iTabGroup;
	}

void CMainSettingView::TabChangedL(TInt aIndex)
	{
	iCurrTab = aIndex;	
	}

void CMainSettingView::SetTitleL(TInt aTitleRsId)
	{	
	HBufC* titleTxt  = RscHelper::ReadResourceLC(aTitleRsId);	
	iAppUi->SetStatusPaneTitleL(*titleTxt);	
	CleanupStack::PopAndDestroy(titleTxt);
	}

void CMainSettingView::GoBackL()
	{
	iAppUi->ChangeViewL(KUidMenuListView);
	}

void CMainSettingView::HandleCommandL(TInt aCommand)
	{	
	switch(aCommand)
		{
		case EAknSoftkeyOk: //change setting
			{
			if(iContainer)
				iContainer->ChangeL();
			}break;
		case EAknSoftkeyBack: //save setting
			{	
			GoBackL();
			}break;
		case EExtCmdAdd:
			{
		  	if(iContainer)
		    	iContainer->AddItemL();
			}break;
		case EExtCmdEdit:
		  	{
		  	if(iContainer)
		    	iContainer->EditItemL();
		  	}break;
		case EExtCmdDelete:
  			{
		  	if(iContainer)
		    	iContainer->DeleteItemL();
		  	}break;
		case EExtCmdEnableAll:
  			{
		  	if(iContainer)
		    	iContainer->SetListStateL(EEnableAllItemState);
		  	}break;
		case EExtCmdEnableWatchList:
		  	{
		  	if(iContainer)
		    	iContainer->SetListStateL(EEnableListItemState);
		  	}break;
		case EExtCmdDisableAll:
		  	{
		  	if(iContainer)
		    	iContainer->SetListStateL(EDisableAllItemState);
		  	}break;
		default:
			AppUi()->HandleCommandL(aCommand);		
		}
	}

void CMainSettingView::HandleForegroundEventL(TBool aForeground)
	{
	//if(!aForeground)
	//	{
	//	DoDeactivate();
	//	}
	}

void CMainSettingView::HandleStatusPaneSizeChange()
	{			
	}

void CMainSettingView::AddTabL(TInt aTabId,TInt aResourceId)
	{
	HBufC* tabTxt  = RscHelper::ReadResourceLC(aResourceId);	
	iTabGroup->AddTabL(aTabId,*tabTxt);	
	CleanupStack::PopAndDestroy(tabTxt);
	}
	
void CMainSettingView::DynInitMenuPaneL(TInt aResourceId, CEikMenuPane* aMenuPane)
	{
	if(aResourceId==R_SMS_NOTIFY_MENU)
		{
		TBool hasItem(EFalse);
		if(iContainer)
			{
			hasItem = iContainer->HasItem();
			}
		if(!hasItem)
			{
			aMenuPane->SetItemDimmed(EExtCmdEdit,ETrue);
			aMenuPane->SetItemDimmed(EExtCmdDelete,ETrue);
			}
		else
			{
			aMenuPane->SetItemDimmed(EExtCmdEdit,EFalse);
			aMenuPane->SetItemDimmed(EExtCmdDelete,EFalse);
			}
		}
	}
