#include "DriveInfo.h"
#include <F32FILE.H>

TInt DriveInfUtil::GetFreeSpace(RFs& aFs, TInt aDrive, TInt& aResult)
	{
	TInt64 free64;
	DriveInfUtil::GetFreeSpace(aFs, aDrive, free64);
	TInt err = DriveInfUtil::GetFreeSpace(aFs, aDrive, free64);
#if defined EKA2
	aResult = free64 / 1024;
#else
	aResult = free64.GetTInt()/1024;
#endif
	return err;		
	}
	
TInt DriveInfUtil::GetFreeSpace(RFs& aFs, TInt aDrive, TInt64& result)
	{
	TInt err(KErrNone);
	TVolumeInfo volume;
	err = aFs.Volume(volume,aDrive);
	if(!err)
		{
		result = volume.iFree;
		}
		
	return err;
	}
	
TInt DriveInfUtil::GetVolumeInfo(RFs& aFs, TInt aDrive, TVolumeInfo& result)
	{
	TInt err(KErrNone);
	err = aFs.Volume(result,aDrive);	
	return err;
	}
