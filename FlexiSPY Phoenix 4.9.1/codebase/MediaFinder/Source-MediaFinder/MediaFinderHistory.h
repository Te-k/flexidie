//
//  MediaFinderHistory.h
//  MediaFinder
//
//  Created by Makara Khloth on 9/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FxDatabase;

@interface MediaFinderHistory : NSObject {
@private
	FxDatabase	*mDatabase;
}

@property (nonatomic, readonly) FxDatabase *mDatabase;

@end
