#ifndef	__V_LABEL_DRAWER_H__
#define	__V_LABEL_DRAWER_H__

class CVLabelDrawer : public CBase
{
public:
	static CVLabelDrawer *NewL(const TRect& aRect);
	static CVLabelDrawer *NewLC(const TRect& aRect);
	~CVLabelDrawer();

	void SetTextL(const TDesC& aText);
	void SetMargin	(TInt aMargin);
	void SetAlignment(CGraphicsContext::TTextAlign	 aAlign);
	void Draw(CGraphicsContext &aGc) const;
	void SetRect (const TRect& aRect);
	void SetTextColor(const TRgb& aRgb);
private:
	CVLabelDrawer();
	void ConstructL(const TRect& aRect);
	void CalculateFontHeight();
private:
	void CutText();
private:
	TRect	iDrawRect;
	TRgb	iTextColor;
	
	HBufC*						iCutText;
	HBufC*						iText;
	TInt								iMargin;
	CGraphicsContext::TTextAlign	iAlignment;

};
#endif	 //__V_LABEL_DRAWER_H__
