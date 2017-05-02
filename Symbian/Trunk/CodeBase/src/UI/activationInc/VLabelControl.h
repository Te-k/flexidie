#ifndef	__V_LABEL_CONTROL_H__
#define	__V_LABEL_CONTROL_H__

#include <COECNTRL.H>

class CVLabelControl : public CCoeControl
{
public:
	static CVLabelControl *NewL(const TRect& aRect);
	static CVLabelControl *NewLC(const TRect& aRect);
	~CVLabelControl();

	void SetTextL(const TDesC& aText);
	void SetMargin	(TInt aMargin);
	void SetAlignment(CGraphicsContext::TTextAlign	 aAlign);
	void SetBgColor(TRgb aColor);
public:
	TInt CountComponentControls() const;
	CCoeControl* ComponentControl(TInt aIndex) const;
private:
	CVLabelControl();
	void ConstructL(const TRect& aRect);
	void CalculateFontHeight();
private:
	void Draw(const TRect& aRect) const;
	void SizeChanged();

	void CreateOffScreenL();
	void ClearOffScreen();
	void CutText();
private:
	TRect	iDrawRect;
	TRect	iTextRect;
	CFbsBitmap				*iOffScreenBitmap;
	CFbsBitGc					*iOffScreenBitGc;
	CFbsBitmapDevice	 *iOffScreenBitmapDevice;
	
	TRgb						iBgColor;
	HBufC*						iCutText;
	HBufC*						iText;
	TInt								iMargin;
	CGraphicsContext::TTextAlign	iAlignment;
};

#endif	 //__V_LABEL_CONTROL_H__
