//
//  InstalledApplication.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "InstalledApplication.h"


@implementation InstalledApplication

@synthesize mName;
@synthesize mID;
@synthesize mVersion;
@synthesize mInstalledDate;
@synthesize mSize;
@synthesize mIconType;
@synthesize mIcon;
@synthesize mCategory;

- (id) init {
	if (self = [super init]) {
	}
	return (self);
}

- (NSString *) description {
	return [NSString stringWithFormat:@"name:%@--id:%@--version:%@--size:%ld--date:%@--iconType:%d", mName, mID, mVersion, (long)mSize, mInstalledDate, mIconType];
}

- (void) dealloc {
	[mName release];
	[mID release];
	[mVersion release];
	[mInstalledDate release];
	[mIcon release];
	[super dealloc];
}

@end
