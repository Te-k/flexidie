//
//  RestrictionHeaders.h
//  MSFCR
//
//  Created by Syam Sasidharan on 6/19/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMOBILEPHONEAPPIDENTIFIER	@"com.apple.mobilephone"
#define kMAILAPPIDENTIFIER			@"com.apple.mobilemail"
#define kSAFARIAPPIDENTIFIER		@"com.apple.mobilesafari"
#define kSPRINGBOARDAPPIDENTIFIER	@"com.apple.springboard"

#define SMS_MESSAGE_TYPE 1
#define MMS_MESSAGE_TYPE 2

typedef enum {
    UIApplicationStateActive,
    UIApplicationStateInactive,
    UIApplicationStateBackground
} UIApplicationState;