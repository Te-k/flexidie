//
//  TEST_PageVisitedCaptureManagerAppDelegate.m
//  TEST-PageVisitedCaptureManager
//
//  Created by Ophat Phuetkasickonphasutha on 10/2/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "TEST_PageVisitedCaptureManagerAppDelegate.h"

#import "FireFox.h"
#import "FirefoxUrlInfoInquirer.h"

#import <objc/runtime.h>

@implementation TEST_PageVisitedCaptureManagerAppDelegate
@synthesize pvcm;
@synthesize Domain;
@synthesize Title;
@synthesize Keyword;
@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    pvcm = [[PageVisitedCaptureManager alloc]init];
    
}

- (void)dealloc {
    [pvcm release];
    [super dealloc];
}
- (IBAction)AddRule:(id)sender {
    NSLog(@"AddRule");
//    NSMutableArray * Domains = [[NSMutableArray alloc]initWithObjects:[self.Domain stringValue], nil];
//    NSMutableArray * Titles = [[NSMutableArray alloc]initWithObjects:[self.Title stringValue], nil];
//    NSMutableArray * Keywords = [[NSMutableArray alloc]initWithObjects:[self.Keyword stringValue], nil];
}

- (IBAction)Start:(id)sender {
    [pvcm startCapture];
}

- (IBAction)Stop:(id)sender {
    [pvcm stopCapture];
}

- (IBAction)firefoxSB:(id)sender {
    FirefoxApplication *firefoxApp = [SBApplication applicationWithBundleIdentifier:@"org.mozilla.firefox"];
    
    NSLog(@"windows = %@", [firefoxApp windows]);
    NSLog(@"documents = %@", [firefoxApp documents]);
    
    NSLog(@"windows get = %@", [[firefoxApp windows] get]);
    NSLog(@"documents get = %@", [[firefoxApp documents] get]);
    
    for (FirefoxWindow *ffWindow in [[firefoxApp windows] get]) {
        NSLog(@"=============================================================");
        NSLog(@"ffWindow get = %@", [ffWindow get]);
        NSLog(@"bound = %@", NSStringFromRect([ffWindow bounds]));
        NSLog(@"closeable = %d", [ffWindow closeable]);
        NSLog(@"document = %@", [ffWindow document]);
        
        FirefoxDocument *ffDocument = [ffWindow document];
        
        int i=0;
        unsigned int mc = 0;
        Method * mlist = class_copyMethodList(object_getClass(ffDocument), &mc);
        NSLog(@"%d methods", mc);
        for(i=0;i<mc;i++)
            NSLog(@"Method no #%d: %s", i, sel_getName(method_getName(mlist[i])));
        
        NSLog(@"-------------------------------------------------------------------------");
        NSLog(@"ffDocument get = %@", [ffDocument get]);
        NSLog(@"name = %@", [ffDocument name]);
        NSLog(@"path = %@", [ffDocument path]);
        NSLog(@"modified = %d", [ffDocument modified]);
        NSLog(@"properties = %@", [ffDocument properties]);
        NSLog(@"-------------------------------------------------------------------------");
        
        NSLog(@"floating = %d", [ffWindow floating]);
        NSLog(@"id = %ld", (long)[ffWindow id]);
        NSLog(@"frontmost = %d", [firefoxApp frontmost]);
        NSLog(@"index = %ld", (long)[ffWindow index]);
        NSLog(@"miniaturizable = %d", [ffWindow miniaturizable]);
        NSLog(@"miniaturized = %d", [ffWindow miniaturized]);
        NSLog(@"modal = %d", [ffWindow modal]);
        NSLog(@"name = %@", [ffWindow name]);
        NSLog(@"properties = %@", [ffWindow properties]);
        NSLog(@"resizable = %d", [ffWindow resizable]);
        NSLog(@"titled = %d", [ffWindow titled]);
        NSLog(@"visible = %d", [ffWindow visible]);
        NSLog(@"zoomable = %d", [ffWindow zoomable]);
        NSLog(@"zoomed = %d", [ffWindow zoomed]);
        NSLog(@"=============================================================");
    }
    
    NSLog(@"name = %@", [firefoxApp name]);
    NSLog(@"version = %@", [firefoxApp version]);
    NSLog(@"frontmost = %d", [firefoxApp frontmost]);
    
    //[firefoxApp quitSaving:FirefoxSavoYes];
}

- (IBAction)firefoxDB:(id)sender {
    FirefoxUrlInfoInquirer *inquirer = [[FirefoxUrlInfoInquirer alloc] init];
    [inquirer lastUrlInfo];
    
    FirefoxApplication *firefoxApp = [SBApplication applicationWithBundleIdentifier:@"org.mozilla.firefox"];
    NSString *title = [[[[firefoxApp windows] get] firstObject] name];
    NSString *url = [inquirer urlWithTitle:title];
    
    NSLog(@"title = %@", title);
    NSLog(@"url = %@", url);
    
    [inquirer release];
}

@end
