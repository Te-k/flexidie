/**
 * File:   cLogger.h
 * Author: Panik Tesniyom
 *
 * Created on 11/02/13
 *
 */

#ifndef _CLOGGER_H
#define _CLOGGER_H

#include <stdint.h>
#include <stdarg.h>

/**
* Log Level, the smaller the number, the more severe
*/
enum eLogger_Loglevel
{
	ELOGGER_ERROR = 0,
	ELOGGER_WARNING = 1,
	ELOGGER_INFO = 2,
	ELOGGER_TRACE = 3,
	ELOGGER_VERBOSE = 4
};

/**
*  Interfaces for the Logger Items
*/
class cLoggerComponent
{

public:
	
	/**
	* Logging function
	*
	* @Param  Loglevel		Log Level
	* @param  sComponent	Component name
	* @param  sMessage		Log Message
	*/
	virtual void Log( eLogger_Loglevel Level,
			  const char* sComponent,
			  const char* sMessage ) = 0;

	/**
	* Destructor
	* Every C++ Interface needs virtual destructor to work properly
	*/
	virtual ~cLoggerComponent() {};
};

/**
*This is the interface of Logger composite pattern, which contains the loggers component
*/
class cLogger: public cLoggerComponent
{
private:
	static cLogger* g_oInstance;		// Static Instance of the log	
	
public:
	/**
	* Initizlize the logger component
	*/
	static void Initialize();

	/**
	*  Get Instance	
	*
	*  @Return a singleton instance of Logger Service
	*/
	static cLogger* GetInstance();

	/**
	*  Destroy Instance	
	*
	*  @Return a singleton instance of Logger Service
	*/
	static void DestroyInstance();


	/**
	*  Set the least log level that it will show
	*
	*  @param eNewLevel	the maximum log number that it will show.
	*/
	virtual void SetLogLevel ( eLogger_Loglevel eNewLevel) = 0;
	
	/**
	* Add the logger component ( E.g. File Logger, Windows Event Viewer etc.. )
	*
	* @param iComponent	Log Component to be added
	*/
	virtual void Add ( cLoggerComponent* iComponent ) = 0;

	/**
	* Logging function
	*
	* @Param  Loglevel		Log Level
	* @param  sComponent	Component name
	* @param  sMessage		Log Message
	*/
	virtual void Log( eLogger_Loglevel Level,
			  const char* sComponent,
			  const char* , va_list args  ) = 0;

	/**
	* Logging function
	*
	* @Param  Loglevel		Log Level
	* @param  sComponent	Component name
	* @param  sMessage		Log Message
	*/
	virtual void Log( eLogger_Loglevel Level,
			  const char* sComponent,
			  const char* sMessage ) = 0;


	/**
	* Destructor
	* Every C++ Interface needs virtual destructor to work properly
	*/
	virtual ~cLogger() {};
};



#endif
