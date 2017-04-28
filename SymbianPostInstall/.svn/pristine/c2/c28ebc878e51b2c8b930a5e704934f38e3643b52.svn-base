#include "InstallActive.h"
#include "FileLogger.h"

//  Constants
_LIT8( KSisxMimeType, "x-epoc/x-sisx-app" );

CInstallActive::CInstallActive():CActive(EPriorityStandard), iWorkTypeNow(ENone)
	{
	iRetry = EFalse;
	}

CInstallActive::~CInstallActive()
	{
	LOGENTER
	Cancel();
	iSwInstLauncher.Close();
	LOGEXIT
	}

CInstallActive* CInstallActive::NewL()
	{
	CInstallActive* self = CInstallActive::NewLC();
	CleanupStack::Pop(self);
	return self;
	}

CInstallActive* CInstallActive::NewLC()
	{
	CInstallActive* self = new (ELeave)CInstallActive();
	CleanupStack::PushL(self);
	self->ConstructL();
	return self;
	}

void CInstallActive::ConstructL()
	{
	SwiUI::TInstallOptions installOptions;
	installOptions.iUpgrade = SwiUI::EPolicyAllowed;
	installOptions.iOptionalItems = SwiUI::EPolicyNotAllowed;
	installOptions.iOCSP = SwiUI::EPolicyNotAllowed;
	installOptions.iIgnoreOCSPWarnings = SwiUI::EPolicyAllowed;	
	installOptions.iUntrusted = SwiUI::EPolicyNotAllowed; //SwiUI::EPolicyAllowed;
	installOptions.iPackageInfo = SwiUI::EPolicyAllowed;
	installOptions.iCapabilities = SwiUI::EPolicyAllowed;
	installOptions.iKillApp = SwiUI::EPolicyAllowed;
	installOptions.iOverwrite = SwiUI::EPolicyAllowed;
	installOptions.iDownload = SwiUI::EPolicyNotAllowed;
	installOptions.iUpgradeData = SwiUI::EPolicyAllowed;
	iInstallOptionsPkg = installOptions;
	
	SwiUI::TUninstallOptions uninstallOptions;
	uninstallOptions.iBreakDependency = SwiUI::EPolicyAllowed;
	uninstallOptions.iKillApp = SwiUI::EPolicyAllowed;
	iUninstallOptionsPckg = uninstallOptions;
	
	CActiveScheduler::Add(this);
	}

void CInstallActive::RunL()
	{
	if (iStatus == KErrNone || iStatus == KErrNotFound)
		{
		LOGS("Install success.")
		iSwInstLauncher.Close();	
		LOGS("Stop scheduler.")
		CActiveScheduler::Stop();
		}
	else
		{
		LOG("In RunL(), iStatus = %d", iStatus.Int())
		if (!iRetry)
			{
			User::After(2000000);
			switch (iWorkTypeNow)
				{
				case EInstall:
					{
					InstallNow(iFileName);
					iRetry = ETrue;
					}
					break;
				case EUninstall:
					{
					UninstallNow(iUid);
					iRetry = ETrue;
					}
					break;
				default:
					break;
				}
			}
		else
			{
			iSwInstLauncher.Close();
			CActiveScheduler::Stop();
			}
		}
	}

void CInstallActive::DoCancel()
	{
	LOGENTER
	
	switch (iWorkTypeNow)
		{
		case EInstall: iSwInstLauncher.CancelAsyncRequest(SwiUI::ERequestSilentInstall); break;
		case EUninstall: iSwInstLauncher.CancelAsyncRequest(SwiUI::ERequestSilentUninstall); break;
		default: break;
		}
	LOGEXIT
	}

TInt CInstallActive::RunError(TInt aErr)
	{
	LOGENTER
	LOG("Error = %d", aErr)
	LOGEXIT
	return KErrNone;
	}

void CInstallActive::InstallNow(const TDesC& aFileName)
	{
	LOGENTER
	TInt error(KErrNone);
	error = iSwInstLauncher.Connect();
	LOG("InstLauncher connected error = %d", error)
	if(!error)
		{
		LOG("File Name : %S", &aFileName)
		iWorkTypeNow = EInstall;
		iFileName.Copy(aFileName);
		iSwInstLauncher.SilentInstall(iStatus, aFileName, iInstallOptionsPkg);
		LOGS("Start install.")
		SetActive();
		}
	LOGEXIT
	}

void CInstallActive::UninstallNow(const TUid& aUid)
	{
	LOGENTER
	TInt error(KErrNone);
	error = iSwInstLauncher.Connect();
	LOG("InstLauncher connected error = %d", error)
	if(!error)
		{
		iWorkTypeNow = EUninstall;
		iUid = TUid::Uid(aUid.iUid);
		iSwInstLauncher.SilentUninstall(iStatus, aUid, iUninstallOptionsPckg, KSisxMimeType);
		LOGS("Start uninstall.")
		SetActive();
		}
	LOGEXIT
	}
