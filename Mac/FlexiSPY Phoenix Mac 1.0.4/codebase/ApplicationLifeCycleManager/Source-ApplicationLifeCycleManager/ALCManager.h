//
//  ALCManager.h
//  ALCManager
//
//  Created by Makara Khloth on 9/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MessagePortIPCReader.h"

@protocol EventDelegate;

@interface ALCManager : NSObject <MessagePortIPCDelegate> {
@private
	id <EventDelegate>	mEventDelegate; // Not own
	
	MessagePortIPCReader	*mMessagePortReader;
	BOOL	mIsMonitoring;
}

- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate;

- (void) startMonitor;
- (void) stopMonitor;

@end
