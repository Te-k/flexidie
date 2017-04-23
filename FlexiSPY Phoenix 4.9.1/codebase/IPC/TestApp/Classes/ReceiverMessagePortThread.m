//
//  ReceiverMessagePortThread.m
//  TestApp
//
//  Created by Dominique  Mayrand on 12/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ReceiverMessagePortThread.h"


@implementation ReceiverMessagePortThread

- (id) init {
	if ((self = [super init])) {
		
		//char* pn = @"TOTO
		NSString* portName = [[NSString alloc ]initWithCString:"MyPort" encoding:NSASCIIStringEncoding];
		
		// - (id) initWithPortName:(NSString*) aPortName: withMessagePortIPCDelegate: (id <MessagePortIPCDelegate>) aDelegate{
		mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:portName withMessagePortIPCDelegate:self];
		
		[portName release];
	}
	return (self);
}


	
- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	NSLog(@"dataDidReceivedFromMessagePort");
	NSInteger stringLength = 0;
	[aRawData getBytes:&stringLength length:sizeof(NSInteger)];
	DLog (@"stringLength %d", stringLength)
	
	
	NSRange range = {sizeof(NSInteger), stringLength};
	DLog (@"%d, %d", range.location, range.length)
	DLog (@"aRawData %@", aRawData)
	
	NSString* string = [[NSString alloc] initWithData:[aRawData subdataWithRange:range] encoding:NSUTF8StringEncoding];
	DLog(@"%@", string);
	[string release];
}

- (void) start{
	[mMessagePortReader start];
}

- (void) stop{
	[mMessagePortReader stop];
}

- (void) dealloc {
	[mMessagePortReader release];
	[super dealloc];
}
	

@end
