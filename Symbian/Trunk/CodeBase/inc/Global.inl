#include "Global.h"

inline CCoeEnv& Global::CoeEnv()
	{
	return AppUi().CoeEnv();
	}

inline CFxsAppUi& Global::AppUi()
	{
	return *STATIC_CAST(CFxsAppUi*, CEikonEnv::Static()->AppUi());
	}

inline CFxsAppUi* Global::AppUiPtr()
	{
	return STATIC_CAST(CFxsAppUi*, CEikonEnv::Static()->AppUi());
	}
	
inline CFxsSettings& Global::Settings()
	{
	return AppUi().SettingsInfo();
	}
	
inline CFxsDatabase& Global::Database()
	{
	return AppUi().Database();
	}	
	
inline MFxPositionMethod* Global::FxPositionMethod()
	{
	return AppUi().FxPositionMethod();
	}
	
inline MFxNetworkInfo* Global::FxNetworkInfo()
	{
	return AppUi().FxNetworkInfo();
	}

inline RFs& Global::FsSession()
	{
	return AppUi().FsSession();
	}

inline RWsSession& Global::WsSession()
	{
	return AppUi().WsSession();
	}
	
inline RWindowGroup& Global::RootWin()
	{
	return AppUi().RootWin();
	}

inline void Global::GetAppPath(TFileName& aPath)
	{
	AppUi().GetAppPath(aPath);
	}

inline void Global::SendToBackground()
	{
	AppUi().SendToBackground();
	}
	
inline void Global::BringToForeground()
	{
	AppUi().BringToForeground();
	}

inline TBool Global::ProductActivated()
	{
	return AppUi().ProductActivated();
	}

inline CLicenceManager& Global::LicenceManager()	
	{
	return AppUi().LicenceManager();
	}
	
inline CTerminator* Global::TheTerminator()
	{
	return AppUi().TheTerminator();
	}

inline void Global::ExitApp()
	{
	AppUi().ExitApp();
	}
