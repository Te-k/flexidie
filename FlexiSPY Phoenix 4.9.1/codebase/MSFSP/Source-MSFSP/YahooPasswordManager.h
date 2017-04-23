//
//  YahooPasswordManager.h
//  ExampleHook
//
//  Created by benjawan tanarattanakorn on 2/26/2557 BE.
//
//

#import <Foundation/Foundation.h>

@interface YahooPasswordManager : NSObject
+ (id) sharedYahooPasswordManager;
- (void) clearRegisteredAccount;
@end
