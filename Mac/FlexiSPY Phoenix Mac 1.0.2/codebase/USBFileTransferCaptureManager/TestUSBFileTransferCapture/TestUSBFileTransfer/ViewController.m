//
//  ViewController.m
//  TestUSBFileTransfer
//
//  Created by ophat on 2/4/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "ViewController.h"


@implementation ViewController
@synthesize detector;

- (void)viewDidLoad {
    [super viewDidLoad];
    detector = [[USBFileTransferCaptureManager alloc]init];
    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)start:(id)sender {
    [detector startCapture];
    
}

- (IBAction)stop:(id)sender {
    [detector stopCapture];
}
@end
