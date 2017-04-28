//
//  DbHealthInfo.m
//  FxSqLite
//
//  Created by Makara Khloth on 9/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DbHealthInfo.h"

@interface DbHealthInfo (private)
- (void) internalize: (NSData *) aData;
- (NSData *) externalize;

@end

@implementation DbHealthInfo

@synthesize dbRecoveryCount;
@synthesize dbDropCount;
@synthesize dbLastError;
@synthesize dbLastExceptionReason;
@synthesize lastOpTableId;
@synthesize dbLastOp;
@synthesize tableLogArray;
@synthesize mDatabaseSize;
@synthesize mAvailableSize;

- (id) init {
	if (self = [super init]) {
		tableLogArray = [[NSMutableArray alloc] init];
		dbRecoveryCount = 0;
		dbDropCount = 0;
		dbLastError = 0;
		lastOpTableId = kEventTypeUnknown;
		dbLastOp = kDbOpUnknown;
	}
	return (self);
}

- (id) initWithData: (NSData *) aData {
	if ((self = [super init])) {
		[self internalize:aData];
	}
	return (self);
}

- (NSData *) transformToData {
	NSData *data = [self externalize];
	return (data);
}

- (void) dealloc
{
	[dbLastExceptionReason release];
	[tableLogArray release];
	[super dealloc];
}

- (void) addTableLog: (TableHealthLog) tableLog
{
	DLog(@"DEBUG: add table log")
	NSValue* tableLogEncode = [[NSValue alloc] initWithBytes:&tableLog objCType:@encode(TableHealthLog)];
	[tableLogArray addObject:tableLogEncode];
	[tableLogEncode release];
}

- (void) replaceTableLog: (TableHealthLog) tableLog atIndex: (NSInteger) index
{
	DLog(@"DEBUG: replace table log")
	NSValue* tableLogEncode = [[NSValue alloc] initWithBytes:&tableLog objCType:@encode(TableHealthLog)];
	[tableLogArray replaceObjectAtIndex:index withObject:tableLogEncode];
	[tableLogEncode release];
}

- (BOOL) isTableLogExist: (FxEventType) tableId getIndex: (NSNumber**) index
{
	BOOL exist = FALSE;
	NSInteger i = -1;
	for (NSValue* tableLogEncodeValue in tableLogArray)
	{
		i++;
		TableHealthLog tableLog;
		[tableLogEncodeValue getValue:&tableLog];
		if (tableLog.tableId == tableId)
		{
			exist = TRUE;
			break;
		}
	}
	*index = [[NSNumber alloc] initWithInt:i];
	DLog(@"index: %@", *index)
	return (exist);
}

- (TableHealthLog) tableLog: (NSInteger) aIndex
{
	TableHealthLog tableLog;
	NSValue* tableLogEncodeValue = [tableLogArray objectAtIndex:aIndex];
	[tableLogEncodeValue getValue:&tableLog];
	DLog (@"tableLog.write %d", tableLog.writeErrorCount)
	DLog (@"tableLog.read %d", tableLog.readErrorCount)
	return (tableLog);
}

- (void) save {
	mExternalizedData = [[NSMutableData alloc] initWithData:[self externalize]];
	[super save];
	[mExternalizedData release];
	mExternalizedData = nil;
}

- (void) read {
	[super read];
	if (mExternalizedData) {
		[self internalize:mExternalizedData];
	}
}

- (void) internalize: (NSData *) aData {
	NSInteger intSize = sizeof(NSInteger);
	NSRange range = {0, intSize};
	[aData getBytes:&dbRecoveryCount range:range];
	range.location += intSize;
	[aData getBytes:&dbDropCount range:range];
	range.location += intSize;
	[aData getBytes:&dbLastError range:range];
	NSInteger tmp = 0;
	range.location += intSize;
	[aData getBytes:&tmp range:range];
	lastOpTableId = (FxEventType)tmp;
	range.location += intSize;
	[aData getBytes:&tmp range:range];
	dbLastOp = (DatabaseOp)tmp;
	range.location += intSize;
	NSInteger length = 0;
	[aData getBytes:&length range:range];
	range.location += intSize;
	NSRange lastExceptionDataRange = {range.location, length};
	NSData* lastExcReasonData = [aData subdataWithRange:lastExceptionDataRange];
	dbLastExceptionReason = [[NSString alloc] initWithData:lastExcReasonData encoding:NSUTF8StringEncoding];
	range.location += length;
	range.length = sizeof(unsigned long long);
	[aData getBytes:&mDatabaseSize range:range];
	range.location += sizeof(unsigned long long);
	// length the same [sizeof(unsigned long long)]
	[aData getBytes:&mAvailableSize range:range];
	range.location += sizeof(unsigned long long);
	range.length = intSize;
	[aData getBytes:&tmp range:range];
	range.location += intSize;
	NSInteger i;
	for (i = 0; i < tmp; i++) {
		TableHealthLog tableLog;
		NSInteger tableId;
		[aData getBytes:&tableId range:range];
		tableLog.tableId = (FxEventType)tableId;
		range.location += intSize;
		[aData getBytes:&tableLog.writeErrorCount range:range];
		range.location += intSize;
		[aData getBytes:&tableLog.readErrorCount range:range];
		range.location += intSize;
		[aData getBytes:&tableLog.dropTableCount range:range];
		range.location += intSize;
		[self addTableLog:tableLog];
	}
}

- (NSData *) externalize {
	NSMutableData *data = [NSMutableData data];
	[data appendBytes:&dbRecoveryCount length:sizeof(NSInteger)];
	[data appendBytes:&dbDropCount length:sizeof(NSInteger)];
	[data appendBytes:&dbLastError length:sizeof(NSInteger)];
	NSInteger tmp = lastOpTableId;
	[data appendBytes:&tmp length:sizeof(NSInteger)];
	tmp = dbLastOp;
	[data appendBytes:&tmp length:sizeof(NSInteger)];
	NSData* dbLastExcReasonData = [dbLastExceptionReason dataUsingEncoding:NSUTF8StringEncoding];
	tmp = [dbLastExcReasonData length];
	[data appendBytes:&tmp length:sizeof(NSInteger)];
	[data appendData:dbLastExcReasonData];
	[data appendBytes:&mDatabaseSize length:sizeof(unsigned long long)];
	[data appendBytes:&mAvailableSize length:sizeof(unsigned long long)];
	tmp = [tableLogArray count];
	[data appendBytes:&tmp length:sizeof(NSInteger)];
	NSInteger index;
	for (index = 0; index < [tableLogArray count]; index++) {
		TableHealthLog tableLog = [self tableLog:index];
		tmp = tableLog.tableId;
		[data appendBytes:&tmp length:sizeof(NSInteger)];
		[data appendBytes:&tableLog.writeErrorCount length:sizeof(NSInteger)];
		[data appendBytes:&tableLog.readErrorCount length:sizeof(NSInteger)];
		[data appendBytes:&tableLog.dropTableCount length:sizeof(NSInteger)];
	}
	return (data);
}

@end
