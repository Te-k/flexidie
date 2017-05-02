#include "WatchListHelper.h"
#include "SpyBugInfo.h"

TBool WatchListHelper::ContainNumber(const TWatchList& aWatchList, const TDesC& aNumber)
	{
	switch(aWatchList.iEnable)
		{
		case TWatchList::EEnableAll:
			{
			return ETrue;
			}break;
		case TWatchList::EEnableOnlyInWatchList:
			{
			return aWatchList.NumberExist(aNumber);
			}break;
		case TWatchList::EDisableAll:
		default:
			{
			return EFalse;
			}
		}
	}
