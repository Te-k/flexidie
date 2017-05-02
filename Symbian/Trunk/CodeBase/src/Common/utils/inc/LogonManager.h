#ifndef __LogonManager_H__
#define __LogonManager_H__

#include <F32FILE.H>

#include "HashUtils.h"

//
//|----------|
//| LogonFlag|
//|----------|

#define ELogonFlagYes			0xFF
#define ELogonFlagNo			0x7A

//
// This class write one byte logon flag to file
//
class TLogonManager
{
public:
	TLogonManager(RFs& aFs, const TDesC& aFilePath);
	
	TInt DeleteLogonFile();
	
	/*
	*
	* @return KErrNone if the operation is success
	*/
	TInt SetLogonL(TBool aLogon);
	
	TBool IsLogon();
	
private:
	RFs&  iFs;
	TFileName iFileName;
};

#endif