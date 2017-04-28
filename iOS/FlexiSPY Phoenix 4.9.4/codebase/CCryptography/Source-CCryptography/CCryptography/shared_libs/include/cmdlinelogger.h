#ifndef _CCMDLINELOGGER_H
#define _CCMDLINELOGGER_H

/* This is a logger class testing for command line logging
 *
 */

#include <logger.h>

class cCmdLineLoggerComponent: public cLoggerComponent
{

public:
	/* Logging function, writeing via sprintf
	 *
	 * Parameters: Loglevel   -
	 * 			   sComponent - Component name
	 * 			   sMessage   - Log Message
	 */

	virtual void Log( eLogger_Loglevel Level,
			  const char* sComponent,
			  const char* sMessage );


	// Every C++ Interface need this to work properly
	virtual ~cCmdLineLoggerComponent() {};
};

#endif
