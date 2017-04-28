//
//  DebugStatus.h
//  FxStd
//
//  Created by Makara Khloth on 10/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

#import "FxLogger.h"

#define DEBUG_DLOG
#define DEBUG_FXLOG

// Debug log
#ifdef DEBUG_DLOG
    #ifdef DEBUG_FXLOG
        #define DLog(fmt, ...) FxLog(__func__, __FILE__, __LINE__, kFxLogLevelVerbose, fmt, ##__VA_ARGS__);
    #else
        #define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
    #endif
#else
    #define DLog(...)
#endif

// To remove debug log warning https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/Strings/Articles/formatSpecifiers.html
#if TARGET_OS_IPHONE
    #define NSINTEGER_DLOG(i) \
            (NSInteger)i
    #define NSUINTEGER_DLOG(i) \
            (NSUInteger)i
    #define SINT32_DLOG(i) \
            (SInt32)i
    #define UINT32_DLOG(i) \
            (UInt32)i
#else
    #define NSINTEGER_DLOG(i) \
            (long)i
    #define NSUINTEGER_DLOG(i) \
            (unsigned long)i
    #define SINT32_DLOG(i) \
            (signed long)i
    #define UINT32_DLOG(i) \
            (unsigned long)i
#endif