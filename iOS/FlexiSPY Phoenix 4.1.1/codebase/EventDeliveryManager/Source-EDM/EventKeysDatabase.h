//
//  EventKeysDatabase.h
//  EDM
//
//  Created by Makara Khloth on 10/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

@interface EventKeysDatabase : NSObject {
@private
	NSString*	mDatabaseFullName;
	FMDatabase*	mDatabase;
	
	BOOL		mOpened;
}

@property (readonly) NSString* mDatabaseFullName;
@property (readonly) FMDatabase* mDatabase;
@property BOOL mOpened;

- (id) initWithDatabasePathAndOpen: (NSString*) aDBPath;
- (void) openDB;
- (void) closeDB;
- (void) dropDB;

@end
