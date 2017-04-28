//
//  HistoricalEventOP.m
//  HistoricalEventManager
//
//  Created by Benjawan Tanarattanakorn on 12/3/2557 BE.
//
//

#import "HistoricalEventOP.h"


@implementation HistoricalEventOP

@synthesize mThread;

/*
 
Obsolete
 
- (id) initWithDelegate: (id) aDelegate
                 thread: (NSThread *) aThread
               selector: (SEL) aSelector
                   mode: (HistoricalEventCaptureMode) aMode {
	self = [super init];
	if (self != nil) {
		mDelegate               = aDelegate;
        [self setMThread:aThread];
        mOPCompletedSelector    = aSelector;
        mMode                   = aMode;
	}
	return self;
}
*/

- (id) initWithDelegate: (id) aDelegate
                 thread: (NSThread *) aThread
               selector: (SEL) aSelector
            totalNumber: (NSInteger) aTotalNumber {

	self = [super init];
	if (self != nil) {
		mDelegate               = aDelegate;
        [self setMThread:aThread];
        mOPCompletedSelector    = aSelector;
        mTotalNumber            = aTotalNumber;
	}
	return self;
}

- (void) dealloc {
    [mThread release];
    [super dealloc];
}

@end
