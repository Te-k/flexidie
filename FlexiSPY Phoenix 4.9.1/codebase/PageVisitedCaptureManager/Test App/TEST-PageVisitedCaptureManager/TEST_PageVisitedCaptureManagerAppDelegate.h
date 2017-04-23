//
//  TEST_PageVisitedCaptureManagerAppDelegate.h
//  TEST-PageVisitedCaptureManager
//
//  Created by Ophat Phuetkasickonphasutha on 10/2/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PageVisitedCaptureManager.h"
@interface TEST_PageVisitedCaptureManagerAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
    PageVisitedCaptureManager *pvcm;
    NSTextField *Domain;
    NSTextField *Title;
    NSTextField *Keyword;
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic,retain)  PageVisitedCaptureManager *pvcm;
@property (assign) IBOutlet NSTextField *Domain;
@property (assign) IBOutlet NSTextField *Title;
@property (assign) IBOutlet NSTextField *Keyword;
- (IBAction)AddRule:(id)sender;


- (IBAction)Start:(id)sender;
- (IBAction)Stop:(id)sender;
- (IBAction)firefoxSB:(id)sender;
- (IBAction)firefoxDB:(id)sender;

@end
