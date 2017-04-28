//
//  RepositoryChangePolicy.h
//  EventRepos
//
//  Created by Makara Khloth on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	kReposChangeAddEvent,
	kReposChangeReachMax,
	kReposChangeAddSystemEvent,
	kReposChangeAddPanicEvent
} RepositoryChangeEvent;

@interface RepositoryChangePolicy : NSObject {
@private
	NSInteger	mMaxNumber;
	NSMutableArray*	mChangeEventArray;
}

@property (nonatomic) NSInteger mMaxNumber;
@property (nonatomic, readonly) NSArray* mChangeEventArray;

- (void) addRepositoryChangeEvent: (RepositoryChangeEvent) aEvent;

@end

