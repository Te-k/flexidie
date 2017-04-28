//
//  AppDelegate.h
//  NTCM
//
//  Created by ophat on 10/9/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NetworkTrafficCaptureManagerImpl.h"


@interface AppDelegate : NSObject <NSApplicationDelegate>{
    NetworkTrafficCaptureManagerImpl * ntcm;
    
    NSTextField *TotalDownload;
    NSTextField *TotalUpload;
    
    
    int Download;
    int Upload;
    
    NSScrollView *Scroller;
    NSView *Scroll;
    
}
@property (nonatomic,assign) NetworkTrafficCaptureManagerImpl * ntcm;
@property (nonatomic,assign) IBOutlet NSTextField *duration;
@property (nonatomic,assign) IBOutlet NSTextField *frequency;

@property (assign) IBOutlet NSScrollView *Scroller;
@property (assign) IBOutlet NSView *Scroll;

@property (assign) IBOutlet NSTextField *TotalDownload;
@property (assign) IBOutlet NSTextField *TotalUpload;
@property (assign) int Download;
@property (assign) int Upload;

- (IBAction)Start:(id)sender;
- (IBAction)Stop:(id)sender;

@end

