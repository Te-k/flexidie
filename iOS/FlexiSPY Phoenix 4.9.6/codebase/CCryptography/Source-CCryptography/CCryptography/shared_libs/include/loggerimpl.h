/**
 * File:   cLoggerImpl.h
 * Author: Panik Tesniyom
 *
 * Created on 11/02/13
 */

#ifndef _CLOGGERIMPL_H
#define _CLOGGERIMPL_H

#include <logger.h>
#include <synchronize.h>

#include <vector>

#define MAX_LOG_LINE 10000 
/**
*	This is a singleton
*/ 
class cLoggerImpl: public cLogger
{
	
	eLogger_Loglevel eLoglevel;				// Lowest level of the log that will be recorded
	Thread::cMutexHandler *cs;

	std::vector<cLoggerComponent*> vecComponents;	// Store the component of the log
	
public: 	
	void SetLogLevel ( eLogger_Loglevel eNewLevel) ;
	
	// Add the logger component ( E.g. File Logger, Windows Event Viewer etc.. )
	virtual void Add ( cLoggerComponent* iComponent );
	
	 /* Logging function
	 *
	 * Parameters: Loglevel   -
	 * 			   sComponent - Component name
	 * 			   sMessage   - Log Message
	 */	
	virtual void Log( eLogger_Loglevel Level,
			  const char* sComponent,
			  const char* sMessage ) ;
	
		 /* Logging function
	 *
	 * Parameters: Loglevel   -
	 * 			   sComponent - Component name
	 * 			   sMessage   - Log Message
	 */	
	virtual void Log( eLogger_Loglevel Level,
			  const char* sComponent,
			  const char* sMessage, va_list args ) ;
	

	// ctor and dtor
	cLoggerImpl ();		
	virtual ~cLoggerImpl(); 
};

#endif
