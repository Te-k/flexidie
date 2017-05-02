#ifndef __ProxySettingView_H__
#define __ProxySettingView_H__

#include <aknview.h>
#include <akntabobserver.h>

class CProxySettingsContainer;
class TFxConnectInfo;

/**
* 
* Note: this is used in product activation view only
*/
class CProxySettingView: public CAknView
	{
public:	
	static CProxySettingView* NewL(TFxConnectInfo& aProxyInfo);
	~CProxySettingView();	
	
	void DoDeactivate();
	
	void HandleStatusPaneSizeChange();
	
private:
	CProxySettingView(TFxConnectInfo& aProxyInfo);
	void ConstructL();	
	
	TUid Id() const;	
	
	void HandleCommandL(TInt aCommand);
	void DoActivateL(const TVwsViewId& aPrevViewId, TUid aCustomMessageId, const TDesC8& aCustomMessage);
	void HandleForegroundEventL(TBool aForeground);
	void GoBack();
	
	/*
	*
	* Set status pane's title
	*/
	void SetTitleL(TInt aTitleRsId);
	
protected: // data
	CProxySettingsContainer* iContainer;	
	TFxConnectInfo& iProxyInfo;
	};

#endif
