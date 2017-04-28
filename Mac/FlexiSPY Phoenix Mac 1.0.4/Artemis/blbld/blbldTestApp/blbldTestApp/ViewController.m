//
//  ViewController.m
//  blbldTestApp
//
//  Created by Makara Khloth on 2/18/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import "ViewController.h"

#import "blbldUtils.h"
#import "AppTerminateMonitor.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    mAppDieMontior = [[AppTerminateMonitor alloc] init];
    
    NSLog(@"runningProcesses: %@", [blbldUtils getRunnigProcesses]);
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
