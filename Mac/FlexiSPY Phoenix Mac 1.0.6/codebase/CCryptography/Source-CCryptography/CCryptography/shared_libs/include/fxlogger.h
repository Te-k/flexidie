 /**
 * File:   cFXLogger.h
 * Author: Panik Tesniyom
 *
 * Created on 11/02/13
 */

#ifndef _CFXLOGGER_H
#define _CFXLOGGER_H

/**
* File Log Wrapper to used with Phoenix components.
*/
#include <logger.h>
#include <string>
#include <string.h>
#include <stdarg.h>
#include <stdio.h>

//#define LOGVERBOSE cFXLogger::d
//#define LOGDEBUG cFXLogger::d
//#define LOGERROR cFXLogger::e

//#define LOGENTER LOGVERBOSE(COMPONENT_NAME, "%s %s", __FUNCTION__, "enter" );

#define LOGVERBOSE cFXLogger::a
#define LOGDEBUG cFXLogger::a
#define LOGERROR cFXLogger::a

#define LOGENTER cFXLogger::a

#ifdef _WIN32

#ifndef snprintf
	#define snprintf sprintf_s
#endif

#endif

class cFXLogger 
{
		// Main singleton logger
		static cLogger* m_oLogger;
public:
    /**
     * Log for Mac
     *
     * @param sComponent	Component Name 
     * @param sMessage	Error Message to log
     */
    static void a( const char* /*sComponent*/, const char* sMessage, ... )
    {
        va_list args;
        
        va_start( args, sMessage );
        
        va_end ( args );
    }
    
		/**
        * Log Error
        *
        * @param sComponent	Component Name 
        * @param sMessage	Error Message to log
        */
		static void e( const char* sComponent, const char* sMessage, ... )
		{
			if ( !cLogger::GetInstance() )
				return;

			va_list args;
	
			va_start( args, sMessage );
				cLogger::GetInstance()->Log ( ELOGGER_ERROR, sComponent, sMessage, args );
			va_end ( args );
		}
		
		
		/**
        * Log Debug
        *
        * @param sComponent	Component Name 
        * @param sMessage	Error Message to log
        */
		static void d( const char* sComponent, const char* sMessage, ...  )
		{
			if ( !cLogger::GetInstance() )
				return;

			va_list args;
	
			va_start( args, sMessage );
				cLogger::GetInstance()->Log( ELOGGER_VERBOSE, sComponent, sMessage, args  );
			va_end ( args );
		}

		/** 
		* Log Byte Stream to String
		*
		* @param pByte byte
		* @param iSize size of the byte
		*/
		static std::string byteToString ( unsigned char* pByte, size_t iSize )
		{
			std::string ret = "";
			char item[10];
			for ( size_t i = 0; i < iSize; i++ )
			{
				snprintf ( item, 10, "%x ", pByte[i] ); 
				ret.append ( item );
			}

			return ret;
		}
};


#endif
