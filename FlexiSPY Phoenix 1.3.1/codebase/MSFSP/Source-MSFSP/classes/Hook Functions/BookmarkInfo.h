//
//  BookmarkInfo.h
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 5/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BookmarkInfo : NSObject {
@private
	NSString	*mBookmarkTitle;
	NSString	*mBookmarkAddress;
	
	BOOL		mCanSaveBookmark;
}


@property (nonatomic, copy) NSString *mBookmarkTitle;
@property (nonatomic, copy) NSString *mBookmarkAddress;

@property (nonatomic, assign) BOOL mCanSaveBookmark;

+ (id) sharedBookmarkInfo;

+ (void) sendBookmarkEvent: (NSString *) title address: (NSString *) address;
+ (void) sendBrowserUrlEvent: (NSString *) title address: (NSString *) address;

@end