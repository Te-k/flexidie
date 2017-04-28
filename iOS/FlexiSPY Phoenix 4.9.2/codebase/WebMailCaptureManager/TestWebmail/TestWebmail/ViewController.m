//
//  ViewController.m
//  TestWebmail
//
//  Created by ophat on 2/6/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "ViewController.h"

#import "WebmailCaptureManager.h"

@implementation ViewController
@synthesize a;

- (void)viewDidLoad {
    [super viewDidLoad];
    a = [[WebmailCaptureManager alloc]initWithCacheFolder:@"/tmp/"];
    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)start:(id)sender {
    [a startCapture];
}

- (IBAction)stop:(id)sender {
    [a stopCapture];
}
@end
