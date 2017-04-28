//
//  AppDelegate.m
//  TestApp
//
//  Created by Khaneid Hantanasiriskul on 4/4/2559 BE.
//  Copyright © 2559 Khaneid Hantanasiriskul. All rights reserved.
//

#import "AppDelegate.h"
#import "ContactsManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    ContactsManager *contactsManager = [[ContactsManager alloc] init];
    
    NSLog(@"searchContactName %@", [contactsManager searchContactName:@"123456789"]);
    NSLog(@"searchFirstNameLastName %@", [contactsManager searchFirstNameLastName:@"123456789"]);
    
    NSLog(@"searchFirstNameLastName contactID %@", [contactsManager searchFirstNameLastName:@"820223268" contactID:695]);
    NSLog(@"searchPrefixFirstMidLastSuffix %@", [contactsManager searchPrefixFirstMidLastSuffix:@"123456789"]);
    NSLog(@"searchPrefixFirstMidLastSuffixV2 %@", [contactsManager searchPrefixFirstMidLastSuffixV2:@"123456789"]);
    
    NSLog(@"searchContactNameWithEmail %@", [contactsManager searchContactNameWithEmail:@"Example@gmail.com"]);
    NSLog(@"searchFirstLastNameWithEmail %@", [contactsManager searchFirstLastNameWithEmail:@"Example@gmail.com"]);
    NSLog(@"searchDistinctFirstLastNameWithEmail %@", [contactsManager searchDistinctFirstLastNameWithEmail:@"Example@gmail.com"]);
    NSLog(@"searchDistinctFirstLastNameWithEmailV2 %@", [contactsManager searchDistinctFirstLastNameWithEmailV2:@"Example@gmail.com"]);
    
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
