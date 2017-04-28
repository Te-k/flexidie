//
//  AppDelegate.m
//  TestApp109
//
//  Created by Makara on 3/19/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import "AppDelegate.h"

#import "IMWindowTitleUtils.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (IBAction)skype:(id)sender {
    NSString *title = [IMWindowTitleUtils skypeWindowTitle];
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
    NSString *title = [IMWindowTitleUtils lineWindowTitle];
    NSLog(@"----------- title = %@", title);
    
    //[IMWindowTitleUtils logUIElementOfLINE];
}

- (IBAction)qq:(id)sender {
    NSString *title = [IMWindowTitleUtils qqWindowTitle];
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
}

- (IBAction)trillian:(id)sender {
    NSString *title = [IMWindowTitleUtils trillianWindowTitle];
    NSLog(@"----------- title = %@", title);
    
    //[IMWindowTitleUtils logUIElementOfTrillian];
}

- (IBAction)spotlight:(id)sender {
    [IMWindowTitleUtils logUIElementOfSpotlight];
}

@end
