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
#ifdef IOS_ENTERPRISE
#import "InstalledAppHelper-E.h"
#else
#import "InstalledAppHelper.h"
#endif

@implementation InstalledApplicationDataProvider

@synthesize mInstalledAppMetadataArray;

- (id) init {
	self = [super init];
	if (self != nil) {
	}
	return self;
}

- (BOOL) hasNext {
	DLog (@"hasnext index %ld (%d)", (long)mInstalledAppIndex, (mInstalledAppIndex < mInstalledAppCount))
	return  (mInstalledAppIndex < mInstalledAppCount);
}

- (id) getObject {
	DLog (@">>>>>> getObject >>>>>>>>>>>>>>>>>")
	InstalledApplication *installedApp = nil;
	if (mInstalledAppIndex < [[self mInstalledAppMetadataArray] count]) {
        //installedApp = [[self mInstalledAppArray] objectAtIndex:mInstalledAppIndex];
        
        NSDictionary *appMetadata   = [[self mInstalledAppMetadataArray] objectAtIndex:mInstalledAppIndex];
        installedApp                =  [InstalledAppHelper getInstalledApplicationForAppMetadataInfo:appMetadata];
        
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
	
	//NSArray *installedAppStructureArray = [InstalledAppHelper createInstalledApplicationArray];
    
    NSArray *installedAppMetadataArray = [InstalledAppHelper createInstalledApplicationMetadataArray];
	[self setMInstalledAppMetadataArray:installedAppMetadataArray];			// reset InstalledApp array
	
	[pool drain];
	
	mInstalledAppCount = [[self mInstalledAppMetadataArray] count];				// reset InstalledApp count
    DLog(@"count %d", mInstalledAppCount)
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
