//
//  PanicViewController.m
//  FeelSecure
//
//  Created by Makara Khloth on 8/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PanicViewController.h"
#import "FeelSecureAppDelegate.h"
#import "ActivateViewController.h"
#import "LicenseExpiredDisabledViewController.h"
#import "RootViewController.h"
#import "UIViewController+More.h"
#import "LicenseChangeDelegate.h"
#import "AdvancedSettingsLockViewController.h"

#import "AppUIConnection.h"
#import "AppEngineUICmd.h"
#import "LicenseInfo.h"
#import "ConfigurationManagerImpl.h"
#import "PhoneInfoImp.h"
#import "SyncTime.h"
#import "DateTimeFormat.h"
#import "DefStd.h"

// Features
#import "CameraCaptureManager.h"
#import "CameraCaptureManagerUIUtils.h"
#import "FeelSecureSettingsNotificationHelper.h"

#import "AudioPlayer.h"

#import <CoreLocation/CoreLocation.h>
#import "SpringBoardServices.h"

#define UIColorFromRGB(rgbValue) [UIColor \
									colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
									green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
									blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define LOGOHIGHT	43

// Location Service Warning Dialog Box
#define SETTING_BUTTON_INDEX		0
#define OK_BUTTON_INDEX				1
#define DUMMY_BUTTON_INDEX			2

//static NSInteger countOfNotificationReg = 0;


@interface PanicViewController (private)
- (void) applicationUIDidBecomeActive: (NSNotification *) aNotification;
- (void) applicationUIWillResignActive: (NSNotification *) aNotification;

- (void) licenseDidChange: (NSNotification *) aNotification;

- (void) requestServerSyncTime;

- (NSDictionary *) defaultSettings;

- (void) startPanic;

- (BOOL) checkLocationServiceStatusAndAlertUserIfDisable;
- (void) dismissLocationServiceDialogBoxIfExist;
@end


@implementation PanicViewController

@synthesize mCameraCaptureManager;
@synthesize mCCMUtils;
//@synthesize mFeelSecureSettingsNotificationHelper;

@synthesize mOverlayView;
@synthesize mFeelSecureLogo;
@synthesize mRadarView;
@synthesize mSendingLocLabel;
@synthesize mServerSyncTimeLabel;
@synthesize mBlackOutLabel;

@synthesize mXDiffTimeInterval;

#pragma mark -
#pragma mark Public methods
#pragma mark -

- (void) cameraDidStartCapture {
	//DLog (@"Camera capture manager did start capturing.....");
	[[self mOverlayView] setBackgroundColor:[UIColor clearColor]];
	[[self mRadarView] setHidden:YES];
	[[self mSendingLocLabel] setHidden:YES];
}

- (void) cameraDidStopCapture {
	//DLog (@"Camera capture manager did stop capturing.....");
	[[self mOverlayView] setBackgroundColor:[UIColor blackColor]];
	
//	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//	[userDefaults registerDefaults:[self defaultSettings]];
//	NSString *mode = [userDefaults stringForKey:@"mode"];
	NSString *mode = [[self defaultSettings] objectForKey:@"mode"];
	DLog (@"[cameraDidStopCapture]- panic mode from settings bundle = %@", mode);
	
	if ([mode isEqualToString:@"2"]) {	// 2 - Location only
		UIApplication *application = [UIApplication sharedApplication];
		if ([application applicationState] == UIApplicationStateActive) {
			// User change panic mode from remote command in daemon otherwise application is just resign active/background
			// thus no need to show the radar or sending location view
			[[self mRadarView] setHidden:NO];
			[[self mSendingLocLabel] setHidden:NO];
		}
	}
//	[userDefaults synchronize];
}

#pragma mark -
#pragma mark Feelsecure settings bundle launch the application
#pragma mark -

- (void) feelSecureSettingsBundleDidLaunch {
	FeelSecureAppDelegate *appDelegate = (FeelSecureAppDelegate *)[[UIApplication sharedApplication] delegate];
	UINavigationController *navigationController = [appDelegate navigationController];
	
	[navigationController popViewControllerAnimated:YES];
	
	/*
	RootViewController *rootViewController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil];
	UINavigationController *naviViewController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
	[rootViewController release];
	
	if ([navigationController respondsToSelector:@selector(presentViewController:animated:completion:)]) {
		[navigationController presentViewController:naviViewController animated:YES completion:nil];
	} else {
		// Deprecated API in newer version
		[navigationController presentModalViewController:naviViewController animated:YES];
	}
	[naviViewController release];
	 */
	
	AdvancedSettingsLockViewController *advancedSettingsLockViewController = [[AdvancedSettingsLockViewController alloc] initWithNibName:@"AdvancedSettingsLockViewController"
																																  bundle:nil];
	if ([navigationController respondsToSelector:@selector(presentViewController:animated:completion:)]) {
		[navigationController presentViewController:advancedSettingsLockViewController animated:YES completion:nil];
	} else {
		// Deprecated API in newer version
		[navigationController presentModalViewController:advancedSettingsLockViewController animated:YES];
	}
	[advancedSettingsLockViewController release];
}

#pragma mark -
#pragma mark UIViewController methods
#pragma mark -

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Custom initialization
	}
	return self;
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	//DLog (@"Panic view controller load view");
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	
	CGRect rect = [[UIScreen mainScreen] applicationFrame];
	//CGRect rect = [[UIScreen mainScreen] bounds];
	
	UIView *overlayView = [[[UIView alloc] initWithFrame:rect] autorelease];
    [overlayView setOpaque:NO];
	[overlayView setBackgroundColor:[UIColor blackColor]];
	[self setMOverlayView:overlayView];
	
    UIImageView *feelSecureLogo = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, LOGOHIGHT)] autorelease];
    [feelSecureLogo setImage:[UIImage imageNamed:@"logobar.png"]];
    [feelSecureLogo setAlpha:0.6];		// old value is 0.3
	[self setMFeelSecureLogo:feelSecureLogo];
    [[self mOverlayView] addSubview:[self mFeelSecureLogo]];
	
	// radar
    UIImageView *radarView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 80, 280, 280)];
	
    
    // load all the frames of our animation
    [radarView setAnimationImages:[NSArray arrayWithObjects:    
								 [UIImage imageNamed:@"greenradar_up.png"],
								 [UIImage imageNamed:@"greenradar_right.png"],
								 [UIImage imageNamed:@"greenradar_down.png"],
								 [UIImage imageNamed:@"greenradar_left.png"], nil]];
    // all frames will execute in 4.0 seconds
    [radarView setAnimationDuration:4.0];
    // repeat the annimation forever
    [radarView setAnimationRepeatCount:0];
    // start animating
    [radarView startAnimating];
	[radarView setHidden:YES];
	[self setMRadarView:radarView];
	[radarView release];
    // add the animation view to the main window
    [[self mOverlayView] addSubview:[self mRadarView]];
    
    UILabel *sendingLocLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 390, 310, 30)];
    [sendingLocLabel setText:NSLocalizedString(@"kPanicViewSendingLocation", @"")];
    [sendingLocLabel setTextColor:UIColorFromRGB(0x005f00)];
    [sendingLocLabel setBackgroundColor:[UIColor clearColor]];
	[sendingLocLabel setHidden:YES];
	[self setMSendingLocLabel:sendingLocLabel];
	[sendingLocLabel release];
    [[self mOverlayView] addSubview:[self mSendingLocLabel]];
	
	UILabel *serverSyncTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 410, 310, 30)];
    [serverSyncTimeLabel setText:@""];
    [serverSyncTimeLabel setTextColor:UIColorFromRGB(0x005f00)];
    [serverSyncTimeLabel setBackgroundColor:[UIColor clearColor]];
	[serverSyncTimeLabel setHidden:YES];
	[self setMServerSyncTimeLabel:serverSyncTimeLabel];
	[serverSyncTimeLabel release];
    [[self mOverlayView] addSubview:[self mServerSyncTimeLabel]];
	
	// For fixing white ui part when activate camera controller
	UILabel *blackOutLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 477, 320, 3)]; // 477+3=480 screen height
    [blackOutLabel setText:@""];
    [blackOutLabel setTextColor:UIColorFromRGB(0x005f00)];
    [blackOutLabel setBackgroundColor:[UIColor blackColor]];
	[self setMBlackOutLabel:blackOutLabel];
	[blackOutLabel release];
    [[self mOverlayView] addSubview:[self mBlackOutLabel]];
	
	[self setView:[self mOverlayView]];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	DLog (@"!!!!!!!!!!!!!!!!! Panic view controller view did load");
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	// Features
	mCameraCaptureManager = [[CameraCaptureManager alloc] initWithUIViewController:self];
	// The same result to above line of code
	//mCameraCaptureManager = [[CameraCaptureManager alloc] initWithUIViewController:self.navigationController];
	[mCameraCaptureManager setMCameraCaptureDelegate:self];
	[mCameraCaptureManager setMCameraStartCaptureSelector:@selector(cameraDidStartCapture)];
	[mCameraCaptureManager setMCameraStopCaptureSelector:@selector(cameraDidStopCapture)];
	// Use only to handle when user change panic mode while panic is on
	mCCMUtils = [[CameraCaptureManagerUIUtils alloc] initWithCameraCaptureManager:mCameraCaptureManager];
	
	// Obsolete notification from settings bundle
	//mFeelSecureSettingsNotificationHelper = [[FeelSecureSettingsNotificationHelper alloc] initWithPanicViewController:self];
	
	
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *bundleResourcePath = [bundle resourcePath];
	NSString *panicSoundPath = [bundleResourcePath stringByAppendingString:@"/panicSound.mp3"];
	mAudioPlayer = [[AudioPlayer alloc] init];
	[mAudioPlayer setMRepeat:YES];
	[mAudioPlayer setMFilePath:panicSoundPath];
	[mAudioPlayer setMDelegate:nil];
	
	mMessageReader = [[MessagePortIPCReader alloc] initWithPortName:kAllBlockAlertViewDismissMessagePort
										 withMessagePortIPCDelegate:self];
	[mMessageReader start];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(applicationUIDidBecomeActive:)
			   name:UIApplicationDidBecomeActiveNotification
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(applicationUIWillResignActive:)
			   name:UIApplicationWillResignActiveNotification
			 object:nil];
	
	//DLog (@">>>>>>>> registering notification %d", countOfNotificationReg)
	[nc addObserver:self
		   selector:@selector(licenseDidChange:)
			   name:kFeelSecureLicenseChangeNotification
			 object:nil];
	//++countOfNotificationReg;
}

- (void)viewWillDisappear: (BOOL) animated {
	//DLog (@"!!!!!!!!!!!!!!!!!  Panic view controller view will disappear");
	[super viewWillDisappear:animated];
	FeelSecureAppDelegate *appDelegate = (FeelSecureAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate mAppUIConnection] removeCommandDelegate:self];
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void) viewWillAppear: (BOOL) animated {
	//DLog (@"!!!!!!!!!!!!!!!!!  Panic view controller view will appear");
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	//DLog (@"!!!!!!!!!!!!!!!!! Panic view controller view did appear");
	[super viewDidAppear:animated];
	//DLog(@"----->Register for command activate response<----- %@", self);
	FeelSecureAppDelegate *appDelegate = (FeelSecureAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate mAppUIConnection] addCommandDelegate:self];
	
	// This request is for:
	// a. Switch between views
	[[appDelegate mAppUIConnection] processCommand:kAppUI2EngineGetLicenseInfoCmd withCmdData:nil];
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
	
	//--countOfNotificationReg;
	//DLog (@">>>>>>>> registering notification %d", countOfNotificationReg) /// !!!: for debuging purpose
	DLog (@"******************************************************************************************")
	DLog (@"************************ viewDidUnload ************************");
	DLog (@"******************************************************************************************")
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
	[nc removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
	[nc removeObserver:self name:kFeelSecureLicenseChangeNotification object:nil];
}

#pragma mark -
#pragma mark UI daemon connection
#pragma mark -

- (void) commandCompleted: (id) aCmdResponse toCommand: (NSInteger) aCmd {
	DLog(@"PanicViewController got echo commad from daemon: %d", aCmd)
	if (aCmd == kAppUI2EngineGetLicenseInfoCmd) {
		FeelSecureAppDelegate *appDelegate = (FeelSecureAppDelegate *)[[UIApplication sharedApplication] delegate];
		NSData *data = aCmdResponse;
		LicenseInfo *licenseInfo = [[LicenseInfo alloc] initWithData:data];
		
		[appDelegate setMLicenseInfo:licenseInfo];
		[[appDelegate mConfigurationManager] updateConfigurationID:[licenseInfo configID]];
		
		if ([[appDelegate mLicenseInfo] licenseStatus] == DEACTIVATED) {
			//DLog (@"Stop capture panic image unilaterally");
			
			mPanicStart = NO;
			
			//*************************************************
			// Get user default preference from settings bundle first prevent the same case of start panic
//			NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//			[userDefaults registerDefaults:[self defaultSettings]];
//			NSString *mode = [userDefaults stringForKey:@"mode"];
			NSString *mode = [[self defaultSettings] objectForKey:@"mode"];
			DLog (@"[STOP LICENSE CHANGE]- panic mode from settings bundle = %@", mode);
			
			if ([mode isEqualToString:@"1"]) { // Location plus camera image
				[mCameraCaptureManager stopCapture];
			}
			
			[mAudioPlayer stop];
			
			[[self mRadarView] setHidden:YES];
			[[self mSendingLocLabel] setHidden:YES];
//			[userDefaults synchronize];
			//*************************************************
			
			ActivateViewController *activateViewController = [[ActivateViewController alloc] initWithNibName:@"ActivateViewController" bundle:nil];
			[[appDelegate navigationController] popViewControllerAnimated:NO];
			//DLog(@"Popped panic view out of navigation controller");
			[[appDelegate navigationController] pushViewController:activateViewController animated:NO];
			//DLog(@"Pushed activate view controller onto navigation controller");
			[activateViewController release];
		} else if ([licenseInfo licenseStatus] == EXPIRED ||
				   [licenseInfo licenseStatus] == DISABLE ||
				   [licenseInfo licenseStatus] == LC_UNKNOWN) {
			LicenseExpiredDisabledViewController *licenseExpiredDisabledViewController = [[LicenseExpiredDisabledViewController alloc] initWithNibName:@"LicenseExpiredDisabledViewController" bundle:nil];
			[[appDelegate navigationController] popViewControllerAnimated:NO];
			[[appDelegate navigationController] pushViewController:licenseExpiredDisabledViewController animated:NO];
			[licenseExpiredDisabledViewController release];
		} else {
			/// !!!: This cause the issue of extra notification registration
			/*
			DLog (@">>>>>>>> registering notification %d", countOfNotificationReg)
			NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
			[nc addObserver:self
				   selector:@selector(licenseDidChange:)
					   name:kFeelSecureLicenseChangeNotification
					 object:nil];
			++countOfNotificationReg;
			*/
			
			// License is activated thus request server sync time ===> Obsolete this flow
			//[self performSelector:@selector(requestServerSyncTime) withObject:nil afterDelay:1.00];
		}
		[licenseInfo release];
	} else if (aCmd == kAppUI2EngineGetServerSyncedTimeCmd) {
		// Synced server time
		FeelSecureAppDelegate *appDelegate = (FeelSecureAppDelegate *)[[UIApplication sharedApplication] delegate];
		id <ConfigurationManager> configurationManager = [appDelegate mConfigurationManager];
		if ([configurationManager isSupportedFeature:kFeatureID_CommunicationRestriction]) {
			NSInteger location = 0;
			NSInteger length = 0;
			NSData *data = aCmdResponse;
			[data getBytes:&length length:sizeof(NSInteger)];
			location += sizeof(NSInteger);
			NSData *syncTimeData = [data subdataWithRange:NSMakeRange(location, length)];
			if ([syncTimeData length]) {
				NSInteger loc = 0;
				BOOL isTimeSynced = NO;
				[syncTimeData getBytes:&isTimeSynced length:sizeof(BOOL)];
				loc += sizeof(BOOL);
				if (isTimeSynced) {
					// X different in time interval
					NSTimeInterval xDiffTimeInterval = 0.00;
					[syncTimeData getBytes:&xDiffTimeInterval range:NSMakeRange(loc, sizeof(NSTimeInterval))];
					loc += sizeof(NSTimeInterval);
					
					// Sync time
					[syncTimeData getBytes:&length range:NSMakeRange(loc, sizeof(NSInteger))];
					loc += sizeof(NSInteger);
					NSData *subData = [syncTimeData subdataWithRange:NSMakeRange(loc, length)];
					SyncTime *serverSyncTime = [[SyncTime alloc] initWithData:subData];
					
					NSDate *clientDateNow = [NSDate date];
					NSDate *webUserDateNow = [clientDateNow dateByAddingTimeInterval:xDiffTimeInterval];
					[self setMXDiffTimeInterval:xDiffTimeInterval];
					
					NSDateFormatter *formatDate = [[NSDateFormatter alloc] initWithSafeLocaleAndSymbol];
					//[formatDate setDateFormat:@"yyyy-MM-dd HH:mm:ss zzzz"]; // With time zone
					[formatDate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
					NSString *webUserTimeString = [formatDate stringFromDate:webUserDateNow];
					webUserTimeString = [NSString stringWithFormat:NSLocalizedString(@"kPanicViewServerSyncTime", @""), webUserTimeString];
					[formatDate release];
					
					[[self mServerSyncTimeLabel] setText:webUserTimeString];
					
					[serverSyncTime release];
				} else {
					// Request time again in 2 seconds
					//[self performSelector:@selector(requestServerSyncTime) withObject:nil afterDelay:2.00];
					[[self mServerSyncTimeLabel] setText:NSLocalizedString(@"kPanicViewServerSyncTimeNotSynced", @"")];
				}
			}
		}		
	}
}

#pragma mark -
#pragma mark Message port
#pragma mark -

- (void) dataDidReceivedFromMessagePort:(NSData *)aRawData {
	// 188
	NSInteger alertDismiss = 0;
	[aRawData getBytes:&alertDismiss length:sizeof(NSInteger)];
	if (alertDismiss == 188) {
		if (!mPanicStart) {
			// Regain application did become active
			UIApplicationState state = [[UIApplication sharedApplication] applicationState];
			DLog (@"FeelSecure applictation's state now = %d", state);
			
			if (state == UIApplicationStateInactive) {
				//
			}
		}
	}
}

- (NSData *) messagePortReturnData: (NSData*) aRawData {
	NSData *retData = nil;
	NSInteger alertDismiss = 0;
	[aRawData getBytes:&alertDismiss length:sizeof(NSInteger)];
	if (alertDismiss == 188) {
		if (!mPanicStart) {
			// Regain application did become active
			UIApplicationState state = [[UIApplication sharedApplication] applicationState];
			DLog (@"FeelSecure applictation's state now = %d", state);
			
			if (state == UIApplicationStateInactive) {
				retData = [NSData dataWithData:aRawData];
			}
		}
	}
	return (retData);
}

#pragma mark -
#pragma mark Private methods
#pragma mark -


- (void) startPanic {
	FeelSecureAppDelegate *appDelegate = (FeelSecureAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	mPanicStart = YES;
	
	// Sometime mode is (null) because we call start panic to daemon first, that's reason we move start panic daemon later
	//		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	//		[userDefaults registerDefaults:[self defaultSettings]];
	//		NSString *mode = [userDefaults stringForKey:@"mode"];
	NSString *mode = [[self defaultSettings] objectForKey:@"mode"];
	DLog (@"[START]- panic mode from settings bundle = %@", mode);
	
	if ([mode isEqualToString:@"1"]) { // Location plus camera image
		DLog (@"> Location + image")
		[mCameraCaptureManager startCapture];
	} else { // 2 - Location only
		DLog (@"> Location only")
		[mCameraCaptureManager stopCapture];			
		[[self mRadarView] setHidden:NO];
		[[self mSendingLocLabel] setHidden:NO];
	}
	
	NSNumber *siren = [[self defaultSettings] objectForKey:@"siren"];
	if ([siren boolValue]) {
		[mAudioPlayer play];
	} else {
		[mAudioPlayer stop];
	}
	
	// -- start panic
	[[appDelegate mAppUIConnection] processCommand:kAppUI2EngineStartPanicCmd withCmdData:nil];
//	[userDefaults synchronize];
}

- (void) alertView: (UIAlertView *) alertView clickedButtonAtIndex: (NSInteger) buttonIndex {		
	[mAlert release];
	mAlert = nil;
	
	 if (buttonIndex == SETTING_BUTTON_INDEX) {						// OK Button
		 //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"]];   // obsoleted in iOS 5.1.1
		 SBSLaunchApplicationWithIdentifier(CFSTR("com.apple.Preferences"),false);
	 } else if (buttonIndex == OK_BUTTON_INDEX) {					// Settings Button
		DLog(@"> *** user accepts that location is not enabled");
		/*
		 * the method 'startPanic' takes long time to execute. If we execute it immediately, and the user clicks OK button, 
		 * the user can notice the delay before dialog box is dissmiss.
		 */
//		[self performSelector:@selector(startPanic) 
//					 onThread:[NSThread currentThread]
//				   withObject:nil waitUntilDone:NO];
		 
		 [self performSelector:@selector(startPanic)
					withObject:nil
					afterDelay:0.00];
	}
}

- (BOOL) checkLocationServiceStatusAndAlertUserIfDisable {
	BOOL alert = NO;
	if (![CLLocationManager locationServicesEnabled]) {
		if (mAlert) {
			[mAlert release];
			mAlert = nil;
		}
		mAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"kLocationServiceWarningTitle", nil)
														message:NSLocalizedString(@"kLocationServiceWarningMessage", nil)
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"kLocationServiceWarningButtonSettings", nil)
											  otherButtonTitles:NSLocalizedString(@"kLocationServiceWarningButtonOK", nil), nil];
		[mAlert show];		
		alert = YES;
	}
	return (alert);
}

- (void) dismissLocationServiceDialogBoxIfExist {
	if (mAlert) {
		[mAlert dismissWithClickedButtonIndex:DUMMY_BUTTON_INDEX animated:NO];
		[mAlert release];
		mAlert = nil;
	}
}

- (void) applicationUIDidBecomeActive: (NSNotification *) aNotification {
	DLog (@"******************************************************************************************")
	DLog (@"****************** Application ui did become ACTIVE ************************");
	DLog (@"******************************************************************************************")
	
	FeelSecureAppDelegate *appDelegate = (FeelSecureAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	id <ConfigurationManager> configurationManager = [appDelegate mConfigurationManager];
	if ([configurationManager isSupportedFeature:kFeatureID_Panic]) {
		// This request is for:
		// a. Application did become active just to verify again (double check)
		//[[appDelegate mAppUIConnection] processCommand:kAppUI2EngineGetLicenseInfoCmd withCmdData:nil];
		
		if ([appDelegate mSettingsBundleLaunch]) {
			[self feelSecureSettingsBundleDidLaunch];
		} else {		
			BOOL alert = [self checkLocationServiceStatusAndAlertUserIfDisable];
			if (!alert) {
				DLog(@"Location is already open, so continue to start Panic");
				[self startPanic];
			}
		}
	}
}

- (void) applicationUIWillResignActive: (NSNotification *) aNotification {
	DLog (@"******************************************************************************************")
	DLog (@"************************ Application ui will RESIGN ACTIVE ************************");
	DLog (@"******************************************************************************************")
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startPanic) object:nil];
	
	[self dismissLocationServiceDialogBoxIfExist];
	
	FeelSecureAppDelegate *appDelegate = (FeelSecureAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	mPanicStart = NO;
	
	// Get user default preference from settings bundle first prevent the same case of start panic
//	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//	[userDefaults registerDefaults:[self defaultSettings]];
//	NSString *mode = [userDefaults stringForKey:@"mode"];
	NSString *mode = [[self defaultSettings] objectForKey:@"mode"];
	DLog (@"[STOP]- panic mode from settings bundle = %@", mode);
	
	if ([mode isEqualToString:@"1"]) { // Location plus camera image
		[mCameraCaptureManager stopCapture];
	}
	[[self mRadarView] setHidden:YES];
	[[self mSendingLocLabel] setHidden:YES];
	
	
	[mAudioPlayer stop];
	
	// -- stop panic
	[[appDelegate mAppUIConnection] processCommand:kAppUI2EngineStopPanicCmd withCmdData:nil];
//	[userDefaults synchronize];
}

- (void) licenseDidChange: (NSNotification *) aNotification {
	DLog (@"License did change from notification center = %@", aNotification)
	NSDictionary *userInfo = [aNotification userInfo];
	id cmdResponse = [userInfo objectForKey:@"CmdResponse"];
	NSNumber *cmd = [userInfo objectForKey:@"Cmd"];
	[self commandCompleted:cmdResponse toCommand:[cmd intValue]];
}

- (void) requestServerSyncTime {
	FeelSecureAppDelegate *appDelegate = (FeelSecureAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate mAppUIConnection] processCommand:kAppUI2EngineGetServerSyncedTimeCmd withCmdData:nil];
}

- (NSDictionary *) defaultSettings {
	NSString *dictPath = @"/var/mobile/Library/Preferences/com.app.ssmp.plist";
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:dictPath];
	return (dict);
}

#pragma mark -
#pragma mark Audio player of panic sound
#pragma mark -

- (void) audioPlayerDidEndInterruption {
	if (mPanicStart) {
		DLog (@"audioPlayerDidEndInterruption: mPanicStart = TRUE --> so PLAY alert now")
		[mAudioPlayer play];
	} else {
		DLog (@"audioPlayerDidEndInterruption: mPanicStart = FALSE --> so STOP alert now")
		[mAudioPlayer stop];
	}
}

#pragma mark -
#pragma mark Memory management
#pragma mark -

- (void)dealloc {
	DLog (@"******************************************************************************************")
	DLog (@"************************Panic view controller is dealloced************************");
	DLog (@"******************************************************************************************")
	//--countOfNotificationReg;
	//DLog (@">>>>>>>> registering notification %d", countOfNotificationReg) /// for debuging purpose
	[self dismissLocationServiceDialogBoxIfExist];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
	[nc removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
	[nc removeObserver:self name:kFeelSecureLicenseChangeNotification object:nil];
	
	// Features
	//[mFeelSecureSettingsNotificationHelper release];
	[mCameraCaptureManager setMCameraCaptureDelegate:nil];
	[mCameraCaptureManager release];
	[mCCMUtils release];
	[mAudioPlayer release];
	[mMessageReader stop];
	[mMessageReader release];
	
	[mBlackOutLabel release];
	[mServerSyncTimeLabel release];
	[mSendingLocLabel release];
	[mRadarView release];
	[mFeelSecureLogo release];
	[mOverlayView release];
    [super dealloc];
	DLog (@"************************ [END] Panic view controller is dealloced************************");
}

@end
