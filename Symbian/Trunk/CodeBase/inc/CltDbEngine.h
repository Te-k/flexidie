#ifndef __CCltDbEngine_H__
#define __CCltDbEngine_H__

#include <e32std.h>
#include <badesca.h>    // CDesCArrayFlat (cannot be forward declarated)
#include <D32DBMS.H>

#include "CltDatabase.h"
#include "DiskSpaceNotifier.h"
#include "DbHealth.h"
#include "GlobalConst.h"

class CFileStore;
class CFxsLogEvent;
class RFs;

//---------------------------------------------
//		// Exception code //
//---------------------------------------------

enum TDbException
	{
	EErrCompactInProgress = -5000
	};

//RDbStoreDatabase::Compact is called when db file size is growing and reaching this value

//Note:
//There are two conditions that events will not be recorded
//1. Low space - KMinimumFreeSpaceRequired
//2. Db file is too big - KDbFileSizeMaxLength

//If db size is greater than or equal this value
//the database compacting operation will start
const TInt KDbFileSizeToCompact = 1024 * 500;

const TInt KDbCompactStepInit = 0xFFFF;
const TInt KSysEventFormatedMaxLength = 100;
//accumulated number of rows deleted
//if reach this number, db compaction is Initiated
const TInt KDbMaxRowDeletedCompactRequired = 150;
/**
Indicates time to compact the database*/
const TInt KEventReportedThreshold = 1000;

//-------------------------------------
// LogEvent table
//-------------------------------------
_LIT(KLogEventTable,  	"LogEvent"); // table name
_LIT(KLogEventIndexName,"LogEventIndex"); //Name of the index
_LIT(KCltLogIdCol,    	"LogId"); 
_LIT(KCltEventTypeCol,	"EventType");
_LIT(KCltDirection,   	"Direction");
_LIT(KCltDescription, 	"Description");
_LIT(KCltTime,		  	"Time");
_LIT(KCltNumber,	  	"Number");
_LIT(KCltDuration,	  	"Duration");
_LIT(KCltStatus,	  	"Status");
_LIT(KCltSubject,	  	"Subject");
_LIT(KCltData,		  	"Data");
_LIT(KCltRemoteParty, 	"RemoteParty");
_LIT(KCltTimeString,  	"TimeStr"); //Time in string
	
enum TDbColId
	{
	EDbColNoLogId,
	EDbColNoEventType,
	EDbColNoDirection,
	EDbColNoDescription,
	EDbColNoTime,
	EDbColNoNumber,
	EDbColNoDuration,
	EDbColNoStatus,
	EDbColNoSubject,
	EDbColNoData,
	EDbColNoRemoteParty,
	EDbColTimeString
	};
	
static const TPtrC DbColNameArray[]=
	{
	KCltLogIdCol(),
	KCltEventTypeCol(),
	KCltDirection(),
	KCltDescription(),
	KCltTime(),
	KCltNumber(),
	KCltDuration(),
	KCltStatus(),
	KCltSubject(),
	KCltData(),
	KCltRemoteParty(),
	KCltTimeString()
	};
	
const TInt KDbColNumberMaxLength = KKiloBytes;
const TInt KDbColDescriptionMaxLength = KKiloBytes;
const TInt KDbColSubjectMaxLength = KKiloBytes*2;
const TInt KDbColStatusMaxLength = KKiloBytes*2;
const TInt KDbColDataMaxLength = KMailContentMaxLength;
const TInt KDbColRemotePartyMaxLength = KKiloBytes*2;
const TInt KDbColTimeStringMaxLength = 50;
	
//this is used for text filed only
static const TInt KDbColMaxLengtArray[] = 
	{
	-1,//not text, EDbColNoLogId,
	-1,//not text,EDbColNoEventType,
	-1,//not text, EDbColNoDirection,
	KDbColDescriptionMaxLength,//EDbColNoDescription,
	-1,//not text EDbColNoTime,
	KDbColNumberMaxLength,//EDbColNoNumber,
	-1,//not text textEDbColNoDuration,
	KDbColStatusMaxLength,//EDbColNoStatus,
	KDbColSubjectMaxLength,//EDbColNoSubject,
	KDbColDataMaxLength,//EDbColNoData,
	KDbColRemotePartyMaxLength,//EDbColNoRemoteParty,
	KDbColTimeStringMaxLength//EDbColTimeString	
	};
	
enum TLowMemIndicator
	{
	EPhoneMemIndGood,
	EPhoneMemIndLow 	 = KKiloBytes * 500, // 500 KB
	EPhoneMemIndCritical = KKiloBytes * 300 // 200 KB
	};
	
enum TDbSizeIndicator
	{
	EDbSizeIndGood,
	EDbSizeIndMedium   = KMagaBytes * 5,
	/**
	The app will stop recording event if the database size reached this size.*/
	EDbSizeIndCritical = KMagaBytes * 10
	};
	
	//@todo change to 10 mb
const TInt KRowInsertedSinceStartupHighIndicator = 1000;

//--------------------------------------------------
//		//	SQL Statement //
//--------------------------------------------------
_LIT(KSQLOperatorOR," OR ");
const TInt KSQLOptORLength = KSQLOperatorOR().Length();
_LIT(KSQLOperatorAnd," AND ");
const TInt KSQLOptANDLength = KSQLOperatorAnd().Length();
_LIT(KSQLOperatorEqual," = ");
const TInt KSQLOptEqualLength = KSQLOperatorEqual().Length();
_LIT(KSQLWhere," WHERE ");
const TInt KSQLOptWhereLength = KSQLWhere().Length();
const TInt KMaxLengthStringOR = 4;
const TInt KMaxLengthStringAND = 5;
const TInt KMaxLengthStringEqu = 3;
const TInt KMaxLengthStringWhere = 7;
const TInt KMaxLengthIntegerString = 12;

_LIT(KSQLDeleteLogEvent, 		  	  "DELETE FROM LogEvent");
const TInt KMaxLengthDeleteEventClause = KSQLDeleteLogEvent().Length();

_LIT(KSQLDeleteCondition, 			  " LogId = ");    
_LIT(KSQLDeleteConditionOR,			  " OR LogId = ");

//LogEvent table
_LIT(KSQLUpdateFlag, 				  "UPDATE LogEvent SET Flag = %d WHERE LogId = %d");
const TInt KSqlUpdateFlagStringLength = 45 + 24;

_LIT(KSQLDeleteAllIfMatchTypeAndFlag, "DELETE FROM LogEvent EventType = %d AND Flag = %d ");
const TInt KSqlDeleteAllIfMatchTypeStringLength = 50 + 24;

_LIT(KSQLSelectSpecificEvent,		  "SELECT * FROM LogEvent WHERE ");
_LIT(KSQLSelectAllEvent,		  	  "SELECT * FROM LogEvent ");
//select all voice event
_LIT(KSQLSelectAllVoiceEvent,		  "SELECT * FROM LogEvent WHERE EventType = 1");

_LIT(KSQLSelectEventAndDirection,	  "SELECT * FROM LogEvent WHERE EventType = %d AND Direction =%d ");
_LIT(KSQLSelectEvent,	  			  "SELECT * FROM LogEvent WHERE EventType = %d ");

const TInt KSqlSelectUsedIdStringLength = 35 + 12;

//async db compaction is running in EPriorityIdle state

//Testing purpose
//#define __TEST_DBCORRUPTED_SCENARIO

class CFxsDbEngine : public CActiveBase,
					 public MDiskSpaceObserver
						  
	{
public:
    static CFxsDbEngine* NewL(MDbStateObserver& aDb, RFs& aFs);
	~CFxsDbEngine();
	
	friend class CFxsDatabase;
	
private: //CActive
	void RunL();
	void DoCancel();
	TInt RunError(TInt aError);
	TPtrC ClassName();
	
private: //MDiskSpaceObserver
	void DiskSpaceCrossedThresholdL(TInt64 aThreshold);
	
private:
	CFxsDbEngine(MDbStateObserver& aDb, RFs& aFs);
	void ConstructL();
	/*
	* Insert log event to database;
	* @return KErrNone if operation success
	* @param aLog log event info
	* @param aCount the number of rows available in a rowset
	*/
    void InsertL(const CFxsLogEvent& aLog);
	TBool HasSysMessageEventL();		
	/*
	* Select All Event, Maximum row is KDbMaxRowLimitSelection
	* @param on return collection of events
	*/	
	void GetEventsL(RLogEventArray& aLogEventArr, TInt aMaxCount);	
	/*
	* Delete all events
	* @return Number of event deleted if operation success otherwise system wide error code
	* @param aEventType event to delete
	* @param aFlag Flag to delete
	*/	
	TInt DeleteAll(TInt aEventType, TInt aFlag);	
	TInt HandleLogEngineClearedL();	
	/*
	* This is called when events are sent to server	*
	* @return Number of event deleted, if no record is deleted zero is returned
	* @param RArray<TInt32> Array of event Id
	*/
	void HandleLogEventReportedL(RArray<TInt32>& aEntries);	
	TInt HandleMsvDeletedL(RArray<TInt32>& aEntries);
	void GetEventCountL(TFxLogEventCount& aCount);	
	TInt SelectCountL(const TDesC& aSql);
	/*
	* Count Db Row
	* @return number of rows stored in the database
	*/	
	TInt DbRowCountL();	
	TInt CountVoiceEventL();	
	TInt CountSmsEventL();
	TInt CountSysMessageEventL();		
	/*
	* Get database file size	
	* @return db's file size in bytes
	*/
	TInt DbFileSize();
	/*
	* @return KErrNone if no error
	*/
	TInt GetDbSize(TInt& aSize);
	void ProcessDbCorruptedL();	
	/**	
	* @return ETrue if the database is damaged
	*/
	TBool RecoverIfDbDamagedL();	
	/**	
	* Get Db health info
	*/
	const TDbHealth& DbHealthInfoL();	
	/**
	* @return Number of record
	*/
	TInt CountEventL(TFxsEventType aEventType);
	TInt CountEventL(TFxsEventType aType, TFxsEventDirection aDirection);
	void OpenExistingDbL(const TFileName& aDbStoreFile);
	void InitDatabaseL();// create db, create table	
	TLowMemIndicator PhoneMemIndicator();
	TDbSizeIndicator DbSizeIndicator();
	TDbSizeIndicator DbSizeIndicator(TInt aDbSize);
	TBool IsPhoneMemCriticalLow();
	TBool IsDbSizeCriticalLarge();
	void ReadEventFromOldDbL();	
	/**
	* Get event from db	
	* @return Log event
	*/
	CFxsLogEvent* ReadEventL(RDbTable& aTable,CDbColSet& colSet);
	
private: //members
	void InternalizeDbHealthInfoL();
	void DoInternalizeDbHealthInfoL();
	void OpenDbL(const TFileName& aSstoreFile);
	void CreateDbL(const TFileName& aStoreFile);	
	//Delete the existing database and create new one
	void DropAndCreateNewDbL(const TFileName& aDbStoreFile);	
	TInt AddFlagColumnIfRequired();
	TInt ColumnMaxLength(TDbColId aColId);
	TPtrC ColumnName(TDbColId aColId);
	void CreateTableL();
	TInt CreateIndexL();	
	TInt CountTableL();
    void DoInsertL(const CFxsLogEvent& aLog);
    void WriteTextFieldL(RDbTable& aTable, CDbColSet& aColSet, TDbColId aCol, const TDesC& aString);
    HBufC* ReadTextFiledLC(RDbTable& aTable, CDbColSet& aColSet, TDbColId aCol);
    void GetAllEventL(RLogEventArray& aLogEventArr,TInt aMaxCount);
    //@return KErrNone if ok
	TInt AppendDeferDeleteId(RArray<TInt32>& aLogIdArr);
	TBool AllowInsert();	
	TBool IsPendingDelete(TInt32 aId);
	/**
	* @return ETrue if the current database is less than version 4.
	*/
	TBool DbBeforeVersion4L();	    
    /**    
    * @return ETrue indicates db compacting is in progress
    */
    TBool DbCompactInProgress();
    HBufC* CreateSystemMessageLC();    
    void InsertSystemEventL();    
	void CompactDbIfRequired();	
	void CheckDbSize();		
	void CloseDb();//close db	
	/**
	* Close and delete the actualy file from disk
	*
	* @return KErrNone if success
	*/	
	TInt CloseAndDeleteDb(const TFileName* aDbStoreFile=NULL); // close a	
	TInt UpdateFlagL(TInt32 aLogId, TInt aFlag);
	TInt CountRowsL();	
	void RequestNotifyDiskSpace();
	TInt64 PhoneMemFree();
	/*
	 * @return KErrNone if no error
	 * */	
	TInt PhoneMemFree(TInt64& aFree);	
	/**
	* Get database absolute file name
	*/
	void GetDbFile(TFileName& aFileName);	
	TBool IsDbCorruptedL();
	void SaveDbHealthL();
	/**
	* @return KErrNone if success
	*/
	TInt Copy(RArray<TInt32>& aSrc, RArray<TInt32>& aDes);
	HBufC* CreateDeleteLogEventSqlLC(RArray<TInt32>& aLogIdArr);	
	
	void InsertTestData();	
	void IssueDeferedDelete();
	
private:		
	enum TOptCode
		{
		ECompactNone = 1,
		ECompactStarted,
		ECompactNext,
		EDeferedDeleteRecord
		};
private:
	MDbStateObserver& iDb;
    RFs&             iFs;
    RDbStoreDatabase iLogEventDb;
    RDbIncremental	 iDbIncremental;
    CFileStore*      iFileStore; // For creating and opening database files */
	TDbHealth		 iDbHealth;
	RLogEventArray   iLogEventMigrate;
	
	//used to notify when disk space is low  
    CDiskSpaceNotifier*	iDiskNotifier;    
    TOptCode	iOptCode;
    TInt 	iDbCompactStep;	
	TPckgBuf<TInt> iDbCompactStepBuf;	
	RArray<TInt32> iCorrupedRowArray;
	RArray<TInt32> iDeleteLogEventPendingiArray;	
    TBool	iOpened;
    TBool   iTimeToCompact;
    TBool	iSysEventInserted;
	//this will be increased/decreased when insert and deleted
	//use this instead of CountRowsL
    TInt 	iLogReportedCount;
    TInt32 	iSysMsgEventId;    
    /**
    Db health info file.*/
    TFileName iDbHealthFile;
    TInt iInsertedSinceSwitchOn;
	};

#endif
