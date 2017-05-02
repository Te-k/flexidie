#ifndef	__V_STATUS_CONTAINER_H__
#define	__V_STATUS_CONTAINER_H__

#include <eiksbfrm.h> 

#include "VLabelDrawer.h"
#include "VLabelControl.h"
#include "VProgressBarControl.h"
#include "Timeout.h"

class CVStatusContainer : public CCoeControl, 
						  public MTimeoutObserver						  
{
public:
	static CVStatusContainer *NewL(CCoeControl *aParent,const TRect& aRect);
	static CVStatusContainer *NewLC(CCoeControl *aParent,const TRect& aRect);
	~CVStatusContainer();
	
public:
	void SetTitleTextL(const TDesC&	aTitle);
	void SetAccessPointTitleL(const TDesC& aTitle);
	void SetAccessPointNameL(const TDesC& aName);
	void SetStatusTextL(const TDesC& aText);
	void SetErrorCodeL(TInt aError);
	void SetErrorCodeL(const TDesC& aError);
	void StartTimer();
	void StopTimer();
	void ClearTimer();

	TKeyResponse OfferKeyEventL(const TKeyEvent& aKeyEvent, TEventCode aType);
private:
	TInt CountComponentControls() const;
	CCoeControl* ComponentControl(TInt aIndex) const;
	void Draw(const TRect& aRect) const;
	void SizeChanged();

private:	
	void HandleTimedOutL();

private:
	CVStatusContainer();
	void ConstructL(CCoeControl *aParent,const TRect& aRect);
	void InitComponentsL();
    void CleanupComponents();
	void SetTimeLabel();
	void MoveControl();	
	void CalculateComponentsRect();	
	
private:
	RPointerArray<CCoeControl> iCtrlArray;
	TRect	iDrawRect;
	
	TInt						iTitleSepLineStartY;
	TInt						iTitleSepLineStartYWOffset;
	TInt						iMessageSepLineStartY;
	TInt						iMessageSepLineStartYWOffset;
	TInt						iSepLineMargin;

	TRect							iTitleRect;
	TRect							iMessageTitleRect;
	TRect							iMessageLabelRect;
	TRect							iProgressRect;
	TRect							iTimeRect;
	TRect							iErrorTitleRect;
	TRect							iErrorRect;
	TRect							iStatusLabelRect;

	CVLabelDrawer				*iTitlelabel;
	CVLabelDrawer				*iMessageTitle;
	CVLabelControl				*iMessageLabel;
	CVLabelControl				*iTimeLabel;
	CVLabelDrawer				*iErrorTitle;
	CVLabelControl				*iErrorLabel;
	CVLabelControl				*iStatusLabel;
	CVProgressBarControl	*iProgressBar;

	CEikScrollBarFrame		*iSBFrame;

	CTimeOut				*iStatusTimer;
	TInt										iHourInt;
	TInt										iMinuteInt;
	TInt										iSecondsInt;

	TInt									iOffset;
	TInt									iOffsetMove;
	TInt									iMinOffset;

	TEikScrollBarModel	iArrowAttributes;
	TAknDoubleSpanScrollBarModel iDoubleSpanAttributes;
};

#endif
