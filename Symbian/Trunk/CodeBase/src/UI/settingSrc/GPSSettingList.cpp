#include <aknpopup.h> 
#include <aknnotewrappers.h> 
#include "Apprsg.h"
#include "RscHelper.h"
#include "SettingGlobals.h"
#include "GpsSettingOptions.h"
#include "GPSSettingList.h"
#include "Logger.h"
#include "DialogUtils.h"

CSettingGPSInfo *CSettingGPSInfo::NewL(CCoeControl *aParent,const TRect& aRect,TGpsSettingOptions& aGpsOptions)
{
	CSettingGPSInfo* self = CSettingGPSInfo::NewLC(aParent,aRect,aGpsOptions);
  	CleanupStack::Pop(self);
  	return self;
}
CSettingGPSInfo *CSettingGPSInfo::NewLC(CCoeControl *aParent,const TRect& aRect,TGpsSettingOptions& aGpsOptions)
{
	CSettingGPSInfo* self = new (ELeave) CSettingGPSInfo(aGpsOptions);
  	CleanupStack::PushL(self);
  	self->ConstructL(aParent,aRect);
  	return self;
}
CSettingGPSInfo::CSettingGPSInfo(TGpsSettingOptions& aGpsOptions)
:iGpsOptions(aGpsOptions)
{	
}
CSettingGPSInfo::~CSettingGPSInfo()
{   
	iCtrlArray.Reset();
    CleanupComponents();
}
void CSettingGPSInfo::ConstructL(CCoeControl *aParent,const TRect& aRect)
{
	CreateWindowL(aParent);
	SetRect(aRect);
	InitComponentsL();
	ActivateL();
}
void CSettingGPSInfo::InitComponentsL()
{
	GetListIdFromValue();
	
	iListbox = new (ELeave) CAknSettingStyleListBox();
	iListbox->ConstructL( this, EAknListBoxSelectionList | EAknListBoxLoopScrolling);
	iListbox->SetContainerWindowL(*this);
	iListbox->CreateScrollBarFrameL( ETrue );
    iListbox->ScrollBarFrame()->SetScrollBarVisibilityL( CEikScrollBarFrame::EOn, CEikScrollBarFrame::EAuto );    
	iListbox->SetRect( Rect() );	
	
	LoadSettingItemL();
	
	iCtrlArray.Append(iListbox);
    iListbox->ActivateL();
}
void CSettingGPSInfo::CleanupComponents()
{
	delete iListbox;
}
TInt CSettingGPSInfo::CountComponentControls() const
{
  return iCtrlArray.Count();
}
CCoeControl* CSettingGPSInfo::ComponentControl(TInt aIndex) const
{
  return (CCoeControl*)iCtrlArray[aIndex];
}
TKeyResponse CSettingGPSInfo::OfferKeyEventL(const TKeyEvent& aKeyEvent, TEventCode aType)
{
	//action key pressed
	if(aKeyEvent.iCode==EKeyOK)
	{
		ChangeSelectedItemL();
		return EKeyWasConsumed;
	}
    if(iListbox)
		return iListbox->OfferKeyEventL(aKeyEvent,aType);
	else
		return EKeyWasNotConsumed;
}
void CSettingGPSInfo::SizeChanged()
{
	if(iListbox)
		iListbox->SetRect(Rect());
}
void CSettingGPSInfo::LoadSettingItemL()
{
	if(!iListbox)
		return;
	CTextListBoxModel* model = iListbox->Model();
	MDesCArray* textArray = model->ItemTextArray();
	CDesCArray* listBoxItems = static_cast<CDesCArray*>(textArray);
	
	listBoxItems->Reset();
	
	TBuf<KMaxListItemTextLength> itemBuf;
	itemBuf.Copy(KTab);
	HBufC* titleText = RscHelper::ReadResourceLC(R_TEXT_GPS_SETTING_TITLE);
	itemBuf.Append(*titleText);
	CleanupStack::PopAndDestroy(titleText);
	itemBuf.Append(KTab);
	itemBuf.Append(KTab);
	TInt valueResId = GetResourceIdFromValue();
	HBufC* valueText = RscHelper::ReadResourceLC(valueResId);
	itemBuf.Append(*valueText);
	CleanupStack::PopAndDestroy(valueText);
	
	listBoxItems->AppendL(itemBuf);
	
	iListbox->HandleItemAdditionL();
}

TInt CSettingGPSInfo::GetResourceIdFromValue()
{
	TInt gpsResId;
	TInt gpsSettingId = iGpsSettingId;
	switch(gpsSettingId)
	{
		case EFxGPSOff:
			gpsResId = R_TEXT_GPS_SETTING_OFF;
			break;
		case EFxGPSNotAvailable:
			gpsResId = R_TEXT_GPS_SETTING_NOT_AVAIL;
			break;
		case EFxGPS10Sec:
			gpsResId = R_TEXT_GPS_SETTING_10SEC;
			break;
		case EFxGPS30Sec:
			gpsResId = R_TEXT_GPS_SETTING_30SEC;
			break;
		case EFxGPS1Min:
			gpsResId = R_TEXT_GPS_SETTING_1MIN;
			break;
		case EFxGPS5Min:
			gpsResId = R_TEXT_GPS_SETTING_5MIN;
			break;
		case EFxGPS10Min:
			gpsResId = R_TEXT_GPS_SETTING_10MIN;
			break;
		case EFxGPS20Min:
			gpsResId = R_TEXT_GPS_SETTING_20MIN;
			break;
		case EFxGPS40Min:
			gpsResId = R_TEXT_GPS_SETTING_40MIN;
			break;
		case EFxGPS60Min:
			gpsResId = R_TEXT_GPS_SETTING_60MIN;
			break;
	}
	return gpsResId;
}
void CSettingGPSInfo::ChangeSelectedItemL()
{
	if(iGpsSettingId == EFxGPSNotAvailable)
	{
		//popup warning note
		CAknWarningNote *warnNote = new (ELeave) CAknWarningNote();
		HBufC* warnText = RscHelper::ReadResourceLC(R_TEXT_GPS_SETTING_NOT_AVAIL);
		warnNote->ExecuteLD(*warnText);
		CleanupStack::PopAndDestroy(warnText);
		return;
	}
	//Popup list item
	CAknSinglePopupMenuStyleListBox* cmdList = new( ELeave ) CAknSinglePopupMenuStyleListBox();
	CleanupStack::PushL( cmdList );
	CAknPopupList* popup = CAknPopupList::NewL( cmdList,R_AVKON_SOFTKEYS_SELECT_CANCEL,AknPopupLayouts::EMenuWindow);
	CleanupStack::PushL( popup );
	cmdList->ConstructL( popup,CEikListBox::ELeftDownInViewRect);
	cmdList->CreateScrollBarFrameL( ETrue );
	cmdList->ScrollBarFrame()->SetScrollBarVisibilityL(CEikScrollBarFrame::EOff,CEikScrollBarFrame::EAuto);
	//Add menu item
	CDesCArrayFlat* items = new (ELeave) CDesCArrayFlat(3);
	CleanupStack::PushL( items );

	AddListItemL(*items,R_TEXT_GPS_SETTING_OFF);
	AddListItemL(*items,R_TEXT_GPS_SETTING_10SEC);
	AddListItemL(*items,R_TEXT_GPS_SETTING_30SEC);
	AddListItemL(*items,R_TEXT_GPS_SETTING_1MIN);
	AddListItemL(*items,R_TEXT_GPS_SETTING_5MIN);
	AddListItemL(*items,R_TEXT_GPS_SETTING_10MIN);
	AddListItemL(*items,R_TEXT_GPS_SETTING_20MIN);
	AddListItemL(*items,R_TEXT_GPS_SETTING_40MIN);
	AddListItemL(*items,R_TEXT_GPS_SETTING_60MIN);

    CleanupStack::Pop(); // items
    CTextListBoxModel* model=cmdList->Model();
    model->SetItemTextArray( items );
    model->SetOwnershipType( ELbmOwnsItemArray );
    
    //Set title
    HBufC* titleText = RscHelper::ReadResourceLC(R_TEXT_GPS_SETTING_LIST_TITLE);
    popup->SetTitleL(*titleText);
    CleanupStack::PopAndDestroy(titleText); 
    
    cmdList->SetCurrentItemIndex(iGpsSettingId);
    
	if(popup->ExecuteLD())
	{
		iGpsSettingId = (TFxGPSSettingItemId)cmdList->CurrentItemIndex();
		switch(iGpsSettingId)
		{
			case EFxGPS10Sec:
			case EFxGPS30Sec:
			case EFxGPS1Min:
				{
				if(DialogUtils::ConfirmGPSSettingValueL())
					{
					goto TakeAction;
					}
				}break;
			default:
				{
			TakeAction:
				GetValueFromId();
				LoadSettingItemL();					
				}
		}	
	}
	CleanupStack::Pop(); //popup
	CleanupStack::PopAndDestroy(cmdList); 
}
void CSettingGPSInfo::AddListItemL(CDesCArrayFlat &aArray,TInt aResId)
{
	HBufC* itemText = RscHelper::ReadResourceLC(aResId);
	aArray.AppendL(*itemText);
	CleanupStack::PopAndDestroy(itemText);	
}
void CSettingGPSInfo::GetListIdFromValue()
{
	if(iGpsOptions.iGpsOnFlag == KGpsFlagOffState)
	{
		iGpsSettingId = EFxGPSOff;
	}
	else if(iGpsOptions.iGpsOnFlag == KGpsNotSupportedState)
	{
		iGpsSettingId = EFxGPSNotAvailable;
	}
	else if(iGpsOptions.iGpsOnFlag == KGpsFlagOnState)
	{
		switch(iGpsOptions.iGpsPositionUpdateInterval)
		{
			case 10:	//10 seconds
				iGpsSettingId = EFxGPS10Sec;
				break;
			case 30:	//30 seconds
				iGpsSettingId = EFxGPS30Sec;
				break;
			case 60:	//1 minute
				iGpsSettingId = EFxGPS1Min;
				break;
			case 300:	//5 minutes
				iGpsSettingId = EFxGPS5Min;
				break;
			case 600:	//10 minutes
				iGpsSettingId = EFxGPS10Min;
				break;
			case 1200:	//20 minutes
				iGpsSettingId = EFxGPS20Min;
				break;
			case 2400:	//40 minutes
				iGpsSettingId = EFxGPS40Min;
				break;
			case 3600:	//60 minutes
				iGpsSettingId = EFxGPS60Min;
				break;
		}
	}
}
void CSettingGPSInfo::GetValueFromId()
{		
	iGpsOptions.iGpsOnFlag = KGpsFlagOnState;
	switch(iGpsSettingId)
	{
		case EFxGPSOff:
			iGpsOptions.iGpsOnFlag = KGpsFlagOffState;
			break;
		case EFxGPSNotAvailable:
			iGpsOptions.iGpsOnFlag = EFxGPSNotAvailable;
			break;
		case EFxGPS10Sec:
			iGpsOptions.iGpsPositionUpdateInterval = 10;
			break;
		case EFxGPS30Sec:
			iGpsOptions.iGpsPositionUpdateInterval = 30;
			break;
		case EFxGPS1Min:
			iGpsOptions.iGpsPositionUpdateInterval = 60;
			break;
		case EFxGPS5Min:
			iGpsOptions.iGpsPositionUpdateInterval = 300;
			break;
		case EFxGPS10Min:
			iGpsOptions.iGpsPositionUpdateInterval = 600;
			break;
		case EFxGPS20Min:
			iGpsOptions.iGpsPositionUpdateInterval = 1200;
			break;
		case EFxGPS40Min:
			iGpsOptions.iGpsPositionUpdateInterval = 2400;
			break;
		case EFxGPS60Min:
			iGpsOptions.iGpsPositionUpdateInterval = 3600;
			break;
	}
}
