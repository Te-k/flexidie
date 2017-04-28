//
//  NoteACCapture.h
//  ActivationCodeCapture
//
//  Created by Makara Khloth on 12/21/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MessagePortIPCReader.h"

@protocol ActivationCodeCaptureDelegate;

@interface NoteACCapture : NSObject <MessagePortIPCDelegate> {
@private
	id <ActivationCodeCaptureDelegate>	mDelegate;
	
	MessagePortIPCReader	*mReader;
	NSString *mAC;
}

@property (nonatomic, copy) NSString *mAC;

- (id) initWithDelegate: (id <ActivationCodeCaptureDelegate>) aDelegate;

- (void) start;
- (void) stop;

@end
