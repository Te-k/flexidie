//
//  BookmarkDelegate.h
//  BookmarkManager
//
//  Created by Benjawan Tanarattanakorn on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol BookmarkDelegate <NSObject>
@required
- (void) deliverBookmarkDidFinished: (NSError *) aError;
@end

