//
//  FileStreamAbstract.m
//  FxStd
//
//  Created by Makara Khloth on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FileStreamAbstract.h"

@implementation FileStreamAbstract

@synthesize mFileFullName, mExternalizedData;

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (void) save {
	NSFileManager* fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:mFileFullName]) {
		if ([fileManager isDeletableFileAtPath:mFileFullName]) {
			NSError* error = nil;
			BOOL success = [fileManager removeItemAtPath:mFileFullName error:&error];
			if (success) {
				[mExternalizedData writeToFile:mFileFullName atomically:YES];
			} else {
				DLog (@"Remove file error = %@", error)
			}
		} else {
			DLog (@"File cannot be deleted")
		}
	} else {
		[mExternalizedData writeToFile:mFileFullName atomically:YES];
	}
}

- (void) read {
	NSFileManager* fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:mFileFullName]) {
		mExternalizedData = [NSData dataWithContentsOfFile:mFileFullName];
	}
}

- (void) dealloc {
	[mFileFullName release];
	[mExternalizedData release];
	[super dealloc];
}

@end
