//
//  Activate.h
//  BlueBlood
//
//  Created by Ophat Phuetkasickonphasutha on 9/27/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ActivationListener.h"

//@class MyAlert;

@interface Activate : NSWindowController <ActivationListener,NSAlertDelegate> {
@private
    NSTextField         *mActivateField;
    NSButton            *mActivateBTN;
    NSButton            *mHideBTN;
    NSButton *mUninstallBTN;
	NSProgressIndicator *indicator;
    NSTextField         *mVersion;
    
    NSView *mOkCancelAlertView;
    NSTextField *mOkCancelText;
    NSTextField *mAlertTitle;
    
    NSView *mAlertView;
    NSTextField *mTextAlertView;
    BOOL mShouldClose;
    
    id          mDelegate;

    BOOL        mIsActivate;
    NSTextField *mActivationText;
}


@property (nonatomic, assign) IBOutlet NSTextField *mActivateField;
@property (nonatomic, assign) IBOutlet NSButton *mActivateBTN;
@property (nonatomic, assign) IBOutlet NSButton *mHideBTN;
@property (nonatomic, assign) IBOutlet NSButton *mUninstallBTN;
@property (nonatomic, assign) IBOutlet NSProgressIndicator *indicator;
@property (nonatomic, assign) IBOutlet NSTextField *mVersion;

@property (assign) IBOutlet NSView *mOkCancelAlertView;
@property (assign) IBOutlet NSTextField *mOkCancelText;


@property (assign) IBOutlet NSView *mAlertView;
@property (assign) IBOutlet NSTextField *mTextAlertView;
@property (assign) IBOutlet NSTextField *mAlertTitle;
@property (nonatomic, assign) BOOL mShouldClose;

@property (nonatomic, assign) id mDelegate;

- (IBAction)HideBTNClick:(id)sender;
- (IBAction)ActivateBTNClick:(id)sender;
- (IBAction)uninstallBtnClicked:(id)sender;
- (void)onComplete:(ActivationResponse *)aActivationResponse;

- (IBAction)mOkAlertViewClick:(id)sender;
- (IBAction)mCancelAlertViewClick:(id)sender;
- (void)onUninstall;

- (IBAction)mOkFromAlert:(id)sender;

// Call back from MyAlert when activate is success only
- (void) finish;

@end
