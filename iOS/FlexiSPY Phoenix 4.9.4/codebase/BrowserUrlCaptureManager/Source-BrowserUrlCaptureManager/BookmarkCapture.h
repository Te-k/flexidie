//
//  BookmarkCapture.h
//  BrowserUrlCaptureManager
//
//  Created by Suttiporn Nitipitayanusad on 4/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessagePortIPCReader.h"
#import "SharedFile2IPCReader.h"

@protocol EventDelegate;

@interface BookmarkCapture : NSObject <MessagePortIPCDelegate, SharedFile2IPCDelegate> {
@private
	MessagePortIPCReader	*mMessagePortReader;
	
	SharedFile2IPCReader	*mSharedFileReader;
	
	id <EventDelegate>		mEventDelegate;
}

- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate;
- (void) startCapture;
- (void) stopCapture;

@end
