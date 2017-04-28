//
//  LinkedInPasswordManager.h
//  ExampleHook
//
//  Created by benjawan tanarattanakorn on 3/3/2557 BE.
//
//

#import <Foundation/Foundation.h>

@interface LinkedInPasswordManager : NSObject
+ (id) sharedLinkedInPasswordManager;
- (void) clearRegisteredAccount;
@end

