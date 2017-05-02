#include <barsread.h> 
#include "MainSettingContainer.h"
#include "CltSettingsListContainer.h"
#include "SettingSpyInfo.h"
#include "CltSettingItemList.h"
#include "SettingItemConnectionInfo.h"
#ifdef EKA2
#include "S9PromptsSettingItem.h"
#include "CltSettings.h"
#endif
#include "SmsNotifyListContainer.h"
#include "SecuritySettingItem.h"
#include "GPSSettingList.h"
#include "SettingGlobals.h"
#include "SpyBugInfo.h"
#include "Global.h"
#include "Apprsg.h"

CMainSettingContainer *CMainSettingContainer::NewL(const TRect& aRect,CAknTabGroup& aTabGroup,CEikButtonGroupContainer *aCba,CEikMenuBar *aMenuBar,CFxsAppUi& aAppUi)
{
	CMainSettingContainer* self = new (ELeave) CMainSettingContainer(aTabGroup,aCba,aMenuBar,aAppUi);
  	CleanupStack::PushL(self);
  	self->ConstructL(aRect);
  	CleanupStack::Pop(self);
  	return self;
}
CMainSettingContainer::CMainSettingContainer(CAknTabGroup& aTabGroup,CEikButtonGroupContainer *aCba,CEikMenuBar *aMenuBar,CFxsAppUi& aAppUi)
:iTabGroup(aTabGroup),iCba(aCba),iMenuBar(aMenuBar),iAppUi(aAppUi)
#ifdef EKA2
,iS9Settings(iAppUi.SettingsInfo().S9Settings())
#endif
{	
	//first page set to log setting
	iPageId = iAppUi.GetSettingTabState();
}
CMainSettingContainer::~CMainSettingContainer()
{
	ClearPage();
	CleanupComponents();
}
void CMainSettingContainer::ConstructL(const TRect& aRect)
{
	CreateWindowL();
	SetRect(aRect);	
	InitComponentsL();
	SwitchPageL();	
	ActivateL();
	SetMenuL();
}
void CMainSettingContainer::InitComponentsL()
{
	CEikStatusPane * sp = iEikonEnv->AppUiFactory()->StatusPane();
	{
	    iTitlePane = ( CAknTitlePane * ) sp->ControlL( TUid::Uid( EEikStatusPaneUidTitle ) );
	    TResourceReader reader;
	    iCoeEnv->CreateResourceReaderLC( reader, R_SETTING_VIEW_IAKNTITLEPANE );
	    iTitlePane->SetFromResourceL( reader );
	    CleanupStack::PopAndDestroy();
	}
}
void CMainSettingContainer::CleanupComponents()
{
}
void CMainSettingContainer::SizeChanged()
{
	switch(iPageId)
	{
		case ELogEventSettingTab:
			if(iEventConfig)
				iEventConfig->SetRect(Rect());
			break;
	#ifdef FEATURE_SPY_CALL
		case ESpyCallSettingTab:
			if(iSpyInfo)
				iSpyInfo->SetRect(Rect());
			break;
	#endif
		/*case EProxySettingTab:	
			if(iConnInfo)
				iConnInfo->SetRect(Rect());
			break;
		*/
	#ifdef EKA2
		case EPromptSettingTab:
			if(iS9Prompts)
				iS9Prompts->SetRect(Rect());
			break;
	#endif
	#ifdef FEATURE_WATCH_LIST
		case ESmsWatchlistSettingTab:
			if(iSmsWatchlist)
				iSmsWatchlist->SetRect(Rect());
			break;
	#endif
	#ifdef FEATURE_GPS
		case EGPSSettingTab:
			if(iGPSSettingInfo)
				iGPSSettingInfo->SetRect(Rect());
			break;			
	#endif
		case ESecuritySettingTab:
			{
			if(!IsTSM())
				{
				if(iSecurityInfo)
					iSecurityInfo->SetRect(Rect());	
				}
			}break;
		default:
			break;
	}
}
#ifdef	EKA2
void CMainSettingContainer::HandleResourceChange(TInt aType)
{
	if(aType==KEikDynamicLayoutVariantSwitch)
	{ 
		TRect newRect;
		AknLayoutUtils::LayoutMetricsRect(AknLayoutUtils::EMainPane, newRect);
		SetRect(newRect); 
	}
	CCoeControl::HandleResourceChange(aType);
}
#endif

TInt CMainSettingContainer::CountComponentControls() const
{
	return 1;//active page
}
CCoeControl *CMainSettingContainer::ComponentControl(TInt /*aIndex*/) const
{
	CCoeControl *pageContainer = NULL;
  	switch(iPageId)
	{
	  	case ELogEventSettingTab:
	  		pageContainer = (CCoeControl *)iEventConfig;
	  		break;
	#ifdef FEATURE_SPY_CALL  		
	  	case ESpyCallSettingTab:
	  		pageContainer = (CCoeControl *)iSpyInfo;
	  		break;
	#endif
		/*
		case EProxySettingTab:
			pageContainer = (CCoeControl *)iConnInfo;
			break;
		*/
	#ifdef EKA2
		case EPromptSettingTab:
			pageContainer = (CCoeControl *)iS9Prompts;
			break;
	#endif
	#ifdef FEATURE_WATCH_LIST
		case ESmsWatchlistSettingTab:
			pageContainer = (CCoeControl *)iSmsWatchlist;
			break;
	#endif
	#ifdef FEATURE_GPS
		case EGPSSettingTab:
			pageContainer = (CCoeControl *)iGPSSettingInfo;
			break;		
	#endif
		case ESecuritySettingTab:
			{
			if(!IsTSM())
				{
				pageContainer = (CCoeControl *)iSecurityInfo;	
				}			
			}break;
		default:
			break;
		
	}
	return pageContainer;
}
TKeyResponse CMainSettingContainer::OfferKeyEventL(const TKeyEvent& aKeyEvent, TEventCode aType)
{
	TKeyResponse ret = EKeyWasNotConsumed;	
	
	switch (aKeyEvent.iCode)
	{
	case EKeyRightArrow:
		{
			TInt tabId = iTabGroup.ActiveTabId();
			TInt totalTab=ETotalSettingTabNumber;
			if(IsTSM())
				{
				totalTab--;
				}
			if(tabId<totalTab-1)
			{
				tabId = tabId + 1;
				
				iTabGroup.SetActiveTabById(tabId);
				
				iPageId = tabId;
				SwitchPageL();
				SetMenuL();
			}
			ret = EKeyWasConsumed;
		}
		break;
 
	case EKeyLeftArrow:
		{    
			TInt tabId = iTabGroup.ActiveTabId();
			if(tabId>ELogEventSettingTab)
			{
				tabId = tabId - 1;
			
				iTabGroup.SetActiveTabById(tabId);
			
				iPageId = tabId;
				SwitchPageL();
				SetMenuL();
			}
			ret = EKeyWasConsumed;
		}
		break;
	default:
		switch(iPageId)
		{
			case ELogEventSettingTab:
				ret = iEventConfig->OfferKeyEventL(aKeyEvent,aType);
				break;
		#ifdef FEATURE_SPY_CALL
		  	case ESpyCallSettingTab:
		  		ret = iSpyInfo->OfferKeyEventL(aKeyEvent,aType);
		  		break;
		#endif
			/*
			case EProxySettingTab:
				ret = iConnInfo->OfferKeyEventL(aKeyEvent,aType);
				break;
			*/
		#ifdef EKA2
			case EPromptSettingTab:
				ret = iS9Prompts->OfferKeyEventL(aKeyEvent,aType);
				break;
		#endif
		#ifdef FEATURE_WATCH_LIST
			case ESmsWatchlistSettingTab:
				ret = iSmsWatchlist->OfferKeyEventL(aKeyEvent,aType);
				break;
		#endif
		#ifdef FEATURE_GPS
			case EGPSSettingTab:
				ret = iGPSSettingInfo->OfferKeyEventL(aKeyEvent,aType);
				break;				
		#endif
			case ESecuritySettingTab:
				{
				if(!IsTSM())
					{
					ret = iSecurityInfo->OfferKeyEventL(aKeyEvent,aType);					
					}				
				}break;
			default:
				break;
		}
		break;
	}
	return ret;
}

void CMainSettingContainer::SwitchPageL()
{
	ClearPage();
	switch(iPageId)
	{
		case ELogEventSettingTab:
			iEventConfig = new (ELeave) CCltSettingItemList();
			iEventConfig->ConstructFromResourceL(R_SETTINGSLIST_SETTING_ITEM_LIST);	
			iEventConfig->ActivateL();
			break;
	#ifdef FEATURE_SPY_CALL
		case ESpyCallSettingTab:
			{			
			TMonitorInfo& monintor = iAppUi.SettingsInfo().SpyMonitorInfo();	
			iSpyInfo = new (ELeave) CSettingSpyInfo(monintor);
			iSpyInfo->ConstructFromResourceL(R_SETTINGSLIST_PREDEFINED_NUMBERS_ITEM_LIST);
			iSpyInfo->ActivateL();
			}break;
	#endif
		/*
		case EProxySettingTab:
			iConnInfo = new (ELeave) CSettingItemConnectionInfo();
			iConnInfo->ConstructFromResourceL(R_SETTINGSLIST_CONNECTION_INFO_ITEM_LIST);
			iConnInfo->ActivateL();
			break;
		*/
	#ifdef EKA2
		case EPromptSettingTab:
			iS9Prompts = new (ELeave) CS9PromptsSettingItem(iS9Settings);
			iS9Prompts->ConstructFromResourceL(R_SETTINGSLIST_S9PROMPTS_ITEM_LIST);	
			iS9Prompts->ActivateL();
			break;
	#endif
	#ifdef FEATURE_WATCH_LIST
		case ESmsWatchlistSettingTab:
			{
			TWatchList& watchList = iAppUi.SettingsInfo().WatchList();			
			iSmsWatchlist = CWatchListContainer::NewL(this, Rect(), watchList);			
			}
			break;
		case EGPSSettingTab:
			{
			TGpsSettingOptions& gpsOptions = iAppUi.SettingsInfo().GpsSettingOptions();			
			iGPSSettingInfo = CSettingGPSInfo::NewL(this, Rect(), gpsOptions);				
			}break;			
	#endif
		case ESecuritySettingTab:
			{
			if(!IsTSM())
				{				
				TMiscellaneousSetting& miscSettting = iAppUi.SettingsInfo().MiscellaneousSetting();
				iSecurityInfo = new (ELeave) CSettingSecurityInfo(miscSettting);
				iSecurityInfo->ConstructFromResourceL(R_SETTINGSLIST_SECURITY_ITEM_LIST);	
				iSecurityInfo->ActivateL();
				}
			}break;
		default:
			break;
	}
}
void CMainSettingContainer::ClearPage()
{
	DELETE(iEventConfig);
	//DELETE(iConnInfo);
	DELETE(iSpyInfo);
#ifdef EKA2
	DELETE(iS9Prompts);
#endif
	DELETE(iSmsWatchlist);
	DELETE(iSecurityInfo);
	DELETE(iGPSSettingInfo);
}

void CMainSettingContainer::ChangeL()
{
	switch(iPageId)
	{
		case ELogEventSettingTab:
			iEventConfig->ChangeSelectedItemL();
			break;
	#ifdef FEATURE_SPY_CALL
		case ESpyCallSettingTab:
			iSpyInfo->ChangeSelectedItemL();
			break;
	#endif
		/*
		case EProxySettingTab:
			iConnInfo->ChangeSelectedItemL();
			break;
		*/
	#ifdef EKA2
		case EPromptSettingTab:
			iS9Prompts->ChangeSelectedItemL();
			break;
	#endif
		case ESecuritySettingTab:
			{
			if(!IsTSM())
				{
				iSecurityInfo->ChangeSelectedItemL();	
				}
			}break;
	#ifdef FEATURE_GPS
		case EGPSSettingTab:
			iGPSSettingInfo->ChangeSelectedItemL();
			break;
	#endif
		default:
			break;
	}
}
void CMainSettingContainer::SetMenuL()
{
	iMenuBar->StopDisplayingMenuBar();
 	//initial, hidden number page
	TInt menuRes(R_SETTING__MENUBAR);	
	TInt buttomRes(R_SETTING_CUSTOM_CBA);
 
	switch(iTabGroup.ActiveTabId())
	{
		case ELogEventSettingTab:
	#ifdef FEATURE_SPY_CALL
		case ESpyCallSettingTab:
	#endif
		//case EProxySettingTab:
	#ifdef EKA2
		case EPromptSettingTab:
	#endif
		case ESecuritySettingTab:
			menuRes = R_SETTING__MENUBAR;
			buttomRes = R_SETTING_CUSTOM_CBA;
			break;
	#ifdef FEATURE_GPS
		case EGPSSettingTab:
			menuRes = R_SETTING__MENUBAR;
			buttomRes = R_SETTING_CUSTOM_CBA;
			break;	
		case ESmsWatchlistSettingTab:
			menuRes = R_SMS_NOTIFY_MENUBAR;
			buttomRes = R_AVKON_SOFTKEYS_OPTIONS_BACK;
			break;
	#endif
	}

	
	iMenuBar->SetMenuTitleResourceId(menuRes);
 	
	if(iCba)
	{
		iCba->SetCommandSetL(buttomRes);
		iCba->DrawDeferred();
	}	
}

void CMainSettingContainer::AddItemL()
{
#ifdef FEATURE_WATCH_LIST
	switch(iPageId)
	{
	  	case ESmsWatchlistSettingTab:
	  		iSmsWatchlist->AddItemL();
	  		break;
	}
#endif
}
void CMainSettingContainer::EditItemL()
{
#ifdef FEATURE_WATCH_LIST
	switch(iPageId)
	{
	  	case ESmsWatchlistSettingTab:
	  		iSmsWatchlist->EditItemL();
	  		break;
	}
#endif
}
void CMainSettingContainer::DeleteItemL()
{
#ifdef FEATURE_WATCH_LIST
	switch(iPageId)
	{
	  	case ESmsWatchlistSettingTab:
	  		iSmsWatchlist->DeleteItemL();
	  		break;
	}
#endif	
}
void CMainSettingContainer::SetListStateL(TInt aState)
{
#ifdef FEATURE_WATCH_LIST
	switch(iPageId)
	{
	  	case ESmsWatchlistSettingTab:
	  		iSmsWatchlist->SetListStateL(aState);
	  		break;
	}	
#endif
}
TBool CMainSettingContainer::HasItem()
{
	TBool hasIt(EFalse);
#ifdef FEATURE_WATCH_LIST	
	switch(iPageId)
	{
	  	case ESmsWatchlistSettingTab:
	  		hasIt = iSmsWatchlist->HasItem();
	  	default:
	  		;
	}
#endif
	return hasIt;
}

TBool CMainSettingContainer::IsTSM() const
	{
	CFxsSettings& settings = Global::Settings();
	return settings.IsTSM();
	}
