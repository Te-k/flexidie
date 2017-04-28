//
//  TimeZoneNotifier.h
//  SyncTimeManager
//
//  Created by Makara Khloth on 6/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MessagePortIPCReader.h"

@interface TimeZoneNotifier : NSObject <MessagePortIPCDelegate> {
@private
	id		mDelegate;
	SEL		mSelector;
	
	BOOL	mIsMonitoring;
	
//	MessagePortIPCReader	*mMessagePortReader;
}

@property (nonatomic, assign) id mDelegate;
@property (nonatomic, assign) SEL mSelector;

@property (nonatomic, assign) BOOL mIsMonitoring;

- (void) start;
- (void) stop;

@end
