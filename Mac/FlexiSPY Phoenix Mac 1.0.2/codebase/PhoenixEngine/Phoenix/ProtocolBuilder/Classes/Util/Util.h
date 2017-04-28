//
//  Util.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 9/8/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject {

}

+ (int)getValueFromData:(NSData *)source toBuffer:(void *)buffer withBufferSize:(int)bufferSize atOffset:(int)offset;
+ (int)getValueFromFile:(NSFileHandle *)fileHandle toBuffer:(void *)buffer withBufferSize:(int)bufferSize atOffset:(int)offset;

+ (NSData *)getDataFromFile:(NSFileHandle *)fileHandle length:(int)len atOffset:(unsigned long*)offset;
+ (NSString *)getStringFromFile:(NSFileHandle *)fileHandle length:(int)len atOffset:(unsigned long*)offset;

@end
