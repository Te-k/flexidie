//
//  RequestDatabase.h
//  DDM
//
//  Created by Makara Khloth on 10/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

@interface RequestDatabase : NSObject {
@private
	NSString*	mDatabaseFullName;
	FMDatabase*	mDatabase;
	
	BOOL	mOpened;
}

@property (nonatomic, readonly) NSString* mDatabaseFullName;

- (id) initAndOpenDatabaseWithName: (NSString*) aFullName;
- (void) openDatabase;
- (void) closeDatabase;
- (void) dropDatabase;
- (FMDatabase*) database;

@end
