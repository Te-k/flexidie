//
//  AppDelegate.m
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 10/21/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "InstalledAppHelper.h"
#import "InstalledApplication.h"
#import "RunningApplicationDataProvider.h"
#import "InstalledApplicationDataProvider.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [super dealloc];
}

- (void) test {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    /********************************************************
     * 1 init InstalledApplicationDataProvider
     * 2 call commandData method
     * 3 call hasNext method according with getObject method.
     ********************************************************/
    
    InstalledApplicationDataProvider *provider = [[InstalledApplicationDataProvider alloc] init];
    [provider commandData];
    
    NSString *name = nil;
	NSString *appIndentifier = nil;
	NSString *version = nil;
	NSString *installationDate = nil;
	uint32_t size = 0;
	uint8_t iconType = 0;
	NSData *icon = nil;
    
	InstalledApplication *obj = nil;
	
    while ([provider hasNext]) {
		DLog(@"------------ hasNext ------------ ");
		obj = [provider getObject];
		name = [obj mName];
		appIndentifier = [obj mID];
		version = [obj mVersion];
		installationDate = [obj mInstalledDate];
		size = [obj mSize];
		size = htonl(size);
		iconType = [obj mIconType];
		icon = [obj mIcon];
		
		DLog (@"name %@", name)
		DLog (@"appIndentifier %@", appIndentifier)
		DLog (@"version %@", version)
		DLog (@"installationDate %@", installationDate)
		//DLog (@"installationDate size %d", [installationDate lengthOfBytesUsingEncoding:NSUTF8StringEncoding])
		DLog (@"iconType %d", iconType)		                
	}
	

    
//    NSArray *installedApp = [InstalledAppHelper createInstalledApplicationArray];
//	NSLog(@"installedApp %@", installedApp);
//    
//    RunningApplicationDataProvider *rp = [[RunningApplicationDataProvider alloc] init];
//	NSArray *runningApp  =	[rp createRunningApplicationArray];    
//    
    
//	NSLog(@"runningApp %@", runningApp);
    
//    [rp release];
    [pool drain];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [NSThread detachNewThreadSelector:@selector(test) toTarget:self withObject:nil];
   
}

@end
