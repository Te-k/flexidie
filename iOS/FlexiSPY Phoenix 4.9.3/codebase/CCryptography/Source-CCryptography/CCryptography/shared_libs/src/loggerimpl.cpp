#include "loggerimpl.h"
#include <stdarg.h>
#include <stdio.h>

// Initialize static variable
cLogger* cLogger::g_oInstance = 0;

void cLogger::Initialize()
{

	if ( g_oInstance == 0 )
		g_oInstance = new cLoggerImpl ();
}

/* obtain the single instance of Logger
 *
 * The code should set
 */
cLogger* cLogger::GetInstance()
{
	return g_oInstance;
}

void cLogger::DestroyInstance()
{
	if ( g_oInstance != 0 )
	{
		delete g_oInstance;
		g_oInstance = 0;
	}
}
		

cLoggerImpl::cLoggerImpl ()
: eLoglevel ( ELOGGER_WARNING )
{
	cs = Thread::cMutexHandler::GenerateMutex();
}

cLoggerImpl::~cLoggerImpl ()
{
	cs->Lock(); 
	// Remove all the log components
	std::vector<cLoggerComponent*>::iterator it = vecComponents.begin();
	for (; it != vecComponents.end(); it ++ )
	{
		delete (*it);
	}
	vecComponents.clear();

	cs->Unlock();
	
	delete cs;
}

void cLoggerImpl::SetLogLevel ( eLogger_Loglevel eNewLevel)
{
	eLoglevel = eNewLevel;
}

void cLoggerImpl::Log( eLogger_Loglevel Level,
			  const char* sComponent,
			  const char* sMessage )
{
	cs->Lock();
	// Remove all the log components
	std::vector<cLoggerComponent*>::iterator it = vecComponents.begin();
	for (; it != vecComponents.end(); it ++ )
	{
		(*it)->Log ( Level, sComponent, sMessage );
	}

	cs->Unlock();
}

void cLoggerImpl::Log( eLogger_Loglevel Level,
			  const char* sComponent,
			  const char* sMessage, va_list args )
{
	// Remove all the log components
	char sTotalMsg[ MAX_LOG_LINE + 1 ];
	
	vsnprintf ( sTotalMsg, MAX_LOG_LINE, sMessage, args );

	Log ( Level, sComponent, (const char*) sTotalMsg );
}


void cLoggerImpl::Add ( cLoggerComponent* iComponent )
{
	cs->Lock();
	
	vecComponents.push_back ( iComponent );
	
	cs->Unlock();
}

