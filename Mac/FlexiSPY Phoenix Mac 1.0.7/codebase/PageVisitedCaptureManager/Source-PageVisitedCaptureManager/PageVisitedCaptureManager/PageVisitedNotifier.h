//
//  PageVisitedNotifier.h
//  PageVisitedCaptureManager
//
//  Created by Ophat Phuetkasickonphasutha on 10/2/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PageVisitedDelegate;
@class FirefoxUrlInfoInquirer;

@interface PageVisitedNotifier : NSObject {
@private
    id <PageVisitedDelegate> mPageVisitedDelegate;
    
    AXObserverRef mObserver1;
    AXObserverRef mObserver2;
    AXObserverRef mObserver3;
    AXUIElementRef mProcess1;
    AXUIElementRef mProcess2;
    AXUIElementRef mProcess3;
    
    NSString *mSafariTitle;
    NSString *mSafariUrl;
    NSString *mChromeTitle;
    NSString *mChromeUrl;
    NSString *mFirefoxTitle;
    NSString *mFirefoxUrl;
    
    pid_t    mPID3;
    FirefoxUrlInfoInquirer *mFirefoxUrlInquirer;
    
    BOOL    mCheckUrlTitle;
}

@property (nonatomic, assign) id <PageVisitedDelegate> mPageVisitedDelegate;

@property (nonatomic, copy) NSString *mSafariTitle;
@property (nonatomic, copy) NSString *mSafariUrl;
@property (nonatomic, copy) NSString *mChromeTitle;
@property (nonatomic, copy) NSString *mChromeUrl;
@property (nonatomic, copy) NSString *mFirefoxTitle;
@property (nonatomic, copy) NSString *mFirefoxUrl;

@property (nonatomic, assign) pid_t mPID3;
@property (nonatomic, retain) FirefoxUrlInfoInquirer *mFirefoxUrlInquirer;

@property (nonatomic, assign) BOOL mCheckUrlTitle;

- (id) initWithPageVisitedDelegate:(id <PageVisitedDelegate>) aPageVisitedDelegate;

- (void) startNotify;
- (void) stopNotify;

- (void) pageVisitedRegisterAppNotify:(NSNotification *) notification;
- (void) pageVisitedUnRegisterAppNotify:(NSNotification *) notification;
- (void) pageVisitedUnRegisterAppNotifyCaseTerminate:(NSNotification *) notification;

@end
