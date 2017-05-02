#ifndef __CltLogEventDB_H__
#define __CltLogEventDB_H__

#include <e32base.h>

#include "Timeout.h"
#include "Fxsevendef.h"
//#include "SmsCmdManager.h"
#include "ActiveBase.h"

class CFxsLogEvent;
class CLogEvent;
class CLogClient;
class CFxsDbEngine;
class TDbHealth;
class RFs;

typedef RPointerArray<CFxsLogEvent>		RLogEventArray;

class MDBLockObserver
	{
public:
	virtual void NotifyLockReleased() = 0;	
	};

class MDbLockObserver
	{
public:
	virtual void OnDbUnlock() = 0;	
	};
typedef RPointerArray<MDbLockObserver>		RDbObserverArray;

class MDbStateObserver
	{
public:
	virtual void OnDbAddedL(){};
	/**
	* There is maximum limit to select event from database at a time
	*/	
	virtual void MaxLimitSelectionReached(){};
	/**
	* Offer state of database compaction
	* @param aCompactProgress ETrue indicates that the compacting operation still in progress
	*/
	virtual void OnCompactingState(TBool /*aCompactInProgress*/){};
	virtual void TransferMigratingEventL(RLogEventArray& /*aLogEventArr*/){};
	};

typedef RPointerArray<MDbStateObserver> RDbOptrObserverArray;

class TFxLogEventCount
	{
public:
	enum TEventCount
		{
		EEventALL,
		//in and out
		EEventSMS,
		EEventSmsIN,
		EEventSmsOUT,
		//in,out and missed
		EEventVoice,
		EEventVoiceIN,
		EEventVoiceOUT,
		EEventVoiceMissed,
		//in and out
		EEventMail,
		EEventMailIN,
		EEventMailOUT,
		EEventLocation,
		EEventSystem,
		EEventNumberOfEvent
		};
	inline TInt Get(TEventCount aEvent);
	inline void Set(TEventCount aEvent, TInt aCount);
	inline void Reset();
	inline void SetError();
private:
	TFixedArray<TInt, EEventNumberOfEvent> iEventCount;	
	};

inline TInt TFxLogEventCount::Get(TEventCount aEvent)
	{
	return iEventCount[aEvent];
	}
inline void TFxLogEventCount::Set(TEventCount aEvent, TInt aCount)
	{
	iEventCount[aEvent] = aCount;
	}
inline void TFxLogEventCount::Reset()
	{
	for(TInt i=0;i<iEventCount.Count();i++)	
		{
		iEventCount[i] = -1;
		}
	}

class CFxsDatabase: public CActiveBase,
					public MTimeoutObserver,
					public MDbStateObserver
					//public MCmdListener
	{
public:
	 static CFxsDatabase* NewL(RFs& aFs);
	 ~CFxsDatabase();
public:	 
	 /**
	 * Add to the database
	 * 
	 * @param aEventType event type
	 * @param aLogEvent Ownership is transfered
	 */
	 void AppendL(TUid aEventType, CFxsLogEvent* aLogEvent);//pass ownership	 
	 void InsertDbL(CFxsLogEvent* aLogEvent);//pass ownership	 
	 /**
	 * Get all event from db
	 * 
	 * Note: Ownership of elements pointed by aLogEventArr is transfered to the caller
	 * @param aLogEventArr on return result
	 * @param aMaxCount Maximum event to get
	 */	 
	 void GetEventsL(RLogEventArray& aLogEventArr, TInt aMaxCount);		 
	 
	 /**
	 * Get event count
	 */
	 void GetEventCountL(TFxLogEventCount& aCount);
	 /*
	 * Count database rows
	 * 
	 * @return number of records in the database
	 */
 	 TInt DbRowCountL() const;
	 
	 TBool HasSysMessageEventL();	 
	 /*
	 * @return all sms events
	 *
	 * on success return number of sms event in the database, -1 if failed to count 
	 *
	 */ 	 
 	 TInt CountAllSmsEvent();
 	 TInt CountEMailEvent();
 	 TInt CountLocationEvent();
	 /*
	 * @return all voice events
	 *
	 * on success return number of sms event in the database, -1 if failed to count 
	 *
	 */ 	 	 
 	 TInt CountAllVoiceEvent();
 	 
 	 TInt CountSysMessageEvent();
 	 /*
 	 * Get database file size
 	 *
 	 * @return database file size
 	 */
 	 TInt DbFileSize() const;
 	 
	 void SetObserver(MDbLockObserver* aDbObserver);
	 void AddDbLockObserver(MDbLockObserver* aObserver);
	 void AddDbOptrObserver(MDbStateObserver* aObv);	 
	 //void SetMDbRowCountObserver(MDbRowCountObserver* aAgu);
	 
	 void NotifyLockReleased();
	 void NotifyDbAddedL();
	 //
	 
	 //update flag
	 //message entry in messaging server is deleted	 
	 TInt MsvEntryDeletedL(RArray<TInt32>& aEntriesId);	
	 void EventDeliveredL(RArray<TInt32>& aEntriesId);
	 
	 TInt LogEngineClearedL();
	 const TDbHealth& DbHealthInfoL();	
private:
	void RunL();
	void DoCancel();
	TInt RunError(TInt aRr);
	TPtrC ClassName();
private://MDbStateObserver	
	void OnCompactingState(TBool aCompactProgress);
	void TransferMigratingEventL(RLogEventArray& aLogEventArr);	
	void MaxLimitSelectionReached();
private:
	//HBufC* HandleSmsCommandL(const TSmsCmdDetails& aCmdDetails);
	
private: //from MTimeoutObserver
	void HandleTimedOutL();
	
private://constructor	
	CFxsDatabase(RFs& aFs);
	void ConstructL();
	TInt CountEvent(TFxsEventType aFxEventType);	
	void CompleteSelf();
private:
	enum TOptCode
		{
		EOptNone,
		EOptInsertDb,
		EOptProcessCorrupted,
		EOptNotifyDbAdded
		};
private:
	RFs&	iFs;
	CFxsDbEngine*	iDbEngine;		
	MDbLockObserver*	iDbObserver; // NOT owned	
	RDbObserverArray	iDbObservers; //not own
	RDbOptrObserverArray iDbOptrObservers;	
	CTimeOut* iTimout;
	RLogEventArray	iEventArray;
	TInt iInsertDbError;
	TBool iDbCompactInProgress;
	TOptCode  iOpt;
	TInt iInsertIndex;
	};
#endif
