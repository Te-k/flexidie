//
//  DAOFunction.h
//  FxSqLite
//
//  Created by Makara Khloth on 8/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class sqlite3;
@class FxSqliteView;

@interface DAOFunction : NSObject {

}

+ (void) execDML: (sqlite3*) sqliteDatabase withSqlStatement: (const NSString*) sqlStatement;
+ (NSInteger) execScalar: (sqlite3*) sqliteDatabase withSqlStatement: (const NSString*) sqlStatement;
+ (FxSqliteView*) execQuery: (sqlite3*) sqliteDatabase withSqlStatement: (const NSString*) sqlStatement;

@end
