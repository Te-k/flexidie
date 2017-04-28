//
//  FxIMAccountEvent.m
//  FxEvents
//
//  Created by Makara Khloth on 1/31/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "FxIMAccountEvent.h"


@implementation FxIMAccountEvent

@synthesize mServiceID;
@synthesize mAccountID;
@synthesize mDisplayName;
@synthesize mStatusMessage;
@synthesize mPicture;

- (id) init {
	if ((self = [super init])) {
		eventType = kEventTypeIMAccount;
	}
	return (self);
}

- (void) dealloc {
	[mAccountID release];
	[mDisplayName release];
	[mStatusMessage release];
	[mPicture release];
	[super dealloc];
}

@end
