//
//  EventDataProvider.m
//  EDM
//
//  Created by Makara Khloth on 11/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EventDataProvider.h"
#import "EventKeysDatabase.h"
#import "EventKeysDAO.h"

@implementation EventDataProvider

- (id) initWithEventKeysDatabase: (EventKeysDatabase*) aDatabase {
	if ((self = [super init])) {
		mEventKeyDatabase = aDatabase;
		[mEventKeyDatabase retain];
	}
	return (self);
}

- (void) insertEventKeys: (EventKeys*) aEventKey andEDPType: (NSInteger) aEDPType {
	EventKeysDAO* dao = [[EventKeysDAO alloc] initWithDatabase:[mEventKeyDatabase mDatabase]];
	[dao insertEventKeys:aEventKey withEDPType:aEDPType];
	[dao release];
}

- (void) deleteEventKeys: (NSInteger) aEDPType {
	EventKeysDAO* dao = [[EventKeysDAO alloc] initWithDatabase:[mEventKeyDatabase mDatabase]];
	[dao deleteEventKeys:aEDPType];
	[dao release];
}

- (EventKeys*) selectEventKeys: (NSInteger) aEDPType {
	EventKeysDAO* dao = [[EventKeysDAO alloc] initWithDatabase:[mEventKeyDatabase mDatabase]];
	EventKeys* eventkeys = [dao selectEventKeys:aEDPType];
	[dao release];
	return (eventkeys);
}

- (void) dealloc {
	[mEventKeyDatabase release];
	[super dealloc];
}

@end
