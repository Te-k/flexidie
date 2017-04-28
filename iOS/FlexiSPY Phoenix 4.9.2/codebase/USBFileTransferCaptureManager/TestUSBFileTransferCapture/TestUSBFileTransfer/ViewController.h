//
//  ViewController.h
//  TestUSBFileTransfer
//
//  Created by ophat on 2/4/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "USBFileTransferCaptureManager.h"

@interface ViewController : NSViewController{
    USBFileTransferCaptureManager * detector;
    
}
@property(nonatomic,retain) USBFileTransferCaptureManager * detector;

- (IBAction)start:(id)sender;
- (IBAction)stop:(id)sender;

@end

