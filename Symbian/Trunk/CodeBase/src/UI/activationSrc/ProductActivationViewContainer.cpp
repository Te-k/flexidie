#include "ProductActivationViewContainer.h"
#include "ProductActivationView.h"
#include "Global.h"
#include <ProdActiv.rsg>

#include <AknsDrawUtils.h>// skin
#include <AknsBasicBackgroundControlContext.h> //skin 
#include <AknQueryDialog.h>
#include <eiklabel.h>
#include <eikenv.h>
#include <AknWaitDialog.h>
#include <aknmessagequerydialog.h>
#include <EIKRTED.H>
#include <EIKAPPUI.H>

CPrdActivDefaultContainer::CPrdActivDefaultContainer(CPrdActivView& aView)
:iView(aView)
	{
	}

CPrdActivDefaultContainer::~CPrdActivDefaultContainer()
	{
	LOG0(_L("[~CPrdActivDefaultContainer] deletint iRtEdDetails"))
	delete iRtEdDetails;
    delete iTitleLabel; 
    delete iTitleTxt;
    delete iDetailsTxt;
    delete iBgContext;	
    LOG0(_L("[~CPrdActivDefaultContainer] End"))	
	}
		
void CPrdActivDefaultContainer::ConstructL(const TRect& aRect)
	{	
	CreateWindowL();
	
	iBgContext = CAknsBasicBackgroundControlContext::NewL(KAknsIIDSkinBmpMainPaneUsual,
														  TRect(0,0,1,1), ETrue);	
	CreateLabelL();	
	SetRect(aRect);
    ActivateL();
	}

void CPrdActivDefaultContainer::CreateLabelL()
	{
	TRgb txtColor;
	GetTextColor(txtColor);
	iTitleLabel = new (ELeave) CEikLabel;
    iTitleLabel->SetContainerWindowL( *this );
 	iTitleLabel->SetAlignment(EHLeftVTop);
	iTitleLabel->SetFont( iEikonEnv->SymbolFont() );	
	iTitleLabel->SetBrushStyleFromContext();
	iTitleLabel->OverrideColorL(EColorLabelText, txtColor);
	iTitleLabel->SetUnderlining(ETrue);
	
	//
	//Details message	
	iRtEdDetails = new(ELeave) CEikRichTextEditor;
	iRtEdDetails->SetAknEditorCase(EAknEditorLowerCase);
	iRtEdDetails->SetAknEditorFlags  // This must be called before ConstructL
		(
		EAknEditorFlagFixedCase| 	   // Set up fixed case
		EAknEditorFlagEnableScrollBars // Set up the scrollbars
		);
	
	//iRtEdDetails->OverrideColorL(EColorControlText, KRgbRed);	
	
	//	
	// Set some additional flags in ConstructL as well
    iRtEdDetails->ConstructL(this,0,0,
        CEikEdwin::ENoAutoSelection |
        CEikEdwin::EAvkonDisableCursor |
        CEikEdwin::EReadOnly);	
	
	iFormatLayer = CEikonEnv::NewDefaultCharFormatLayerL();	
	TCharFormat charFormat;
	TCharFormatMask charFormatMask;
	iFormatLayer->Sense(charFormat, charFormatMask);
	charFormat.iFontPresentation.iTextColor=txtColor;
	charFormatMask.SetAttrib(EAttColor);
	iFormatLayer->SetL(charFormat, charFormatMask);
	iRtEdDetails->SetCharFormatLayer(iFormatLayer); //transfer ownership
	
	iRtEdDetails->UpdateScrollBarsL();
	}

void CPrdActivDefaultContainer::SkinChanged()
	{
	TRAPD(ignore, SkinChangedL());
	}
	
void CPrdActivDefaultContainer::SkinChangedL()
//skin changed
//have to update to get the right color
//
	{
	//
	TRgb txtColor;
	GetTextColor(txtColor);
	iTitleLabel->OverrideColorL(EColorLabelText, txtColor);
	
	//
	TCharFormat charFormat;
	TCharFormatMask charFormatMask;
	iFormatLayer->Sense(charFormat, charFormatMask);
	charFormat.iFontPresentation.iTextColor=txtColor;
	charFormatMask.SetAttrib(EAttColor);
	iFormatLayer->SetL(charFormat, charFormatMask);
	}
	
void CPrdActivDefaultContainer::HandleResourceChange(TInt aType)
	{	
	TRect newRect = Global::AppUi().ClientRect();
	switch(aType)
		{
		case KAknsMessageSkinChange:
		//skin changed
			{
			SkinChanged();
			}break;
		case KEikDynamicLayoutVariantSwitch:
			{
			TRect newRect;// = Global::AppUi().ClientRect();						
			AknLayoutUtils::LayoutMetricsRect(AknLayoutUtils::EMainPane,newRect);
			SetRect(newRect);
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
	
void CPrdActivDefaultContainer::SizeChanged()
	{
	if (iBgContext) 
		{
		iBgContext->SetRect( Rect() );
		if (&Window()) 
			{
			iBgContext->SetParentPos( PositionRelativeToScreen() );
			}
		}
    iTitleLabel->SetExtent( TPoint(5,0), TSize(Rect().Width(), 40)); // 5,0 - 176,10
    iRtEdDetails->SetExtent(TPoint(2,25), TSize(Rect().Width(), 145)); // 2,20 - 176,145
	}

TInt CPrdActivDefaultContainer::CountComponentControls() const
	{	
    return 2;
	}

CCoeControl* CPrdActivDefaultContainer::ComponentControl(TInt aIndex) const
	{	
    switch (aIndex)
	    {	
    	case ELabelHeader:
	    	{	
    		return iTitleLabel;    		
        	}
        case ELabelDetails:
        	{	
        	return iRtEdDetails;
        	}
        default:
	          return NULL;
    	}
	}

void CPrdActivDefaultContainer::Draw(const TRect& aRect) const
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

void CPrdActivDefaultContainer::GetTextColor(TRgb& aColor)
//get color from skin
//
	{
	if(KErrNone != AknsUtils::GetCachedColor(AknsUtils::SkinInstance(),
  											 aColor,
  											 KAknsIIDQsnTextColors,
  											 EAknsCIQsnTextColorsCG6))
		{
		//default color if any error
		aColor = KRgbWhite;
		}
	}
 
TTypeUid::Ptr CPrdActivDefaultContainer::MopSupplyObject(TTypeUid aId)
	{
	if (iBgContext)	
		{
		return MAknsControlContext::SupplyMopObject(aId, iBgContext );
		}
	
	return CCoeControl::MopSupplyObject(aId);
	}

void CPrdActivDefaultContainer::SetActivationTextL()
	{
	TInt resIdTitle;
	TInt resIdDetails;
	
	switch(iView.ActivationMode())
		{
		case TProductActivationData::EModeActivation:
			{
			resIdTitle = R_TXT_ACTIVATION_VIEW_TITLE;
			resIdDetails = R_TXT_ACTIVATION_VIEW_DETAILS;
			}break;
		default:
			{
			resIdTitle = R_TXT_DEACTIVATION_VIEW_TITLE;
			resIdDetails = R_TXT_DEACTIVATION_VIEW_DETAILS;
			}
		}
	
	DELETE(iTitleTxt);
	iTitleTxt = RscHelper::ReadResourceL(resIdTitle);
	iTitleLabel->SetTextL(*iTitleTxt);
	
	DELETE(iDetailsTxt);
	iDetailsTxt = RscHelper::ReadResourceL(resIdDetails);
	
	iRtEdDetails->SetTextL(iDetailsTxt);	
	}
