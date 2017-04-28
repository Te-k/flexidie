//
//  BookmarkDataProvider.h
//  BookmarkManager
//
//  Created by Benjawan Tanarattanakorn on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataProvider.h"


@interface BookmarkDataProvider : NSObject <DataProvider>{
	NSArray			*mBookmarkArray;
	NSInteger		mBookmarkCount;
	
	NSInteger		mBookmarkIndex;
}

@property (nonatomic, retain) NSArray *mBookmarkArray;

- (BOOL) hasNext;	// DataProvider protocol
- (id) getObject;	// DataProvider protocol

- (id) commandData;

@end
