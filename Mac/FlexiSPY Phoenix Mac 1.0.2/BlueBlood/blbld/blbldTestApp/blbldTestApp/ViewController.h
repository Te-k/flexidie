//
//  ViewController.h
//  blbldTestApp
//
//  Created by Makara Khloth on 2/18/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AppTerminateMonitor;

@interface ViewController : NSViewController {
    AppTerminateMonitor *mAppDieMontior;
}

- (IBAction)start:(id)sender;
- (IBAction)stop:(id)sender;

@end

