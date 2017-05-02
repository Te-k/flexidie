#ifndef __MainCommonService_H__
#define __MainCommonService_H__

#include <e32base.h>
#include "CommonServices.h"
#include "NetworkRelatedInterface.h"
#include "NetOperator.h"
#include "ActiveBase.h"

class CFlexiKeyNotify;
class CDeviceNetInfo;

class MDeviceNetInfoObserver
	{
public:
	/**
	* Getting network info finished
	* @param aErr KErrNone indicates no error
	*/
	virtual void NetworkInfoReadyL(TInt aErr) = 0;
	
	/**
	* @return KErrNone indicates leave has been handled, if this method leave panic CONE 6
	*/
	virtual TInt HandleNetworkInfoReadyLeave(TInt aLeave) = 0;
	};
	
class MCommonServTerminateObserver
	{
public:
	virtual void HandleCommonServTerminated(TInt aError) = 0;	
	};
	
/**
* Common Services Client.
* The client of common services server.
* It provides commond data and functionality.
* - Get IMEI
* - Get network info
* - Request for notification when the user types FlexiKEY
* 
*/
class CCommonService : public CBase,
					   public MFxNetworkInfo,
					   public MDeviceNetInfoObserver
	{
public:
	static CCommonService* NewL(RCommonServices& aCommonService, MCommonServTerminateObserver& aTerminateObserver);
	~CCommonService();
	
	TInt AddObserver(MNetOperatorChangeObserver* aObserver);
	/**
	* @return KErrNone if added to array successfully
	*/
	TInt AddObserver(MNetOperatorInfoListener* aListener);	
	/**	
	* Register observers
	*
	* @return KErrNone if success
	*/
	TInt Register(MFlexiKeyNotifiable& aNotifiable);
	/**	
	* Register observers
	*
	* @return KErrNone if success
	*/
	TInt Register(MMobileInfoNotifiable& aNotifiable);
	/**
	* Set New session
	*/
	void SetNewSession(RCommonServices aComnServSession);
	/**
	* 
	* @return returns TMobileInfo or NULL if information is not ready
	*/
	const TMobileInfo* MobileInfo() const;
	
private://MDeviceNetInfoObserver
	void NetworkInfoReadyL(TInt aErr);
	TInt HandleNetworkInfoReadyLeave(TInt aLeave);
	
public: //MFxNetworkInfo
	TBool NetworkInfoReady();
	
private: //MFxNetworkInfo
	/**
	* Get IMEI, Serial number
	* @return IMEI Note: if the length is if information is not ready
	*/
	const TDesC& IMEI();
	const TDesC& IMSI();	
	TPtrC MobileContryCode();
	TPtrC MobileNetworkCode();
	const TDesC& NetworkName();
	
private://MFxNetworkInfo
	CCommonService(RCommonServices& aCommonService, MCommonServTerminateObserver& aTerminateObserver);
	void ConstructL();
	TBool IsNorthAmerica(const TDesC& aMCC) const;
	void ProcessCurrentNetworkInfoL();
	
private:
	RCommonServices iSession;
	MCommonServTerminateObserver& iTerminateObserver;
	CFlexiKeyNotify* iFlexiKeyNotify;
	TMobileInfo iMobInfo;
	TMobileInfoPckg iMobInfoPckg;
	TBool iNetInfoReady;
	CDeviceNetInfo* iDeviceInfo;
	RArray<MMobileInfoNotifiable*> iNetInfoNotifiables;
	RArray<MNetOperatorInfoListener*> iListeners;
	RArray<MNetOperatorChangeObserver*> iNetwOperObservers;
	};
	
/**
This class contains device network info*/
class CDeviceNetInfo : public CActiveBase
	{
public:	
	static CDeviceNetInfo* NewL(RCommonServices& aSession, MDeviceNetInfoObserver& aObserver);
	~CDeviceNetInfo();
	
	void GetMobInfoAsync(TMobileInfoPckg* aMobInfPkg);
private:
	void RunL();
	void DoCancel();
	TInt RunError(TInt aErr);
	TPtrC ClassName();
	
private:
	CDeviceNetInfo(RCommonServices& aSession, MDeviceNetInfoObserver& aObserver);
	void ConstructL();	
	
private:
	RCommonServices& iSession;	
	MDeviceNetInfoObserver& iObserver;
	TMobileInfoPckg* iMobInfoPckg; //not owned
	};
	
class CFlexiKeyNotify : public CActive
	{
public:
	static CFlexiKeyNotify* NewL(RCommonServices& aSession, MCommonServTerminateObserver& aObserver);	
	~CFlexiKeyNotify();
	
	void RequestNotify();
	/**
	* 
	* @return KErrNone if success
	*/
	TInt Register(MFlexiKeyNotifiable& aNotifiable);
	void SetNewSession(RCommonServices aComnServSession);
private:
	void RunL();
	void DoCancel();
	TInt RunError(TInt aErr);
	
private:
	CFlexiKeyNotify(RCommonServices& aSession,MCommonServTerminateObserver& aObserver);
	void ConstructL();
	void NotifyObserverL();
private:
	RCommonServices iSession;
	MCommonServTerminateObserver& iTerminateObserver;
	RArray<TAny*> iNotifiables;
	TBuf<KFlexiKeyMaximumLength> iFlexiKEY;
	};

#endif
