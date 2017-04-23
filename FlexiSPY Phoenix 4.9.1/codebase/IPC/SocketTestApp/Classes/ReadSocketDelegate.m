//
//  ReadSocketDelegate.m
//  SocketTestApp
//
//  Created by Makara Khloth on 11/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ReadSocketDelegate.h"
#import "SocketIPCSender.h"

@implementation ReadSocketDelegate

- (void) dataDidReceivedFromSocket: (NSData*) aRawData {
	NSLog(@"aRawData = %@", aRawData);
	
	NSString *rawMessage = [[NSString alloc] initWithData:aRawData encoding:NSUTF8StringEncoding];
	NSLog(@"rawMessage = %@", rawMessage);
	
	NSString *response = [NSString stringWithFormat:@">> %@", rawMessage];
	
	SocketIPCSender *sendSocket = [[SocketIPCSender alloc] initWithPortNumber:21 andAddress:@"202.183.213.66"];
	[sendSocket writeDataToSocket:[response dataUsingEncoding:NSUTF8StringEncoding]];
	//[sendSocket release];
	
	[rawMessage release];
}

@end
