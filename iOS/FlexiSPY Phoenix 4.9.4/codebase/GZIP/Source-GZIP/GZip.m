//
//  GZip.m
//  PhoenixComponent
//
//  Created by Pichaya Srifar on 7/12/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "GZip.h"
#import "NSData+CocoaDevUsersAdditions.h"

@implementation GZip

+ (uint32_t) gzipDeflateFile:(NSString *)fileToZip toDestination:(NSString *)dest {
	NSData *dataToZip = [NSData dataWithContentsOfFile:fileToZip];
	NSData *compressedData = [self gzipDeflateData:dataToZip];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:dest]) {
		[fileManager removeItemAtPath:dest error:nil];
	}
	
	[compressedData writeToFile:dest atomically:YES];
	return [compressedData length];
}

+ (uint32_t) gzipInflateFile:(NSString *)fileToUnzip toDestination:(NSString *)dest {
	NSData *dataToUnzip = [NSData dataWithContentsOfFile:fileToUnzip];
	NSData *uncompressedData = [self gzipInflateData:dataToUnzip];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:dest]) {
		[fileManager removeItemAtPath:dest error:nil];
	}
	
	[uncompressedData writeToFile:dest atomically:YES];
	return [uncompressedData length];
}

+ (NSData *) gzipDeflateData: (NSData *)uncompressedData {
	/*
	if (!uncompressedData || [uncompressedData length] == 0) {
		return nil;
	}
	z_stream zlibStreamStruct;
	zlibStreamStruct.zalloc    = Z_NULL;
	zlibStreamStruct.zfree     = Z_NULL;
	zlibStreamStruct.opaque    = Z_NULL;
	zlibStreamStruct.total_out = 0;
	zlibStreamStruct.next_in   = (Bytef*)[uncompressedData bytes];
	zlibStreamStruct.avail_in  = [uncompressedData length];
	int initError = deflateInit2(&zlibStreamStruct, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY);
	if (initError != Z_OK) {
		DLog(@"Error 1");
		return nil;
	}
	NSMutableData *compressedData = [NSMutableData dataWithLength:[uncompressedData length] * 1.01 + 12];
	int deflateStatus;
	do {
		zlibStreamStruct.next_out = [compressedData mutableBytes] + zlibStreamStruct.total_out;
		zlibStreamStruct.avail_out = [compressedData length] - zlibStreamStruct.total_out;
		deflateStatus = deflate(&zlibStreamStruct, Z_FINISH);
	} while ( deflateStatus == Z_OK);
	
	if (deflateStatus != Z_STREAM_END) {
		DLog(@"Error 2");
		deflateEnd(&zlibStreamStruct);
		return nil;
	}
	deflateEnd(&zlibStreamStruct);
	[compressedData setLength: zlibStreamStruct.total_out];
	DLog(@"%s: Compressed file from %d KB to %d KB", __func__, [uncompressedData length]/1024, [compressedData length]/1024);
	
	return compressedData;
	*/
	return [uncompressedData gzipDeflate];
}

+ (NSData *) gzipInflateData:(NSData *)compressedData {
	/*
	if (!compressedData || [compressedData length] == 0) {
		DLog(@"Error -1");
		return nil;
	}
	
	unsigned full_length = [compressedData length];
	unsigned half_length = [compressedData length] / 2;
	NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
	
	BOOL done = NO;
	int InflateStatus;
	
	z_stream strm;
	strm.next_in = (Bytef *)[compressedData bytes];
	strm.avail_in = [compressedData length];
	strm.total_out = 0;
	strm.zalloc = Z_NULL;
	strm.zfree = Z_NULL;
	
	if (inflateInit2(&strm, (15+32)) != Z_OK) {
		DLog(@"Error 0");
		return nil;
	}
	
	while (!done) {
		if (strm.total_out >= [decompressed length]) {
			[decompressed increaseLengthBy: half_length];
		}
		strm.next_out = [decompressed mutableBytes] + strm.total_out;
		strm.avail_out = [decompressed length] - strm.total_out;
		
		InflateStatus = inflate (&strm, Z_SYNC_FLUSH);
		if (InflateStatus == Z_STREAM_END) {
			done = YES;
		}
		else if (InflateStatus != Z_OK){
			break;
		}
	}
	if (inflateEnd (&strm) != Z_OK) {
		return nil;
	}
	
	if (done) {
		[decompressed setLength: strm.total_out];
		DLog(@"success");
		return [NSData dataWithData: decompressed];
	}
	else {
		return nil;
	}
	 */
	return [compressedData gzipInflate];
}



@end
