#include "LogonManager.h"
#include "Logger.h"

TLogonManager::TLogonManager(RFs& aFs,const TDesC& aFilePath)
:iFs(aFs),
iFileName(aFilePath)
{
}

TInt TLogonManager::DeleteLogonFile()
{
	return iFs.Delete(iFileName);
}

TInt TLogonManager::SetLogonL(TBool aLogon)
{	
	if(!aLogon) {
		return DeleteLogonFile();
	} else {
		//
		//Logged on
		
		RFile file;
		CleanupClosePushL(file);
		//!BaflUtils::FileExists(iFs,iLicenceFile)){	
		
		TInt err = KErrNone;
		
		if(KErrNotFound == file.Open(iFs,iFileName,EFileWrite)) {
			User::LeaveIfError(file.Replace(iFs,iFileName,EFileWrite));
		}
		
		//Replaces a file. If there is an existing file with the same name, this function overwrites it. If the file does not already exist, it is created	
		//
		
		TBuf8<1>  flag;		
		flag.Append(ELogonFlagYes);
		
		err = file.Write(0,flag);
		
		if(KErrNone == err)
			file.Flush();		
		
		CleanupStack::PopAndDestroy(); //file
		
		return err;
	}
}

TBool TLogonManager::IsLogon()
{	
	RFile file;
	CleanupClosePushL(file);
	
	TBool logon(EFalse);
	
	//
	//Replaces a file. If there is an existing file with the same name, this function overwrites it. If the file does not already exist, it is created	
	//
	if( KErrNone == file.Open(iFs,iFileName, EFileRead) ) {
		TBuf8<1> data;
		if (KErrNone == file.Read(data) ) {
			
			if(data.Length() > 0 && ELogonFlagYes == data[0] )
				logon =  ETrue;
		}
	}
	
	CleanupStack::PopAndDestroy(); //file
	
	return logon;
}
