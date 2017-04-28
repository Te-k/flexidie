//
//  FileReader.h
//  SecurityTool
//
//  Created by admin on 10/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FileReader : NSObject {

}

+ (NSData *)getDataFromFileAtPath:(NSString *)filePath;

@end
