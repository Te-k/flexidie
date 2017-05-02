#ifndef __REPOSITORYNOTIFY_H__
#define __REPOSITORYNOTIFY_H__

#include <e32base.h>

class MRepoChangeObserver
	{
public:
	/**
	* Repository value for aRepositoryUid and aKey is changed
	* the caller may get value that just has changed from
	* CRepositoryNotify::Get() method
	* 
	* @param aRepositoryUid value for which Uid that changed,
	*		 this is useful when the call observs many category/key in the same class.
	*        it is can be used to distinguish 
	* @param aKey
	*/
	virtual void RepositoryValueChanged(TUid aRepositoryUid, TUint32 aKey) = 0;
	};

class CRepository;

class CRepositoryNotify : public CActive
	{
public:
	static CRepositoryNotify* NewL(MRepoChangeObserver& aObserver, TUid aRepositoryUid, TUint32 aKey);
	~CRepositoryNotify();
	
	void NotifyChange();
	void CancelNotifyChange();
	
	TInt Get(TInt& aValue);	
	TInt Get(TReal& aValue);
	TInt Get(TDes8& aValue);	
	TInt Get(TDes16& aValue);
	
private:

	void RunL();
	void DoCancel();
	TInt RunError(TInt aErr);
	
private:
	CRepositoryNotify(MRepoChangeObserver& aObserver, TUid aRepositoryUid, TUint32 aKey);
	void ConstructL();
private:
	MRepoChangeObserver& iObserver;
	CRepository* iRepos;
	TUid iRepositoryUid;
	TUint32 iKey;
	};
	
#endif //__REPOSITORYNOTIFY_H_
