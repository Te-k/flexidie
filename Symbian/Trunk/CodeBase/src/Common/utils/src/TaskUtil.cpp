#include "TaskUtil.h"

#include <W32STD.H>
#include <APGTASK.H>
#include <APGCLI.H>
#include <APACMDLN.H>

TApaTaskUtil::TApaTaskUtil(RWsSession& aWs)
:iWs(aWs)
{
}

TApaTaskUtil::~TApaTaskUtil()
{
}

const TApaTask TApaTaskUtil::FindAppByUid(TUid aUid) const
{	
	TApaTaskList taskList(iWs);
	return taskList.FindApp(aUid);	
}

const TApaTask TApaTaskUtil::FindAppByPos(TInt aPosition) const
{	
	TApaTaskList taskList(iWs);
	return taskList.FindByPos(aPosition);
}

TBool TApaTaskUtil::BringAppToForeground(TUid aUid)
{	
	TApaTask task = FindAppByUid(aUid);
	if(task.Exists()) {
		task.BringToForeground();
		return ETrue;
	}
	
	return EFalse;
}

void TApaTaskUtil::SendAppToBackground(TUid aUid)
{
	TApaTask task = FindAppByUid(aUid);
	if(task.Exists())
		task.SendToBackground();		
}

void TApaTaskUtil::StartAppL(const TDesC& aAppFile, TApaCommand aApCmd)
{	
    RApaLsSession ls;
    User::LeaveIfError(ls.Connect());
	CleanupClosePushL(ls);
	CApaCommandLine *cmd = CApaCommandLine::NewLC();

#if defined EKA2
	cmd->SetExecutableNameL(aAppFile);
#else
	cmd->SetLibraryNameL(aAppFile);
#endif	
	cmd->SetCommandL(aApCmd);
	
	User::LeaveIfError(ls.StartApp(*cmd));
	
	CleanupStack::PopAndDestroy(2);		
}
	
