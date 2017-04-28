//
//  RepositoryChangePolicyMapPool.h
//  EventRepos
//
//  Created by Makara Khloth on 9/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RepositoryChangePolicyMap;

@interface RepositoryChangePolicyMapPool : NSObject {
@private
	NSMutableArray*	mMapPool;
}

@property (nonatomic, readonly) NSMutableArray* mMapPool;

@end
