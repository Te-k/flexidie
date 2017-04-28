//
//  blbluAppDelegate.h
//  blblu
//
//  Created by Ophat Phuetkasickonphasutha on 10/2/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "HotKeyCaptureDelegate.h"
#import "USBAutoActivationDelegate.h"
#import "LicenseChangeListener.h"

@class AppEngine, Activate;

@interface blbluAppDelegate : NSObject <NSApplicationDelegate, HotKeyCaptureDelegate, USBAutoActivationDelegate, LicenseChangeListener> {
@private
    NSWindow *window;
    
    AppEngine   *mAppEngine;
    
    Activate    *mActivate;
    BOOL        mIsShowActivate;
}

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic, retain) AppEngine *mAppEngine;
@property (nonatomic, assign) BOOL mIsShowActivate;

@end
