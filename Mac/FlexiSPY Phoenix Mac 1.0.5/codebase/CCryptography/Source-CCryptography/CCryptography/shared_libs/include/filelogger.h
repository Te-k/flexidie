/**
 * File:   cFileLoggerComponent.h
 * Author: Panik Tesniyom
 *
 * Created on 11/02/13
 *
 */


#ifndef _CFILELOGGER_H
#define _CFILELOGGER_H

/* 
*  File Logger Class Component
*
*/

#include <logger.h>
#include <string>

class cFileLoggerComponent: public cLoggerComponent
{
	std::string sFileName;
public:
	
	 /* Logging function, writeing via sprintf
	 *
	 *	@param  eLoglevel  Error, Warning Etc..
	 * 	@param  sComponent Component name
	 * 	@param 	sMessage   Log Message
	 *
	 */
	 virtual void Log( eLogger_Loglevel eLogLevel,
			  const char* sComponent,
			  const char* sMessage );

	 /* Contstuctor
	 *
	 *	@param sFileName  Log File Name
	 *
	 */
	 cFileLoggerComponent( const char* sFileName );
	
	/* Every C++ Interface need this to work properly
	*
	*/
	virtual ~cFileLoggerComponent() {};
};

#endif
