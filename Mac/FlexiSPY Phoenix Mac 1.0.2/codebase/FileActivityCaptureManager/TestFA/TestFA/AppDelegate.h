//
//  AppDelegate.h
//  TestFA
//
//  Created by ophat on 9/22/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class FileActivityCaptureManager;

@interface AppDelegate : NSObject <NSApplicationDelegate>{
    FileActivityCaptureManager * fa;
}

@property (nonatomic , assign) FileActivityCaptureManager * fa ;

- (IBAction)start:(id)sender;
- (IBAction)stop:(id)sender;

@end

