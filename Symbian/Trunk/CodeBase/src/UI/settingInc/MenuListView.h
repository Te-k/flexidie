#ifndef	__MENU_LIST_VIEW_H__
#define	__MENU_LIST_VIEW_H__

#include <aknview.h>
#include <eikmenup.h> 

class CMenuListContainer;

class  CMenuListView : public CAknView
{
  public:
    static CMenuListView* NewL();
    static CMenuListView* NewLC();
	~CMenuListView();
	
  private:
    TUid Id() const;
    void HandleCommandL(TInt aCommand);
    void DoActivateL(const TVwsViewId &aPrevViewId, TUid  aCustomMessageId, const TDesC8& aCustomMessage);
    void DoDeactivate();

  private:
    CMenuListView(); 
    void ConstructL();
    void GoBackL();	//Back to main screen    
  private:
    CMenuListContainer* iContainer;
    TUid iIdentifier;
	CFxsAppUi* iAppUi;	//Not Owned
};

#endif	 //__MENU_LIST_VIEW_H__
