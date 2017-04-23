//
//  ProtocolParserUtil.h
//  ProtocolBuilder
//
//  Created by Khaneid Hantanasiriskul on 9/29/2558 BE.
//
//

#import <Foundation/Foundation.h>

@class UIImage;

@interface ProtocolParserUtil : NSObject

+ (BOOL)isDeviceJailbroken;
+ (UIImage *)normalizedImage:(UIImage *)image;
+ (NSString *)fetchStringWithOriginalString:(NSString *)originalString withByteLength:(NSUInteger)length;

@end
