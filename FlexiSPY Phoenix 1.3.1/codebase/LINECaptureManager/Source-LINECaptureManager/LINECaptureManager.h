//
//  LINECaptureManager.h
//  LINECaptureManager
//
//  Created by Makara Khloth on 11/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EventCapture.h"
#import "MessagePortIPCReader.h"

@interface LINECaptureManager : NSObject <EventCapture, MessagePortIPCDelegate> {
@private
	id <EventDelegate>		mEventDelegate;
	
	MessagePortIPCReader	*mMessagePortReader1;
	MessagePortIPCReader	*mMessagePortReader2;
	MessagePortIPCReader	*mMessagePortReader3;
}

@property (nonatomic, assign) id <EventDelegate> mEventDelegate;

@end
