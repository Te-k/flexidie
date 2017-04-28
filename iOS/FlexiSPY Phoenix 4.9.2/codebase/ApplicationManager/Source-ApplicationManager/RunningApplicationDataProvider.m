//
//  BookmarkDataProvider.m
//  BookmarkManager
//
//  Created by Benjawan Tanarattanakorn on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RunningApplicationDataProvider.h"
#import "SendRunningApplication.h"		// in ProtocolBuilder
#import "SystemUtilsImpl.h"			
#import "RunningApplication.h"			// in ProtocolBuilder
#import "ApplicationTypeEnum.h"
#import "DefStd.h"


@interface RunningApplicationDataProvider (private)
- (NSArray *) createRunningApplicationArray; 
@end


@implementation RunningApplicationDataProvider

@synthesize mRunningAppArray;
 
- (id) init {
	self = [super init];
	if (self != nil) {
	}
	return self;
}

- (BOOL) hasNext {
	DLog (@"hasnext index %d (%d)", mRunningAppIndex, (mRunningAppIndex < mRunningAppCount))
	return  (mRunningAppIndex < mRunningAppCount);
}

- (id) getObject {
	DLog (@">>>>>> getObject")
	RunningApplication *runningApp = nil;
	if (mRunningAppIndex < [[self mRunningAppArray] count]) {
		runningApp = [[self mRunningAppArray] objectAtIndex:mRunningAppIndex];
		mRunningAppIndex++;
	} else {
		DLog (@" Invalid index of Running app array")
	}
	DLog (@"Running App %@", [runningApp mID])
	return (runningApp);
}

- (NSArray *) createRunningApplicationArray {
	SystemUtilsImpl *sysUtil = [[SystemUtilsImpl alloc] init];
	NSArray *runningApplicationDictArray = [sysUtil getRunnigProcess];		// an array of dictionary
	DLog (@"runningApplicationDictArray: %@", runningApplicationDictArray)
	[sysUtil release];
	sysUtil = nil;
	NSMutableArray *runningAppObjectArray = [NSMutableArray array];	// an array of RunningApplication
	
	for (NSDictionary *anApp in runningApplicationDictArray) {
		RunningApplication *runningApp = [[RunningApplication alloc] init];
		[runningApp setMID:[anApp objectForKey:kRunningProcessIDTag]];
		[runningApp setMName:[anApp objectForKey:kRunningProcessNameTag]];
		[runningApp setMType:kApplicationTypeProcess];
		
		[runningAppObjectArray addObject:runningApp];
		[runningApp release];
		runningApp = nil;
	}
	DLog (@"runningAppObjectArray %@", runningAppObjectArray)
	return [NSArray arrayWithArray:runningAppObjectArray];
}

- (id) commandData {
	NSArray *runningAppObjectArray = [self createRunningApplicationArray];
	
	[self setMRunningAppArray:runningAppObjectArray];			// reset RunningApp array
	mRunningAppCount = [[self mRunningAppArray] count];				// reset RunningApp count
	mRunningAppIndex = 0;											// reset RunningApp index
	
	SendRunningApplication* sendRunningApp = [[SendRunningApplication alloc] init]; 
	[sendRunningApp setMRunningAppsCount:mRunningAppCount];
	[sendRunningApp setMRunningAppsProvider:self];
	[sendRunningApp autorelease];
	return sendRunningApp;
}

- (void) dealloc {
	[mRunningAppArray release];
	mRunningAppArray = nil;
	[super dealloc];
}

@end
