#ifndef _GLOBAL_DEF_H__
#define _GLOBAL_DEF_H__

#include <e32base.h>
#include <e32des8.h>
#include <eikenv.h>
#include <BAUTILS.H>

#include "CltApplication.h"
#include "CltDocument.h"
#include "CltDatabase.h"
#include "CltAppUi.h"
#include "CltSettings.h"
#include "CltSettingMan.h"
#include "Logger.h"
#include "commondef.h"
#include "ViewId.h"
#include "TheTerminator.h"
#include "GlobalConst.h"
#include "FxLocationServiceInterface.h"
#include "NetworkRelatedInterface.h"
#include "Exception.h"
#include "RscHelper.h"
#include "AppDefinitions.h"
#include "DialogUtils.h"
#include "AppInfoConst.h"

class Global
	{
public:
	static CCoeEnv& CoeEnv();
	/**
	* Get file session
	*/
	static RFs& FsSession();
	/**
	* Get window session
	*/
	static RWsSession& WsSession();
	/**
	* Get window group
	*/
	static RWindowGroup& RootWin();	
	/**
	* Get AppUi
	* @return CFxsAppUi&
	*/
	static CFxsAppUi& AppUi();
	/**
	* Get AppUi
	* @return CFxsAppUi&
	*/
	static CFxsAppUi* AppUiPtr();
	/**
	* Get application settings
	* @return CFxsSettings
	*/	
	static CFxsSettings& Settings();
	/**
	* Get database instance
	*/	
	static CFxsDatabase& Database();
	/**
	* Get licence manager instance
	*/
	static CLicenceManager& LicenceManager();
	/**
	* Get teminator object 
	*/
	static CTerminator* TheTerminator();
	/**
	* Get implementation of MFxPositionMethod interface
	* @return NULL is acceptable
	*/	
	static MFxPositionMethod* FxPositionMethod();
	/**
	* Get implementation of MFxNetworkInfo interface
	*/	
	static MFxNetworkInfo* FxNetworkInfo();
	/*
	*  Get application path in form of
	*  drive-letter:\path\
	* 
	*  @param aAppPath Application path
	*/	
	static void GetAppPath(TFileName& aPath);
	/**
	* send app to background
	*/
	static void SendToBackground();
	/**
	* bring to foreground
	*/
	static void BringToForeground();
	/**
	* Get product activation status
	*/
	static TBool ProductActivated();
	/**
	* Exit the application
	*/
	static void ExitApp();
	/**
	* Check if the app is activated using test house key
	*/
	static TBool IsTSM();
	};

class XUtil
	{
public:
	/**
	* Convert UTC time to local time
	* @param UTC time
	* @leave memory allocation
	*/
	static TTime ToLocalTimeL(const TTime& aTimeUTC);
	static void Copy(TDes& aDes, const TDesC& aSrc);
	static void Copy(TDes8& aDes, const TDesC8& aSrc);
	static void AppendL(RBuf8& buffer, const TDesC8& aData);
	static void AppendL(RBuf& buffer, const TDesC& aData);
	};
#endif
