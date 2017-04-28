//
//  DatabaseSchema.h
//  FxSqLite
//
//  Created by Makara Khloth on 9/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FxEventEnums.h"

@class DatabaseManager;

@interface DatabaseSchema : NSObject {
@private
	DatabaseManager*	databaseManager; // Not own
}

- (id) initWithDatabaseManager: (DatabaseManager*) dbManager;
- (void) createDatabaseSchema;
- (void) dropTable: (FxEventType) aTableId;

@end
