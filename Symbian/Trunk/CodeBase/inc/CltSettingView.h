#ifndef __CltSettingView_H__
#define __CltSettingView_H__

#include <aknview.h>
#include <akntabobserver.h>

class CSettingsMainContainer;
class CAknNavigationControlContainer;
class CAknNavigationDecorator;
class CAknTabGroup;
class CEikStatusPane;
class CFxsAppUi;

/**
Setting Tabs*/
enum TSettingTabs
	{
	/*default fxs Light setting*/
	ETabDefaultSetting,
	/*Fxs Pro: Spy number setting*/	
	ETabSpyNumberSetting
	};

/**
Setting View*/
class CCltSettingView: public CAknView,
					   public MAknTabObserver
{
public:	
	static CCltSettingView* NewL();
	~CCltSettingView();	
	
	void DoDeactivate();
	
    CAknTabGroup& TabGroup();	
	
	/**
    * From MAknTabObserver.
    * @param aIndex tab index
    */
	void TabChangedL(TInt aIndex);
	
	CEikStatusPane* StatusPane();
	
	void HandleStatusPaneSizeChange();
	
private:
	CCltSettingView();
	void ConstructL();	
	
	TUid Id() const;	
	void DeleteTabGroup();
	void CreateTabGroupL();
	
	void HandleCommandL(TInt aCommand);
	//void DynInitMenuPaneL(TInt aResourceId, CEikMenuPane* aMenuPane);
	void DoActivateL(const TVwsViewId& aPrevViewId, TUid aCustomMessageId, const TDesC8& aCustomMessage);
	void HandleForegroundEventL(TBool aForeground);
	void GoBack();
	
	/*
	*
	* Set status pane's title
	*/
	void SetTitleL(TInt aTitleRsId);
	
protected: // data
	CFxsAppUi* iAppUi;//Not Owned
	CSettingsMainContainer*		iContainer;		
	
	CAknNavigationDecorator*		iNaviDecorator;		
	CAknNavigationControlContainer* iNaviPane; //NOT owned
	CAknTabGroup*					iTabGroup; // NOT owned	
	TInt iCurrTab;
};

#endif
