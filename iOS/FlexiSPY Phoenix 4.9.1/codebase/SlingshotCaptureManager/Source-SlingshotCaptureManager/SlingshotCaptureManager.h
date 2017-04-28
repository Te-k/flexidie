//
//  SlingshotCaptureManager.h
//  SlingshotCaptureManager
//
//  Created by Makara on 7/22/14.
//  Copyright (c) 2014 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EventCapture.h"
#import "MessagePortIPCReader.h"
#import "SharedFile2IPCReader.h"

@interface SlingshotCaptureManager : NSObject <EventCapture, MessagePortIPCDelegate, SharedFile2IPCDelegate> {
@private
	id <EventDelegate>		mEventDelegate;
	
	MessagePortIPCReader	*mMessagePortReader;
	MessagePortIPCReader	*mMessagePortReader1;
	MessagePortIPCReader	*mMessagePortReader2;
	
	SharedFile2IPCReader	*mSharedFileReader1;
}

@property (nonatomic, assign) id <EventDelegate> mEventDelegate;

- (void) startCapture;
- (void) stopCapture;

@end