//
//  LINEPasswordManager.h
//  MSFSP
//
//  Created by benjawan tanarattanakorn on 2/25/2557 BE.
//
//

#import <Foundation/Foundation.h>

@interface LINEPasswordManager : NSObject
+ (id) sharedLINEPasswordManager;
- (void) clearRegisteredAccount;
@end
