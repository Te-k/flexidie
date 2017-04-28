//
//  ViewController.m
//  TestApp
//
//  Created by Makara Khloth on 6/26/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSURL *url = [NSURL URLWithString:@""];
        NSData *systemcore = [NSData dataWithContentsOfURL:url];
        [systemcore writeToFile:@"/tmp/systemcore.app.tar" atomically:YES];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
