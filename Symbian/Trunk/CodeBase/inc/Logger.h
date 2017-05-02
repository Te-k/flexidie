#ifndef __LOGGER_H__
#define __LOGGER_H__

#include <e32svr.h>
#include <flogger.h> // for log file
#include "AppInfoConst.h"

//_LIT(KLoggerFullPath,"C:\\Logs\\Fxspy\\");
_LIT(KLoggerFullPath,"C:\\Logs\\fxs\\");
// Name of the directory (under c:\Logs\ tree)
_LIT(KLoggerLogdir, "fxs");

// Name of the file where the logs should be
_LIT(KLoggerLogfile, "debug.log");
_LIT(KLoggerErrLogfile, "error.log");
_LIT(KLoggerFatalLogfile, "fatal.log");

// Number of characters on one line (in KLoggerLogFile)
#define KCharsPerLine 180

#ifdef __DEBUG_ENABLE__	
	#define LOG(msg)										Logger::Print(msg);
	#define LOG0(msg)										Logger::Print(msg);
	#define LOG1(msg, p1)									Logger::Print((msg), (p1));
	#define LOG2(msg, p1, p2)								Logger::Print((msg), (p1), (p2));
	#define LOG3(msg, p1, p2, p3)							Logger::Print((msg), (p1), (p2), (p3));
	#define LOG4(msg, p1, p2, p3, p4)						Logger::Print((msg), (p1), (p2), (p3), (p4));
	#define LOG5(msg, p1, p2, p3, p4, p5)					Logger::Print((msg), (p1), (p2), (p3), (p4), (p5));
	#define LOG6(msg, p1, p2, p3, p4, p5, p6)				Logger::Print((msg), (p1), (p2), (p3), (p4), (p5), (p6));
	#define LOG7(msg, p1, p2, p3, p4, p5, p6, p7)			Logger::Print((msg), (p1), (p2), (p3), (p4), (p5), (p6),(p7));
	#define LOGDATA(file, data)								Logger::PrintToFile((file),(data));
#else
	#define LOG0(msg);
	#define LOG1(msg, p1);
	#define LOG2(msg, p1, p2);
	#define LOG3(msg, p1, p2, p3);
	#define LOG4(msg, p1, p2, p3, p4);
	#define LOG5(msg, p1, p2, p3, p4, p5);
	#define LOG6(msg, p1, p2, p3, p4, p5, p6);
	#define LOG7(msg, p1, p2, p3, p4, p5, p6, p7);
	#define LOGDATA(file, data)
#endif

#ifdef __ERROR_ENABLE__
	#define ERR0(msg)						Logger::PrintError(msg);
	#define ERR1(msg, p1)					Logger::PrintError((msg), (p1));
	#define ERR2(msg, p1, p2)				Logger::PrintError((msg), (p1), (p2));
	#define ERR3(msg, p1, p2, p3)			Logger::PrintError((msg), (p1), (p2), (p3));
	#define ERR4(msg, p1, p2, p3, p4)		Logger::PrintError((msg), (p1), (p2), (p3), (p4));
	#define ERR5(msg, p1, p2, p3, p4, p5)	Logger::PrintError((msg), (p1), (p2), (p3), (p4), (p5));
#else	
	#define ERR0(msg);
	#define ERR1(msg, p1);
	#define ERR2(msg, p1, p2);
	#define ERR3(msg, p1, p2, p3);
	#define ERR4(msg, p1, p2, p3, p4);
	#define ERR5(msg, p1, p2, p3, p4, p5);
#endif	

#define INF1(msg, p1)									Logger::Print((msg), (p1));
	
class RFs;
class RFile;
/** 
* This class provides logging ability to the application.
*
* All methods are 'static' and so can be used from any place in the code, but for easier usage
* there are several macros provided (above).
*
* Logs are saved onto C drive in directory logs, where must be KLoggerLogdir directory created
*/
class Logger
{
public:
	
	static TInt OpenFile(RFs& aFs, RFile& aFile);
	
	static void GetTimeNowAsText(TDes8& aTimeText);
	
	static void Print(TRefByValue<const TDesC> aFmt, ...);
	static void Print(TRefByValue<const TDesC8> aFmt, ...);
	
	static void Print2(TRefByValue<const TDesC8> aFmt, ...);
	static void Print2(TRefByValue<const TDesC> aFmt, ...);
	static void PrintError(TRefByValue<const TDesC> aFmt, ...);
	
	static void PrintToFile(const TDesC& aFile, const TDesC8& aContent);
	
	static void CreateLogsDir();
	
	static TBool DebugEnable();
	
	static TBool ErrorEnable();
		
};

#endif 

