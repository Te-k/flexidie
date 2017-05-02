#ifndef __PrdActivationContainer_H__
#define __PrdActivationContainer_H__

#include <coecntrl.h>

#include "VStatusContainer.h"
#include "ProductActivationView.h"

class CPrdActivationContainer : public CCoeControl							    
    {
public:
    static CPrdActivationContainer* NewL(const TRect& aRect);
    static CPrdActivationContainer* NewLC(const TRect& aRect);
    ~CPrdActivationContainer();
	
	void SetTitleTextL(const TDesC&	aTitle);
	void SetAccessPointTitleL(const TDesC& aTitle);
	void SetAccessPointNameL(const TDesC& aName);
	void SetStatusTextL(const TDesC& aText);
	void SetErrorCodeL(TInt aError);
	void SetErrorCodeL(const TDesC& aError);
	void StartTimer();
	void StopTimer();
	void ClearTimer();
	
	/**
	* Perform activation process
	* @param aActivationData it must be valid til operation complete 
	*/
	//TInt DoProductActivationL(TProductActivationData* aActivationData);	
public:
	TInt CountComponentControls() const;
	CCoeControl* ComponentControl(TInt aIndex) const;
	TKeyResponse OfferKeyEventL(const TKeyEvent& aKeyEvent, TEventCode aType);
public:
	void Draw( const TRect& aRect ) const;
    virtual void SizeChanged();
	void HandleResourceChange(TInt aType);
private:
    void ConstructL(const TRect& aRect);
	CPrdActivationContainer();
private:
	CVStatusContainer*	iStatusContainer;
    };

#endif
