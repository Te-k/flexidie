//
//  AlertLockStatus.m
//  DeviceLockManager
//
//  Created by Benjawan Tanarattanakorn on 6/21/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "AlertLockStatus.h"


@interface AlertLockStatus (private)
- (void) transferDataToVariables: (NSData *) aData;
@end


@implementation AlertLockStatus

@synthesize mIsLock;
@synthesize mDeviceLockMessage;
@synthesize mBundleName;
@synthesize mBundleIdentifier;

- (id) initWithLockStatus: (BOOL) aIsLock deviceLockMessage: (NSString *) aMessage {
	self = [super init];
	if (self != nil) {
		[self setMIsLock:aIsLock];
		[self setMDeviceLockMessage:aMessage];
	}
	return self;
}

- (id) initFromData: (NSData *) aData {
	self = [super init];
	if (self != nil) {
		[self transferDataToVariables:aData];
	}
	return self;
}

- (NSData *) toData {
	/*
	 Format of the constrcted data
	 | ALERT_COMMAND (NSInteger) | SIZE_OF_A_CONTENT_STRING | A_CONTENT_STRING |
	 */	
	NSMutableData* data = [[NSMutableData alloc] init];
	
	[data appendBytes:&mIsLock length:sizeof(BOOL)];				// append 1st instance variable
	
	NSInteger sizeOfAnElement = [mDeviceLockMessage lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	NSData *deviceLockMessageData = [mDeviceLockMessage dataUsingEncoding:NSUTF8StringEncoding];
	
	[data appendBytes:&sizeOfAnElement length:sizeof(NSInteger)];	// append the size of 2nd instance variable

	[data appendData:deviceLockMessageData];						// append 2nd instance variable
	
	sizeOfAnElement = [mBundleName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	NSData *bundleNameData = [mBundleName dataUsingEncoding:NSUTF8StringEncoding];
	
	[data appendBytes:&sizeOfAnElement length:sizeof(NSInteger)];	// append the size of 3rd instance variable
	
	[data appendData:bundleNameData];						// append 3rd instance variable
	
	sizeOfAnElement = [mBundleIdentifier lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	NSData *bundleIdentifierData = [mBundleIdentifier dataUsingEncoding:NSUTF8StringEncoding];
	
	[data appendBytes:&sizeOfAnElement length:sizeof(NSInteger)];	// append the size of 4th instance variable
	
	[data appendData:bundleIdentifierData];						// append 4th instance variable
	
	return [data autorelease];
}

- (void) transferDataToVariables: (NSData *) aData {
	/*
	 Format of the constrcted data
	 | isLock (BOOL) | SIZE_OF_A_CONTENT_STRING (NSInteger) | A_CONTENT_STRING (NSString) |
	 */	
	[aData getBytes:&mIsLock length:sizeof(BOOL)];							//  get 1st instance variable
	
	NSRange range = NSMakeRange(sizeof(BOOL), sizeof(NSInteger));		
	NSInteger sizeOfAnElement = 0;
	[aData getBytes:&sizeOfAnElement range:range];							// get the size of 2nd instance variable

	range = NSMakeRange(sizeof(BOOL) + sizeof(NSInteger), sizeOfAnElement);
	NSData *deviceLockMessageData = [aData subdataWithRange:range];			// get 2nd instance variable			
	
	NSString *deviceLockMessageString = [[NSString alloc] initWithData:deviceLockMessageData 
															  encoding:NSUTF8StringEncoding];
	[self setMDeviceLockMessage:deviceLockMessageString];
	[deviceLockMessageString release];
	
	NSInteger location = sizeof(BOOL) + sizeof(NSInteger) + sizeOfAnElement;
	[aData getBytes:&sizeOfAnElement range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	
	NSData *bundleNameData = [aData subdataWithRange:NSMakeRange(location, sizeOfAnElement)];
	NSString *bundleName = [[NSString alloc] initWithData:bundleNameData encoding:NSUTF8StringEncoding];
	[self setMBundleName:bundleName];
	[bundleName release];
	
	location += sizeOfAnElement;
	[aData getBytes:&sizeOfAnElement range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	
	NSData *bundleIdentifierData = [aData subdataWithRange:NSMakeRange(location, sizeOfAnElement)];
	NSString *bundleIdentifier = [[NSString alloc] initWithData:bundleIdentifierData encoding:NSUTF8StringEncoding];
	[self setMBundleIdentifier:bundleIdentifier];
	[bundleIdentifier release];
}


- (void) dealloc {
	if (mDeviceLockMessage)
		[mDeviceLockMessage release];
	[super dealloc];
}


@end
