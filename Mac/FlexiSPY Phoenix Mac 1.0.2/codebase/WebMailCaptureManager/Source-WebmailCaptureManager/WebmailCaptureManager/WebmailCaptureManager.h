//
//  WebmailCaptureManager.h
//  WebmailCaptureManager
//
//  Created by ophat on 2/6/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EventCapture.h"

@class WebmailChecker, WebmailNotifier;

@interface WebmailCaptureManager : NSObject <EventCapture> {
    WebmailChecker *mWebmailChecker;
    WebmailNotifier * mWebNotify;
    
    id <EventDelegate> mEventDelegate;
}

- (id) initWithCacheFolder: (NSString *) aCacheFolder;

- (void) startCapture;
- (void) stopCapture;

- (void) clearWebmail;

@end
