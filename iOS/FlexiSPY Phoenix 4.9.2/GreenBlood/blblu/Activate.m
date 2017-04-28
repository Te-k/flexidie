//
//  Activate.m
//  BlueBlood
//
//  Created by Ophat Phuetkasickonphasutha on 9/27/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Activate.h"
#import "blbluAppDelegate.h"

#import "AppEngine.h"
#import "ActivationInfo.h"
#import "ActivationManager.h"
#import "AppContextImp.h"
#import "ActivationResponse.h"
#import "LicenseManager.h"
#import "LicenseInfo.h"
#import "AppContext.h"
#import "ProductInfoImp.h"

@implementation Activate

@synthesize mActivateField;
@synthesize mActivateBTN;
@synthesize mHideBTN;
@synthesize mUninstallBTN;
@synthesize indicator;
@synthesize mVersion;
@synthesize mOkCancelAlertView;
@synthesize mOkCancelText;
@synthesize mAlertTitle;
@synthesize mAlertView;
@synthesize mTextAlertView;
@synthesize mDelegate;
@synthesize mShouldClose;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        [self window];
    }
    return self;
}

- (void)windowDidLoad
{
    [[NSApplication sharedApplication] activateIgnoringOtherApps : YES];
    
    [super windowDidLoad];
    [[self mActivateField] becomeFirstResponder];
    
    [self.mOkCancelAlertView setHidden:YES];
    [self.mAlertView setHidden:YES];
    mShouldClose = false;
    
    blbluAppDelegate * appDelegate = (blbluAppDelegate *)[[NSApplication sharedApplication] delegate];
    AppEngine *appEngine = [appDelegate mAppEngine];
    AppContextImp *appContext = [appEngine mApplicationContext];
    ProductInfoImp * productInfo = [appContext mProductInfo];
    [[self mVersion] setStringValue:[NSString stringWithFormat:@"%@",[productInfo getProductFullVersion]]];
    LicenseInfo *licInfo = [[appEngine mLicenseManager] mCurrentLicenseInfo];
    if ([licInfo licenseStatus] == DEACTIVATED) {
        [mHideBTN setTitle:@"Activate Later"];
        [mActivateField setEnabled:YES];
        [mActivateBTN setTitle:NSLocalizedString(@"kActivationWindowActivate", @"")];
    } else {
        [mHideBTN setTitle:@"Hide"];
//        [mActivateField setEnabled:NO];
//        [mActivateField setStringValue:[licInfo activationCode]];
        [mActivateBTN setTitle:NSLocalizedString(@"kActivationWindowDeactivate", @"")];
    }
}

- (IBAction)HideBTNClick:(id)sender {
    
    [mDelegate setMIsShowActivate:NO];
    
    blbluAppDelegate * appDelegate = (blbluAppDelegate *)[[NSApplication sharedApplication] delegate];
    AppEngine *appEngine = [appDelegate mAppEngine];
    LicenseInfo *licInfo = [[appEngine mLicenseManager] mCurrentLicenseInfo];
    if ([licInfo licenseStatus] == DEACTIVATED) {
        [self.mAlertTitle setTitleWithMnemonic:@"Alert"];
        [self.mAlertView setHidden:NO];
        [self.mTextAlertView setTitleWithMnemonic:NSLocalizedString(@"kInstalllater", @"")];
        mShouldClose = true;
        [self disableAll];
        
    }else{
        [self finish];
    }
}

- (IBAction)ActivateBTNClick:(id)sender {
    
    blbluAppDelegate * appDelegate = (blbluAppDelegate *)[[NSApplication sharedApplication] delegate];
    AppEngine *appEngine = [appDelegate mAppEngine];
    
    LicenseInfo *licInfo = [[appEngine mLicenseManager] mCurrentLicenseInfo];
	if ( [[self.mActivateField stringValue] length] == 0) {
        
        [self.mAlertTitle setTitleWithMnemonic:@"Error"];
        [self.mAlertView setHidden:NO];
        [self.mTextAlertView setTitleWithMnemonic:NSLocalizedString(@"kInvalidActivationCode", @"")];
        [self disableAll];
        
	} else {
        [mActivateField setEnabled:NO];
        [mActivateBTN setEnabled:NO];
        [mHideBTN setEnabled:NO];
        [mUninstallBTN setEnabled:NO];
        [indicator startAnimation:self];
        
		NSString *activationCode = [[self.mActivateField stringValue] stringByReplacingOccurrencesOfString:@" " withString:@""];


        ActivationInfo *activationInfo = [[ActivationInfo alloc] init];
        [activationInfo setMActivationCode:activationCode];
        [activationInfo setMDeviceInfo:[[[appEngine mApplicationContext] getPhoneInfo] getDeviceInfo]];
        [activationInfo setMDeviceModel:[[[appEngine mApplicationContext] getPhoneInfo] getDeviceModel]];
        BOOL isSubmit = NO;
        
        if ([licInfo licenseStatus] == ACTIVATED ||
            [licInfo licenseStatus] == EXPIRED ||
            [licInfo licenseStatus] == DISABLE) {
            
            if (! [[licInfo activationCode]isEqualToString:activationCode] ) {
                
                [self.mAlertTitle setTitleWithMnemonic:@"Error"];
                [self.mAlertView setHidden:NO];
                [self.mTextAlertView setTitleWithMnemonic:NSLocalizedString(@"kInvalidActivationCode", @"")];
                [self disableAll];
                
            }else{
                isSubmit = [[appEngine mActivationManager] deactivate:self];
                mIsActivate = NO;
            }
        } else {
            isSubmit = [[appEngine mActivationManager] activate:activationInfo andListener:self];
            mIsActivate = YES;
        }
        
        if (!isSubmit) {
            [mActivateField setEnabled:YES];
            [mActivateBTN setEnabled:YES];
            [mHideBTN setEnabled:YES];
            [mUninstallBTN setEnabled:YES];
            [indicator stopAnimation:self];
        }
        [activationInfo release];
            
        
    }
}

- (void)onComplete:(ActivationResponse *)aActivationResponse {
    NSString * message = @"";
	if ([aActivationResponse isMSuccess]) { // Success
        [mActivateBTN setEnabled:YES];
        [mHideBTN setEnabled:YES];
        [mUninstallBTN setEnabled:YES];
        if (mIsActivate) {
            [mActivateField setEnabled:NO];
            [mActivateBTN setTitle:NSLocalizedString(@"kActivationWindowDeactivate", @"")];
            message = [NSString stringWithString:NSLocalizedString(@"kActivationSuccessText", @"")];
            [self.mAlertTitle setTitleWithMnemonic:@"Activation Successful"];
        } else {
            [mActivateField setEnabled:YES];
            [mActivateBTN setTitle:NSLocalizedString(@"kActivationWindowActivate", @"")];
            message = [NSString stringWithString:NSLocalizedString(@"kDeactivationSuccessText", @"")];
            [self.mAlertTitle setTitleWithMnemonic:@"Deactivation Successful"];
        }
	} else { // Fail
        [mActivateBTN setEnabled:YES];
        [mHideBTN setEnabled:YES];
        [mUninstallBTN setEnabled:YES];
        if (mIsActivate) {
            [mActivateField setEnabled:YES];
            [mActivateBTN setTitle:NSLocalizedString(@"kActivationWindowActivate", @"")];
            message = [NSString stringWithString:NSLocalizedString(@"kActivationFailedText", @"")];
            if ([[aActivationResponse mMessage] length] > 0) {
                message = [aActivationResponse mMessage];
            }
             [self.mAlertTitle setTitleWithMnemonic:@"Error"];
        } else {
            [mActivateField setEnabled:NO];
            [mActivateBTN setTitle:NSLocalizedString(@"kActivationWindowDeactivate", @"")];
            message = [NSString stringWithString:NSLocalizedString(@"kDeactivationFailedText", @"")];
            if ([[aActivationResponse mMessage] length] > 0) {
                message = [aActivationResponse mMessage];
                DLog(@"Deactivate failed message: %@", message);
            }
            [self.mAlertTitle setTitleWithMnemonic:@"Error"];
            
//            // ------ Deactivate application anyway ---------
//            [aActivationResponse setMSuccess:YES];
//            message = NSLocalizedString(@"kDeactivationSuccessText", @"");
//            blbluAppDelegate * appDelegate = (blbluAppDelegate *)[[NSApplication sharedApplication] delegate];
//            AppEngine *appEngine = [appDelegate mAppEngine];
//            [[appEngine mLicenseManager] resetLicense];
        }
	}
    mIsActivate = NO;
    [indicator stopAnimation:self];
    
    [self.mAlertView setHidden:NO];
    [self.mTextAlertView setTitleWithMnemonic:message];
    mShouldClose = [aActivationResponse isMSuccess];
    [self disableAll];
}

#pragma mark -Disable/Enable

-(void)disableAll{
    [self.mActivateField setEnabled:NO];
    [self.mActivateBTN setEnabled:NO];
    [self.mHideBTN setEnabled:NO];
    [self.mUninstallBTN setEnabled:NO];
}

-(void)enableAll{
    [self.mActivateField setEnabled:YES];
    [self.mActivateBTN setEnabled:YES];
    [self.mHideBTN setEnabled:YES];
    [self.mUninstallBTN setEnabled:YES];
}

#pragma mark -Uninstall

- (IBAction)uninstallBtnClicked:(id)sender {
    [self.mOkCancelAlertView setHidden:NO];
    [self.mOkCancelText setTitleWithMnemonic:NSLocalizedString(@"kActivationWindowMsg", @"")];
    [self disableAll];
}

-(void)onUninstall {
    blbluAppDelegate * appDelegate = (blbluAppDelegate *)[[NSApplication sharedApplication] delegate];
    AppEngine *appEngine = [appDelegate mAppEngine];
    id <AppContext> appContext = [appEngine mApplicationContext];
    [[appContext getAppVisibility] uninstallApplicationMac];
}

- (IBAction)mOkAlertViewClick:(id)sender {
    [self onUninstall];
}

- (IBAction)mCancelAlertViewClick:(id)sender {
    [self.mOkCancelAlertView setHidden:YES];
    [self enableAll];
}

#pragma mark -Alert

- (IBAction)mOkFromAlert:(id)sender {
    [self.mAlertView setHidden:YES];
    if (mShouldClose) {
         mShouldClose = false;
        [self finish];
    }else{
        [self enableAll];
        
        blbluAppDelegate * appDelegate = (blbluAppDelegate *)[[NSApplication sharedApplication] delegate];
        AppEngine *appEngine = [appDelegate mAppEngine];
        AppContextImp *appContext = [appEngine mApplicationContext];
        ProductInfoImp * productInfo = [appContext mProductInfo];
        [[self mVersion] setStringValue:[NSString stringWithFormat:@"%@",[productInfo getProductFullVersion]]];
        LicenseInfo *licInfo = [[appEngine mLicenseManager] mCurrentLicenseInfo];
        if ([licInfo licenseStatus] == DEACTIVATED) {
            [mHideBTN setTitle:@"Activate Later"];
            [mActivateField setEnabled:YES];
            [mActivateBTN setTitle:NSLocalizedString(@"kActivationWindowActivate", @"")];
        } else {
            [mHideBTN setTitle:@"Hide"];
            //[mActivateField setEnabled:NO];
            //[mActivateField setStringValue:[licInfo activationCode]];
            [mActivateBTN setTitle:NSLocalizedString(@"kActivationWindowDeactivate", @"")];
        }
    }
}

#pragma mark -Destroy

- (void) finish {
    [mDelegate setMIsShowActivate:NO];
    [self close];
}

-(void) dealloc{
    mDelegate = nil;
    [super dealloc];
}

@end
