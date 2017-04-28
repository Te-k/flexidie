//
//  EventQueryPriority.h
//  EventRepos
//
//  Created by Makara Khloth on 9/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventQueryPriority : NSObject {
@private
	NSMutableArray*	mDefaultPriority;
	NSArray*	mUserPriority;
}

@property (nonatomic, readonly) NSArray* mDefaultPriority;
@property (nonatomic, readonly) NSArray* mUserPriority;

- (id) initWithUserPriority: (NSArray*) aEventTypePriority;
- (NSArray*) selectPriority;

@end
