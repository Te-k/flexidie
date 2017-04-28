#include "cmdlinelogger.h"
#include "stdio.h"

void cCmdLineLoggerComponent::Log( eLogger_Loglevel Level,
								  const char* sComponent,
								  const char* sMessage )
{
	printf ( "%s : %s \n", sComponent, sMessage );
}
