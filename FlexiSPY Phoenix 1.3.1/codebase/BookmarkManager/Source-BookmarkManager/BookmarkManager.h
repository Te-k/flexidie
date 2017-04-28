//
//  BookmarkManager.h
//  BookmarkManager
//
//  Created by Benjawan Tanarattanakorn on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol BookmarkDelegate;


@protocol BookmarkManager <NSObject>
@required
- (BOOL) deliverBookmark: (id <BookmarkDelegate>) aDelegate;
@end


