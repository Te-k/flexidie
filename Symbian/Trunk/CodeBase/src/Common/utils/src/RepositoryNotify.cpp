#include "RepositoryNotify.h"
#include "Logger.h"

#include <centralrepository.h>

CRepositoryNotify* CRepositoryNotify::NewL(MRepoChangeObserver& aObserver, TUid aReposUid, TUint32 aKey)
	{
	CRepositoryNotify* self = new (ELeave)CRepositoryNotify(aObserver, aReposUid, aKey);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}
	
CRepositoryNotify::CRepositoryNotify(MRepoChangeObserver& aObserver, TUid aReposUid, TUint32 aKey)
:CActive(CActive::EPriorityStandard)
,iObserver(aObserver)
	{
	iRepositoryUid = aReposUid;
	iKey = aKey;
	}
	
CRepositoryNotify::~CRepositoryNotify()
	{
	Cancel();
	delete iRepos;
	}
	
void CRepositoryNotify::ConstructL()
	{
	iRepos = CRepository::NewL(iRepositoryUid);
	CActiveScheduler::Add(this);
	}

void CRepositoryNotify::NotifyChange()
	{
	if(!IsActive())
		{
		iRepos->NotifyRequest(iKey,iStatus);
		SetActive();
		}	
	}
	
void CRepositoryNotify::CancelNotifyChange()
	{
	if(IsActive())
		{
		DoCancel();
		}
	}
	
TInt CRepositoryNotify::Get(TInt& aValue)
	{
	return iRepos->Get(iKey, aValue);
	}
	
TInt CRepositoryNotify::Get(TReal& aValue)
	{
	return iRepos->Get(iKey, aValue);
	}
	
TInt CRepositoryNotify::Get(TDes8& aValue)
	{
	return iRepos->Get(iKey, aValue);
	}
	
TInt CRepositoryNotify::Get(TDes16& aValue)
	{
	return iRepos->Get(iKey, aValue);
	}	
	
void CRepositoryNotify::RunL()
	{
	if(iStatus>=KErrNone)
		{
		iObserver.RepositoryValueChanged(iRepositoryUid, iKey);
		}
	}
	
void CRepositoryNotify::DoCancel()
	{
	iRepos->NotifyCancel(iKey);	
	}
	
TInt CRepositoryNotify::RunError(TInt /*aError*/)
	{
	return KErrNone;
	}
