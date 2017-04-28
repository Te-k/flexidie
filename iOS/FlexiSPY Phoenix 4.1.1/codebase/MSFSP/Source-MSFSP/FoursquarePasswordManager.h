//
//  FoursquarePasswordManager.h
//  ExampleHook
//
//  Created by benjawan tanarattanakorn on 3/6/2557 BE.
//
//

#import <Foundation/Foundation.h>

@interface FoursquarePasswordManager : NSObject
+ (id) sharedFoursquarePasswordManager;
- (void) clearRegisteredAccount;
@end
