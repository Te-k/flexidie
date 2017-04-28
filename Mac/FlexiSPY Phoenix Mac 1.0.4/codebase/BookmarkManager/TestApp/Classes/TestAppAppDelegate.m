//
//  TestAppAppDelegate.m
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 7/9/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "TestAppAppDelegate.h"

@implementation TestAppAppDelegate

@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
	
    [window makeKeyAndVisible];
    
    [self shortenString];
	
	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

- (NSString *) substring: (NSString*) aString WithNumberOfBytes: (NSInteger) aNumberOfBytes {
    NSData *data  = [aString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *newData = [data subdataWithRange:NSMakeRange(0, aNumberOfBytes)];
    NSString *newString = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
    return [newString autorelease];
}

- (void) shortenString {
    NSString *title = @"Application windows are expected to have a root view controller at the end of application launch (Application windows are expected to have a root view controller at the end of application launch) <Application windows are expected to have a root view controller at the end of application launch>";
    NSLog (@"original bookmark, title %@", title);				// may be exceed 1 byte
    uint32_t oritinalTitleSize = (uint32_t)[title lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSLog (@"original title size: %d", oritinalTitleSize);
    
    // -- Ensure that title must less than 1 byte
    if (oritinalTitleSize > 255) {
        NSString *bookmarkStr = title;
        char outputBuffer [256];						// include the space for NULL-terminated string
        NSUInteger usedLength = 0;
        NSRange remainingRange = NSMakeRange(0, 0);
        NSRange range = NSMakeRange(0, [bookmarkStr length]);
        NSString *newTitle = nil;
        
        if ([bookmarkStr getBytes:outputBuffer				// The returned bytes are not NULL-terminated.
                        maxLength:255
                       usedLength:&usedLength
                         encoding:NSUTF8StringEncoding
                          options:NSStringEncodingConversionAllowLossy
                            range:range
                   remainingRange:&remainingRange]) {
            outputBuffer[usedLength] = '\0';				// add NULL terminated string
            newTitle = [[[NSString alloc] initWithCString:outputBuffer encoding:NSUTF8StringEncoding] autorelease];
            NSLog(@"new title 1 approach: %@ size:%lu usedLength %lu remainLOC: %lu remainLEN %lu",
                 newTitle,
                 (unsigned long)[newTitle lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
                 (unsigned long)usedLength,
                 (unsigned long)remainingRange.location,
                 (unsigned long)remainingRange.length);
        } else {
            NSLog(@"!!!!! can not get byte from this bookmark");
            newTitle = [self substring:bookmarkStr WithNumberOfBytes:255];
            if (!newTitle) {
                newTitle = [self substring:bookmarkStr WithNumberOfBytes:254];
                if (!newTitle) {
                    newTitle = [self substring:bookmarkStr WithNumberOfBytes:253];
                    if (!newTitle) {		
                        newTitle = [self substring:bookmarkStr WithNumberOfBytes:252];
                    }
                }				
            }			
            NSLog(@"new title 2 approach: %@", newTitle);
        }	
        NSLog(@"title shorten: %@", newTitle);
    }
}

- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
