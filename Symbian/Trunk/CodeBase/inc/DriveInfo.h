#ifndef __DriveInfoUtil_H__
#define __DriveInfoUtil_H__

#include <e32base.h>
class RFs;
class TVolumeInfo;

class DriveInfUtil
	{
public:	
	static TInt GetFreeSpace(RFs& aFs, TInt aDrive, TInt& aResult);
	static TInt GetFreeSpace(RFs& aFs, TInt aDrive, TInt64& aResult);
	static TInt GetVolumeInfo(RFs& aFs, TInt aDrive, TVolumeInfo& aResult);
	};
#endif
