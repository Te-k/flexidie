//
//  EventKeys.m
//  EventRepos
//
//  Created by Makara Khloth on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EventKeys.h"

@implementation EventKeys

- (id) init {
	if ((self = [super init])) {
		mEventIdDictionary = [[NSMutableDictionary alloc] init];
	}
	return (self);
}

- (void) put: (FxEventType) aEventType withEventIdArray: (NSArray*) aEventIdArray {
	[mEventIdDictionary setObject:aEventIdArray forKey:[NSNumber numberWithInt:aEventType]];
}

- (NSArray*) eventTypeArray {
	NSArray* allKey = [mEventIdDictionary allKeys];
	return (allKey);
}

- (NSArray*) eventIdArray: (FxEventType) aEventType {
	NSArray* eventIdArray = [mEventIdDictionary objectForKey:[NSNumber numberWithInt:aEventType]];
	return (eventIdArray);
}

- (NSString *) description {
	NSString *description = [NSString stringWithFormat:@"EventIdInfo = %@", mEventIdDictionary];
	return (description);
}

- (void) dealloc {
	[mEventIdDictionary release];
	[super dealloc];
}

@end
