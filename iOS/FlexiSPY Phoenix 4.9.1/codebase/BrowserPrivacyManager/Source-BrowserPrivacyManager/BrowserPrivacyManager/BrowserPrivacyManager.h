//
//  BrowserPrivacyManager.h
//  BrowserPrivacyManager
//
//  Created by Benjawan Tanarattanakorn on 11/13/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BrowserPrivacyManager : NSObject

// Clear Cookie and related resource of browser
- (void) clearCookies;

// Clear saved password in keychaine
- (BOOL) clearPrivacyData;

// Clear All
- (BOOL) clearCookiesAndPrivacyData;

@end
