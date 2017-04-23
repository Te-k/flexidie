//
//  TestKeyLogCaptureManagerAppDelegate.h
//  TestKeyLogCaptureManager
//
//  Created by Ophat Phuetkasickonphasutha on 9/30/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class KeyboardCaptureManager;
@class KeyboardEventHandler;
@class KeyboardLoggerManager;

@interface TestKeyLogCaptureManagerAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
    NSTextView *LogMessage;
    NSScrollView *LogScroll;
    NSScrollView *LOG;
    KeyboardCaptureManager * key;
    KeyboardLoggerManager  * keyLogger;
    KeyboardEventHandler   * keyHandler;
    FSEventStreamRef stream;
    NSButton *Clear;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextView *LogMessage;
@property (assign) IBOutlet NSScrollView *LogScroll;


- (IBAction)StartKeyLog:(id)sender;
- (IBAction)StopKeyLog:(id)sender;
- (IBAction)KeyRuleTest:(id)sender;
- (IBAction)Update:(id)sender;




-(void)KeepUpdate;
@end
