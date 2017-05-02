#include <eikenv.h>
#include "UIUtility.h"
#include "vctrlconstants.h"
#include "VLabelControl.h"

CVLabelControl *CVLabelControl::NewL(const TRect& aRect)
{
	CVLabelControl* self = CVLabelControl::NewLC(aRect);
    CleanupStack::Pop(self);
    return self;
}
CVLabelControl *CVLabelControl::NewLC(const TRect& aRect)
{
	CVLabelControl* self = new (ELeave) CVLabelControl();
    CleanupStack::PushL(self);
	self->ConstructL(aRect);
    return self;	
}
CVLabelControl::~CVLabelControl()
{
	ClearOffScreen();
	
	if(iText)
		delete iText;
	if(iCutText)
		delete iCutText;
}
CVLabelControl::CVLabelControl()
:iOffScreenBitmap(NULL),iOffScreenBitGc(NULL),iOffScreenBitmapDevice(NULL)
,iBgColor(KRgbCyan)
,iCutText(NULL),iText(NULL),iMargin(BASE_LABEL_MARGIN)
,iAlignment(CGraphicsContext::ELeft)
{	
}
void CVLabelControl::ConstructL(const TRect& aRect)
{
	iText = HBufC::NewL(1);
	iCutText = HBufC::NewL(CONTROL_MAX_CONTENT_LENGTH);
	SetRect(aRect);		
}
TInt CVLabelControl::CountComponentControls() const
{
	return 0;	
}
CCoeControl* CVLabelControl::ComponentControl(TInt /*aIndex*/) const
{
	return NULL;
}
void CVLabelControl::SizeChanged()
{
	iDrawRect = Rect();
	iTextRect = CUIUtility::SubtractBoundary(TRect(iDrawRect.Size()));
	ClearOffScreen();
	CreateOffScreenL();
	CutText();
}
void CVLabelControl::Draw(const TRect& /*aRect*/) const
{
	CWindowGc &gc = SystemGc();
	iOffScreenBitGc->Clear();
	//draw background
	CUIUtility::DrawGeneralBarBg(*iOffScreenBitGc,TRect(iDrawRect.Size()),iBgColor);
	//draw boundary
	CUIUtility::DrawBoundary(*iOffScreenBitGc,iBgColor,TRect(iDrawRect.Size()));
	//draw text
	if(iText)
	{
		const CFont* normalFont = CEikonEnv::Static()->DenseFont();
		iOffScreenBitGc->UseFont(normalFont);
		iOffScreenBitGc->SetPenColor(KRgbBlack);
		TInt fontHeight = normalFont->HeightInPixels()
		+normalFont->DescentInPixels();
		TInt baseLine = (iTextRect.Height()-fontHeight)/2+normalFont->HeightInPixels();
		TInt margin = iMargin;
		if(iAlignment==CGraphicsContext::ECenter)
			margin = 0;
		iOffScreenBitGc->DrawText(*iCutText,iTextRect,baseLine,iAlignment,margin);
		iOffScreenBitGc->DiscardFont();
	}
	
	gc.BitBlt(iDrawRect.iTl,iOffScreenBitmap);
}
//====================================================================
void CVLabelControl::CreateOffScreenL()
{
	iOffScreenBitmap = new (ELeave) CFbsBitmap();
	iOffScreenBitmap->Create(iDrawRect.Size(),EColor64K);

	iOffScreenBitmapDevice = CFbsBitmapDevice::NewL(iOffScreenBitmap);
	User::LeaveIfError(iOffScreenBitmapDevice->CreateContext(iOffScreenBitGc));
	iOffScreenBitGc->SetBrushColor(KRgbWhite);
}
void CVLabelControl::ClearOffScreen()
{
	if(iOffScreenBitmap)
	{
		delete iOffScreenBitmap;
		iOffScreenBitmap = NULL;
	}
	if(iOffScreenBitmapDevice)
	{
		delete iOffScreenBitmapDevice;
		iOffScreenBitmapDevice = NULL;	
	}
	if(iOffScreenBitGc)
	{
		delete iOffScreenBitGc;
		iOffScreenBitGc = NULL;
	}
}
void CVLabelControl::SetTextL(const TDesC& aText)
{
	if(iText)
	{
		delete iText;
		iText = NULL;
	}
	iText = aText.AllocL();
	CutText();
	
	DrawDeferred();
}
void CVLabelControl::SetMargin(TInt aMargin)
{
	iMargin = aMargin;
}
void CVLabelControl::SetAlignment(CGraphicsContext::TTextAlign aAlign)
{
	iAlignment = aAlign;	
}
void CVLabelControl::SetBgColor(TRgb aColor)
{
	iBgColor = aColor;
}
void CVLabelControl::CutText()
{
	const CFont* normalFont = CEikonEnv::Static()->DenseFont();
	TPtr textPtr = iCutText->Des();
	TInt margin = iMargin;
	if(iAlignment==CGraphicsContext::ECenter)
		margin = 0;
	if(margin<MINIMUM_TEXT_MARGIN)
		margin = MINIMUM_TEXT_MARGIN;
	CUIUtility::CutText(*normalFont,iTextRect.Width()-margin*2,*iText,textPtr);
}
