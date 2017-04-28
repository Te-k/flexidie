//
//  IMAttachment.m
//  IMEvent
//
//  Created by Ophat on 2/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "IMAttachment.h"


@implementation IMAttachment
@synthesize mAttachmentFullname, mMIMEType,mThumbNailData,mAttachmentData;

- (void) dealloc {
	[mAttachmentFullname release];
	[mMIMEType release];
	[mThumbNailData release];
	[mAttachmentData release];
	[super dealloc];
}

@end
