//
//  MobileSubstrateDummy.m
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 6/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MobileSubstrateDummy.h"
#import "MessagePortIPCReader.h"
#import "DeviceLockOption.h"
#import "DeviceLockUtils.h"
#import "MessagePortIPCReader.h"
#import "DefStd.h"

@implementation MobileSubstrateDummy

- (void) start {
	DLog (@"start")
	if (!mMessagePortReader) {
		DLog(@"create message port reader")
		mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:kAlertMessagePort 
												 withMessagePortIPCDelegate:self];
		[mMessagePortReader start];
	}
}

- (void) stop {
	DLog (@"stop")
	if (mMessagePortReader) {
		[mMessagePortReader stop];
		[mMessagePortReader release];
		mMessagePortReader = nil;
	}
}

/**
 - Method name:						dataDidReceivedFromSocket
 - Purpose:							Callback function when data is received via message port
 - Argument list and description:	aRawData, the received data
 - Return description:				No return type
 */
- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	DLog (@">>>>>>>>>>>>>>>> data did receive")
	AlertCommand alertCommand;
	[aRawData getBytes:&alertCommand length:sizeof(NSInteger)];
	
	NSInteger sizeOfContentString = 0;
	NSRange range = NSMakeRange(sizeof(NSInteger), sizeof(NSInteger));	
	[aRawData getBytes:&sizeOfContentString range:range];
	
	range = NSMakeRange(sizeof(NSInteger) + sizeof(NSInteger), sizeOfContentString);	
	NSData *contentStringData = [aRawData subdataWithRange:range];		
	NSString *contentString = [[NSString alloc] initWithData:contentStringData 
													encoding:NSUTF8StringEncoding];
	
	DLog (@"AlertCommand %d", alertCommand)
	DLog (@"content string %@", contentString)
}

@end
