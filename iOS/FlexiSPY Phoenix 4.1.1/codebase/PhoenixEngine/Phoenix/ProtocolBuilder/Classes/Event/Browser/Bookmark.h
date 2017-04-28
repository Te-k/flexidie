//
//  Bookmark.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Bookmark : NSObject {
@private
	NSString* mTitle;
	NSString* mUrl;
	NSString *mBrowser;
}

@property (nonatomic, copy) NSString* mTitle;
@property (nonatomic, copy) NSString* mUrl;
@property (nonatomic, copy) NSString *mBrowser;

@end
