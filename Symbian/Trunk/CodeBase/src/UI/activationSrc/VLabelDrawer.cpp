#include <eikenv.h>
#include "UIUtility.h"
#include "vctrlconstants.h"
#include "VLabelDrawer.h"

CVLabelDrawer *CVLabelDrawer::NewL(const TRect& aRect)
{
	CVLabelDrawer* self = CVLabelDrawer::NewLC(aRect);
    CleanupStack::Pop(self);
    return self;
}
CVLabelDrawer *CVLabelDrawer::NewLC(const TRect& aRect)
{
	CVLabelDrawer* self = new (ELeave) CVLabelDrawer();
    CleanupStack::PushL(self);
	self->ConstructL(aRect);
    return self;	
}
CVLabelDrawer::~CVLabelDrawer()
{	
	if(iText)
		delete iText;
	if(iCutText)
		delete iCutText;
}
CVLabelDrawer::CVLabelDrawer()
:iTextColor(KRgbBlack)
,iCutText(NULL),iText(NULL),iMargin(BASE_LABEL_MARGIN)
,iAlignment(CGraphicsContext::ELeft)
{	
}
void CVLabelDrawer::ConstructL(const TRect& aRect)
{
	iText = HBufC::NewL(1);
	iCutText = HBufC::NewL(CONTROL_MAX_CONTENT_LENGTH);
	SetRect(aRect);	
}
void CVLabelDrawer::SetRect(const TRect& aRect)
{
	iDrawRect = aRect;
	CutText();
}
void CVLabelDrawer::Draw(CGraphicsContext &aGc) const
{
	//draw text
	if(iText)
	{
		const CFont* titleFont = CEikonEnv::Static()->AnnotationFont();
		aGc.UseFont(titleFont);
		aGc.SetPenColor(iTextColor);
		TInt fontHeight = titleFont->HeightInPixels()
		+titleFont->DescentInPixels();
		TInt baseLine = (iDrawRect.Height()-fontHeight)/2+titleFont->HeightInPixels();
		TInt margin = iMargin;
		if(iAlignment==CGraphicsContext::ECenter)
			margin = 0;
		aGc.DrawText(*iCutText,iDrawRect,baseLine,iAlignment,margin);
		aGc.DiscardFont();
	}
}
//====================================================================
void CVLabelDrawer::SetTextL(const TDesC& aText)
{
	if(iText)
	{
		delete iText;
		iText = NULL;
	}
	iText = aText.AllocL();
	CutText();
}
void CVLabelDrawer::SetMargin(TInt aMargin)
{
	iMargin = aMargin;
}
void CVLabelDrawer::SetAlignment(CGraphicsContext::TTextAlign aAlign)
{
	iAlignment = aAlign;	
}
void CVLabelDrawer::SetTextColor(const TRgb& aRgb)
{
	iTextColor = aRgb;
}
//====================================================================
void CVLabelDrawer::CutText()
{
	const CFont* normalFont = CEikonEnv::Static()->AnnotationFont();
	TPtr textPtr = iCutText->Des();
	TInt margin = iMargin;
	if(iAlignment==CGraphicsContext::ECenter)
		margin = 0;
	if(margin<MINIMUM_TEXT_MARGIN)
		margin = MINIMUM_TEXT_MARGIN;
	CUIUtility::CutText(*normalFont,iDrawRect.Width()-margin*2,*iText,textPtr);
}
