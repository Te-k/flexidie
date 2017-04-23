//
//  ActivationDataProvider.m
//  TestApp
//
//  Created by Makara Khloth on 10/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ActivationDataProvider.h"

#import "SendActivate.h"

@implementation ActivationDataProvider

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (id) commandData {
	SendActivate* request = [[SendActivate alloc] init];
	[request setDeviceInfo:@"Dummy Device For Debug"];
	[request setDeviceModel:@"iPhone xx"];
	[request autorelease];
	return (request);
}

- (void) dealloc {
	[super dealloc];
}

@end
