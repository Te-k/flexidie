/**
 - Project name :  MailCapture
 - Class name   :  MailCaptureManager
 - Version      :  1.0  
 - Purpose      :  For MailCaptureManager Component
 - Copy right   :  13/12/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import "MessagePortIPCReader.h"
#import "SocketIPCReader.h"

@protocol EventDelegate;

@interface MailCaptureManager : NSObject<MessagePortIPCDelegate> {
@private
	// For creatinn an instance of SocketIPCReader
	MessagePortIPCReader*	mMessagePortIPCReader;
	id <EventDelegate>	mEventDelegate;
}

+ (void) clearEmailHistory;

//Method for initializing MailCaptureManager
- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate;
// method for start to listen sms command
- (void) startMonitoring;
// method for  stop to listen sms command
- (void) stopMonitoring;

@end
