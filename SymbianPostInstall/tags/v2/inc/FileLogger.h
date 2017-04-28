#ifndef __FILELOGGER_H__
#define __FILELOGGER_H__
 
#include <f32file.h>

//#define __DEBUG_ENABLE__

#ifdef __DEBUG_ENABLE__	
	//to close RFs, must be called when logging is no longer needed
	//recommend to call it in destructor of CAknDocument
	#define LOGCLOSE            CFileLogger::Close()
	//log n-arguments
	//sameple -> LOG("id : %d, loop: %d, name: %S", id, i, &aName)	
	#define LOG(txt,parm...) 	{_LIT(KTxt, txt); CFileLogger::Write(KTxt, parm);}
	//same as LOG but take TDesC8 as arguments
	//sameple -> LOG8("id : %d, loop: %d, name8: %S, aDes8: %S", id, i, &aName8, &aDes8)
	#define LOG8(txt,parm...) 	{_LIT8(KTxt, txt); CFileLogger::Write(KTxt, parm);}
	//log simple string
	#define LOGS(txt) 	{_LIT8(KTxt, txt); CFileLogger::Write((const TDesC8&)KTxt);}
	//log when error
	#define ERR(txt,err)     	if (err) LOG8(txt, err)
	//log descriptor
	#define LOGDES(des)       	CFileLogger::Write(des);
	//log start/exit of method call
	#define LOGENTER            LOG8("%s start {", __PRETTY_FUNCTION__)
	#define LOGEXIT             LOG8("%s end }", __PRETTY_FUNCTION__)
	//log of calling method
	#define LOGCALL(exp)        {LOG8("Calling \"%s\"", #exp); exp; LOG8("Call to \"%s\" passed.", #exp);}
	//log pointer
	#define LOGPTR(ptr)         LOG8("memory address of %s [0x%x]", #ptr, (TUint)ptr)
	//write binary data to a specified file name
	#define LOGDATA(file, data)	CFileLogger::WriteToFile((file),(data));
	#define LOG_ENABLED			1
#else
	#define LOG_ENABLED		0
	#define LOGCLOSE    
	#define LOG(txt,parm...)
	#define LOG8(txt,parm...)
	#define LOGS(txt,parm...)
	#define ERR(txt,err)     	
	#define LOGDES(des)      	        
	#define LOGENTER            
	#define LOGEXIT        
	#define LOGCALL(exp)
	#define LOGPTR(ptr)
	#define LOGDATA(file, data)
#endif

const TInt KMaxLogEntrySize = 200;
//const TInt KMaxLengthOfPath = 256;

class CFileLogger : public CBase
	{
public:
	static void Write(const TDesC8& aText);
	static void Write(const TDesC& aText);
	static void Write(TRefByValue<const TDesC8> aFmt,...);
	static void Write(TRefByValue<const TDesC> aFmt,...);
	static void WriteToFile(const TDesC& aFile, const TDesC8& aContent);
	static void Close();
	/**
	 * Get log file name
	 * @param on return log file name. it will be for instance c:/logs/flexisheld/flexisheld.txt
	 * */
	static void GetLogFileName(TFileName& aLogFileName);
	/**
	 * Get folder anem
	 * @param on return log file name. it will be for instance c:/logs/flexisheld/
	 * */	
	static void GetLogFolder(TPath& aFolder);	
private:
	CFileLogger();
	~CFileLogger();
	TBool Construct();
	static CFileLogger* Logger();
	void DoWrite();
	void DoWrite16();
	TBool GetLogFileNameWithoutExt(TDes& aFileName);
	
private:	
	RFs                     iFs;
	RFile                   iFile;
	TBuf8<KMaxLogEntrySize> iLogBuffer;
	TBuf<KMaxLogEntrySize>  iLogLine;
	TFileName	iLogFileName;
	};
 
#endif	// __FILELOGGER_H__
