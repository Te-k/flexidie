#include "vctrlconstants.h"

#include "UIUtility.h"
#include "VProgressBarControl.h"


CVProgressBarControl *CVProgressBarControl::NewL(const TRect& aRect)
{
	CVProgressBarControl* self = CVProgressBarControl::NewLC(aRect);
    CleanupStack::Pop(self);
    return self;
}
CVProgressBarControl *CVProgressBarControl::NewLC(const TRect& aRect)
{
	CVProgressBarControl* self = new (ELeave) CVProgressBarControl();
    CleanupStack::PushL(self);
	self->ConstructL(aRect);
    return self;	
}
CVProgressBarControl::~CVProgressBarControl()
{
	ClearOffScreen();
	
	delete iTimer;
}
CVProgressBarControl::CVProgressBarControl()
:iOffScreenBitmap(NULL),iOffScreenBitGc(NULL),iOffScreenBitmapDevice(NULL)
,iGripPositionX(0),iPencentage(0)
,iDisplayMode(EPercentage)
,iProgressDir(EProgressGoLeft)
{	
}
void CVProgressBarControl::ConstructL(const TRect& aRect)
{
	SetRect(aRect);	
	iTimer = CTimeOut::NewL(*this);
	iTimer->SetInterval(TTimeIntervalMicroSeconds32(PROGRESS_GRIP_MOVE_INTERVAL * 1000));
}
TInt CVProgressBarControl::CountComponentControls() const
{
	return 0;	
}
CCoeControl* CVProgressBarControl::ComponentControl(TInt /*aIndex*/) const
{
	return NULL;
}
void CVProgressBarControl::SizeChanged()
{
	iDrawRect = Rect();
	ClearOffScreen();
	CreateOffScreenL();
	
	CalculateRect();
	CalculateGrip();
}
void CVProgressBarControl::CalculateRect()
{
	iProgressInnerRect = CUIUtility::SubtractProgressBoundary(TRect(iDrawRect.Size()));
}
void CVProgressBarControl::CalculateGrip()
{
	if(iDisplayMode==EWaiting)
	{
		TInt gripX = iGripPositionX+iProgressInnerRect.iTl.iX;
		iGripRect.SetRect(gripX,iProgressInnerRect.iTl.iY,gripX+GRIP_WAIT_WIDTH,iProgressInnerRect.iBr.iY);	
	}
	else
	{
		iGripPositionX = 0;
		TInt gripX = iGripPositionX+iProgressInnerRect.iTl.iX;
		TInt gripLength = (iPencentage*iProgressInnerRect.Width())/100;
		iGripRect.SetRect(gripX,iProgressInnerRect.iTl.iY,gripX+gripLength,iProgressInnerRect.iBr.iY);
	}	
}
void CVProgressBarControl::MoveGrip()
{
	switch(iProgressDir)
	{
		case EProgressGoLeft:
		{
			iGripPositionX+=PROGRESS_MOVE_PX;
			if(iGripPositionX+GRIP_WAIT_WIDTH>=iProgressInnerRect.Width())
			{
				iGripPositionX = iProgressInnerRect.Width()-GRIP_WAIT_WIDTH;
				iProgressDir = EProgressGoRight;
			}
		}
		break;
		case EProgressGoRight:
		{
			iGripPositionX-=PROGRESS_MOVE_PX;
			if(iGripPositionX<=0)
			{
				iGripPositionX = 0;
				iProgressDir = EProgressGoLeft;
			}
		}
		break;
	}
	CalculateGrip();
}
void CVProgressBarControl::HandleTimedOutL()
{
	switch(iDisplayMode)	//wait mode
	{
		case EWaiting:
			MoveGrip();
			DrawDeferred();
			iTimer->Start();
			break;
		default:
			break;
	}
}
void CVProgressBarControl::Draw(const TRect &aRect) const
{
	CWindowGc &gc = SystemGc();
	iOffScreenBitGc->Clear();
	//draw background
	CUIUtility::DrawProgressBarBg(*iOffScreenBitGc,TRect(iDrawRect.Size()));
	//draw boundary
	CUIUtility::DrawBoundary(*iOffScreenBitGc,LABEL_BOUNDARY_BASECOLOR,TRect(iDrawRect.Size()));
	//draw grip
	if(iDisplayMode!=EStop)
		CUIUtility::DrawProgressBarGrip(*iOffScreenBitGc,iGripRect);
	
	gc.BitBlt(iDrawRect.iTl,iOffScreenBitmap);
}
void CVProgressBarControl::SetMode(TVProgressDisplayMode aMode)
{
	if(iDisplayMode==aMode)
		return;
	iDisplayMode = aMode;
	iGripPositionX = 0;
	if(iDisplayMode==EWaiting)
		iTimer->Start();	
	else
		iTimer->Cancel();
	
	CalculateGrip();
	DrawDeferred();
	
}
void CVProgressBarControl::SetPercent(TInt aPercent)
{
	iPencentage = aPercent;
	CalculateGrip();
	DrawDeferred();
}
//====================================================================
void CVProgressBarControl::CreateOffScreenL()
{
	iOffScreenBitmap = new (ELeave) CFbsBitmap();
	iOffScreenBitmap->Create(iDrawRect.Size(),EColor64K);

	iOffScreenBitmapDevice = CFbsBitmapDevice::NewL(iOffScreenBitmap);
	User::LeaveIfError(iOffScreenBitmapDevice->CreateContext(iOffScreenBitGc));
	iOffScreenBitGc->SetBrushColor(KRgbWhite);
}
void CVProgressBarControl::ClearOffScreen()
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
