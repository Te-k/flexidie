//
//  CookiesUtils.m
//  TestCookies
//
//  Created by Benjawan Tanarattanakorn on 10/24/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Security/Security.h>
#import <CoreFoundation/CoreFoundation.h>

#import "BrowserResourceUtils.h"


static NSString* const kSafariBundleID              = @"com.apple.Safari"; 
static NSString* const kChromeBundleID              = @"com.google.Chrome"; 
static NSString* const kFirefoxBundleID             = @"org.mozilla.firefox"; 


@interface BrowserResourceUtils (private)
+ (void) removeSafariResources;
+ (void) removeChromeResources;
+ (void) removeFirefoxResources;
+ (NSString *) getLibraryPath;

+ (void) removeResourcePath: (NSString *) aResourcePath;
@end



@implementation BrowserResourceUtils


#pragma mark - Public Method

/**
 - Method name: removeBrowserResource
 - Purpose:     Remove Cookie and resources for a specific browser
 - Argument list:   a specific browser
 - Return description:
 */
+ (void) removeBrowserResource: (BrowserName) aBrowserName {
    switch (aBrowserName) {
        case kSafariBrowserName:
            [self clearSafariCookies];
            [self removeSafariResources];
            break;
        case kFirefoxBrowserName:
            [self removeFirefoxResources];
            break;
        case kChromeBrowserName:
            [self removeChromeResources];
            break;            
        default:
            break;
    }
}

+ (void) forceTerminateAllBrowsers {
    [BrowserResourceUtils forceTerminateApplicationWithBundleID:kSafariBundleID];
    [BrowserResourceUtils forceTerminateApplicationWithBundleID:kFirefoxBundleID];
    //[BrowserResourceUtils forceTerminateApplicationWithBundleID:kChromeBundleID];
    system("killall -9 'Google Chrome'");
}

/**
 - Method name: forceTerminateApplicationWithBundleID
 - Purpose:     Force quit the application
 - Argument list:  
 - Return description:
 */
+ (BOOL) forceTerminateApplicationWithBundleID: (NSString *) aBundleID {    
    //NSArray *safariArray = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.Safari"];
    NSArray *appArray = [NSRunningApplication runningApplicationsWithBundleIdentifier:aBundleID];

    BOOL result = NO;
    
    if ([appArray count] !=0){ result = YES;}
    
    for (NSRunningApplication* aRunningApp in appArray) {
        DLog(@"terminate %@", aRunningApp);
        result = [aRunningApp forceTerminate];
        DLog(@"success %d", result);
    }
    
    return result;
}



#pragma mark - Private Methods

#pragma mark - Safari -

/**
 - Method name: removeSafariResources
 - Purpose:     Remove Safari Resource
 - Argument list:  
 - Return description:
 */
+ (void) removeSafariResources {
    DLog(@"-------------------------");
    DLog(@"---- BEGIN (Safari) -----");

    
    NSAutoreleasePool *pool  = [[NSAutoreleasePool alloc] init];
    /*
     * It's required that Safari application must quit first, otherwise Cookies.plist file will not be deleted
     */
    [BrowserResourceUtils forceTerminateApplicationWithBundleID:kSafariBundleID];
    
    [NSThread sleepForTimeInterval:2];      // !!! This is required, otherwise the cache is not deleted immediately
    
    NSString *libPath  = [BrowserResourceUtils getLibraryPath];
    DLog (@"libPath = %@", libPath);
  

#pragma mark Safari Version 5.1.10 (6534.59.10) and Safari Version 7.0 (9537.71)
    
    // -- Autosave  
    NSString *autofill              = [libPath stringByAppendingPathComponent:@"Autosave Information/com.apple.TextEdit.plist"]; 
    [self removeResourcePath:autofill];
    
    // -- Cache
    NSString *cache1                = [libPath stringByAppendingPathComponent:@"Caches/com.apple.Safari/Cache.db"];             // !!! required     // shared with 10.9
    NSString *cache2folder          = [libPath stringByAppendingPathComponent:@"Caches/com.apple.Safari/Webpage Previews"];     // !!! required     // shared with 10.9
    NSString *cache3folder          = [libPath stringByAppendingPathComponent:@"Caches/Metadata/Safari/History"];               // !!! required
    
    // -- Cookies
    NSString *cookie                = [libPath stringByAppendingPathComponent:@"Cookies/Cookies.plist"];
    
    // -- Other
    NSString *safariHistory         = [libPath stringByAppendingPathComponent:@"Safari/History.plist"];
    NSString *safariLastSession     = [libPath stringByAppendingPathComponent:@"Safari/LastSession.plist"];
    NSString *safariLoc             = [libPath stringByAppendingPathComponent:@"Safari/LocationPermissions.plist"];
    NSString *safariTopSite         = [libPath stringByAppendingPathComponent:@"Safari/TopSites.plist"];
    NSString *safariLocalStore      = [libPath stringByAppendingPathComponent:@"Safari/LocalStorage"];
    NSString *safariWebpageIcons    = [libPath stringByAppendingPathComponent:@"Safari/WebpageIcons.db"];
    NSString *safariFormValues      = [libPath stringByAppendingPathComponent:@"Safari/Form Values"];

    [self removeResourcePath:autofill];
    
    [self removeResourcePath:cache1];
    [self removeResourcePath:cache2folder];
    [self removeResourcePath:cache3folder];
    
    [self removeResourcePath:cookie];
    
    [self removeResourcePath:safariHistory];
    [self removeResourcePath:safariWebpageIcons];
    [self removeResourcePath:safariLastSession];
    [self removeResourcePath:safariLoc];    
    [self removeResourcePath:safariTopSite];
    [self removeResourcePath:safariFormValues];
    [self removeResourcePath:safariLocalStore];   
    
    
#pragma mark Safari Version 7.0 (9537.71)
    
    // -- Cookies
    NSString *cookie10_9_no1                = [libPath stringByAppendingPathComponent:@"Cookies/Cookies.binarycookies"];
    NSString *cookie10_9_no2                = [libPath stringByAppendingPathComponent:@"Cookies/HSTS.plist"];
    
    // -- Cache
    
    NSString *cache10_9_no1                 = [libPath stringByAppendingPathComponent:@"Caches/com.apple.Safari/Cache.db-shm"];
    NSString *cache10_9_no2                 = [libPath stringByAppendingPathComponent:@"Caches/com.apple.Safari/Cache.db-wal"];
    NSString *cacheFolder10_9_no1           = [libPath stringByAppendingPathComponent:@"Caches/com.apple.Safari/fsCachedData"];
    
    NSString *webkit10_9_no1                = [libPath stringByAppendingPathComponent:@"Caches/com.apple.WebKit.PluginProcess/Cache.db-shm"];
    NSString *webkit10_9_no2                = [libPath stringByAppendingPathComponent:@"Caches/com.apple.WebKit.PluginProcess/Cache.db-wal"];
    NSString *webkit10_9_no3                = [libPath stringByAppendingPathComponent:@"Caches/com.apple.WebKit.PluginProcess/Cache.db"];
    
    NSString *quicktime10_9                 = [libPath stringByAppendingPathComponent:@"Caches/QuickTime/downloads"];
    
    // -- Saved Application State
    
    NSString *savedApplicationState10_9_keychain    = [libPath stringByAppendingPathComponent:@"Saved Application State/com.apple.keychainaccess.savedState"];
    NSString *savedApplicationState10_9_safari      = [libPath stringByAppendingPathComponent:@"Saved Application State/com.apple.Safari.savedState"];
    NSString *savedApplicationState10_9_script      = [libPath stringByAppendingPathComponent:@"Saved Application State/com.apple.ScriptEditor2.savedState"];
    
    // -- Other
    NSString *pref10_9_no1                  = [libPath stringByAppendingPathComponent:@"Preferences/com.apple.Safari.plist"];
    NSString *pref10_9_no2                  = [libPath stringByAppendingPathComponent:@"Preferences/com.apple.xpc.activity.plist"];
    NSString *plugin10_9                    = [libPath stringByAppendingPathComponent:@"Safari/PlugInOrigins.plist"];
        
    [self removeResourcePath:cookie10_9_no1];
    [self removeResourcePath:cookie10_9_no2];

    [self removeResourcePath:cache10_9_no1];
    [self removeResourcePath:cache10_9_no2];
    [self removeResourcePath:cacheFolder10_9_no1];

    [self removeResourcePath:savedApplicationState10_9_keychain];
    [self removeResourcePath:savedApplicationState10_9_safari];
    [self removeResourcePath:savedApplicationState10_9_script];
    
    [self removeResourcePath:webkit10_9_no1];
    [self removeResourcePath:webkit10_9_no2];
    [self removeResourcePath:webkit10_9_no3];
    
    [self removeResourcePath:quicktime10_9];
    
    [self removeResourcePath:pref10_9_no1];
    [self removeResourcePath:pref10_9_no2];
    
    [self removeResourcePath:plugin10_9];
    
#pragma mark Safari Version 8.0.5 (10600.5.17)
    
    NSMutableArray *deletedPaths = [NSMutableArray array];
    
    // Cache
    [deletedPaths addObject:[libPath stringByAppendingPathComponent:@"Caches/com.apple.Safari/com.apple.Safari.SafeBrowsing/Cache.db"]];    // 10.10
    [deletedPaths addObject:[libPath stringByAppendingPathComponent:@"Caches/Metadata/Safari"]];                                            // 10.10
    
    // Cookies
    [deletedPaths addObject:[libPath stringByAppendingPathComponent:@"Cookies/com.apple.Safari.SafeBrowsing.binarycookies"]];               // 10.10
    [deletedPaths addObject:[libPath stringByAppendingPathComponent:@"Cookies/Cookies.binarycookies"]];                                     // 10.10
    
    // Other
    [deletedPaths addObject:[libPath stringByAppendingPathComponent:@"Safari/Bookmarks.plist"]];                                            // 10.10
    
    for (NSString *path in deletedPaths) {
        [self removeResourcePath:path];
    }
    
    NSString * resetdeamon = [NSString stringWithFormat:@"ps -A | grep -m1 cookied | xargs kill -9"];
    system([resetdeamon UTF8String]);
    DLog(@"resetdeamon: %@", resetdeamon);
    
    DLog(@"---- COMPLETE (Safari) -----");
     
    [pool drain];
}

#pragma mark - Chrome -

/**
 - Method name: removeChromeResources
 - Purpose:     Remove Chrome Resource
 - Argument list:  
 - Return description:
 */
+ (void) removeChromeResources {
    DLog(@"---- BEGIN (Chrome) -----");
    
    NSAutoreleasePool *pool  = [[NSAutoreleasePool alloc] init];
    
    // close Chrome
    [BrowserResourceUtils forceTerminateApplicationWithBundleID:kChromeBundleID];        
    
    NSString *libPath  = [BrowserResourceUtils getLibraryPath];         
 
    // -- in Application Support
    
    NSString *chromePath            = [libPath stringByAppendingPathComponent:@"Application Support/Google/Chrome"];
    
    NSString *arcHistory1           = [chromePath stringByAppendingPathComponent:@"/Default/Archived History"];
    NSString *arcHistory2           = [chromePath stringByAppendingPathComponent:@"/Default/Archived History-journal"];
    [self removeResourcePath:arcHistory1];
    [self removeResourcePath:arcHistory2];
    
    NSString *cookies1              = [chromePath stringByAppendingPathComponent:@"/Default/Cookies"];
    NSString *cookies2              = [chromePath stringByAppendingPathComponent:@"/Default/Cookies-journal"];
    [self removeResourcePath:cookies1];
    [self removeResourcePath:cookies2];
    
    NSString *currentTabs           = [chromePath stringByAppendingPathComponent:@"/Default/Current Tabs"];
    [self removeResourcePath:currentTabs];
    
    NSString *currentSession        = [chromePath stringByAppendingPathComponent:@"/Default/Current Session"];
    [self removeResourcePath:currentSession];
    
    NSString *favIcon               = [chromePath stringByAppendingPathComponent:@"/Default/Favicons"];
    NSString *favIcon2              = [chromePath stringByAppendingPathComponent:@"/Default/Favicons-journal"];
    [self removeResourcePath:favIcon];
    [self removeResourcePath:favIcon2];
    
    NSString *gpuCacheFolder        = [chromePath stringByAppendingPathComponent:@"/Default/GPUCache"];
    [self removeResourcePath:gpuCacheFolder];
    
    NSString *history1              = [chromePath stringByAppendingPathComponent:@"/Default/History"];
    NSString *history2              = [chromePath stringByAppendingPathComponent:@"/Default/History-journal"];
    [self removeResourcePath:history1];
    [self removeResourcePath:history2];
    
    NSString *localStorageFolder    = [chromePath stringByAppendingPathComponent:@"/Default/Local Storage"];
    [self removeResourcePath:localStorageFolder];
    
    NSString *loginData1            = [chromePath stringByAppendingPathComponent:@"/Default/Login Data"];
    NSString *loginData2            = [chromePath stringByAppendingPathComponent:@"/Default/Login Data-journal"];
    [self removeResourcePath:loginData1];
    [self removeResourcePath:loginData2];
    
    NSString *netAction1            = [chromePath stringByAppendingPathComponent:@"/Default/Network Action Predictor"];
    NSString *netAction2            = [chromePath stringByAppendingPathComponent:@"/Default/Network Action Predictor-journal"];
    [self removeResourcePath:netAction1];
    [self removeResourcePath:netAction2];
    
    NSString *pepperFolder          = [chromePath stringByAppendingPathComponent:@"/Default/Pepper Data"];
    [self removeResourcePath:pepperFolder];
    
    NSString *preferences           = [chromePath stringByAppendingPathComponent:@"/Default/Preferences"];
    [self removeResourcePath:preferences];
    
    NSString *sessionFolder         = [chromePath stringByAppendingPathComponent:@"/Default/Session Storage"];
    [self removeResourcePath:sessionFolder];
    
    NSString *shortcut1             = [chromePath stringByAppendingPathComponent:@"/Default/Shortcuts"];
    NSString *shortcut2             = [chromePath stringByAppendingPathComponent:@"/Default/Shortcuts-journal"];
    [self removeResourcePath:shortcut1];
    [self removeResourcePath:shortcut2];
    
    NSString *sync                  = [chromePath stringByAppendingPathComponent:@"/Default/Sync Data"];
    [self removeResourcePath:sync];
    
    NSString *topsite1              = [chromePath stringByAppendingPathComponent:@"/Default/Top Sites"];
    NSString *topsite2              = [chromePath stringByAppendingPathComponent:@"/Default/Top Sites-journal"];
    [self removeResourcePath:topsite1];
    [self removeResourcePath:topsite2];
    
    NSString *visitLink             = [chromePath stringByAppendingPathComponent:@"/Default/Visited Links"];
    [self removeResourcePath:visitLink];
    
    NSString *webData1              = [chromePath stringByAppendingPathComponent:@"/Default/Web Data"];
    NSString *webData2              = [chromePath stringByAppendingPathComponent:@"/Default/Web Data-journal"];
    [self removeResourcePath:webData1];
    [self removeResourcePath:webData2];
    
    NSString *localState            = [chromePath stringByAppendingPathComponent:@"/Local State"];
    [self removeResourcePath:localState];
    
    NSString *quota                 = [chromePath stringByAppendingPathComponent:@"/Default/QuotaManager"];
    NSString *quota2                = [chromePath stringByAppendingPathComponent:@"/Default/QuotaManager-journal"];
    NSString *transportSecurity     = [chromePath stringByAppendingPathComponent:@"/Default/TransportSecurity"];
    NSString *dbFolder              = [chromePath stringByAppendingPathComponent:@"/Default/databases"];
    NSString *extStateFolder        = [chromePath stringByAppendingPathComponent:@"/Default/Extension State"];
    [self removeResourcePath:quota];
    [self removeResourcePath:quota2];
    [self removeResourcePath:transportSecurity];
    [self removeResourcePath:dbFolder];
    [self removeResourcePath:extStateFolder];
    
    // ---- in Cache
    NSString *chromeCachePath            = [libPath stringByAppendingPathComponent:@"Caches/Google/Chrome/Default"];
    NSString *chromeCachePath2            = [libPath stringByAppendingPathComponent:@"Caches/Google/Chrome/PnaclTranslationCache"];
    [self removeResourcePath:chromeCachePath];
    [self removeResourcePath:chromeCachePath2];
    
    
    DLog(@"---- COMPLETE (Chrome) -----");
    
    
    [pool drain];
}

#pragma mark - Firefox -

/**
 - Method name: removeFirefoxResources
 - Purpose:     Remove Firefox Resource
 - Argument list:  
 - Return description:
 */
+ (void) removeFirefoxResources {
    DLog(@"--------------------------");
    DLog(@"---- BEGIN (Firefox) -----");

    NSAutoreleasePool *pool  = [[NSAutoreleasePool alloc] init];

    // Close Firefox  
    [BrowserResourceUtils forceTerminateApplicationWithBundleID:kFirefoxBundleID];    
    
    /*************************************************************************************************
     Passwords
     Your passwords are stored in two different files, both of which are required:     
     key3.db             - This file stores your key database for your passwords. To transfer saved passwords, you must copy this file along with the following file.
     signons.sqlite      - Saved passwords.
     *************************************************************************************************/
    
    NSArray *filesToRemove = [[NSArray alloc] initWithObjects:   
                              @"key3.db",                   // Password     // /Users/benjawan_t/Library/"Application Support"/Firefox/Profiles/71w0eakn.NewProfile/key3.db
                              @"signons.sqlite",                            // /Users/benjawan_t/Library/"Application Support"/Firefox/Profiles/71w0eakn.NewProfile/signons.sqlite
                              
                              @"cookies.sqlite",            // Cookies      // /Users/benjawan_t/Library/"Application Support"/Firefox/Profiles/px1l4hw1.default/key3.db
                              @"cookies.sqlite-shm",
                              @"cookies.sqlite-wal",
                              
                              @"formhistory.sqlite",        // Autocomplete
                              
                              @"places.sqlite",             // Bookmarks and Browsing History
                              @"places.sqlite-shm",
                              @"places.sqlite-wal",
                              
                              @"localstore.rdf",
                              @"prefs.js",
                              @"sessionstore.js",
                              
                              @"webappsstore.sqlite",
                              @"webappsstore.sqlite-shm",
                              @"webappsstore.sqlite-wal"
                              
                              @"content-prefs.sqlite",
                              
                              @"sessionstore-backups",      // Restore websites
                              
                              nil ];
    [filesToRemove autorelease];
 
    NSString *libPath  = [BrowserResourceUtils getLibraryPath];    
    //DLog(@"libPath %@", libPath);  
      
    NSString *firefoxProfilePath                = [libPath stringByAppendingPathComponent:@"Application Support/Firefox/Profiles"];    
    NSArray *profileContents                    = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:firefoxProfilePath error:nil];
    DLog(@"profile path to be deleted: %@", profileContents);
    
     for (NSString *eachProfile in profileContents)  {
        // Go inside profile folder
        NSString *eachProfileFullpath          = [firefoxProfilePath stringByAppendingPathComponent:eachProfile];
        DLog(@"---- eachProfileFullpath: %@", eachProfileFullpath);
        
        NSArray *eachProfileContents           = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:eachProfileFullpath error:nil];
        
        for (NSString *item in eachProfileContents) {                
            if ([filesToRemove containsObject:item]) {          
                NSString *deleteItem       = [eachProfileFullpath stringByAppendingPathComponent:item];
                DLog(@"Deleting ... %@", deleteItem);                
                [self removeResourcePath:deleteItem];
            }                
        }                
    }
    
    // -- Cache
    NSString *cachePath                 = [libPath stringByAppendingPathComponent:@"Caches/Firefox/Profiles"];
    NSArray *cacheContents              = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cachePath error:nil];
    //DLog(@"cache path to be deleted: %@", cacheContents);    
    for (NSString *filename in cacheContents)  {                
        [self removeResourcePath:[cachePath stringByAppendingPathComponent:filename]];
    }    


    DLog(@"---- COMPLETE (Firefox) -----");

    
    [pool drain];
}

/**
 - Method name: removeResourcePath
 - Purpose:     Remove a file/folder to be deleted
 - Argument list:  
 - Return description:
 */
+ (void) removeResourcePath: (NSString *) aResourcePath {
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:aResourcePath error:&error];
    
    if (error && [error code] != NSFileNoSuchFileError) {
        DLog(@"******** Error to remove %@", aResourcePath);           
    }    
}

/**
 - Method name: getLibraryPath
 - Purpose:      Get Library path ~/Library
 - Argument list:  
 - Return description:
 */
+ (NSString *) getLibraryPath {
    NSArray *paths      = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libPath   = nil;
    if ([paths count])
        libPath             = [paths objectAtIndex:0];
    return libPath;
}



#pragma mark - Testing Purpose Only -


/**
 - Method name: createCookiesWithName:domain:value:path:expireDate
 - Purpose:      Create Cookies
 - Argument list:  
 - Return description:
 */
+ (NSHTTPCookie *) createCookiesWithName: (NSString *) aName
                                  domain: (NSString *) aDomain
                                   value: (NSString *) aValue 
                                    path: (NSString *) aPath 
                              expireDate: (NSDate *) aDate  {
    
    NSDictionary *newCookieDict = [NSMutableDictionary 
                                   dictionaryWithObjectsAndKeys:                                   
                                   aDomain, NSHTTPCookieDomain,
                                   aName,   NSHTTPCookieName,
                                   aPath,   NSHTTPCookiePath,
                                   aValue,  NSHTTPCookieValue,
                                   aDate ,  NSHTTPCookieExpires,  // required
                                   nil];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:newCookieDict];
    return cookie;    
}

+ (void) showCookies {
//    NSHTTPCookieStorage *cookieStorage  = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    NSArray *cookies                    = [cookieStorage cookies];
//    DLog(@"a number of cookies %ld", [cookies count]);
//    
// 
//    NSMutableString* allCookiesString = [NSMutableString string];
//    
//    for (NSHTTPCookie *cookie in cookies) {
//        [allCookiesString appendFormat:@"%@ %@\n", [cookie domain], [cookie name]];
//        
//        DLog (@"comment %@", [cookie comment]);
//        DLog (@"commentURL %@", [cookie commentURL]);
//        DLog (@"domain %@", [cookie domain]);
//        DLog (@"expiresDate %@", [cookie expiresDate]);
//        DLog (@"isHTTPOnly %d", [cookie isHTTPOnly]);
//        DLog (@"isSecure %d", [cookie isSecure]);
//        DLog (@"isSessionOnly %d", [cookie isSessionOnly]);
//        DLog (@"name %@", [cookie name]);
//        DLog (@"path %@", [cookie path]);
//        DLog (@"portList %@", [cookie portList]);
//        DLog (@"properties %@", [cookie properties]);
//        DLog (@"value %@", [cookie value]);
//        DLog (@"version %d", [cookie version]);   
//                        
//    }
//
//    
//    [CookiesUtils showDialog:allCookiesString];
}

+ (void) addNewCookie {
    
    NSHTTPCookie *cookie = [BrowserResourceUtils createCookiesWithName:@"BenCookies1" 
                                                        domain:@".benba.com" 
                                                         value:@"ImSoTired" 
                                                          path:@"/" 
                                                    expireDate:[[NSDate date] dateByAddingTimeInterval:2629743]];
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    
    cookie = [BrowserResourceUtils createCookiesWithName:@"BenCookies2" 
                                          domain:@".benba.com" 
                                           value:@"ImSoTired" 
                                            path:@"/" 
                                      expireDate:[[NSDate date] dateByAddingTimeInterval:2629743]];    
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    
    cookie = [BrowserResourceUtils createCookiesWithName:@"BenCookies3" 
                                          domain:@".benba.com" 
                                           value:@"ImSoTired" 
                                            path:@"/" 
                                      expireDate:[[NSDate date] dateByAddingTimeInterval:2629743]];    
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    
    /*
     DLog (@"+++++++++++++++++++++++ NEW COOKIE +++++++++++++++++++++++");
     DLog (@"comment %@", [cookie comment]);
     DLog (@"commentURL %@", [cookie commentURL]);
     DLog (@"domain %@", [cookie domain]);
     DLog (@"expiresDate %@", [cookie expiresDate]);
     DLog (@"isHTTPOnly %d", [cookie isHTTPOnly]);
     DLog (@"isSecure %d", [cookie isSecure]);
     DLog (@"isSessionOnly %d", [cookie isSessionOnly]);
     DLog (@"name %@", [cookie name]);
     DLog (@"path %@", [cookie path]);
     DLog (@"portList %@", [cookie portList]);
     DLog (@"properties %@", [cookie properties]);
     DLog (@"value %@", [cookie value]);
     DLog (@"version %@", [cookie version]);
     DLog (@"+++++++++++++++++++++++ [END] NEW COOKIE +++++++++++++++++++++++");
     */
}

+ (void) printAllCookies {
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStorage cookies];
    DLog(@"COOKIES COUNT ====> %lu", (unsigned long)[cookies count]);
    //DLog(@"cookies %@", cookies);
    
    /*
     Getting Cookie Properties     
     – comment
     – commentURL
     – domain
     – expiresDate
     – isHTTPOnly
     – isSecure
     – isSessionOnly
     – name
     – path
     – portList
     – properties
     – value
     – version          
     */
    
    for (NSHTTPCookie *cookie in cookies) {
        DLog (@"---------------");
        DLog (@"comment %@", [cookie comment]);
        DLog (@"commentURL %@", [cookie commentURL]);
        DLog (@"domain %@", [cookie domain]);
        DLog (@"expiresDate %@", [cookie expiresDate]);
        DLog (@"isHTTPOnly %d", [cookie isHTTPOnly]);
        DLog (@"isSecure %d", [cookie isSecure]);
        DLog (@"isSessionOnly %d", [cookie isSessionOnly]);
        DLog (@"name %@", [cookie name]);
        DLog (@"path %@", [cookie path]);
        DLog (@"portList %@", [cookie portList]);
        DLog (@"properties %@", [cookie properties]);
        DLog (@"value %@", [cookie value]);
        DLog (@"version %lu", (unsigned long)[cookie version]);
    }
}

+ (void) clearSafariCookies {
    // get storage
    NSHTTPCookieStorage *cookieStorage  = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    // get all cookies
    NSArray *cookies                    = [cookieStorage cookies];
    
    DLog(@"a number of cookies %lu", (unsigned long)[cookies count]);
    for (NSHTTPCookie *cookie in cookies) {
        DLog (@"domain %@", [cookie domain]);
        DLog (@"expiresDate %@ version %lu", [cookie expiresDate], (unsigned long)[cookie version]);
        DLog (@"name %@", [cookie name]);                         
        DLog (@"value %@", [cookie value]); 
        
        // delete cookies
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    
}

+ (void) deleteOneNewCookie {
    NSURL *url = [NSURL URLWithString:@"http://benba.com"];
    DLog(@"url to be deleted %@", url);
    
    NSArray *cookieArray = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
    
    DLog(@"cookie to be deleted %@", cookieArray);  
    
    if ([cookieArray count])
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:[cookieArray objectAtIndex:0]];
}

+ (void) executeAppleScriptResetSafariOnDifferentThread {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ResetSafari" 
                                                     ofType:@"scpt"]; 
    DLog(@"path: %@", path);
    
    NSAppleScript *script = [[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] 
                                                                   error:nil];
    DLog(@"script %@", script);
    
    NSDictionary *error = nil;    
    NSAppleEventDescriptor *scptResult = [script executeAndReturnError:&error];
    
    DLog(@"scripting result %@", [scptResult stringValue]);
    if (error) {
        DLog(@"error while executing script ResetSafari");
    }
    [script release];
}

+ (void) executeAppleScriptResetSafari {
    [NSThread detachNewThreadSelector:@selector(executeAppleScriptResetSafariOnDifferentThread) toTarget:[BrowserResourceUtils class] withObject:nil];
    
}

@end
