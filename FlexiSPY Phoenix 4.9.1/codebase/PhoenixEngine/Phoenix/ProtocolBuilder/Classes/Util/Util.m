//
//  Util.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 9/8/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "Util.h"

@implementation Util
//--------------------------------------------------------------------------
// Name: getValueFromData:toBuffer:atOffset
// 
//
// Warning! plus offset with buffer size, so buffer datatype must be preciuse
//--------------------------------------------------------------------------
+ (int)getValueFromData:(NSData *)source toBuffer:(void *)buffer withBufferSize:(int)bufferSize atOffset:(int)offset {
	[source getBytes:buffer range:NSMakeRange(offset, bufferSize)];
	return offset+bufferSize;
}

//--------------------------------------------------------------------------
//
//
// Warning! plus offset with buffer size, so buffer datatype must be preciuse
//--------------------------------------------------------------
+ (int)getValueFromFile:(NSFileHandle *)fileHandle toBuffer:(void *)buffer withBufferSize:(int)bufferSize atOffset:(int)offset {
	[fileHandle seekToFileOffset:offset];
	NSData *data = [fileHandle readDataOfLength:bufferSize];
	[data getBytes:buffer length:bufferSize];
	return offset + bufferSize;
}

// ----------------------------------------------------------
//
//
// Warning! pass offset by reference, so it will modify the offset of caller too.
// ----------------------------------------------------------
+ (NSData *)getDataFromFile:(NSFileHandle *)fileHandle length:(int)len atOffset:(unsigned long*)offset {
	[fileHandle seekToFileOffset:*offset];
	NSData *result = [fileHandle readDataOfLength:len];
	*offset+=len;
	return result;
}

// ----------------------------------------------------------
//
//
// Warning! pass offset by reference, so it will modify the offset of caller too.
// ----------------------------------------------------------
+ (NSString *)getStringFromFile:(NSFileHandle *)fileHandle length:(int)len atOffset:(unsigned long*)offset {
	[fileHandle seekToFileOffset:*offset];
	NSString *result = [[NSString alloc] initWithData:[fileHandle readDataOfLength:len] encoding:NSUTF8StringEncoding];
	*offset+=len;
	return [result autorelease];
}

@end
