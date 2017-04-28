//
//  ViewController.m
//  TestWebmail
//
//  Created by ophat on 2/6/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "ViewController.h"

#import "WebmailCaptureManager.h"
#import "JavaScriptAccessor.h"
#import "AsJsUtils.h"

@implementation ViewController

@synthesize a, event;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    a = [[WebmailCaptureManager alloc] initWithCacheFolder:@"/tmp/"];
    
    //[self testJavaScriptAppleScript];
    
//    NSString *msg = @"Hello World";
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self testBlockVariable:msg];
//    });
//    msg = nil;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)start:(id)sender {
    if (!a) {
        a = [[WebmailCaptureManager alloc] initWithCacheFolder:@"/tmp/"];
    }
    [a startCapture];
}

- (IBAction)stop:(id)sender {
    [a stopCapture];
    a = nil;
}

- (IBAction)testJS8:(id)sender {
    NSString *method8 = [JavaScriptAccessor jsMethod:8];
    NSString *resultJS8 = [AsJsUtils executeJS:method8 app:@"Safari"];
    NSLog(@"resultJS8 : %@", resultJS8);
}

- (void) testJavaScriptAppleScript {
    NSString *method7 = [JavaScriptAccessor jsMethod:7];
    [AsJsUtils executeJS:method7 app:@"Google Chrome"];
}

- (void) testBlockVariable: (NSString *) aMsg {
    //NSString *msg = @"Hello World";
    NSString *msg = aMsg;
    self.event = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask handler:^(NSEvent * mouseEvent) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"Block variable : %@", msg);
        });
    }];
}

@end
