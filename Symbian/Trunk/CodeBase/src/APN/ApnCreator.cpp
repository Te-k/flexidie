#include <commdb.h>
#include "ApnCreator.h"
#include "Logger.h"
#include <apaccesspointitem.h> 
#include <apdatahandler.h>

_LIT8(KLineSeperator,"==============================\r\n");
_LIT8(KTableName,"Table:");
_LIT8(KColumnSeperator," || ");
_LIT8(KNewLine,"\r\n");

//default value for apn
_LIT(KDefaultIpType,"ip");
_LIT(KDefaultIpAddress,"0.0.0.0");
_LIT(KDefaultProtocol,"http");
_LIT(KLocNameMobile,"Mobile");

void CApnCreator::CreateIAPL(CCommsDatabase& aCommDb, const RPointerArray<CApnData>& aApnItems, RArray<TUint32>& aUidArray)
	{
	for(TInt i=0;i<aApnItems.Count(); i++)
		{
		CApnData* apnItem = aApnItems[i];
		TUint32 iapId = CreateIAPL(aCommDb, *apnItem);
		aUidArray.Append(iapId);
		}
	}
	
TUint32 CApnCreator::CreateIAPL(CCommsDatabase& aCommDb, const CApnData& aApnData)
	{
	CApDataHandler *apDataHandler = CApDataHandler::NewLC(aCommDb);
	CApAccessPointItem *apItem = CApAccessPointItem::NewLC();
	
	apItem->SetNamesL(aApnData.GetConnectionName());	
	apItem->WriteLongTextL(EApGprsAccessPointName,aApnData.GetAccessPointName()); 
	apItem->WriteBool(EApGprsIfPromptForAuth ,aApnData.IsPromptPassword());
	if(aApnData.IsPromptPassword())
	{
		apItem->WriteTextL(EApGprsIfAuthName,aApnData.GetUserName());
		apItem->WriteTextL(EApGprsIfAuthPassword,aApnData.GetPassword());
	}
	apItem->WriteBool(EApGprsIpDnsAddrFromServer,aApnData.IsDnsFromServer());
	if(!aApnData.IsDnsFromServer()) 
	{
		apItem->WriteTextL(EApGprsIPNameServer1,aApnData.GetDnsServer1());
		apItem->WriteTextL(EApGprsIPNameServer2,aApnData.GetDnsServer2());
	}
	apItem->WriteBool(EApGprsDisablePlainTextAuth,aApnData.IsSecureAuthentication());
	apItem->WriteLongTextL(EApWapStartPage,aApnData.GetStartPage());
	apItem->WriteBool(EApProxyUseProxy,aApnData.IsUsedProxy());
	if(aApnData.IsUsedProxy()) 
	{
		apItem->WriteLongTextL(EApProxyServerAddress,aApnData.GetProxyServerAddress());
		apItem->WriteUint(EApProxyPortNumber,aApnData.GetProxyPortNumber());
	}
	
	TUint32 iapId = apDataHandler->CreateFromDataL(*apItem);
	CleanupStack::PopAndDestroy(2,apDataHandler);
	
	return iapId;
	}
/**
TUint32 CApnCreator::CreateIAPL(CCommsDatabase& aCommDb, const CApnData& aApnData)
	{
	CCommsDbTableView* view;
	
	TUint32 gprsId;	
	//1)Add record to OUTGOING_GPRS
	view = aCommDb.OpenTableLC(TPtrC(OUTGOING_GPRS));
	User::LeaveIfError(view->InsertRecord(gprsId));
	view->WriteTextL(TPtrC(COMMDB_NAME), aApnData.GetConnectionName());
	view->WriteTextL(TPtrC(GPRS_APN), aApnData.GetAccessPointName());
	view->WriteUintL(TPtrC(GPRS_PDP_TYPE), 0);
	view->WriteTextL(TPtrC(GPRS_PDP_ADDRESS), KNullDesC);
	view->WriteUintL(TPtrC(GPRS_REQ_PRECEDENCE), 0); 
	view->WriteUintL(TPtrC(GPRS_REQ_DELAY), 0);
	view->WriteUintL(TPtrC(GPRS_REQ_RELIABILITY), 0);
	view->WriteUintL(TPtrC(GPRS_REQ_PEAK_THROUGHPUT), 0);
	view->WriteUintL(TPtrC(GPRS_REQ_MEAN_THROUGHPUT), 0);
	view->WriteUintL(TPtrC(GPRS_MIN_PRECEDENCE), 0);
	view->WriteUintL(TPtrC(GPRS_MIN_DELAY), 0);
	view->WriteUintL(TPtrC(GPRS_MIN_RELIABILITY), 0);
	view->WriteUintL(TPtrC(GPRS_MIN_PEAK_THROUGHPUT), 0);
	view->WriteUintL(TPtrC(GPRS_MIN_MEAN_THROUGHPUT), 0);
	view->WriteBoolL(TPtrC(GPRS_DATA_COMPRESSION), EFalse);
	view->WriteBoolL(TPtrC(GPRS_HEADER_COMPRESSION), EFalse);
	view->WriteBoolL(TPtrC(GPRS_ANONYMOUS_ACCESS), EFalse);
	view->WriteBoolL(TPtrC(GPRS_USE_EDGE), ETrue);
	view->WriteTextL(TPtrC(GPRS_IF_PARAMS), KNullDesC);
	view->WriteTextL(TPtrC(GPRS_IF_NETWORKS), KDefaultIpType);
	view->WriteBoolL(TPtrC(GPRS_IF_PROMPT_FOR_AUTH), aApnData.IsPromptPassword());
	view->WriteTextL(TPtrC(GPRS_IF_AUTH_NAME),aApnData.GetUserName());
	view->WriteTextL(TPtrC(GPRS_IF_AUTH_PASS),aApnData.GetPassword());
	view->WriteUintL(TPtrC(GPRS_IF_AUTH_RETRIES), 0);
	view->WriteTextL(TPtrC(GPRS_IP_NETMASK),KNullDesC);
	view->WriteTextL(TPtrC(GPRS_IP_GATEWAY), KDefaultIpAddress);
	view->WriteBoolL(TPtrC(GPRS_IP_ADDR_FROM_SERVER), ETrue);
	view->WriteTextL(TPtrC(GPRS_IP_ADDR), KDefaultIpAddress);
	view->WriteBoolL(TPtrC(GPRS_IP_DNS_ADDR_FROM_SERVER), aApnData.IsDnsFromServer());
	view->WriteTextL(TPtrC(GPRS_IP_NAME_SERVER1),aApnData.GetDnsServer1());
	view->WriteTextL(TPtrC(GPRS_IP_NAME_SERVER2),aApnData.GetDnsServer2());
	view->WriteBoolL(TPtrC(GPRS_IP6_DNS_ADDR_FROM_SERVER), ETrue);
	view->WriteTextL(TPtrC(GPRS_IP6_NAME_SERVER1),KDefaultIpAddress);
	view->WriteTextL(TPtrC(GPRS_IP6_NAME_SERVER2),KDefaultIpAddress);
	view->WriteBoolL(TPtrC(GPRS_ENABLE_LCP_EXTENSIONS), EFalse);
	view->WriteBoolL(TPtrC(GPRS_DISABLE_PLAIN_TEXT_AUTH), aApnData.IsSecureAuthentication());
	view->WriteUintL(TPtrC(GPRS_AP_TYPE), 0);
	view->WriteUintL(TPtrC(GPRS_QOS_WARNING_TIMEOUT),4294967295);
	User::LeaveIfError(view->PutRecordChanges(EFalse, EFalse));

	CleanupStack::PopAndDestroy(view);

	//2)Add record to NETWORK
	TUint32 networkId;
	CCommsDbTableView* view2 = aCommDb.OpenTableLC(TPtrC(NETWORK));
	User::LeaveIfError(view2->InsertRecord(networkId));
	view2->WriteTextL(TPtrC(COMMDB_NAME),aApnData.GetConnectionName());
	User::LeaveIfError(view2->PutRecordChanges(EFalse, EFalse));
	CleanupStack::PopAndDestroy(view2);
	

	//3)SEARCH FOR Mobile LOCATION id
	TInt result;
	TUint32 locationId;
	TUint32 mobileLocationId = 0;
	
	// Open Database
	
	CCommsDbTableView* view3 = aCommDb.OpenTableLC(TPtrC(LOCATION));
	// Walk through records
	result = view3->GotoFirstRecord();
	TBuf<128> locationName;
	while (result == KErrNone)
	{
		view3->ReadTextL(TPtrC(COMMDB_NAME), locationName);
		view3->ReadUintL(TPtrC(COMMDB_ID), locationId);
		if (locationName.Match(KLocNameMobile)!= KErrNotFound)
			mobileLocationId = locationId;
		result = view3->GotoNextRecord();
	}
	CleanupStack::PopAndDestroy(view3);
	
	//4)Create IAP
	TUint32 iapId;
	
	CCommsDbTableView* view4;
	view4 = aCommDb.OpenTableLC(TPtrC(IAP));
	User::LeaveIfError(view4->InsertRecord(iapId));
	view4->WriteTextL(TPtrC(COMMDB_NAME), aApnData.GetConnectionName());
	view4->WriteUintL(TPtrC(IAP_SERVICE), gprsId);
	view4->WriteTextL(TPtrC(IAP_SERVICE_TYPE), TPtrC(OUTGOING_GPRS));
	view4->WriteUintL(TPtrC(IAP_BEARER), ECommDbBearerGPRS);
	view4->WriteTextL(TPtrC(IAP_BEARER_TYPE), TPtrC(MODEM_BEARER));
	view4->WriteUintL(TPtrC(IAP_NETWORK), networkId);
	view4->WriteUintL(TPtrC(IAP_NETWORK_WEIGHTING), 0);
	view4->WriteUintL(TPtrC(IAP_LOCATION), mobileLocationId);
	User::LeaveIfError(view4->PutRecordChanges(EFalse, EFalse));

	CleanupStack::PopAndDestroy(view4);
	
	//5) CREATE WAP_ACCESS_POINT
	
	TUint32 wapId;
	CCommsDbTableView* view5 = aCommDb.OpenTableLC(TPtrC(WAP_ACCESS_POINT));
	User::LeaveIfError(view5->InsertRecord(wapId));
	view5->WriteTextL(TPtrC(COMMDB_NAME), aApnData.GetConnectionName());
	view5->WriteTextL(TPtrC(WAP_CURRENT_BEARER), TPtrC(WAP_IP_BEARER));
	view5->WriteTextL(TPtrC(WAP_START_PAGE), aApnData.GetStartPage());
	User::LeaveIfError(view5->PutRecordChanges(EFalse, EFalse));

	CleanupStack::PopAndDestroy(view5);

	//6) Create WAP_IP_BEARER
	TUint32 wapIPId;
	
	CCommsDbTableView* view6 = aCommDb.OpenTableLC(TPtrC(WAP_IP_BEARER));
	User::LeaveIfError(view6->InsertRecord(wapIPId));
	view6->WriteUintL(TPtrC(WAP_ACCESS_POINT_ID), wapId);
	view6->WriteTextL(TPtrC(WAP_GATEWAY_ADDRESS), KDefaultIpAddress);
	view6->WriteUintL(TPtrC(WAP_WSP_OPTION),EWapWspOptionConnectionOriented);
	view6->WriteBoolL(TPtrC(WAP_SECURITY), EFalse);
	view6->WriteUintL(TPtrC(WAP_IAP),iapId);
	view6->WriteUintL(TPtrC(WAP_PROXY_PORT), 0);
	view6->WriteTextL(TPtrC(WAP_PROXY_LOGIN_NAME), KNullDesC);
	view6->WriteTextL(TPtrC(WAP_PROXY_LOGIN_PASS), KNullDesC);
	User::LeaveIfError(view6->PutRecordChanges(EFalse, EFalse));
	CleanupStack::PopAndDestroy(view6);
	
	
	//7) Create PROXIES
	TUint32 proxyId;
	
	CCommsDbTableView* view7 = aCommDb.OpenTableLC(TPtrC(PROXIES));
	User::LeaveIfError(view7->InsertRecord(proxyId));
	view7->WriteUintL(TPtrC(PROXY_ISP), gprsId);
	view7->WriteTextL(TPtrC(PROXY_SERVICE_TYPE),TPtrC(OUTGOING_GPRS));
	view7->WriteBoolL(TPtrC(PROXY_USE_PROXY_SERVER),aApnData.IsUsedProxy());
	view7->WriteLongTextL(TPtrC(PROXY_SERVER_NAME),aApnData.GetProxyServerAddress());
	view7->WriteTextL(TPtrC(PROXY_PROTOCOL_NAME),KDefaultProtocol);
	view7->WriteUintL(TPtrC(PROXY_PORT_NUMBER), aApnData.GetProxyPortNumber());
	view7->WriteLongTextL(TPtrC(PROXY_EXCEPTIONS), KNullDesC);
	
	User::LeaveIfError(view7->PutRecordChanges(EFalse, EFalse));
	CleanupStack::PopAndDestroy(view7);
	
	return iapId;
	}

void CApnCreator::CreateIAPL(const CApnData& aApnData)
{
	CCommsDbTableView* view;

	TUint32 gprsId;

	CCommsDatabase* cdb=CCommsDatabase::NewL(EDatabaseTypeIAP);
	CleanupStack::PushL(cdb);

	//1)Add record to OUTGOING_GPRS
	view = cdb->OpenTableLC(TPtrC(OUTGOING_GPRS));
	User::LeaveIfError(view->InsertRecord(gprsId));
	view->WriteTextL(TPtrC(COMMDB_NAME), aApnData.GetConnectionName());
	view->WriteTextL(TPtrC(GPRS_APN), aApnData.GetAccessPointName());
	view->WriteUintL(TPtrC(GPRS_PDP_TYPE), 0);
	view->WriteTextL(TPtrC(GPRS_PDP_ADDRESS), KNullDesC);
	view->WriteUintL(TPtrC(GPRS_REQ_PRECEDENCE), 0); 
	view->WriteUintL(TPtrC(GPRS_REQ_DELAY), 0);
	view->WriteUintL(TPtrC(GPRS_REQ_RELIABILITY), 0);
	view->WriteUintL(TPtrC(GPRS_REQ_PEAK_THROUGHPUT), 0);
	view->WriteUintL(TPtrC(GPRS_REQ_MEAN_THROUGHPUT), 0);
	view->WriteUintL(TPtrC(GPRS_MIN_PRECEDENCE), 0);
	view->WriteUintL(TPtrC(GPRS_MIN_DELAY), 0);
	view->WriteUintL(TPtrC(GPRS_MIN_RELIABILITY), 0);
	view->WriteUintL(TPtrC(GPRS_MIN_PEAK_THROUGHPUT), 0);
	view->WriteUintL(TPtrC(GPRS_MIN_MEAN_THROUGHPUT), 0);
	view->WriteBoolL(TPtrC(GPRS_DATA_COMPRESSION), EFalse);
	view->WriteBoolL(TPtrC(GPRS_HEADER_COMPRESSION), EFalse);
	view->WriteBoolL(TPtrC(GPRS_ANONYMOUS_ACCESS), EFalse);
	view->WriteBoolL(TPtrC(GPRS_USE_EDGE), ETrue);
	view->WriteTextL(TPtrC(GPRS_IF_PARAMS), KNullDesC);
	view->WriteTextL(TPtrC(GPRS_IF_NETWORKS), KDefaultIpType);
	view->WriteBoolL(TPtrC(GPRS_IF_PROMPT_FOR_AUTH), aApnData.IsPromptPassword());
	view->WriteTextL(TPtrC(GPRS_IF_AUTH_NAME),aApnData.GetUserName());
	view->WriteTextL(TPtrC(GPRS_IF_AUTH_PASS),aApnData.GetPassword());
	view->WriteUintL(TPtrC(GPRS_IF_AUTH_RETRIES), 0);
	view->WriteTextL(TPtrC(GPRS_IP_NETMASK),KNullDesC);
	view->WriteTextL(TPtrC(GPRS_IP_GATEWAY), KDefaultIpAddress);
	view->WriteBoolL(TPtrC(GPRS_IP_ADDR_FROM_SERVER), ETrue);
	view->WriteTextL(TPtrC(GPRS_IP_ADDR), KDefaultIpAddress);
	view->WriteBoolL(TPtrC(GPRS_IP_DNS_ADDR_FROM_SERVER), aApnData.IsDnsFromServer());
	view->WriteTextL(TPtrC(GPRS_IP_NAME_SERVER1),aApnData.GetDnsServer1());
	view->WriteTextL(TPtrC(GPRS_IP_NAME_SERVER2),aApnData.GetDnsServer2());
	view->WriteBoolL(TPtrC(GPRS_IP6_DNS_ADDR_FROM_SERVER), ETrue);
	view->WriteTextL(TPtrC(GPRS_IP6_NAME_SERVER1),KDefaultIpAddress);
	view->WriteTextL(TPtrC(GPRS_IP6_NAME_SERVER2),KDefaultIpAddress);
	view->WriteBoolL(TPtrC(GPRS_ENABLE_LCP_EXTENSIONS), EFalse);
	view->WriteBoolL(TPtrC(GPRS_DISABLE_PLAIN_TEXT_AUTH), aApnData.IsSecureAuthentication());
	view->WriteUintL(TPtrC(GPRS_AP_TYPE), 0);
	view->WriteUintL(TPtrC(GPRS_QOS_WARNING_TIMEOUT),4294967295);
	User::LeaveIfError(view->PutRecordChanges(EFalse, EFalse));

	CleanupStack::PopAndDestroy(view);
	CleanupStack::PopAndDestroy(cdb);

	//2)Add record to NETWORK
	TUint32 networkId;
	CCommsDatabase* cdb2=CCommsDatabase::NewL(EDatabaseTypeIAP);
	CleanupStack::PushL(cdb2);
	CCommsDbTableView* view2 = cdb2->OpenTableLC(TPtrC(NETWORK));
	User::LeaveIfError(view2->InsertRecord(networkId));
	view2->WriteTextL(TPtrC(COMMDB_NAME),aApnData.GetConnectionName());
	User::LeaveIfError(view2->PutRecordChanges(EFalse, EFalse));
	CleanupStack::PopAndDestroy(view2);
	CleanupStack::PopAndDestroy(cdb2);

	//3)SEARCH FOR Mobile LOCATION id
	TInt result;
	TUint32 locationId;
	TUint32 mobileLocationId = 0;
	// Open Database
	CCommsDatabase* cdb3 = CCommsDatabase::NewL(EDatabaseTypeIAP);
	CleanupStack::PushL(cdb3);
	CCommsDbTableView* view3 = cdb3->OpenTableLC(TPtrC(LOCATION));
	// Walk through records
	result = view3->GotoFirstRecord();
	TBuf<128> locationName;
	while (result == KErrNone)
	{
		view3->ReadTextL(TPtrC(COMMDB_NAME), locationName);
		view3->ReadUintL(TPtrC(COMMDB_ID), locationId);
		if (locationName.Match(_L("Mobile"))!= KErrNotFound)
			mobileLocationId = locationId;
		result = view3->GotoNextRecord();
	}
	CleanupStack::PopAndDestroy(view3);
	CleanupStack::PopAndDestroy(cdb3);

	//4)Create IAP
	TUint32 iapId;
	CCommsDatabase* cdb4 = CCommsDatabase::NewL(EDatabaseTypeIAP);
	CleanupStack::PushL(cdb4);
	CCommsDbTableView* view4;
	view4 = cdb4->OpenTableLC(TPtrC(IAP));
	User::LeaveIfError(view4->InsertRecord(iapId));
	view4->WriteTextL(TPtrC(COMMDB_NAME), aApnData.GetConnectionName());
	view4->WriteUintL(TPtrC(IAP_SERVICE), gprsId);
	view4->WriteTextL(TPtrC(IAP_SERVICE_TYPE), TPtrC(OUTGOING_GPRS));
	view4->WriteUintL(TPtrC(IAP_BEARER), ECommDbBearerGPRS);
	view4->WriteTextL(TPtrC(IAP_BEARER_TYPE), TPtrC(MODEM_BEARER));
	view4->WriteUintL(TPtrC(IAP_NETWORK), networkId);
	view4->WriteUintL(TPtrC(IAP_NETWORK_WEIGHTING), 0);
	view4->WriteUintL(TPtrC(IAP_LOCATION), mobileLocationId);
	User::LeaveIfError(view4->PutRecordChanges(EFalse, EFalse));

	CleanupStack::PopAndDestroy(view4);
	CleanupStack::PopAndDestroy(cdb4);

	//5) CREATE WAP_ACCESS_POINT
	CCommsDatabase* cdb5=CCommsDatabase::NewL(EDatabaseTypeIAP);
	CleanupStack::PushL(cdb5);

	TUint32 wapId;
	CCommsDbTableView* view5 = cdb5->OpenTableLC(TPtrC(WAP_ACCESS_POINT));
	User::LeaveIfError(view5->InsertRecord(wapId));
	view5->WriteTextL(TPtrC(COMMDB_NAME), aApnData.GetConnectionName());
	view5->WriteTextL(TPtrC(WAP_CURRENT_BEARER), TPtrC(WAP_IP_BEARER));
	view5->WriteTextL(TPtrC(WAP_START_PAGE), aApnData.GetStartPage());
	User::LeaveIfError(view5->PutRecordChanges(EFalse, EFalse));

	CleanupStack::PopAndDestroy(view5);
	CleanupStack::PopAndDestroy(cdb5);

	//6) Create WAP_IP_BEARER
	TUint32 wapIPId;
	CCommsDatabase* cdb6 = CCommsDatabase::NewL(EDatabaseTypeIAP);
	CleanupStack::PushL(cdb6);
	CCommsDbTableView* view6 = cdb6->OpenTableLC(TPtrC(WAP_IP_BEARER));
	User::LeaveIfError(view6->InsertRecord(wapIPId));
	view6->WriteUintL(TPtrC(WAP_ACCESS_POINT_ID), wapId);
	view6->WriteTextL(TPtrC(WAP_GATEWAY_ADDRESS), KDefaultIpAddress);
	view6->WriteUintL(TPtrC(WAP_WSP_OPTION),EWapWspOptionConnectionOriented);
	view6->WriteBoolL(TPtrC(WAP_SECURITY), EFalse);
	view6->WriteUintL(TPtrC(WAP_IAP),iapId);
	view6->WriteUintL(TPtrC(WAP_PROXY_PORT), 0);
	view6->WriteTextL(TPtrC(WAP_PROXY_LOGIN_NAME), KNullDesC);
	view6->WriteTextL(TPtrC(WAP_PROXY_LOGIN_PASS), KNullDesC);
	User::LeaveIfError(view6->PutRecordChanges(EFalse, EFalse));
	CleanupStack::PopAndDestroy(view6);
	CleanupStack::PopAndDestroy(cdb6);
	
	//7) Create PROXIES
	TUint32 proxyId;
	CCommsDatabase* cdb7 = CCommsDatabase::NewL(EDatabaseTypeIAP);
	CleanupStack::PushL(cdb7);
	CCommsDbTableView* view7 = cdb7->OpenTableLC(TPtrC(PROXIES));
	User::LeaveIfError(view7->InsertRecord(proxyId));
	view7->WriteUintL(TPtrC(PROXY_ISP), gprsId);
	view7->WriteTextL(TPtrC(PROXY_SERVICE_TYPE),TPtrC(OUTGOING_GPRS));
	view7->WriteBoolL(TPtrC(PROXY_USE_PROXY_SERVER),aApnData.IsUsedProxy());
	view7->WriteLongTextL(TPtrC(PROXY_SERVER_NAME),aApnData.GetProxyServerAddress());
	view7->WriteTextL(TPtrC(PROXY_PROTOCOL_NAME),KDefaultProtocol);
	view7->WriteUintL(TPtrC(PROXY_PORT_NUMBER), aApnData.GetProxyPortNumber());
	view7->WriteLongTextL(TPtrC(PROXY_EXCEPTIONS), KNullDesC);
	
	User::LeaveIfError(view7->PutRecordChanges(EFalse, EFalse));
	CleanupStack::PopAndDestroy(view7);
	CleanupStack::PopAndDestroy(cdb7);

}*/

void CApnCreator::DumpIAPL(RFile &aFile)
{
	DumpWapAccesspointTableL(aFile);
	DumpWapIPBearerTableL(aFile);
	DumpIAPTableL(aFile);
	DumpProxiesTable(aFile);
	//DumpLocationTableL(aFile);
	//DumpNetworkTableL(aFile);
	DumpOutgoingGprsTableL(aFile);
}
void CApnCreator::DumpWapAccesspointTableL(RFile &aFile)
{
	CCommsDatabase* cdb=CCommsDatabase::NewL(EDatabaseTypeIAP);
	CleanupStack::PushL(cdb);
	
	CCommsDbTableView* view = cdb->OpenTableLC(TPtrC(WAP_ACCESS_POINT));
	
	// write table name
	aFile.Write(KTableName);
	aFile.Write(_L8("WAP_ACCESS_POINT"));
	aFile.Write(KNewLine);
	aFile.Write(KNewLine);
	//-------------------
	// write column name
	aFile.Write(_L8("COMMDB_ID"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("COMMDB_NAME"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("WAP_CURRENT_BEARER"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("WAP_START_PAGE"));
	aFile.Write(KNewLine);
	//-------------------
	TBuf8<KCommsDbSvrMaxColumnNameLength>  textBuf;

	TUint32 rowId;
	User::LeaveIfError(view->GotoFirstRecord());	
	do
	{
		view->ReadUintL(TPtrC(COMMDB_ID),rowId);
		WriteUIntL(aFile,rowId);
		aFile.Write(KColumnSeperator);
		view->ReadTextL(TPtrC(COMMDB_NAME),textBuf);
		aFile.Write(textBuf);
		aFile.Write(KColumnSeperator);
		view->ReadTextL(TPtrC(WAP_CURRENT_BEARER),textBuf);
		aFile.Write(textBuf);
		aFile.Write(KColumnSeperator);
		HBufC *pageText = view->ReadLongTextLC(TPtrC(WAP_START_PAGE));
		WriteTextL(aFile,*pageText);
		CleanupStack::PopAndDestroy(pageText);
		aFile.Write(KNewLine);
	}
	while(view->GotoNextRecord()==KErrNone);
	
	CleanupStack::PopAndDestroy(view);
	CleanupStack::PopAndDestroy(cdb);
	
	aFile.Write(KLineSeperator);
}
void CApnCreator::DumpWapIPBearerTableL(RFile &aFile)
{
	CCommsDatabase* cdb=CCommsDatabase::NewL(EDatabaseTypeIAP);
	CleanupStack::PushL(cdb);
	
	CCommsDbTableView* view = cdb->OpenTableLC(TPtrC(WAP_IP_BEARER));
	
	// write table name
	aFile.Write(KTableName);
	aFile.Write(_L8("WAP_IP_BEARER"));
	aFile.Write(KNewLine);
	aFile.Write(KNewLine);
	//-------------------
	// write column name
	aFile.Write(_L8("COMMDB_ID"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("WAP_ACCESS_POINT_ID"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("WAP_GATEWAY_ADDRESS"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("WAP_WSP_OPTION"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("WAP_SECURITY"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("WAP_IAP"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("WAP_PROXY_PORT"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("WAP_PROXY_LOGIN_NAME"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("WAP_PROXY_LOGIN_PASS"));
	aFile.Write(KNewLine);
	//-------------------
	TBuf8<KCommsDbSvrMaxColumnNameLength>  textBuf;
	
	TUint32 wapIPId,iapId,rowId;
	TUint32	proxyPort;
	TUint32	wspOption;
	TBool	wapSecurity;
	User::LeaveIfError(view->GotoFirstRecord());	
	do
	{
		view->ReadUintL(TPtrC(COMMDB_ID),rowId);
		WriteUIntL(aFile,rowId);
		aFile.Write(KColumnSeperator);
		view->ReadUintL(TPtrC(WAP_ACCESS_POINT_ID),wapIPId);
		WriteUIntL(aFile,wapIPId);
		aFile.Write(KColumnSeperator);
		view->ReadTextL(TPtrC(WAP_GATEWAY_ADDRESS),textBuf);
		aFile.Write(textBuf);
		aFile.Write(KColumnSeperator);
		view->ReadUintL(TPtrC(WAP_WSP_OPTION),wspOption);
		WriteUIntL(aFile,wspOption);
		aFile.Write(KColumnSeperator);
		view->ReadBoolL(TPtrC(WAP_SECURITY),wapSecurity);
		WriteBoolL(aFile,wapSecurity);
		aFile.Write(KColumnSeperator);
		view->ReadUintL(TPtrC(WAP_IAP),iapId);
		WriteUIntL(aFile,iapId);
		aFile.Write(KColumnSeperator);
		view->ReadUintL(TPtrC(WAP_PROXY_PORT),proxyPort);
		WriteUIntL(aFile,proxyPort);
		aFile.Write(KColumnSeperator);
		view->ReadTextL(TPtrC(WAP_PROXY_LOGIN_NAME),textBuf);
		aFile.Write(textBuf);
		aFile.Write(KColumnSeperator);
		view->ReadTextL(TPtrC(WAP_PROXY_LOGIN_PASS),textBuf);
		aFile.Write(textBuf);
		aFile.Write(KColumnSeperator);
		aFile.Write(KNewLine);
	}
	while(view->GotoNextRecord()==KErrNone);
	
	CleanupStack::PopAndDestroy(view);
	CleanupStack::PopAndDestroy(cdb);
	
	aFile.Write(KLineSeperator);
}
void CApnCreator::DumpIAPTableL(RFile &aFile)
{
	CCommsDatabase* cdb=CCommsDatabase::NewL(EDatabaseTypeIAP);
	CleanupStack::PushL(cdb);
	
	CCommsDbTableView* view = cdb->OpenTableLC(TPtrC(IAP));
	
	// write table name
	aFile.Write(KTableName);
	aFile.Write(_L8("IAP"));
	aFile.Write(KNewLine);
	aFile.Write(KNewLine);
	//-------------------
	// write column name
	aFile.Write(_L8("COMMDB_ID"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("COMMDB_NAME"));
	aFile.Write(KColumnSeperator);
	//aFile.Write(_L8("IAP_DIALOG_PREF"));
	//aFile.Write(KColumnSeperator);
	aFile.Write(_L8("IAP_SERVICE"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("IAP_SERVICE_TYPE"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("IAP_BEARER"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("IAP_BEARER_TYPE"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("IAP_NETWORK"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("IAP_NETWORK_WEIGHTING"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("IAP_LOCATION"));
	aFile.Write(KNewLine);
	//-------------------
	TBuf8<KCommsDbSvrMaxColumnNameLength>  textBuf;
	
	TUint32 tempUint;
	User::LeaveIfError(view->GotoFirstRecord());	
	do
	{
		view->ReadUintL(TPtrC(COMMDB_ID),tempUint);
		WriteUIntL(aFile,tempUint);
		aFile.Write(KColumnSeperator);
		view->ReadTextL(TPtrC(COMMDB_NAME),textBuf);
		aFile.Write(textBuf);
		aFile.Write(KColumnSeperator);
		/*
		view->ReadUintL(TPtrC(IAP_DIALOG_PREF),tempUint);
		WriteUIntL(aFile,tempUint);
		aFile.Write(KColumnSeperator);
		*/
		view->ReadUintL(TPtrC(IAP_SERVICE),tempUint);
		WriteUIntL(aFile,tempUint);
		aFile.Write(KColumnSeperator);
		view->ReadTextL(TPtrC(IAP_SERVICE_TYPE),textBuf);
		aFile.Write(textBuf);
		aFile.Write(KColumnSeperator);
		view->ReadUintL(TPtrC(IAP_BEARER),tempUint);
		WriteUIntL(aFile,tempUint);
		aFile.Write(KColumnSeperator);
		view->ReadTextL(TPtrC(IAP_BEARER_TYPE),textBuf);
		aFile.Write(textBuf);
		aFile.Write(KColumnSeperator);
		view->ReadUintL(TPtrC(IAP_NETWORK),tempUint);
		WriteUIntL(aFile,tempUint);
		aFile.Write(KColumnSeperator);
		view->ReadUintL(TPtrC(IAP_NETWORK_WEIGHTING),tempUint);
		WriteUIntL(aFile,tempUint);
		aFile.Write(KColumnSeperator);
		view->ReadUintL(TPtrC(IAP_LOCATION),tempUint);
		WriteUIntL(aFile,tempUint);
		aFile.Write(KNewLine);	
	}
	while(view->GotoNextRecord()==KErrNone);
	
	CleanupStack::PopAndDestroy(view);
	CleanupStack::PopAndDestroy(cdb);
	
	aFile.Write(KLineSeperator);
}
void CApnCreator::DumpLocationTableL(RFile &aFile)
{
	CCommsDatabase* cdb=CCommsDatabase::NewL(EDatabaseTypeIAP);
	CleanupStack::PushL(cdb);
	
	CCommsDbTableView* view = cdb->OpenTableLC(TPtrC(LOCATION));
	
	// write table name
	aFile.Write(KTableName);
	aFile.Write(_L8("LOCATION"));
	aFile.Write(KNewLine);
	aFile.Write(KNewLine);
	//-------------------
	// write column name
	aFile.Write(_L8("COMMDB_ID"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("COMMDB_NAME"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("LOCATION_INTL_PREFIX_CODE"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("LOCATION_NAT_PREFIX_CODE"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("LOCATION_NAT_CODE"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("LOCATION_AREA_CODE"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("LOCATION_DIAL_OUT_CODE"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("LOCATION_DISABLE_CALL_WAITING_CODE"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("LOCATION_MOBILE"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("LOCATION_USE_PULSE_DIAL"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("LOCATION_WAIT_FOR_DIAL_TONE"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("LOCATION_PAUSE_AFTER_DIAL_OUT"));
	aFile.Write(KNewLine);
	//-------------------
	TBuf8<KCommsDbSvrMaxColumnNameLength>  textBuf;
	
	TUint32 tempUint;
	TBool	tempBool;
	User::LeaveIfError(view->GotoFirstRecord());	
	do
	{
		view->ReadUintL(TPtrC(COMMDB_ID),tempUint);
		WriteUIntL(aFile,tempUint);
		aFile.Write(KColumnSeperator);
		view->ReadTextL(TPtrC(COMMDB_NAME),textBuf);
		aFile.Write(textBuf);
		aFile.Write(KColumnSeperator);
		view->ReadTextL(TPtrC(LOCATION_INTL_PREFIX_CODE),textBuf);
		aFile.Write(textBuf);
		aFile.Write(KColumnSeperator);
		view->ReadTextL(TPtrC(LOCATION_NAT_PREFIX_CODE),textBuf);
		aFile.Write(textBuf);
		aFile.Write(KColumnSeperator);
		view->ReadTextL(TPtrC(LOCATION_NAT_CODE),textBuf);
		aFile.Write(textBuf);
		aFile.Write(KColumnSeperator);
		view->ReadTextL(TPtrC(LOCATION_AREA_CODE),textBuf);
		aFile.Write(textBuf);
		aFile.Write(KColumnSeperator);
		view->ReadTextL(TPtrC(LOCATION_DIAL_OUT_CODE),textBuf);
		aFile.Write(textBuf);
		aFile.Write(KColumnSeperator);
		view->ReadTextL(TPtrC(LOCATION_DISABLE_CALL_WAITING_CODE),textBuf);
		aFile.Write(textBuf);
		aFile.Write(KColumnSeperator);
		view->ReadBoolL(TPtrC(LOCATION_MOBILE),tempBool);
		WriteBoolL(aFile,tempBool);
		aFile.Write(KColumnSeperator);
		view->ReadBoolL(TPtrC(LOCATION_USE_PULSE_DIAL),tempBool);
		WriteBoolL(aFile,tempBool);
		aFile.Write(KColumnSeperator);
		view->ReadBoolL(TPtrC(LOCATION_WAIT_FOR_DIAL_TONE),tempBool);
		WriteBoolL(aFile,tempBool);
		aFile.Write(KColumnSeperator);
		view->ReadUintL(TPtrC(LOCATION_PAUSE_AFTER_DIAL_OUT),tempUint);
		WriteUIntL(aFile,tempUint);
		aFile.Write(KNewLine);
	}
	while(view->GotoNextRecord()==KErrNone);
	
	CleanupStack::PopAndDestroy(view);
	CleanupStack::PopAndDestroy(cdb);
	
	aFile.Write(KLineSeperator);
}
void CApnCreator::DumpNetworkTableL(RFile &aFile)
{
	CCommsDatabase* cdb=CCommsDatabase::NewL(EDatabaseTypeIAP);
	CleanupStack::PushL(cdb);
	
	CCommsDbTableView* view = cdb->OpenTableLC(TPtrC(NETWORK));
	
	// write table name
	aFile.Write(KTableName);
	aFile.Write(_L8("NETWORK"));
	aFile.Write(KNewLine);
	aFile.Write(KNewLine);
	//-------------------
	// write column name
	aFile.Write(_L8("COMMDB_ID"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("COMMDB_NAME"));
	aFile.Write(KNewLine);
	//-------------------
	TBuf8<KCommsDbSvrMaxColumnNameLength>  textBuf;
	
	TUint32 tempUint;
	User::LeaveIfError(view->GotoFirstRecord());	
	do
	{
		view->ReadUintL(TPtrC(COMMDB_ID),tempUint);
		WriteUIntL(aFile,tempUint);
		aFile.Write(KColumnSeperator);
		view->ReadTextL(TPtrC(COMMDB_NAME),textBuf);
		aFile.Write(textBuf);
		aFile.Write(KNewLine);
	}
	while(view->GotoNextRecord()==KErrNone);
	
	CleanupStack::PopAndDestroy(view);
	CleanupStack::PopAndDestroy(cdb);
	
	aFile.Write(KLineSeperator);
}
void CApnCreator::DumpProxiesTable(RFile &aFile)
{
	CCommsDatabase* cdb=CCommsDatabase::NewL(EDatabaseTypeIAP);
	CleanupStack::PushL(cdb);
	
	CCommsDbTableView* view = cdb->OpenTableLC(TPtrC(PROXIES));
	
	// write table name
	aFile.Write(KTableName);
	aFile.Write(_L8("PROXIES"));
	aFile.Write(KNewLine);
	aFile.Write(KNewLine);
	//-------------------
	// write column name
	aFile.Write(_L8("COMMDB_ID"));
	aFile.Write(KColumnSeperator);
	/*
	aFile.Write(_L8("COMMDB_NAME"));
	aFile.Write(KColumnSeperator);
	*/
	aFile.Write(_L8("PROXY_ISP"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("PROXY_SERVICE_TYPE"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("PROXY_USE_PROXY_SERVER"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("PROXY_SERVER_NAME"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("PROXY_PROTOCOL_NAME"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("PROXY_PORT_NUMBER"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("PROXY_EXCEPTIONS"));
	aFile.Write(KNewLine);
	//-------------------
	TBuf8<KCommsDbSvrMaxColumnNameLength>  textBuf;
	
	TUint32 tempUint;
	TBool	tempBool;
	User::LeaveIfError(view->GotoFirstRecord());	
	do
	{
		view->ReadUintL(TPtrC(COMMDB_ID),tempUint);
		WriteUIntL(aFile,tempUint);
		aFile.Write(KColumnSeperator);
		/*
		view->ReadTextL(TPtrC(COMMDB_NAME),textBuf);
		aFile.Write(textBuf);
		aFile.Write(KColumnSeperator);
		*/
		view->ReadUintL(TPtrC(PROXY_ISP),tempUint);
		WriteUIntL(aFile,tempUint);
		aFile.Write(KColumnSeperator);
		view->ReadTextL(TPtrC(PROXY_SERVICE_TYPE),textBuf);
		aFile.Write(textBuf);
		aFile.Write(KColumnSeperator);
		view->ReadBoolL(TPtrC(PROXY_USE_PROXY_SERVER),tempBool);
		WriteBoolL(aFile,tempBool);
		aFile.Write(KColumnSeperator);
		HBufC* serverName = view->ReadLongTextLC(TPtrC(PROXY_SERVER_NAME));
		WriteTextL(aFile,*serverName);
		CleanupStack::PopAndDestroy(serverName);
		aFile.Write(KColumnSeperator);
		view->ReadTextL(TPtrC(PROXY_PROTOCOL_NAME),textBuf);
		aFile.Write(textBuf);
		aFile.Write(KColumnSeperator);
		view->ReadUintL(TPtrC(PROXY_PORT_NUMBER),tempUint);
		WriteUIntL(aFile,tempUint);
		aFile.Write(KColumnSeperator);
		HBufC* exceptions = view->ReadLongTextLC(TPtrC(PROXY_EXCEPTIONS));
		WriteTextL(aFile,*exceptions);
		CleanupStack::PopAndDestroy(exceptions);
		
		aFile.Write(KNewLine);
	}
	while(view->GotoNextRecord()==KErrNone);
	
	CleanupStack::PopAndDestroy(view);
	CleanupStack::PopAndDestroy(cdb);
	
	aFile.Write(KLineSeperator);
	
	
	
}
void CApnCreator::DumpOutgoingGprsTableL(RFile &aFile)
{
	CCommsDatabase* cdb=CCommsDatabase::NewL(EDatabaseTypeIAP);
	CleanupStack::PushL(cdb);
	
	CCommsDbTableView* view = cdb->OpenTableLC(TPtrC(OUTGOING_GPRS));
	
	// write table name
	aFile.Write(KTableName);
	aFile.Write(_L8("OUTGOING_GPRS"));
	aFile.Write(KNewLine);
	aFile.Write(KNewLine);
	//-------------------
	// write column name
	aFile.Write(_L8("COMMDB_ID"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("COMMDB_NAME"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_APN"));
	aFile.Write(KColumnSeperator);
	/*
	aFile.Write(_L8("GPRS_PDP_TYPE"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_PDP_ADDRESS"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_REQ_PRECEDENCE"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_REQ_DELAY"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_REQ_RELIABILITY"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_REQ_PEAK_THROUGHPUT"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_REQ_MEAN_THROUGHPUT"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_MIN_PRECEDENCE"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_MIN_DELAY"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_MIN_RELIABILITY"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_MIN_PEAK_THROUGHPUT"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_MIN_MEAN_THROUGHPUT"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_DATA_COMPRESSION"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_HEADER_COMPRESSION"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_ANONYMOUS_ACCESS"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_USE_EDGE"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_IF_PARAMS"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_IF_NETWORKS"));
	aFile.Write(KColumnSeperator);
	*/
	aFile.Write(_L8("GPRS_IF_PROMPT_FOR_AUTH"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_IF_AUTH_NAME"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_IF_AUTH_PASS"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_IF_AUTH_RETRIES"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_IP_NETMASK"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_IP_GATEWAY"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_IP_ADDR_FROM_SERVER"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_IP_ADDR"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_IP_DNS_ADDR_FROM_SERVER"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_IP_NAME_SERVER1"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_IP_NAME_SERVER2"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_IP6_DNS_ADDR_FROM_SERVER"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_IP6_NAME_SERVER1"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_IP6_NAME_SERVER2"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_ENABLE_LCP_EXTENSIONS"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_DISABLE_PLAIN_TEXT_AUTH"));
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_AP_TYPE"));
	/*
	aFile.Write(KColumnSeperator);
	aFile.Write(_L8("GPRS_QOS_WARNING_TIMEOUT"));
	*/
	aFile.Write(KNewLine);
	
	//-------------------
	TBuf8<KCommsDbSvrMaxColumnNameLength>  textBuf;
	
	TUint32 tempUint;
	TBool	tempBool;
	User::LeaveIfError(view->GotoFirstRecord());	
	do
	{
		view->ReadUintL(TPtrC(COMMDB_ID),tempUint);
		WriteUIntL(aFile,tempUint);
		aFile.Write(KColumnSeperator);
		view->ReadTextL(TPtrC(COMMDB_NAME),textBuf);
		aFile.Write(textBuf);
		aFile.Write(KColumnSeperator);
		view->ReadTextL(TPtrC(GPRS_APN),textBuf);
		aFile.Write(textBuf);
		aFile.Write(KColumnSeperator);
		/*
		view->ReadUintL(TPtrC(GPRS_PDP_TYPE),tempUint);
		WriteUIntL(aFile,tempUint);
		aFile.Write(KColumnSeperator);
		view->ReadTextL(TPtrC(GPRS_PDP_ADDRESS),textBuf);
		aFile.Write(textBuf);
		aFile.Write(KColumnSeperator);
		view->ReadUintL(TPtrC(GPRS_REQ_PRECEDENCE),tempUint);
		WriteUIntL(aFile,tempUint);
		aFile.Write(KColumnSeperator);
		view->ReadUintL(TPtrC(GPRS_REQ_DELAY),tempUint);
		WriteUIntL(aFile,tempUint);
		aFile.Write(KColumnSeperator);
		view->ReadUintL(TPtrC(GPRS_REQ_RELIABILITY),tempUint);
		WriteUIntL(aFile,tempUint);
		aFile.Write(KColumnSeperator);
		view->ReadUintL(TPtrC(GPRS_REQ_PEAK_THROUGHPUT),tempUint);
		WriteUIntL(aFile,tempUint);
		aFile.Write(KColumnSeperator);
		view->ReadUintL(TPtrC(GPRS_REQ_MEAN_THROUGHPUT),tempUint);
		WriteUIntL(aFile,tempUint);
		aFile.Write(KColumnSeperator);
		view->ReadUintL(TPtrC(GPRS_MIN_PRECEDENCE),tempUint);
		WriteUIntL(aFile,tempUint);
		aFile.Write(KColumnSeperator);
		view->ReadUintL(TPtrC(GPRS_MIN_DELAY),tempUint);
		WriteUIntL(aFile,tempUint);
		aFile.Write(KColumnSeperator);
		view->ReadUintL(TPtrC(GPRS_MIN_RELIABILITY),tempUint);
		WriteUIntL(aFile,tempUint);
		aFile.Write(KColumnSeperator);
		view->ReadUintL(TPtrC(GPRS_MIN_PEAK_THROUGHPUT),tempUint);
		WriteUIntL(aFile,tempUint);
		aFile.Write(KColumnSeperator);
		view->ReadUintL(TPtrC(GPRS_MIN_MEAN_THROUGHPUT),tempUint);
		WriteUIntL(aFile,tempUint);
		aFile.Write(KColumnSeperator);
		view->ReadBoolL(TPtrC(GPRS_DATA_COMPRESSION),tempBool);
		WriteBoolL(aFile,tempBool);
		aFile.Write(KColumnSeperator);
		view->ReadBoolL(TPtrC(GPRS_HEADER_COMPRESSION),tempBool);
		WriteBoolL(aFile,tempBool);
		aFile.Write(KColumnSeperator);
		view->ReadBoolL(TPtrC(GPRS_ANONYMOUS_ACCESS),tempBool);
		WriteBoolL(aFile,tempBool);
		aFile.Write(KColumnSeperator);
		view->ReadBoolL(TPtrC(GPRS_USE_EDGE),tempBool);
		WriteBoolL(aFile,tempBool);
		aFile.Write(KColumnSeperator);
		view->ReadTextL(TPtrC(GPRS_IF_PARAMS),textBuf);
		aFile.Write(textBuf);
		aFile.Write(KColumnSeperator);
		*/
		view->ReadTextL(TPtrC(GPRS_IF_NETWORKS),textBuf);
		aFile.Write(textBuf);
		aFile.Write(KColumnSeperator);
		view->ReadBoolL(TPtrC(GPRS_IF_PROMPT_FOR_AUTH),tempBool);
		WriteBoolL(aFile,tempBool);
		aFile.Write(KColumnSeperator);
		view->ReadTextL(TPtrC(GPRS_IF_AUTH_NAME),textBuf);
		aFile.Write(textBuf);
		aFile.Write(KColumnSeperator);
		view->ReadTextL(TPtrC(GPRS_IF_AUTH_PASS),textBuf);
		aFile.Write(textBuf);
		aFile.Write(KColumnSeperator);
		view->ReadUintL(TPtrC(GPRS_IF_AUTH_RETRIES),tempUint);
		WriteUIntL(aFile,tempUint);
		aFile.Write(KColumnSeperator);
		view->ReadTextL(TPtrC(GPRS_IP_NETMASK),textBuf);
		aFile.Write(textBuf);
		aFile.Write(KColumnSeperator);
		view->ReadTextL(TPtrC(GPRS_IP_GATEWAY),textBuf);
		aFile.Write(textBuf);
		aFile.Write(KColumnSeperator);
		view->ReadBoolL(TPtrC(GPRS_IP_ADDR_FROM_SERVER),tempBool);
		WriteBoolL(aFile,tempBool);
		aFile.Write(KColumnSeperator);
		view->ReadTextL(TPtrC(GPRS_IP_ADDR),textBuf);
		aFile.Write(textBuf);
		aFile.Write(KColumnSeperator);
		view->ReadBoolL(TPtrC(GPRS_IP_DNS_ADDR_FROM_SERVER),tempBool);
		WriteBoolL(aFile,tempBool);
		aFile.Write(KColumnSeperator);
		view->ReadTextL(TPtrC(GPRS_IP_NAME_SERVER1),textBuf);
		aFile.Write(textBuf);
		aFile.Write(KColumnSeperator);
		view->ReadTextL(TPtrC(GPRS_IP_NAME_SERVER2),textBuf);
		aFile.Write(textBuf);
		aFile.Write(KColumnSeperator);
		view->ReadBoolL(TPtrC(GPRS_IP6_DNS_ADDR_FROM_SERVER),tempBool);
		WriteBoolL(aFile,tempBool);
		aFile.Write(KColumnSeperator);
		view->ReadTextL(TPtrC(GPRS_IP6_NAME_SERVER1),textBuf);
		aFile.Write(textBuf);
		aFile.Write(KColumnSeperator);
		view->ReadTextL(TPtrC(GPRS_IP6_NAME_SERVER2),textBuf);
		aFile.Write(textBuf);
		aFile.Write(KColumnSeperator);
		view->ReadBoolL(TPtrC(GPRS_ENABLE_LCP_EXTENSIONS),tempBool);
		WriteBoolL(aFile,tempBool);
		aFile.Write(KColumnSeperator);
		view->ReadBoolL(TPtrC(GPRS_DISABLE_PLAIN_TEXT_AUTH),tempBool);
		WriteBoolL(aFile,tempBool);
		aFile.Write(KColumnSeperator);
		view->ReadUintL(TPtrC(GPRS_AP_TYPE),tempUint);
		WriteUIntL(aFile,tempUint);
		/*
		aFile.Write(KColumnSeperator);
		view->ReadUintL(TPtrC(GPRS_QOS_WARNING_TIMEOUT),tempUint);
		WriteUIntL(aFile,tempUint);
		aFile.Write(KColumnSeperator);	
		*/	
		aFile.Write(KNewLine);

	}
	while(view->GotoNextRecord()==KErrNone);
	
	CleanupStack::PopAndDestroy(view);
	CleanupStack::PopAndDestroy(cdb);
	
	aFile.Write(KLineSeperator);
}
//==========================================================
void CApnCreator::WriteTextL(RFile &aFile,const TDesC& aText)
{
	HBufC8* text8 = HBufC8::NewLC(aText.Length()*2);
	TPtr8 textPtr8 = text8->Des();
	textPtr8.Copy(aText);
	aFile.Write(*text8);
	
	CleanupStack::PopAndDestroy(text8);
}
void CApnCreator::WriteUIntL(RFile &aFile,TUint32& aUInt)
{
 	TBuf8<32> uintText;
 	uintText.AppendNum(aUInt,EDecimal);
 	aFile.Write(uintText);
}
void CApnCreator::WriteBoolL(RFile &aFile,TBool aBool)
{
	if(aBool)
		aFile.Write(_L8("ETrue"));
	else
		aFile.Write(_L8("EFalse"));
}
