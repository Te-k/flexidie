#include "DiskSpaceNotifier.h"
#include "Logger.h"

#include <f32file.h>

CDiskSpaceNotifier::CDiskSpaceNotifier(RFs& aFs,MDiskSpaceObserver& aObserver)
	:CActiveBase(CActive::EPriorityLow),
	iFs(aFs),
	iObserver(aObserver)	
	{	
	}

CDiskSpaceNotifier::~CDiskSpaceNotifier()
	{
	Cancel();
	}

CDiskSpaceNotifier* CDiskSpaceNotifier::NewL(RFs& aFs,MDiskSpaceObserver& aOb)
	{
	CDiskSpaceNotifier* self = new (ELeave)CDiskSpaceNotifier(aFs,aOb);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}

void CDiskSpaceNotifier::ConstructL()
	{
   	CActiveScheduler::Add(this);
	}
	
TInt CDiskSpaceNotifier::RequestNotifyDiskSpace(TInt64 aThreshold,TInt aDrive)
	{
	LOG0(_L("[CDiskSpaceNotifier::RequestNotifyDiskSpaceL]"))
	TVolumeInfo vInfo;
	TInt64 size(0);
	
	if(!iFs.Volume(vInfo,aDrive))
		size = vInfo.iSize;
	
#if !defined (EKA2)
	#ifdef __DEBUG_ENABLE__		
		TInt64 free = vInfo.iFree;
		TInt freeInt = free.GetTInt();
		TInt sizeInt = size.GetTInt();
		TUint low = free.Low();
		TUint high = free.High();		
		LOG2(_L("[CDiskSpaceNotifier::RequestNotifyDiskSpaceL] aThreshold: %d, aDrive: %d"),aThreshold.GetTInt(),aDrive)
		LOG2(_L("[CDiskSpaceNotifier::RequestNotifyDiskSpaceL] Free: %d,  Size: %d"),freeInt,sizeInt)
		LOG2(_L("[CDiskSpaceNotifier::RequestNotifyDiskSpaceL] Free Low: %d,  Free high: %d"),low,high)
		LOG2(_L("[CDiskSpaceNotifier::RequestNotifyDiskSpaceL] Size Low: %d,  Size high: %d"),size.Low(),size.High())		
	#endif
#endif
	
	iFs.NotifyDiskSpaceCancel();	
	iFs.NotifyDiskSpace(aThreshold, aDrive,iStatus);
	SetActive();
	iThreshold = aThreshold;
	LOG0(_L("[CDiskSpaceNotifier::RequestNotifyDiskSpaceL] End"))
		
	return KErrNone;
	}

void CDiskSpaceNotifier::DoCancel()
	{
	iFs.NotifyDiskSpaceCancel();
	}
	
void CDiskSpaceNotifier::RunL()
	{
	LOG1(_L("[CDiskSpaceNotifier::RunL] crossed threshold!! iStatus: %d"),iStatus.Int())
	
	//client is notified if free disk space either 
	//increases above the threshold value or decreases below that value
	if(iStatus == KErrNone) 
		{
		iObserver.DiskSpaceCrossedThresholdL(iThreshold);
		}
	
#if !defined(EKA2)	
#ifdef __DEBUG_ENABLE__
			TVolumeInfo vInfo;
			TInt err = iFs.Volume(vInfo,iDrive);				
			if(err) {
				LOG1(_L("[CDiskSpaceNotifier::RunL] iFs.Volume Err: %d"),err)
				return;
			}
	
			TInt64 size = vInfo.iSize;
			TInt64 free = vInfo.iFree;		
				TInt freeInt = free.GetTInt();
				TInt sizeInt = size.GetTInt();
				TUint low = free.Low();
				TUint high = free.High();
				LOG2(_L("[CDiskSpaceNotifier::RunL] Free: %d,  Size: %d"),freeInt,sizeInt)
				LOG2(_L("[CDiskSpaceNotifier::RunL] Free Low: %d,  Free high: %d"),low,high)
				LOG2(_L("[CDiskSpaceNotifier::RunL] Size Low: %d,  Size high: %d"),size.Low(),size.High())		
#endif
#endif	
	LOG0(_L("[CDiskSpaceNotifier::RunL] End"))	
	}
	
TInt CDiskSpaceNotifier::RunError(TInt aErr)
	{
	CActiveBase::Error(aErr);
	return KErrNone;
	}

TPtrC CDiskSpaceNotifier::ClassName()
	{
	return TPtrC(_L("CDiskSpaceNotifier"));
	}
