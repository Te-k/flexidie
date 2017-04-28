//
//  PanicButton.m
//  Source-PanicButtonInterface
//
//  Created by Dominique  Mayrand on 11/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PanicButton.h"
#import "PanicButtonPriv.h"
#import "DefStd.h"
#import "DebugStatus.h"

@interface PanicButton (PRIVATE) <SocketIPCDelegate>

@end

@implementation PanicButton

@synthesize delegate;

-(id) init
{
	self = [super init];
	if(self)
	{
		mSocketReader = [[SocketIPCReader alloc] initWithPortNumber:kMSPanicButtonSocketPort andAddress:kLocalHostIP withSocketDelegate:self];
		if(mSocketReader)
		{
			[mSocketReader start];
		}
	}
	
	return self;
}

- (void) start {
	[mSocketReader start];
}

- (void) stop {
	[mSocketReader stop];
}

- (void) dataDidReceivedFromSocket: (NSData*) aRawData {
	@try{
		NSString* string = [[NSString alloc] initWithData:aRawData encoding:NSUTF8StringEncoding];
		DLog(@"Panic message is: %@", string);
		[string release];
		if(delegate)
		{
			[[self delegate] PanicButtonTriggered];
		}
	}@catch (NSException* ex) {
		DLog(@"Receive panic dada exception: %@",[ex reason])
	}
	
	
	
}

- (void) dealloc {
	[mSocketReader release];
	[super dealloc];
}
	
@end
