//
//  KeyDataFileGenerator.h
//  BinaryCrackPrevention
//
//  Created by Pichaya Srifar on 10/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyDataFileGenerator : NSObject
//+ (void)genFileWithString32:(NSString *)string suffix:(NSString *)suffix;
+ (void)genFileWithString32:(NSString *)string suffix:(NSString *)suffix modKey:(int)modKey;
//+ (void)genindexFile:(int *)indexArray;
+ (void)genindexFile:(int *)indexArray modKey:(int)modKey;

@end
