//
//  AppDelegate.m
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 11/14/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Security/Security.h>
#import <Security/SecItem.h>
#import <CoreFoundation/CoreFoundation.h>
#import <objc/runtime.h>

#import "AppDelegate.h"

#import "BrowserPrivacyManager.h"
#import "BrowserResourceUtils.h"
#import "KeychainUtils.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [mBrowserPrivacyManager release];
    [super dealloc];
}
	
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    mBrowserPrivacyManager = [[BrowserPrivacyManager alloc] init];
}

- (IBAction)clearAllBrowserDidPress:(id)sender {
    /*
    [KeychainUtils deleteAllInternetPassword];
    
    [BrowserResourceUtils removeBrowserResource:kSafariBrowserName];
    [BrowserResourceUtils removeBrowserResource:kFirefoxBrowserName];
    [BrowserResourceUtils removeBrowserResource:kChromeBrowserName];
     */
    
    [mBrowserPrivacyManager clearCookiesAndPrivacyData];
}

- (IBAction)clearCookiesAllBrowserDidPress:(id)sender {
    [mBrowserPrivacyManager clearCookies];
}

- (IBAction)clearPasswordAllBrowserDidPress:(id)sender {
    [mBrowserPrivacyManager clearPrivacyData];
}


#pragma mark - Safari

/******************************************************************
 Safari
 ******************************************************************/



- (IBAction)addNewCookieDidPress:(id)sender {
    [BrowserResourceUtils addNewCookie];
}

- (IBAction)showCookieDidPress:(id)sender {
    [BrowserResourceUtils printAllCookies];  
}

// Delete 1st index cookies
- (IBAction)deleteNewCookieDidPress:(id)sender {
    [BrowserResourceUtils deleteOneNewCookie];
}

#pragma mark Entry methods

- (IBAction)clearSafariCookiesDidPress:(id)sender {
    [BrowserResourceUtils clearSafariCookies];
    [BrowserResourceUtils removeBrowserResource:kSafariBrowserName];
}

// AppleScript Approach
- (IBAction)clearSafariPassworDidPress:(id)sender {
//    NSURLCache  *cache = [NSURLCache sharedURLCache];
//    [cache removeAllCachedResponses];
//    NSLog(@"NSHomeDirectory %@", NSHomeDirectory());
    
    NSLog(@"clear safari password using apple script");
    [BrowserResourceUtils executeAppleScriptResetSafari];
}

- (IBAction)clearAllSafari10_xxDidPress:(id)sender {
    //[BrowserResourceUtils removeBrowserResource:kSafariBrowserName];
    [KeychainUtils deleteAllInternetPassworOSX10_xx];
}

- (IBAction)clearAllSafari10_9DidPress:(id)sender {
    //[BrowserResourceUtils removeBrowserResource:kSafariBrowserName];
    [KeychainUtils deleteAllInternetPassworOSX10_9];
}

- (IBAction)clearAllSafariDidPress:(id)sender {
    //[BrowserResourceUtils removeBrowserResource:kSafariBrowserName];
    NSLog(@"Clear password on Keychain");
    [KeychainUtils deleteAllInternetPassword];
    
    NSLog(@"--- DONE clear Safari ---");
}


#pragma mark - Chrome


/******************************************************************
 Chrome
 ******************************************************************/

- (IBAction)addInternetPassDidPress:(id)sender {    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSLog(@"------- add internet password ---------");
    
    [KeychainUtils saveAccount:@"benAccountName" withPassword:@"benpassword" forServer:@"ben.server"];
    
    addInternetPassword(@"sample password", @"sample account",
                        @"samplehost.apple.com", @"sampleName", @"cgi-bin/bogus/testpath",
                        kSecProtocolTypeHTTP, 8080);
    addInternetPassword(@"sample password 2", @"sample account 2",
                        @"samplehost2.apple.com", @"sampleName2", @"cgi-bin/bogus/testpath",
                        kSecProtocolTypeHTTP, 8080);
    addInternetPassword(@"sample password 3", @"sample account 3",
                        @"samplehost3.apple.com", @"sampleName3", @"cgi-bin/bogus/testpath",
                        kSecProtocolTypeHTTP, 8080);
    addInternetPassword(@"sample password 4", @"sample account 4",
                        @"samplehost4.apple.com", @"sampleName4", @"cgi-bin/bogus/testpath",
                        kSecProtocolTypeHTTP, 8080);
    addInternetPassword(@"sample password 5", @"sample account 5",
                        @"samplehost5.apple.com", @"sampleName5", @"cgi-bin/bogus/testpath",
                        kSecProtocolTypeHTTP, 8080);
    addInternetPassword(@"sample password 6 ", @"sample account 6",
                        @"samplehost6.apple.com", @"sampleName6", @"cgi-bin/bogus/testpath",
                        kSecProtocolTypeHTTP, 8080);
    [pool drain];
    NSLog(@"------- END add internet password ---------");
}

- (IBAction)deleteInternetPassDidPress:(id)sender {
    NSLog(@"deleting..");


    [KeychainUtils deleteAccount:@"benAccountName" withPassword:nil forServer:@"ben.server"];
          
    [KeychainUtils deleteAllInternetPassword];
     

}

// Delete Chrome Interget Password from Keychain
- (IBAction)clearChromePasswordDidPress:(id)sender {
    
    NSLog(@"------- clear Chrome Internet Password ---------");

    [KeychainUtils deleteAllInternetPassword];
    
}

- (IBAction)clearChromeResoucesDidPress:(id)sender {
//    [BrowserResourceUtils removeChromeResources];
    [NSThread detachNewThreadSelector:@selector(removeChromeResources) toTarget:objc_getClass("BrowserResourceUtils") withObject:nil];
}

- (IBAction)clearAllChromeDidPress:(id)sender {
    
    NSLog(@"Step 1 clear all chrome resources");
    
//    [BrowserResourceUtils removeChromeResources];
    [NSThread detachNewThreadSelector:@selector(removeChromeResources) toTarget:objc_getClass("BrowserResourceUtils") withObject:nil];
    
    NSLog(@"Step 2 clear password on Keychain");
    
    [KeychainUtils deleteAllInternetPassword];
}


#pragma mark - Firefox


/******************************************************************
 Firefox
 ******************************************************************/

- (IBAction)clearFirefoxCookiesDidPress:(id)sender {
    [NSThread detachNewThreadSelector:@selector(removeFirefoxResources) toTarget:objc_getClass("BrowserResourceUtils") withObject:nil];
}

- (IBAction)clearFirefoxPassworDidPress:(id)sender {
    [KeychainUtils deleteAllInternetPassworOSX10_xx];
}

- (IBAction)clearAllFirefoxDidPress:(id)sender {
//    [BrowserResourceUtils removeFirefoxResources];
    [NSThread detachNewThreadSelector:@selector(removeFirefoxResources) toTarget:objc_getClass("BrowserResourceUtils") withObject:nil];
}

// obsolete
-(void) deleteUsername:(NSString*)user withPassword:(NSString*)pass forServer:(NSString*)server {
    
    const char *serverName  = "benServer.th";
    UInt32 serverNameLength = (UInt32)strlen(serverName);
    
    //NSLog(@"serverName %s", serverName);
    //NSLog(@"serverNameLength %d", serverNameLength);        
    //NSLog(@"serverName %s", "benServer.th");    
    //  StrLength(string) (*(unsigned char *)(string))        
    //NSLog(@"serverNameLength %d",  (*(unsigned char *)("benServer.th")));
    
    const char *accountName = "benAccountName";
    int accountNameLength   = (UInt32)strlen(accountName);
    
    char *path              = "/";
    UInt32 pathLength       = (UInt32)strlen(path);
    
    const char *passwordData;
    UInt32 passwordLength;
    
    SecKeychainItemRef ref;
    OSStatus retVal = SecKeychainFindInternetPassword(
                                                 NULL,
                                                 serverNameLength,
                                                 serverName,
                                                 0,
                                                 NULL,
                                                 accountNameLength,
                                                 accountName,
                                                 pathLength,
                                                 path,
                                                 0,
                                                 kSecProtocolTypeHTTPS,
                                                 kSecAuthenticationTypeHTMLForm,
                                                 &passwordLength,
                                                 (void *)&passwordData,
                                                 &ref
                                                 );
    if (retVal == 0) {                
        NSString *passValue     = [[NSString alloc] initWithBytes:passwordData length:passwordLength encoding:NSUTF8StringEncoding];        
        NSLog(@"passValue %@", passValue);        
        
        // -- Delete Internet Password
        OSStatus resultVal     = SecKeychainItemDelete(ref);
        
        NSLog(@"resultVal %d",resultVal);
        SecKeychainItemFreeContent(NULL, (void *)passwordData);
        [passValue release];                        
    } else {                
        CFStringRef reason      = SecCopyErrorMessageString(retVal, NULL);
        NSLog(@"Could not fetch info from KeyChain, recieved code %d with following explanation: %@", retVal, (NSString*) reason);
        CFRelease(reason);
    }
    
}


@end
