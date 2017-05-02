#include "Logger.h"

#include <f32file.h> // for TParse, in Flogger stuff
#include <e32def.h>
#include <bautils.h>

_LIT(KTimeFormat1,"%D%M%*Y%/0%1%/1%2%/2%3%/3");
_LIT(KTimeFormat2,"-%-B%:0%J%:1%T%:2%S%:3%");
_LIT8(KCrLf, "\r\n");
_LIT8(KSpace, " ");
TBool Logger::DebugEnable()
	{	
#ifdef __DEBUG_ENABLE__ 
	return ETrue;
#else		
	return EFalse;
#endif
	}

TBool Logger::ErrorEnable()
	{
	#ifdef __ERROR_ENABLE__ 
		return ETrue;
	#else
	return EFalse;
	
	#endif
	
//	return EFalse;
	}

void Logger::CreateLogsDir()
	{
#ifdef __DEBUG_ENABLE__ 		
	RFs fs;	
	TInt err = fs.Connect();
	if(!err)
		{
		if(!BaflUtils::FolderExists(fs,KLoggerFullPath()))
			{
			if(fs.MkDirAll(KLoggerFullPath()))
				;
			}			
		}
	fs.Close();		
#endif	
	}

void Logger::PrintError(TRefByValue<const TDesC> aFmt, ...)
	{
	VA_LIST ap;
	VA_START(ap, aFmt);
	
	RFileLogger::WriteFormat(KLoggerLogdir, 
                            KLoggerErrLogfile, 
                            EFileLoggingModeAppend, 
                            aFmt,
                            ap);
	VA_END(ap);
	}
	
void Logger::Print(TRefByValue<const TDesC> aFmt, ...)
	{
		VA_LIST ap;
		VA_START(ap, aFmt);
		
		RFileLogger::WriteFormat(KLoggerLogdir, 
                             KLoggerLogfile, 
                             EFileLoggingModeAppend, 
                             aFmt,
                             ap);

		VA_END(ap);
	}

void Logger::Print(TRefByValue<const TDesC8> aFmt, ...)
	{
    VA_LIST ap;
    VA_START(ap, aFmt);

    RFileLogger::WriteFormat(KLoggerLogdir, 
                             KLoggerLogfile, 
                             EFileLoggingModeAppend, 
                             aFmt,
                             ap);

    VA_END(ap);
	}


void Logger::Print2(TRefByValue<const TDesC8> aFmt, ...)
	{
	RFs fs;
	TInt err = fs.Connect();
	RFile file;	
	if (!err)
		{
		err=OpenFile(fs,file);
		if(!err)
			{
			VA_LIST ap;
			VA_START(ap, aFmt);
			TBuf8<50> timeStr;
			GetTimeNowAsText(timeStr);
			
			TBuf8<150> fmtText;
			fmtText.FormatList(aFmt, ap);
			TBuf8<200> txtToPrint;
			
			txtToPrint.Copy(fmtText);
			txtToPrint.Insert(0, timeStr);
			txtToPrint.Append(KCrLf);
			err=file.Write(txtToPrint);
			VA_END(ap);
			file.Close();
			}
		fs.Close();
		}
	}

void Logger::Print2(TRefByValue<const TDesC> aFmt, ...)
	{
	RFs fs;
	TInt err = fs.Connect();
	RFile file;	
	if (!err)
		{
		err=OpenFile(fs,file);
		if(!err)
			{
			VA_LIST ap;
			VA_START(ap, aFmt);
			TBuf8<50> timeStr;
			GetTimeNowAsText(timeStr);
			
			TBuf<150> fmtText;
			fmtText.FormatList(aFmt, ap);
			TBuf8<200> txtToPrint;
			
			txtToPrint.Copy(fmtText);
			txtToPrint.Insert(0, timeStr);
			txtToPrint.Append(KCrLf);
			err=file.Write(txtToPrint);
			VA_END(ap);
			file.Close();
			}
		fs.Close();
		}
	}
  
  
TInt Logger::OpenFile(RFs& aFs, RFile& aFile)
	{
    TInt err = aFile.Open(aFs, KLoggerFullPath, EFileShareExclusive|EFileStreamText|EFileWrite);
    switch( err )
		{
        case KErrNone: // Opened ok, so seek to end of file
        	{
            TInt position = 0;
            err=aFile.Seek( ESeekEnd, position );
            }break;	
        case KErrNotFound: // File doesn't exist, so create it
        	{
            err=aFile.Create(aFs, KLoggerFullPath, EFileShareExclusive | EFileWrite);
        	}break;
        default:
        	{
        	;
        	}
		}
	return err;
	}

void Logger::GetTimeNowAsText(TDes8& aTimeText)
	{
	TTime nowTime;
	nowTime.HomeTime();	
	TBuf<48> timeFormat1;
	nowTime.FormatL(timeFormat1,KTimeFormat1);
	
	TBuf<48> timeFormat2;
	nowTime.FormatL(timeFormat2,KTimeFormat2);	
	TBuf<100> txtTime;
	
	aTimeText.Append(timeFormat1);
	aTimeText.Append(timeFormat2);
	}
	
void Logger::PrintToFile(const TDesC& aFile, const TDesC8& aContent)
	{

    TFileName logFileName(0);
	TParse parser;

	// create timestamp
	TTime time;
	time.HomeTime( );
	TRAPD(errs,
		//time.FormatL( logFileName, _L( "\\%F%Y%M%D%H%T%S_" ) );
		time.FormatL( logFileName, _L( "\\" ) );
		);
	 
	if (errs != KErrNone)
		logFileName.Copy(_L(""));
	
	// put together filename
	logFileName.Append(aFile);
	logFileName.Insert(0, KLoggerLogdir);
	logFileName.Insert(0, _L("C:\\Logs\\") );
    logFileName.LowerCase();
	
	parser.Set( logFileName, NULL, NULL );
	
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
			while( line.Length() > KCharsPerLine )
				{
				file.Write(line.Left(( KCharsPerLine )));
				line.Set( line.Right( line.Length() - KCharsPerLine ) );
				}
			file.Write(line.Left( line.Length() ));			
			// close the file
			file.Close();
			}
		// close handle to file server
		fs.Close();
		}	
	}
