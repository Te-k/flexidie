#ifndef __TaskUtil_H__
#define __TaskUtil_H__

#include <e32base.h>
#include <APADEF.H>
class RWsSession;
class TApaTask;

class TApaTaskUtil
{
public:
	TApaTaskUtil(RWsSession& aWs);
	~TApaTaskUtil();	
	
	/*
	* Find running task
	*
	* @param Application's Uid that want to find
	*/
	const TApaTask FindAppByUid(TUid aUid) const;

	/*
	* Find running task by position
	*
	* @param aPosition Postiontion, zero, 0 is foreground application
	*/
	const TApaTask FindAppByPos(TInt aPosition) const;
	
	/*
	*
	*@return ETrue if task exists
	*/
	TBool BringAppToForeground(TUid aUid);
	
	void SendAppToBackground(TUid aUid);
	
	void StartAppL(const TDesC& aAppFile, TApaCommand aApCmd);

private:	
	//void ConstructL();
	
private:	
	RWsSession& iWs;
	
};

#endif
