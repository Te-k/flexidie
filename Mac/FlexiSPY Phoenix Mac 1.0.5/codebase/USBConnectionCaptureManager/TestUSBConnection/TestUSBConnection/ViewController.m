//
//  ViewController.m
//  TestUSBConnection
//
//  Created by ophat on 2/4/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "ViewController.h"


@implementation ViewController
@synthesize mm;

- (void)viewDidLoad {
    [super viewDidLoad];
    mm = [[USBConnectionCaptureManager alloc]init];
    
    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)Start:(id)sender {
    
    [mm startCapture];
}

- (IBAction)Stop:(id)sender {
    [mm stopCapture];
}
@end
