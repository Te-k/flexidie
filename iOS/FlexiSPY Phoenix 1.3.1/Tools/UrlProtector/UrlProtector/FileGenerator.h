//
//  FileGenerator.h
//  UrlProtector
//
//  Created by Pichaya Srifar on 10/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileGenerator : NSObject

+ (void)genFileWithUrl:(NSString *)url;
+ (void)genFileWithUrl:(NSString *)url number:(NSString *)num;

@end
