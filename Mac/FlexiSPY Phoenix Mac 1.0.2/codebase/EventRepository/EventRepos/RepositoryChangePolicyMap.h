//
//  RepositoryChangePolicyMap.h
//  EventRepos
//
//  Created by Makara Khloth on 9/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RepositoryChangeListener.h"

@class RepositoryChangePolicy;

@interface RepositoryChangePolicyMap : NSObject {
@private
	RepositoryChangePolicy*	mReposChangePolicy;
	id <RepositoryChangeListener>	mReposChangeListener;
}

@property (nonatomic, readonly) RepositoryChangePolicy* mReposChangePolicy;
@property (nonatomic, readonly) id <RepositoryChangeListener> mReposChangeListener;

- (id) initWithRepositoryChangePolicy: (RepositoryChangePolicy*) aPolicy andRepositoryChangeListener: (id <RepositoryChangeListener>) aListener;

@end
