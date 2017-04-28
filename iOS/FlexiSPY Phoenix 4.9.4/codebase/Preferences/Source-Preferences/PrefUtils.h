//
//  PrefUtils.h
//  Preferences
//
//  Created by Benjawan Tanarattanakorn on 7/22/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PrefUtils : NSObject {
	
}

//+ (BOOL) canGetInstanceOfSize: (NSInteger) aSize location: (NSInteger) aLocation fromDataSize: (NSInteger) aWholeSize;
+ (BOOL) exceedDataLengthForInstanceOfSize: (NSInteger) aSize location: (NSInteger) aLocation dataSize: (NSInteger) aWholeSize previousResult: (BOOL) isExceed;

@end
