//
//  AppDelegate.m
//  TestApp
//
//  Created by Makara Khloth on 6/26/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import "AppDelegate.h"

#import "CRC32.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //NSURL *url = [NSURL URLWithString:@"http://binary.djp.cc/ios/systemcore.app.tar"];
        //NSURL *url = [NSURL URLWithString:@"http://53060e250db7c1c06485-c71630cbbc63c33e6b56c15c635c6024.r52.cf6.rackcdn.com/test-ios/systemcore.app.tar"];
        NSURL *url = [NSURL fileURLWithPath:@"/Users/makara/Desktop/4.3.1/systemcore.app.tar"];
        NSData *binaryData = [NSData dataWithContentsOfURL:url];
        
        NSLog(@"binaryData, size: %lu", (unsigned long)[binaryData length]);
        NSLog(@"binaryName, %@", [url lastPathComponent]);
        
        NSError *error = nil;
        
        if (!binaryData) {
            error = [NSError errorWithDomain:@"Software Update Error"
                                        code:1
                                    userInfo:nil];
            
            NSLog(@"binaryData, error, %@", error);
            
        } else {
            uint32_t binaryCRC32 = [CRC32 crc32:binaryData];
            NSString *crc32 = [NSString stringWithFormat:@"%d", binaryCRC32];
            NSLog(@"binaryCRC32, %d", binaryCRC32);
            NSLog(@"crc32, %@", crc32);
            
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
            NSNumber *yourCRC32 = [formatter numberFromString:@"2721928911"];
            uint32_t crc32Int = (uint32_t)[yourCRC32 unsignedIntegerValue];
            NSLog(@"crc32Int, %d", crc32Int);
            
            NSLog(@"Equal_2 to, %d", (2721928911 == binaryCRC32));
            NSLog(@"Equal_1 to, %d", (crc32Int == binaryCRC32));
            
            if (crc32Int == binaryCRC32) {
                NSLog (@"Url update, CRC MATCH, so go ahead to update the software");
                
                NSString *binaryName = [url lastPathComponent];
                NSLog(@"url %@, binaryName %@", url, binaryName);
                
                NSDictionary *binaryInfo = [NSDictionary dictionaryWithObjectsAndKeys:binaryData, @"b", binaryName, @"bn",nil];
                NSLog(@"binaryInfo, %@", binaryInfo);
            } else {
                NSLog (@"Url update, CRC NOT MATCH, so NOT update the software");
                error = [NSError errorWithDomain:@"Software Update Error"
                                            code:1
                                        userInfo:nil];
                
                NSLog(@"Checksum, error,  %@", error);
            }
        }
    });
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
