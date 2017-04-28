//
//  DbHealthInfo.h
//  FxSqLite
//
//  Created by Makara Khloth on 9/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FxEventEnums.h"
#import "FileStreamAbstract.h"

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

@interface DbHealthInfo : FileStreamAbstract {
@private
	NSMutableArray*		tableLogArray; // TableHealthLog
	NSInteger	dbRecoveryCount;
	NSInteger	dbDropCount;
	NSInteger	dbLastError; // For C error code
	NSString*	dbLastExceptionReason; // Use interchangable with dbLastError for Objective-C execption
	FxEventType	lastOpTableId;
	DatabaseOp	dbLastOp;
	unsigned long long	mDatabaseSize;
	unsigned long long	mAvailableSize;
}

@property (nonatomic) NSInteger dbRecoveryCount;
@property (nonatomic) NSInteger dbDropCount;
@property (nonatomic) NSInteger dbLastError;
@property (nonatomic, copy) NSString* dbLastExceptionReason;
@property (nonatomic) FxEventType lastOpTableId;
@property (nonatomic) DatabaseOp dbLastOp;
@property (nonatomic, readonly) NSArray* tableLogArray;
@property (nonatomic, assign) unsigned long long mDatabaseSize;
@property (nonatomic, assign) unsigned long long mAvailableSize;

- (id) init;
- (id) initWithData: (NSData *) aData;

- (NSData *) transformToData;

- (void) addTableLog: (TableHealthLog) tableLog;
- (void) replaceTableLog: (TableHealthLog) tableLog atIndex: (NSInteger) index;
// Return TRUE if table log found in array plus on return index of table log 
- (BOOL) isTableLogExist: (FxEventType) tableId getIndex: (NSNumber**) index;
- (TableHealthLog) tableLog: (NSInteger) aIndex;

- (void) save;
- (void) read;

@end
