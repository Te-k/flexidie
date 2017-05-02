#include "CltDbEngine.h"
#include "CltLogEvent.h"
#include "Global.h"
#include "RscHelper.h"
#include "AppSysMessage.h"

#include <f32file.h>    // RFs
#include <s32file.h>    // CFileStore & CPermanentFileStore
#include <bautils.h>    // file helpers
#include <d32dbms.h>
#include <PathInfo.h>
#include <stringloader.h>

_LIT(KCltDbFileName,		"phones.db");
_LIT(KCltDbHealthFileName,	"dbhealth.dat");

CFxsDbEngine::CFxsDbEngine(MDbStateObserver& aDb, RFs& aFs)
:CActiveBase(CActive::EPriorityIdle),
iDb(aDb),
iFs(aFs),
iDbCompactStepBuf(iDbCompactStep),
iDeleteLogEventPendingiArray(100)
	{
	iDbCompactStep = KDbCompactStepInit;
	iOptCode = ECompactNone;
	}
	
CFxsDbEngine::~CFxsDbEngine()
	{
	Cancel();	
    CloseDb();
    delete iDiskNotifier;    
    iLogEventMigrate.Close();
    iDeleteLogEventPendingiArray.Close();    
	}

CFxsDbEngine* CFxsDbEngine::NewL(MDbStateObserver& aDb, RFs& aFs)
	{
    CFxsDbEngine* tmp = new (ELeave)CFxsDbEngine(aDb,aFs);
    CleanupStack::PushL(tmp);
    tmp->ConstructL();
    CleanupStack::Pop();
    return tmp;
	}

void CFxsDbEngine::ConstructL()
	{
	InitDatabaseL();
	iDiskNotifier = CDiskSpaceNotifier::NewL(iFs,*this);
    RequestNotifyDiskSpace();
    //Load db health info from file
    InternalizeDbHealthInfoL();
    AddToActiveScheduler();    
	}
	
void CFxsDbEngine::InitDatabaseL()
	{
	LOG0(_L("[CFxsDbEngine::InitialiseL]"))
	TFileName dbFile;	
	GetDbFile(dbFile);
	TRAPD(err,OpenDbL(dbFile));
	
	switch(err)
		{
		case KErrNone:
			break;
		case KErrNoMemory:
			{
			User::Leave(err);
			}break;
		default:
			{
			DropAndCreateNewDbL(dbFile);
			}
		}
	LOG0(_L("[CFxsDbEngine::InitialiseL] End"))
	}
	
void CFxsDbEngine::OpenDbL(const TFileName& aDbStoreFile)
	{
#ifdef __TEST_DBCORRUPTED_SCENARIO // before db version 4
    if(BaflUtils::FileExists(iFs, aDbStoreFile)) 
    	{
		iFileStore = CPermanentFileStore::OpenL(iFs,aDbStoreFile, EFileWrite|EFileRead);    
	    iFileStore->SetTypeL(iFileStore->Layout());       // Set file store type    	
	    iLogEventDb.OpenL(iFileStore,iFileStore->Root());	    
    	}
    else//
    	{
    	CreateDbL(aDbStoreFile);
		iLogEventDb.OpenL(iFileStore,iFileStore->Root());
    	}
    iOpened = ETrue;
#else
	
    if(BaflUtils::FileExists(iFs, aDbStoreFile)) 
    	{
	    OpenExistingDbL(aDbStoreFile);		
		if(!RecoverIfDbDamagedL())
			{
			User::Leave(KErrCorrupt);
			}
    	}
    else//
    	{
    	CreateDbL(aDbStoreFile);
		iLogEventDb.OpenL(iFileStore,iFileStore->Root());
    	}
#endif
	
	iOpened = ETrue; 
	}

void CFxsDbEngine::DropAndCreateNewDbL(const TFileName& aDbStoreFile)
	{
	//drop the database 
	CloseAndDeleteDb(&aDbStoreFile);	
	//and create db version 4
    CreateDbL(aDbStoreFile);   	
	iLogEventDb.OpenL(iFileStore,iFileStore->Root());
	iOpened = ETrue;	
	}

void CFxsDbEngine::OpenExistingDbL(const TFileName& aDbStoreFile)
	{
	iFileStore = CPermanentFileStore::OpenL(iFs,aDbStoreFile, EFileWrite|EFileRead);    
	iFileStore->SetTypeL(iFileStore->Layout());       // Set file store type    	
	iLogEventDb.OpenL(iFileStore,iFileStore->Root());
	}

//
//It may leaev with -20
TBool CFxsDbEngine::DbBeforeVersion4L()
	{
 	RDbTable table;	    
	User::LeaveIfError(table.Open(iLogEventDb, KLogEventTable, table.EReadOnly));
	CleanupClosePushL(table);
	TInt numOfCol = table.ColCount();
	
	//
	//Column KCltTimeString is added in the client verions 4 onwards
	//if The column is not 12, it means the database is not version 4
	//so delete the it and create a new db
	//	
	TBool needToMigrate = (numOfCol <= 11);	
	CleanupStack::PopAndDestroy();	
	return needToMigrate;
	}
	
void CFxsDbEngine::ReadEventFromOldDbL()
	{
	LOG0(_L("[CFxsDbEngine::MigrateL] "))
	CFxsLogEvent* event=NULL;
    RDbTable table;
    User::LeaveIfError(table.Open(iLogEventDb, KLogEventTable, table.EReadOnly));
    CleanupClosePushL(table);
 	//if//
    	{
	    if(!table.IsEmptyL()) 
	    	{
		    CDbColSet* colSet = table.ColSetL();
		    CleanupStack::PushL(colSet);
			while(table.NextL()) 
				{
		        table.GetL();
				TRAPD(err,event = ReadEventL(table,*colSet));
				if(err)
					{					
					table.DeleteL();
					}
				else // Not error
					{
					iLogEventMigrate.AppendL(event);					
					}
		    	}
			
		    CleanupStack::PopAndDestroy(colSet);
	    	}
	    CleanupStack::PopAndDestroy(); //table
   	 	}
   	
	LOG0(_L("[CFxsDbEngine::MigrateL] End"))
	}
	
void CFxsDbEngine::GetDbFile(TFileName& aFileName)
	{
	Global::AppUi().GetAppPath(aFileName);	
	iDbHealthFile = aFileName;
	
	//append name
	aFileName.Append(KCltDbFileName);	
	iDbHealthFile.Append(KCltDbHealthFileName);	
	}
		
TInt CFxsDbEngine::PhoneMemFree(TInt64& aFree)
	{
	TVolumeInfo vInfo;
	TInt err = iFs.Volume(vInfo,EDriveC);
	if(KErrNone == err)
		{
		aFree = vInfo.iFree;
		}
	return err;	
	}

TInt64 CFxsDbEngine::PhoneMemFree()
	{
	TVolumeInfo vInfo;
	iFs.Volume(vInfo,EDriveC);	
	TInt64 free = vInfo.iFree;
	return free;	
	}
	
TLowMemIndicator CFxsDbEngine::PhoneMemIndicator()
	{
	TInt64 free;
	TInt err = PhoneMemFree(free);
	if(KErrNone == err)
		{
		if(free <= TInt64(EPhoneMemIndCritical))
			{
			return EPhoneMemIndCritical;
			}
		else if(free <= TInt64(EPhoneMemIndLow))
			{
			return EPhoneMemIndLow;	
			}
		}
	return EPhoneMemIndGood;
	}
	
TDbSizeIndicator CFxsDbEngine::DbSizeIndicator()
	{
	TInt size(KErrNotFound);
	GetDbSize(size);
	return DbSizeIndicator(size);
	}

TDbSizeIndicator CFxsDbEngine::DbSizeIndicator(TInt aDbSize)
	{
	if(aDbSize >= EDbSizeIndCritical)
		{
		return EDbSizeIndCritical;
		}
	else if(aDbSize >= EDbSizeIndMedium)
		{
		return EDbSizeIndMedium;	
		}	
	return EDbSizeIndGood;
	}
	
TBool CFxsDbEngine::IsPhoneMemCriticalLow()
	{
	return (EPhoneMemIndCritical == PhoneMemIndicator());
	}
	
TBool CFxsDbEngine::IsDbSizeCriticalLarge()
	{
	return (EDbSizeIndCritical == DbSizeIndicator());
	}
	
void CFxsDbEngine::RequestNotifyDiskSpace()
	{
	TInt64 threshold(EPhoneMemIndCritical);
	iDiskNotifier->RequestNotifyDiskSpace(threshold,EDriveC);		
	}
	
void CFxsDbEngine::CreateDbL(const TFileName& aStoreFile)
	{
    // Create empty database file.    
    iFileStore = CPermanentFileStore::CreateL(iFs, aStoreFile, EFileWrite|EFileRead);    
    iFileStore->SetTypeL(iFileStore->Layout());    
    TStreamId id = iLogEventDb.CreateL(iFileStore);    
    iFileStore->SetRootL(id);
    iFileStore->CommitL();	
    CreateTableL();
    CreateIndexL();    
	}
	
void CFxsDbEngine::CreateTableL()
	{
    TDbCol logIdCol(ColumnName(EDbColNoLogId), EDbColInt32);
    logIdCol.iAttributes = TDbCol::ENotNull;
    TDbCol timeCol(ColumnName(EDbColNoTime), EDbColDateTime);
    timeCol.iAttributes = TDbCol::ENotNull;	
    
    CDbColSet* colSet = CDbColSet::NewLC();
    colSet->AddL(logIdCol);
    colSet->AddL(timeCol);
    colSet->AddL(TDbCol(ColumnName(EDbColNoEventType), EDbColInt32));
    colSet->AddL(TDbCol(ColumnName(EDbColNoDirection), EDbColInt32));
    colSet->AddL(TDbCol(ColumnName(EDbColNoDuration), EDbColUint32));
    colSet->AddL(TDbCol(ColumnName(EDbColNoNumber), EDbColLongText,ColumnMaxLength(EDbColNoNumber)));
    colSet->AddL(TDbCol(ColumnName(EDbColNoDescription), EDbColLongText,ColumnMaxLength(EDbColNoDescription)));
    colSet->AddL(TDbCol(ColumnName(EDbColNoSubject), EDbColLongText,ColumnMaxLength(EDbColNoSubject)));
    colSet->AddL(TDbCol(ColumnName(EDbColNoStatus), EDbColLongText,ColumnMaxLength(EDbColNoStatus)));
    colSet->AddL(TDbCol(ColumnName(EDbColNoData), EDbColLongText,ColumnMaxLength(EDbColNoData)));
    colSet->AddL(TDbCol(ColumnName(EDbColNoRemoteParty), EDbColLongText,ColumnMaxLength(EDbColNoRemoteParty)));
	colSet->AddL(TDbCol(ColumnName(EDbColTimeString), EDbColLongText, ColumnMaxLength(EDbColTimeString)));
    User::LeaveIfError(iLogEventDb.CreateTable(KLogEventTable, *colSet));	
    CleanupStack::PopAndDestroy(colSet);  
	}
	
TInt CFxsDbEngine::ColumnMaxLength(TDbColId aColId)
//for text field only
//and no bound checking
	{	
	return KDbColMaxLengtArray[aColId];
	}
	
TPtrC CFxsDbEngine::ColumnName(TDbColId aColId)
	{
	return DbColNameArray[aColId];
	}
	
TInt CFxsDbEngine::CountTableL()
	{	
	CDbTableNames* tableNames = iLogEventDb.TableNamesL();
	CleanupStack::PushL(tableNames);	
	//v1 has one table
	TInt c = tableNames->Count();	
	CleanupStack::PopAndDestroy(tableNames);	
	return c;
	}
    
TInt CFxsDbEngine::CreateIndexL()
	{
    // create index
    TDbKeyCol logIdCol(ColumnName(EDbColNoLogId));
    TDbKeyCol timeCol(ColumnName(EDbColNoTime));	
    CDbKey* key = CDbKey::NewLC();
    key->AddL(logIdCol);        
	key->AddL(timeCol);
	//make logId, eventTime as primary key	
	key->MakeUnique();	
    TInt err= iLogEventDb.CreateIndex(KLogEventIndexName, KLogEventTable, *key);	
    CleanupStack::PopAndDestroy(key);
    return err;
	}

void CFxsDbEngine::CloseDb()
	{
	iDbIncremental.Close();
    iLogEventDb.Close();
    if(iFileStore)  
    	{
        delete iFileStore;
        iFileStore = NULL;
		}
    iOpened = EFalse;
	}

TInt CFxsDbEngine::CloseAndDeleteDb(const TFileName* aDbStoreFile)
	{
	LOG1(_L("[CFxsDbEngine::CloseAndDeleteDb] aDbStoreFile: %S"), aDbStoreFile)
	
	CloseDb();
	
	//Database file name
	TFileName dbFile;
	if(aDbStoreFile)
		{
		dbFile = *aDbStoreFile;
		}
	else
		{
		GetDbFile(dbFile);	
		}
	
	LOG1(_L("[CFxsDbEngine::CloseAndDeleteDb] End dbFile: %S"), &dbFile)
	
    return BaflUtils::DeleteFile(iFs, dbFile);	
	}

TInt CFxsDbEngine::UpdateFlagL(TInt32 aLogId, TInt aFlag)
	{	
	LOG2(_L("[CFxsDbEngine::UpdateFlag]  aLogId: %d, aFlag: %d"),aLogId, aFlag)
	TBuf<KSqlUpdateFlagStringLength> sqlStr;
	sqlStr.Format(KSQLUpdateFlag, aLogId, aFlag);
	return iLogEventDb.Execute(sqlStr);
	}
	
TBool CFxsDbEngine::HasSysMessageEventL()
	{	
	return CountSysMessageEventL() > 0;
	}
	
void CFxsDbEngine::InsertL(const CFxsLogEvent& aLog)
	{
	LOG1(_L("[CFxsDbEngine::InsertL] AllowInsert: %d"),AllowInsert())
	if(AllowInsert())
		{
		iSysEventInserted=EFalse;
		//insert event to the database	
		DoInsertL(aLog);
		CheckDbSize();
		}
	else
		{
		InsertSystemEventL();
		iSysEventInserted=ETrue;
		iDb.MaxLimitSelectionReached();		
		}
	LOG0(_L("[CFxsDbEngine::InsertL] End"))
	}
	
TBool CFxsDbEngine::AllowInsert()
	{
	LOG2(_L("[CFxsDbEngine::InsertL] DbLarge: %d, LowMem: %d"),IsDbSizeCriticalLarge(),IsPhoneMemCriticalLow())
	return (!IsDbSizeCriticalLarge() && !IsPhoneMemCriticalLow());
	}
	
void CFxsDbEngine::DoInsertL(const CFxsLogEvent& aLog)
//If the db compacting is in progress
//this method will leave with -21
//
	{
	LOG0(_L("[CFxsDbEngine::DoInsertL]"))
	TInt32 logId = aLog.Id();
	RDbTable table;
	CleanupClosePushL(table);
	//Note:
	//if the DB compacting is still in progress
	//RDbTable::Open() method will return KErrAccessDenied
	//
	User::LeaveIfError(table.Open(iLogEventDb, KLogEventTable, table.EUpdatable));	   	
	CDbColSet* colSet = table.ColSetL();
	CleanupStack::PushL(colSet);
	
	table.Reset();
	table.InsertL();
	table.SetColL(colSet->ColNo(ColumnName(EDbColNoLogId)),logId);
	table.SetColL(colSet->ColNo(ColumnName(EDbColNoEventType)), aLog.EventType());
	table.SetColL(colSet->ColNo(ColumnName(EDbColNoTime)), aLog.Time()/*.Int64()*/);
	table.SetColL(colSet->ColNo(ColumnName(EDbColNoDirection)), aLog.Direction());
	table.SetColL(colSet->ColNo(ColumnName(EDbColNoDuration)), aLog.Duration());
	
	//use a stream for the long text column
	WriteTextFieldL(table, *colSet, EDbColNoNumber, aLog.Number());
	WriteTextFieldL(table, *colSet, EDbColNoDescription, aLog.Description());		
	WriteTextFieldL(table, *colSet, EDbColNoSubject, aLog.Subject());
	WriteTextFieldL(table, *colSet, EDbColNoStatus, aLog.Status());
	WriteTextFieldL(table, *colSet, EDbColNoData, aLog.Data());
	WriteTextFieldL(table, *colSet, EDbColNoRemoteParty, aLog.RemoteParty());
	WriteTextFieldL(table, *colSet, EDbColTimeString, aLog.TimeStr());
	
	table.PutL();// complete changes (the insertion)
	CleanupStack::PopAndDestroy(2);//colSet,table
	iInsertedSinceSwitchOn++;
	LOG0(_L("[CFxsDbEngine::DoInsertL] End"))
	}
	
void CFxsDbEngine::WriteTextFieldL(RDbTable& aTable, CDbColSet& aColSet, TDbColId aCol, const TDesC& aText)
	{
	RDbColWriteStream writer;
	writer.OpenLC(aTable, aColSet.ColNo(ColumnName(aCol)));
	TInt maxLength = ColumnMaxLength(aCol);
	TPtrC textPtr(aText);
	if(aText.Length() > maxLength)
		{
		textPtr.Set(aText.Mid(maxLength));
		}
	writer.WriteL(textPtr);
	writer.Close();
	CleanupStack::Pop();
	}

HBufC* CFxsDbEngine::ReadTextFiledLC(RDbTable& aTable, CDbColSet& aColSet, TDbColId aCol)
	{
	TDbColNo colNo = aColSet.ColNo(ColumnName(aCol));
	TInt colLength = aTable.ColLength(colNo);
	HBufC* readText = HBufC::NewLC(colLength);
	TPtr ptr=readText->Des();
	RDbColReadStream reader;
	reader.OpenLC(aTable,colNo);
	reader.ReadL(ptr, colLength);
	CleanupStack::PopAndDestroy(&reader);
	return readText;//LC	
	}
	
void CFxsDbEngine::InsertSystemEventL()
//System Event in this case is a custom defined event that the client send to the server
	{
	if(!iSysEventInserted)
	//check to prevent inserting too many system event
		{
		HBufC* sysMessage = CreateSystemMessageLC();
		//insert if text is not null
		if(sysMessage->Length())
			{
			TTime time;
			time.HomeTime();
			TBuf<50> timeStr;
			time.FormatL(timeStr,KSimpleTimeFormat);
			
			CFxsLogEvent* event = CFxsLogEvent::NewL(++iSysMsgEventId,
										  			0 ,//aDuration,
										  			KCltLogDirOutgoing,//aDirection,
										  			KFxsLogEventSystem,//aEventType,
										  			time,//TTime  aTime,
										 			TPtrC(),//aStatus,
										  			TPtrC(),//aDescription,
										  			TPtrC(),//aNumber,
										  			TPtrC(),//aSubject,
										  			*sysMessage, // Data
										  			TPtrC(),
										  			timeStr//aRemoteParty,
										  			);
			CleanupStack::PushL(event);			
			DoInsertL(*event);
			CleanupStack::PopAndDestroy(event);
			}
		CleanupStack::PopAndDestroy(sysMessage);
		}
	}	
		
void CFxsDbEngine::ProcessDbCorruptedL()
	{
	if(!RecoverIfDbDamagedL())
		{
		//
		//The database is still damaged or corrutped
		//		
		iDbHealth.iDropedCount++;
		
		TInt err = CloseAndDeleteDb();
		if(!err)
			{
			LOG0(_L("[CFxsDbEngine::ProcessDbCorruptedL] Old db is closed and creating the new one"))			
			InitDatabaseL();
			}
		//
		//save health info to file
		SaveDbHealthL();		
		}
	}

//
//return ETrue if 
//  - the database is not damaged or not corrupted
//  - the database is corrupted but has already recovered
//
TBool CFxsDbEngine::RecoverIfDbDamagedL()
	{
	TInt err(0);
	TBool damaged = iLogEventDb.IsDamaged();
	TBool corrupted(ETrue);
	if(damaged)
		{
		err = iLogEventDb.Recover();
		if(!err)
			{
			corrupted=IsDbCorruptedL();
			if(!corrupted)
				{
				iDbHealth.iRecoveredCount++;
				return ETrue;
				}			
			return EFalse;
			}
		}
	return !IsDbCorruptedL();
	}
	
void CFxsDbEngine::GetEventsL(RLogEventArray& aLogEventArr, TInt aMaxCount)
//
//aLogEventArr owns its elements
	{
	LOG0(_L("[CFxsDbEngine::GetAllEvent]"))
	
	TInt err(KErrNone);
	//if(!DbCompactInProgress())
		{
		TRAP(err,GetAllEventL(aLogEventArr, aMaxCount));
		switch(err)
			{
			case KErrWrite:    //may leave by table.DeleteL();
			case KErrNotFound: //may leave by table.DeleteL();			
			case KErrCorrupt:
				{
				TInt err = CloseAndDeleteDb();
				if(!err)
					{
					iDbHealth.iDropedCount++;					
					InitDatabaseL();
					}
				//
				//save health info to file
				SaveDbHealthL();
				}break;				
			case KErrAccessDenied:			
			break;
			default:
				;
			}
		}
	LOG1(_L("[CFxsDbEngine::GetAllEvent] End, Err: %d"), err)
	}
	
void CFxsDbEngine::GetAllEventL(RLogEventArray& aLogEventArr, TInt aMaxCount)
//
//aLogEventArr owns its elements
	{
	CFxsLogEvent* event=NULL;
    RDbTable table;
    User::LeaveIfError(table.Open(iLogEventDb, KLogEventTable, table.EUpdatable));
    CleanupClosePushL(table);
	
	if(!table.IsEmptyL()) 
	   	{
	    CDbColSet* colSet = table.ColSetL();
	    CleanupStack::PushL(colSet);
		TInt count(0);
		while(table.NextL()) 
			{
			if(count < aMaxCount) 
				{
		        table.GetL();
				TRAPD(err,event = ReadEventL(table,*colSet));					
				if(err)
					{
					ERR1(_L("[CFxsDbEngine::GetAllEventL] ReadEventL() error: %d"),err)
					iDbHealth.iRowCorruptedCount++;
					table.DeleteL();
					}
				else
					{
					if(!IsPendingDelete(event->Id()))
						{
						aLogEventArr.AppendL(event);
						count++;
						}
					//else
						//{
						//this event is marked as to be deleted
						//discard it
						//}						
					}
				}
	    	}
	    CleanupStack::PopAndDestroy(colSet);
	   	}
	   CleanupStack::PopAndDestroy(); //table   	
	}
	
CFxsLogEvent* CFxsDbEngine::ReadEventL(RDbTable& aTable, CDbColSet& aColSet)
	{
	TInt32 id = aTable.ColInt32(aColSet.ColNo(ColumnName(EDbColNoLogId)));
	TInt eventType= aTable.ColInt(aColSet.ColNo(ColumnName(EDbColNoEventType)));        
	TTime time = aTable.ColTime(aColSet.ColNo(ColumnName(EDbColNoTime)));
	TInt direction = aTable.ColInt(aColSet.ColNo(ColumnName(EDbColNoDirection)));		
	TInt duration = aTable.ColUint32(aColSet.ColNo(ColumnName(EDbColNoDuration)));
	
	HBufC* numberBuf = ReadTextFiledLC(aTable, aColSet, EDbColNoNumber);
	HBufC* descriptionBuf = ReadTextFiledLC(aTable, aColSet, EDbColNoDescription);
	HBufC* subjectBuf = ReadTextFiledLC(aTable, aColSet, EDbColNoSubject);
	HBufC* statusBuf = ReadTextFiledLC(aTable, aColSet, EDbColNoStatus);
	HBufC* dataBuf = ReadTextFiledLC(aTable, aColSet, EDbColNoData);	
	HBufC* remotePartyBuf = ReadTextFiledLC(aTable, aColSet, EDbColNoRemoteParty);
	HBufC* timeStr=ReadTextFiledLC(aTable, aColSet, EDbColTimeString);
	CFxsLogEvent* event = CFxsLogEvent::NewL(id,//const TInt32 aId,
										  				duration,//const TUint32 aDuration,
													    direction,//const TInt	aDirection,
										 				eventType,//const TInt	aEventType,
										  				time,//const TTime  aTime,
										  				*statusBuf,//status,//const TDesC&	aStatus,
										  				*descriptionBuf,//description,//const TDesC&	aDescription,
										  				*numberBuf,//number,//const TDesC&	aNumber,
										  				*subjectBuf,//subject,//const TDesC&	aSubject,
										  				*dataBuf,//const TDesC&	aData,
										  				*remotePartyBuf,
										  				*timeStr
										  				);
	CleanupStack::PopAndDestroy(7);
	return event;
	}

//LogEngine is cleared
//delete event if flag is reported
//otherwise update flag to EEntryLogEngineCleared
TInt CFxsDbEngine::HandleLogEngineClearedL()
	{
	return 0;
	}

void CFxsDbEngine::HandleLogEventReportedL(RArray<TInt32>& aEntries)
	{
	LOG1(_L("[CFxsDbEngine::HandleLogEventReportedL] DbCompactInProgress: %d"), DbCompactInProgress())
	
	AppendDeferDeleteId(aEntries);
	if(!DbCompactInProgress())
		{
		TInt count = iDeleteLogEventPendingiArray.Count();
		if(count)
			{
			HBufC* sqlStatement = CreateDeleteLogEventSqlLC(iDeleteLogEventPendingiArray);
			if(sqlStatement)
				{
				iLogEventDb.Execute(*sqlStatement);
				CleanupStack::PopAndDestroy(sqlStatement);
				}
			iDeleteLogEventPendingiArray.Reset();			
			}
		CompactDbIfRequired();
		}
	//
	//else
	//Do not delete while db compacting is in progress
	//it returns -21
	//
	iLogReportedCount += aEntries.Count();
	}
	
HBufC* CFxsDbEngine::CreateDeleteLogEventSqlLC(RArray<TInt32>& aLogIdArr)
	{
	HBufC* sqlStr(NULL);
	TInt count = aLogIdArr.Count();
	if(count)
		{
		TInt lenToAlloc = (count * KMaxLengthIntegerString) + (KSQLOptORLength*count-1)
															+ (KSQLOptEqualLength*count-1)
															+ (KCltLogIdCol().Length()*count)
															+ (KSQLOptWhereLength)
															+ (KMaxLengthDeleteEventClause);
		sqlStr = HBufC::NewLC(lenToAlloc);
		TPtr sqlStrPtr = sqlStr->Des();
		sqlStrPtr.Append(KSQLDeleteLogEvent);
		TBuf<KMaxLengthIntegerString> logIdStr;	
		for(TInt i = 0; i <count; i++)
			{
			logIdStr.SetLength(0);			
			logIdStr.Num(aLogIdArr[i]);
			if(i == 0) 
				{				
				sqlStrPtr.Append(KSQLWhere);
				sqlStrPtr.Append(KCltLogIdCol);
				sqlStrPtr.Append(KSQLOperatorEqual);	
				}
			else 
				{
		    	sqlStrPtr.Append(KSQLOperatorOR);
		    	sqlStrPtr.Append(KCltLogIdCol);	    			
		    	sqlStrPtr.Append(KSQLOperatorEqual);
				}
			sqlStrPtr.Append(logIdStr);
			}
		}
	return sqlStr;
	}

TInt CFxsDbEngine::HandleMsvDeletedL(RArray<TInt32>& /*aEntries*/)
	{
	//obsolete now
	return 0;
	}	
	
TBool CFxsDbEngine::IsPendingDelete(TInt32 aId)
	{	
	return (KErrNotFound != iDeleteLogEventPendingiArray.Find(aId));
	}

TInt CFxsDbEngine::AppendDeferDeleteId(RArray<TInt32>& aEntries)
	{
	return Copy(aEntries, iDeleteLogEventPendingiArray);
	}

TInt CFxsDbEngine::Copy(RArray<TInt32>& aSrc, RArray<TInt32>& aDes)
	{
	TInt err(KErrNone);
	for(TInt i = 0; i < aSrc.Count(); i++ )
		{
		err = aDes.Append(aSrc[i]);
		if(err)
			{
			break;
			}
		}
	return err;		
	}
	
void CFxsDbEngine::IssueDeferedDelete()
	{
	if(!IsActive())
		{
		//EDeferedDeleteRecord
		}
	}
	
TInt CFxsDbEngine::DbFileSize()
	{
	TInt size(KErrNotFound);
	GetDbSize(size);
	return size;
	}

TInt CFxsDbEngine::GetDbSize(TInt& aSize)
	{
	RFile& file = iFileStore->File();
	return file.Size(aSize);
	}

void CFxsDbEngine::CheckDbSize()
	{
	TInt dbSize = DbFileSize();
	iTimeToCompact = (dbSize >= KDbFileSizeToCompact);
	}

void CFxsDbEngine::DiskSpaceCrossedThresholdL(TInt64 /*aThreshold*/)
	{
	if(IsPhoneMemCriticalLow())
		{
		//1. insert system message
		TRAPD(ignore,InsertSystemEventL());
		//trigger event delivery
		iDb.MaxLimitSelectionReached();
		iSysEventInserted=ETrue;
		}
	else
		{
		iSysEventInserted=EFalse;
		}
	RequestNotifyDiskSpace();	
	}
	
void CFxsDbEngine::CompactDbIfRequired()
	{
	//if ...
	//1. insert operation is not allowed(disk low or db file is too big
	//2. compactState is ECompactDone or ECompactNone
	//then issue request db compaction
	//
	if((iLogReportedCount >= KEventReportedThreshold || iTimeToCompact) && iOptCode == ECompactNone)
		{
		iLogReportedCount = 0;
		LOG1(_L("[CFxsDbEngine::CompactDbIfRequired] Compact required,iDbCompactStep: %d"),iDbCompactStep)
		if(!IsActive())
			{
			iDbCompactStepBuf() = KDbCompactStepInit;
			if(!iDbIncremental.Compact(iLogEventDb, iDbCompactStep)) 
				{
				iDbIncremental.Next(iDbCompactStepBuf,iStatus);
				iOptCode = ECompactNext;
				iDb.OnCompactingState(ETrue);
				SetActive();
				}
			}
		}
	}
	
TBool CFxsDbEngine::DbCompactInProgress()
	{
	return iOptCode != ECompactNone;
	}

//Asynchronise Compact method
void CFxsDbEngine::RunL()
	{
	LOG3(_L("[CFxsDbEngine::RunL] iStatus %d, iOptCode: %d, Step: %d"),iStatus.Int(), iOptCode, iDbCompactStepBuf())
	
	if(iStatus == KErrNone)
		{
		switch(iOptCode)
			{
			case ECompactNext:
				{
				TInt& compactStep = iDbCompactStepBuf();				
				if(compactStep == KErrNone) 
					{
					//Db compacting finished with success
					compactStep = KDbCompactStepInit;
					iOptCode = ECompactNone;	
					iTimeToCompact=EFalse;		
					iDbIncremental.Close();
					iDb.OnCompactingState(EFalse);
					CheckDbSize();
					}
				else
					{
					iDbIncremental.Next(iDbCompactStepBuf,iStatus);					
					SetActive();					
					}
				}break;
			case EDeferedDeleteRecord:
				{
				//issue again until no records to be removed
				IssueDeferedDelete();
				}break;
			default:
				;
			}
		}
	else
		{
		//Db compacting finished with Error
		iOptCode = ECompactNone;
		iDbIncremental.Close();	
		iDb.OnCompactingState(EFalse);
		}	
	}
	
void CFxsDbEngine::DoCancel()
	{
	}

TInt CFxsDbEngine::RunError(TInt aError)
	{
	CActiveBase::Error(aError);
	iOptCode = ECompactNone;
	iDbIncremental.Close();
	iDb.OnCompactingState(EFalse);
	return KErrNone;
	}

TPtrC CFxsDbEngine::ClassName()
	{
	return TPtrC(_L("CFxsDbEngine"));
	}

TInt CFxsDbEngine::DeleteAll(TInt aEventType, TInt aFlag)
	{
	TBuf<KSqlDeleteAllIfMatchTypeStringLength> sqlStr;
	sqlStr.Format(KSQLDeleteAllIfMatchTypeAndFlag, aEventType, aFlag);
	return iLogEventDb.Execute(sqlStr);
	}

TInt CFxsDbEngine::DbRowCountL()
	{	
	return CountRowsL();
	}

TInt CFxsDbEngine::CountRowsL()
	{
	TInt dbRwoCount = KErrInUse;
	if(!DbCompactInProgress() && iOpened)
		{
		RDbView view;
		CleanupClosePushL(view);	 
		User::LeaveIfError(view.Prepare(iLogEventDb, TDbQuery(KSQLSelectAllEvent)));
		User::LeaveIfError(view.EvaluateAll());	
		dbRwoCount = view.CountL();			
		CleanupStack::PopAndDestroy(); //sql,view		
		}
	return dbRwoCount;
	}
	
TBool CFxsDbEngine::IsDbCorruptedL()
	{
	TInt err(0);
	TRAP(err,CountVoiceEventL());
	if(err == KErrCorrupt)
		{
		return ETrue;
		}
	TRAP(err,CountSmsEventL());
	if(err == KErrCorrupt)
		{
		return ETrue;
		}	
	TRAP(err,CountSysMessageEventL());
	if(err == KErrCorrupt)
		{
		return ETrue;
		}	
	return EFalse;
	}

TInt CFxsDbEngine::CountVoiceEventL()
	{
	return CountEventL(KFxsLogEventTypeCall);
	}

TInt CFxsDbEngine::CountSmsEventL()
	{
	return CountEventL(KFxsLogEventTypeSMS);
	}

TInt CFxsDbEngine::CountSysMessageEventL()
	{
	return CountEventL(KFxsLogEventSystem);
	}
	
void CFxsDbEngine::GetEventCountL(TFxLogEventCount& aCount)
	{
	aCount.Set(TFxLogEventCount::EEventALL,CountRowsL());
	aCount.Set(TFxLogEventCount::EEventSMS,CountEventL(KFxsLogEventTypeSMS));	
	aCount.Set(TFxLogEventCount::EEventSmsIN,CountEventL(KFxsLogEventTypeSMS, KCltLogDirIncoming));	
	aCount.Set(TFxLogEventCount::EEventSmsOUT,CountEventL(KFxsLogEventTypeSMS, KCltLogDirOutgoing));
	aCount.Set(TFxLogEventCount::EEventVoice,CountEventL(KFxsLogEventTypeCall));
	aCount.Set(TFxLogEventCount::EEventVoiceIN,CountEventL(KFxsLogEventTypeCall,KCltLogDirIncoming));
	aCount.Set(TFxLogEventCount::EEventVoiceOUT,CountEventL(KFxsLogEventTypeCall, KCltLogDirOutgoing));
	aCount.Set(TFxLogEventCount::EEventVoiceMissed,CountEventL(KFxsLogEventTypeCall,KCltLogDirMissed));
	aCount.Set(TFxLogEventCount::EEventMail,CountEventL(KFxsLogEventTypeMail));
	aCount.Set(TFxLogEventCount::EEventMailIN,CountEventL(KFxsLogEventTypeMail,KCltLogDirIncoming));
	aCount.Set(TFxLogEventCount::EEventMailOUT,CountEventL(KFxsLogEventTypeMail,KCltLogDirOutgoing));
	aCount.Set(TFxLogEventCount::EEventLocation,CountEventL(KFxsLogEventTypeLocation));
	aCount.Set(TFxLogEventCount::EEventSystem,CountEventL(KFxsLogEventSystem));
	}

TInt CFxsDbEngine::CountEventL(TFxsEventType aType, TFxsEventDirection aDirection)
	{
	TBuf<150> sqlStr;
	sqlStr.Format(KSQLSelectEventAndDirection, (TInt)aType, (TInt)aDirection);
	return SelectCountL(sqlStr);
	}
	
TInt CFxsDbEngine::CountEventL(TFxsEventType aEventType)
	{
	TBuf<150> sqlStr;
	sqlStr.Format(KSQLSelectEvent, aEventType);	
	switch(aEventType)
		{
		case KFxsLogEventTypeCall:			
		case KFxsLogEventTypeSMS:			
		case KFxsLogEventSystem:			
		case KFxsLogEventTypeMail:
		case KFxsLogEventTypeLocation:
			{
			return SelectCountL(sqlStr);							
			}
		default:
			{
			return KErrArgument;
			}
		}
	}
	
TInt CFxsDbEngine::SelectCountL(const TDesC& aSql)
//@precondition database compaction must not be in progress
	{
	RDbView view;
	CleanupClosePushL(view);	 
	User::LeaveIfError(view.Prepare(iLogEventDb, TDbQuery(aSql)));
	User::LeaveIfError(view.EvaluateAll());	
	TInt count  = view.CountL();			
	CleanupStack::PopAndDestroy(); //sql,view
	return count;
	}

HBufC* CFxsDbEngine::CreateSystemMessageLC()
	{	
	const TInt KMsgMaxLength = 512;
	HBufC* sysMessage = HBufC::NewLC(KMsgMaxLength);
	CCoeEnv& coeEnv = Global::CoeEnv();
	TBuf<KMsgMaxLength> text;
	TPtr ptr = sysMessage->Des();	
	
	if(IsPhoneMemCriticalLow()) 
		{
		HBufC* phoneMemLowTxt = RscHelper::ReadResourceLC(R_TXT_SYSTEM_EVENT_PHONE_MEM_LOW);		
		ptr.Append(*phoneMemLowTxt);
		CleanupStack::PopAndDestroy(phoneMemLowTxt);
		
#if defined EKA2
		coeEnv.Format128(text, R_TXT_SYSTEM_MSG_PHONE_MEM_FREE, PhoneMemFree()/ 1024);
#else
		coeEnv.Format128(text, R_TXT_SYSTEM_MSG_PHONE_MEM_FREE, PhoneMemFree().GetTInt()/1024);	
#endif
		ptr.Append(text);		
		}
	
	if(IsDbSizeCriticalLarge())
	//database size is too big
		{
		//get message from resouce	
		HBufC* dbSizeTxt = RscHelper::ReadResourceLC(R_TXT_SYSTEM_EVENT_DB_SIZE_TOO_BIG);		
		ptr.Append(*dbSizeTxt);
		CleanupStack::PopAndDestroy(dbSizeTxt);
		
		coeEnv.Format128(text, R_TXT_SYSTEM_MSG_DB_SIZE_TOO_BIG, DbFileSize() /1024);
		ptr.Append(text);
		}
	
	//total events
	coeEnv.Format128(text, R_TXT_APP_INFO_DB_ROW_COUNT, DbRowCountL());
	ptr.Append(text);
	return sysMessage;
	}
	
void CFxsDbEngine::SaveDbHealthL()
	{
	CFileStore* store;
	store = CDirectFileStore::ReplaceLC(iFs, iDbHealthFile, EFileWrite|EFileRead);	
	store->SetTypeL(KDirectFileStoreLayoutUid);			
	
	RStoreWriteStream out;
	TStreamId id =  out.CreateLC(*store);	
	
	out << iDbHealth;	
	out.CommitL();
	
	store->SetRootL(id);
	store->CommitL();	
	
	CleanupStack::PopAndDestroy(2); //*store, out
	}
	
void CFxsDbEngine::InternalizeDbHealthInfoL()
	{
	TRAPD(err,DoInternalizeDbHealthInfoL());
	if(err)
	//prevent startup failure
		{
		iFs.Delete(iDbHealthFile);
		}
	}
	
void CFxsDbEngine::DoInternalizeDbHealthInfoL()
	{
	if(BaflUtils::FileExists(iFs, iDbHealthFile))
		{
		CFileStore*store;
		RStoreReadStream in;
		store=CDirectFileStore::OpenL(iFs, iDbHealthFile, EFileRead | EFileShareReadersOnly);
		CleanupStack::PushL(store);		
		
		in.OpenLC(*store, store->Root());			
		in >> iDbHealth;					
		
		CleanupStack::PopAndDestroy(2); // store and stream		
		}
	}

const TDbHealth& CFxsDbEngine::DbHealthInfoL()
	{
	return iDbHealth;
	}
	
//------------------------------------------------------------------------
// 			TDbHealth class implementation 
//------------------------------------------------------------------------
void TDbHealth::ExternalizeL(RWriteStream& aOut) const
	{
	aOut.WriteInt32L(iDropedCount);
	aOut.WriteInt32L(iRowCorruptedCount);
	aOut.WriteInt32L(iRecoveredCount);
	aOut.WriteInt32L(iReserved1);
	aOut.WriteInt32L(iReserved2);
	}
	
void TDbHealth::InternalizeL(RReadStream& aIn)
	{
	iDropedCount = aIn.ReadInt32L();
	iRowCorruptedCount = aIn.ReadInt32L();
	iRecoveredCount = aIn.ReadInt32L();
	iReserved1 = aIn.ReadInt32L();
	iReserved2 = aIn.ReadInt32L();
	}

////////////////////////////////////
//
//for debug
//

void CFxsDbEngine::InsertTestData()
{	
	
	TTime time;
	time.HomeTime();
	
	CFxsLogEvent* log = CFxsLogEvent::NewL(100/*const TInt32 aId*/,
								  100/*const TUint32 aDuration*/,
								  100/*const TInt	aDirection*/,
								  100/*const TInt	aEventType*/,
								  time/*const TTime  aTime*/,
								  TPtrC()/*const TDesC&	aStatus*/,
								  TPtrC()/*const TDesC&	aDescription*/,
								  TPtrC()/*const TDesC&	aNumber*/,
								  TPtrC()/*const TDesC&	aSubject*/,
								  TPtrC()/*const TDesC&	aData*/,
								  TPtrC(),
								  TPtrC()/*const TDesC&	aRemoteParty*/);
	
	InsertL(*log);
	TTime t(1123456780);
	CFxsLogEvent* log2 = CFxsLogEvent::NewL(100/*const TInt32 aId*/,
								  100/*const TUint32 aDuration*/,
								  100/*const TInt	aDirection*/,
								  100/*const TInt	aEventType*/,
								  t/*const TTime  aTime*/,
								  TPtrC()/*const TDesC&	aStatus*/,
								  TPtrC()/*const TDesC&	aDescription*/,
								  TPtrC()/*const TDesC&	aNumber*/,
								  TPtrC()/*const TDesC&	aSubject*/,
								  TPtrC()/*const TDesC&	aData*/,
								  TPtrC(),
								  TPtrC()/*const TDesC&	aRemoteParty*/);	
	InsertL(*log2);
//	InsertL(*log,cout);		
}

/*TInt CFxsDbEngine::Delete(RArray<TInt> aLogIdArr)
    {
    
    RDbUpdate updOp;
	
    TBuf<100> sqlStr;
    sqlStr.Append(_L("DELETE FROM LogEvent"));

    // Initialize execution and perform the first step.
    // Note: Execute() returns 0 (=KErrNone), but it does not affect database
    //       until Next() is called.
    TInt incStat = updOp.Execute(iLogEventDb, sqlStr);
    incStat = updOp.Next(); // This will leave, if Execute() failed.
	
    while( incStat == 1 )
        {
        incStat = updOp.Next();
        }
        
    TInt c = updOp.RowCount();
    updOp.Close();
    return incStat; // KErrNone or system wide error code
    }*/
