//
//  TestAppAppDelegate.m
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "TestAppAppDelegate.h"
#import "TestAppViewController.h"

#import "MediaFinder.h"
#import "FileSystemEntry.h"

@implementation TestAppAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	mMediaFinder = [[MediaFinder alloc] initWithEventDelegate:nil];
	NSMutableArray *findEntries = [NSMutableArray array];
	FindEntry *entry = [[FindEntry alloc] init];
	[entry setMExtMime:@"pdf"];
	[entry setMMediaType:kFinderMediaTypeVideo];
	[findEntries addObject:entry];
	[entry release];
	[mMediaFinder findMediaFileWithExtMime:findEntries];
}


- (void)dealloc {
	[mMediaFinder release];
    [viewController release];
    [window release];
    [super dealloc];
}


@end
