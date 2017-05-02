#include "UIUtility.h"

#define BOUNDARY_WIDTH	2
#define DARK_ADD_VALUE_1	70
#define DARK_ADD_VALUE_2	35
#define BASE_COLOR_BOUNDARY		1


#define DLG_BOUNDARY_WIDTH	3
#define DIALOG_DARK_COLOR	TRgb(90,72,255)
#define DIALOG_LIGHT_COLOR1	TRgb(150,138,255)
#define DIALOG_LIGHT_COLOR2	TRgb(176,168,255)
#define DIALOG_LIGHT_COLOR3	TRgb(120,108,255)
#define DIALOG_LIGHT_COLOR4	TRgb(160,150,255)

#define DLG_BG_START_COLOR_R	209
#define DLG_BG_START_COLOR_G	204
#define DLG_BG_START_COLOR_B	255

#define DLG_BG_REPEAT_LINE		2
#define GRAD_BG_REPEAT_LINE		2

#define CONT_BG_REPEAT_LINE		4

#define PROGRESS_GRIP_START_COLOR_R		255
#define PROGRESS_GRIP_START_COLOR_G		128
#define PROGRESS_GRIP_START_COLOR_B		0
#define	PROGRESS_GRIP_REPEAT_LINE			1
#define	PROGRESS_GRIP_REDUCE_AMOUNT			5
#define GRIP_DARK_COLOR1					TRgb(149,74,0)
#define GRIP_DARK_COLOR2					TRgb(202,101,0)
#define PROGRESS_BOUND_WIDTH			2

#define SEP_LINE_COLOR			TRgb(150,138,255)

_LIT(KTextCont,"...");

void CUIUtility::DrawBoundary(CGraphicsContext &iGc,TRgb baseColor,const TRect& aRect)
{
	iGc.SetPenStyle(CGraphicsContext::ESolidPen);
	iGc.SetPenSize(TSize(BASE_COLOR_BOUNDARY,BASE_COLOR_BOUNDARY));
	iGc.SetPenColor(baseColor);
	iGc.SetBrushStyle(CGraphicsContext::ENullBrush);

	iGc.DrawRect(aRect);
	TInt iRed = baseColor.Red()-DARK_ADD_VALUE_1;
	if(iRed<0)
		iRed = 0;
	TInt iGreen = baseColor.Green()-DARK_ADD_VALUE_1;
	if(iGreen<0)
		iGreen = 0;
	TInt iBlue = baseColor.Blue()-DARK_ADD_VALUE_1;
	if(iBlue<0)
		iBlue = 0;
	
	iGc.SetPenColor(TRgb(iRed,iGreen,iBlue)); //darker color
	iGc.DrawLine(TPoint(aRect.iTl.iX+BASE_COLOR_BOUNDARY,aRect.iTl.iY+BASE_COLOR_BOUNDARY),TPoint(aRect.iBr.iX-BASE_COLOR_BOUNDARY,aRect.iTl.iY+BASE_COLOR_BOUNDARY));
	iGc.DrawLine(TPoint(aRect.iTl.iX+BASE_COLOR_BOUNDARY,aRect.iTl.iY+BASE_COLOR_BOUNDARY),TPoint(aRect.iTl.iX+BASE_COLOR_BOUNDARY,aRect.iBr.iY-BASE_COLOR_BOUNDARY));
	iGc.SetPenColor(KRgbWhite);
	iGc.DrawLine(TPoint(aRect.iBr.iX-BOUNDARY_WIDTH,aRect.iTl.iY+BASE_COLOR_BOUNDARY),TPoint(aRect.iBr.iX-BOUNDARY_WIDTH,aRect.iBr.iY-BASE_COLOR_BOUNDARY));
	iGc.DrawLine(TPoint(aRect.iTl.iX+BASE_COLOR_BOUNDARY,aRect.iBr.iY-BOUNDARY_WIDTH),TPoint(aRect.iBr.iX-BASE_COLOR_BOUNDARY,aRect.iBr.iY-BOUNDARY_WIDTH));

	iRed = baseColor.Red()-DARK_ADD_VALUE_2;
	if(iRed<0)
		iRed = 0;
	iGreen = baseColor.Green()-DARK_ADD_VALUE_2;
	if(iGreen<0)
		iGreen = 0;
	iBlue = baseColor.Blue()-DARK_ADD_VALUE_2;
	if(iBlue<0)
		iBlue = 0;
	iGc.SetPenColor(TRgb(iRed,iGreen,iBlue)); //dark color
	iGc.Plot(TPoint(aRect.iBr.iX-BOUNDARY_WIDTH,aRect.iTl.iY+BASE_COLOR_BOUNDARY));
	iGc.Plot(TPoint(aRect.iTl.iX+BASE_COLOR_BOUNDARY,aRect.iBr.iY-BOUNDARY_WIDTH));
	
}
void CUIUtility::DrawBoundary2(CGraphicsContext &iGc,TRgb baseColor,const TRect& aRect)
{
	iGc.SetPenColor(KRgbWhite);
	iGc.SetBrushStyle(CGraphicsContext::ENullBrush);
	TRect rect2(aRect.iTl.iX+1,aRect.iTl.iY+1,aRect.iBr.iX+1,aRect.iBr.iY+1);
	iGc.DrawRect(rect2);
	iGc.SetPenColor(baseColor);
	iGc.DrawRect(aRect);
}
TRect CUIUtility::SubtractBoundary(const TRect& aRect)
{
	TRect outRect = aRect;
	outRect.iTl.iX += BOUNDARY_WIDTH;
	outRect.iBr.iX -= BOUNDARY_WIDTH;
	outRect.iTl.iY += BOUNDARY_WIDTH;
	outRect.iBr.iY -= BOUNDARY_WIDTH;
	return outRect;
}
void CUIUtility::DrawRoundRect(CFbsBitGc &iGc,const TRect& aRect)
{
	iGc.DrawLine(TPoint(aRect.iTl.iX+2,aRect.iTl.iY),TPoint(aRect.iBr.iX-2,aRect.iTl.iY));
	iGc.DrawLine(TPoint(aRect.iTl.iX+1,aRect.iTl.iY+1),TPoint(aRect.iBr.iX-1,aRect.iTl.iY+1));
	for(TInt i=aRect.iTl.iY+2;i<=aRect.iBr.iY-2;i++)
	{
		iGc.DrawLine(TPoint(aRect.iTl.iX,i),TPoint(aRect.iBr.iX,i));
	}
	iGc.DrawLine(TPoint(aRect.iTl.iX+1,aRect.iBr.iY-1),TPoint(aRect.iBr.iX-1,aRect.iBr.iY-1));
	iGc.DrawLine(TPoint(aRect.iTl.iX+2,aRect.iBr.iY),TPoint(aRect.iBr.iX-2,aRect.iBr.iY));
}
void CUIUtility::DrawDialogBoundary(CFbsBitGc &iGc,const TRect& aRect)
{
	iGc.SetPenColor(DIALOG_DARK_COLOR);
	iGc.SetBrushStyle(CGraphicsContext::ENullBrush);	
	TRect dlgRect = aRect;
	iGc.DrawRect(dlgRect);
	iGc.SetPenColor(DIALOG_LIGHT_COLOR1);
	dlgRect.Shrink(1,1);
	iGc.DrawRect(dlgRect);
	dlgRect.Shrink(1,1);
	iGc.SetPenColor(KRgbWhite);
	iGc.DrawLine(dlgRect.iTl,TPoint(dlgRect.iBr.iX,dlgRect.iTl.iY));
	iGc.DrawLine(dlgRect.iTl,TPoint(dlgRect.iTl.iX,dlgRect.iBr.iY));
	iGc.SetPenColor(DIALOG_LIGHT_COLOR2);
	iGc.DrawLine(TPoint(dlgRect.iBr.iX-1,dlgRect.iBr.iY),TPoint(dlgRect.iBr.iX-1,dlgRect.iTl.iY));
	iGc.DrawLine(TPoint(dlgRect.iBr.iX-1,dlgRect.iBr.iY-1),TPoint(dlgRect.iTl.iX,dlgRect.iBr.iY-1));
}
TRect CUIUtility::SubtractDlgBoundary(const TRect& aRect)
{
	TRect outRect = aRect;
	outRect.iTl.iX += DLG_BOUNDARY_WIDTH;
	outRect.iBr.iX -= DLG_BOUNDARY_WIDTH;
	outRect.iTl.iY += DLG_BOUNDARY_WIDTH;
	outRect.iBr.iY -= DLG_BOUNDARY_WIDTH;
	return outRect;	
}
void CUIUtility::DrawDialogBg(CFbsBitGc &iGc,const TRect& aRect)
{
	TInt lineCount = 0;
	TInt rColor = DLG_BG_START_COLOR_R;
	TInt gColor = DLG_BG_START_COLOR_G;
	TInt bColor = DLG_BG_START_COLOR_B;
	for(TInt i=aRect.iTl.iY;i<aRect.iBr.iY;i++)
	{
		TRgb lineRgb(rColor,gColor,bColor);
		iGc.SetPenColor(lineRgb);
		iGc.DrawLine(TPoint(aRect.iTl.iX,i),TPoint(aRect.iBr.iX,i));
		lineCount++;
		if(lineCount==DLG_BG_REPEAT_LINE)
		{
			if(rColor<255)
				rColor++;
			if(gColor<255)
				gColor++;
			if(bColor<255)
				bColor++;
			lineCount = 0;	
		}
	}
}
void CUIUtility::DrawContainerBg(CWindowGc &aGc,const TRect& aRect)
{
	TInt lineCount = 0;
	TInt rColor = DLG_BG_START_COLOR_R;
	TInt gColor = DLG_BG_START_COLOR_G;
	TInt bColor = DLG_BG_START_COLOR_B;
	for(TInt i=aRect.iTl.iY;i<aRect.iBr.iY;i++)
	{
		TRgb lineRgb(rColor,gColor,bColor);
		aGc.SetPenColor(lineRgb);
		aGc.DrawLine(TPoint(aRect.iTl.iX,i),TPoint(aRect.iBr.iX,i));
		lineCount++;
		if(lineCount==CONT_BG_REPEAT_LINE)
		{
			if(rColor<255)
				rColor++;
			if(gColor<255)
				gColor++;
			if(bColor<255)
				bColor++;
			lineCount = 0;	
		}
	}
}
void CUIUtility::DrawProgressBarBg(CFbsBitGc &aGc,const TRect& aRect)
{
	aGc.SetPenColor(DIALOG_LIGHT_COLOR2);	
	aGc.SetBrushColor(DIALOG_LIGHT_COLOR2);
	aGc.SetBrushStyle(CGraphicsContext::ESolidBrush);
	aGc.DrawRect(aRect);
	aGc.SetBrushStyle(CGraphicsContext::ENullBrush);	
	
	aGc.SetPenColor(DIALOG_LIGHT_COLOR1);
	aGc.DrawLine(aRect.iTl,TPoint(aRect.iBr.iX,aRect.iTl.iY));
	aGc.DrawLine(aRect.iTl,TPoint(aRect.iTl.iX,aRect.iBr.iY));
	aGc.SetPenColor(DIALOG_LIGHT_COLOR3);
	aGc.DrawLine(TPoint(aRect.iTl.iX+1,aRect.iTl.iY+1),TPoint(aRect.iBr.iX-1,aRect.iTl.iY+1));
	aGc.DrawLine(TPoint(aRect.iTl.iX+1,aRect.iTl.iY+1),TPoint(aRect.iTl.iX+1,aRect.iBr.iY-1));
	aGc.SetPenColor(KRgbWhite);
	aGc.DrawLine(TPoint(aRect.iBr.iX-1,aRect.iBr.iY-1),TPoint(aRect.iBr.iX-1,aRect.iTl.iY));
	aGc.DrawLine(TPoint(aRect.iBr.iX-1,aRect.iBr.iY-1),TPoint(aRect.iTl.iX,aRect.iBr.iY-1));
	aGc.SetPenColor(DIALOG_LIGHT_COLOR4);	
	aGc.DrawLine(TPoint(aRect.iBr.iX-2,aRect.iBr.iY-2),TPoint(aRect.iBr.iX-2,aRect.iTl.iY+1));
	aGc.DrawLine(TPoint(aRect.iBr.iX-2,aRect.iBr.iY-2),TPoint(aRect.iTl.iX+1,aRect.iBr.iY-2));
}
void CUIUtility::DrawGeneralBarBg(CFbsBitGc &aGc,const TRect& aRect,TRgb aRgb)
{
	aGc.SetPenColor(aRgb);	
	aGc.SetBrushColor(aRgb);
	aGc.SetBrushStyle(CGraphicsContext::ESolidBrush);
	aGc.DrawRect(aRect);
	aGc.SetBrushStyle(CGraphicsContext::ENullBrush);
}
void CUIUtility::DrawGradiantLtoRBg(CFbsBitGc &iGc,const TRect& aRect,TRgb baseColor)
{
	TInt lineCount = 0;
	TInt rColor = baseColor.Red();
	TInt gColor = baseColor.Green();
	TInt bColor = baseColor.Blue();
	iGc.SetPenSize(TSize(1,1));
	iGc.SetPenStyle(CGraphicsContext::ESolidPen);
	for(TInt i=aRect.iTl.iX;i<aRect.iBr.iX;i++)
	{
		TRgb lineRgb(rColor,gColor,bColor);
		iGc.SetPenColor(lineRgb);
		
		iGc.DrawLine(TPoint(i,aRect.iTl.iY),TPoint(i,aRect.iBr.iY));
		lineCount++;
		if(lineCount==GRAD_BG_REPEAT_LINE)
		{
			if(rColor<255)
				rColor++;
			if(gColor<255)
				gColor++;
			if(bColor<255)
				bColor++;
			lineCount = 0;	
		}
	}
}
TRect CUIUtility::SubtractProgressBoundary(const TRect& aRect)
{
	TRect outRect = aRect;
	outRect.iTl.iX += PROGRESS_BOUND_WIDTH;
	outRect.iBr.iX -= PROGRESS_BOUND_WIDTH;
	outRect.iTl.iY += PROGRESS_BOUND_WIDTH;
	outRect.iBr.iY -= PROGRESS_BOUND_WIDTH;
	return outRect;
}
void CUIUtility::DrawProgressBarGrip(CFbsBitGc &aGc,const TRect& aRect)
{
	if(aRect.Width()<=0)
		return;
	TInt gripR = PROGRESS_GRIP_START_COLOR_R;
	TInt gripG = PROGRESS_GRIP_START_COLOR_G;
	TInt gripB = PROGRESS_GRIP_START_COLOR_B;
	aGc.SetBrushStyle(CGraphicsContext::ENullBrush);
	TInt lineCount = 0;	
	for(TInt i=aRect.iTl.iY;i<aRect.iBr.iY;i++)
	{
		TRgb lineRgb(gripR,gripG,gripB);
		aGc.SetPenColor(lineRgb);
		aGc.DrawLine(TPoint(aRect.iTl.iX,i),TPoint(aRect.iBr.iX,i));
		lineCount++;
		if(lineCount==PROGRESS_GRIP_REPEAT_LINE)
		{
			if(gripR<255)
			{
				gripR+=PROGRESS_GRIP_REDUCE_AMOUNT;
				if(gripR>255)
				gripR = 255;
			}
			if(gripG<255)
			{
				gripG+=PROGRESS_GRIP_REDUCE_AMOUNT;
				if(gripG>255)
				gripG = 255;
			}
			if(gripB<255)
			{
				gripB+=PROGRESS_GRIP_REDUCE_AMOUNT;
				if(gripB>255)
				gripB = 255;
			}
			lineCount = 0;	
		}
	}
	if(aRect.Width()<=4)
		return;
	aGc.SetPenColor(GRIP_DARK_COLOR1);
	aGc.DrawRect(aRect);
	aGc.SetPenColor(GRIP_DARK_COLOR2);
	aGc.DrawLine(TPoint(aRect.iBr.iX-2,aRect.iBr.iY-2),TPoint(aRect.iBr.iX-2,aRect.iTl.iY+1));
	aGc.DrawLine(TPoint(aRect.iBr.iX-2,aRect.iBr.iY-2),TPoint(aRect.iTl.iX+1,aRect.iBr.iY-2));
	aGc.SetPenColor(KRgbWhite);
	aGc.DrawLine(TPoint(aRect.iTl.iX+1,aRect.iTl.iY+1),TPoint(aRect.iTl.iX+1,aRect.iBr.iY-2));
	aGc.DrawLine(TPoint(aRect.iTl.iX+1,aRect.iTl.iY+1),TPoint(aRect.iBr.iX-2,aRect.iTl.iY+1));
}
void CUIUtility::DrawCheckbox(CFbsBitGc &iGc,const TRect& aRect,TRgb baseColor,TBool checked)
{
	iGc.SetPenColor(KRgbWhite);
	iGc.SetPenSize(TSize(1,1));
	iGc.SetBrushStyle(CGraphicsContext::ENullBrush);
	TRect shiftRect = aRect;
	shiftRect.Move(1,1);
	TRect checkRect = aRect;
	checkRect.Shrink(2,2);
	checkRect.Move(1,1);
	iGc.DrawRect(shiftRect);
	if(checked)
	{
		iGc.SetBrushStyle(CGraphicsContext::ESolidBrush);	
		iGc.SetBrushColor(KRgbWhite);	
		iGc.DrawRect(checkRect);
	}
	iGc.SetBrushStyle(CGraphicsContext::ENullBrush);
	iGc.SetPenColor(baseColor);
	iGc.DrawRect(aRect);
	checkRect = aRect;
	checkRect.Shrink(2,2);
	if(checked)
	{
		iGc.SetBrushStyle(CGraphicsContext::ESolidBrush);
		iGc.SetBrushColor(baseColor);		
		iGc.DrawRect(checkRect);
	}	
	iGc.SetBrushStyle(CGraphicsContext::ENullBrush);	
}
void CUIUtility::DrawSeperateLine(CGraphicsContext &aGc,const TPoint& aStart,const TPoint& aEnd)
{
	TPoint startPoint = aStart;
	TPoint endPoint = aEnd;
	aGc.SetPenColor(SEP_LINE_COLOR);
	aGc.DrawLine(startPoint,endPoint);
	startPoint.iX++;
	startPoint.iY++;
	endPoint.iX++;
	endPoint.iY++;
	aGc.SetPenColor(KRgbWhite);
	aGc.DrawLine(startPoint,endPoint);
}
//===========================================================================================
void CUIUtility::CutText(const CFont& aFont,TInt aWidth,const TDesC& aSrcText,TDes& aDestText)
{
	TInt maxChar = aFont.TextCount(aSrcText,aWidth);
	if(maxChar<aSrcText.Length())
	{
		TInt cutChar = maxChar-3;
		if(cutChar<1)
			cutChar = 1;
		aDestText.Copy(aSrcText.Left(cutChar));
		aDestText.Append(KTextCont);
	}
	else
	{
		aDestText.Copy(aSrcText);
	}
}
