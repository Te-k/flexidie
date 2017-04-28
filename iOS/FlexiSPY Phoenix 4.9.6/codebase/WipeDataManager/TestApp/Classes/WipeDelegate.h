//
//  WipeDelegate.h
//  WipeDataManager
//
//  Created by Benjawan Tanarattanakorn on 5/11/2558 BE.
//
//

#import <Foundation/Foundation.h>
#import "WipeDataManager.h"

@interface WipeDelegate : NSObject  <WipeDataDelegate>

- (void) wipeDataProgress: (WipeDataType) aWipeDataType error: (NSError *) aError;
- (void) wipeAllDataDidFinished;

@end
