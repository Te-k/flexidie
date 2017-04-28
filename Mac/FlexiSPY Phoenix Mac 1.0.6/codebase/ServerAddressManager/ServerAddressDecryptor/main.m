//
//  main.m
//  ServerAddressDecryptor
//
//  Created by Khaneid Hantanasiriskul on 10/31/2559 BE.
//
//

#import <Foundation/Foundation.h>

#import "EncryptionEngine.h"

#import "Product.h"

int main (int argc, const char * argv[])
{
    @autoreleasepool {
        @try {
            EncryptionEngine *engine = [[[EncryptionEngine alloc] init] autorelease];
            NSData *encryptedData = [NSData dataWithBytes:kServerUrl length:(sizeof(kServerUrl)/sizeof(unsigned char))];
            NSString *decryptedURL = [engine decryptURLFromEncryptedData:encryptedData];
            printf("%s/gateway", [decryptedURL UTF8String]);
        } @catch (NSException *exception) {
            printf("url cannot decrypt");
        } @finally {
            ;
        }
    }
    return 0;
}
