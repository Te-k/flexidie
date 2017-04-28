//
//  UrlProfileDatabase.h
//  UrlProfileManager
//
//  Created by Makara Khloth on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FxDatabase;

@interface UrlProfileDatabase : NSObject {
@private
	FxDatabase	*mDatabase;
	NSString	*mFileName;
}

@property (nonatomic, readonly) FxDatabase *mDatabase;
@property (nonatomic, copy) NSString *mFileName;

- (id) initOpenWithDatabaseFileName: (NSString *) aFileName;

@end
