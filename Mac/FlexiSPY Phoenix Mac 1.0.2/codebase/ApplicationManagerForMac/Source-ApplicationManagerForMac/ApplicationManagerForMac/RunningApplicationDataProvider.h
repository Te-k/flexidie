//
//  BookmarkDataProvider.h
//  BookmarkManager
//
//  Created by Benjawan Tanarattanakorn on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataProvider.h"


@interface RunningApplicationDataProvider : NSObject <DataProvider> {
 	NSArray			*mRunningAppArray;
	NSInteger		mRunningAppCount;
	NSInteger		mRunningAppIndex;
}


@property (nonatomic, retain) NSArray *mRunningAppArray;

- (BOOL) hasNext;	// DataProvider protocol
- (id) getObject;	// DataProvider protocol

- (id) commandData;
//- (NSArray *) createRunningApplicationArray;	// for testing

@end
