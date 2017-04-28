//
//  HistoricalEventOP.h
//  HistoricalEventManager
//
//  Created by Benjawan Tanarattanakorn on 12/3/2557 BE.
//
//

#import <Foundation/Foundation.h>
#import "HistoricalEventManager.h"

#pragma mark - Constants


#define kMaxRegularEventNumber          100                 // Obsolete


#define kHistoricalEventTypeKey         @"historicalEventTypeKey"
#define kHistoricalEventDataKey         @"historicalEventDataKey"
#define kHistoricalEventErrorKey        @"historicalEventErrorKey"

@interface HistoricalEventOP : NSOperation {
@protected
    id                      mDelegate;				// not own
    SEL                     mOPCompletedSelector;	// not own
    NSThread                *mThread;				// own
    HistoricalEventCaptureMode  mMode;              // obsolete
    NSInteger               mTotalNumber;
}

@property (nonatomic, retain) NSThread *mThread;

/*
 Obsolete
- (id) initWithDelegate: (id) aDelegate
                 thread: (NSThread *) aThread
               selector: (SEL) aSelector
                   mode: (HistoricalEventCaptureMode) aMode;
*/
- (id) initWithDelegate: (id) aDelegate
                 thread: (NSThread *) aThread
               selector: (SEL) aSelector
            totalNumber: (NSInteger) aTotalNumber;

@end
