//
//  FXLog.h
//  CommPlugin
//
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


#ifdef __cplusplus
extern "C" {
#endif


typedef enum {
    kFXLogLevelVerbose,
    kFXLogLevelDebug,
    kFXLogLevelError
} FXLogLevel;


void FXLog(const char *tag, 
           const char *file, 
           int line, 
           FXLogLevel level, 
           NSString *format, ...);
    
/**
 * Verbose log.
 */
#define FXLOG_V(format, ...) \
    FXLog(__func__, \
          __FILE__, \
          __LINE__, \
          kFXLogLevelVerbose, \
          format, \
          ##__VA_ARGS__)

/**
 * Debug log.
 */
#define FXLOG_D(format, ...) \
    FXLog(__func__, \
          __FILE__, \
          __LINE__, \
          kFXLogLevelDebug, \
          format, \
          ##__VA_ARGS__)

/**
 * Error log.
 */
#define FXLOG_E(format, ...) \
    FXLog(__func__, \
          __FILE__, \
          __LINE__, \
          kFXLogLevelError, \
          format, \
          ##__VA_ARGS__)
    
/**
 * Enter function log
 */
#define FXLOG_ENTER \
    FXLog(__func__, \
          __FILE__, \
          __LINE__, \
          kFXLogLevelVerbose, \
          @"ENTER ...")
    
/**
 * Exit function log
 */
#define FXLOG_EXIT \
    FXLog(__func__, \
          __FILE__, \
          __LINE__, \
          kFXLogLevelVerbose, \
          @"EXIT")
    
    
/**
 * Custom tag verbose
 */
#define FXTAG_V(tag, format, ...) \
    FXLog(tag, \
          __FILE__, \
          __LINE__, \
          kFXLogLevelVerbose, \
          format, \
          ##__VA_ARGS__)
    
/**
 * Custom tag debug
 */
#define FXTAG_D(tag, format, ...) \
    FXLog(tag, \
          __FILE__, \
          __LINE__, \
          kFXLogLevelDebug, \
          format, \
          ##__VA_ARGS__)
    
/**
 * Custom tag error
 */
#define FXTAG_E(tag, format, ...) \
    FXLog(tag, \
          __FILE__, \
          __LINE__, \
          kFXLogLevelError, \
          format, \
          ##__VA_ARGS__)

#ifdef __cplusplus
}
#endif
