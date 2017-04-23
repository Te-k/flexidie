//
//  Tester.h
//  TestAppHistoricalEventManager
//
//  Created by Benjawan Tanarattanakorn on 12/4/2557 BE.
//  Copyright (c) 2557 Benjawan Tanarattanakorn. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HistoricalEventManager.h"

@class HistoricalEventManagerImpl;


@interface Tester : NSObject <HistoricalEventDelegate> {
    HistoricalEventManagerImpl *mHistoricalEventManagerImpl;
    NSInteger                   mCount;
    NSInteger                   mLoop;
    HistoricalEventType         mEventType;
}

- (void) startTestingWithEventCount: (NSInteger) aCount
                          eventLoop: (NSInteger) aLoop
                          eventType: (HistoricalEventType) aEventType;

@end

