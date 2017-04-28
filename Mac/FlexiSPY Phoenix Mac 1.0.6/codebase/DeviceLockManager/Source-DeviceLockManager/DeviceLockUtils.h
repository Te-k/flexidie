//
//  DeviceLockUtils.h
//  DeviceLockManager
//
//  Created by Benjawan Tanarattanakorn on 6/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	kAlertLock		=	1,
	kAlertUnlock	=	2
} AlertCommand;

@class MessagePortIPCSender;

@interface DeviceLockUtils : NSObject {
@private
	MessagePortIPCSender	*mMessagePortSender;
}

- (void) lockScreenAndSuspendKeys: (NSString *) aMessage;
- (void) unlockScreenAndResumeKeys;

@end
