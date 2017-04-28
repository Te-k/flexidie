//
//  ThumbnailDelegate.m
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 12/18/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "ThumbnailDelegate.h"

#import "MediaInfo.h"
@implementation ThumbnailDelegate
- (void) thumbnailCreationDidFinished: (NSError *) aError
							mediaInfo: (MediaInfo *) aMedia
						thumbnailPath: (id) aPaths {

	NSLog(@"---Succes--- %@", aPaths);
	if (aError) {
		NSLog(@"E: %@", aError);
	}
	
	NSLog(@"media info %@" ,aMedia)	;
}

@end
