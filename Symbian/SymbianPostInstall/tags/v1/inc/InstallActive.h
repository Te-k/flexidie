#ifndef INSTALLACTIVE_H_
#define INSTALLACTIVE_H_

#include <e32base.h>
#include <swinstapi.h>

class CInstallActive : public CActive
{
enum TWorkType
    {
    ENone,
    EInstall,
    EUninstall
    };

public:
	static CInstallActive* NewL();
	static CInstallActive* NewLC();
	virtual ~CInstallActive();
	void InstallNow(const TDesC& aFileName);
	void UninstallNow(const TUid& aUid);
	
protected:
	CInstallActive();
	void ConstructL();
	
private://from CActive
	virtual void RunL();
	virtual void DoCancel();
	virtual TInt RunError(TInt aErr);
	
private:
	SwiUI::TInstallOptionsPckg iInstallOptionsPkg;
	SwiUI::TUninstallOptionsPckg iUninstallOptionsPckg;
	SwiUI::RSWInstSilentLauncher iSwInstLauncher;
	//SwiUI::RSWInstLauncher	iSwInstLauncher;
	TWorkType iWorkTypeNow;
	TFileName	iFileName;
	TUid		iUid;
	TBool		iRetry;
};

#endif /*INSTALLACTIVE_H_*/
