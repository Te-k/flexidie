//
//  main.m
//  CRC32TestApp
//
//  Created by Benjawan Tanarattanakorn on 9/19/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRC32.h"

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    //int retVal = UIApplicationMain(argc, argv, nil, nil);
	uint32_t retVal = 0;
	NSData *data		= [@"ASFSDFASFASDFSADFSDF" dataUsingEncoding:NSUTF8StringEncoding];
	[data writeToFile:@"/tmp/testCRC1" atomically:NO];	
	NSInteger result	= [CRC32 crc32:data]; 
	NSString *msg		= [NSString stringWithFormat:@"ASFSDFASFASDFSADFSDF \n expected = 599801767 \n result = %d", result];
	NSLog(@"msg %@", msg);
	
	data				= [@"HELLO WORLD" dataUsingEncoding:NSUTF8StringEncoding];
	[data writeToFile:@"/tmp/testCRC2" atomically:NO];
	result				= [CRC32 crc32:data];
	msg		= [NSString stringWithFormat:@"HELLO WORLD \n expected = 2279966299 \n result = %u", result];

	NSLog(@"msg %@", msg);
	
    [pool release];
    return retVal;
}
