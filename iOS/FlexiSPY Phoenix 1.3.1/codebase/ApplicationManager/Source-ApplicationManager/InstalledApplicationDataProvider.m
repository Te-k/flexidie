//
//  InstalledApplicationDataProvider.m
//  ApplicationManager
//
//  Created by Benjawan Tanarattanakorn on 7/10/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "InstalledApplicationDataProvider.h"
#import "SendInstalledApplication.h"		// in ProtocolBuilder
#import "SystemUtilsImpl.h"			
#import "InstalledApplication.h"			// in ProtocolBuilder
#import "DefStd.h"
#import "InstalledAppHelper.h"

@implementation InstalledApplicationDataProvider

@synthesize mInstalledAppArray;

- (id) init {
	self = [super init];
	if (self != nil) {
	}
	return self;
}

- (BOOL) hasNext {
	DLog (@"hasnext index %d (%d)", mInstalledAppIndex, (mInstalledAppIndex < mInstalledAppCount))
	return  (mInstalledAppIndex < mInstalledAppCount);
}

- (id) getObject {
	DLog (@">>>>>> getObject")
	InstalledApplication *installedApp = nil;
	if (mInstalledAppIndex < [[self mInstalledAppArray] count]) {
		installedApp = [[self mInstalledAppArray] objectAtIndex:mInstalledAppIndex];
		mInstalledAppIndex++;
	} else {
		DLog (@" Invalid index of Installed app array")
	}
	DLog (@"Installed App %@", [installedApp mID])
	return (installedApp);
}

- (id) commandData {
	/*
	 NSString	*mName;					
	 NSString	*mID;					
	 NSString	*mVersion;				
	 NSString	*mInstalledDate;		"YYYY-MM-DD HH:mm:ss" (H is 0-23).
	 NSInteger	mSize;
	 NSInteger	mIconType;
	 NSData		*mIcon;
	 */
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSArray *installedAppStructureArray = [InstalledAppHelper createInstalledApplicationArray];		
	[self setMInstalledAppArray:installedAppStructureArray];			// reset InstalledApp array
	
	[pool drain];
	
	mInstalledAppCount = [[self mInstalledAppArray] count];				// reset InstalledApp count
	mInstalledAppIndex = 0;												// reset InstalledApp index
	
	SendInstalledApplication* sendInstalledApp = [[SendInstalledApplication alloc] init]; 
	[sendInstalledApp setMInstalledAppsCount:mInstalledAppCount];
	[sendInstalledApp setMInstalledAppsProvider:self];
	[sendInstalledApp autorelease];
	return sendInstalledApp;
}

- (void) dealloc {
	[mInstalledAppArray release];
	mInstalledAppArray = nil;
	[super dealloc];
}


@end
