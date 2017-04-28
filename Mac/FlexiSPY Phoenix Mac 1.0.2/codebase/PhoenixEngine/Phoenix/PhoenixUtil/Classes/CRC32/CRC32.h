//
//  CRC32.h
//  PhoenixComponent
//
//  Created by Pichaya Srifar on 7/12/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CRC32 : NSObject {

}

+ (uint32_t)crc32File: (NSString *)filePath;
+ (uint32_t)crc32File: (NSString *)filePath offset:(int)off lenght:(int)len;
+ (uint32_t)crc32File: (NSString *)filePath offset:(int)off;

+ (uint32_t)crc32: (NSData *)data;
+ (uint32_t)crc32: (NSData *)data offset:(int)off lenght:(int)len;

@end
