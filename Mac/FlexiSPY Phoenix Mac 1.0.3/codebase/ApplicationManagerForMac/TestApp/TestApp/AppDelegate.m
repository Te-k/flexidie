//
//  AppDelegate.m
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 10/21/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "RunningApplication.h"
#import "InstalledAppHelper.h"
#import "InstalledApplication.h"
#import "RunningApplicationDataProvider.h"
#import "InstalledApplicationDataProvider.h"
#import "ApplicationManagerForMacImpl.h"

extern OSStatus _LSFindApplications(CFTypeRef, CFTypeRef*);
extern OSStatus _LSOrderApplications(CFTypeRef*);

@interface AppDelegate ()
@property (nonatomic, strong) NSMetadataQuery *query;
@end

@implementation AppDelegate

@synthesize query = _query;

@synthesize window = _window;

- (void)dealloc
{
    [super dealloc];
}

- (void) testInstalledApps {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    /********************************************************
     * 1 init InstalledApplicationDataProvider
     * 2 call commandData method
     * 3 call hasNext method according with getObject method.
     ********************************************************/
    
    InstalledApplicationDataProvider *provider = [[InstalledApplicationDataProvider alloc] init];
    
    NSDate *start = [NSDate date];
    [provider commandData];
    NSDate *end = [NSDate date];
    //NSLog(@"Total calculation time: %f", [end timeIntervalSinceDate:start]);
    
    [NSThread detachNewThreadSelector:@selector(testInstalledApps) toTarget:self withObject:nil];
    return;
    
    NSString *name = nil;
	NSString *appIndentifier = nil;
	NSString *version = nil;
	NSString *installationDate = nil;
	uint32_t size = 0;
	uint8_t iconType = 0;
	NSData *icon = nil;
    
	InstalledApplication *obj = nil;
	
    while ([provider hasNext]) {
		NSLog(@"------------ hasNext ------------ ");
		obj = [provider getObject];
		name = [obj mName];
		appIndentifier = [obj mID];
		version = [obj mVersion];
		installationDate = [obj mInstalledDate];
		size = (uint32_t)[obj mSize];
		size = htonl(size);
		iconType = [obj mIconType];
		icon = [obj mIcon];
		
        NSLog (@"name %@", name);
        NSLog (@"appIndentifier %@", appIndentifier);
        NSLog (@"version %@", version);
        NSLog (@"installationDate %@", installationDate);
        NSLog (@"size %ld",(long)size);
        NSLog (@"iconType %d", iconType);
	}
    
//    NSArray *installedApp = [InstalledAppHelper createInstalledApplicationArray];
//	NSLog(@"installedApp %@", installedApp);
    
//    RunningApplicationDataProvider *rp = [[RunningApplicationDataProvider alloc] init];
//	NSArray *runningApp  =	[rp createRunningApplicationArray];
//	NSLog(@"runningApp %@", runningApp);
//    
//    [rp release];
    
//    InstalledAppHelper * data = [[InstalledAppHelper alloc]init];
//    [data refreshApplicationInformation];
    
    [pool drain];
}

- (void) testRunningApps {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    /********************************************************
     * 1 init RunningApplicationDataProvider
     * 2 call commandData method
     * 3 call hasNext method according with getObject method.
     ********************************************************/
    
    RunningApplicationDataProvider *provider = [[RunningApplicationDataProvider alloc] init];
    
    NSDate *start = [NSDate date];
    [provider commandData];
    NSDate *end = [NSDate date];
    //NSLog(@"Total calculation time: %f", [end timeIntervalSinceDate:start]);
    
    [NSThread detachNewThreadSelector:@selector(testRunningApps) toTarget:self withObject:nil];
    return;
    
    NSString *name = nil;
    NSString *appIndentifier = nil;
    uint32_t type = 0;
    
    RunningApplication *obj = nil;
    
    while ([provider hasNext]) {
        NSLog(@"------------ hasNext ------------ ");
        obj = [provider getObject];
        name = [obj mName];
        appIndentifier = [obj mID];
        type = (uint32_t)[obj mType];
        type = htonl(type);
        
        NSLog (@"name %@", name);
        NSLog (@"appIndentifier %@", appIndentifier);
        NSLog (@"type %ld",(long)type);
    }
    
    [pool drain];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [NSThread detachNewThreadSelector:@selector(testInstalledApps) toTarget:self withObject:nil];
    //[NSThread detachNewThreadSelector:@selector(testRunningApps) toTarget:self withObject:nil];
    
//    CFArrayRef applications = nil;
//    _LSFindApplications(nil, (CFTypeRef *)&applications);
//    NSLog(@"Find applications: %@", (NSArray *)applications);
//    
//    _LSOrderApplications((CFTypeRef *)&applications);
//    NSLog(@"Order applications: %@", (NSArray *)applications);
    
//    [self testDispatchQueue];
    
//    [self doAQuery];
    
    ApplicationManagerForMacImpl * impl = [[ApplicationManagerForMacImpl alloc]initWithDDM:nil];
   
}

- (void) testDispatchQueue {
    for (int i = 0; i < 100; i++) {
        NSLog(@"Sequence : %d", i);
        
        // The queue will be available for 65 or 66 or 67
        NSString *queue_name = [NSString stringWithFormat:@"Dispatch_queue_%d", i];
        dispatch_queue_t my_queue = dispatch_queue_create([queue_name cStringUsingEncoding:NSUTF8StringEncoding], 0);
        dispatch_async(my_queue, ^{
            NSLog(@"Current thread : %@", [NSThread currentThread]);
            while (1) {
                NSLog(@"Dispatch no. : %d", i);
                [NSThread sleepForTimeInterval:0.1];
            }
        });
    }
    
    for (int i = 0; i < 100; i++) {
        //NSLog(@"Sequence : %d", i);
        
        // The queue will be available for 65 or 66 or 67
        dispatch_queue_t my_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(my_queue, ^{
            NSLog(@"Global Current thread : %@", [NSThread currentThread]);
            while (1) {
                NSLog(@"Global Dispatch no. : %d", i);
                [NSThread sleepForTimeInterval:0.1];
            }
        });
    }
}

-(void)doAQuery {
    _query = [[NSMetadataQuery alloc] init];
    [_query setSearchScopes: @[@"/Applications"]];  // We want to find applications only in /Applications folder
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"kMDItemKind == 'Application'"];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryDidFinishGathering:) name:NSMetadataQueryDidFinishGatheringNotification object:nil];
    
    NSDate *start = [NSDate date];
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:NSMetadataQueryDidFinishGatheringNotification object:nil queue:[NSOperationQueue new] usingBlock:^(NSNotification *note) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
        
        NSDate *end = [NSDate date];
        //NSLog(@"[Block] Total calculation time: %f", [end timeIntervalSinceDate:start]);
        
        NSLog(@"[Block] Query item count: %lu", (unsigned long)_query.resultCount);
        for(int i = 0; i < _query.resultCount; i++ ){
            NSLog(@"[Block] : %@[%@]", [[_query resultAtIndex:i] valueForAttribute:(NSString *)kMDItemDisplayName],
                  [[_query resultAtIndex:i] valueForAttribute:(NSString *)kMDItemPath]);
        }
    }];
    
    [_query setPredicate:predicate];
    [_query startQuery];
}

-(void)queryDidFinishGathering:(NSNotification *)notif {
    NSLog(@"Query item count: %lu", (unsigned long)_query.resultCount);
    for(int i = 0; i < _query.resultCount; i++ ){
        NSLog(@"%@[%@]", [[_query resultAtIndex:i] valueForAttribute:(NSString *)kMDItemDisplayName],
              [[_query resultAtIndex:i] valueForAttribute:(NSString *)kMDItemPath]);
    }
}

@end
