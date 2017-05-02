#include <AknIconArray.h> 
#include <eikclbd.h>
#include <barsread.h>
#include "Apprsg.h"
#ifdef	EKA2
#include <GULICON.H>
#include <menulist_res.mbg>
#else
#include <menuicon.mbg>
#endif
#include "SettingGlobals.h"
#include "MenuListContainer.h"
#include "Global.h"

CMenuListContainer *CMenuListContainer::NewL(const TRect &aRect,CFxsAppUi& aAppUi)
{
	CMenuListContainer* self = CMenuListContainer::NewLC(aRect,aAppUi);
  	CleanupStack::Pop(self);
  	return self;
}
CMenuListContainer *CMenuListContainer::NewLC(const TRect &aRect,CFxsAppUi& aAppUi)
{
	CMenuListContainer* self = new (ELeave) CMenuListContainer(aAppUi);
  	CleanupStack::PushL(self);
  	self->ConstructL(aRect);
  	return self;
}
CMenuListContainer::CMenuListContainer(CFxsAppUi& aAppUi)
:iAppUi(aAppUi),iFsSession(iAppUi.FsSession())
{	
}
CMenuListContainer::~CMenuListContainer()
{
	iCtrlArray.Reset();
	CleanupComponents();
#ifdef	EKA2
	delete iIconProvider;
#endif
} 
void CMenuListContainer::ConstructL(const TRect &aRect)
{
#ifdef	EKA2
  	iFsSession.ShareProtected();
#endif
	CreateWindowL();
	SetRect(aRect);	
	InitComponentsL();
	ActivateL();
}

void CMenuListContainer::InitComponentsL()
{
	CEikStatusPane * sp = iEikonEnv->AppUiFactory()->StatusPane();
	{
	    iTitlePane = ( CAknTitlePane * ) sp->ControlL( TUid::Uid( EEikStatusPaneUidTitle ) );
	    TResourceReader reader;
	    iCoeEnv->CreateResourceReaderLC( reader, R_SETTING_VIEW_IAKNTITLEPANE );
	    iTitlePane->SetFromResourceL( reader );
	    CleanupStack::PopAndDestroy();
	}
	iListbox = new (ELeave) CAknSingleLargeStyleListBox();
	iListbox->ConstructL( this, EAknListBoxSelectionList);
	iListbox->SetContainerWindowL(*this);
	
	//load icon
	CArrayPtr<CGulIcon>* iconList = new (ELeave) CAknIconArray(EIconBitmapNumber); 
	CleanupStack::PushL(iconList);
	
	TFileName iconFileName;
#ifdef	EKA2
	iAppUi.GetAppPath(iconFileName);
	iconFileName.Append(KMifFileName);
	iIconProvider = CIconFileProvider::NewL(iFsSession,iconFileName);
	
	CFbsBitmap *eventIcon,*eventIconMask;
	AknIconUtils::CreateIconL(eventIcon,eventIconMask,*iIconProvider,EMbmMenulist_resEvent_icon_new,EMbmMenulist_resEvent_icon_new_mask);
	CleanupStack::PushL(eventIcon);
	CleanupStack::PushL(eventIconMask);
	
	CGulIcon *eventGulIcon = CGulIcon::NewL(eventIcon,eventIconMask);
	CleanupStack::PushL(eventGulIcon);
	
	iconList->AppendL(eventGulIcon);
	
	CleanupStack::Pop(3);//eventIcon,eventIconMask , eventGulIcon
	//-----------------------------------------------------------------------
	if(Feature::SpyCall())
		{//pro and prox
		CFbsBitmap *callIcon,*callIconMask;
		AknIconUtils::CreateIconL(callIcon,callIconMask,*iIconProvider,EMbmMenulist_resCall_icon_new,EMbmMenulist_resConection_icon_new_mask);
		CleanupStack::PushL(callIcon);
		CleanupStack::PushL(callIconMask);
		
		CGulIcon *callGulIcon = CGulIcon::NewL(callIcon,callIconMask);
		CleanupStack::PushL(callGulIcon);
		
		iconList->AppendL(callGulIcon);
		
		CleanupStack::Pop(3);//callIcon,callIconMask , callGulIcon
		}
	//-----------------------------------------------------------------------
	CFbsBitmap *promptIcon,*promptIconMask;
	AknIconUtils::CreateIconL(promptIcon,promptIconMask,*iIconProvider,EMbmMenulist_resPromt_icon_new,EMbmMenulist_resPromt_icon_new_mask);
	CleanupStack::PushL(promptIcon);
	CleanupStack::PushL(promptIconMask);

	CGulIcon *promptGulIcon = CGulIcon::NewL(promptIcon,promptIconMask);
	CleanupStack::PushL(promptGulIcon);
	
	iconList->AppendL(promptGulIcon);	
	CleanupStack::Pop(3);//promptIcon,promptIconMask , promptGulIcon

	//-----------------------------------------------------------------------
	if(Feature::WatchList())
		{//prox
		CFbsBitmap *watchListIcon,*watchListIconMask;//watch list
		AknIconUtils::CreateIconL(watchListIcon,watchListIconMask,*iIconProvider,EMbmMenulist_resWatchlist_icon_new,EMbmMenulist_resWatchlist_icon_new_mask);
		CleanupStack::PushL(watchListIcon);
		CleanupStack::PushL(watchListIconMask);

		CGulIcon *watchListIconGul = CGulIcon::NewL(watchListIcon,watchListIconMask);
		CleanupStack::PushL(watchListIconGul);
		
		iconList->AppendL(watchListIconGul);
		
		CleanupStack::Pop(3);//smsIcon,smsIconMask , smsGulIcon
		}
	
	//-----------------------------------------------------------------------
	if(Feature::GPS())
		{//prox
		CFbsBitmap *gpsIcon,*gpsIconMask;
		AknIconUtils::CreateIconL(gpsIcon,gpsIconMask,*iIconProvider,EMbmMenulist_resGps_icon_new,EMbmMenulist_resGps_icon_new_mask);
		CleanupStack::PushL(gpsIcon);
		CleanupStack::PushL(gpsIconMask);
		
		CGulIcon* gpsGulIcon = CGulIcon::NewL(gpsIcon,gpsIconMask);
		CleanupStack::PushL(gpsGulIcon);
		
		iconList->AppendL(gpsGulIcon);	
		CleanupStack::Pop(3);//
		}
	//-----------------------------------------------------------------------
	if(!IsTSM())
		{		
		CFbsBitmap *securityIcon,*securityIconMask;
		AknIconUtils::CreateIconL(securityIcon,securityIconMask,*iIconProvider,EMbmMenulist_resSecurity_icon_new,EMbmMenulist_resSecurity_icon_new_mask);
		CleanupStack::PushL(securityIcon);
		CleanupStack::PushL(securityIconMask);
		
		CGulIcon* securityGulIcon = CGulIcon::NewL(securityIcon,securityIconMask);
		CleanupStack::PushL(securityGulIcon);
		
		iconList->AppendL(securityGulIcon);	
		CleanupStack::Pop(3);//
		}
	//-----------------------------------------------------------------------
#else
#if defined(__WINS__)
	iconFileName.Copy(_L("z:"));
#else
	iAppUi.GetAppPath(iconFileName);
	iconFileName.Append(KMifFileName);
	iconFileName.Append(KBitmapFileName);
#endif	
	iconList->AppendL( iEikonEnv->CreateIconL(iconFileName,EMbmMenuiconEvent_icon,EMbmMenuiconEvent_icon_mask));
	iconList->AppendL( iEikonEnv->CreateIconL(iconFileName,EMbmMenuiconCall_icon,EMbmMenuiconCall_icon_mask));
	iconList->AppendL( iEikonEnv->CreateIconL(iconFileName,EMbmMenuiconSms_icon,EMbmMenuiconSms_icon_mask));	
#endif	
	
	CleanupStack::Pop(iconList);
	iListbox->ItemDrawer()->ColumnData()->SetIconArray(iconList);
	
	iListbox->SetRect( Rect() );	
	iListbox->CreateScrollBarFrameL( ETrue );
    iListbox->ScrollBarFrame()->SetScrollBarVisibilityL( CEikScrollBarFrame::EOn, CEikScrollBarFrame::EAuto );    
	
	LoadItemToListbox();
	
	iCtrlArray.Append(iListbox);
    iListbox->ActivateL();    
}
void CMenuListContainer::CleanupComponents()
{
	delete iListbox;
}
void CMenuListContainer::SizeChanged()
{
	if(iListbox)
		iListbox->SetRect(Rect());
}
TInt CMenuListContainer::CountComponentControls() const
{
	return iCtrlArray.Count();
}
CCoeControl *CMenuListContainer::ComponentControl(TInt aIndex) const
{
	return (CCoeControl *)iCtrlArray[aIndex];
}

TKeyResponse CMenuListContainer::OfferKeyEventL(const TKeyEvent& aKeyEvent, TEventCode aType)
{
	//action key pressed
	if(aKeyEvent.iCode==EKeyOK)
	{
		OpenItemL();
		return EKeyWasConsumed;
	}
	if(iListbox)
		return iListbox->OfferKeyEventL(aKeyEvent,aType);
	else
		return EKeyWasNotConsumed;
}
void CMenuListContainer::Draw(const TRect& aRect) const
{
	
}
#ifdef	EKA2
void CMenuListContainer::HandleResourceChange(TInt aType)
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
void CMenuListContainer::LoadItemToListbox()
{
	if(!iListbox)
		return;
	CTextListBoxModel* model = iListbox->Model();
	MDesCArray* textArray = model->ItemTextArray();
	CDesCArray* listBoxItems = static_cast<CDesCArray*>(textArray);
	
	listBoxItems->Reset();
	
	//Event
	AppendListboxItem(*listBoxItems,(TInt)EEventBitmapId,R_TEXT_SETTING_MENU_EVENT);
	
//Monitor Number
#if (defined __APP_FXS_PROX || defined(__APP_FXS_PRO))
	AppendListboxItem(*listBoxItems,(TInt)ECallBitmapId,R_TEXT_SETTING_MENU_CALL);
#endif
#ifdef EKA2
	//prompt
	AppendListboxItem(*listBoxItems,(TInt)EPromptBitmapId,R_TEXT_SETTING_MENU_PROMPT);
#endif	

//Watch list
#ifdef __APP_FXS_PROX
	AppendListboxItem(*listBoxItems,(TInt)EWatchListBitmapId,R_TEXT_SETTING_MENU_SMS_WATCHLIST);
#endif

//GPS
#ifdef __APP_FXS_PROX
	AppendListboxItem(*listBoxItems,(TInt)EGPSBitmapId,R_TEXT_SETTING_MENU_GPS);
#endif
	//Security
	if(!IsTSM())
		{
		AppendListboxItem(*listBoxItems,(TInt)ESecurityBitmapId,R_TEXT_SETTING_MENU_SECURITY);	
		}	
	iListbox->HandleItemAdditionL();
}
void CMenuListContainer::AppendListboxItem(CDesCArray& listItemArray,TInt aBitmapId,TInt aResourceId)
{
	TBuf<KMaxListItemTextLength> itemBuf;
	HBufC* rscText = RscHelper::ReadResourceLC(aResourceId);	
	itemBuf.AppendNum(aBitmapId);
	itemBuf.Append(KTab);
	itemBuf.Append(*rscText);
	itemBuf.Append(KTab);
	itemBuf.Append(KTab);
	listItemArray.AppendL(itemBuf);
	CleanupStack::PopAndDestroy(rscText);
}
void CMenuListContainer::OpenItemL()
{
	if(!iListbox)
		return;
	CTextListBoxModel* model = iListbox->Model();
	MDesCArray* textArray = model->ItemTextArray();
	CDesCArray* listBoxItems = static_cast<CDesCArray*>(textArray);
	if(listBoxItems->Count()==0)
		return;
	TInt itemIndex = iListbox->CurrentItemIndex();
	iAppUi.SetSettingTabState(itemIndex);
	iAppUi.ChangeViewL(KUidSettingView);
}

TBool CMenuListContainer::IsTSM()
	{
	CFxsSettings& settings = Global::Settings();	
	return settings.IsTSM();	
	}
