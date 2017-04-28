//
//  AppDelegate.h
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 11/14/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BrowserPrivacyManager;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    BrowserPrivacyManager *mBrowserPrivacyManager;
}

// All
- (IBAction)clearAllBrowserDidPress:(id)sender;
- (IBAction)clearCookiesAllBrowserDidPress:(id)sender;
- (IBAction)clearPasswordAllBrowserDidPress:(id)sender;

// Safari
- (IBAction)addNewCookieDidPress:(id)sender;

- (IBAction)showCookieDidPress:(id)sender;

- (IBAction)deleteNewCookieDidPress:(id)sender; // Delete one cooky

- (IBAction)clearSafariCookiesDidPress:(id)sender;

- (IBAction)clearSafariPassworDidPress:(id)sender;      

- (IBAction)clearAllSafari10_xxDidPress:(id)sender;         // > 10.9
- (IBAction)clearAllSafari10_9DidPress:(id)sender;          // 10.9
- (IBAction)clearAllSafariDidPress:(id)sender;              // MAIN (> 10.6 && < 10.9)

// Chrome

- (IBAction)addInternetPassDidPress:(id)sender;
- (IBAction)deleteInternetPassDidPress:(id)sender;

- (IBAction)clearChromePasswordDidPress:(id)sender;
- (IBAction)clearChromeResoucesDidPress:(id)sender;
- (IBAction)clearAllChromeDidPress:(id)sender;              // MAIN


// Firefox
- (IBAction)clearFirefoxCookiesDidPress:(id)sender;
- (IBAction)clearFirefoxPassworDidPress:(id)sender;
- (IBAction)clearAllFirefoxDidPress:(id)sender;

@property (assign) IBOutlet NSWindow *window;

@end
