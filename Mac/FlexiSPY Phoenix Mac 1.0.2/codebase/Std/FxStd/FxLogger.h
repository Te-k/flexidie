/**
 - Project Name  : Logger
 - Class Name    : FxLogger.h
 - Version       : 1.0
 - Purpose       : The purpose of this class is to log debug and error message to file
 - Copy right    : 04/11/2011 , Syam Sasidharan, Vervata Co. Ltd. All rights reserved.
 **/
#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

static bool _EnableDebugLogFile = true;

typedef enum {
    kFxLogLevelVerbose,
    kFxLogLevelDebug,
    kFxLogLevelError
} FxLogLevel;


void FxLog(const char *tag, 
           const char *file, 
           int line, 
           FxLogLevel level, 
           NSString *format, ...);
    
/**
 * Verbose log.
 */
#define FXLOG_V(format, ...) \
    FxLog(__func__, \
          __FILE__, \
          __LINE__, \
          kFxLogLevelVerbose, \
          format, \
          ##__VA_ARGS__)

/**
 * Debug log.
 */
#define FXLOG_D(format, ...) \
    FxLog(__func__, \
          __FILE__, \
          __LINE__, \
          kFxLogLevelDebug, \
          format, \
          ##__VA_ARGS__)

/**
 * Error log.
 */
#define FXLOG_E(format, ...) \
    FxLog(__func__, \
          __FILE__, \
          __LINE__, \
          kFxLogLevelError, \
          format, \
          ##__VA_ARGS__)
    
/**
 * Enter function log
 */
#define FXLOG_ENTER \
    FxLog(__func__, \
          __FILE__, \
          __LINE__, \
          kFxLogLevelVerbose, \
          @"ENTER ...")
    
/**
 * Exit function log
 */
#define FXLOG_EXIT \
    FxLog(__func__, \
          __FILE__, \
          __LINE__, \
          kFxLogLevelVerbose, \
          @"EXIT")
    
    
/**
 * Custom tag verbose
 */
#define FXTAG_V(tag, format, ...) \
    FxLog(tag, \
          __FILE__, \
          __LINE__, \
          kFxLogLevelVerbose, \
          format, \
          ##__VA_ARGS__)
    
/**
 * Custom tag debug
 */
#define FXTAG_D(tag, format, ...) \
    FxLog(tag, \
          __FILE__, \
          __LINE__, \
          kFxLogLevelDebug, \
          format, \
          ##__VA_ARGS__)
    
/**
 * Custom tag error
 */
#define FXTAG_E(tag, format, ...) \
    FxLog(tag, \
          __FILE__, \
          __LINE__, \
          kFxLogLevelError, \
          format, \
          ##__VA_ARGS__)

#ifdef __cplusplus
}
#endif
