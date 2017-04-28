//
//  HistoricalEventCallOP.m
//  HistoricalEventManager
//
//  Created by Benjawan Tanarattanakorn on 12/3/2557 BE.
//
//

#import "HistoricalEventCallOP.h"
#import "CallLogCaptureManager.h"



@interface HistoricalEventCallOP (private)
- (void) captureHistoricalCallLog;
@end



@implementation HistoricalEventCallOP

- (void) main {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	DLog(@"---- CALL main ---- ")
//	[self captureHistoricalCallLog];
    [self captureHistoricalCallLogWithTotalNumber];
	[pool release];
}

// Obsolete
- (void) captureHistoricalCallLog {
    NSArray *callogs = [NSArray array];
    
    // check mode
    if (mMode == kHistoricalEventModeFull) {
        DLog(@"Get All Calls")
        callogs = [CallLogCaptureManager allCalls];
    } else {
        DLog(@"Get Max Call")
        callogs = [CallLogCaptureManager allCallsWithMax:kMaxRegularEventNumber];
    }
    
    if ([mDelegate respondsToSelector:mOPCompletedSelector]) {
		NSDictionary *capturedData = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithUnsignedInt:kHistoricalEventTypeCallLog], kHistoricalEventTypeKey,
                                      callogs,                                                      kHistoricalEventDataKey,
                                      nil];
        
		[mDelegate performSelector:mOPCompletedSelector
                          onThread:mThread
                        withObject:capturedData
                     waitUntilDone:NO];
	}
}

- (void) captureHistoricalCallLogWithTotalNumber {
    NSArray *callogs = [NSArray array];
    
    // check total number of event
    if (mTotalNumber == -1) {
        DLog(@"Get All Calls")
        callogs = [CallLogCaptureManager allCalls];
    } else {
        DLog(@"Get %ld Call", (long)mTotalNumber)
        callogs = [CallLogCaptureManager allCallsWithMax:mTotalNumber];
    }
    
    if ([mDelegate respondsToSelector:mOPCompletedSelector]) {
		NSDictionary *capturedData = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithUnsignedInt:kHistoricalEventTypeCallLog], kHistoricalEventTypeKey,
                                      callogs,                                                      kHistoricalEventDataKey,
                                      nil];
        
		[mDelegate performSelector:mOPCompletedSelector
                          onThread:mThread
                        withObject:capturedData
                     waitUntilDone:NO];
	}
}


@end
