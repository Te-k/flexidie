//
//  ResumeRequest.m
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 8/1/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "ResumeRequest.h"


@implementation ResumeRequest

@synthesize delegate;
@synthesize session;

- (RequestType) getRequestType {
	return RESUME_REQUEST;
}

- (void) dealloc
{
	[delegate release];
	[session release];
	[super dealloc];
}


@end
