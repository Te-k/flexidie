//
//  PrefUtils.m
//  Preferences
//
//  Created by Benjawan Tanarattanakorn on 7/22/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "PrefUtils.h"

@interface PrefUtils (private)

@end

@implementation PrefUtils

+ (BOOL) exceedDataLengthForInstanceOfSize: (NSInteger) aSize location: (NSInteger) aLocation aWholeSize: (NSInteger) aWholeSize {
	BOOL canGetInstance = NO;
	//DLog (@"----- start %d, byte num %d, whole size %d", aLocation, aSize, aWholeSize)
	
	if ((aLocation + aSize <= aWholeSize)	&&
		(aLocation < aWholeSize)			){
		canGetInstance = YES;
	} else {
		DLog (@"----- start %d, byte num %d, whole size %d", (int)aLocation, (int)aSize, (int)aWholeSize)
		DLog (@"Stop reading data")
	}

	return canGetInstance;
}

+ (BOOL) exceedDataLengthForInstanceOfSize: (NSInteger) aSize location: (NSInteger) aLocation dataSize: (NSInteger) aWholeSize previousResult: (BOOL) aIsPreviousPass {
	BOOL canGetInstance = NO;
	if (aIsPreviousPass) {
		canGetInstance = [PrefUtils exceedDataLengthForInstanceOfSize:aSize location:aLocation aWholeSize:aWholeSize];
	}
	return canGetInstance;
}

@end
