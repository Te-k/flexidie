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

//@synthesize mInstalledAppArray;

- (id) init {
	self = [super init];
	if (self != nil) {
        mInstalledAppHelper = [[InstalledAppHelper alloc] init];
	}
	return self;
}

- (BOOL) hasNext {
    DLog (@"hasnext index %d (%d)", mInstalledAppIndex,  mInstalledAppCount );
	return  (mInstalledAppIndex < mInstalledAppCount);
}

- (id) getObject {
    DLog (@">>>>>> getObject");
	InstalledApplication *installedApp = nil;
	//if (mInstalledAppIndex < [[self mInstalledAppArray] count]) {
    if (mInstalledAppIndex < mInstalledAppCount) {
        //obsolete
		//installedApp = [[self mInstalledAppArray] objectAtIndex:mInstalledAppIndex];
        
        installedApp = [mInstalledAppHelper getInstalledAppIndex:mInstalledAppIndex]; 
        if ([[installedApp mID] isEqualToString:@"com.apple.Safari"] ||
            [[installedApp mID] isEqualToString:@"org.mozilla.firefox"] ||
            [[installedApp mID] isEqualToString:@"com.google.Chrome"]) {
            [installedApp setMCategory:kInstalledAppCategoryBrowser];
        }else{
            [installedApp setMCategory:kInstalledAppCategoryNoneBrowser];
        }
		mInstalledAppIndex++;
	} else {
        DLog (@" Invalid index of Installed app array");
	}
    DLog (@"Installed App %@", [installedApp mID]);
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
	// obsolete
    // NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    //NSArray *installedAppStructureArray = [InstalledAppHelper createInstalledApplicationArray];		
    //[self setMInstalledAppArray:installedAppStructureArray];			// reset InstalledApp array
    //[pool drain];
    //mInstalledAppCount = [[self mInstalledAppArray] count];				// reset InstalledApp count
    
    // get count of installed application only
    
    [mInstalledAppHelper refreshApplicationInformation];
    NSInteger installedAppCount = [mInstalledAppHelper getInstalledApplicationCount];
        
    
    mInstalledAppCount = installedAppCount;                                 // reset InstalledApp count
	mInstalledAppIndex = 0;                                                 // reset InstalledApp index
	
	SendInstalledApplication* sendInstalledApp = [[SendInstalledApplication alloc] init]; 
	[sendInstalledApp setMInstalledAppsCount:mInstalledAppCount];
	[sendInstalledApp setMInstalledAppsProvider:self];
	[sendInstalledApp autorelease];
	return sendInstalledApp;
}

- (void) dealloc {
    
    [mInstalledAppHelper release];
    mInstalledAppHelper = nil;
    
	[mInstalledAppArray release];
	mInstalledAppArray = nil;
    
    
	[super dealloc];
}


@end
