//
//  HangoutCaptureManager.h
//  HangoutCaptureManager
//
//  Created by Ophat Phuetkasickonphasutha on 3/19/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventCapture.h"
#import "MessagePortIPCReader.h"
#import "SharedFile2IPCReader.h"


@interface HangoutCaptureManager : NSObject <EventCapture, MessagePortIPCDelegate, SharedFile2IPCDelegate> {
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