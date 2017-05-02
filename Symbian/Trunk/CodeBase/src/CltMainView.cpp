#include "CltMainView.h"
#include "CltSettingsListContainer.h"
#include "CltMainContainer.h"
#include "Global.h"
#include "RscHelper.h"
#include "ViewId.h"

#include <aknviewappui.h>
#include <eikmenup.h>

#include "Apprsg.h"

CCltMainView::~CCltMainView()
	{
	delete iContainer;
	}

CCltMainView* CCltMainView::NewL()
	{
	CCltMainView* self = new (ELeave) CCltMainView();
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);	
	return self;
	}
	
CCltMainView::CCltMainView()
	{
	}

void CCltMainView::ConstructL()
	{			
	BaseConstructL(R_CLTMAIN_VIEW);	
	}
	
TUid CCltMainView::Id() const
	{
	return KUidMainView;
	}
	
void CCltMainView::DoActivateL(const TVwsViewId& /*aPrevViewId*/, 
							TUid /*aCustomMessageId*/, 
							const TDesC8& /*aCustomMessage*/)
	{
	SetTitleL();	
	if (!iContainer) 
		{
		iContainer = new (ELeave) CCltMainContainer;
		iContainer->SetMopParent(this);			
		iContainer->ConstructL(ClientRect());					
		AppUi()->AddToStackL(*this, iContainer);
		}
	}

void CCltMainView::SetTitleL()
	{
	HBufC* titleTxt  = RscHelper::ReadResourceLC(R_TXT_TITLE_PANE_MAINVIEW);
	Global::AppUi().SetStatusPaneTitleL(*titleTxt);	
	CleanupStack::PopAndDestroy(titleTxt );	
	}

void CCltMainView::DoDeactivate()
	{
	if (iContainer) 
		{
		AppUi()->RemoveFromStack(iContainer);
		delete iContainer;
		iContainer = NULL;
		}
	}
 
void CCltMainView::HandleCommandL(TInt aCommand)
	{				
	AppUi()->HandleCommandL(aCommand);
	}
