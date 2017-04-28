//
//  BookmarkManagerImpl.h
//  BookmarkManager
//
//  Created by Benjawan Tanarattanakorn on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookmarkManager.h"
#import "DeliveryListener.h"

@protocol DataDelivery;
@protocol BookmarkDelegate;

@class BookmarkDataProvider;

@interface BookmarkManagerImpl : NSObject <BookmarkManager, DeliveryListener> {
@private
	id <DataDelivery>		mDDM;
	BookmarkDataProvider	*mBookmarkDataProvider;
	id <BookmarkDelegate>	mBookmarkDelegate;		// e.g., processor
}


- (id) initWithDDM: (id <DataDelivery>) aDDM;

@end
