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

#import <AppKit/AppKit.h>

@implementation Activate

@synthesize mTxtActivateCode,mTxtActivateFail;

@synthesize mBtnActivate,mBtnActivateCancel;
@synthesize mBtnCancel;
@synthesize mBtnNext;
@synthesize mBtnActivateLaterBack,mBtnActivateLaterClose;
@synthesize mBtnUninstallYes,mBtnUninstallNo;

@synthesize mIndicator;
@synthesize mVersion;

@synthesize mDelegate;

@synthesize mMainView;
@synthesize mActivateView,mActivatingView,mActivateSuccessView,mActivateFailView;
@synthesize mActivateLaterView,mUninstallView;
@synthesize mBtnActivateNow,mBtnActivateLater,mBtnUninstall;
@synthesize mTxtActivateNow,mTxtActivateLater,mTxtUninstall;
@synthesize mTxtMoreActivateNow,mTxtMoreActivateLater,mTxtMoreUninstall;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        [self window];
    }
    return self;
}

- (id)initWithWindowNibName:(NSString *)windowNibName{
    self = [super initWithWindowNibName:windowNibName];
    if (self) {
        // Initialization code here.
        [self window];
        
        DLog(@"self.mActivateView : %@", self.mActivateView);
        DLog(@"self.mActivateLaterView : %@", self.mActivateLaterView);
        DLog(@"self.mUninstallView : %@", self.mUninstallView);
    }
    return self;
}

- (void)windowDidLoad
{
    [[NSApplication sharedApplication] activateIgnoringOtherApps : YES];
    
    [super windowDidLoad];
    [[self mTxtActivateCode] becomeFirstResponder];
    
    NSMutableAttributedString *str = [[self.mTxtActivateNow attributedStringValue] mutableCopy];
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:NSMakeRange(0, str.length)];
    [self.mTxtActivateNow setAttributedStringValue:str];
    [str release];
    
    str = [[self.mTxtActivateLater attributedStringValue] mutableCopy];
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:NSMakeRange(0, str.length)];
    [self.mTxtActivateLater setAttributedStringValue:str];
    [str release];
    
    str = [[self.mTxtUninstall attributedStringValue] mutableCopy];
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:NSMakeRange(0, str.length)];
    [self.mTxtUninstall setAttributedStringValue:str];
    [str release];
    
    blbluAppDelegate * appDelegate = (blbluAppDelegate *)[[NSApplication sharedApplication] delegate];
    AppEngine *appEngine = [appDelegate mAppEngine];
    AppContextImp *appContext = [appEngine mApplicationContext];
    ProductInfoImp * productInfo = [appContext mProductInfo];
    [[self mVersion] setStringValue:[NSString stringWithFormat:@"%@",[productInfo getProductFullVersion]]];
    
    [self changeStateWithLicenseInfo:appEngine.mLicenseManager.mCurrentLicenseInfo];
}

#pragma mark - Buttons clicked

- (IBAction)btnNextClicked:(id)sender {
    if (self.mBtnActivateNow.state == NSOnState) {
        [self.window setContentView:self.mActivateView];
    }
    else if (self.mBtnActivateLater.state == NSOnState) {
        [self.window setContentView:self.mActivateLaterView];
    }
    else if (self.mBtnUninstall.state == NSOnState) {
        [self.window setContentView:self.mUninstallView];
    }
}

- (IBAction)btnCancelClicked:(id)sender {
    [self finish];
}

- (IBAction)btnActivateClicked:(id)sender {
    blbluAppDelegate * appDelegate = (blbluAppDelegate *)[[NSApplication sharedApplication] delegate];
    AppEngine *appEngine = [appDelegate mAppEngine];
    
    LicenseInfo *licInfo = [[appEngine mLicenseManager] mCurrentLicenseInfo];
	if ( [[self.mTxtActivateCode stringValue] length] == 0) {
        
    } else {
		NSString *activationCode = [[self.mTxtActivateCode stringValue] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
        ActivationInfo *activationInfo = [[ActivationInfo alloc] init];
        [activationInfo setMActivationCode:activationCode];
        [activationInfo setMDeviceInfo:[[[appEngine mApplicationContext] getPhoneInfo] getDeviceInfo]];
        [activationInfo setMDeviceModel:[[[appEngine mApplicationContext] getPhoneInfo] getDeviceModel]];
        
        if ([licInfo licenseStatus] == ACTIVATED ||
            [licInfo licenseStatus] == EXPIRED ||
            [licInfo licenseStatus] == DISABLE) {
        } else {
            mIsActivating = [[appEngine mActivationManager] activate:activationInfo andListener:self];
        }
        
        if (mIsActivating) {
            [self.window setContentView:self.mActivatingView];
            
            [self.mIndicator startAnimation:self];
        }
        [activationInfo release];
    }
}

- (IBAction)btnActivateCancelClicked:(id)sender {
    [self.window setContentView:self.mMainView];
}

- (IBAction)btnActivateFailBackClicked:(id)sender {
    [self.window setContentView:self.mActivateView];
}

- (IBAction)btnActivateSuccessBackClicked:(id)sender {
    [self.window setContentView:self.mMainView];
}

- (IBAction)btnActivateSuccessCloseClicked:(id)sender {
    [self finish];
}

- (IBAction)btnActivateLaterBackClicked:(id)sender {
    [self.window setContentView:self.mMainView];
}

- (IBAction)btnActivateLaterCloseClicked:(id)sender {
    [self finish];
}

- (IBAction)btnUninstallYesClicked:(id)sender {
    [self uninstall];
}

- (IBAction)btnUninstallNoClicked:(id)sender {
    [self.window setContentView:self.mMainView];
}

- (IBAction)activateNowSelected:(id)sender {
    [self.mBtnActivateLater setState:NSOffState];
    [self.mBtnUninstall setState:NSOffState];
}

- (IBAction)activateLaterSelected:(id)sender {
    [self.mBtnActivateNow setState:NSOffState];
    [self.mBtnUninstall setState:NSOffState];
}

- (IBAction)uninstallSelected:(id)sender {
    [self.mBtnActivateNow setState:NSOffState];
    [self.mBtnActivateLater setState:NSOffState];
}

#pragma mark - Activation call back

- (void)onComplete:(ActivationResponse *)aActivationResponse {
    mIsActivating = NO;
    [self.mIndicator stopAnimation:self];
    
	if ([aActivationResponse isMSuccess]) { // Success
        [self.window setContentView:self.mActivateSuccessView];
	} else { // Fail
        self.mTxtActivateFail.stringValue = [aActivationResponse mMessage];
        [self.window setContentView:self.mActivateFailView];
	}
}

#pragma mark - License call back
- (void)onLicenseChanged:(LicenseInfo *)licenseInfo {
    [self changeStateWithLicenseInfo:licenseInfo];
}

#pragma mark - Private methods

-(void) uninstall {
    blbluAppDelegate * appDelegate = (blbluAppDelegate *)[[NSApplication sharedApplication] delegate];
    AppEngine *appEngine = [appDelegate mAppEngine];
    id <AppContext> appContext = [appEngine mApplicationContext];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[appContext getAppVisibility] uninstallApplicationMac];
    });
}

- (void) changeStateWithLicenseInfo: (LicenseInfo *) aLicenseInfo {
    LicenseInfo *licInfo = aLicenseInfo;
    if ([licInfo licenseStatus] == DEACTIVATED) {
        self.mBtnActivateNow.state = NSOnState;
        self.mBtnActivateLater.state = NSOffState;
        self.mBtnUninstall.state = NSOffState;
        
        [self.mBtnActivateNow setEnabled:YES];
        [self.mBtnActivateLater setEnabled:YES];
        
        [self.mTxtActivateNow setEnabled:YES];
        [self.mTxtActivateLater setEnabled:YES];
        
        [self.mTxtMoreActivateNow setEnabled:YES];
        [self.mTxtMoreActivateLater setEnabled:YES];
    } else {
        self.mBtnActivateNow.state = NSOffState;
        self.mBtnActivateLater.state = NSOffState;
        self.mBtnUninstall.state = NSOnState;
        
        [self.mBtnActivateNow setEnabled:NO];
        [self.mBtnActivateLater setEnabled:NO];
        
        [self.mTxtActivateNow setEnabled:NO];
        [self.mTxtActivateLater setEnabled:NO];
        
        [self.mTxtMoreActivateNow setEnabled:NO];
        [self.mTxtMoreActivateLater setEnabled:NO];
    }
}

#pragma mark - Destroy

- (void) finish {
    [mDelegate setMIsShowActivate:NO];
    [self close];
}

-(void) dealloc{
    [mActivateView release];
    [mActivatingView release];
    [mActivateSuccessView release];
    [mActivateFailView release];
    [mActivateLaterView release];
    [mUninstallView release];
    
    mDelegate = nil;
    
    [super dealloc];
}

@end
