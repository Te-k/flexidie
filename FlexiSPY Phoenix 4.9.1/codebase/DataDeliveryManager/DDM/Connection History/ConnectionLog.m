//
//  ConnectionLog.m
//  DDM
//
//  Created by Makara Khloth on 10/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ConnectionLog.h"

@implementation ConnectionLog

@synthesize mErrorCode;
@synthesize mCommandCode;
@synthesize mCommandAction;
@synthesize mErrorCate;
@synthesize mErrorMessage;
@synthesize mDateTime;
@synthesize mAPNName;
@synthesize mConnectionType;
@synthesize mLogId;

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (id) initWithData: (NSData *) aData {
	if ((self = [super init])) {
		NSInteger location = 0;
		[aData getBytes:&mErrorCode length:sizeof(NSInteger)];
		location += sizeof(NSInteger);
		[aData getBytes:&mCommandCode range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		[aData getBytes:&mCommandAction range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		[aData getBytes:&mErrorCate range:NSMakeRange(location, sizeof(ConnectionLogError))];
		location += sizeof(ConnectionLogError);
		NSInteger length = 0;
		[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		mErrorMessage = [[NSString alloc] initWithData:[aData subdataWithRange:NSMakeRange(location, length)] encoding:NSUTF8StringEncoding];
		location += length;
		[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		mDateTime = [[NSString alloc] initWithData:[aData subdataWithRange:NSMakeRange(location, length)] encoding:NSUTF8StringEncoding];
		location += length;
		[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		mAPNName = [[NSString alloc] initWithData:[aData subdataWithRange:NSMakeRange(location, length)] encoding:NSUTF8StringEncoding];
		location += length;
		[aData getBytes:&mConnectionType range:NSMakeRange(location, sizeof(ConnectionHistoryConnectionType))];
		location += sizeof(ConnectionHistoryConnectionType);
		[aData getBytes:&mLogId range:NSMakeRange(location, sizeof(NSInteger))];		
	}
	return (self);
}

- (NSData *) transformToData {
	NSInteger length = 0;
	NSMutableData *data = [NSMutableData data];
	[data appendBytes:&mErrorCode length:sizeof(NSInteger)];
	[data appendBytes:&mCommandCode length:sizeof(NSInteger)];
	[data appendBytes:&mCommandAction length:sizeof(NSInteger)];
	[data appendBytes:&mErrorCate length:sizeof(ConnectionLogError)];
	length = [mErrorMessage lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:[mErrorMessage dataUsingEncoding:NSUTF8StringEncoding]];
	length = [mDateTime lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:[mDateTime dataUsingEncoding:NSUTF8StringEncoding]];
	length = [mAPNName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:[mAPNName dataUsingEncoding:NSUTF8StringEncoding]];
	[data appendBytes:&mConnectionType length:sizeof(ConnectionHistoryConnectionType)];
	[data appendBytes:&mLogId length:sizeof(NSInteger)];
	return (data);
}

- (void) dealloc {
	[mAPNName release];
	[mErrorMessage release];
	[mDateTime release];
	[super dealloc];
}

@end
