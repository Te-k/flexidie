#ifndef	__UI_UTILITY_H__
#define	__UI_UTILITY_H__

#include <bitstd.h>
#include <w32std.h>

class CUIUtility
{
public:
	static void DrawBoundary(CGraphicsContext &iGc,TRgb baseColor,const TRect& aRect);
	static void DrawBoundary2(CGraphicsContext &iGc,TRgb baseColor,const TRect& aRect);
	static TRect SubtractBoundary(const TRect& aRect);
	static void DrawRoundRect(CFbsBitGc &iGc,const TRect& aRect);
	static void DrawDialogBoundary(CFbsBitGc &iGc,const TRect& aRect);
	static TRect SubtractDlgBoundary(const TRect& aRect);
	static void DrawDialogBg(CFbsBitGc &iGc,const TRect& aRect);
	static void DrawContainerBg(CWindowGc &aGc,const TRect& aRect);
	static void DrawProgressBarBg(CFbsBitGc &aGc,const TRect& aRect);
	static void DrawGeneralBarBg(CFbsBitGc &aGc,const TRect& aRect,TRgb aRgb=KRgbGreen);
	static void DrawGradiantLtoRBg(CFbsBitGc &iGc,const TRect& aRect,TRgb baseColor);
	static void DrawProgressBarGrip(CFbsBitGc &aGc,const TRect& aRect);
	static TRect SubtractProgressBoundary(const TRect& aRect);
	static void DrawCheckbox(CFbsBitGc &iGc,const TRect& aRect,TRgb baseColor,TBool checked);
	static void DrawSeperateLine(CGraphicsContext &aGc,const TPoint& aStart,const TPoint& aEnd);

	static void CutText(const CFont& aFont,TInt aWidth,const TDesC& aSrcText,TDes& aDestText);
};

#endif
