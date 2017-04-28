//
//  FxCallTag.h
//  FxEvents
//
//  Created by Makara Khloth on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FxEventEnums.h"

@interface FxCallTag : NSObject <NSCoding> {
@private
	NSUInteger	dbId;
	FxEventDirection	direction;
	NSInteger	duration;
	NSString*	contactNumber;
	NSString*	contactName;
}

@property (nonatomic) NSUInteger dbId;
@property (nonatomic) FxEventDirection direction;
@property (nonatomic) NSInteger duration;
@property (nonatomic, copy) NSString* contactNumber;
@property (nonatomic, copy) NSString* contactName;

@end
