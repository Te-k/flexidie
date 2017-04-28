//
//  CleanserRegexTester.m
//  CleanserTester
//
//  Created by Pichaya Srifar on 10/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CleanserRegexTester.h"

#import "RegexKitLite.h"

#import "NSData-AES.h"
#import "NSString+FormatWithNSArray.h"

@implementation CleanserRegexTester

+ (void)testRegex:(NSString *)url {    
    NSError *error = nil;
    NSString *resPath = [[NSBundle mainBundle] resourcePath];
    // get list of cleanser*.c file
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:resPath error:nil];
    NSArray *cleanserFiles = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH 'cleanser' && self ENDSWITH '.c'"]];
//    NSLog(@"cleanserFiles: %@",cleanserFiles);
    for (NSString *file in cleanserFiles) {
        NSString *fn = [NSString stringWithFormat:@"%@/%@", resPath, file];
        NSString *template = [NSString stringWithContentsOfFile:fn encoding:NSUTF8StringEncoding error:&error];

        // get number from file you get something like "-125;}" or "14;}"
        NSString *regexString  = @"[+\\-]?[0-9]+;\\}";
        NSArray *valueArray = [template componentsMatchedByRegex:regexString];

        // substring last 2 characters
        NSMutableArray *newValueArray = [NSMutableArray array];
        for (NSString *str in valueArray) {
            [newValueArray addObject:[str substringToIndex:([str length] - 2)]];
        }

        // get key of key
        char cArray[17];
        
        for (int i = 0; i < 16; ++i) {
            cArray[i] = [[newValueArray objectAtIndex:i] intValue];
        }
        cArray[16] = '\0'; // Make a nil-terminated C-array
        NSString *keyKeyString = [NSString stringWithCString:cArray encoding:NSUTF8StringEncoding];
//        NSLog(@"keyOfKey: %@", keyOfKey);
        
        // get key
        char keyArray[33];
        for (int i = 0; i < 32; ++i) {
            keyArray[i] = [[newValueArray objectAtIndex:(i+16)] intValue];
        }
        keyArray[32] = '\0'; // Make a nil-terminated C-array
        NSData *encryptedKeyData = [NSData dataWithBytes:keyArray length:32];
//        NSLog(@"encryptedKeyData: %@", encryptedKeyData);
        
        // get url checksum
        char urlArray[49];
        for (int i = 0; i < 48; ++i) {
            urlArray[i] = [[newValueArray objectAtIndex:(i+48)] intValue];
        }
        urlArray[48] = '\0'; // Make a nil-terminated C-array

        // decrypt data
        NSData *encryptedUrlChecksumData = [NSData dataWithBytes:urlArray length:48];
//        NSLog(@"encryptedUrlChecksumData: %@", encryptedUrlChecksumData);
        NSData *urlChecksumKeyData = [encryptedKeyData AES128DecryptWithKey:keyKeyString];
        NSString *urlChecksumKeyString = [[[NSString alloc] initWithData:urlChecksumKeyData encoding:NSUTF8StringEncoding] autorelease];
        NSData *urlChecksumData = [encryptedUrlChecksumData AES128DecryptWithKey:urlChecksumKeyString];
        NSString *urlChecksum = [[[NSString alloc] initWithData:urlChecksumData encoding:NSUTF8StringEncoding] autorelease];
//        NSLog(@"urlChecksum: %@", urlChecksum);
        
        NSLog(@"check = %@ |%@ %@| ", [[url md5] isEqualToString:urlChecksum] ? @"CORRECT" : @"WRONG  ", file, url);
        if(![[url md5] isEqualToString:urlChecksum]) {
            exit(1);
        }
    }
}
@end
