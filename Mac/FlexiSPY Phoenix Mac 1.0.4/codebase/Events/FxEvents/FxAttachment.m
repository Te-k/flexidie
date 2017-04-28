//
//  FxAttachment.m
//  FxEvents
//
//  Created by Makara Khloth on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FxAttachment.h"

@implementation FxAttachment

@synthesize mThumbnail;

- (id) init {
	if (self = [super init]) {
		
	}
	return (self);
}

- (id)copyWithZone:(NSZone *)zone {
	FxAttachment *me = [[[self class] allocWithZone:zone] init];
	if (me) {
		[me setDbId:[self dbId]];
		
		NSData *thumbnail = [[self mThumbnail] copyWithZone:zone];
		[me setMThumbnail:thumbnail];
		[thumbnail release];
		
		NSString *path = [[self fullPath] copyWithZone:zone];
		[me setFullPath:path];
		[path release];
	}
	return (me);
}

- (NSString *) description {
	return [NSString stringWithFormat:@"fullPath: %@ thumbnail length %lu", [self fullPath], (unsigned long)[[self mThumbnail] length]];
}
- (void) dealloc {
	[mThumbnail release];
	[fullPath release];
	[super dealloc];
}

@synthesize fullPath;
@synthesize dbId;

@end
