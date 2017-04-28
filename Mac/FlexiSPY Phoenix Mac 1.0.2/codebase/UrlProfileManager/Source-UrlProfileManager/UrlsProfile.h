//
//  UrlsProfile.h
//  UrlProfileManager
//
//  Created by Makara Khloth on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UrlsProfile : NSObject {
@private
	NSInteger	mDBID;
	NSString	*mUrl;
	NSString	*mBrowser;
	BOOL		mAllow;
}

- (id) initFromData: (NSData *) aData;

- (NSData *) toData;

@property (nonatomic, assign) NSInteger mDBID;
@property (nonatomic, copy) NSString *mUrl;
@property (nonatomic, copy) NSString *mBrowser;
@property (nonatomic, assign) BOOL mAllow;

@end
