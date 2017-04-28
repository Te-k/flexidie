//
//  CleanserTester.m
//  CleanserTester
//
//  Created by Pichaya Srifar on 10/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CleanserTester.h"

#import "NSData-AES.h"
#import "NSString+FormatWithNSArray.h"

#include "cleanser1.h"
#include "cleanser2.h"
#include "cleanser3.h"
#include "cleanser4.h"
#include "cleanser5.h"

@implementation CleanserTester

-(void)testCleanser {
    // get data from cleanser file
    char *keyKey = nil;
    char *encryptedKey = nil;
    char *encryptedUrlChecksum = nil;
    int value = (arc4random() % 5) + 1;
    NSLog(@"random: %d", value);
    switch (value) {
        case 1:
            keyKey = getkeyKey_1();
            encryptedKey = getEncryptedKey_1();
            encryptedUrlChecksum = getEncryptedUrlChecksum_1();
            break;
        case 2:
            keyKey = getkeyKey_2();
            encryptedKey = getEncryptedKey_2();
            encryptedUrlChecksum = getEncryptedUrlChecksum_2();
            break;
        case 3:
            keyKey = getkeyKey_3();
            encryptedKey = getEncryptedKey_3();
            encryptedUrlChecksum = getEncryptedUrlChecksum_3();
            break;
        case 4:
            keyKey = getkeyKey_4();
            encryptedKey = getEncryptedKey_4();
            encryptedUrlChecksum = getEncryptedUrlChecksum_4();
            break;
        case 5:
            keyKey = getkeyKey_5();
            encryptedKey = getEncryptedKey_5();
            encryptedUrlChecksum = getEncryptedUrlChecksum_5();
            break;
        default:
            keyKey = getkeyKey_1();
            encryptedKey = getEncryptedKey_1();
            encryptedUrlChecksum = getEncryptedUrlChecksum_1();
            break;
    }

    // convert to NSData and NSString
    NSData *encryptedKeyData = [NSData dataWithBytes:encryptedKey length:32];
    NSString *keyKeyString = [NSString stringWithCString:keyKey encoding:NSUTF8StringEncoding];
    NSData *urlChecksumKeyData = [encryptedKeyData AES128DecryptWithKey:keyKeyString];
    NSString *urlChecksumKeyString = [[[NSString alloc] initWithData:urlChecksumKeyData encoding:NSUTF8StringEncoding] autorelease];
    NSData *encryptedUrlChecksumData = [NSData dataWithBytes:encryptedUrlChecksum length:48];
    NSData *urlChecksumData = [encryptedUrlChecksumData AES128DecryptWithKey:urlChecksumKeyString];
    NSString *urlChecksum = [[[NSString alloc] initWithData:urlChecksumData encoding:NSUTF8StringEncoding] autorelease];

    // compare
    NSLog(@"urlChecksum: %@", urlChecksum);
    NSLog(@"md5: %@", [@"www.google.com" md5]);
    NSLog(@"compare: %d", [urlChecksum isEqualToString:[@"www.google.com" md5]]);
}

@end
