//
//  StringTestClass.m
//  TestApp
//
//  Created by Makara Khloth on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StringTestClass.h"


@implementation StringTestClass

@synthesize hello;
@synthesize world;

- (id) init
{
	if (self = [super init])
	{
	}
	return (self);
}

- (void) dealloc
{
	[hello release];
	[world release];
	[super dealloc];
}

@end
