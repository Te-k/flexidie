//
//  FxDatabase.h
//  FxStd
//
//  Created by Makara Khloth on 11/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

@interface FxDatabase : NSObject {
@private
	NSString*	mFullPath;
	FMDatabase*	mDatabase;
	
	BOOL		mIsOpen;
}

@property (nonatomic, readonly) NSString* mFullPath;
@property (nonatomic, readonly) FMDatabase* mDatabase;

+ (id) databaseWithPath: (NSString *) aFullPath;
- (id) initDatabaseWithPath: (NSString*) aFullPath;

- (void) openDatabase;
- (void) closeDatabase;
- (void) dropDatabase;

- (BOOL) createDatabaseSchema: (NSString*) aSqlStatement;

@end
