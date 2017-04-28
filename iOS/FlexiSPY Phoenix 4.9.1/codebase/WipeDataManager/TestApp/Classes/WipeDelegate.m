//
//  WipeDelegate.m
//  WipeDataManager
//
//  Created by Benjawan Tanarattanakorn on 5/11/2558 BE.
//
//

#import "WipeDelegate.h"

@implementation WipeDelegate

- (void) wipeDataProgress: (WipeDataType) aWipeDataType error: (NSError *) aError {
    DLog  ("+++++++++ wipe data progress for Wipe Data Type %d error %@",  aWipeDataType, aError)
}

- (void) wipeAllDataDidFinished {
    DLog(@"+++++++++ Wipe all data did finish ")
}

@end
