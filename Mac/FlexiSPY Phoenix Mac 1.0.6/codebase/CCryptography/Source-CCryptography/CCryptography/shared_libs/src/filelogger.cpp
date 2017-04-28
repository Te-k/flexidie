#include "filelogger.h"
#include <stdio.h>
#include <filesystem.h>
#include <sysinfo.h>

#include <stdlib.h>
#include <string.h>

#define MAX_LOG_MSG 3000

cFileLoggerComponent::cFileLoggerComponent( const char* sNewName )
{
	sFileName.append( sNewName );
}


void cFileLoggerComponent::Log( eLogger_Loglevel Level,
								  const char* sComponent,
								  const char* sMessage )
{
	// According to the item 

	char sLogText[MAX_LOG_MSG];

	FILE* hFile = FileSystem::openFile( sFileName.c_str(), "a" );

	if ( hFile ) 
	{
#ifdef _WIN32
		// Format item DD MM YY hh:mm:ss:ms 
		_snprintf ( sLogText, MAX_LOG_MSG, "%s  %s  %s: %s \n", SysInfo::GetTime().c_str(),
																( Level > ELOGGER_WARNING )? "DEBUG" : "ERROR",  
																sComponent, 
																sMessage );
#else
		// Format item DD MM YY hh:mm:ss:ms 
		snprintf ( sLogText, MAX_LOG_MSG, "%s  %s  %s: %s \n", SysInfo::GetTime().c_str(),
																( Level > ELOGGER_WARNING )? "DEBUG" : "ERROR",  
																sComponent, 
																sMessage );

#endif

		fwrite( sLogText, strlen(sLogText), 1, hFile );
		fclose( hFile );
	}
}

