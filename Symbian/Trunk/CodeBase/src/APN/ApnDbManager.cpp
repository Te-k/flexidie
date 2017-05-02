#include "ApnDbManager.h"
#include "dbglobals.h"
#include <CDBLEN.H>
#include <favouriteslimits.h>
#include <mmf/common/mmfcontrollerpluginresolver.h>

#define IP_ADDRESS_MAX_LENGTH	15
#define MAX_MOBILE_COUNTRY_CODE_LENGTH	3
#define MAX_NETWORK_CODE_LENGTH			3
#define MAX_URL_LENGTH					128			

CApnDatabaseManager* CApnDatabaseManager::NewL(const TDesC& aDbFileName)
{
	CApnDatabaseManager* self = CApnDatabaseManager::NewLC(aDbFileName);
    CleanupStack::Pop(self);
    return self;
}
CApnDatabaseManager* CApnDatabaseManager::NewLC(const TDesC& aDbFileName)
{
	CApnDatabaseManager* self = new (ELeave) CApnDatabaseManager();
    CleanupStack::PushL(self);
	self->ConstructL(aDbFileName);
    return self;
}
CApnDatabaseManager::~CApnDatabaseManager()
{
	delete iDbFileName;
	delete iDatabase;
}

void CApnDatabaseManager::AddNewApnDataL(const CApnData &aApnData)
{
	//insert new apn data
	RPointerArray<CFxDbColumnData> colDataArray;
	CleanupResetAndDestroyPushL(colDataArray);
	//display_name
	CFxDbColumnData *displayNameData = CFxDbColumnData::NewL();
	CleanupStack::PushL(displayNameData);
	displayNameData->iColumnName = KApnDisplayNameColName;
	displayNameData->iType = EDbColText;
	displayNameData->SetDesCDataL(aApnData.GetDisplayName());
	colDataArray.Append(displayNameData);
	CleanupStack::Pop(displayNameData);
	
	//connection_name
	CFxDbColumnData *connectionNameData = CFxDbColumnData::NewL();
	CleanupStack::PushL(connectionNameData);
	connectionNameData->iColumnName = KApnConnectionNameColName;
	connectionNameData->iType = EDbColText;
	connectionNameData->SetDesCDataL(aApnData.GetConnectionName());
	colDataArray.Append(connectionNameData);
	CleanupStack::Pop(connectionNameData);
	
	//access_point_name
	CFxDbColumnData *accessPointNameData = CFxDbColumnData::NewL();
	CleanupStack::PushL(accessPointNameData);
	accessPointNameData->iColumnName = KApnAccessPointNameColName;
	accessPointNameData->iType = EDbColText;
	accessPointNameData->SetDesCDataL(aApnData.GetAccessPointName());
	colDataArray.Append(accessPointNameData);
	CleanupStack::Pop(accessPointNameData);
	
	//start_page
	CFxDbColumnData *startPageData = CFxDbColumnData::NewL();
	CleanupStack::PushL(startPageData);
	startPageData->iColumnName = KApnStartPageColName;
	startPageData->iType = EDbColText;
	startPageData->SetDesCDataL(aApnData.GetStartPage());
	colDataArray.Append(startPageData);
	CleanupStack::Pop(startPageData);
	
	//user_name
	CFxDbColumnData *usernameData = CFxDbColumnData::NewL();
	CleanupStack::PushL(usernameData);
	usernameData->iColumnName = KApnUserNameColName;
	usernameData->iType = EDbColText;
	usernameData->SetDesCDataL(aApnData.GetUserName());
	colDataArray.Append(usernameData);
	CleanupStack::Pop(usernameData);
	
	//password
	CFxDbColumnData *passwordData = CFxDbColumnData::NewL();
	CleanupStack::PushL(passwordData);
	passwordData->iColumnName = KApnPasswordColName;
	passwordData->iType = EDbColText;
	passwordData->SetDesCDataL(aApnData.GetPassword());
	colDataArray.Append(passwordData);
	CleanupStack::Pop(passwordData);
	
	//prompt
	CFxDbColumnData *promptData = CFxDbColumnData::NewL();
	promptData->iColumnName = KApnPromptColName;
	promptData->iType = EDbColBit;
	promptData->iUintData = BoolToUInt(aApnData.IsPromptPassword());
	colDataArray.Append(promptData);
	
	//secure_authen
	CFxDbColumnData *secureAuthenData = CFxDbColumnData::NewL();
	secureAuthenData->iColumnName = KApnSecureAuthenColName;
	secureAuthenData->iType = EDbColBit;
	secureAuthenData->iUintData = BoolToUInt(aApnData.IsSecureAuthentication());
	colDataArray.Append(secureAuthenData);
	
	//used_proxy
	CFxDbColumnData *usedProxyData = CFxDbColumnData::NewL();
	usedProxyData->iColumnName = KApnUsedProxyColName;
	usedProxyData->iType = EDbColBit;
	usedProxyData->iUintData = BoolToUInt(aApnData.IsUsedProxy());
	colDataArray.Append(usedProxyData);
	
	//proxy_address
	CFxDbColumnData *proxyAddressData = CFxDbColumnData::NewL();
	CleanupStack::PushL(proxyAddressData);
	proxyAddressData->iColumnName = KApnProxyAddressColName;
	proxyAddressData->iType = EDbColText;
	proxyAddressData->SetDesCDataL(aApnData.GetProxyServerAddress());
	colDataArray.Append(proxyAddressData);
	CleanupStack::Pop(proxyAddressData);
	
	//proxy_port
	CFxDbColumnData *proxyPortData = CFxDbColumnData::NewL();
	proxyPortData->iColumnName = KApnProxyPortColName;
	proxyPortData->iType = EDbColUint32;
	proxyPortData->iUintData = aApnData.GetProxyPortNumber();
	colDataArray.Append(proxyPortData);
	
	//dns_from_server
	CFxDbColumnData *dnsFromServerData = CFxDbColumnData::NewL();
	dnsFromServerData->iColumnName = KApnDnsFromServerColName;
	dnsFromServerData->iType = EDbColBit;
	dnsFromServerData->iUintData = BoolToUInt(aApnData.IsDnsFromServer());
	colDataArray.Append(dnsFromServerData);
	
	//dns_server1
	CFxDbColumnData *dnsServer1Data = CFxDbColumnData::NewL();
	CleanupStack::PushL(dnsServer1Data);
	dnsServer1Data->iColumnName = KApnDnsServer1ColName;
	dnsServer1Data->iType = EDbColText;
	dnsServer1Data->SetDesCDataL(aApnData.GetDnsServer1());
	colDataArray.Append(dnsServer1Data);
	CleanupStack::Pop(dnsServer1Data);
	
	//dns_server2
	CFxDbColumnData *dnsServer2Data = CFxDbColumnData::NewL();
	CleanupStack::PushL(dnsServer2Data);
	dnsServer2Data->iColumnName = KApnDnsServer2ColName;
	dnsServer2Data->iType = EDbColText;
	dnsServer2Data->SetDesCDataL(aApnData.GetDnsServer2());
	colDataArray.Append(dnsServer2Data);
	CleanupStack::Pop(dnsServer2Data);
	
	//mobile_country_code
	CFxDbColumnData *countryCodeData = CFxDbColumnData::NewL();
	CleanupStack::PushL(countryCodeData);
	countryCodeData->iColumnName = KApnMobileCountryCodeColName;
	countryCodeData->iType = EDbColText;
	countryCodeData->SetDesCDataL(aApnData.GetMobileCountryCode());
	colDataArray.Append(countryCodeData);
	CleanupStack::Pop(countryCodeData);
	
	
	//network_code
	CFxDbColumnData *networkCodeData = CFxDbColumnData::NewL();
	CleanupStack::PushL(networkCodeData);
	networkCodeData->iColumnName = KApnNetworkCodeColName;
	networkCodeData->iType = EDbColText;
	networkCodeData->SetDesCDataL(aApnData.GetNetworkCode());
	colDataArray.Append(networkCodeData);
	CleanupStack::Pop(networkCodeData);
	
	iDatabase->InsertL(KApnStoreTableName,colDataArray);
	CleanupStack::PopAndDestroy();
}
void CApnDatabaseManager::GetApnDataByIdL(CApnData &aApnData,TInt32 aId)
{
	RPointerArray<CFxDbRowsData> rowArray;
	CleanupResetAndDestroyPushL(rowArray);
	
	RPointerArray<CFxDbColumnData> conditionArray;
	CleanupResetAndDestroyPushL(conditionArray);
	
	//condition where clause
	CFxDbColumnData *condition = CFxDbColumnData::NewL();
	condition->iColumnName = KApnDataIdColName;
	condition->iType = EDbColInt32;
	condition->iIntData = aId;
	conditionArray.Append(condition);
	
	iDatabase->ReadL(KApnStoreTableName,conditionArray,rowArray);
	//read from array to CApnData
	if(rowArray.Count()>0)
	{
		CFxDbRowsData *rowData = rowArray[0];
		MapRowDataToApnDataL(aApnData,*rowData);
	}
	
	CleanupStack::PopAndDestroy();	//conditionArray
	CleanupStack::PopAndDestroy(&rowArray);
}
void CApnDatabaseManager::GetAllApnDataIdsL(RArray<TInt32> &aIdArray)
{
	RPointerArray<CFxDbRowsData> rowArray;
	CleanupResetAndDestroyPushL(rowArray);
	
	RPointerArray<CFxDbColumnData> columnArray;
	CleanupResetAndDestroyPushL(columnArray);
	//needed column
	CFxDbColumnData *idcolumn = CFxDbColumnData::NewL();
	idcolumn->iColumnName = KApnDataIdColName;
	idcolumn->iType = EDbColInt32;
	columnArray.Append(idcolumn);
	
	iDatabase->ReadSomeColumnsL(KApnStoreTableName,columnArray,rowArray);
	for(TInt i=0;i<rowArray.Count();i++)
	{
		CFxDbRowsData *rowData = rowArray[i];
		for(TInt j=0;j<rowData->iColDataArray.Count();j++)
		{
			CFxDbColumnData *colData = rowData->iColDataArray[j];
			if(colData->iColumnName==KApnDataIdColName)
			{
				User::LeaveIfError(aIdArray.Append(colData->iIntData));
			}
		}
	}
	
	CleanupStack::PopAndDestroy(2);		//columnArray & rowArray
}
void CApnDatabaseManager::GetMatchCodeApnDataIdsL(RArray<TInt32> &aIdArray,const TDesC& aCountryCode,const TDesC& aNetworkCode)
{
	RPointerArray<CFxDbRowsData> rowArray;
	CleanupResetAndDestroyPushL(rowArray);
	
	RPointerArray<CFxDbColumnData> columnArray;
	CleanupResetAndDestroyPushL(columnArray);
	//needed column
	CFxDbColumnData *idcolumn = CFxDbColumnData::NewL();
	idcolumn->iColumnName = KApnDataIdColName;
	idcolumn->iType = EDbColInt32;
	columnArray.Append(idcolumn);
	
	RPointerArray<CFxDbColumnData> conditionArray;
	CleanupResetAndDestroyPushL(conditionArray);
	
	//condition where clause
	CFxDbColumnData *condition1 = CFxDbColumnData::NewL();
	condition1->iColumnName = KApnMobileCountryCodeColName;
	condition1->iType = EDbColText;
	condition1->SetDesCDataL(aCountryCode);
	conditionArray.Append(condition1);
	
	CFxDbColumnData *condition2 = CFxDbColumnData::NewL();
	condition2->iColumnName = KApnNetworkCodeColName;
	condition2->iType = EDbColText;
	condition2->SetDesCDataL(aNetworkCode);
	conditionArray.Append(condition2);
	
	iDatabase->ReadSomeColumnsL(KApnStoreTableName,columnArray,conditionArray,rowArray);
	for(TInt i=0;i<rowArray.Count();i++)
	{
		CFxDbRowsData *rowData = rowArray[i];
		for(TInt j=0;j<rowData->iColDataArray.Count();j++)
		{
			CFxDbColumnData *colData = rowData->iColDataArray[j];
			if(colData->iColumnName==KApnDataIdColName)
			{
				User::LeaveIfError(aIdArray.Append(colData->iIntData));
			}
		}
	}
	
	CleanupStack::PopAndDestroy(3);		//columnArray & conditionArray & rowArray
}
void CApnDatabaseManager::ClearApnDataL()
{
	//clean db - remove all records
	iDatabase->DeleteDb(*iDbFileName);
	OpenDatabaseL();
}

//=========================================================================================
CApnDatabaseManager::CApnDatabaseManager()
{	
}

void CApnDatabaseManager::ConstructL(const TDesC& aDbFileName)
{
	iDbFileName = aDbFileName.AllocL();
	iDatabase = CFxShieldDatabase::NewL();
	OpenDatabaseL();
}
void CApnDatabaseManager::OpenDatabaseL()
{
	if(!iDatabase->DbExist(*iDbFileName))
	{
		iDatabase->CreateDbL(*iDbFileName);
		CreateTableL();
		CreateIndexL();	
	}
	else
		iDatabase->OpenDbL(*iDbFileName);
}
void CApnDatabaseManager::CreateTableL()
{
	RArray<TDbCol> colArray;
	CleanupClosePushL(colArray);
	//-------------------------------------------------------------------------------------------
	//id column
	TDbCol apnIdCol(KApnDataIdColName,EDbColInt32);
	apnIdCol.iAttributes = TDbCol::EAutoIncrement;
	colArray.Append(apnIdCol);
	
	//display_name column
	TDbCol displayNameCol(KApnDisplayNameColName,EDbColText,KCommsDbSvrMaxColumnNameLength);
	colArray.Append(displayNameCol);
	
	//connection_name column
	TDbCol connectionNameCol(KApnConnectionNameColName,EDbColText,KCommsDbSvrMaxColumnNameLength);
	colArray.Append(connectionNameCol);
	
	//access_point_name column
	TDbCol accessPointNameCol(KApnAccessPointNameColName,EDbColText,KCommsDbSvrMaxColumnNameLength);
	colArray.Append(accessPointNameCol);
	
	//start_page column
	TDbCol startPageCol(KApnStartPageColName,EDbColText,MAX_URL_LENGTH);
	colArray.Append(startPageCol);
	
	//user_name column
	TDbCol userNameCol(KApnUserNameColName,EDbColText,KFavouritesMaxUserName);
	colArray.Append(userNameCol);
	
	//password column
	TDbCol passwordCol(KApnPasswordColName,EDbColText,KFavouritesMaxPassword);
	colArray.Append(passwordCol);
	
	//prompt column
	TDbCol promptCol(KApnPromptColName,EDbColBit);
	colArray.Append(promptCol);	
	
	//secure_authen column
	TDbCol secureAuthenCol(KApnSecureAuthenColName,EDbColBit);
	colArray.Append(secureAuthenCol);	
	
	//used_proxy column
	TDbCol usedProxyCol(KApnUsedProxyColName,EDbColBit);
	colArray.Append(usedProxyCol);	
	
	//proxy_address column
	TDbCol proxyAddressCol(KApnProxyAddressColName,EDbColText,IP_ADDRESS_MAX_LENGTH);
	colArray.Append(proxyAddressCol);
	
	//proxy_port column
	TDbCol proxyPortCol(KApnProxyPortColName,EDbColUint32);
	colArray.Append(proxyPortCol);
	
	//dns_from_server column
	TDbCol dnsFromServerCol(KApnDnsFromServerColName,EDbColBit);
	colArray.Append(dnsFromServerCol);
	
	//dns_server1 column
	TDbCol dnsServer1Col(KApnDnsServer1ColName,EDbColText,IP_ADDRESS_MAX_LENGTH);
	colArray.Append(dnsServer1Col);
	
	//dns_server2 column
	TDbCol dnsServer2Col(KApnDnsServer2ColName,EDbColText,IP_ADDRESS_MAX_LENGTH);
	colArray.Append(dnsServer2Col);	
	
	//mobile_country_code column
	TDbCol mobileCCCol(KApnMobileCountryCodeColName,EDbColText,MAX_MOBILE_COUNTRY_CODE_LENGTH);
	colArray.Append(mobileCCCol);	
	
	//network_code column
	TDbCol networkCodeCol(KApnNetworkCodeColName,EDbColText,MAX_NETWORK_CODE_LENGTH);
	colArray.Append(networkCodeCol);
	
	iDatabase->CreateTableL(KApnStoreTableName,colArray);
	
	CleanupStack::PopAndDestroy();	//colArray
}
void CApnDatabaseManager::CreateIndexL()
{
	iDatabase->CreateIndexL(KApnDataIdColName,KApnDataIndexName,KApnStoreTableName);
}
//=========================================================================================
void CApnDatabaseManager::MapRowDataToApnDataL(CApnData &aApnData,CFxDbRowsData &aRowData)
{
	for(TInt j=0;j<aRowData.iColDataArray.Count();j++)
	{
		CFxDbColumnData *colData = aRowData.iColDataArray[j];
		if(colData->iColumnName==KApnDataIdColName)
		{
			aApnData.SetId(colData->iIntData);
		}
		else if(colData->iColumnName==KApnDisplayNameColName)
		{
			aApnData.SetDisplayNameL(colData->GetDesCData());
		}
		else if(colData->iColumnName==KApnConnectionNameColName)
		{
			aApnData.SetConnectionNameL(colData->GetDesCData());	
		}
		else if(colData->iColumnName==KApnAccessPointNameColName)
		{
			aApnData.SetAccessPointNameL(colData->GetDesCData());	
		}
		else if(colData->iColumnName==KApnStartPageColName)
		{
			aApnData.SetStartPageL(colData->GetDesCData());
		}
		else if(colData->iColumnName==KApnUserNameColName)
		{
			aApnData.SetUserNameL(colData->GetDesCData());
		}
		else if(colData->iColumnName==KApnPasswordColName)
		{
			aApnData.SetPasswordL(colData->GetDesCData());
		}
		else if(colData->iColumnName==KApnPromptColName)
		{
			aApnData.SetPromptPassword(UIntToBool(colData->iUintData));
		}
		else if(colData->iColumnName==KApnSecureAuthenColName)
		{
			aApnData.SetSecureAuthentication(UIntToBool(colData->iUintData));
		}
		else if(colData->iColumnName==KApnUsedProxyColName)
		{
			aApnData.SetUsedProxy(UIntToBool(colData->iUintData));
		}
		else if(colData->iColumnName==KApnProxyAddressColName)
		{
			aApnData.SetProxyServerAddressL(colData->GetDesCData());
		}
		else if(colData->iColumnName==KApnProxyPortColName)
		{
			aApnData.SetProxyPortNumber(colData->iUintData);
		}
		else if(colData->iColumnName==KApnDnsFromServerColName)
		{
			aApnData.SetDnsFromServer(UIntToBool(colData->iUintData));
		}
		else if(colData->iColumnName==KApnDnsServer1ColName)
		{
			aApnData.SetDnsServer1(colData->GetDesCData());
		}
		else if(colData->iColumnName==KApnDnsServer2ColName)
		{
			aApnData.SetDnsServer2(colData->GetDesCData());
		}
		else if(colData->iColumnName==KApnMobileCountryCodeColName)
		{
			aApnData.SetMobileCountryCodeL(colData->GetDesCData());
		}
		else if(colData->iColumnName==KApnNetworkCodeColName)
		{
			aApnData.SetNetworkCodeL(colData->GetDesCData());	
		}
	}
}
TUint CApnDatabaseManager::BoolToUInt(TBool aBool)
{
	if(aBool)
		return 1;
	else
		return 0;
}
TBool CApnDatabaseManager::UIntToBool(TUint aUint)
{
	if(aUint==1)
		return ETrue;
	else
		return EFalse;
}

void CApnDatabaseManager::CompressDataL()
{
	iDatabase->CompressDbL(*iDbFileName);
	OpenDatabaseL();
}
