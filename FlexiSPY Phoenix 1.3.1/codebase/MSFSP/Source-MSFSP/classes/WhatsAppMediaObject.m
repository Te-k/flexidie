//
//  WhatsAppMediaObject.m
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 4/10/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "WhatsAppMediaObject.h"


@implementation WhatsAppMediaObject

@synthesize mImage;
@synthesize mThumbnailData;
@synthesize mMessageID;
@synthesize mVideoUrl;

- (void) dealloc {
	[self setMImage:nil];
	[self setMThumbnailData:nil];
	[self setMMessageID:nil];
	[self setMVideoUrl:nil];
	[super dealloc];
}

- (NSString *) description {
	return [NSString stringWithFormat:@"message id: %@ image: %@ thumbnail size: %d video path %@", [self mMessageID], 
			[self mImage],
			[[self mThumbnailData] length],
			[self mVideoUrl]
	];
}

@end
