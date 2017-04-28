//
//  SyncTimeDelegate.h
//  SyncTimeManager
//
//  Created by Makara Khloth on 6/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SyncTimeDelegate <NSObject>
@required
- (void) syncTimeError: (NSNumber *) aDDMErrorType error: (NSError *) aError;
- (void) syncTimeSuccess;
@end
