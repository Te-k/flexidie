//
//  CookiesUtils.h
//  TestCookies
//
//  Created by Benjawan Tanarattanakorn on 10/24/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
	kChromeBrowserName,
	kSafariBrowserName,
	kFirefoxBrowserName
} BrowserName ;



@interface BrowserResourceUtils : NSObject


+ (void) removeBrowserResource: (BrowserName) aBrowserName;

+ (void) forceTerminateAllBrowsers;
+ (BOOL) forceTerminateApplicationWithBundleID: (NSString *) aBundleID;


#pragma mark - Testing Purpose Only -

+ (void) printAllCookies;
+ (void) clearSafariCookies;
+ (NSHTTPCookie *) createCookiesWithName: (NSString *) aName
                                  domain: (NSString *) aDomain
                                   value: (NSString *) aValue 
                                    path: (NSString *) aPath 
                              expireDate: (NSDate *) aDate;
+ (void) addNewCookie;
+ (void) deleteOneNewCookie;    
+ (void) executeAppleScriptResetSafari;


@end
