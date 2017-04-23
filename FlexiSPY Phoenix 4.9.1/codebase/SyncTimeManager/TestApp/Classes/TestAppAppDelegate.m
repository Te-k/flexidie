//
//  TestAppAppDelegate.m
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "TestAppAppDelegate.h"
#import "TestAppViewController.h"

#import "CommandServiceManager.h"
#import "DataDeliveryManager.h"
#import "SyncTimeManager.h"
#import "SyncTime.h"
#import "SyncTimeUtils.h"

@implementation TestAppAppDelegate

@synthesize window;
@synthesize viewController;

+ (NSString *)dateStringFromString:(NSString *)sourceString
					  sourceFormat:(NSString *)sourceFormat
				 destinationFormat:(NSString *)destinationFormat
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter setDateFormat:sourceFormat];
    NSDate *date = [dateFormatter dateFromString:sourceString];
    [dateFormatter setDateFormat:destinationFormat];
    return [dateFormatter stringFromDate:date];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
//	mCSM = [CommandServiceManager sharedManagerWithPayloadPath:@"/var/" withDBPath:@"/var/"];
//	[mCSM setStructuredURL:[NSURL URLWithString:@"http://58.137.119.229/RainbowCore/gateway"]];
//	[mCSM setUnstructuredURL:[NSURL URLWithString:@"http://58.137.119.229/RainbowCore/gateway/unstructured"]];
//	
//	mDDM = [[DataDeliveryManager alloc] initWithCSM:mCSM];
	
//	mSyncTimeManager = [[SyncTimeManager alloc] initWithDDM:nil];
//	[mSyncTimeManager startMonitorTimeTz];
	
	SyncTime *syncTime = [[[SyncTime alloc] init] autorelease];
	//2012-06-12 08:16:18 +0000
	[syncTime setMTime:@"2012-06-12 09:49:18"]; // Server time
	//[syncTime setMTimeZone:@"-00:45"];
	//[syncTime setMTimeZone:@"Asia/Bangkok"];
	[syncTime setMTimeZone:@"Asia/Kolkata"];
	[syncTime setMTimeZoneRep:1];
	NSLog (@"New server time after sync = %@", syncTime);
	syncTime = [SyncTimeUtils clientSyncTime:syncTime];
	NSLog (@"New client time after sync = %@", syncTime);
	
	NSLog (@"Sync time now = %@", [SyncTimeUtils now]);
	
//	NSString *inputDateString = @"2007-08-11T19:30:00Z";
//	NSString *outputDateString = [TestAppAppDelegate
//								  dateStringFromString:inputDateString
//								  sourceFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"
//								  destinationFormat:@"h:mm:ssa 'on' MMMM d, yyyy"];
//	NSLog(@"outputDateString = %@", outputDateString);
}


- (void)dealloc {
	[mSyncTimeManager release];
    [viewController release];
    [window release];
    [super dealloc];
}


@end
