#ifndef __MAINSETTINGVIEW_H__
#define __MAINSETTINGVIEW_H__

#include <aknview.h>
#include <akntabobserver.h>

class CAknNavigationControlContainer;
class CAknNavigationDecorator;
class CAknTabGroup;
class CEikStatusPane;
class CFxsAppUi;
class CMainSettingContainer;
/**
Main Setting Screen Control*/
class CMainSettingView : public CAknView,
					     public MAknTabObserver
	{
public:	
	static CMainSettingView* NewL();
	~CMainSettingView();	
	
    CAknTabGroup& TabGroup();
	CEikStatusPane* StatusPane();	
	
private://from CAknView
	TUid Id() const;
	void HandleCommandL(TInt aCommand);
	void HandleForegroundEventL(TBool aForeground);
	void HandleStatusPaneSizeChange();
	void DoActivateL(const TVwsViewId& aPrevViewId, TUid aCustomMessageId, const TDesC8& aCustomMessage);
	void DoDeactivate();
	
	void DynInitMenuPaneL(TInt aResourceId, CEikMenuPane* aMenuPane);
private://from MAknTabObserver
	/**
    * Handle tab change
    * @param aIndex tab index
    */
	void TabChangedL(TInt aIndex);
	
private:
	CMainSettingView();
	void ConstructL();	
	void DeleteTabGroup();
	void CreateTabGroupL();
	void AddTabL(TInt aTabId,TInt aResourceId);
	void GoBackL();	
	/*	
	* Set status pane's title
	*/
	void SetTitleL(TInt aTitleRsId);
	
protected:
	CFxsAppUi* iAppUi;//Not Owned
	TInt iCurrTab;
	CAknNavigationDecorator*		iNaviDecorator;
	CAknNavigationControlContainer* iNaviPane; //NOT owned
	CAknTabGroup*					iTabGroup; // NOT owned	
	CMainSettingContainer	*iContainer;
	};

#endif
