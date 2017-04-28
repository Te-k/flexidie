//
//  CCryptography.h
//  CCryptography
//
//  Created by Makara Khloth on 10/21/13.
//  Copyright (c) 2013 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCryptography : NSObject

+ (NSData *) encrypt:(NSData *) aData withServerPublicKey:(NSData *) aKeyData;

@end
