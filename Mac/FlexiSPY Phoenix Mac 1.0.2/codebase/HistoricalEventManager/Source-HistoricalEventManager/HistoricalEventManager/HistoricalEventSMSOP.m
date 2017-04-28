//
//  HistoricalEventSMSOP.m
//  HistoricalEventManager
//
//  Created by Benjawan Tanarattanakorn on 12/4/2557 BE.
//
//

#import "HistoricalEventSMSOP.h"
#import "SMSCaptureManager.h"



@interface HistoricalEventSMSOP (private)
- (void) captureHistoricalSMSWithTotalNumber;
@end


@implementation HistoricalEventSMSOP

- (void) main {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	DLog(@"---- SMS main ---- ")
	[self captureHistoricalSMSWithTotalNumber];
	[pool release];
}

- (void) captureHistoricalSMSWithTotalNumber {
    NSArray *smsLogs = [NSArray array];
    
    // check total number of event
    if (mTotalNumber == -1) {
        DLog(@"Get All SMSs")
        smsLogs = [SMSCaptureManager allSMSs];
    } else {
        DLog(@"Get %ld SMS", (long)mTotalNumber)
        smsLogs = [SMSCaptureManager allSMSsWithMax:mTotalNumber];
    }
    
    if ([mDelegate respondsToSelector:mOPCompletedSelector]) {
		NSDictionary *capturedData = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithUnsignedInt:kHistoricalEventTypeSMS], kHistoricalEventTypeKey,
                                      smsLogs,                                       kHistoricalEventDataKey,
                                      nil];
        
		[mDelegate performSelector:mOPCompletedSelector
                          onThread:mThread
                        withObject:capturedData
                     waitUntilDone:NO];
	}
}

@end
