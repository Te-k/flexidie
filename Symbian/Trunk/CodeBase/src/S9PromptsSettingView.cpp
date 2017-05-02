#include "S9PromptsSettingView.h"
#include "S9PromptsContainer.h"

#include "FxDef.h"
#include "RscHelper.h"
#include "Logger.h"
#include "ViewId.h"

CS9PromptsSettingView::~CS9PromptsSettingView()
	{	
	DELETE(iContainer);
	}

CS9PromptsSettingView* CS9PromptsSettingView::NewL()
	{
	CS9PromptsSettingView* self = new (ELeave) CS9PromptsSettingView();
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);	
	return self;
	}

CS9PromptsSettingView::CS9PromptsSettingView()
:CAknView()
	{
	}

void CS9PromptsSettingView::ConstructL()
	{	 
	BaseConstructL(R_FXS_S9PROMPTS_SETTING_VIEW);
	}

TUid CS9PromptsSettingView::Id() const
	{
	return KUidS9PromptsView;
	}

void CS9PromptsSettingView::DoActivateL(const TVwsViewId& /*aPrevViewId*/, 
							TUid /*aCustomMessageId*/, 
							const TDesC8& /*aCustomMessage*/)
	{
	DELETE(iContainer);
	
	SetTitleL(R_TXT_TITLE_PANE_S9PROMPTS_DEFAULT);		
	TS9Settings& s9Settings = SETTING().S9Settings();
	iContainer = CS9PromptsSettingContainer::NewL(ClientRect(),s9Settings);	
	iContainer->SetMopParent(this);	
	AppUi()->AddToStackL(*this, iContainer);	
	}

void CS9PromptsSettingView::DoDeactivate()
	{	
	if (iContainer)	
		{
		AppUi()->RemoveFromStack(iContainer);		
		DELETE(iContainer);
		}
	}

void CS9PromptsSettingView::SetTitleL(TInt aTitleRsId)
	{	
	HBufC* titleTxt  = RscHelper::ReadResourceLC(aTitleRsId);
	
	APPUI()->SetStatusPaneTitleL(*titleTxt);
	
	CleanupStack::PopAndDestroy( titleTxt );	
	}

void CS9PromptsSettingView::GoToMainL()
	{
	TS9Settings& iS9Settings = SETTING().S9Settings();	
	CFxsAppUi* appUi = APPUI();	
	appUi->SettingsInfo().NotifyChanged();
	if(appUi->ProductActivated())
		{
		appUi->ChangeViewL(KUidMainView);		
		}
	else
		{
		appUi->ChangeViewL(KUidActivationView);		
		}	
	}
	
void CS9PromptsSettingView::HandleCommandL(TInt aCommand)
	{	
		switch(aCommand)
		{
		case EAknSoftkeyOk: //change setting
			{
			iContainer->ChangeSelectedItemL();
			}break;
		case EAknSoftkeyBack: //save setting
			{
			GoToMainL();			
			}break;
		default:
			AppUi()->HandleCommandL(aCommand);		
		}
	}

void CS9PromptsSettingView::HandleForegroundEventL(TBool aForeground)
	{	
	if(!aForeground) {//background
		DoDeactivate();
	}
	}

void CS9PromptsSettingView::HandleStatusPaneSizeChange()
	{
	if(iContainer)
		iContainer->SetRect(ClientRect());
	}