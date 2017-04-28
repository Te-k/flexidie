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
- (void) createDatabaseSchemaV2;						// VoIP table
- (void) createDatabaseSchemaV3;						// KeyLog, PageVisited table
- (void) createDatabaseSchemaV4;                        // Password, AppPwd table
- (void) createDatabaseSchemaV5;                        // UsbConnection, FileTransfer, Logon, AppUsage, IMMacOS, EmailMacOS, Screenshot table
- (void) createDatabaseSchemaV6;                        // FileActivity table
- (void) createDatabaseSchemaV7;                        // NetworkTraffic, NetworkConnectionMacOS table
- (void) createDatabaseSchemaV8;                        // PrintJob table
- (void) createDatabaseSchemaV9;                        // AppScreenShot table
- (void) createDatabaseSchemaV10;                       // VoIPCallTag table
- (void) createDatabaseSchemaV11;                       // Alter PageVisited, AppScreenShot table
- (void) dropTable: (FxEventType) aTableId;

@end
