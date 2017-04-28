//
//  ViewController.m
//  UserActivityTestApp
//
//  Created by Makara Khloth on 2/16/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import "ViewController.h"

#import "UserActivityCaptureManager.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    mUserActivityCaptureManager = [[UserActivityCaptureManager alloc] init];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)startCapture:(id)sender {
    [mUserActivityCaptureManager startCapture];
}

- (IBAction)stopCapture:(id)sender {
    [mUserActivityCaptureManager stopCapture];
}


@end
