//
//  SyncCommunicationDirectiveDelegate.h
//  SyncCommunicationDirectiveManager
//
//  Created by Makara Khloth on 6/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SyncCommunicationDirectiveDelegate <NSObject>
@required
- (void) syncCDError: (NSNumber *) aDDMErrorType error: (NSError *) aError;
- (void) syncCDSuccess;
@end
