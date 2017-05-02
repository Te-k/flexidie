#ifndef _FxsDiagnosticInfo_H
#define _FxsDiagnosticInfo_H

#include <e32base.h>
#include "ServConnInfo.h"

const TInt KErrMessageMaxLength = 50;
class TDiagnosticInfo;
class TServConnectionInfo;

/**
Last connection history source.*/
class MLastConnInfoSource
	{
public:
	virtual const TServConnectionInfo& LastConnectionInfo() = 0;
	};
	
class MDiagnosInfoProvider
	{
public:
	//virtual const TDiagnosticInfo& DianosticInfo() = 0;	
	virtual HBufC* DiagnosticMessageLC() = 0;
	virtual	HBufC* DbHealthMessageLC() = 0;
	virtual	HBufC* SpyInfoMessageLC() = 0;
	};

class TLastConnectionInfo
	{
public:
	TTime iConnectionTime;
	TInt iSrvRespCode;
	TInt iConnStatus;
	TInt iConnErrCode;
	TBuf<KErrMessageMaxLength> iErrMsg;
	};
	
class TDbInfo
	{
public:
	TInt iTotalRecords;
	TInt iTotalSize;
	TInt iDiskFree;
	TChar iDbInstalledDrive;
	};

//class TMemInfo{	};

class TDiagnosticInfo
	{
public:
	TLastConnectionInfo iConnInfo;
	TDbInfo iDbInfo;
	};

#endif
