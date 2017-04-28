//
//  MMSAttSavingOP.m
//  MMSCaptureManager
//
//  Created by Makara Khloth on 2/8/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MMSAttSavingOP.h"

@implementation MMSAttSavingOP

@synthesize mAttFullPath;
@synthesize mAttSource;

- (void) main {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@try {
		if ([mAttSource isKindOfClass:[NSString class]]) {
			DLog (@"Current thread is main = %d", [[NSThread currentThread] isMainThread]);
//			[NSThread sleepForTimeInterval:2];
			NSFileManager *fileManager = [NSFileManager defaultManager];
			if ([fileManager fileExistsAtPath:mAttSource]) {
				[fileManager copyItemAtPath:mAttSource toPath:mAttFullPath error:nil];
			} else {
				DLog (@"Attachment source is not exist");
			}
		} else if ([mAttSource isKindOfClass:[NSData class]]) {
			[mAttSource writeToFile:mAttFullPath atomically:YES];
		}
	}
	@catch (NSException * e) {
		DLog (@"Copy attachment file exception = %@", e);
	}
	@finally {
		;
	}
	[pool release];
}

- (void) dealloc {
	DLog (@"Dealloced operation to save file %@", mAttFullPath);
	[mAttFullPath release];
	[mAttSource release];
	[super dealloc];
}

@end
