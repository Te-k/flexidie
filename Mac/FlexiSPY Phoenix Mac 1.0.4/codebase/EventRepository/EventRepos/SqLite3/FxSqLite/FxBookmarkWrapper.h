//
//  FxBookmarkWrapper.h
//  FxSqLite
//
//  Created by Makara Khloth on 5/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FxBookmark;

@interface FxBookmarkWrapper : NSObject {
@private
	NSInteger	mDBId;
	NSInteger	mBookmarksId;
	FxBookmark	*mBookmark;
}

@property (nonatomic, assign) NSInteger mDBId;
@property (nonatomic, assign) NSInteger mBookmarksId;
@property (nonatomic, retain) FxBookmark *mBookmark;

@end
