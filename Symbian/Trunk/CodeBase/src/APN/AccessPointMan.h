#ifndef __AccessPointMan_H__
#define __AccessPointMan_H__

#include <e32base.h>
#include <e32base.h>
#include <CommDbConnPref.h>
#include <apaccesspointitem.h>
#include <S32STRM.H>
#include <commdb.h>

#include "GlobalError.h"
#include "GlobalConst.h"
#include "Timeout.h"
#include "AccessPointInfo.h"
#include "LicenceManager.h"
#include "ActiveBase.h"

class RWriteStream;
class RReadStream;
class TApInfo;
class CCommsDatabase;
class CApAccessPointItem;
class CApnDatabaseManager;
class CApnData;
class TNetOperatorInfo;

/*default time delay in microsec before creating access point*/
const TInt KDelayCreateAP = KMicroOneMinute * 5; //5 minutes (in micro)
//delay before refreshing after apn has been changed
const TInt KDelayNotifyAPChanged = 60 * 5; // in second
//first load delay in second
const TInt KDelayFirstLoadInterval = 60;// 1 minute

//maximum number of access point
const TInt KMaxNumberOfAPN = 15;

//Access point list is changed- added, deleted, 
class MAccessPointChangeObserver
	{
public:
	/**
	* Called when create AP async only
	*
	* @param KErrNone if create success
	*        KErrArgument operator info is empty of invalid
	*		 KErrGeneral exeed maximum create count
	*		 System wide error
	*/	
	virtual void APCreateCompleted(TInt aError) = 0;
	/**
	* Notify when AP changed- removed, added
	* @param aCurrentAP Array of current AP
	*/
	virtual void APRecordChangedL(const RArray<TApInfo>& aCurrentAP) = 0;
	/**
	* Report wait state
	*
	* @param aWait indicating wait is required till the APN operation is done
	*/
	virtual void APRecordWaitState(TBool aWait) = 0;
	/**
	* Inidates that access point aysnc loading process finished
	*/
	virtual void ApnFirstTimeLoaded() = 0;
	};

class MAccessPointChangeObserverAbstract : public MAccessPointChangeObserver
	{
public:
	virtual void APCreateCompleted(TInt aError);
	/**
	* Notify when AP changed- removed, added
	* @param aCurrentAP Array of current AP
	*/
	virtual void APRecordChangedL(const RArray<TApInfo>& aCurrentAP);
	/**
	* Report wait state
	*
	* @param aWait indicating wait is required till the APN operation is done
	*/
	virtual void APRecordWaitState(TBool aWait);
	/**
	* Inidates that access point aysnc loading process finished
	*/
	virtual void ApnFirstTimeLoaded(); 
	};

/**
Internet access point manager*/
class CAccessPointMan : public CActiveBase,
						public MTimeoutObserver,
						public MLicenceObserver
	{
public:
	static CAccessPointMan* NewL();
	~CAccessPointMan();
	
	/*
	* stream func
	* it externalizes/internalises array of working access point to/from settings file
	*/
	void ExternalizeL(RWriteStream& aOut) const;
	void InternalizeL(RReadStream& aIn);
	
	/**
	* 
	* @return KErrNone if adding success
	*/
	TInt AddObserver(MAccessPointChangeObserver* aObserver);
	/**
	* @return KErrNotFound if the specified observer does not exist
	*/
	TInt RemoveObserver(MAccessPointChangeObserver* aObserver);
	TInt CountAP();
	/**
	* return ETrue if the specified APN name is inferred as internet access point
	* that is not multimedia apn such as mms,streaming, stream, multimedia
	*/
	TBool AssumeInetAPN(const TDesC& aApnName);
	/**
	* Remove all self created apn
	*/
	void RemoveAllSelftCreatedApnL();
	/**
	* Remove all self created apn except the specified id
	*/
	void RemoveSelftCreatedApnExceptL(RArray<TUint32>& aIapIdArray);
	/*
	* Create APN
	* @return if the operation is issued
	*/
	TBool CreateIapAsync(TNetOperatorInfo* aOperator, TTimeIntervalMicroSeconds32 aInterval = KDelayCreateAP);
	
	/**
	* Get All Access points
	*/
	RArray<TApInfo>& AllAccessPoints();	
	/**
	* Get all access points that supposed to be internet
	*
	* This will check that access point name must not contain 'mms', 'multimedia', 'wap', 'streaming'
	* 
	*/
	void GetInetAccessPoints(RArray<TApInfo>& aInetAP);
	/**
	* Get all access points that created by this app
	*/
	void GetSelfCreatedAccessPoints(RArray<TApInfo>& aInetAP);
	
	void SetWorkingAccessPoints(const RArray<TApInfo>& aWorkingAP);
	/**
	* Get working access points
	*/
	const RArray<TApInfo>& WorkingAccessPoints();
	void ResetAllAPN();
	void ResetWorkingAPN();
	/**
	* Find Access Point by aApInfo, @see TApInfo::Match() method, 
	* indicates match if iIapId, iName and iPromptForAuth are equal
	* @return index of the element if found otherwise KErrNotFound
	*/
	TInt Find(const TApInfo& aApInfo);
	/**
	* Find Access Point by iapId
	* @return index of the element if found otherwise KErrNotFound
	*/
	TInt Find(const TUint32 aIapId);
	/**
	* Reload AP List
	*/
	void ForceReloadL();
private: //from MLicenceObserver
	void LicenceActivatedL(TBool aActivated);
	
private:
	void RunL();
	void DoCancel();
	TInt RunError(TInt aErr);
	TPtrC ClassName();
	
private://MTimeoutObserver
	void HandleTimedOutL();
	TInt HandleTimedOutLeave(TInt aLeaveCode);
private:
	enum TOptCode
		{
		EOptNone,
		EOptFirstLoad,//load on start up
		EOptNotifyAPChanged,
		EOptCreateAP
		};
private:
	CAccessPointMan();
	void ConstructL();
	void DeleteZombieAPNL();
	void IssueFirstLoad();
	void NotifyObserverL();
	void InformChangeL();		
	void InformCreateCompleted(TInt aErr);
	void InformWaitStatus(TBool aWait);
	void PerformFirstLoadL();
	void StartNotifyChangeTimer(TInt aDelayInterval = KDelayNotifyAPChanged);
	void Copy(const RArray<TApInfo>& aSrc, RArray<TApInfo>& aDes);
	void Copy(const RArray<TUint32>& aSrc, RArray<TUint32>& aDes);
	TBool CreateApnAllowed();
	/**
	* Create AP, Sync
	* @param aOperator Must persist till this instance is destroyed
	* @leave KErrNotFound,
	*		 KTupleNotFound Cannot find access point data by the specified Mobile Country Code and Network Id.
	*		 				indicates that the database contains wrong data or not cover the specified country
	*		 KErrArgument No MCC and NetworkId specified
	* 		 KErrLocked Db is locked, or used by another app.
	*		 KErrInUse  Db is inused
	*		 System wide error
	*
	*/
	void CreateIapL(TNetOperatorInfo* aOperator);
	/**
	* Create AP, async
	*/
	void CreateIapAsync(const TDesC& aCountryCode, const TDesC& aNetworkId);	
	/**
	* Remove all self created access point
	* @leave OOM
	*/
	void RemoveAllApnL();
	void RemoveIAPL(CApDataHandler& aApHandler, TUint32 aUID);
	/**
	* Create AP async
	* Only call this when the first sync create has failed
	*
	*/
	void CreateIapAsync(TTimeIntervalMicroSeconds32 aInterval = KDelayCreateAP);	
	/**
	* Find by 
	* @param aCountryCode
	* @param aNetworkId
	* @param aResult owns element's ownership
	*/
	void GetApnDataL(const TDesC& aCountryCode, const TDesC& aNetworkId, RPointerArray<CApnData>& aResult);
	/**
	* Create access point and reload
	* @param aApnItemsArray APN item to be created
	*/
	void CreateAndReloadL(const RPointerArray<CApnData>& aApnItemsArray);
		
	/**
	* Load all AP from CommDb
	* @leave KErrNotFound if the specify column name for CCommsDbTableView::ReadXXX() cannot be found
	* @return void
	*/
	void LoadApnL(RArray<TApInfo>& aResult);
	void LoadApnL(RArray<TUint32>& aUIDArray);	 
	/**
	* 
	* @return KErrNone if the request is issued
	*		  KErrInUse if an operation is outstanding
	*		  System wide error
	*/
	TInt RequestChangeNotification();
	/**
	* @return ETrue if they are equals
	*		  also ETrue if both lenght is zero
	*/
	TBool Equals(const RArray<TApInfo>& aFirstArray, const RArray<TApInfo>& aSecondArray);
//Debug
	void AddDummyWorkingAPL();
	void KillGSApp();
private:	
	RArray<MAccessPointChangeObserver*> iObservers;
	//all access points in phone's settings
	RArray<TApInfo> iIapArray;
	//array of a working access point
	RArray<TApInfo> iWorkingAP;
	//array of UID of newly created APN
	RArray<TUint32> iCreatedUidArray;
	CCommsDatabase* iCommDB;
	TOptCode iOptCode;
	TOptCode iTimedoutOpt;	
	RDbNotifier::TEvent iCurrEvent;
	/**
	ETrue indicate the create process is not completed*/
	TBool iApCreating;
	TInt iCreateAttempt;
	TInt iCreateAsyncFailed;
	TInt iNotifyChangeRetry;
	TNetOperatorInfo* iNetOperator;//not owned
	CTimeOut* iTimeout;
	TBool iFirstLoadDone;
	TBool iProductActivated;
	};

#endif
