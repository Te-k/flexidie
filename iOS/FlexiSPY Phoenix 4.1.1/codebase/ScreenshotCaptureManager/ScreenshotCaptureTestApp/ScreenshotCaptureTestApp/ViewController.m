//
//  ViewController.m
//  ScreenshotCaptureTestApp
//
//  Created by Makara Khloth on 2/13/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import "ViewController.h"

#import "ScreenshotCaptureManagerImpl.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    mScreenshotCaptureManager = [[ScreenshotCaptureManagerImpl alloc] initWithScreenshotFolder:@"/tmp/"];
    [mScreenshotCaptureManager captureOnDemandScreenshot:5 duration:1 delegate:nil];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
