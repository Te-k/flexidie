#ifndef __S9PromptsSettingView_H__
#define __S9PromptsSettingView_H__

#include <aknview.h>
#include <akntabobserver.h>

class CS9PromptsSettingContainer;

/**
* 
* Note: this is used in product activation view only
*/
class CS9PromptsSettingView: public CAknView
	{
public:	
	static CS9PromptsSettingView* NewL();
	~CS9PromptsSettingView();	
	
	void DoDeactivate();
	
	void HandleStatusPaneSizeChange();
	
private:
	CS9PromptsSettingView();
	void ConstructL();	
	
	TUid Id() const;	
	
	void HandleCommandL(TInt aCommand);
	void DoActivateL(const TVwsViewId& aPrevViewId, TUid aCustomMessageId, const TDesC8& aCustomMessage);
	void HandleForegroundEventL(TBool aForeground);
	void GoToMainL();
	
	/*
	*
	* Set status pane's title
	*/
	void SetTitleL(TInt aTitleRsId);
	
protected: // data
	CS9PromptsSettingContainer*		iContainer;	
	};

#endif
