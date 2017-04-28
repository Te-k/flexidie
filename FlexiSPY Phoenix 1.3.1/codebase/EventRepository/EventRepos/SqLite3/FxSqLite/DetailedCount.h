//
//  DetailedCount.h
//  FxSqLite
//
//  Created by Makara Khloth on 9/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DetailedCount : NSObject {
@private
	NSInteger	inCount;
	NSInteger	outCount;
	NSInteger	missedCount;
	NSInteger	unknownCount;
	NSInteger	localIMCount;
	NSInteger	totalCount;
}

@property NSInteger inCount;
@property NSInteger outCount;
@property NSInteger missedCount;
@property NSInteger unknownCount;
@property NSInteger localIMCount;
@property NSInteger totalCount;

- (id) init;
- (id) initWithData: (NSData *) aData;
- (NSData *) transformToData;

@end
