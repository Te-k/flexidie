#include "ApnAppWizardReader.h"

const TInt CApnAppWizardReader::KMaxTableNamesLength = 64;
const TInt CApnAppWizardReader::KMaxDumpBuffer = 512;
const TInt CApnAppWizardReader::KSqlMaxStatementLength = 128;

const TInt CApnAppWizardReader::KDefaultArrayGran = 2;

//sql element
_LIT(KSqlSelect,"SELECT ");
_LIT(KSqlStar,"*");
_LIT(KSqlFrom," FROM ");
_LIT(KSqlWhere," WHERE ");
_LIT(KSqlEqual," = ");
_LIT(KSqlQuote,"\'");
_LIT(KSqlAnd," AND ");
_LIT(KSqlLike," LIKE ");
_LIT(KSqlPercent, "%");
_LIT(KSqlComma,",");

_LIT(KDefaultIpAddress,"0.0.0.0");

//table element
_LIT(KGsmCodeTableName,"GSMMNC");
_LIT(KGsmOpIDColumnName,"GSMOpID");
_LIT(KMobileCountryCodeColumnName,"MCC");
_LIT(KMobileNetworkCodeColumnName,"MNC");

_LIT(KGPRSSettingTableName,"GPRSSetting");
_LIT(KGPRSSettingIdColumnName,"GPRSSettingID");
_LIT(KGPRSConnectionNameColumnName,"ConnectionName");
_LIT(KGPRSPromptPasswordColumnName,"PromptPassword");
_LIT(KGPRSAuthenticationColumnName,"Authentication");
_LIT(KGPRSConnectionSecurityColumnName,"ConnectionSecurity");
_LIT(KGPRSPortNumColumnName,"PortNum");
_LIT(KGPRSAccessPointNameColumnName,"AccessPointName");
_LIT(KGPRSUserNameColumnName,"UserName");
_LIT(KGPRSPasswordColumnName,"Password");
_LIT(KGPRSHomepageColumnName,"Homepage");
_LIT(KGPRSPriNameSrvrColumnName,"PriNameSrvr");
_LIT(KGPRSSndNameSrvrColumnName,"SndNameSrvr");
_LIT(KGPRSProxySrvrAddrColumnName,"ProxySrvrAddr");

CApnAppWizardReader* CApnAppWizardReader::NewL(RFs& aFs)
{
	CApnAppWizardReader* self = new (ELeave) CApnAppWizardReader(aFs);
    CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
    return self;
}
CApnAppWizardReader::CApnAppWizardReader(RFs& aFs)
:iFs(aFs)
{
	iDbOpened = EFalse;
}
CApnAppWizardReader::~CApnAppWizardReader()
{
	//CloseDumpFile();
	CloseDb();	
}
void CApnAppWizardReader::ConstructL()
{	
}

void CApnAppWizardReader::OpenDbL(const TDesC& aStoreFile)
{
	if(iDbOpened)
		return;
	iFileStore = CPermanentFileStore::OpenL(iFs,aStoreFile, EFileWrite|EFileRead);    
	iFileStore->SetTypeL(iFileStore->Layout());
	iDbStore.OpenL(iFileStore,iFileStore->Root());
	
	iDbOpened = ETrue;
}
void CApnAppWizardReader::CloseDb()
{
	if(!iDbOpened)
		return;
	iDbStore.Close();
    if(iFileStore)  
    {
        delete iFileStore;
        iFileStore = NULL;
	}
    iDbOpened = EFalse;
}
/////////////////// Read Sections /////////////////////////
void CApnAppWizardReader::GetMatchCodeApnDataIdsL(CDesCArray &aIdArray,const TDesC& aCountryCode,const TDesC& aNetworkCode)
{
	if(!iDbOpened)
	{
		User::Leave(KErrNotReady);	
	}
	CDesCArrayFlat *opIdArray = new (ELeave) CDesCArrayFlat(KDefaultArrayGran);
	CleanupStack::PushL(opIdArray);
	
	RDbView view;
	CleanupClosePushL(view);
	//Ensure that all codes are number
	TLex ccLex(aCountryCode);
	TInt ccInt;
	TInt convErr = ccLex.Val(ccInt);
	if(convErr!=KErrNone)
	{
		User::Leave(KErrArgument);
	}
	TLex ncLex(aNetworkCode);
	TInt ncInt;
	convErr = ncLex.Val(ncInt);
	if(convErr!=KErrNone)
	{
		User::Leave(KErrArgument);
	}
	
	TBuf<KSqlMaxStatementLength> sqlString;
	//SELECT GSMOpID FROM GSMMNC WHERE MCC = aCountryCode AND MNC = aNetworkCode
	sqlString.Append(KSqlSelect);
	sqlString.Append(KGsmOpIDColumnName);
	sqlString.Append(KSqlFrom);
	sqlString.Append(KGsmCodeTableName);
	sqlString.Append(KSqlWhere);
	sqlString.Append(KMobileCountryCodeColumnName);
	sqlString.Append(KSqlEqual);
	sqlString.Append(aCountryCode);
	sqlString.Append(KSqlAnd);
	sqlString.Append(KMobileNetworkCodeColumnName);
	sqlString.Append(KSqlEqual);
	sqlString.Append(aNetworkCode);
	
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
    			for(TInt i=1;i<=view.ColCount();i++)
				{
					TDbCol dbCol = view.ColDef(i);
					if(dbCol.iName == KGsmOpIDColumnName)
						opIdArray->AppendL(view.ColDes16(i));
				}
	    	}
	    }
	}
	CleanupStack::PopAndDestroy(); //view
	
	//Select id from gprssetting table
	TBuf<KGSMOpIDMaxLength> opIdBuffer;
	for(TInt j=0;j<opIdArray->Count();j++)
	{
		opIdBuffer = (*opIdArray)[j];
		GetGprsSettingIdsByOpIdL(aIdArray,opIdBuffer);
	}
	
	CleanupStack::PopAndDestroy(opIdArray);
}
void CApnAppWizardReader::GetApnDataByIdL(CApnData &aApnData,const TDesC& aId)
{
	if(!iDbOpened)
	{
		User::Leave(KErrNotReady);	
	}
	
	TBuf<KSqlMaxStatementLength> sqlString;
	RDbView view;
	CleanupClosePushL(view);
	//SELECT * FROM GPRSSetting WHERE GPRSSettingID = '?'
	sqlString.Append(KSqlSelect);
	sqlString.Append(KSqlStar);
	sqlString.Append(KSqlFrom);
	sqlString.Append(KGPRSSettingTableName);
	sqlString.Append(KSqlWhere);
	sqlString.Append(KGPRSSettingIdColumnName);
	sqlString.Append(KSqlEqual);
	sqlString.Append(KSqlQuote);
	sqlString.Append(aId);
	sqlString.Append(KSqlQuote);
	
	TDbQuery dbQuery(sqlString);
	TInt result = view.Prepare(iDbStore,dbQuery,RDbTable::EReadOnly);
	if(result==KErrNone)
	{
		result = view.EvaluateAll();
	    if(result==KErrNone)
	    {
	    	if(view.NextL())
	    	{
	    		view.GetL();
	    		ReadApnRowL(view,aApnData);
	    	}
	    }
	}
	CleanupStack::PopAndDestroy(); //view
}
void CApnAppWizardReader::ReadApnRowL(RDbRowSet& aRowSet,CApnData &aRowData)
{
	for(TInt i=1;i<=aRowSet.ColCount();i++)
	{
		TDbCol dbCol = aRowSet.ColDef(i);
		
		// use stream to read long string
		RDbColReadStream readStream;
		
		if(dbCol.iName==KGPRSSettingIdColumnName)
		{
			aRowData.SetIdTextL(aRowSet.ColDes16(i));
		}
		else if(dbCol.iName==KGPRSConnectionNameColumnName)
		{
			aRowData.SetConnectionNameL(aRowSet.ColDes16(i));	
		}
		else if(dbCol.iName==KGPRSAccessPointNameColumnName)
		{
			aRowData.SetAccessPointNameL(aRowSet.ColDes16(i));	
		}
		else if(dbCol.iName==KGPRSHomepageColumnName)
		{
			aRowData.SetStartPageL(aRowSet.ColDes16(i));	
		}
		else if(dbCol.iName==KGPRSUserNameColumnName)
		{
			aRowData.SetUserNameL(aRowSet.ColDes16(i));	
		}
		else if(dbCol.iName==KGPRSPasswordColumnName)
		{
			aRowData.SetPasswordL(aRowSet.ColDes16(i));	
		}
		else if(dbCol.iName==KGPRSPromptPasswordColumnName)
		{
			if(aRowSet.ColUint(i)>0)
				aRowData.SetPromptPassword(ETrue);
			else
				aRowData.SetPromptPassword(EFalse);
		}
		else if(dbCol.iName==KGPRSAuthenticationColumnName)
		{
			if(aRowSet.ColUint(i)>0)
				aRowData.SetSecureAuthentication(ETrue);
			else
				aRowData.SetSecureAuthentication(EFalse);
		}
		else if(dbCol.iName==KGPRSProxySrvrAddrColumnName)
		{
			aRowData.SetProxyServerAddressL(aRowSet.ColDes16(i));	
		}
		else if(dbCol.iName==KGPRSPortNumColumnName)
		{
			aRowData.SetProxyPortNumber(aRowSet.ColUint(i));	
		}
		else if(dbCol.iName==KGPRSPriNameSrvrColumnName)
		{
			aRowData.SetDnsServer1(aRowSet.ColDes16(i));	
		}
		else if(dbCol.iName==KGPRSSndNameSrvrColumnName)
		{
			aRowData.SetDnsServer2(aRowSet.ColDes16(i));	
		}
	}
	//set use proxy
	if((aRowData.GetProxyServerAddress().Length()==0)||
	(aRowData.GetProxyServerAddress()==KDefaultIpAddress))
	{
		aRowData.SetUsedProxy(EFalse);	
	}
	else
	{
		aRowData.SetUsedProxy(ETrue);	
	}
	//set dns from server
	if(((aRowData.GetDnsServer1().Length()==0)||(aRowData.GetDnsServer1()==KDefaultIpAddress))&&
	((aRowData.GetDnsServer2().Length()==0)||(aRowData.GetDnsServer2()==KDefaultIpAddress)))
	{
		aRowData.SetDnsFromServer(EFalse);
	}
	else
	{
		aRowData.SetDnsFromServer(ETrue);	
	}
}

void CApnAppWizardReader::GetGprsSettingIdsByOpIdL(CDesCArray &gprsIdArray,const TDesC& opId)
{
	if(!iDbOpened)
	{
		User::Leave(KErrNotReady);	
	}
	TBuf<KSqlMaxStatementLength> sqlString;
	RDbView view;
	CleanupClosePushL(view);
	//SELECT GPRSSettingID FROM GPRSSetting WHERE GSMOpID = '?'
	sqlString.Zero();
	sqlString.Append(KSqlSelect);
	sqlString.Append(KGPRSSettingIdColumnName);
	sqlString.Append(KSqlFrom);
	sqlString.Append(KGPRSSettingTableName);
	sqlString.Append(KSqlWhere);
	sqlString.Append(KGsmOpIDColumnName);
	sqlString.Append(KSqlEqual);
	sqlString.Append(KSqlQuote);
	sqlString.Append(opId);
	sqlString.Append(KSqlQuote);
	
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
    			for(TInt i=1;i<=view.ColCount();i++)
				{
					TDbCol dbCol = view.ColDef(i);
					if(dbCol.iName == KGPRSSettingIdColumnName)
						gprsIdArray.AppendL(view.ColDes16(i));
				}
	    	}
	    }
	}
	CleanupStack::PopAndDestroy(); //view
}
void CApnAppWizardReader::GetAllApnDataIdsL(CDesCArray &aIdArray)
{
	if(!iDbOpened)
	{
		User::Leave(KErrNotReady);	
	}
	TBuf<KSqlMaxStatementLength> sqlString;
	RDbView view;
	CleanupClosePushL(view);
	//SELECT GPRSSettingID FROM GPRSSetting
	sqlString.Zero();
	sqlString.Append(KSqlSelect);
	sqlString.Append(KGPRSSettingIdColumnName);
	sqlString.Append(KSqlFrom);
	sqlString.Append(KGPRSSettingTableName);
	
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
	    		for(TInt i=1;i<=view.ColCount();i++)
				{
					TDbCol dbCol = view.ColDef(i);
					if(dbCol.iName == KGPRSSettingIdColumnName)
						aIdArray.AppendL(view.ColDes16(i));
				}
	    	}
	    }
	}
	CleanupStack::PopAndDestroy(); //view
}

/////////////////////////////////////////////////////////////
/////////////////// Dump Sections /////////////////////////
/*
void CApnAppWizardReader::DumpAllL(const TDesC& aDumpFileName)
{
	if(!iDbOpened)
	{
		User::Leave(KErrNotReady);	
	}
	OpenDumpFileL(aDumpFileName);
	CDbTableNames *tableNamesArray = iDbStore.TableNamesL();
	CleanupStack::PushL(tableNamesArray);
	TBuf<KMaxTableNamesLength>	tableNameBuffer;
	for(TInt i=0;i<tableNamesArray->Count();i++)
	{
		tableNameBuffer = (*tableNamesArray)[i];
		DumpTableL(tableNameBuffer);
	}
	CleanupStack::PopAndDestroy(tableNamesArray);
	CloseDumpFile();
}

void CApnAppWizardReader::DumpTableL(const TDesC& aTableName)
{
	if(!iDbOpened)
	{
		User::Leave(KErrNotReady);	
	}
	RDbTable table;
    User::LeaveIfError(table.Open(iDbStore,aTableName,RDbTable::EReadOnly));
    CleanupClosePushL(table);
    if(!table.IsEmptyL())
    {
		while(table.NextL()) 
		{
			table.GetL();
			// Dump Row
		}
    }
    CleanupStack::PopAndDestroy(); //table
    
}

void CApnAppWizardReader::OpenDumpFileL(const TDesC& aFileName)
{
	if(iDumpFileOpened)
		return;
	//Clear existing file
	iFs.Delete(aFileName);
	iFs.MkDirAll(aFileName);
	User::LeaveIfError(iDumpFile.Create(iFs,aFileName,EFileWrite));
	if(iDumpBuffer)
	{
		delete iDumpBuffer;
		iDumpBuffer = NULL;
	}
	iDumpBuffer = HBufC8::NewL(KMaxDumpBuffer);
	iDumpFileOpened = ETrue;
}
void CApnAppWizardReader::CloseDumpFile()
{
	if(!iDumpFileOpened)
		return;
	//flush buffer
	
	iDumpFile.Close();
	if(iDumpBuffer)
	{
		delete iDumpBuffer;
		iDumpBuffer = NULL;
	}
	iDumpFileOpened = EFalse;
}
void CApnAppWizardReader::WriteDumpFileL(const TDesC& aText)
{
	if(!iDumpFileOpened)
	{
		User::Leave(KErrNotReady);	
	}
	//Append to buffer
	
	//write to file when reach limit
	HBufC8* utf8Text = HBufC8::NewLC(aText.Length()*2);
	TPtr8 utfPtr = utf8Text->Des();
	CnvUtfConverter::ConvertFromUnicodeToUtf8(utfPtr,aText);
	iDumpFile.Write(*utf8Text);
	CleanupStack:PopAndDestroy(utf8Text);
	
}
*/
