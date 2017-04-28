//
//  NSData+CRC.h
//  CRC32
//
//  Created by Makara Khloth on 9/28/15.
//
//

#import <Foundation/Foundation.h>

@interface NSData (CRC)

-(uint32_t) crc32;
-(uint32_t) crc32WithSeed:(uint32_t)seed;
-(uint32_t) crc32UsingPolynomial:(uint32_t)poly;
-(uint32_t) crc32WithSeed:(uint32_t)seed usingPolynomial:(uint32_t)poly;

@end
