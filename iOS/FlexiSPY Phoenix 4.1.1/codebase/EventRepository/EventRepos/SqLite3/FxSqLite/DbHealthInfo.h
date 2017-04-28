//
//  DbHealthInfo.h
//  FxSqLite
//
//  Created by Makara Khloth on 9/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FxEventEnums.h"

typedef struct {
	FxEventType	tableId;
	NSInteger	writeErrorCount;
	NSInteger	readErrorCount;
	NSInteger	dropTableCount;
} TableHealthLog;

typedef enum {
	kDbOpUnknown,
	kDbOpRead,
	kDbOpWrite
} DatabaseOp;

@interface DbHealthInfo : NSObject {
@private
	NSMutableArray*		tableLogArray;	// TableHealthLog
	NSInteger	dbRecoveryCount;
	NSInteger	dbDropCount;
	NSInteger	dbLastError;			// For C error code
	NSString*	dbLastExceptionReason;	// Use interchangable with dbLastError for Objective-C execption
	FxEventType	lastOpTableId;
	DatabaseOp	dbLastOp;
	unsigned long long	mDatabaseSize;
	unsigned long long	mAvailableSize;
	
	NSString	*mFileFullPath;
}

@property (nonatomic, assign) NSInteger dbRecoveryCount;
@property (nonatomic, assign) NSInteger dbDropCount;
@property (nonatomic, assign) NSInteger dbLastError;
@property (nonatomic, copy) NSString* dbLastExceptionReason;
@property (nonatomic, assign) FxEventType lastOpTableId;
@property (nonatomic, assign) DatabaseOp dbLastOp;
@property (nonatomic, readonly) NSArray* tableLogArray;

@property (nonatomic, assign) unsigned long long mDatabaseSize;
@property (nonatomic, assign) unsigned long long mAvailableSize;

@property (nonatomic, copy) NSString *mFileFullPath;

- (id) init;
- (id) initWithData: (NSData *) aData;

- (NSData *) transformToData;

- (void) addTableLog: (TableHealthLog) tableLog;
- (void) replaceTableLog: (TableHealthLog) tableLog atIndex: (NSInteger) index;

/*
 - Method name:isTableLogExist:getIndex:
 - Purpose: This is method is used to search table log in table array, on return get index of that table log. Invoked when the class object releasd.
 - Argument list and description: @FxEventType tableId table id to search, @NSNumber *index on return get index of that table in array
 - Return type and description: true if table is found otherwise false
 */
- (BOOL) isTableLogExist: (FxEventType) tableId getIndex: (NSNumber**) index;
- (TableHealthLog) tableLog: (NSInteger) aIndex;

- (void) save;
- (void) read;

@end
