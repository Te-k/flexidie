//
//  PinterestPasswordManager.h
//  ExampleHook
//
//  Created by benjawan tanarattanakorn on 3/4/2557 BE.
//
//

#import <Foundation/Foundation.h>

@interface PinterestPasswordManager : NSObject
+ (id) sharedPinterestPasswordManager;
- (void) clearRegisteredAccount;
@end
