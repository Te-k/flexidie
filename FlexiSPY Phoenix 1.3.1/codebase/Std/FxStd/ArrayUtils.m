//
//  ArrayUtils.m
//  FxStd
//
//  Created by Makara Khloth on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ArrayUtils.h"

@implementation ArrayUtils

+ (NSArray*) reverseArray: (NSArray*) aArray {
	NSMutableArray* reversedArray = [[NSMutableArray alloc] init];
	NSInteger index;
	for (index = [aArray count] - 1; index >= 0; index--) {
		[reversedArray addObject:[aArray objectAtIndex:index]];
	}
	[reversedArray autorelease];
	return (reversedArray);
}

@end
