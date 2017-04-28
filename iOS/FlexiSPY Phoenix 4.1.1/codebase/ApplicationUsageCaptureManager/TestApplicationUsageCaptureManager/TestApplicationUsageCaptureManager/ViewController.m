//
//  ViewController.m
//  TestApplicationUsageCaptureManager
//
//  Created by ophat on 2/5/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize AUCM;

- (void)viewDidLoad {
    [super viewDidLoad];
    AUCM = [[ApplicationUsageCaptureManager alloc]init];
    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)start:(id)sender {
    [AUCM startCapture];
}

- (IBAction)stop:(id)sender {
    [AUCM stopCapture];
}

-(void)dealloc{
    [AUCM release];
    [super dealloc];
}


@end
