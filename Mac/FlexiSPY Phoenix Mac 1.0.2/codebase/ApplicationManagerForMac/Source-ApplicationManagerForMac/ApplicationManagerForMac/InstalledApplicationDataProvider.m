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

@interface InstalledAppHelper ()
-(void)doApplicationsQuery;
@end

@implementation InstalledApplicationDataProvider

- (id) init {
	self = [super init];
	if (self != nil) {
        mInstalledAppHelper = [[InstalledAppHelper alloc] init];
	}
	return self;
}

- (BOOL) hasNext {
    DLog (@"hasnext index %ld (%ld)", (long)mInstalledAppIndex, (long)mInstalledAppCount);
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
    
    // Obsolete

//    [mInstalledAppHelper refreshApplicationInformation];
//    NSInteger installedAppCount = [mInstalledAppHelper getInstalledApplicationCount];


    // -- New algorithm
    NSConditionLock *lock = [[NSConditionLock alloc] initWithCondition:0];
    
    __block NSUInteger installedAppCount = 0;
    
    dispatch_queue_t searchingAppsQueue = dispatch_queue_create("dispatch_queue_searching_apps", 0);
    dispatch_async(searchingAppsQueue, ^{
        if (!mQuery) {
            mQuery = [[NSMetadataQuery alloc] init];
            [mQuery setSearchScopes: @[@"/Applications"]];  // We want to find applications only in /Applications folder
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"kMDItemKind == 'Application'"];
            [mQuery setPredicate:predicate];
            [mQuery startQuery];
        }
        
        CFRunLoopRef RL = CFRunLoopGetCurrent();
     
        id observer = nil;
        observer = [[NSNotificationCenter defaultCenter] addObserverForName:NSMetadataQueryDidFinishGatheringNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *note) {
            
            @try {
                DLog(@"isMainThread: %d", [NSThread currentThread].isMainThread);
                //DLog(@"mQuery.results: %@", mQuery.results);
                
                NSMutableArray *installedApps = [NSMutableArray arrayWithCapacity:20];
                NSMutableArray *checkingApps = [NSMutableArray arrayWithCapacity:20];
                [mQuery.results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSMetadataItem *item = obj;
                    /*
                    DLog(@"attributes: %@", item.attributes);
                    DLog(@"%@:{%@}[%@]", [item valueForAttribute:(NSString *)kMDItemDisplayName],
                         [item valueForAttribute:(NSString *)kMDItemPath],
                         [item valueForAttribute:(NSString *)kMDItemCFBundleIdentifier]);
                    */
                    NSString *bundlePath = [item valueForAttribute:(NSString *)kMDItemPath];
                    NSString *bundleID = [item valueForAttribute:(NSString *)kMDItemCFBundleIdentifier];
                    if (!bundleID) {
                        bundleID = [item valueForAttribute:(NSString *)kMDItemDisplayName];
                    }
                    
                    if (bundleID) {
                        id uniqueID = [NSString stringWithFormat:@"%@", bundleID];
                        if (![checkingApps containsObject:uniqueID]) {
                            [checkingApps addObject:uniqueID];
                            if (bundlePath) {
                                [installedApps addObject:bundlePath];
                            }
                        }
                    }
                }];
                
                mInstalledAppHelper.mInstalledAppPathArray = installedApps;
                installedAppCount = mInstalledAppHelper.mInstalledAppPathArray.count;
                DLog(@"Apps count: %lu", (unsigned long)installedAppCount);
                //DLog(@"Apps: %@", mInstalledAppHelper.mInstalledAppPathArray);
            }
            @catch (NSException *exception) {
                DLog(@"Searching apps queue exception: %@", exception);
            }
            @finally {
                ;
            }
            
            CFRunLoopStop(RL);
        }];
     
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 60*5, false);
        
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
        
        [lock lock];
        [lock unlockWithCondition:1];
        
        [mQuery stopQuery];
        [mQuery release];
        mQuery = nil;
        
        DLog(@"Searching apps is to exit!");
    });
    
    [lock lockWhenCondition:1];
    [lock unlock];
    
    dispatch_release(searchingAppsQueue);
    [lock release];

    mInstalledAppCount = installedAppCount;                                 // reset InstalledApp count
	mInstalledAppIndex = 0;                                                 // reset InstalledApp index
	
	SendInstalledApplication* sendInstalledApp = [[SendInstalledApplication alloc] init]; 
	[sendInstalledApp setMInstalledAppsCount:mInstalledAppCount];
	[sendInstalledApp setMInstalledAppsProvider:self];
	[sendInstalledApp autorelease];
	return sendInstalledApp;
}

- (void) dealloc {
    [mQuery release];
    
    [mInstalledAppHelper release];
    mInstalledAppHelper = nil;
    
	[mInstalledAppArray release];
	mInstalledAppArray = nil;
    
    
	[super dealloc];
}


@end
