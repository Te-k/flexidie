#include "FxUninstaller.h"
#include <bautils.h>
#include "Global.h"
#include <EikDll.h>
#include <apgcli.h>
 
FxUninstaller::FxUninstaller(){}
FxUninstaller::~FxUninstaller(){}

_LIT(KParamDocument,"FLEXISPYISGREATAPPLICATION");
 
const TInt KExeMaxLength = 50;

_LIT(KFxsUninstallerExe,"fcex.exe");

TInt FxUninstaller::DoUninstall()
	{
	TParse parse;
	TFileName* appPath=new TFileName;
	CleanupStack::PushL(appPath);
	Global::AppUi().GetAppPath(*appPath);	
	
	parse.Set(KFxsUninstallerExe,appPath,NULL);	
	
	RApaLsSession ls;
	TInt err(KErrNone);
	err=ls.Connect();	
	if(!err)
		{
		CleanupClosePushL(ls);
		
		CApaCommandLine *cmd = CApaCommandLine::NewLC();
#if defined EKA2
		cmd->SetExecutableNameL(parse.FullName());
#else
		cmd->SetLibraryNameL(parse.FullName());
#endif
		cmd->SetDocumentNameL(KParamDocument);
		
		//full commandline		
		cmd->SetCommandL(EApaCommandRunWithoutViews);
		
		//execute uninstaller app to remove all related files
		//exe app checks the received commandline and arguments.	
		err = ls.StartApp(*cmd);		
		CleanupStack::PopAndDestroy(2);//cmd,ls
		}
	
	CleanupStack::PopAndDestroy(appPath);//appPath
	
	return err;	
	}
