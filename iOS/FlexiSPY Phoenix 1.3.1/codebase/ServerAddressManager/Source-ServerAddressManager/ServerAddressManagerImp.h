//
//  ServerAddressManagerImp.h
//  Source-ServerAddressManager
//
//  Created by Dominique  Mayrand on 11/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ServerAddressManager.h"

@protocol ServerAddressChangeDelegate;

@interface ServerAddressManagerImp : NSObject <ServerAddressManager> {
@private
	NSMutableArray*	mDefinedUrlArray; // NSString*
	NSArray* mTotalUrlArray;
	id <ServerAddressChangeDelegate> mDelegate;
	
	BOOL mIsRequiredBaseServer;
	
	NSInteger	mCurrentIndex;
	NSInteger	mStartIndex;
}

@property (nonatomic, assign) BOOL mIsRequiredBaseServer;
@property (nonatomic, assign) NSInteger mCurrentIndex;
@property (nonatomic, assign) NSInteger mStartIndex;

- (id) init;
- (id) initWithServerAddressChangeDelegate: (id <ServerAddressChangeDelegate>) aServerAddressChangeDelegate;

@end
