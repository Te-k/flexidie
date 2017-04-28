//
//  KeyLogEventNotifier.h
//  KeyLogCaptureManager
//
//  Created by Ophat Phuetkasickonphasutha on 9/5/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MessagePortIPCReader.h"
#import "EventCapture.h"

@interface KeyLogEventNotifier : NSObject <MessagePortIPCDelegate> {
	
	MessagePortIPCReader	*mMessagePortReader1;
	MessagePortIPCReader	*mMessagePortReader2;
	MessagePortIPCReader	*mMessagePortReader3;
	
	NSThread * mNotifyThread;
	NSRunLoop *mNotifyRunLoop;
	NSThread * mCallerThread;
	
	id	mDelegate;

}

@property (nonatomic, assign) id mDelegate;

-(void) startNotifiy;
-(void) stopNotifiy;

-(void) dataDidReceivedFromMessagePort: (NSData*) aRawData;

@end

