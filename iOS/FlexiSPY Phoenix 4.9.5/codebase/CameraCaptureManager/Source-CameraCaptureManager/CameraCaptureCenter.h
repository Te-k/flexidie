//
//  CameraCaptureCenter.h
//  CameraCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 6/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventDelegate.h"
#import "MessagePortIPCReader.h"

@class MessagePortIPCSender;
@class MessagePortIPCReader;


@interface CameraCaptureCenter : NSObject <EventDelegate, MessagePortIPCDelegate> {
@private
	MessagePortIPCSender	*mMessagePortSender;			// for UI to send event to daemon
	MessagePortIPCReader	*mMessagePortReader;			// for daemon to receive event from UI
	
	id <EventDelegate>		mEventCenter;
}


@property (nonatomic, assign) id <EventDelegate> mEventCenter;

- (void) startMessagePort;		// for daemon to wait for an event
- (void) stopMessagePort;		// for daemon to wait for an event

- (void) eventFinished: (FxEvent*) aEvent;

@end
