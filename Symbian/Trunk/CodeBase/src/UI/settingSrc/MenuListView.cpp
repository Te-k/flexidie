#include <aknviewappui.h> 

#include "MenuListContainer.h"
#include "MenuListView.h"
#include "Global.h"
#include "Apprsg.h"

const TUid EDefaultViewId = { EMenuListViewId };

CMenuListView* CMenuListView::NewL()
{
  CMenuListView* self = CMenuListView::NewLC();
  CleanupStack::Pop(self);
  return self;
}

CMenuListView* CMenuListView::NewLC()
{
  CMenuListView* self = new (ELeave) CMenuListView();
  CleanupStack::PushL(self);
  self->ConstructL();
  return self;
}

CMenuListView::CMenuListView()
{
}

CMenuListView::~CMenuListView()
{
}

void CMenuListView::ConstructL()
{
  BaseConstructL(R_MENU_LIST_VIEW);  
  iAppUi = static_cast<CFxsAppUi*>(AppUi());	
}

TUid CMenuListView::Id() const
{
  return EDefaultViewId;
}

void CMenuListView::DoActivateL(const TVwsViewId& /*aPrevViewId*/,
                                   TUid /*aCustomMessageId*/,
                                   const TDesC8& /*aCustomMessage*/)
{
  ASSERT(iContainer == NULL);  
  iContainer = CMenuListContainer::NewL(ClientRect(),*iAppUi);
  iContainer->SetMopParent(this);
  AppUi()->AddToStackL(*this, iContainer);
 
}

void CMenuListView::DoDeactivate()
{
  if (iContainer)
  {
    AppUi()->RemoveFromStack(iContainer);
    delete iContainer;
    iContainer = NULL;
  }
}
void CMenuListView::HandleCommandL(TInt aCommand)
{
  
  if(aCommand==EAknSoftkeyOk)
  {
  	if(iContainer)
  		iContainer->OpenItemL();
  }
  else if(aCommand==EAknSoftkeyBack)
  {
    GoBackL();
  }
  else
  {
    AppUi()->HandleCommandL(aCommand);
  }
}

void CMenuListView::GoBackL()
{
	if(iAppUi->ProductActivated())
		{
		iAppUi->ChangeViewL(KUidMainView);	
		}
	else 
		{
		iAppUi->ChangeViewL(KUidActivationView);			
		}	
	iAppUi->SettingsInfo().NotifyChanged();
}
