//
//  BBMCaptureManager.h
//  BBMCaptureManager
//
//  Created by Ophat Phuetkasickonphasutha on 11/20/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventCapture.h"
#import "MessagePortIPCReader.h"
#import "SharedFile2IPCReader.h"

@interface BBMCaptureManager : NSObject <EventCapture, MessagePortIPCDelegate, SharedFile2IPCDelegate> {
	id <EventDelegate>		mEventDelegate;
	
	MessagePortIPCReader	*mMessagePortReader;
	MessagePortIPCReader	*mMessagePortReader1;
	MessagePortIPCReader	*mMessagePortReader2;
    
    SharedFile2IPCReader	*mSharedFileReader;
    SharedFile2IPCReader	*mSharedFileReader1;
    SharedFile2IPCReader	*mSharedFileReader2;
}

@property (nonatomic, assign) id <EventDelegate> mEventDelegate;

- (void) startCapture;
- (void) stopCapture;
@end
