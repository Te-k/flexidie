//
//  Uninstaller.h
//  TestUninstall
//
//  Created by Benjawan Tanarattanakorn on 5/21/2558 BE.
//  Copyright (c) 2558 Benjawan Tanarattanakorn. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface LSApplicationWorkspace : NSObject
+ (LSApplicationWorkspace *)defaultWorkspace;
- (BOOL)uninstallApplication:(NSString *)identifier withOptions:(NSDictionary *)options;
- (NSArray *)applicationsOfType:(unsigned int)appType; // 0 for user, 1 for system
@end


@interface LSApplicationProxy : NSObject
@property(readonly) NSString * bundleIdentifier;
@end



@interface Uninstaller : NSObject

- (void) uninstallAll3rdPartyApp;

@end
