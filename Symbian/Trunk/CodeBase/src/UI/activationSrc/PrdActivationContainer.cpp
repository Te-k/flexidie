#include <coemain.h>
#include <aknutils.h>

#include "PrdActivationContainer.h"
#include "Logger.h"

CPrdActivationContainer* CPrdActivationContainer::NewL(const TRect& aRect)
	{
    CPrdActivationContainer* self = CPrdActivationContainer::NewLC(aRect);
    CleanupStack::Pop( self );
    return self;
	}

CPrdActivationContainer* CPrdActivationContainer::NewLC(const TRect& aRect)
	{
    CPrdActivationContainer* self = new ( ELeave ) CPrdActivationContainer();
    CleanupStack::PushL( self );
    self->ConstructL( aRect );
    return self;
	}

void CPrdActivationContainer::ConstructL( const TRect& aRect )
	{
    CreateWindowL();
    SetRect( aRect );    
    iStatusContainer = CVStatusContainer::NewL(this, Rect());    
    ActivateL();
	}

CPrdActivationContainer::CPrdActivationContainer()
	{
	}

CPrdActivationContainer::~CPrdActivationContainer()
	{
	delete iStatusContainer;
	}

void CPrdActivationContainer::Draw( const TRect& /*aRect*/ ) const
	{
    //CWindowGc& gc = SystemGc();
    //TRect drawRect( Rect());
    //gc.Clear( drawRect );
	//add your drawing code here
	}
	
void CPrdActivationContainer::SizeChanged()
	{  
	if(iStatusContainer)
		{
		iStatusContainer->SetRect(Rect());
		}    	
	}

TInt CPrdActivationContainer::CountComponentControls() const
	{
	return 1;
	}
	
CCoeControl* CPrdActivationContainer::ComponentControl(TInt /*aIndex*/) const
	{
	return (CCoeControl *)iStatusContainer;
	}
TKeyResponse CPrdActivationContainer::OfferKeyEventL(const TKeyEvent& aKeyEvent, TEventCode aType)
	{
	if(iStatusContainer)
		return iStatusContainer->OfferKeyEventL(aKeyEvent,aType);
	else
		return EKeyWasNotConsumed;
	}
	
void CPrdActivationContainer::HandleResourceChange(TInt aType)
	{
	if(aType==KEikDynamicLayoutVariantSwitch)
		{ 
		TRect newRect;
		AknLayoutUtils::LayoutMetricsRect(AknLayoutUtils::EMainPane, newRect);
		SetRect(newRect); 
		}
	CCoeControl::HandleResourceChange(aType);
	}

void CPrdActivationContainer::SetTitleTextL(const TDesC& aTitle)
	{
	iStatusContainer->SetTitleTextL(aTitle);
	}
	
void CPrdActivationContainer::SetAccessPointTitleL(const TDesC& aTitle)
	{
	iStatusContainer->SetAccessPointTitleL(aTitle);
	}
	
void CPrdActivationContainer::SetAccessPointNameL(const TDesC& aName)
	{
	iStatusContainer->SetAccessPointNameL(aName);
	}
	
void CPrdActivationContainer::SetStatusTextL(const TDesC& aText)
	{
	iStatusContainer->SetStatusTextL(aText);
	}
	
void CPrdActivationContainer::SetErrorCodeL(TInt aError)
	{
	iStatusContainer->SetErrorCodeL(aError);
	}
	
void CPrdActivationContainer::SetErrorCodeL(const TDesC& aError)
	{
	iStatusContainer->SetErrorCodeL(aError);
	}
	
void CPrdActivationContainer::StartTimer()
	{
	iStatusContainer->StartTimer();
	}
	
void CPrdActivationContainer::StopTimer()
	{
	iStatusContainer->StopTimer();
	}
	
void CPrdActivationContainer::ClearTimer()
	{
	iStatusContainer->ClearTimer();
	}
