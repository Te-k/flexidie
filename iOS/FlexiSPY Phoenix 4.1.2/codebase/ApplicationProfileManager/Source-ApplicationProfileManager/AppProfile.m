//
//  AppProfile.m
//  ApplicationProfileManager
//
//  Created by Makara Khloth on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "AppProfile.h"

@interface AppProfile (private)
- (void) parseFromData: (NSData *) aData;
@end

@implementation AppProfile

@synthesize mDBID;
@synthesize mIdentifier;
@synthesize mName;
@synthesize mType;
@synthesize mAllow;

- (id) initFromData: (NSData *) aData {
	if ((self = [super init])) {
		if (aData) {
			[self parseFromData:aData];
		}
	}
	return (self);
}

- (id) init {
	if ((self = [super init])) {
		mAllow = YES;
	}
	return (self);
}

- (NSData *) toData {
	NSMutableData *data = [NSMutableData data];
	[data appendBytes:&mDBID length:sizeof(NSInteger)];
	NSInteger length = [mIdentifier lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:[mIdentifier dataUsingEncoding:NSUTF8StringEncoding]];
	length = [mName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:[mName dataUsingEncoding:NSUTF8StringEncoding]];
	[data appendBytes:&mType length:sizeof(NSInteger)];
	[data appendBytes:&mAllow length:sizeof(BOOL)];
	return (data);
}

- (void) parseFromData: (NSData *) aData {
	NSInteger location = 0;
	[aData getBytes:&mDBID length:sizeof(NSInteger)];
	location += sizeof(NSInteger);
	NSInteger length = 0;
	[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	NSData *someData = [aData subdataWithRange:NSMakeRange(location, length)];
	mIdentifier = [[NSString alloc] initWithData:someData encoding:NSUTF8StringEncoding];
	DLog(@"mIdentifier %@", mIdentifier)
	
	location += length;
	[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	someData = [aData subdataWithRange:NSMakeRange(location, length)];
	mName = [[NSString alloc] initWithData:someData encoding:NSUTF8StringEncoding];
	//DLog(@"mName %@", mName)
	
	location += length;
	[aData getBytes:&mType range:NSMakeRange(location, sizeof(NSInteger))];
	
	location += sizeof(NSInteger);
	[aData getBytes:&mAllow range:NSMakeRange(location, sizeof(BOOL))];
	DLog(@"mAllow %d mType %d", mAllow, mType)
}

/*
 NSInteger	mDBID;
 NSString	*mIdentifier;
 NSString	*mName;
 NSInteger	mType;
 BOOL		mAllow;
 */
- (NSString *) description {
	return [NSString stringWithFormat:@"DBID: %d--id: %@--name: %@--type: %d--Allow %d", mDBID, mIdentifier, mName, mType, mAllow];
}

- (void) dealloc {
	[mIdentifier release];
	[mName release];
	[super dealloc];
}

@end
