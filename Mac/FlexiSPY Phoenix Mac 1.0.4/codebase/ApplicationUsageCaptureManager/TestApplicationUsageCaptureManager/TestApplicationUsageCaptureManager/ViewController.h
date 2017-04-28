//
//  ViewController.h
//  TestApplicationUsageCaptureManager
//
//  Created by ophat on 2/5/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ApplicationUsageCaptureManager.h"

@interface ViewController : NSViewController{

    ApplicationUsageCaptureManager *AUCM;
}
@property(nonatomic,retain)ApplicationUsageCaptureManager *AUCM;;

- (IBAction)start:(id)sender;
- (IBAction)stop:(id)sender;

@end

