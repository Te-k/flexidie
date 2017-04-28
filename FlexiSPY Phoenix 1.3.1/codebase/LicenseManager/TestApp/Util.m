//
//  Util.m
//  LicenseManager3
//
//  Created by Pichaya Srifar on 10/5/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "Util.h"


@implementation Util

+ (NSString *)generateRandomString:(int)length {
	srandom(time(NULL));
	NSString *letter = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
	NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
	for (int i=0; i<length; i++) {
		[randomString appendFormat:@"%c", [letter characterAtIndex: arc4random()%[letter length]]];
	}
	return randomString;
}

@end
