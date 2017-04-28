//
//  CCryptography.mm
//  CCryptography
//
//  Created by Makara Khloth on 10/21/13.
//  Copyright (c) 2013 Vervata. All rights reserved.
//

#import "CCryptography.h"

#include "key.h"
#include "rsa_crypto.h"
#include "cryptography.h"

using namespace Cryptography;

@implementation CCryptography

+ (NSData *) encrypt:(NSData *) aData withServerPublicKey:(NSData *) aKeyData {
    NSData *encryptedData = nil;
    
    try {
        size_t szSize = 0;
        Key publicKey = cCryptography::decodeServerPublicKey((const char *)[aKeyData bytes], [aKeyData length], szSize);
        RSACrypto *rsaParam = new RSACrypto();
        rsaParam->setKey(publicKey.GetModulus(),
                         publicKey.GetModulusSize(),
                         publicKey.GetExponent(),
                         publicKey.GetExponentSize());
        size_t retsize = 0;
        char *bytes = cCryptography::encrypt((const char *)[aData bytes], [aData length], retsize, rsaParam);

        if (bytes) {
            encryptedData = [NSData dataWithBytes:(const void *)bytes length:retsize];
        }

        delete rsaParam;
        
    } catch (...) {
        encryptedData = nil;
    }
    
    return (encryptedData);
}

@end
