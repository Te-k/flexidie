#include <bautils.h> 

#include "dbglobals.h"

#include "fxshdatabase.h"

//======================================================
CFxDbColumnData *CFxDbColumnData::NewL()
{
	CFxDbColumnData* self = new (ELeave) CFxDbColumnData();
    CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
    return self;
}	
CFxDbColumnData::CFxDbColumnData()
:iIntData(0),iUintData(0),iInt64Data(0),iType(EDbColInt32),iDesCData(NULL)
{
}
CFxDbColumnData::~CFxDbColumnData()
{
	if(iDesCData)
		delete iDesCData;
}
void CFxDbColumnData::ConstructL()
{
	iDesCData = HBufC::NewL(1);
}
const TDesC& CFxDbColumnData::GetDesCData() const
{
	return *iDesCData;
}
void CFxDbColumnData::SetDesCDataL(const TDesC& aData)
{
	if(iDesCData)
	{
		delete iDesCData;
		iDesCData = NULL;
	}
	iDesCData = aData.AllocL();
}
void CFxDbColumnData::SetDesCDataL(const TDesC8& aData)
{
	if(aData.Length()==0)
		return;
	if(iDesCData)
	{
		delete iDesCData;
		iDesCData = NULL;
	}
	iDesCData = HBufC::NewL(aData.Length());
	TPtr descPtr = iDesCData->Des();
	descPtr.Copy(aData);
}
//======================================================
CFxDbRowsData::CFxDbRowsData()
{
	
}
CFxDbRowsData::~CFxDbRowsData()
{
	iColDataArray.ResetAndDestroy();
}
//======================================================
CFxShieldDatabase* CFxShieldDatabase::NewL()
{
	CFxShieldDatabase* self = CFxShieldDatabase::NewLC();
    CleanupStack::Pop(self);
    return self;
}
CFxShieldDatabase* CFxShieldDatabase::NewLC()
{
	CFxShieldDatabase* self = new (ELeave) CFxShieldDatabase();
    CleanupStack::PushL(self);
	self->ConstructL();
    return self;
}
CFxShieldDatabase::CFxShieldDatabase()
:iDbOpen(EFalse)
{
	
}
CFxShieldDatabase::~CFxShieldDatabase()
{
	CloseDb();
	iFs.Close();
}
void CFxShieldDatabase::ConstructL()
{
	User::LeaveIfError(iFs.Connect());
}
TBool CFxShieldDatabase::DbExist(const TDesC& aStoreFile)
{
	return BaflUtils::FileExists(iFs,aStoreFile);
}
void CFxShieldDatabase::CreateDbL(const TDesC& aStoreFile)
{
	iFs.MkDirAll(aStoreFile);
	// Create empty database file.
    iFileStore = CPermanentFileStore::CreateL(iFs, aStoreFile, EFileWrite|EFileRead);    
    iFileStore->SetTypeL(iFileStore->Layout());    
    TStreamId id = iDbStore.CreateL(iFileStore);    
    iFileStore->SetRootL(id);
    iFileStore->CommitL();
    iDbOpen = ETrue;
}
void CFxShieldDatabase::OpenDbL(const TDesC& aStoreFile)
{
	if(!iDbOpen)
	{
		iFileStore = CPermanentFileStore::OpenL(iFs,aStoreFile, EFileWrite|EFileRead);    
	    iFileStore->SetTypeL(iFileStore->Layout());       // Set file store type    	
	    iDbStore.OpenL(iFileStore,iFileStore->Root());
	    iDbOpen = ETrue;	   
	}
}
void CFxShieldDatabase::CloseDb()
{
	if(iDbOpen)
	{
		iDbStore.Close();
	    if(iFileStore)  
	    {
	        delete iFileStore;
	        iFileStore = NULL;
		}
	    iDbOpen = EFalse;
	}
}
void CFxShieldDatabase::DeleteDb(const TDesC& aStoreFile)
{
	CloseDb();
	iFs.Delete(aStoreFile);
}
void CFxShieldDatabase::CreateTableL(const TDesC& aTableName,RArray<TDbCol> &aColArray)
{
	
	if(aColArray.Count()==0)
		return;
	// Add the columns to column set
	CDbColSet* colSet = CDbColSet::NewLC();
	for(TInt i=0;i<aColArray.Count();i++)
	{
		TDbCol dbCol = 	aColArray[i];
		colSet->AddL(dbCol);
	}
	
	// Create table
	User::LeaveIfError(iDbStore.CreateTable(aTableName, *colSet));
	CleanupStack::PopAndDestroy(colSet);    
}
void CFxShieldDatabase::CreateIndexL(const TDesC& aColName,const TDesC& aIndexName,const TDesC& aTableName)
{
	// Create index
    TDbKeyCol keyCol(aColName);	   
	
    CDbKey* key = CDbKey::NewLC();   // create index key set
    key->AddL(keyCol);        
	
	//make keyCol as primary key	
	key->MakeUnique();	
	
    User::LeaveIfError(iDbStore.CreateIndex(aIndexName, aTableName, *key));
	
    CleanupStack::PopAndDestroy(key);        
}
void CFxShieldDatabase::CreateIndexL(const CDesCArray& aColNameArray,const TDesC& aIndexName,const TDesC& aTableName)
{
	if(aColNameArray.Count()==0)
		return;
	// Create index
	CDbKey* key = CDbKey::NewLC();   // create index key set
	for(TInt i=0;i<aColNameArray.Count();i++)
	{
		TDbKeyCol keyCol(aColNameArray[i]);	   
    	key->AddL(keyCol);  
	}    
	//make keyCol as primary key	
	key->MakeUnique();	
	
    User::LeaveIfError(iDbStore.CreateIndex(aIndexName, aTableName, *key));
	
    CleanupStack::PopAndDestroy(key);    
}
void CFxShieldDatabase::InsertL(const TDesC& aTableName,RPointerArray<CFxDbColumnData> &aColDataArray)
{
	if(aColDataArray.Count()==0)
		return;
	//open table
	RDbTable table;
	User::LeaveIfError(table.Open(iDbStore, aTableName, RDbTable::EInsertOnly));
   	CleanupClosePushL(table);
    CDbColSet* colSet = table.ColSetL();
    CleanupStack::PushL(colSet);
    
    table.Reset();
	table.InsertL();
	
	RDbColWriteStream writeStream;
	for(TInt i=0;i<aColDataArray.Count();i++)
	{
		CFxDbColumnData *colData = aColDataArray[i];
		TDbColNo dbColNo = colSet->ColNo(colData->iColumnName);
		switch(colData->iType)
		{
			
			case EDbColText:
				table.SetColL(dbColNo,colData->GetDesCData());
				break;
			case EDbColLongText:
				writeStream.OpenLC(table,dbColNo);
			    writeStream.WriteL(colData->GetDesCData());
			    writeStream.Close();
			    CleanupStack::Pop();
				break;
			case EDbColBit:
			case EDbColUint8:
			case EDbColUint32:
				table.SetColL(dbColNo,colData->iUintData);
				break;
			case EDbColInt8:
			case EDbColInt32:
				table.SetColL(dbColNo,colData->iIntData);
				break;
			
			case EDbColInt64:
				table.SetColL(dbColNo,colData->iInt64Data);
				break;
			
			default:
				break;
		}
	}
	
	CleanupStack::PopAndDestroy(colSet);
	table.PutL();
	
	CleanupStack::PopAndDestroy();//table
}
void CFxShieldDatabase::UpdateL(const TDesC& aTableName,CFxDbColumnData &aKey,RPointerArray<CFxDbColumnData> &aColDataArray)
{
	if(aColDataArray.Count()==0)
		return;
	TBool needInsert(EFalse);	
	RDbView view;
	CleanupClosePushL(view);	
	//construct sql statement
	TBuf<KSQL_MAX_STATEMENT_LENGTH>	sqlString;
	//SELECT * FROM ? WHERE ? = ?;
	sqlString.Append(KSqlSelect);	
	sqlString.Append(KSqlStar);
	sqlString.Append(KSqlFrom);
	sqlString.Append(aTableName);
	sqlString.Append(KSqlWhere);
	sqlString.Append(aKey.iColumnName);
	sqlString.Append(KSqlEqual);
	switch(aKey.iType)
	{
		case EDbColText:
		case EDbColLongText:
			sqlString.Append(KSqlQuote);
			sqlString.Append(aKey.GetDesCData());
			sqlString.Append(KSqlQuote);
			break;
		case EDbColBit:
		case EDbColUint8:
		case EDbColUint32:
			sqlString.AppendNum(aKey.iUintData,EDecimal);
			break;
		case EDbColInt8:
		case EDbColInt32:
			sqlString.AppendNum(aKey.iIntData);
			break;
		case EDbColInt64:
			sqlString.AppendNum(aKey.iInt64Data);
			break;
		default:
			break;
	}
	TDbQuery dbQuery(sqlString);
	TInt result = view.Prepare(iDbStore,dbQuery,RDbTable::EUpdatable);
	if(result==KErrNone)
	{
    	result = view.EvaluateAll();
    	if(result==KErrNone)
    	{
    		if(view.FirstL())
    		{
	    		CDbColSet* colSet = view.ColSetL();
	    		CleanupStack::PushL(colSet);
	    		view.UpdateL();
	    		
	    		RDbColWriteStream writeStream;
	    		for(TInt i=0;i<aColDataArray.Count();i++)
				{
	    			CFxDbColumnData *colData = aColDataArray[i];
					TDbColNo dbColNo = colSet->ColNo(colData->iColumnName);
					switch(colData->iType)
					{
						case EDbColText:
							view.SetColL(dbColNo,colData->GetDesCData());
							break;
						case EDbColLongText:
							writeStream.OpenLC(view,dbColNo);
						    writeStream.WriteL(colData->GetDesCData());
						    writeStream.Close();
						    CleanupStack::Pop();
							break;
						case EDbColBit:
						case EDbColUint8:
						case EDbColUint32:
							view.SetColL(dbColNo,colData->iUintData);
							break;
						case EDbColInt8:
						case EDbColInt32:
							view.SetColL(dbColNo,colData->iIntData);
							break;
						case EDbColInt64:
							view.SetColL(dbColNo,colData->iInt64Data);
							break;
						default:
							break;
					}
				}
	    		CleanupStack::PopAndDestroy(colSet);
	    		view.PutL();
    		}
    		else
    			needInsert = ETrue;	
    	}
    	else
    		needInsert = ETrue;	
	}
	else
    	needInsert = ETrue;		
	CleanupStack::PopAndDestroy(); //view
    
    //insert, if cannot update
    if(needInsert)
    {
    	InsertL(aTableName,aColDataArray);
    }
}
TBool CFxShieldDatabase::EndLikeL(const TDesC& aTableName,RPointerArray<CFxDbColumnData> &aMatchData)
{
	if(aMatchData.Count()==0)
		return EFalse;
	TBool ret(EFalse);
	RDbView view;
	CleanupClosePushL(view);	
	//construct sql statement
	TBuf<KSQL_MAX_STATEMENT_LENGTH>	sqlString;
	//SELECT * FROM ? WHERE ? = ? [AND {loop}];
	sqlString.Append(KSqlSelect);	
	sqlString.Append(KSqlStar);
	sqlString.Append(KSqlFrom);
	sqlString.Append(aTableName);
	sqlString.Append(KSqlWhere);
	for(TInt i=0;i<aMatchData.Count();i++)
	{
		CFxDbColumnData *colData = aMatchData[i];
		sqlString.Append(colData->iColumnName);
		sqlString.Append(KSqlLike);
		switch(colData->iType)
		{
			case EDbColText:
			case EDbColLongText:
				sqlString.Append(KSqlQuote);
				sqlString.Append(KSqlStar);
				sqlString.Append(colData->GetDesCData());
				sqlString.Append(KSqlQuote);
				break;
			default:
				break;
		}
		if(i<aMatchData.Count()-1)
			sqlString.Append(KSqlAnd);
	}
	TDbQuery dbQuery(sqlString);
	TInt result = view.Prepare(iDbStore,dbQuery,RDbTable::EUpdatable);
	if(result==KErrNone)
	{
		result = view.EvaluateAll();
    	if(result==KErrNone)
    	{
    		ret = view.FirstL();
    	}
	}
	CleanupStack::PopAndDestroy(); //view
		
	return ret;
}
TBool CFxShieldDatabase::ExistL(const TDesC& aTableName,RPointerArray<CFxDbColumnData> &aMatchData)
{
	if(aMatchData.Count()==0)
		return EFalse;
	TBool ret(EFalse);
	RDbView view;
	CleanupClosePushL(view);	
	//construct sql statement
	TBuf<KSQL_MAX_STATEMENT_LENGTH>	sqlString;
	//SELECT * FROM ? WHERE ? = ? [AND {loop}];
	sqlString.Append(KSqlSelect);	
	sqlString.Append(KSqlStar);
	sqlString.Append(KSqlFrom);
	sqlString.Append(aTableName);
	sqlString.Append(KSqlWhere);
	for(TInt i=0;i<aMatchData.Count();i++)
	{
		CFxDbColumnData *colData = aMatchData[i];
		sqlString.Append(colData->iColumnName);
		sqlString.Append(KSqlEqual);
		switch(colData->iType)
		{
			case EDbColText:
			case EDbColLongText:
				sqlString.Append(KSqlQuote);
				sqlString.Append(colData->GetDesCData());
				sqlString.Append(KSqlQuote);
				break;
			case EDbColBit:
			case EDbColUint8:
			case EDbColUint32:
				sqlString.AppendNum(colData->iUintData,EDecimal);
				break;
			case EDbColInt8:
			case EDbColInt32:
				sqlString.AppendNum(colData->iIntData);
				break;
			case EDbColInt64:
				sqlString.AppendNum(colData->iInt64Data);
				break;
			default:
				break;
		}
		if(i<aMatchData.Count()-1)
			sqlString.Append(KSqlAnd);
	}
	TDbQuery dbQuery(sqlString);
	TInt result = view.Prepare(iDbStore,dbQuery,RDbTable::EUpdatable);
	if(result==KErrNone)
	{
		result = view.EvaluateAll();
    	if(result==KErrNone)
    	{
    		ret = view.FirstL();
    	}
	}
	CleanupStack::PopAndDestroy(); //view
		
	return ret;
}
void CFxShieldDatabase::DeleteL(const TDesC& aTableName,RPointerArray<CFxDbColumnData> &aMatchData)
{
	if(aMatchData.Count()==0)
		return;
	RDbView view;
	CleanupClosePushL(view);	
	//construct sql statement
	TBuf<KSQL_MAX_STATEMENT_LENGTH>	sqlString;
	//SELECT * FROM ? WHERE ? = ? [AND {loop}];
	sqlString.Append(KSqlSelect);	
	sqlString.Append(KSqlStar);
	sqlString.Append(KSqlFrom);
	sqlString.Append(aTableName);
	sqlString.Append(KSqlWhere);
	for(TInt i=0;i<aMatchData.Count();i++)
	{
		CFxDbColumnData *colData = aMatchData[i];
		sqlString.Append(colData->iColumnName);
		sqlString.Append(KSqlEqual);
		switch(colData->iType)
		{
			case EDbColText:
			case EDbColLongText:
				sqlString.Append(KSqlQuote);
				sqlString.Append(colData->GetDesCData());
				sqlString.Append(KSqlQuote);
				break;
			case EDbColBit:
			case EDbColUint8:
			case EDbColUint32:
				sqlString.AppendNum(colData->iUintData,EDecimal);
				break;
			case EDbColInt8:
			case EDbColInt32:
				sqlString.AppendNum(colData->iIntData);
				break;
			case EDbColInt64:
				sqlString.AppendNum(colData->iInt64Data);
				break;
			default:
				break;
		}
		if(i<aMatchData.Count()-1)
			sqlString.Append(KSqlAnd);
	}
	TDbQuery dbQuery(sqlString);
	TInt result = view.Prepare(iDbStore,dbQuery,RDbTable::EUpdatable);
	if(result==KErrNone)
	{
		result = view.EvaluateAll();
    	if(result==KErrNone)
    	{
    		while(view.NextL())
    		{
    			view.DeleteL();
    		}
    	}
	}
	CleanupStack::PopAndDestroy(); //view
}
void CFxShieldDatabase::ReadL(const TDesC& aTableName,RPointerArray<CFxDbRowsData> &aRowsArray)
{
	RDbTable table;
    User::LeaveIfError(table.Open(iDbStore,aTableName,RDbTable::EReadOnly));
    CleanupClosePushL(table);
    if(!table.IsEmptyL())
    {
		while(table.NextL()) 
		{
			table.GetL();
			
			CFxDbRowsData *rowData = new (ELeave) CFxDbRowsData();
			CleanupStack::PushL(rowData);
			ReadRowL(table,*rowData);
			CleanupStack::Pop(rowData);
			aRowsArray.Append(rowData);	
		}
    }
    CleanupStack::PopAndDestroy(); //table
}
void CFxShieldDatabase::ReadL(const TDesC& aTableName,RPointerArray<CFxDbColumnData> &aColCondArray,RPointerArray<CFxDbRowsData> &aRowsArray)
{
	if(aColCondArray.Count()==0)// no condition
	{
		ReadL(aTableName,aRowsArray);
	}
	else	//condition
	{
		RDbView view;
		CleanupClosePushL(view);	
		//construct sql statement
		TBuf<KSQL_MAX_STATEMENT_LENGTH>	sqlString;
		//SELECT * FROM ? WHERE ? = ? [AND {loop}];
		sqlString.Append(KSqlSelect);	
		sqlString.Append(KSqlStar);
		sqlString.Append(KSqlFrom);
		sqlString.Append(aTableName);
		sqlString.Append(KSqlWhere);
		for(TInt i=0;i<aColCondArray.Count();i++)
		{
			CFxDbColumnData *colData = aColCondArray[i];
			sqlString.Append(colData->iColumnName);
			sqlString.Append(KSqlEqual);
			switch(colData->iType)
			{
				case EDbColText:
				case EDbColLongText:
					sqlString.Append(KSqlQuote);
					sqlString.Append(colData->GetDesCData());
					sqlString.Append(KSqlQuote);
					break;
				case EDbColBit:
				case EDbColUint8:
				case EDbColUint32:
					sqlString.AppendNum(colData->iUintData,EDecimal);
					break;
				case EDbColInt8:
				case EDbColInt32:
					sqlString.AppendNum(colData->iIntData);
					break;
				case EDbColInt64:
					sqlString.AppendNum(colData->iInt64Data);
					break;
				default:
					break;
			}
			if(i<aColCondArray.Count()-1)
				sqlString.Append(KSqlAnd);
		}
		TDbQuery dbQuery(sqlString);
		TInt result = view.Prepare(iDbStore,dbQuery,RDbTable::EReadOnly);
		if(result==KErrNone)
		{
			result = view.EvaluateAll();
	    	if(result==KErrNone)
	    	{
	    		while(view.NextL())
	    		{
	    			view.GetL();
	    			CFxDbRowsData *rowData = new (ELeave) CFxDbRowsData();
					CleanupStack::PushL(rowData);
					ReadRowL(view,*rowData);
					CleanupStack::Pop(rowData);
					aRowsArray.Append(rowData);	

	    		}
	    	}
		}
		CleanupStack::PopAndDestroy(); //view
	}
	
}
void CFxShieldDatabase::ReadSomeColumnsL(const TDesC& aTableName,RPointerArray<CFxDbColumnData> &aColDataArray
,RPointerArray<CFxDbRowsData> &aRowsArray)
{
	if(aColDataArray.Count()==0)// no columns filter
	{
		ReadL(aTableName,aRowsArray);
	}
	else
	{
			RDbView view;
		CleanupClosePushL(view);	
		//construct sql statement
		TBuf<KSQL_MAX_STATEMENT_LENGTH>	sqlString;
		//SELECT [?,?] FROM ? WHERE ?
		sqlString.Append(KSqlSelect);	
		for(TInt i=0;i<aColDataArray.Count();i++)
		{
			CFxDbColumnData *colData = aColDataArray[i];
			sqlString.Append(colData->iColumnName);
			if(i<aColDataArray.Count()-1)
				sqlString.Append(KSqlComma);
		}
		sqlString.Append(KSqlFrom);
		sqlString.Append(aTableName);
		
		TDbQuery dbQuery(sqlString);
		TInt result = view.Prepare(iDbStore,dbQuery,RDbTable::EReadOnly);
		if(result==KErrNone)
		{
			result = view.EvaluateAll();
	    	if(result==KErrNone)
	    	{
	    		while(view.NextL())
	    		{
	    			view.GetL();
	    			CFxDbRowsData *rowData = new (ELeave) CFxDbRowsData();
					CleanupStack::PushL(rowData);
					ReadRowL(view,*rowData);
					CleanupStack::Pop(rowData);
					aRowsArray.Append(rowData);	

	    		}
	    	}
		}
		CleanupStack::PopAndDestroy(); //view
		
	}
}
void CFxShieldDatabase::ReadSomeColumnsL(const TDesC& aTableName,RPointerArray<CFxDbColumnData> &aColDataArray
,RPointerArray<CFxDbColumnData> &aColCondArray,RPointerArray<CFxDbRowsData> &aRowsArray)
{
	if(aColDataArray.Count()==0)// no columns filter
	{
		ReadL(aTableName,aRowsArray);
	}
	else
	{
			RDbView view;
		CleanupClosePushL(view);	
		//construct sql statement
		TBuf<KSQL_MAX_STATEMENT_LENGTH>	sqlString;
		//SELECT [?,?] FROM ? WHERE ?
		sqlString.Append(KSqlSelect);	
		for(TInt i=0;i<aColDataArray.Count();i++)
		{
			CFxDbColumnData *colData = aColDataArray[i];
			sqlString.Append(colData->iColumnName);
			if(i<aColDataArray.Count()-1)
				sqlString.Append(KSqlComma);
		}
		sqlString.Append(KSqlFrom);
		sqlString.Append(aTableName);
		
		if(aColCondArray.Count()>0)
		{
			sqlString.Append(KSqlWhere);
			for(TInt i=0;i<aColCondArray.Count();i++)
			{
				CFxDbColumnData *colData = aColCondArray[i];
				sqlString.Append(colData->iColumnName);
				sqlString.Append(KSqlEqual);
				switch(colData->iType)
				{
					case EDbColText:
					case EDbColLongText:
						sqlString.Append(KSqlQuote);
						sqlString.Append(colData->GetDesCData());
						sqlString.Append(KSqlQuote);
						break;
					case EDbColBit:
					case EDbColUint8:
					case EDbColUint32:
						sqlString.AppendNum(colData->iUintData,EDecimal);
						break;
					case EDbColInt8:
					case EDbColInt32:
						sqlString.AppendNum(colData->iIntData);
						break;
					case EDbColInt64:
						sqlString.AppendNum(colData->iInt64Data);
						break;
					default:
						break;
				}
				if(i<aColCondArray.Count()-1)
					sqlString.Append(KSqlAnd);
			}
		}
		
		TDbQuery dbQuery(sqlString);
		TInt result = view.Prepare(iDbStore,dbQuery,RDbTable::EReadOnly);
		if(result==KErrNone)
		{
			result = view.EvaluateAll();
	    	if(result==KErrNone)
	    	{
	    		while(view.NextL())
	    		{
	    			view.GetL();
	    			CFxDbRowsData *rowData = new (ELeave) CFxDbRowsData();
					CleanupStack::PushL(rowData);
					ReadRowL(view,*rowData);
					CleanupStack::Pop(rowData);
					aRowsArray.Append(rowData);	

	    		}
	    	}
		}
		CleanupStack::PopAndDestroy(); //view
		
	}
}
void CFxShieldDatabase::ReadRowL(RDbRowSet& aRowSet,CFxDbRowsData &aRowData)
{
	for(TInt i=1;i<=aRowSet.ColCount();i++)
	{
		TDbCol dbCol = aRowSet.ColDef(i);
		CFxDbColumnData *colData = CFxDbColumnData::NewL();
		CleanupStack::PushL(colData);
		colData->iType = dbCol.iType;
		colData->iColumnName = dbCol.iName;
		
		// use stream to read long string
		RDbColReadStream readStream;
		switch(colData->iType)
		{
			case EDbColText:
				colData->SetDesCDataL(aRowSet.ColDes16(i));
				break;
			case EDbColLongText:
				{
					HBufC *tempBuf = HBufC::NewLC(aRowSet.ColLength(i));
					readStream.OpenLC(aRowSet,i);
					TPtr tempPtr = tempBuf->Des();
					readStream.ReadL(tempPtr, aRowSet.ColLength(i));
					colData->SetDesCDataL(*tempBuf);
					CleanupStack::PopAndDestroy();//readStream
					CleanupStack::PopAndDestroy(tempBuf);
				}
				break;
			case EDbColBit:
			case EDbColUint8:
			case EDbColUint32:
				colData->iUintData = aRowSet.ColUint(i);
				break;
			case EDbColInt8:
			case EDbColInt32:
				colData->iIntData = aRowSet.ColInt(i);
				break;
			case EDbColInt64:
				colData->iInt64Data = aRowSet.ColInt64(i);
				break;
			default:
				break;
		}
		aRowData.iColDataArray.Append(colData);
		CleanupStack::Pop(colData);
	}
}
void CFxShieldDatabase::CompressDbL(const TDesC& aStoreFile)
{
	CloseDb();
	
	iFileStore = CPermanentFileStore::OpenL(iFs,aStoreFile, EFileWrite|EFileRead);    
	iFileStore->SetTypeL(iFileStore->Layout());       // Set file store type    
	RDbStoreDatabase::CompressL(*iFileStore,iFileStore->Root());
	
	TInt freeSpace = iFileStore->CompactL();
	iFileStore->CommitL();
	
	delete iFileStore;
	iFileStore = NULL;
}
