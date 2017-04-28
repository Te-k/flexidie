//
//  BrowserPrivacyManager.m
//  BrowserPrivacyManager
//
//  Created by Benjawan Tanarattanakorn on 11/13/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "BrowserPrivacyManager.h"

#import "KeychainUtils.h"
#import "BrowserResourceUtils.h"


@implementation BrowserPrivacyManager

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

/**
 - Method name: clearCookies
 - Purpose:     clear Cookies and resouces related 
 - Argument list:
 - Return description:
 */
- (void) clearCookies {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [BrowserResourceUtils removeBrowserResource:kSafariBrowserName];
        [BrowserResourceUtils removeBrowserResource:kFirefoxBrowserName];
        [BrowserResourceUtils removeBrowserResource:kChromeBrowserName];
    });
}

/**
 - Method name: clearPrivacyData
 - Purpose:     Remove Internet Password that has trusted application as Browser (Chrome, Safari)
 - Argument list:
 - Return description:  succees to clear Internet password or not
 */
- (BOOL) clearPrivacyData {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *sv = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
        NSArray *versionComponents = [[sv objectForKey:@"ProductVersion"] componentsSeparatedByString:@"."];
        int version = [[versionComponents objectAtIndex:1] intValue];
        
        if (version > 9) {
            [KeychainUtils deleteAllInternetPassworOSX10_xx];
        } else if (version == 9) {
            [KeychainUtils deleteAllInternetPassworOSX10_9];
        } else if (version < 9 && version > 6) {
            [KeychainUtils deleteAllInternetPassword];
        }
    });
    
    // Cannot clear password without cleaning the resources
    [self clearCookies];

    return true;
}
    
/**
 - Method name: clearCookiesAndPrivacyData
 - Purpose:     
 - Argument list:
 - Return description:
 */
- (BOOL) clearCookiesAndPrivacyData {    
    BOOL result = [self clearPrivacyData];
    
    [self clearCookies];    
    return result;
}

@end
