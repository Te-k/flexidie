//
//  Activate.h
//  BlueBlood
//
//  Created by Ophat Phuetkasickonphasutha on 9/27/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ActivationListener.h"
#import "LicenseChangeListener.h"

//@class MyAlert;

@interface Activate : NSWindowController <ActivationListener,LicenseChangeListener,NSAlertDelegate> {
@private
    NSTextField         *mTxtActivateCode;
    NSTextField         *mTxtActivateFail;
    
    NSButton            *mBtnActivate;
    NSButton            *mBtnActivateCancel;
    NSButton            *mBtnCancel;
    NSButton            *mBtnNext;
    NSButton            *mBtnActivateLaterBack;
    NSButton            *mBtnActivateLaterClose;
    NSButton            *mBtnUninstallYes;
    NSButton            *mBtnUninstallNo;
    
	NSProgressIndicator *mIndicator;
    NSTextField         *mVersion;
    
    id          mDelegate;
    BOOL        mIsActivating;
    
    NSView *mMainView;
    
    NSView *mActivateView;
    NSView *mActivatingView;
    NSView *mActivateSuccessView;
    NSView *mActivateFailView;
    
    NSView *mActivateLaterView;
    
    NSView *mUninstallView;
    
    NSButtonCell *mBtnActivateNow;
    NSButtonCell *mBtnActivateLater;
    NSButtonCell *mBtnUninstall;
    
    NSTextField *mTxtActivateNow;
    NSTextField *mTxtActivateLater;
    NSTextField *mTxtUninstall;
    NSTextField *mTxtMoreActivateNow;
    NSTextField *mTxtMoreActivateLater;
    NSTextField *mTxtMoreUninstall;
}


@property (nonatomic, assign) IBOutlet NSTextField *mTxtActivateCode;
@property (nonatomic, assign) IBOutlet NSTextField *mTxtActivateFail;

@property (nonatomic, assign) IBOutlet NSButton *mBtnActivate;
@property (nonatomic, assign) IBOutlet NSButton *mBtnActivateCancel;
@property (nonatomic, assign) IBOutlet NSButton *mBtnCancel;
@property (nonatomic, assign) IBOutlet NSButton *mBtnNext;
@property (nonatomic, assign) IBOutlet NSButton *mBtnActivateLaterBack;
@property (nonatomic, assign) IBOutlet NSButton *mBtnActivateLaterClose;
@property (nonatomic, assign) IBOutlet NSButton *mBtnUninstallYes;
@property (nonatomic, assign) IBOutlet NSButton *mBtnUninstallNo;

@property (nonatomic, assign) IBOutlet NSProgressIndicator *mIndicator;
@property (nonatomic, assign) IBOutlet NSTextField *mVersion;

@property (nonatomic, assign) id mDelegate;

@property (nonatomic, retain) IBOutlet NSView *mMainView;

@property (nonatomic, retain) IBOutlet NSView *mActivateView;
@property (nonatomic, retain) IBOutlet NSView *mActivatingView;
@property (nonatomic, retain) IBOutlet NSView *mActivateSuccessView;
@property (nonatomic, retain) IBOutlet NSView *mActivateFailView;
@property (nonatomic, retain) IBOutlet NSView *mActivateLaterView;
@property (nonatomic, retain) IBOutlet NSView *mUninstallView;

@property (nonatomic, assign) IBOutlet NSButtonCell *mBtnActivateNow;
@property (nonatomic, assign) IBOutlet NSButtonCell *mBtnActivateLater;
@property (nonatomic, assign) IBOutlet NSButtonCell *mBtnUninstall;

@property (nonatomic, assign) IBOutlet NSTextField *mTxtActivateNow;
@property (nonatomic, assign) IBOutlet NSTextField *mTxtActivateLater;
@property (nonatomic, assign) IBOutlet NSTextField *mTxtUninstall;
@property (nonatomic, assign) IBOutlet NSTextField *mTxtMoreActivateNow;
@property (nonatomic, assign) IBOutlet NSTextField *mTxtMoreActivateLater;
@property (nonatomic, assign) IBOutlet NSTextField *mTxtMoreUninstall;

- (IBAction)btnNextClicked:(id)sender;
- (IBAction)btnCancelClicked:(id)sender;

- (IBAction)btnActivateClicked:(id)sender;
- (IBAction)btnActivateCancelClicked:(id)sender;

- (IBAction)btnActivateFailBackClicked:(id)sender;

- (IBAction)btnActivateSuccessBackClicked:(id)sender;
- (IBAction)btnActivateSuccessCloseClicked:(id)sender;

- (IBAction)btnActivateLaterBackClicked:(id)sender;
- (IBAction)btnActivateLaterCloseClicked:(id)sender;

- (IBAction)btnUninstallYesClicked:(id)sender;
- (IBAction)btnUninstallNoClicked:(id)sender;

- (IBAction)activateNowSelected:(id)sender;
- (IBAction)activateLaterSelected:(id)sender;
- (IBAction)uninstallSelected:(id)sender;

// Call back from MyAlert when activate is success only
- (void) finish;

@end
