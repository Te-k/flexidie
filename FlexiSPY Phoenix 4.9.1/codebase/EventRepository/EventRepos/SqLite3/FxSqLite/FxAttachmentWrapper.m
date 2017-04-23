//
//  FxAttachmentWrapper.m
//  FxSqLite
//
//  Created by Makara Khloth on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FxAttachmentWrapper.h"
#import "FxAttachment.h"

@implementation FxAttachmentWrapper

- (id) init {
	if (self = [super init]) {
		emailId = 0;
		mmsId = 0;
	}
	return (self);
}

- (void) dealloc {
	[attachment release];
	[super dealloc];
}

@synthesize attachment;
@synthesize emailId;
@synthesize mmsId;
@synthesize mIMID;

@end
