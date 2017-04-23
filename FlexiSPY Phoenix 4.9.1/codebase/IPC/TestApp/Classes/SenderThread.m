//
//  SenderThread.m
//  TestApp
//
//  Created by Makara Khloth on 11/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SenderThread.h"

#import "SocketIPCSender.h"
#import "DefStd.h"

@interface SenderThread (private)
- (void) senderThreadMethod;

@end

@implementation SenderThread

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (void) startSendingData {
	if (!mIsRunning) {
		mSenderThread = [[NSThread alloc] initWithTarget:self selector:@selector(senderThreadMethod) object:NULL];
		[mSenderThread start];
		mIsRunning = TRUE;
	}
}

- (void) senderThreadMethod {
	@try {
		NSAutoreleasePool* autoReleasePool = [[NSAutoreleasePool alloc] init];
		mSocketSender = [[SocketIPCSender alloc] initWithPortNumber:kMSSmsReceiverSocketPort andAddress:kLocalHostIP];
		NSString* string = [NSString stringWithString:@"hello if (theSocket4)	setsockopt(CFSocketGetNative(theSocket4), SOL_SOCKET, SO_REUSEADDR, &reuseOn, sizeof(reuseOn))"
									"Copyright 2011 __MyCompanyName__. All rights reserved"];
		NSData* stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
		NSInteger stringDataLength = [stringData length];
		NSMutableData* data = [[NSMutableData alloc] init];
		[data appendBytes:&stringDataLength length:sizeof(NSInteger)];
		[data appendData:stringData];
		[mSocketSender writeDataToSocket:data];
		[data release];
		[mSocketSender release];
		[autoReleasePool release];
	}
	@catch (NSException * e) {
	}
	@finally {
	}
	mIsRunning = FALSE;
}

- (void) dealloc {
	[mSenderThread release];
	[super dealloc];
}

@end
