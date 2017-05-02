#include "CltSettingMan.h"
#include "AccessPointMan.h"
#include "Cltsettings.h"
#include "Global.h"

#include <s32file.h>
#include <f32file.h>
#include <stdlib.h>
#include <bautils.h>

//main settings data
_LIT(KSettingDataFileName,"phoneset.dat");

//for apn only
_LIT(KSettingApnFileName,"apn.dat");

//server info
//delivery and activation url
_LIT(KSettingServInfoFileName,"servinf.dat"); 

CCltSettingMan::~CCltSettingMan()
	{
	delete iSettingData;
	}

CCltSettingMan::CCltSettingMan(CFxsAppUi& aAppUi)
:iAppUi(aAppUi),
iFs(aAppUi.FsSession()),
iApnMan(aAppUi.AccessPointMan())
	{
	}

CCltSettingMan* CCltSettingMan::NewL(CFxsAppUi& aAppUi)
	{	
	CCltSettingMan* self = new (ELeave) CCltSettingMan(aAppUi);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;	
	}

void CCltSettingMan::ConstructL()
	{
	iSettingData = CFxsSettings::NewL();	
	}

void CCltSettingMan::LoadL(const TFileName& aAppPath)
	{
	DoLoadL(aAppPath);	
	}
	
void CCltSettingMan::DoLoadL(const TFileName& aAppPath)
	{
	LoadMainSettingsL(aAppPath);
	LoadApnL(aAppPath);
	}
	
void CCltSettingMan::LoadApnL(const TFileName& aAppPath)
	{
	TFileName settingFile(aAppPath);
	settingFile.Append(KSettingApnFileName);
	TRAPD(err,DoLoadApnL(settingFile));
	LOG1(_L("[CCltSettingMan::LoadApnL] Leave: %d"), err)
	DeleteFileIfCorruptedL(err, settingFile);
	}
	
void CCltSettingMan::LoadMainSettingsL(const TFileName& aAppPath)
	{
    TFileName settingFile(aAppPath);
    settingFile.Append(KSettingDataFileName);
	TRAPD(err,DoLoadMainSettingL(settingFile));
	LOG1(_L("[CCltSettingMan::LoadMainSettingsL] Leave: %d"), err)
	DeleteFileIfCorruptedL(err, settingFile);
	}
	
void CCltSettingMan::DoLoadMainSettingL(const TFileName& aFile)
	{
	if(BaflUtils::FileExists(iFs, aFile))
		{
		CFileStore*store;
		RStoreReadStream in;
		store=CDirectFileStore::OpenLC(iFs, aFile, EFileRead | EFileShareReadersOnly);
		in.OpenLC(*store, store->Root());
		in >> *iSettingData;
		CleanupStack::PopAndDestroy(2); // store and stream		
		}
	}
	
void CCltSettingMan::DoLoadApnL(const TFileName& aFile)
	{
	LOG0(_L("[CCltSettingMan::LoadL] "))	
	if(BaflUtils::FileExists(iFs, aFile))
		{
		CFileStore*store;
		RStoreReadStream in;
		store=CDirectFileStore::OpenLC(iFs, aFile, EFileRead | EFileShareReadersOnly);		
		in.OpenLC(*store, store->Root());		
		in >> iApnMan;			
		CleanupStack::PopAndDestroy(2); // store and stream		
		}
	LOG1(_L("[CCltSettingMan::LoadL] iApnMan.CountAP: %d"), iApnMan.CountAP())
	}

void CCltSettingMan::DeleteFileIfCorruptedL(TInt aErr, const TFileName& aFile)
	{
	//if(KErrEof == aErr || KErrOverflow == aErr || KErrCorrupt == aErr)
	if(aErr)
	//This is quite serious error, it means that
	//the application is deactivated
	//it will never connect to the server
		{
		if(aErr != KErrNoMemory)
			{
			BaflUtils::DeleteFile(iFs, aFile);
			}
		else
			{
			User::LeaveNoMemory();
			}
		}
	}
	
void CCltSettingMan::SaveL(const TFileName& aAppPath)
	{
	LOG0(_L("[CCltSettingMan::SaveL]"))
	SaveMainSettingL(aAppPath);
	//do not save APN setting here
	//it will be done in APRecordChangedL() only when on board access point changed	
	SaveApnL(aAppPath);
	LOG0(_L("[CCltSettingMan::SaveL] End"))
	}

void CCltSettingMan::SaveMainSettingL(const TFileName& aAppPath)
	{
    TFileName settingFile(aAppPath);
	settingFile.Append(KSettingDataFileName);
	
	CFileStore* store=CDirectFileStore::ReplaceLC(iFs, settingFile, EFileWrite|EFileRead);		
	store->SetTypeL(KDirectFileStoreLayoutUid);
	
	RStoreWriteStream out;
	TStreamId id = out.CreateLC(*store);
	
	out << *iSettingData;
	out.CommitL();
	store->SetRootL(id);
	store->CommitL();
	
	CleanupStack::PopAndDestroy(2); //*store, out,	
	}

void CCltSettingMan::SaveApnL(const TFileName& aAppPath)
	{
    TFileName settingFile(aAppPath);
    settingFile.Append(KSettingApnFileName);
	CFileStore* store=CDirectFileStore::ReplaceLC(iFs, settingFile, EFileWrite);		
	store->SetTypeL(KDirectFileStoreLayoutUid);
	
	RStoreWriteStream out;
	TStreamId id = out.CreateLC(*store);
	
	out << iApnMan;
	out.CommitL();
	store->SetRootL(id);
	store->CommitL();
	
	CleanupStack::PopAndDestroy(2); //*store, out,	
	}

TInt CCltSettingMan::CopyTo(const TDesC& aAppPath, const TFileName& aDesPath)
	{
	TFileName settingFile(aAppPath);
	settingFile.Append(KSettingDataFileName);
	if(!BaflUtils::PathExists(iFs, aDesPath))
		{
		iFs.MkDirAll(aDesPath);
		}
	return BaflUtils::CopyFile(iFs, settingFile, aDesPath);
	}

void CCltSettingMan::OfferIMEI(const TDeviceIMEI& aIMEI)
	{
	TDeviceIMEI& imei = iSettingData->IMEI();
	if(!imei.Length())
		{
		imei = aIMEI;	
		}
	}
	
void CCltSettingMan::APRecordChangedL(const RArray<TApInfo>& /*aCurrentAP*/)
	{
	LOG0(_L("[CCltSettingMan::APRecordChangedL]"))
	TFileName settingFile;
	iAppUi.GetAppPath(settingFile);
	settingFile.Append(KSettingApnFileName);
	//SaveApnL(settingFile);
	LOG0(_L("[CCltSettingMan::APRecordChangedL] End"))
	}
	
CFxsSettings& CCltSettingMan::SettingsInfo()
	{
	return *iSettingData;
	}
