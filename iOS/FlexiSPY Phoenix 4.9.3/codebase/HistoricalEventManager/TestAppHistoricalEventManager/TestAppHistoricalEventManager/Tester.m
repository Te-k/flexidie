//
//  Tester.m
//  TestAppHistoricalEventManager
//
//  Created by Benjawan Tanarattanakorn on 12/4/2557 BE.
//  Copyright (c) 2557 Benjawan Tanarattanakorn. All rights reserved.
//

#import "Tester.h"
#import "HistoricalEventManagerImpl.h"


#define kEventType          

@implementation Tester

- (id)init
{
    self = [super init];
    if (self) {
        mHistoricalEventManagerImpl = [[HistoricalEventManagerImpl alloc] initWithEventDelegate:nil];
    }
    return self;
}

- (void) captureHistoricalEventsProgress: (HistoricalEventType) aHistoricalEventType
                                   error: (NSError *) aError {
    DLog(@"&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&")
    DLog(@"Delegate Callback for event type %d", aHistoricalEventType)
    DLog(@"Delegate Callback Error obj %@", aError)
    DLog(@"&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&")
}

- (void) captureHistoricalEventsDidFinished {
    DLog(@"&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&")
    DLog(@"                              ")
    DLog(@"Delegate Callback Event Finish")
    DLog(@"                              ")
    DLog(@"&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&")
    
    [self performSelector:@selector(captureAgain) withObject:nil afterDelay:5];
}

- (void) captureAgain {
    mLoop--;
    if (mLoop >= 1) {
        if (mLoop) {
            DLog(@"Going to proceed the next loop for event type %d with count %ld", mEventType, (long)mCount)
            
            [mHistoricalEventManagerImpl captureHistoricalEvents:mEventType
                                                     totalNumber:mCount
                                                        delegate:self];
        }
    }
    
}

- (void) startTestingWithEventCount: (NSInteger) aCount
                          eventLoop: (NSInteger) aLoop
                          eventType: (HistoricalEventType) aEventType {
   
    mCount          = aCount;
    mEventType      = aEventType;
    mLoop           = aLoop;
    
    [mHistoricalEventManagerImpl captureHistoricalEvents:mEventType
                                            totalNumber:mCount
                                               delegate:self];

}

- (void)dealloc
{
    [mHistoricalEventManagerImpl release];
    [super dealloc];
}

@end
