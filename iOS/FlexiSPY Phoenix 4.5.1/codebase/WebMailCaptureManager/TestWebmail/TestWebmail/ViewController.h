//
//  ViewController.h
//  TestWebmail
//
//  Created by ophat on 2/6/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WebmailCaptureManager;

@interface ViewController : NSViewController{
    WebmailCaptureManager * a;
}
@property(nonatomic,retain)WebmailCaptureManager *a;

- (IBAction)start:(id)sender;
- (IBAction)stop:(id)sender;

@end

