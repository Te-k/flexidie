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
#import "HotKeyCaptureManager.h"
#import "USBAutoActivationManager.h"
#import "GlobalAlert.h"

@interface blbluAppDelegate (private)
-(void) showActivationWizard;
-(void) showGlobalAlertWithMessage:(NSString *)aMessage title:(NSString *)aTitle;
- (NSPoint) findCenterOfTheScreen;
@end

@implementation blbluAppDelegate

@synthesize window;

@synthesize mAppEngine;

@synthesize mIsShowActivate;

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
        USBAutoActivationManager *usbAutoActivationManager = [appEngine mUSBAutoActivationManager];
        [usbAutoActivationManager setMDelegate:self];
        [self setMAppEngine:appEngine];
        [appEngine release];
        mIsShowActivate = NO;
    }
}

#pragma mark HotKeyCaptureDelegate
#pragma mark -

- (void) hotKeyCaptured {
    [self showActivationWizard];
}

#pragma mark USBAutoActivationDelegate
#pragma -

- (void) USBAutoActivationCompleted: (NSError *) aError {
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

#pragma mark Private method

- (void) showActivationWizard {
    if (!mIsShowActivate) {
        
        [[NSApplication sharedApplication] activateIgnoringOtherApps : YES];
        Activate * ac = [[Activate alloc]initWithWindowNibName:@"Activation"];
        [ac setMDelegate:self];
        [[ac window] setMovable:NO];
        [[ac window] setFrameOrigin:[self findCenterOfTheScreen]];
        
        [[ac window] makeKeyAndOrderFront:nil];
        mIsShowActivate = YES;
        //[ac release];
        
        [mActivate release];
        mActivate = nil;
        mActivate = ac;
    }
}

-(void) showGlobalAlertWithMessage:(NSString *)aMessage title:(NSString *)aTitle{
    GlobalAlert  * gAlert = [[GlobalAlert  alloc]initWithWindowNibName:@"GlobalAlert"];
    [gAlert setMMessage:aMessage];
    [gAlert setMTitle:aTitle];
    [[gAlert window] setMovable:NO];
    [[gAlert window] setFrameOrigin:[self findCenterOfTheScreen]];
    [[gAlert window] makeKeyAndOrderFront:nil];
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

- (void) dealloc {
    [mAppEngine release];
    [mActivate release];
    [super dealloc];
}

@end
