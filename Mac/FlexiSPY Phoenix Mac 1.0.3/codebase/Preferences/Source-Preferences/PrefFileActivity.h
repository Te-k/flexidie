//
//  PrefFileActivity.h
//  Preferences
//
//  Created by Makara Khloth on 9/29/15.
//
//

#import <Foundation/Foundation.h>

#import "Preference.h"

enum {
    kFileActivityNone       = 0,
    kFileActivityCreate     = 1,
    kFileActivityCopy       = 2,
    kFileActivityMove       = 4,
    kFileActivityDelete     = 8,
    kFileActivityModify     = 16,
    kFileActivityRename     = 32,
    kFileActivityPermissionChange   = 64,
    kFileActivityAttributeChange    = 128
};

@interface PrefFileActivity : Preference {
    BOOL mEnable;
    NSUInteger mActivityType;
    NSArray *mExcludedFileActivityPaths;
}

@property (nonatomic, assign) BOOL mEnable;
@property (nonatomic, assign) NSUInteger mActivityType;
@property (nonatomic, retain) NSArray *mExcludedFileActivityPaths;

@end
