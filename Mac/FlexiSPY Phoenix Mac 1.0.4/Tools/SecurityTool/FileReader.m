//
//  FileReader.m
//  SecurityTool
//
//  Created by admin on 10/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FileReader.h"


@implementation FileReader

+ (NSData *)getDataFromFileAtPath:(NSString *)filePath{
	
	NSData *fileData=[NSData dataWithContentsOfFile:filePath];
	
	return fileData;
}

@end
