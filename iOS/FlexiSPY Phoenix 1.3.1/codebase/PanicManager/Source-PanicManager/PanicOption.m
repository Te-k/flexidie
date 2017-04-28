//
//  PanicOption.m
//  PanicManager
//
//  Created by Makara Khloth on 6/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PanicOption.h"

@implementation PanicOption

@synthesize mEnableSound;
@synthesize mLocationInterval;
@synthesize mImageCaptureInterval;
@synthesize mStartMessageTemplate;
@synthesize mStopMessageTemplate;
@synthesize mPanicingMessageTemplate;
@synthesize mPanicLocationUndetermineTemplate;

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (NSString *) description {
	NSString *des = [NSString stringWithFormat:@"mEnableSound = %d, mLocationInterval = %d, mImageCaptureInterval = %d, "
										"mStartMessageTemplate = %@, mStopMessageTemplate = %@, mPanicingMessageTemplate = %@",
										[self mEnableSound], [self mLocationInterval], [self mImageCaptureInterval], [self mStartMessageTemplate],
					 [self mStopMessageTemplate], [self mPanicingMessageTemplate]];
	return (des);
}

- (void) dealloc {
	[mStartMessageTemplate release];
	[mStopMessageTemplate release];
	[mPanicingMessageTemplate release];
	[super dealloc];
}

@end
