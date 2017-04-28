//
//  FileGenerator.m
//  UrlProtector
//
//  Created by Pichaya Srifar on 10/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CommonCrypto/CommonCryptor.h>

#import "FileGenerator.h"

#import "NSData-AES.h"
#import "NSString+FormatWithNSArray.h"

@interface FileGenerator(Private)
+ (NSString *)randomString:(int)length;
@end    

@implementation FileGenerator

+ (void)genFileWithUrl:(NSString *)url {
    [self genFileWithUrl:url number:@""];
}

+ (void)genFileWithUrl:(NSString *)url number:(NSString *)num {
    //gen md5
    NSLog(@"url: %@", url);
    NSString *checksum = [url md5];
    NSLog(@"checksum: %@", checksum);
    //*unit checksum length = 32
    
    for (int genFileLoop = 0; genFileLoop < [num integerValue]; genFileLoop ++) {
        //random key string
        NSString *urlKey = [self randomString:16];
        NSLog(@"urlKey: %@", urlKey);
        //encrypt url with random key
        NSData *urlData = [checksum dataUsingEncoding:NSUTF8StringEncoding];
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
            [array addObject:[NSNumber numberWithInt:[keyKey characterAtIndex:i]]];
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
        NSString *fileLoopString = [NSString stringWithFormat:@"%d",genFileLoop+1];
        NSString *fileName = [NSString stringWithFormat:@"cleanser%@.c",fileLoopString];
        NSString *headerFileName = [NSString stringWithFormat:@"cleanser%@.h",fileLoopString];
        NSString *filePath = [resPath stringByAppendingPathComponent:fileName];
        NSString *headerFilePath = [resPath stringByAppendingPathComponent:headerFileName];
        [[NSFileManager defaultManager] removeItemAtPath:fileName error:nil];

        NSString *fn = [NSString stringWithFormat:@"%@/cleanser.c.tpl", resPath];
        NSString *headerFn = [NSString stringWithFormat:@"%@/cleanser.h.tpl", resPath];
        
        // template
        NSError *error = nil;
        NSString *template = [NSString stringWithContentsOfFile:fn encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            NSLog(@"%@",error);
        }
        template = [template stringByReplacingOccurrencesOfString:@"<num>" withString:fileLoopString];
        template = [template stringByReplacingOccurrencesOfString:@"<date>" withString:[NSString stringWithFormat:@"%@",[NSDate date]]];
        template = [template stringByReplacingOccurrencesOfString:@"<url>" withString:url];
        template = [template stringByReplacingOccurrencesOfString:@"<checksum>" withString:checksum];
        NSString *headerTemplate = [NSString stringWithContentsOfFile:headerFn encoding:NSUTF8StringEncoding error:&error];
        headerTemplate = [headerTemplate stringByReplacingOccurrencesOfString:@"<num>" withString:fileLoopString];
        headerTemplate = [headerTemplate stringByReplacingOccurrencesOfString:@"<date>" withString:[NSString stringWithFormat:@"%@",[NSDate date]]];
        headerTemplate = [headerTemplate stringByReplacingOccurrencesOfString:@"<url>" withString:url];
        headerTemplate = [headerTemplate stringByReplacingOccurrencesOfString:@"<checksum>" withString:checksum];
        [headerTemplate writeToFile:headerFilePath  atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        // result
        NSString* output = [NSString stringWithFormat:template array:array];
        
        //    NSLog(@"%@", output);
        [output writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            NSLog(@"%@",error);
        }
    }
}

NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
+ (NSString *)randomString:(int)length {
    NSMutableString *randomString = [NSMutableString stringWithCapacity: length];
    for (int i=0; i<length; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    return randomString;
}
@end
