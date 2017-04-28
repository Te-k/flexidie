//
//  BookmarkCapture.h
//  BrowserUrlCaptureManager
//
//  Created by Suttiporn Nitipitayanusad on 4/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessagePortIPCReader.h"

@protocol EventDelegate;

@interface BookmarkCapture : NSObject <MessagePortIPCDelegate> {
@private
	MessagePortIPCReader	*mMessagePortReader;
	id <EventDelegate>		mEventDelegate;
}

- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate;
- (void) startCapture;
- (void) stopCapture;

@end
