//
//  main.m
//  SocketTestApp
//
//  Created by Makara Khloth on 11/15/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SocketIPCReader.h"
#import "SocketIPCSender.h"

#import "ReadSocketDelegate.h"

int main(int argc, char *argv[]) {
    
//    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
//    int retVal = UIApplicationMain(argc, argv, nil, nil);
//    [pool release];
//    return retVal;
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	
	// Sending
	NSString *hello = @"Hello, Iphone 3GS";
	SocketIPCSender *sendSocket = [[SocketIPCSender alloc] initWithPortNumber:21 andAddress:@"202.183.213.66"];
	[sendSocket writeDataToSocket:[hello dataUsingEncoding:NSUTF8StringEncoding]];
	[sendSocket release];
    
	// Waiting
	ReadSocketDelegate *delegate = [[ReadSocketDelegate alloc] init];
	SocketIPCReader *readSocket = [[SocketIPCReader alloc] initWithPortNumber:21
																   andAddress:@"127.0.0.1" 
														   withSocketDelegate:delegate];
	[readSocket start];
	
	CFRunLoopRun();
	
	[readSocket release];
	[delegate release];
	
    [pool release];
	
    return 0;
}
