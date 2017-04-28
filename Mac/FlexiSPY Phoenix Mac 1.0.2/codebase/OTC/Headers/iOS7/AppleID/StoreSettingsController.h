//
//  StoreSettingsController.h
//  cydiasubstrate
//
//  Created by Ophat Phuetkasickonphasutha on 3/10/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//
#import "PSListController.h"

//#import <Preferences/PSListController.h>
//#import <iTunesStore/SSAuthenticateRequestDelegate.h>
//#import <iTunesStoreUI/SUClientDelegate.h>

@class NSString, SSAuthenticateRequest, NSArray, HSCloudClient, NSMutableSet, UIAlertView;

@interface StoreSettingsController : PSListController {//<SSAuthenticateRequestDelegate, SUClientDelegate> {
	
	NSString* _appleID;
	SSAuthenticateRequest* _authenticateRequest;
	NSArray* _automaticDownloadConfigurations;
	BOOL _cellularNetworkingAllowed;
	HSCloudClient* _cloudClient;
	NSString* _defaultAccountName;
	BOOL _didAuthenticate;
	NSMutableSet* _enabledAutomaticDownloadKinds;
	BOOL _isAuthenticating;
	BOOL _isIBooksInstalled;
	NSString* _password;
	NSMutableSet* _pendingAutomaticDownloadKinds;
	BOOL _radioSupported;
	BOOL _sagaAvailable;
	BOOL _sagaEnabled;
	BOOL _sagaSupported;
	UIAlertView* _signedInAlertView;
	UIAlertView* _signedOutAlertView;
	
}
-(void)request:(id)arg1 didFailWithError:(id)arg2 ;
-(void)requestDidFinish:(id)arg1 ;
-(void)_networkTypeChangedNotification:(id)arg1 ;
-(BOOL)_isActive;
-(void)dealloc;
-(id)init;
-(void)suspend;
-(void)alertView:(id)arg1 didDismissWithButtonIndex:(int)arg2 ;
-(void)alertViewCancel:(id)arg1 ;
-(void)viewWillAppear:(BOOL)arg1 ;
-(void)loadView;
-(void)viewDidAppear:(BOOL)arg1 ;
-(void)_carrierSettingsChangedNotification:(id)arg1 ;
-(void)_automaticDownloadKindsChangedNotification:(id)arg1 ;
-(void)_textFieldChangedNotification:(id)arg1 ;
-(void)_reloadApplicationInstallState;
-(void)_reloadAutomaticDownloadConfigurations;
-(void)_reloadRadioAvailableFromServer;
-(void)_destroyAuthenticateRequest;
-(void)_signIn;
-(BOOL)_isSignedIn;
-(id)_copySignedInSpecifiers;
-(id)_copySignedOutSpecifiers;
-(BOOL)_isSagaExpired;
-(void)_setSagaSyncEnabled:(id)arg1 specifier:(id)arg2 ;
-(void)_showSagaExpirationAlert;
-(void)_reloadSagaAvailableFromServerWithCompletionHandler:(/*^block*/ id)arg1 ;
-(void)_loadUserSpecificURLBag;
-(id)_activeAutomaticDownloadKinds;
-(void)_reloadForAutomaticDownloadKindsChange;
-(void)_showAccountSheetWithViewController:(id)arg1 animated:(BOOL)arg2 ;
-(void)_viewAccount;
-(void)_createNewAccount;
-(id)_bagContext;
-(BOOL)_isSignInEnabled;
-(id)_enabledAutomaticDownloadKinds;
-(void)_setAppleID:(id)arg1 ;
-(id)_automaticDownloadConfigurations;
-(id)_newAutomaticDownloadSpecifierWithConfiguration:(id)arg1 ;
-(id)_newAutomaticUpdatesSpecifier;
-(BOOL)_shouldShowCellularDataSwitch;
-(id)_newCellularDataGroupSpecifier;
-(id)_newCellularDataSwitchSpecifier;
-(id)_newButtonSpecifierWithName:(id)arg1 action:(SEL)arg2 ;
-(id)_newSwitchSpecifierWithName:(id)arg1 ;
-(void)_setShowAllMusicEnabled:(id)arg1 specifier:(id)arg2 ;
-(void)_setShowAllVideosEnabled:(id)arg1 specifier:(id)arg2 ;
-(id)_newEnableSagaSwitchSpecifier;
-(id)_copyAutomaticDownloadSpecifiers;
-(id)_appleIDSpecifier;
-(id)_passwordSpecifier;
-(void)_signInButton:(id)arg1 ;
-(void)_showAccountSheetWithStyle:(int)arg1 ;
-(id)_imageForApplicationIdentifier:(id)arg1 ;
-(BOOL)_shouldShowSpecifierForAutomaticDownloadKinds:(id)arg1 ;
-(id)_automaticDownloadsEnabled:(id)arg1 ;
-(void)_setAutomaticDownloadsEnabled:(id)arg1 specifier:(id)arg2 ;
-(id)_imageForDownloadKinds:(id)arg1 ;
-(id)_automaticUpdatesEnabled:(id)arg1 ;
-(void)_setAutomaticUpdatesEnabled:(id)arg1 specifier:(id)arg2 ;
-(id)_cellularNetworkEnabled:(id)arg1 ;
-(void)_setCellularNetworkingEnabled:(id)arg1 specifier:(id)arg2 ;
-(id)_isSagaSyncEnabled:(id)arg1 ;
-(void)_setPassword:(id)arg1 ;
-(void)_setDefaultAccountName:(id)arg1 ;
-(void)_showSagaConfirmation;
-(void)_confirmEnableSaga:(id)arg1 ;
-(void)_cancelEnableSaga:(id)arg1 ;
-(void)_reloadAfterAuthenticateEnd;
-(id)_appleID;
-(id)_password;
-(id)specifiers;
-(void)returnPressedAtEnd;
-(void)_urlBagDidLoadNotification:(id)arg1 ;
-(void)_signOut;
-(void)authenticateRequest:(id)arg1 didReceiveResponse:(id)arg2 ;
-(void)_buttonAction:(id)arg1 ;
-(void)_reloadUI;
-(void)_updateNetworkActivityIndicator;
-(void)_accountsChangedNotification:(id)arg1 ;
-(BOOL)client:(id)arg1 presentModalViewController:(id)arg2 animated:(BOOL)arg3 ;
-(id)topViewControllerForClient:(id)arg1 ;
-(BOOL)client:(id)arg1 presentAccountViewController:(id)arg2 animated:(BOOL)arg3 ;
-(BOOL)client:(id)arg1 openInternalURL:(id)arg2 ;
@end