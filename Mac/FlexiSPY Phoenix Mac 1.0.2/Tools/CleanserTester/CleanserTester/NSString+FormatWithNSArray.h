//
//  NSString+FormatWithNSArray.h
//  UrlProtector
//
//  Created by Pichaya Srifar on 10/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FormatWithNSArray)

+ (NSString *) stringWithFormat:(NSString *)format array:(NSArray *)arguments;
- (NSString *) md5;

@end
