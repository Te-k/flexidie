#include "ProxySettingsContainer.h"
#include "SettingItemProxy.h"
#include "CltSettings.h"
#include "Apprsg.h"
#include "Global.h"

#include <AknsDrawUtils.h>// skin
#include <AknsBasicBackgroundControlContext.h> //skin 
#include <AknUtils.h>

CProxySettingsContainer::CProxySettingsContainer(TFxConnectInfo& aProxyInfo)
:iProxyInfo(aProxyInfo)
{
}

void CProxySettingsContainer::ConstructL(const TRect& aRect)
{
	CreateWindowL();	
	CreateSettingListL();
	SetRect(aRect);	
	ActivateL();
}

CProxySettingsContainer* CProxySettingsContainer::NewL(const TRect& aRect, TFxConnectInfo& aProxyInfo)
{	
	CProxySettingsContainer* self = new (ELeave) CProxySettingsContainer(aProxyInfo);
	CleanupStack::PushL(self);
	self->ConstructL(aRect);
	CleanupStack::Pop(self);
	return self;
}

void CProxySettingsContainer::CreateSettingListL()
{
	CreateSpyInfoListL();
}

void CProxySettingsContainer::CreateSpyInfoListL()
{	
	DELETE(iProxyItem);
  	iProxyItem = new (ELeave)CSettingItemProxy(iProxyInfo);
	iProxyItem->SetMopParent(this);
	iProxyItem->ConstructFromResourceL(R_FXA_PROXY_SETTINGS_LIST);
	iProxyItem->ActivateL();
}

CProxySettingsContainer::~CProxySettingsContainer()
{	
	DELETE(iProxyItem);
	delete iBgContext;
}

void CProxySettingsContainer::SizeChanged()
{		
	if ( iBgContext ) {
		iBgContext->SetRect( Rect() );
		if ( &Window() ) {
			iBgContext->SetParentPos( PositionRelativeToScreen() );
		}
	}
}

TInt CProxySettingsContainer::CountComponentControls() const
{	
	return ENumberOfControls;
}

CCoeControl* CProxySettingsContainer::ComponentControl(TInt aIndex) const
{	
	switch(aIndex)
	{	
		case 0:
		{
		return iProxyItem;
		}break;
	}
	
	return NULL;
}

void CProxySettingsContainer::HandleResourceChange(TInt aType)
	{
	switch(aType)
		{
		case KAknsMessageSkinChange:
		//skin changed
			{
			}break;
		case KEikDynamicLayoutVariantSwitch:
			{
			TRect rect;
			AknLayoutUtils::LayoutMetricsRect(AknLayoutUtils::EMainPane,rect);			
			SetRect(rect);
			iProxyItem->SetRect(rect);
			iProxyItem->SizeChanged();			
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
	
TKeyResponse CProxySettingsContainer::OfferKeyEventL(const TKeyEvent& aKeyEvent,TEventCode aType)
{		
	return iProxyItem->OfferKeyEventL (aKeyEvent, aType);	
}

/**
* Asks the setting list to change the currently selected item
*/
void CProxySettingsContainer::ChangeSelectedItemL()
{	
	iProxyItem->ChangeSelectedItemL();
}

void CProxySettingsContainer::DisplayControl()
{		
	//draw control
	//
	DrawNow();
}


TTypeUid::Ptr CProxySettingsContainer::MopSupplyObject(TTypeUid aId)
{
	if (iBgContext)	{
		return MAknsControlContext::SupplyMopObject(aId, iBgContext );
	}
	
	return CCoeControl::MopSupplyObject(aId);
}

void CProxySettingsContainer::Draw(const TRect& aRect) const
{
    CWindowGc& gc = SystemGc();
    gc.Clear(aRect);
    
	MAknsSkinInstance* skin = AknsUtils::SkinInstance();
	MAknsControlContext* cc = AknsDrawUtils::ControlContext( this );	
	
	if( AknsDrawUtils::HasBitmapBackground( skin, cc ) ) {
		AknsDrawUtils::Background( skin, cc, this, gc, aRect );
	}
}
