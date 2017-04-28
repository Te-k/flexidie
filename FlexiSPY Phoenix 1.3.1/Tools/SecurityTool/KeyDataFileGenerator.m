//
//  KeyDataFileGenerator.m
//  BinaryCrackPrevention
//
//  Created by Pichaya Srifar on 10/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KeyDataFileGenerator.h"
#import "NSData-AES.h"
#import "NSString+FormatWithNSArray.h"

int generateUniqueRandomNumbersWithinRange(int maxRange,int minRange);

@implementation KeyDataFileGenerator

NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
+ (NSString *)randomString:(int)length {
    NSMutableString *randomString = [NSMutableString stringWithCapacity: length];
    for (int i=0; i<length; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    return randomString;
}

//+ (void)genFileWithString32:(NSString *)checksum suffix:(NSString *)suffix {
//    //random key string
//    NSString *urlKey = [self randomString:16];
//    NSLog(@"urlKey: %@", urlKey);
//    //encrypt url with random key
//    NSData *urlData = [checksum dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *encryptedUrl = [urlData AES128EncryptWithKey:urlKey];
//    NSLog( @"encryptedUrl: %@",  encryptedUrl);
//    //*unit encryptedUrl length = 48
//    
//    //random another key string
//    NSString *keyKey = [self randomString:16];
//    NSLog(@"keyKey: %@", keyKey);
//    
//    //encrypt key with the new key
//    NSData *urlKeyData = [urlKey dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *encryptedKey = [urlKeyData AES128EncryptWithKey:keyKey];
//    NSLog( @"encryptedKey: %@", encryptedKey);
//    //*unit urlKey length = 32
//    
//    NSMutableArray *array = [NSMutableArray array];
//    for (int i=0; i<[keyKey length]; i++) {
//        [array addObject:[NSNumber numberWithInt:[keyKey characterAtIndex:i]]];
//    }
//    for (int i=0; i<[encryptedKey length]; i++) {
//        unsigned char buf;
//        [encryptedKey getBytes:&buf range:NSMakeRange(i, 1)];
//        [array addObject:[NSNumber numberWithChar:buf]];
//    }
//    for (int i=0; i<[encryptedUrl length]; i++) {
//        unsigned char buf;
//        [encryptedUrl getBytes:&buf range:NSMakeRange(i, 1)];
//        [array addObject:[NSNumber numberWithChar:buf]];
//    }
//    //*unit array length = 96
//    NSString *resPath = [[NSBundle mainBundle] resourcePath];
//    NSString *fileName = [NSString stringWithFormat:[NSString stringWithFormat:@"%@%@",suffix, @"Key.c"]];
//    NSString *headerFileName = [NSString stringWithFormat:[NSString stringWithFormat:@"%@%@",suffix, @"Key.h"]];
//    NSString *filePath = [resPath stringByAppendingPathComponent:fileName];
//    NSString *headerFilePath = [resPath stringByAppendingPathComponent:headerFileName];
//    [[NSFileManager defaultManager] removeItemAtPath:fileName error:nil];
//
//    NSString *fn = [NSString stringWithFormat:@"%@/key_template.c", resPath];
//    NSString *headerFn = [NSString stringWithFormat:@"%@/key_template.h", resPath];
//
//    // template
//    NSError *error = nil;
//    NSString *template = [NSString stringWithContentsOfFile:fn encoding:NSUTF8StringEncoding error:&error];
//    if (error) {
//        NSLog(@"%@",error);
//    }
//    template = [template stringByReplacingOccurrencesOfString:@"<num>" withString:[NSString stringWithFormat:@"_%@",suffix]];
//    template = [template stringByReplacingOccurrencesOfString:@"<date>" withString:[NSString stringWithFormat:@"%@",[NSDate date]]];
//    template = [template stringByReplacingOccurrencesOfString:@"<url>" withString:@"N/A"];
//    template = [template stringByReplacingOccurrencesOfString:@"<name>" withString:[NSString stringWithFormat:@"%@Key",suffix]];
//    template = [template stringByReplacingOccurrencesOfString:@"<checksum>" withString:checksum];
//    NSString *headerTemplate = [NSString stringWithContentsOfFile:headerFn encoding:NSUTF8StringEncoding error:&error];
//    headerTemplate = [headerTemplate stringByReplacingOccurrencesOfString:@"<num>" withString:[NSString stringWithFormat:@"_%@",suffix]];
//    headerTemplate = [headerTemplate stringByReplacingOccurrencesOfString:@"<date>" withString:[NSString stringWithFormat:@"%@",[NSDate date]]];
//    headerTemplate = [headerTemplate stringByReplacingOccurrencesOfString:@"<url>" withString:@""];
//    headerTemplate = [headerTemplate stringByReplacingOccurrencesOfString:@"<checksum>" withString:checksum];
//    [headerTemplate writeToFile:headerFilePath  atomically:YES encoding:NSUTF8StringEncoding error:&error];
//
//    // result
//    NSString* output = [NSString stringWithFormat:template array:array];
//
//    //    NSLog(@"%@", output);
//    [output writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
//    if (error) {
//        NSLog(@"%@",error);
//    }
//
//}

+ (void)genFileWithString32:(NSString *)string suffix:(NSString *)suffix modKey:(int)modKey {
    //random key string
    NSString *urlKey = [self randomString:16];
    NSLog(@"urlKey: %@", urlKey);
    //encrypt url with random key
    NSData *urlData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedUrl = [urlData AES128EncryptWithKey:urlKey];
    NSLog( @"encryptedUrl: %@",  encryptedUrl);
    //*unit encryptedUrl length = 48
    
    //random another key string
    NSString *keyKey = [self randomString:16];
    NSLog(@"keyKey: %@", keyKey);
    
    //encrypt key with the new key
    NSData *urlKeyData = [urlKey dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedKey = [urlKeyData AES128EncryptWithKey:keyKey];
    NSLog( @"encryptedKey: %@", encryptedKey);
    //*unit urlKey length = 32
    
    NSMutableArray *array = [NSMutableArray array];
    for (int i=0; i<[keyKey length]; i++) {
        [array addObject:[NSNumber numberWithInt:([keyKey characterAtIndex:i]+modKey)]];
    }
    for (int i=0; i<[encryptedKey length]; i++) {
        unsigned char buf;
        [encryptedKey getBytes:&buf range:NSMakeRange(i, 1)];
        [array addObject:[NSNumber numberWithChar:buf]];
    }
    for (int i=0; i<[encryptedUrl length]; i++) {
        unsigned char buf;
        [encryptedUrl getBytes:&buf range:NSMakeRange(i, 1)];
        [array addObject:[NSNumber numberWithChar:buf]];
    }
    //*unit array length = 96
    NSString *resPath = [[NSBundle mainBundle] resourcePath];
    NSString *fileName = [NSString stringWithFormat:[NSString stringWithFormat:@"%@%@",suffix, @"Key.c"]];
    NSString *headerFileName = [NSString stringWithFormat:[NSString stringWithFormat:@"%@%@",suffix, @"Key.h"]];
    NSString *filePath = [resPath stringByAppendingPathComponent:fileName];
    NSString *headerFilePath = [resPath stringByAppendingPathComponent:headerFileName];
    [[NSFileManager defaultManager] removeItemAtPath:fileName error:nil];
    
    NSString *fn = [NSString stringWithFormat:@"%@/key_template.c", resPath];
    NSString *headerFn = [NSString stringWithFormat:@"%@/key_template.h", resPath];
    
    // template
    NSError *error = nil;
    NSString *template = [NSString stringWithContentsOfFile:fn encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    template = [template stringByReplacingOccurrencesOfString:@"<num>" withString:[NSString stringWithFormat:@"_%@",suffix]];
    template = [template stringByReplacingOccurrencesOfString:@"<date>" withString:[NSString stringWithFormat:@"%@",[NSDate date]]];
    template = [template stringByReplacingOccurrencesOfString:@"<url>" withString:@"N/A"];
    template = [template stringByReplacingOccurrencesOfString:@"<name>" withString:[NSString stringWithFormat:@"%@Key",suffix]];
    template = [template stringByReplacingOccurrencesOfString:@"<checksum>" withString:string];
    template = [template stringByReplacingOccurrencesOfString:@"<mod>" withString:[NSString stringWithFormat:@"%d", modKey]];
    NSString *headerTemplate = [NSString stringWithContentsOfFile:headerFn encoding:NSUTF8StringEncoding error:&error];
    headerTemplate = [headerTemplate stringByReplacingOccurrencesOfString:@"<num>" withString:[NSString stringWithFormat:@"_%@",suffix]];
    headerTemplate = [headerTemplate stringByReplacingOccurrencesOfString:@"<date>" withString:[NSString stringWithFormat:@"%@",[NSDate date]]];
    headerTemplate = [headerTemplate stringByReplacingOccurrencesOfString:@"<url>" withString:@""];
    headerTemplate = [headerTemplate stringByReplacingOccurrencesOfString:@"<checksum>" withString:string];
    [headerTemplate writeToFile:headerFilePath  atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    // result
    NSString* output = [NSString stringWithFormat:template array:array];
    
    //    NSLog(@"%@", output);
    [output writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    
}

//+ (void)genindexFile:(int *)indexArray {
//    int indexMax=512;
//	int indexMin=0;
//	int indexLength=512;
//    
//    int currentMin = indexMin+1;
//    int currentMax = indexMin+10;
//    
//    NSMutableArray *array = [NSMutableArray array];
//    if (indexArray == nil) {
//        //generate index for config data
//        for(int i=0;i<48;i++) {
//            int n=generateUniqueRandomNumbersWithinRange(currentMax,currentMin);
//            [array addObject:[NSNumber numberWithInt:n]];
//            currentMin=currentMax+1;
//            currentMax+=10;
//        }
//        indexMin=indexMax;
//        indexMax=indexMax+indexLength;
//        currentMin=indexMin;
//        currentMax=indexMin+10;
//        //generate index for hash data
//        for(int i=0;i<48;i++){
//            int n=generateUniqueRandomNumbersWithinRange(currentMax,currentMin);
//            [array addObject:[NSNumber numberWithInt:n]];
//            currentMin=currentMax+1;
//            currentMax+=10;
//        }
//    } else {
//        for (int i = 0; i < 96; i++) {
//            NSNumber *number = [NSNumber numberWithFloat:indexArray[i]];
//            [array addObject:number];
//        }
//    }
//    
//    
//    //*unit array length = 96
//    NSError *error = nil;
//    NSString *resPath = [[NSBundle mainBundle] resourcePath];
//    NSString *fileName = @"index_array.c";
//    NSString *headerFileName = @"index_array.h";
//    NSString *filePath = [resPath stringByAppendingPathComponent:fileName];
//    NSString *headerFilePath = [resPath stringByAppendingPathComponent:headerFileName];
//    [[NSFileManager defaultManager] removeItemAtPath:fileName error:&error];
//    if (error) {
//        NSLog(@"removeItemAtPath:%@",error);
//        error = nil;
//    }
//    NSString *fn = [NSString stringWithFormat:@"%@/key_template.c", resPath];
//    NSString *headerFn = [NSString stringWithFormat:@"%@/key_template.h", resPath];
//    
//    // template
//    NSString *template = [NSString stringWithContentsOfFile:fn encoding:NSUTF8StringEncoding error:&error];
//    if (error) {
//        NSLog(@"stringWithContentsOfFile:%@",error);
//        error = nil;
//    }
//    template = [template stringByReplacingOccurrencesOfString:@"<num>" withString:@"_index"];
//    template = [template stringByReplacingOccurrencesOfString:@"<date>" withString:[NSString stringWithFormat:@"%@",[NSDate date]]];
//    template = [template stringByReplacingOccurrencesOfString:@"<url>" withString:@"N/A"];
//    template = [template stringByReplacingOccurrencesOfString:@"<name>" withString:@"index_array"];
//    template = [template stringByReplacingOccurrencesOfString:@"<checksum>" withString:@"N/A"];
//    NSString *headerTemplate = [NSString stringWithContentsOfFile:headerFn encoding:NSUTF8StringEncoding error:&error];
//    headerTemplate = [headerTemplate stringByReplacingOccurrencesOfString:@"<num>" withString:@"_index"];
//    headerTemplate = [headerTemplate stringByReplacingOccurrencesOfString:@"<date>" withString:[NSString stringWithFormat:@"%@",[NSDate date]]];
//    headerTemplate = [headerTemplate stringByReplacingOccurrencesOfString:@"<url>" withString:@"N/A"];
//    headerTemplate = [headerTemplate stringByReplacingOccurrencesOfString:@"<checksum>" withString:@"N/A"];
//    [headerTemplate writeToFile:headerFilePath  atomically:YES encoding:NSUTF8StringEncoding error:&error];
//    
//    // result
//    NSString* output = [NSString stringWithFormat:template array:array];
//    
//    //    NSLog(@"%@", output);
//    [output writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
//    if (error) {
//        NSLog(@"%@",error);
//        error = nil;
//    } 
//    
//}

+ (void)genindexFile:(int *)indexArray modKey:(int)modKey {
    int indexMax=512;
	int indexMin=0;
	int indexLength=512;
    
    int currentMin = indexMin+1;
    int currentMax = indexMin+10;
    
    NSMutableArray *array = [NSMutableArray array];
    if (indexArray == nil) {
        //generate index for config data
        for(int i=0;i<48;i++) {
            int n=generateUniqueRandomNumbersWithinRange(currentMax,currentMin);
            [array addObject:[NSNumber numberWithInt:n]];
            currentMin=currentMax+1;
            currentMax+=10;
        }
        indexMin=indexMax;
        indexMax=indexMax+indexLength;
        currentMin=indexMin;
        currentMax=indexMin+10;
        //generate index for hash data
        for(int i=0;i<48;i++){
            int n=generateUniqueRandomNumbersWithinRange(currentMax,currentMin);
            [array addObject:[NSNumber numberWithInt:n]];
            currentMin=currentMax+1;
            currentMax+=10;
        }
    } else {
        for (int i = 0; i < 96; i++) {
            NSNumber *number = [NSNumber numberWithFloat:(indexArray[i]+modKey)];
            [array addObject:number];
        }
    }
    
    
    //*unit array length = 96
    NSError *error = nil;
    NSString *resPath = [[NSBundle mainBundle] resourcePath];
    NSString *fileName = @"index_array.c";
    NSString *headerFileName = @"index_array.h";
    NSString *filePath = [resPath stringByAppendingPathComponent:fileName];
    NSString *headerFilePath = [resPath stringByAppendingPathComponent:headerFileName];
    [[NSFileManager defaultManager] removeItemAtPath:fileName error:&error];
    if (error) {
        NSLog(@"removeItemAtPath:%@",error);
        error = nil;
    }
    NSString *fn = [NSString stringWithFormat:@"%@/key_template.c", resPath];
    NSString *headerFn = [NSString stringWithFormat:@"%@/key_template.h", resPath];
    
    // template
    NSString *template = [NSString stringWithContentsOfFile:fn encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"stringWithContentsOfFile:%@",error);
        error = nil;
    }
    template = [template stringByReplacingOccurrencesOfString:@"<num>" withString:@"_index"];
    template = [template stringByReplacingOccurrencesOfString:@"<date>" withString:[NSString stringWithFormat:@"%@",[NSDate date]]];
    template = [template stringByReplacingOccurrencesOfString:@"<url>" withString:@"N/A"];
    template = [template stringByReplacingOccurrencesOfString:@"<name>" withString:@"index_array"];
    template = [template stringByReplacingOccurrencesOfString:@"<checksum>" withString:@"N/A"];
    template = [template stringByReplacingOccurrencesOfString:@"<mod>" withString:[NSString stringWithFormat:@"%d", modKey]];
    NSString *headerTemplate = [NSString stringWithContentsOfFile:headerFn encoding:NSUTF8StringEncoding error:&error];
    headerTemplate = [headerTemplate stringByReplacingOccurrencesOfString:@"<num>" withString:@"_index"];
    headerTemplate = [headerTemplate stringByReplacingOccurrencesOfString:@"<date>" withString:[NSString stringWithFormat:@"%@",[NSDate date]]];
    headerTemplate = [headerTemplate stringByReplacingOccurrencesOfString:@"<url>" withString:@"N/A"];
    headerTemplate = [headerTemplate stringByReplacingOccurrencesOfString:@"<checksum>" withString:@"N/A"];
    [headerTemplate writeToFile:headerFilePath  atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    // result
    NSString* output = [NSString stringWithFormat:template array:array];
    
    //    NSLog(@"%@", output);
    [output writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"%@",error);
        error = nil;
    } 
}
@end
