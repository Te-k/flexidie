//
//  AppAgentManagerForMac.h
//  AppAgent
//
//  Created by Makara Khloth on 3/23/15.
//
//

#import <Foundation/Foundation.h>

#import "EventCapture.h"

@class DiskSpaceWarningAgent;
@class ExceptionHandleAgent;

@interface AppAgentManagerForMac : NSObject <EventCapture> {
    id <EventDelegate>		mEventDelegate;
    
    // -- DISK SPACE
    DiskSpaceWarningAgent	*mDiskSpaceWarningAgent;
    BOOL					mListeningDiskSpaceWarning;
    
    // -- EXCEPTION
    ExceptionHandleAgent	*mExceptionHandleAgent;
    BOOL					mListeningException;
}

@property (nonatomic, assign) id <EventDelegate> mEventDelegate;

// -- DISK SPACE
- (void) startListenDiskSpaceWarningLevel;
- (void) stopListenDiskSpaceWarningLevel;
- (BOOL) setThresholdInMegabyteForDiskSpaceCriticalLevel: (uint64_t) aValue;
- (BOOL) setThresholdInMegabyteForDiskSpaceUrgentLevel: (uint64_t) aValue;
- (BOOL) setThresholdInMegabyteForDiskSpaceWarningLevel: (uint64_t) aValue;

// -- UNCAUGHT EXCEPTION
- (void) startHandleUncaughtException;
- (void) stopHandleUncaughtException;

@end
