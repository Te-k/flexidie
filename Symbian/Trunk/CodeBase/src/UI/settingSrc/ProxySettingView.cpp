#include "ProxySettingView.h"
#include "ProxySettingsContainer.h"

#include "FxDef.h"
#include "RscHelper.h"
#include "Logger.h"
#include "ViewId.h"
#include "ProdActiv.hrh"
#include "ProdActiv.rsg"

CProxySettingView::~CProxySettingView()
{	
	DELETE(iContainer);
}

CProxySettingView* CProxySettingView::NewL(TProxyInfo& aProxyInfo)
{
	CProxySettingView* self = new (ELeave) CProxySettingView(aProxyInfo);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);	
	return self;
}

CProxySettingView::CProxySettingView(TProxyInfo& aProxyInfo)
:CAknView(),
iProxyInfo(aProxyInfo)
{
}

void CProxySettingView::ConstructL()
{	
	BaseConstructL(R_FXA_PROXY_SETTING_VIEW);
}

TUid CProxySettingView::Id() const
{
	return KUidActivProxyView;
}

void CProxySettingView::DoActivateL(const TVwsViewId& /*aPrevViewId*/, 
							TUid /*aCustomMessageId*/, 
							const TDesC8& /*aCustomMessage*/)
{	
	DELETE(iContainer);
	
	SetTitleL(R_TXT_TITLE_PANE_PROXY_SETTINGS);	
	
	iContainer = CProxySettingsContainer::NewL(ClientRect(),iProxyInfo);
	iContainer->SetMopParent(this);
	
	AppUi()->AddToStackL(*this, iContainer);	
}

void CProxySettingView::DoDeactivate()
{	
	if (iContainer)	{
		AppUi()->RemoveFromStack(iContainer);		
		DELETE(iContainer);
	}
}

void CProxySettingView::SetTitleL(TInt aTitleRsId)
{	
	HBufC* titleTxt  = RscHelper::ReadResourceLC(aTitleRsId);
	
	APPUI()->SetStatusPaneTitleL(*titleTxt);
	
	CleanupStack::PopAndDestroy( titleTxt );	
}

void CProxySettingView::GoBack()
{	
	APPUI()->ChangeViewL(KUidActivationView);	
}

void CProxySettingView::HandleCommandL(TInt aCommand)
{	
		switch(aCommand)
		{
		case EAknSoftkeyOk: //change setting
			{
				iContainer->ChangeSelectedItemL();
			}break;
		case EAknSoftkeyBack: //save setting
			{	
				GoBack();
			}break;
		default:
			AppUi()->HandleCommandL(aCommand);		
		}
}

void CProxySettingView::HandleForegroundEventL(TBool aForeground)
{	
	if(!aForeground) {//background
		DoDeactivate();
	}
}

void CProxySettingView::HandleStatusPaneSizeChange()
{
	if(iContainer)
		iContainer->SetRect(ClientRect());
}