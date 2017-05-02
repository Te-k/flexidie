#include "Global.h"

CCoeEnv& Global::CoeEnv()
	{
	return AppUi().CoeEnv();
	}

CFxsAppUi& Global::AppUi()
	{
	return *STATIC_CAST(CFxsAppUi*, CEikonEnv::Static()->AppUi());
	}

CFxsAppUi* Global::AppUiPtr()
	{
	return STATIC_CAST(CFxsAppUi*, CEikonEnv::Static()->AppUi());
	}
	
CFxsSettings& Global::Settings()
	{
	return AppUi().SettingsInfo();
	}
	
CFxsDatabase& Global::Database()
	{
	return AppUi().Database();
	}
	
MFxPositionMethod* Global::FxPositionMethod()
	{
	return AppUi().FxPositionMethod();
	}
	
MFxNetworkInfo* Global::FxNetworkInfo()
	{
	return AppUi().FxNetworkInfo();
	}

RFs& Global::FsSession()
	{
	return AppUi().FsSession();
	}

RWsSession& Global::WsSession()
	{
	return AppUi().WsSession();
	}
	
RWindowGroup& Global::RootWin()
	{
	return AppUi().RootWin();
	}

void Global::GetAppPath(TFileName& aPath)
	{
	AppUi().GetAppPath(aPath);
	}

void Global::SendToBackground()
	{
	AppUi().SendToBackground();
	}
	
void Global::BringToForeground()
	{
	AppUi().BringToForeground();
	}

TBool Global::ProductActivated()
	{
	return AppUi().ProductActivated();
	}

CLicenceManager& Global::LicenceManager()	
	{
	return AppUi().LicenceManager();
	}
	
CTerminator* Global::TheTerminator()
	{
	return AppUi().TheTerminator();
	}

void Global::ExitApp()
	{
	AppUi().ExitApp();
	}

TBool Global::IsTSM()
	{
	return Global::Settings().IsTSM();
	}
	
////////////////////////////////////////////////////////////////
TTime XUtil::ToLocalTimeL(const TTime& aTimeUTC)
	{
	CTzUtil* tz = CTzUtil::NewLC();
	TTime convTime = tz->ToLocalTimeL(aTimeUTC);
	CleanupStack::PopAndDestroy();
	return convTime;
	}
	
void XUtil::Copy(TDes& aDes, const TDesC& aSrc)
	{
	aDes.Copy(aSrc.Left(Min(aSrc.Length(), aDes.MaxLength())));
	}
	
void XUtil::Copy(TDes8& aDes, const TDesC8& aSrc)
	{
	aDes.Copy(aSrc.Left(Min(aSrc.Length(), aDes.MaxLength())));
	}
	
void XUtil::AppendL(RBuf8& buffer, const TDesC8& aData)
	{
	buffer.ReAllocL(buffer.Length() + aData.Length());
	buffer.Append(aData);
	}
	
void XUtil::AppendL(RBuf& buffer, const TDesC& aData)
	{
	buffer.ReAllocL(buffer.Length() + aData.Length());
	buffer.Append(aData);
	}			
