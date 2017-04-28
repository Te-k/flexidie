//
//  GetBinaryResponse.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 6/21/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "GetBinaryResponse.h"


@implementation GetBinaryResponse

@synthesize mBinaryName, mCRC32, mBinary;

- (void) dealloc {
	[mBinaryName release];
	[mBinary release];
	[super dealloc];
}

@end
