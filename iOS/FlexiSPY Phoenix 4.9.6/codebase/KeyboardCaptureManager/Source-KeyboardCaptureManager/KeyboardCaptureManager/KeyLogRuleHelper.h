//
//  KeyLogRuleHelper.h
//  KeyboardCaptureManager
//
//  Created by Makara Khloth on 1/27/15.
//
//

#import <Foundation/Foundation.h>

@class KeyStrokeInfo;

@interface KeyLogRuleHelper : NSObject {
    
}

+ (BOOL) matchingMonitorApps: (NSArray *) aMonitorApps toKeyInfo: (KeyStrokeInfo *) aKeyStrokeInfo;
+ (BOOL) matchingKeyLogRuleApps: (id) aKeyLogRules toKeyInfo: (KeyStrokeInfo *) aKeyStrokeInfo;
+ (BOOL) matchingKeyLogRules: (NSArray *) aKeyLogRules toKeyInfo: (KeyStrokeInfo *) aKeyStrokeInfo;

@end
