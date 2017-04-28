//
//  PageVisitedCaptureManager.h
//  PageVisitedCaptureManager
//
//  Created by Ophat Phuetkasickonphasutha on 10/2/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EventCapture.h"
#import "PageVisitedDelegate.h"

@protocol EventDelegate;
@class PageVisitedNotifier;

@interface PageVisitedCaptureManager : NSObject<EventCapture, PageVisitedDelegate> {
@private
    id <EventDelegate>   mEventDelegate;
    PageVisitedNotifier * mPageVisitedNotifier;
}

@property (nonatomic, assign) id <EventDelegate> mEventDelegate;
@property (nonatomic, retain) PageVisitedNotifier * mPageVisitedNotifier;

-(void) registerEventDelegate:(id <EventDelegate>) aEventDelegate;
-(void) unregisterEventDelegate;
-(void) startCapture;
-(void) stopCapture;


@end
