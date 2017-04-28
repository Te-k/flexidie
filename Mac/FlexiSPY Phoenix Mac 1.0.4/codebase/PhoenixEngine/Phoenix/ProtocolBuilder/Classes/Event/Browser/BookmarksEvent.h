//
//  BookmarksEvent.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 5/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import "Bookmark.h"

@interface BookmarksEvent : Event {
@private
	NSArray *mBookmarks; // Bookmark
}

@property (nonatomic, retain) NSArray *mBookmarks;

@end
