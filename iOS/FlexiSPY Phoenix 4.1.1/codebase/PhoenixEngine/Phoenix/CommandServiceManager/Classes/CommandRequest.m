//
//  CommandRequest.m
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 7/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "CommandRequest.h"

@implementation CommandRequest

@synthesize commandData;
@synthesize delegate;
@synthesize metaData;
@synthesize priority;

- (void) dealloc {
	[commandData release];
	[delegate release];
	[metaData release];
	[super dealloc];
}

@end
