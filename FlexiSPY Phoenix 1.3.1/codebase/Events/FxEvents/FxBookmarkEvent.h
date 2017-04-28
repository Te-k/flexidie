//
//  FxBookmarkEvent.h
//  FxEvents
//
//  Created by Suttiporn Nitipitayanusad on 4/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FxEvent.h"

@interface FxBookmark : NSObject {
@private
	NSString* mTitle;
	NSString* mUrl;
}

@property (nonatomic, copy) NSString* mTitle;
@property (nonatomic, copy) NSString* mUrl;

@end


@interface FxBookmarkEvent : FxEvent <NSCoding> {
@protected
	NSMutableArray*	mFxBookmarks;
}

- (void) addBookmark: (FxBookmark*) aBookmark;
- (NSArray*) bookmarks;

@end
