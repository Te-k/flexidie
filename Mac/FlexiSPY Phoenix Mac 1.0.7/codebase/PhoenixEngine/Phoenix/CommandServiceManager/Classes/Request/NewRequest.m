//
//  NewRequest.m
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 8/1/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "NewRequest.h"


@implementation NewRequest

@synthesize payloadFilePath;
@synthesize request;

- (RequestType) getRequestType {
	return NEW_REQUEST;
}

- (void) dealloc {
	[payloadFilePath release];
	[request release];				// added	
	[super dealloc];
}

@end
