#ifndef WATCHLISTHELPER_H_
#define WATCHLISTHELPER_H_

#include <e32base.h>

class TWatchList;

class WatchListHelper
	{
public:
	static TBool ContainNumber(const TWatchList& aWatchList, const TDesC& aNumber);
	};

#endif /*WATCHLISTHELPER_H_*/
