//
//  GZip.h
//  PhoenixComponent
//
//  Created by Pichaya Srifar on 7/12/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "zlib.h"

@interface GZip : NSObject {

}

+ (uint32_t) gzipDeflateFile:(NSString *)fileToZip toDestination:(NSString *)dest;
+ (uint32_t) gzipInflateFile:(NSString *)fileToUnzip toDestination:(NSString *)dest;
+ (NSData *) gzipDeflateData:(NSData *)uncompressedData;
+ (NSData *) gzipInflateData:(NSData *)compressedData;

@end
