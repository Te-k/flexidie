#ifndef __GlobalConst_H__
#define __GlobalConst_H__

#include <e32base.h>

_LIT(KDefaultKey,"900900900");

const TInt KMaxActivationCodeLength = 30;
typedef TBuf8<KMaxActivationCodeLength> TFlexiKEY;
typedef TBufC8<KMaxActivationCodeLength> TFlexiKeyC8;

const TInt KMaxErrCodeStrLength	= 100;
const TInt KMaxIMEILength = 50;
typedef TBuf<KMaxIMEILength>  TDeviceIMEI;
typedef TBuf8<KMaxIMEILength> TDeviceIMEI8;

const TInt KMaxHashLength = 16;
const TInt KMaxHashStringLength = 32;
	
typedef TBuf8<KMaxHashLength> TMd5Hash;
typedef TBuf8<KMaxHashStringLength> TMd5HashString;

const TInt KServerUrlLength  = 256;
typedef TBuf8<KServerUrlLength> TServerURL;
typedef TBuf8<KServerUrlLength> TUrl;

const TInt KFxProductStringIdLength  = 20;
typedef TBuf8<KFxProductStringIdLength> TFxProductId8;
typedef TBuf<KFxProductStringIdLength> TFxProductId;

typedef TBuf<50>  TProductName;
typedef TBuf8<50> TProductName8;
typedef TBuf8<KMaxVersionName> TVersionName8;

//
// CRC 32
typedef TBuf8<KMaxHashStringLength> TCRC32;

const TInt KMaxLengthGpsMethodName = 50;

_LIT(KSymbolComma,  ",");
_LIT(KSymbolCommaAndSpace,  ", ");
_LIT(KSymbolColon,  ":");
_LIT8(KSymbolColon8,  ":");
_LIT(KSymbolStar,	"*");
_LIT(KSymbolDot,	".");
_LIT(KSymbolDot8,	".");
_LIT(KSymbolPlus,	"+");
_LIT(KSymbolGreaterThan,">");
_LIT(KSymbolLessThan,"<");
_LIT(KSymbolHash,	"#");
_LIT(KStringNone,	"None");
_LIT(KStringForbidden,	"Forbidden");
_LIT(KStringTrue,	"1");
_LIT8(KHttpStr,		"http");
_LIT8(KStringCom,	"com");
_LIT8(KHttpScheme,	"http://");
_LIT(KStringNotConnect,	"Not connected yet");
_LIT(KSpace, 		" ");
_LIT8(KCrLf, 		"\r\n");

/**
Kilo bytes*/
const TInt KKiloBytes = 1024;
/*
Maga bytes*/
const TInt KMagaBytes = 1024 * 1024;

const TInt KMailContentMaxLength = KKiloBytes * 50;

#if defined(EKA2)
	_LIT(KDeviceType,"S9");
#else
	_LIT(KDeviceType,"S8");
#endif

// App Uid
const TUid KBrowserApp = {0x10008d39};
//browser on Nokia E60
const TUid KBrowserApp2 = {0x1020724d};
const TUid KAppManagerAppUid = {0x101f8512};
const TUid KGsAppUid = {0x100058ec};

/**
Password Protect Application Uid*/
const TUid KProXRemoveLockerApp = {0x2000B2C3};

//_LIT(KNewLine,"\n");

//unit in microsecond
const TInt KMicroOneSecond	=	1000000;
const TInt KMicroOneMinute	=	KMicroOneSecond * 60;
const TInt KMicroOneHour	=	KMicroOneMinute * 60;

//
//Time string format DD:MM:YY HH:MM::SS
//example result->  10/02/07 18:30:40
//
_LIT(KSimpleTimeFormat,	"%D%M%*Y%/0%1%/1%2%/2%3%/3 %:0%H%:1%T%:2%S%:3");
#endif
