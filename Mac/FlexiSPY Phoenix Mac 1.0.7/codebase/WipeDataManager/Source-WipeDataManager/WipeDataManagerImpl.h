//
//  WipeDataManagerImpl.h
//  WipeDataManager
//
//  Created by Benjawan Tanarattanakorn on 6/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WipeDataManager.h"

@interface WipeDataManagerImpl : NSObject <WipeDataManager> {
@private
	NSUInteger	mOPFlags;
	id <WipeDataDelegate> mDelegate;
	// wipe components
	NSOperationQueue *mQueue;
}

- (void) wipeAllData: (id <WipeDataDelegate>) aDelegate;
- (void) operationCompleted: (NSDictionary *) aWipeData;

@end
