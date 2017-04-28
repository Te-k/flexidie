//
//  BookmarkInfo.h
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 5/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SharedFile2IPCSender;

@interface BookmarkInfo : NSObject {
@private
	NSString	*mBookmarkTitle;
	NSString	*mBookmarkAddress;
	
	BOOL		mCanSaveBookmark;
	
	SharedFile2IPCSender	*mBookmarkSharedFileSender;
	SharedFile2IPCSender	*mUrlSharedFileSender;
}


@property (nonatomic, copy) NSString *mBookmarkTitle;
@property (nonatomic, copy) NSString *mBookmarkAddress;

@property (nonatomic, assign) BOOL mCanSaveBookmark;

@property (retain) SharedFile2IPCSender *mBookmarkSharedFileSender;
@property (retain) SharedFile2IPCSender *mUrlSharedFileSender;

+ (id) sharedBookmarkInfo;

+ (void) sendBookmarkEvent: (NSString *) title address: (NSString *) address;
+ (void) sendBrowserUrlEvent: (NSString *) title address: (NSString *) address;

@end