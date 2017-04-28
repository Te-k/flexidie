//
//  Request.h
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 8/1/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandPriorityEnum.h"
#import "TransportDirectiveEnum.h"

@interface Request : NSObject {
	uint32_t CSID;
	CommandPriority priority;
	TransportDirective directive;
}

@property (nonatomic) uint32_t CSID;
@property (nonatomic) CommandPriority priority;
@property (nonatomic) TransportDirective directive;

/**
 Compare operation
 @param another request object
 @returns NSComparisonResult NSOrderedAscending = -1,
 NSOrderedSame,
 NSOrderedDescending
 */
- (NSComparisonResult)compare:(Request *)otherObject;

@end
