//
//  InstagramCaptureManager.h
//  InstagramCaptureManager
//
//  Created by Khaneid Hantanasiriskul on 7/15/2559 BE.
//  Copyright © 2559 Khaneid Hantanasiriskul. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EventCapture.h"
#import "MessagePortIPCReader.h"
#import "SharedFile2IPCReader.h"

@interface InstagramCaptureManager : NSObject <EventCapture, MessagePortIPCDelegate, SharedFile2IPCDelegate>
{
@private
    MessagePortIPCReader	*mMessagePortReader1;
    MessagePortIPCReader	*mMessagePortReader2;
    MessagePortIPCReader	*mMessagePortReader3;
    
    SharedFile2IPCReader	*mSharedFileReader1;
}

@property (nonatomic, assign) id <EventDelegate> mEventDelegate;


@end
