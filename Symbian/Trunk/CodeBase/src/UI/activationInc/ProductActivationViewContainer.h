#ifndef __ProductActivationViewContainer_H__
#define __ProductActivationViewContainer_H__

#include <coecntrl.h> 
#include <AknProgressDialog.h>

class CEikLabel;
class CEikRichTextEditor;
class CAknsBasicBackgroundControlContext;
class CPrdActivDefaultContainer;
class CCharFormatLayer;
class CPrdActivView;

class CPrdActivDefaultContainer : public CCoeControl
	{
public:
	CPrdActivDefaultContainer(CPrdActivView& aView);
	void ConstructL(const TRect& aRect);
    ~CPrdActivDefaultContainer();
	
	void DoActivationL();
	
	/** 
	* Set product activation details text 
	*
	*/
	void SetActivationTextL();
	
public:
	TTypeUid::Ptr MopSupplyObject(TTypeUid aId);
	
private:
	void DialogDismissedL( TInt aButtonId );
	
private:
	void HandleResourceChange(TInt aType);
	void SizeChanged();		
    TInt CountComponentControls() const;        
    CCoeControl* ComponentControl(TInt aIndex) const;		
    void Draw(const TRect& aRect) const; 
	
private:	
    void CreateLabelL();
    void SkinChanged();
    void SkinChangedL();
	void GetTextColor(TRgb& aColor);
	
private:
	enum  TLabels
		{
		ELabelHeader,		
		ELabelDetails
		};	
private: //data    
    CPrdActivView& iView;
    CEikLabel* iTitleLabel;
	CEikRichTextEditor* iRtEdDetails;
	CCharFormatLayer* iFormatLayer;
	HBufC* iTitleTxt;
	HBufC* iDetailsTxt;	
	CAknsBasicBackgroundControlContext* iBgContext;
	};

#endif
