//
//  SyncContact.m
//  AddressbookManager
//
//  Created by Makara Khloth on 6/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SyncContact.h"
#import "FxContact.h"

@interface SyncContact (private)
- (void) parseFromData: (NSData *) aData;
@end

@implementation SyncContact

@synthesize mContacts;

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (id) initFromData: (NSData *) aData {
	if (aData) {
		if ((self = [super init])) {
			[self parseFromData:aData];
		}
	}
	return (self);
}

- (NSData *) toData {
	NSMutableData *contactsData = [NSMutableData data];
	NSInteger count = [[self mContacts] count];
	[contactsData appendBytes:&count length:sizeof(NSInteger)];
	for (FxContact * contact in [self mContacts]) {
		NSInteger length = [[contact toData] length];
		[contactsData appendBytes:&length length:sizeof(NSInteger)];
		[contactsData appendData:[contact toData]];
	}
	return (contactsData);
}

- (void) parseFromData: (NSData *) aData {
	DLog (@"Parse aData = %@, [aData length] = %d", aData, [aData length])
	NSInteger location = 0;
	NSInteger count = 0;
	[aData getBytes:&count length:sizeof(NSInteger)];
	location += sizeof(NSInteger);
	NSMutableArray *allContacts = [NSMutableArray array];
	for (NSInteger i = 0; i < count; i++) {
		NSInteger length = 0;
		[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		FxContact *contact = [[FxContact alloc] initFromData:[aData subdataWithRange:NSMakeRange(location, length)]];
		[allContacts addObject:contact];
		[contact release];
		location += length;
	}
	[self setMContacts:allContacts];
}

- (void) dealloc {
	[mContacts release];
	[super dealloc];
}

@end
