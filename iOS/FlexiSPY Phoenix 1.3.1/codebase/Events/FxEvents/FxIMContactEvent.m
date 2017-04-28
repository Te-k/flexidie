//
//  FxIMContactEvent.m
//  FxEvents
//
//  Created by Makara Khloth on 1/31/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "FxIMContactEvent.h"


@implementation FxIMContactEvent

@synthesize mContactID;

- (id) init {
	if ((self = [super init])) {
		eventType = kEventTypeIMContact;
	}
	return (self);
}

- (NSString *) description {
	return [NSString stringWithFormat:@"Contact picture size: %d, display name: %@", [[self mPicture] length], [self mDisplayName]];
}

- (void) dealloc {
	[mContactID release];
	[super dealloc];
}

@end
