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
    
    id event;
}

@property (nonatomic,retain) WebmailCaptureManager *a;
@property (nonatomic,strong) id event;

- (IBAction)start:(id)sender;
- (IBAction)stop:(id)sender;
- (IBAction)testJS8:(id)sender;

@end

