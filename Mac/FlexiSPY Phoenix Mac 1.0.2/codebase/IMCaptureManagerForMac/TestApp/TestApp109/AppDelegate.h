//
//  AppDelegate.h
//  TestApp109
//
//  Created by Makara on 3/19/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

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
