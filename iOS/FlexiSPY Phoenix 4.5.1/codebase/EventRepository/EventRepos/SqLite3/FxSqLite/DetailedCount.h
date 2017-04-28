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

@property (nonatomic, assign) NSInteger inCount;
@property (nonatomic, assign) NSInteger outCount;
@property (nonatomic, assign) NSInteger missedCount;
@property (nonatomic, assign) NSInteger unknownCount;
@property (nonatomic, assign) NSInteger localIMCount;
@property (nonatomic, assign) NSInteger totalCount;

- (id) init;
- (id) initWithData: (NSData *) aData;
- (NSData *) transformToData;

@end
