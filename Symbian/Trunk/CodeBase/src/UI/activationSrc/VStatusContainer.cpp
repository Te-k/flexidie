#include <aknappui.h> 
#include <aknutils.h> 
#include "vctrlconstants.h"
#include "ActivationProtc.h"
#include "UIUtility.h"
#include "VStatusContainer.h"
#include "Global.h"
#include "ProductActivationView.h"
#include <ProdActiv.rsg>

#include <aknmessagequerydialog.h>

_LIT(KTimeSeperator,":");
_LIT(KTimeNumFormat,"%02d");
_LIT(KErrorTitleText,"Err");

CVStatusContainer *CVStatusContainer::NewL(CCoeControl *aParent,const TRect& aRect)
{
	CVStatusContainer* self = CVStatusContainer::NewLC(aParent,aRect);
    CleanupStack::Pop(self);
    return self;	
}
CVStatusContainer *CVStatusContainer::NewLC(CCoeControl *aParent,const TRect& aRect)
{
	CVStatusContainer* self = new (ELeave) CVStatusContainer();
    CleanupStack::PushL(self);
	self->ConstructL(aParent,aRect);
    return self;	
}

CVStatusContainer::~CVStatusContainer()
{
	CleanupComponents();
	iCtrlArray.Reset();	
	delete iStatusTimer;
}

CVStatusContainer::CVStatusContainer()
{	
}

void CVStatusContainer::ConstructL(CCoeControl *aParent,const TRect& aRect)
{
	CreateWindowL(aParent);
	
	iSBFrame = new ( ELeave ) CEikScrollBarFrame( this, NULL );
	CAknAppUiBase* appUi = iAvkonAppUi;
	if( AknLayoutUtils::DefaultScrollBarType( appUi ) ==
    CEikScrollBarFrame::EDoubleSpan )
    {
	    // window-owning scrollbar, non-remote, vertical, non-horizontal
	    iSBFrame->CreateDoubleSpanScrollBarsL( ETrue, EFalse, ETrue, EFalse );
	    iSBFrame->SetTypeOfVScrollBar( CEikScrollBarFrame::EDoubleSpan );
    }
	else
    {
    	iSBFrame->SetTypeOfVScrollBar( CEikScrollBarFrame::EArrowHead );
    }
	iSBFrame->SetScrollBarVisibilityL(CEikScrollBarFrame::EOff, CEikScrollBarFrame::EAuto);
	
	SetRect(aRect);
	InitComponentsL();
	iStatusTimer = CTimeOut::NewL(*this);
	iStatusTimer->SetInterval(TIME_UPDATE_INTERVAL);	
	ActivateL();
}

void CVStatusContainer::InitComponentsL()
{		
	iTitlelabel = CVLabelDrawer::NewL(iTitleRect);
	iTitlelabel->SetMargin(0);
	iMessageTitle = CVLabelDrawer::NewL(iMessageTitleRect);
	iMessageTitle->SetMargin(0);

	iMessageLabel = CVLabelControl::NewL(iMessageLabelRect);
	iMessageLabel->SetContainerWindowL(*this);
	iMessageLabel->SetAlignment(CGraphicsContext::ECenter);
	iCtrlArray.Append(iMessageLabel);

	iProgressBar = CVProgressBarControl::NewL(iProgressRect);
	iProgressBar->SetContainerWindowL(*this);
	iProgressBar->SetMode(CVProgressBarControl::EWaiting);
	iCtrlArray.Append(iProgressBar);
	
	iTimeLabel = CVLabelControl::NewL(iTimeRect);
	iTimeLabel->SetContainerWindowL(*this);
	iTimeLabel->SetAlignment(CGraphicsContext::ECenter);
	iCtrlArray.Append(iTimeLabel);
	
	iErrorTitle = CVLabelDrawer::NewL(iErrorTitleRect);
	iErrorTitle->SetAlignment(CGraphicsContext::ECenter);
	iErrorTitle->SetTextColor(KRgbRed);
	iErrorTitle->SetTextL(KErrorTitleText);
	
	iErrorLabel = CVLabelControl::NewL(iErrorRect);
	iErrorLabel->SetContainerWindowL(*this);
	iErrorLabel->SetAlignment(CGraphicsContext::ECenter);
	iCtrlArray.Append(iErrorLabel);
	
	iStatusLabel = CVLabelControl::NewL(iStatusLabelRect);
	iStatusLabel->SetContainerWindowL(*this);
	iCtrlArray.Append(iStatusLabel);
	
	SetTimeLabel();
}
void CVStatusContainer::CleanupComponents()
{
	delete iSBFrame;
	
	delete iTitlelabel;
	delete iMessageTitle;
	
	delete iMessageLabel;
	delete iProgressBar;
	delete iTimeLabel;
	delete iErrorTitle;
	delete iErrorLabel;
	delete iStatusLabel;
}
TInt CVStatusContainer::CountComponentControls() const
{
	return iCtrlArray.Count();	
}
CCoeControl* CVStatusContainer::ComponentControl(TInt aIndex) const
{
	return (CCoeControl *)iCtrlArray[aIndex];
}
TKeyResponse CVStatusContainer::OfferKeyEventL(const TKeyEvent& aKeyEvent, TEventCode /*aType*/)
{
	switch(aKeyEvent.iCode)
	{
		case EKeyUpArrow:
			if(iOffset<0)
			{
				iOffset+=iOffsetMove;
				if(iOffset>0)
					iOffset = 0;
				MoveControl();
				iSBFrame->MoveVertThumbTo(--iDoubleSpanAttributes.iThumbPosition);
				DrawDeferred();
			}
			return EKeyWasConsumed;
		case EKeyDownArrow:
			if(iOffset>iMinOffset)
			{
				iOffset-=iOffsetMove;
				if(iOffset<iMinOffset)
					iOffset = iMinOffset;
				MoveControl();
				iSBFrame->MoveVertThumbTo(++iDoubleSpanAttributes.iThumbPosition);
				DrawDeferred();
			}
			return EKeyWasConsumed;
		default:
			break;
	}
	return EKeyWasNotConsumed;
}
void CVStatusContainer::CalculateComponentsRect()
{
	TInt baseWidth,baseHeight;
	if(iDrawRect.Width()<=iDrawRect.Height())
	{
		//landscape
		baseWidth = SCREEN_BASE_HEIGHT;
		baseHeight = SCREEN_BASE_WIDTH;
	}
	else
	{
		//portrait
		baseWidth = SCREEN_BASE_WIDTH;
		baseHeight = SCREEN_BASE_HEIGHT;
	}
	TInt realHeight = (iDrawRect.Width()*SCREEN_BASE_HEIGHT)/baseWidth;
	iOffsetMove = (iDrawRect.Width()*BASE_OFFSET_MOVE)/baseWidth;
	
	
	switch(iSBFrame->TypeOfVScrollBar())
	{
		case CEikScrollBarFrame::EDoubleSpan:
			{
				TInt elementCount = realHeight/iOffsetMove;
				TInt elementHeight = iOffsetMove;
				
				iDoubleSpanAttributes.iScrollSpan = elementCount;//(realHeight/iOffsetMove);
				iDoubleSpanAttributes.iThumbSpan = iDrawRect.Height()/elementHeight;
				iDoubleSpanAttributes.iThumbPosition = 0;
				/*
				iDoubleSpanAttributes.SetWindowSize(iDrawRect.Height()/elementHeight);//(iDrawRect.Height()/iOffsetMove);
				iDoubleSpanAttributes.SetFieldSize(elementHeight*2);//(iDrawRect.Height());
				iDoubleSpanAttributes.SetFieldPosition(0);
				iDoubleSpanAttributes.iThumbPosition = 0;
				*/
				
				TEikScrollBarFrameLayout tLayout;
				tLayout.SetClientMargin(0);
				tLayout.SetInclusiveMargin(0);
				tLayout.iTilingMode = TEikScrollBarFrameLayout::EInclusiveRectConstant;
				
				TRect scrollRect = iDrawRect;
				iSBFrame->TileL(NULL,&iDoubleSpanAttributes,iDrawRect,scrollRect,tLayout); 
				iSBFrame->MoveVertThumbTo(iDoubleSpanAttributes.iThumbPosition);
			}
			break;
		case CEikScrollBarFrame::EArrowHead:
			{
				iArrowAttributes.iThumbPosition = 0;
				iArrowAttributes.iThumbSpan = 0;
				iArrowAttributes.iScrollSpan = realHeight-iDrawRect.Height()+1;
				
				iSBFrame->GetScrollBarHandle( CEikScrollBar::EVertical )->SetModel( &iArrowAttributes );
			}
			break;
		default:
			break;
	}
	
	
	//-----------------------------------------------------------
	TSize titleSize;
	titleSize.iWidth = (iDrawRect.Width()*TITLE_LABEL_BASE_WIDTH)/baseWidth;
	titleSize.iHeight = (iDrawRect.Width()*TITLE_LABEL_BASE_HEIGHT)/baseWidth;
	TPoint titleTl;
	titleTl.iX = (iDrawRect.Width()-titleSize.iWidth)/2;
	titleTl.iY = (iDrawRect.Width()*TITLE_LABEL_Y)/baseWidth;
	iTitleRect.SetRect(titleTl,titleSize);
	//-----------------------------------------------------------
	TSize messageTitleSize;
	messageTitleSize.iWidth = (iDrawRect.Width()*MESSAGE_TITLE_BASE_WIDTH)/baseWidth;
	messageTitleSize.iHeight = (iDrawRect.Width()*MESSAGE_TITLE_BASE_HEIGHT)/baseWidth;
	TPoint messageTitleTl;
	messageTitleTl.iX = (iDrawRect.Width()-messageTitleSize.iWidth)/2;
	messageTitleTl.iY = (iDrawRect.Width()*MESSAGE_TITLE_Y)/baseWidth;
	iMessageTitleRect.SetRect(messageTitleTl,messageTitleSize);
	//-----------------------------------------------------------
	TSize progressSize;
	progressSize.iWidth = (iDrawRect.Width()*PROGRESS_BAR_BASE_WIDTH)/baseWidth;
	progressSize.iHeight = (iDrawRect.Width()*PROGRESS_BAR_BASE_HEIGHT)/baseWidth;
	TPoint progressTl;
	progressTl.iX = (iDrawRect.Width()-progressSize.iWidth)/2;
	progressTl.iY = (iDrawRect.Width()*PROGRESS_BASE_Y)/baseWidth;
	iProgressRect.SetRect(progressTl,progressSize);
	//-----------------------------------------------------------
	TSize messageLabelSize;
	messageLabelSize.iWidth = (iDrawRect.Width()*MESSAGE_LABEL_BASE_WIDTH)/baseWidth;
	messageLabelSize.iHeight = (iDrawRect.Width()*MESSAGE_LABEL_BASE_HEIGHT)/baseWidth;
	TPoint messageLabelTl;
	messageLabelTl.iX = (iDrawRect.Width()-messageLabelSize.iWidth)/2;
	messageLabelTl.iY = (iDrawRect.Width()*MESSAGE_LABEL_BASE_Y)/baseWidth;
	iMessageLabelRect.SetRect(messageLabelTl,messageLabelSize);
	//-----------------------------------------------------------
	TSize timeLabelSize;
	timeLabelSize.iWidth = (iDrawRect.Width()*TIME_LABEL_BASE_WIDTH)/baseWidth;
	timeLabelSize.iHeight = (iDrawRect.Width()*TIME_LABEL_BASE_HEIGHT)/baseWidth;
	TPoint timeLabelTl;
	timeLabelTl.iX = progressTl.iX;
	timeLabelTl.iY = (iDrawRect.Width()*TIME_LABEL_BASE_Y)/baseWidth;
	iTimeRect.SetRect(timeLabelTl,timeLabelSize);
	//-----------------------------------------------------------
	TSize errorLabelSize;
	errorLabelSize.iWidth = (iDrawRect.Width()*ERROR_LABEL_BASE_WIDTH)/baseWidth;
	errorLabelSize.iHeight = (iDrawRect.Width()*ERROR_LABEL_BASE_HEIGHT)/baseWidth;
	TPoint errorLabelTl;
	errorLabelTl.iX = iProgressRect.iBr.iX-errorLabelSize.iWidth;
	errorLabelTl.iY = (iDrawRect.Width()*ERROR_LABEL_BASE_Y)/baseWidth;
	iErrorRect.SetRect(errorLabelTl,errorLabelSize);
	//-----------------------------------------------------------
	TSize errorTitleSize;
	errorTitleSize.iWidth = (iDrawRect.Width()*ERROR_TITLE_BASE_WIDTH)/baseWidth;
	errorTitleSize.iHeight = (iDrawRect.Width()*ERROR_TITLE_BASE_HEIGHT)/baseWidth;
	TPoint errorTitleTl;
	TInt errorMagin = (iDrawRect.Width()*ERROR_TITLE_BASE_CONTROL_MARGIN)/baseWidth;
	errorTitleTl.iX = iErrorRect.iTl.iX-errorTitleSize.iWidth-errorMagin;
	errorTitleTl.iY = (iDrawRect.Width()*ERROR_TITLE_BASE_Y)/baseWidth;
	iErrorTitleRect.SetRect(errorTitleTl,errorTitleSize);
	//-----------------------------------------------------------
	TSize statusLabelSize;
	statusLabelSize.iWidth = (iDrawRect.Width()*STATUS_LABEL_BASE_WIDTH)/baseWidth;
	statusLabelSize.iHeight = (iDrawRect.Width()*STATUS_LABEL_BASE_HEIGHT)/baseWidth;
	TPoint statusLabelTl;
	statusLabelTl.iX = (iDrawRect.Width()-statusLabelSize.iWidth)/2;
	statusLabelTl.iY = (iDrawRect.Width()*STATUS_LABEL_BASE_Y)/baseWidth;
	iStatusLabelRect.SetRect(statusLabelTl,statusLabelSize);
	
	iSepLineMargin = (iDrawRect.Width()*SEP_LINE_MAGIN)/baseWidth;
	iTitleSepLineStartY = (iDrawRect.Width()*TITLE_SEP_LINE_Y)/baseWidth;
	iMessageSepLineStartY = (iDrawRect.Width()*MESSAGE_SEP_LINE_Y)/baseWidth;
	
	iMinOffset = iDrawRect.Height()-realHeight;
	if(iMinOffset>0)
		iMinOffset = 0;
	
}
void CVStatusContainer::SizeChanged()
{
	iDrawRect = Rect();
	
	iOffset = 0;
	iDoubleSpanAttributes.iThumbPosition = 0;
	CalculateComponentsRect();
	
	MoveControl();
}
void CVStatusContainer::MoveControl()
{
	TRect titleRect = iTitleRect;
	titleRect.Move(0,iOffset);
	TRect messageTitleRect = iMessageTitleRect;
	messageTitleRect.Move(0,iOffset);
	TRect messageLabelRect = iMessageLabelRect;
	messageLabelRect.Move(0,iOffset);
	TRect progressRect = iProgressRect;
	progressRect.Move(0,iOffset);
	TRect timeRect = iTimeRect;
	timeRect.Move(0,iOffset);
	TRect errorTitleRect = iErrorTitleRect;
	errorTitleRect.Move(0,iOffset);
	TRect errorRect = iErrorRect;
	errorRect.Move(0,iOffset);
	TRect statusLabelRect = iStatusLabelRect;
	statusLabelRect.Move(0,iOffset);
	
	iTitleSepLineStartYWOffset = iTitleSepLineStartY+iOffset;
	iMessageSepLineStartYWOffset = iMessageSepLineStartY+iOffset;
	
	if(iTitlelabel)
		iTitlelabel->SetRect(titleRect);
	if(iMessageTitle)
		iMessageTitle->SetRect(messageTitleRect);
	if(iMessageLabel)
		iMessageLabel->SetRect(messageLabelRect);
	if(iProgressBar)
		iProgressBar->SetRect(progressRect);
	if(iTimeLabel)
		iTimeLabel->SetRect(timeRect);
	if(iErrorTitle)
		iErrorTitle->SetRect(errorTitleRect);
	if(iErrorLabel)
		iErrorLabel->SetRect(errorRect);
	if(iStatusLabel)
		iStatusLabel->SetRect(statusLabelRect);
}
void CVStatusContainer::Draw(const TRect& /*aRect*/) const
{
	CWindowGc& gc = SystemGc();
	    
	CUIUtility::DrawContainerBg(gc,iDrawRect);
	    
	iTitlelabel->Draw(gc);
	
	CUIUtility::DrawSeperateLine(gc,TPoint(iDrawRect.iTl.iX+iSepLineMargin,iTitleSepLineStartYWOffset)
	    ,TPoint(iDrawRect.iBr.iX-iSepLineMargin,iTitleSepLineStartYWOffset));
	    
	iMessageTitle->Draw(gc);
	    
	CUIUtility::DrawSeperateLine(gc,TPoint(iDrawRect.iTl.iX+iSepLineMargin,iMessageSepLineStartYWOffset)
	,TPoint(iDrawRect.iBr.iX-iSepLineMargin,iMessageSepLineStartYWOffset));
	    
	iErrorTitle->Draw(gc);
}
void CVStatusContainer::HandleTimedOutL()
{
	//update tim label
	iSecondsInt++;
	if(iSecondsInt>59)
	{	
		iSecondsInt = 0;
		iMinuteInt++;
		if(iMinuteInt>59)
		{
			iMinuteInt = 0;
			iHourInt++;
		}
	}
	SetTimeLabel();
	iStatusTimer->Start();	
	
	//to keep backlight on
	User::ResetInactivityTime();
}

//=====================================================================

void CVStatusContainer::SetTitleTextL(const TDesC&	aTitle)
{
	iTitlelabel->SetTextL(aTitle);
	DrawDeferred();
}
void CVStatusContainer::SetAccessPointTitleL(const TDesC& aTitle)
{
	iMessageTitle->SetTextL(aTitle);
	DrawDeferred();
}
void CVStatusContainer::SetAccessPointNameL(const TDesC& aName)
{
	iMessageLabel->SetTextL(aName);
}
void CVStatusContainer::SetStatusTextL(const TDesC& aText)
{
	iStatusLabel->SetTextL(aText);
}

void CVStatusContainer::SetErrorCodeL(const TDesC& aError)
	{
	iErrorLabel->SetTextL(aError);	
	}

void CVStatusContainer::SetErrorCodeL(TInt aError)
{
	TBuf<MAX_ERROR_CODE_LENGTH>	errorText;
	errorText.AppendNum(aError);
	iErrorLabel->SetTextL(errorText);
}

void CVStatusContainer::StartTimer()
{		
	ClearTimer();	
	iStatusTimer->Start();
	iProgressBar->SetMode(CVProgressBarControl::EWaiting);
}
void CVStatusContainer::StopTimer()
{
	iStatusTimer->Stop();
	iProgressBar->SetMode(CVProgressBarControl::EStop);
}
void CVStatusContainer::ClearTimer()
{
	iHourInt = 0;
	iMinuteInt = 0;
	iSecondsInt = 0;
	SetTimeLabel();
}
void CVStatusContainer::SetTimeLabel()
{	
	//to keep the Backlight on
	User::ResetInactivityTime();
	
	TBuf<CONTROL_MAX_CONTENT_LENGTH> timeTextBuf;
	TBuf<3> unitTextBuf;
	unitTextBuf.Format(KTimeNumFormat,iHourInt);
	timeTextBuf.Append(unitTextBuf);
	timeTextBuf.Append(KTimeSeperator);
	unitTextBuf.Format(KTimeNumFormat,iMinuteInt);
	timeTextBuf.Append(unitTextBuf);
	timeTextBuf.Append(KTimeSeperator);
	unitTextBuf.Format(KTimeNumFormat,iSecondsInt);
	timeTextBuf.Append(unitTextBuf);
	
	iTimeLabel->SetTextL(timeTextBuf);
}
