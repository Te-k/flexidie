//
//  main.m
//  CRC32TestAppForMac
//
//  Created by Benjawan Tanarattanakorn on 9/19/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "CRC32.h"

int main(int argc, char *argv[])
{
	NSAutoreleasePool *pool		= [[NSAutoreleasePool alloc] init];
	/*
	 Note that 
	 */
	
	NSData *data		= [@"ASFSDFASFASDFSADFSDF" dataUsingEncoding:NSUTF8StringEncoding];
	[data writeToFile:@"/tmp/testCRC1" atomically:NO];	
	uint32_t result	= [CRC32 crc32:data]; 
	NSString *msg		= [NSString stringWithFormat:@"ASFSDFASFASDFSADFSDF \n expected = 599801767 \n result = %d", result];
	NSLog(@"msg %@", msg);
	
	if (599801767 != result)
		NSLog(@"FAIL !!!!!!!!");
	else
		NSLog(@"PASS !!!!!!!!");
	data				= [@"HELLO WORLD" dataUsingEncoding:NSUTF8StringEncoding];
	[data writeToFile:@"/tmp/testCRC2" atomically:NO];
	result				= [CRC32 crc32:data];
	msg					= [NSString stringWithFormat:@"HELLO WORLD \n expected = 2279966299 \n result = %u", result];
	NSLog(@"msg %@", msg);
	if (2279966299 != result)
		NSLog(@"FAIL !!!!!!!!");
	else
		NSLog(@"PASS !!!!!!!!");
	
	result				= [CRC32 crc32File:@"/tmp/testCRC2"];
	msg					= [NSString stringWithFormat:@"HELLO WORLD \n expected = 2279966299 \n result = %u", result];
	NSLog(@"msg %@", msg);
	if (2279966299 != result)
		NSLog(@"FAIL !!!!!!!!");
	else
		NSLog(@"PASS !!!!!!!!");

	
	int ret = NSApplicationMain(argc,  (const char **) argv);
	
	[pool drain];
    return  ret;
	
}

