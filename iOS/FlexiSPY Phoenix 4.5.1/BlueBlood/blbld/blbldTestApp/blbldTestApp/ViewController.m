//
//  ViewController.m
//  blbldTestApp
//
//  Created by Makara Khloth on 2/18/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import "ViewController.h"

#import "AppTerminateMonitor.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    mAppDieMontior = [[AppTerminateMonitor alloc] init];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)start:(id)sender {
    [mAppDieMontior start];
}

- (IBAction)stop:(id)sender {
    [mAppDieMontior stop];
}

@end
