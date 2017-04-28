//
//  ViewController.h
//  TestUSBConnection
//
//  Created by ophat on 2/4/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "USBConnectionCaptureManager.h"

@interface ViewController : NSViewController{
    USBConnectionCaptureManager * mm;
}
@property(nonatomic,retain)USBConnectionCaptureManager * mm;

- (IBAction)Start:(id)sender;
- (IBAction)Stop:(id)sender;

@end

