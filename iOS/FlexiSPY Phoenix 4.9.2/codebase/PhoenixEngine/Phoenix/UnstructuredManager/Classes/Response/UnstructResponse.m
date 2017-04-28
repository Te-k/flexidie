//
//  UnstructResponse.m
//  PhoenixComponent
//
//  Created by Pichaya Srifar on 7/18/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "UnstructResponse.h"

@implementation UnstructResponse

@synthesize cmdEcho;
@synthesize statusCode;
@synthesize errorMsg;
@synthesize isOK;

- (UnstructResponse *) init {
	if ((self = [super init])) {
		
	}
	return self;	
}

- (void) dealloc
{
	[errorMsg release];
	[super dealloc];
}

@end
