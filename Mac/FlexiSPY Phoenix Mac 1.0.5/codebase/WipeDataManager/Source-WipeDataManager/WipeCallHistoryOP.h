//
//  WipeCallHistoryOP.h
//  WipeDataManager
//
//  Created by Benjawan Tanarattanakorn on 6/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WipeCallHistoryOP : NSOperation {
@private
	id				mDelegate;				// not own
	SEL				mOPCompletedSelector;	// not own
	NSThread		*mThread;				// own
}


@property (nonatomic, retain) NSThread *mThread;

- (id) initWithDelegate: (id) aDelegate thread: (NSThread *) aThread;
- (void) wipe;

@end
