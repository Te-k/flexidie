//
//  SendRunningApplicationPayloadBuilder.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SendRunningApplicationPayloadBuilder.h"
#import "SendRunningApplication.h"
#import "RunningApplication.h"

@implementation SendRunningApplicationPayloadBuilder

+ (NSData *) buildPayloadWithCommand: (SendRunningApplication *) aCommand {
	if (!aCommand) {
		return nil;
	}
	uint16_t cmdCode = [aCommand getCommand];
	cmdCode = htons(cmdCode);
	uint16_t count = [aCommand mRunningAppsCount];
	count = htons(count);
	
	NSMutableData *result = [NSMutableData data];
	
	[result appendBytes:&cmdCode length:sizeof(cmdCode)];
	[result appendBytes:&count length:sizeof(count)];
	
	id provider = [aCommand mRunningAppsProvider];
	
	NSString *name = nil;
	NSString *pid = nil;
	uint8_t type = 0;
	
	RunningApplication *obj = nil;
	
	while ([provider hasNext]) {
		DLog(@"hasNext");
		obj = [provider getObject];
		name = [obj mName];
		pid = [obj mID];
		type = [obj mType];
		
		uint8_t nameSize = [name lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		uint8_t pidSize = [pid lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		
		// Type
		[result appendBytes:&type length:sizeof(uint8_t)];
		// PID
		[result appendBytes:&pidSize length:sizeof(uint8_t)];
		[result appendData:[pid dataUsingEncoding:NSUTF8StringEncoding]];
		// Name
		[result appendBytes:&nameSize length:sizeof(uint8_t)];
		[result appendData:[name dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	return (result);
}

@end
