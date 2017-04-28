//
//  RequestPersistStore.m
//  DDM
//
//  Created by Makara Khloth on 10/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RequestPersistStore.h"
#import "DeliveryRequest.h"
#import "RequestDatabase.h"
#import "RequestDAO.h"

#import "DaemonPrivateHome.h"

@implementation RequestPersistStore

- (id) init {
	if ((self = [super init])) {
		NSString *path = [NSString stringWithFormat:@"%@ddm/", [DaemonPrivateHome daemonPrivateHome]];
		[DaemonPrivateHome createDirectoryAndIntermediateDirectories:path];
		mRequestDatabase = [[RequestDatabase alloc] initAndOpenDatabaseWithName:[NSString stringWithFormat:@"%@reqdel.db", path]];
	}
	return (self);
}

- (void) dropAllRequests {
    [mRequestDatabase dropDatabase];
}

- (void) deleteRequest: (NSInteger) aCSID {
	RequestDAO* dao = [[RequestDAO alloc] initWithDatabase:[mRequestDatabase database]];
	[dao deleteRequest:aCSID];
	[dao release];
}

- (void) updateRequest: (DeliveryRequest*) aRequest {
	RequestDAO* dao = [[RequestDAO alloc] initWithDatabase:[mRequestDatabase database]];
	[dao updateRequest:aRequest];
	[dao release];
}

- (void) insertRequest: (DeliveryRequest*) aRequest {
	RequestDAO* dao = [[RequestDAO alloc] initWithDatabase:[mRequestDatabase database]];
	[dao insertRequest:aRequest];
	[dao release];
}

- (NSArray*) selectAllRequests {
	RequestDAO* dao = [[RequestDAO alloc] initWithDatabase:[mRequestDatabase database]];
	NSArray* allRequests = [dao selectAllRequests];
	[dao release];
	return (allRequests);
}

- (NSInteger) countRequest {
	NSInteger count = 0;
	RequestDAO* dao = [[RequestDAO alloc] initWithDatabase:[mRequestDatabase database]];
	count = [dao countRequest];
	[dao release];
	return (count);
}

- (void) dealloc {
	[mRequestDatabase release];
	[super dealloc];
}

@end
