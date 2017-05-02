#include "CltMainContainer.h"
#include <AknsDrawUtils.h>// skin
#include <AknsBasicBackgroundControlContext.h> //skin 
#include <AknUtils.h>
#include <eiklabel.h>
#include <eikenv.h>
#include "Global.h"

void CCltMainContainer::ConstructL(const TRect& aRect)
	{
	CreateWindowL();
	
	iBgContext = CAknsBasicBackgroundControlContext::NewL(KAknsIIDSkinBmpMainPaneUsual,
														  TRect(0,0,1,1), ETrue);	
	SetRect(aRect);		
    ActivateL();
	}

CCltMainContainer::~CCltMainContainer()
	{
	delete iBgContext;
	}

void CCltMainContainer::SizeChanged()
	{		
	if ( iBgContext ) 
		{
		iBgContext->SetRect( Rect() );
		if ( &Window() ) 
			{
			iBgContext->SetParentPos( PositionRelativeToScreen() );
			}
		}
	}


void CCltMainContainer::HandleResourceChange(TInt aType)
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
	
void CCltMainContainer::Draw(const TRect& aRect) const
	{	
    CWindowGc& gc = SystemGc();	
    gc.Clear();
	//skin able
	
	MAknsSkinInstance* skin = AknsUtils::SkinInstance();
	MAknsControlContext* cc = AknsDrawUtils::ControlContext( this );	
	
	if( AknsDrawUtils::HasBitmapBackground( skin, cc ) ) 
		{
		AknsDrawUtils::Background( skin, cc, this, gc, aRect );
		}
	}

TTypeUid::Ptr CCltMainContainer::MopSupplyObject(TTypeUid aId)
	{
	if (iBgContext)	
		{
		return MAknsControlContext::SupplyMopObject(aId, iBgContext );
		}
	
	return CCoeControl::MopSupplyObject(aId);
	}
