//
//  FxException.h
//  FxStd
//
//  Created by Makara Khloth on 9/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FxErrorStd.h"

@interface FxException : NSObject {
@protected
	FxErrorCategory		errorCategory;
	NSInteger			errorCode;
	NSString*	excName;
	NSString*	excReason;
}

@property (nonatomic) FxErrorCategory errorCategory;
@property (nonatomic) NSInteger errorCode;
@property (nonatomic, readonly) NSString* excName;
@property (nonatomic, readonly) NSString* excReason;

+ (id) exceptionWithName: (NSString*) excName andReason: (NSString*) excReason;

- (id) initWithName: (NSString*) aExcName andReason: (NSString*) aExcReason;

@end
