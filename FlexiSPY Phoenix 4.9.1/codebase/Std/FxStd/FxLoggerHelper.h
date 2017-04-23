/**
 - Project Name  : Logger
 - Class Name    : FxLoggerHelper.h
 - Version       : 1.0
 - Purpose       : The purpose of this class is to configure logger
 - Copy right    : 04/11/2011 , Syam Sasidharan, Vervata Co. Ltd. All rights reserved.
 **/
#import <Foundation/Foundation.h>
#import "DebugStatus.h"

#ifdef DEBUG_DLOG
	#define DEBUG_MODE
#endif

#define FX_LOGGER_MAX_MESSAGE_SIZE 1024

//#define FX_LOGGER_LOG_FILE_PATH "/log/plugin.log"
#define FX_LOGGER_LOG_FILE_PATH @"/log/%@.log"
//#define FX_LOGGER_LOG_FILE_PATH @"/User/Media/Downloads/%@.log"

#ifdef DEBUG_MODE
	#define APPLOG(x1,x2,x3,x4,x5)  ( FxLog(x1,x2,x3,x4,x5) )
	#define APPLOGVERBOSE(x1,...)  ( FXLOG_V(x1,##__VA_ARGS__) )
	#define APPLOGERROR(x1,...)  ( FXLOG_E(x1,##__VA_ARGS__) )
#else
	#define APPLOG //
	#define APPLOGVERBOSE  //
	#define APPLOGERROR  //
#endif

