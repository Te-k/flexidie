#include "filelogger.h"
 
#include <bautils.H>
#include <pathinfo.h>
 
_LIT(KLogFolder, "logs\\");
_LIT(KLogFileExt, ".txt");
//_LIT(KOldFileExt, ".old");

const TUint8 KColon = ':';
const TUint8 KBackSlash = '\\';
_LIT8(KLineEnd, "\r\n");

const TInt KTimeRecordSize = 20;
 
_LIT8(KTimeFormat,"%04d-%02d-%02d %02d:%02d:%02d ");
_LIT8(KLogStart, "--== New %S log ==--\r\n");
 
_LIT(KSquareBracket, "[");
 
const TInt KMyTlsHandle = 0xC0FFEE;

const TInt KMaxLengthOfFileName = 15;
const TInt KMaxLengthOfFolder = 15;

CFileLogger::CFileLogger()
	{

	}
 
TBool CFileLogger::Construct()
	{
	TInt err = iFs.Connect();
	if (!err)
		{
		TFileName logFileName;
		err = !GetLogFileNameWithoutExt(logFileName);
		if(!err)
			{
			logFileName.Append(KLogFileExt);
			err = iFile.Open(iFs, logFileName, EFileShareAny | EFileWrite);
			if (err == KErrNotFound) //File dose not exist - create it
				{
				err = iFile.Create(iFs, logFileName, EFileShareAny | EFileWrite);
				}
			
			if(!err)
				{
				TInt pos(0);
				iFile.Seek(ESeekEnd, pos);
				TBuf8<KMaxFullName> appName;
				appName.Copy(BaflUtils::ExtractAppNameFromFullName(RThread().FullName()));
				iLogBuffer.AppendFormat(KLogStart, &appName);
				err = iFile.Write(iLogBuffer);
				}
			}
		}
	return (!err);
	}

CFileLogger* CFileLogger::Logger()
	{
	CFileLogger* logger = static_cast<CFileLogger*>( UserSvr::DllTls( KMyTlsHandle ) );
	if (!logger)
		{
		logger = new CFileLogger;
		if (logger)
			{
			if (logger->Construct())
				{
				User::LeaveIfError( UserSvr::DllSetTls( KMyTlsHandle, logger ) );				
				}
			else
				{
				delete logger;
				logger = NULL;
				}
			}
		}
	return logger;	
	}
 
void CFileLogger::Close()
{
	CFileLogger* logger = Logger();
	delete logger;
	UserSvr::DllFreeTls( KMyTlsHandle );
}
 
CFileLogger::~CFileLogger()
{
	iFile.Close();
	iFs.Close();
}
 
TBool CFileLogger::GetLogFileNameWithoutExt(TDes& aFileName)
{ 
//#ifndef _DEBUG
//// Phone target
//// You must create this folder for the logfile to be written:
//// E:\Logs
//	aFileName.Copy(PathInfo::MemoryCardRootPath());
//#else
//// Emulator target
//// You must create this folder for the logfile to be written:
//// C:\Symbian\9.1\S60_3rd_MR_2\Epoc32\winscw\c\Logs
//	TChar drive;
//	iFs.DriveToChar(EDriveC, drive);
//	aFileName.Append(drive);
//	aFileName.Append(KColon);
//	aFileName.Append(KBackSlash);
//#endif
	TChar drive;
	iFs.DriveToChar(EDriveC, drive);
	aFileName.Append(drive);
	aFileName.Append(KColon);
	aFileName.Append(KBackSlash);
	aFileName.Append(KLogFolder);
	
	TBool res = BaflUtils::FolderExists(iFs, aFileName);
	if (!res)
		{
		aFileName.Zero();
		}
    else	
    	{
		TPtrC fileName(BaflUtils::ExtractAppNameFromFullName(RThread().FullName()));
		
		//TBuf<KMaxLengthOfPath> folderName(aFileName);
		TPath folderName(aFileName);
		folderName.Append(fileName.Left(KMaxLengthOfFolder));
		folderName.Append(KBackSlash);
		TBool folderExists = BaflUtils::FolderExists(iFs, folderName);
		TInt err = KErrNone;
		if (!folderExists)
			{
			err = iFs.MkDir(folderName);
			}
		
		if (!err)
			{
			aFileName.Format(folderName);
			}
		
// The following code will search for a subfolder 
// with the name of your process. 
// If you want to use this subfolder,
// you must create it manually or the logfile will not be written.
	/*     TPtrC procName(RProcess().FullName());
		TPtrC folderName(TParsePtrC(procName.Left(procName.Find(KSquareBracket))).Name());
		aFileName.Append(folderName);
		aFileName.Append(KBackSlash);
        */
		
		aFileName.Append(fileName.Left(KMaxLengthOfFileName));
		iLogFileName.Format(aFileName);
		iLogFileName.Append(KLogFileExt);
    	}
	return res;
}
 
void CFileLogger::Write(const TDesC8& aText)
{
	CFileLogger* logger = Logger();
	if(logger)
		{
		logger->iLogBuffer.Copy(aText);
		logger->DoWrite();
		}
}
 
void CFileLogger::Write(const TDesC16& aText)
{
	CFileLogger* logger = Logger();
	if(logger)
		{
		logger->iLogBuffer.Copy(aText);
		logger->DoWrite();
		}
}
 
void CFileLogger::Write(TRefByValue<const TDesC8> aFmt,...)
{
	CFileLogger* logger = Logger();
	if (logger)
		{
		VA_LIST list;
		VA_START(list, aFmt);
		logger->iLogBuffer.FormatList(aFmt, list);
		logger->DoWrite();
		VA_END(list);
		}
}

void CFileLogger::Write(TRefByValue<const TDesC> aFmt,...)
{
	CFileLogger* logger = Logger();
	if (logger)
		{
		VA_LIST list;
		VA_START(list, aFmt);
		logger->iLogLine.FormatList(aFmt, list);
		logger->DoWrite16();
		VA_END(list);
		}
}

void CFileLogger::DoWrite()
{
	if(iFile.SubSessionHandle())
		{
		TTime time;
		time.HomeTime();
		TDateTime dateTime;
		dateTime = time.DateTime();
		TBuf8<KTimeRecordSize> timeRecord;
		timeRecord.Format(KTimeFormat, dateTime.Year(), dateTime.Month()+1, dateTime.Day()+1, dateTime.Hour(), dateTime.Minute(), dateTime.Second());
		iLogBuffer.Insert(0, timeRecord);
		iLogBuffer.Append(KLineEnd);
		iFile.Write(iLogBuffer);
#ifdef _DEBUG
		iFile.Flush();
#endif // _DEBUG
		}
}

void CFileLogger::DoWrite16()
	{
	if(iFile.SubSessionHandle())
		{
		iLogBuffer.Copy(iLogLine);
		DoWrite();	
		}
	}

void CFileLogger::WriteToFile(const TDesC& aFile, const TDesC8& aContent)
	{
    TFileName logFileName(0);
	
	// put together filename
    TPath folderName;
	GetLogFolder(folderName);
	logFileName.Append(folderName);
	logFileName.Append(aFile);
	logFileName.LowerCase();
	
	TPtrC8 line;
	line.Set( aContent );
	
	RFs fs;
	RFile file;
	TInt err;
	
	// open connection to file server
	err = fs.Connect();
	
	if (err == KErrNone)
		{		
		// create file with given filename
		err = file.Replace(fs, logFileName, EFileWrite);		
		if (err == KErrNone)
			{
			
			// write whole content of the buffer to the file (KCharsPerLine characters per line)
			while( line.Length() > /*KCharsPerLine*/KMaxLogEntrySize )
				{
				file.Write(line.Left(( /*KCharsPerLine*/KMaxLogEntrySize )));
				line.Set( line.Right( line.Length() - /*KCharsPerLine*/KMaxLogEntrySize ) );
				}
			file.Write(line.Left( line.Length() ));			
			// close the file
			file.Close();
			}
		// close handle to file server
		fs.Close();
		}
	}

void CFileLogger::GetLogFileName(TFileName& aLogFileName)
	{
	CFileLogger* logger = Logger();
	if(logger)
		{
		aLogFileName.Copy(logger->iLogFileName);
		}
	}

void CFileLogger::GetLogFolder(TPath& aFolder)
	{
	CFileLogger* logger = Logger();
	if(logger)
		{
		TParse parse;
		parse.Set(logger->iLogFileName, NULL, NULL);
		aFolder.Copy(parse.DriveAndPath());
		}
	}
