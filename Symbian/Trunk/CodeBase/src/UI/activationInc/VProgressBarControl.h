#ifndef	__V_PROGRESS_BAR_CONTROL_H__
#define __V_PROGRESS_BAR_CONTROL_H__

#include <COECNTRL.H>
#include "Timeout.h"

/*
*	- Progress bar component
*  - Can display waiting progress or percentage progress
*/
class CVProgressBarControl : public CCoeControl ,public  MTimeoutObserver
{
public:
	enum TVProgressDisplayMode
	{
			EStop,
			EWaiting,
			EPercentage
	};
public:
	static CVProgressBarControl *NewL(const TRect& aRect);
	static CVProgressBarControl *NewLC(const TRect& aRect);
	~CVProgressBarControl();
	
	void SetMode(TVProgressDisplayMode aMode);
	void SetPercent(TInt aPercent);
public:
	TInt CountComponentControls() const;
	CCoeControl* ComponentControl(TInt aIndex) const;
private:
	void HandleTimedOutL();
private:
	CVProgressBarControl();
	void ConstructL(const TRect& aRect);
private:
	void Draw(const TRect& aRect) const;
	void SizeChanged();
	void CalculateRect();
	void CalculateGrip();
	void MoveGrip();

	void CreateOffScreenL();
	void ClearOffScreen();
	//implements	 MGeneralTimerNotifier
	void Time2GoL(TInt aError);

private:
	enum TProgressDirection
	{
		EProgressGoLeft,
		EProgressGoRight
	};
	TRect	iDrawRect;
	CFbsBitmap				*iOffScreenBitmap;
	CFbsBitGc					*iOffScreenBitGc;
	CFbsBitmapDevice	 *iOffScreenBitmapDevice;
	CTimeOut		 *iTimer;	 //animation timer

	TInt								iGripPositionX;
	TInt								iPencentage;	
	TVProgressDisplayMode iDisplayMode;
	TRect							iProgressInnerRect;
	TRect							iGripRect;	//progress grip
	TProgressDirection	iProgressDir;
};

#endif	 //	__V_PROGRESS_BAR_CONTROL_H__
