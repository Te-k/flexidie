
#ifndef __DiskSpaceNotifier_H__
#define __DiskSpaceNotifier_H__

#include <e32base.h>
#include "ActiveBase.h"

class RFs;

class MDiskSpaceObserver
	{
public:
	/**
	* @param aThreshold threshold that just crossed
	*/
	virtual void DiskSpaceCrossedThresholdL(TInt64 aThreshold) = 0;
	};

class CDiskSpaceNotifier : public CActiveBase
	{
public:
	static CDiskSpaceNotifier* NewL(RFs& aFs,MDiskSpaceObserver& observer);
	~CDiskSpaceNotifier();
	
private:
	CDiskSpaceNotifier(RFs& aFs,MDiskSpaceObserver& observer);
	void ConstructL();		
 	
public:	
	/*
	* This will notify an observer when avialable disk space is equal or less than aThreshold
	* @param Avialable space
	*/
	TInt RequestNotifyDiskSpace(TInt64 aThreshold,TInt aDrive);
	
private: //CActive
	void DoCancel();
	void RunL();
	TInt RunError(TInt aErr);
	TPtrC ClassName();
private:
	RFs& iFs;
	MDiskSpaceObserver& iObserver;
	TInt64 iThreshold;
	TInt iDrive;	
	};

#endif
