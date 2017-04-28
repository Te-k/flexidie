//
//  blblwUtils.m
//  blbld
//
//  Created by Makara Khloth on 10/13/16.
//
//

#import "blblwUtils.h"

@implementation blblwUtils

+ (NSString *) decrpytWithBase64: (NSString*) aCipherText {
    NSData *nsdataFromBase64String = [[NSData alloc] initWithBase64EncodedString:aCipherText options:0];
    NSString *base64Decoded = [[NSString alloc] initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
    return base64Decoded;
}

@end
