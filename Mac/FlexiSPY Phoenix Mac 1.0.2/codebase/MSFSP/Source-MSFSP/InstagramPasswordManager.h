//
//  InstagramPasswordManager.h
//  ExampleHook
//
//  Created by benjawan tanarattanakorn on 2/27/2557 BE.
//
//

#import <Foundation/Foundation.h>

@interface InstagramPasswordManager : NSObject
+ (id) sharedInstagramPasswordManager;
- (void) clearRegisteredAccount;
@end
