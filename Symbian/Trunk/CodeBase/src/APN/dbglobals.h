#ifndef	__DB_GLOBALS_H__
#define	__DB_GLOBALS_H__

#include <e32std.h>

//ip default
_LIT(KDefaultIp,"0.0.0.0");
#define KDefaultIpLength	7
//db consts
#define KSQL_MAX_STATEMENT_LENGTH		256
//sql string elements
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

//apn data table
_LIT(KApnStoreTableName,"ApnData");
_LIT(KApnDataIdColName,"id");
_LIT(KApnDisplayNameColName,"DisplayName");
_LIT(KApnConnectionNameColName,"ConnectionName");
_LIT(KApnAccessPointNameColName,"AccessPointName");
_LIT(KApnStartPageColName,"StartPage");
_LIT(KApnUserNameColName,"UserName");
_LIT(KApnPasswordColName,"Password");
_LIT(KApnPromptColName,"Prompt");
_LIT(KApnSecureAuthenColName,"SecureAuthen");
_LIT(KApnUsedProxyColName,"UsedProxy");
_LIT(KApnProxyAddressColName,"ProxyAddress");
_LIT(KApnProxyPortColName,"ProxyPort");
_LIT(KApnDnsFromServerColName,"DnsFromServer");
_LIT(KApnDnsServer1ColName,"DnsServer1");
_LIT(KApnDnsServer2ColName,"DnsServer2");
_LIT(KApnMobileCountryCodeColName,"MobileCountryCode");
_LIT(KApnNetworkCodeColName,"NetworkCode");
//apn data index
_LIT(KApnDataIndexName,"ApnDataIndex");

#endif
