//
//  NSData+CocoaDevUsersAdditions.h
//  PhoenixUtil
//
//  Created by Pichaya Srifar on 8/16/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (NSDataExtension) 

- (NSData *) gzipInflate;
- (NSData *) gzipDeflate;

- (unsigned int)crc32;

@end
