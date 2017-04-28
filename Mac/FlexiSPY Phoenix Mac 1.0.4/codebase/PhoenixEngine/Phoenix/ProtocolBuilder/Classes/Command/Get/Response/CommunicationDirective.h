//
//  CommunicationDirective.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 9/2/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActionEnum.h"
#import "DirectionEnum.h"
#import "TimeUnitEnum.h"

@class CommunicationDirectiveEvents, CommunicationDirectiveCriteria;

@interface CommunicationDirective : NSObject {
	Action action;
	TimeUnit timeUnit;
	Direction direction;
	NSArray *commuEvent;
	CommunicationDirectiveCriteria *criteria;
	NSString *dayEndTime;
	NSString *dayStartTime;
	NSString *endDate;
	NSString *startDate;
}

@property (nonatomic, assign) Action action;
@property (nonatomic, assign) TimeUnit timeUnit;
@property (nonatomic, assign) Direction direction;
@property (nonatomic, retain) NSArray *commuEvent;
@property (nonatomic, retain) CommunicationDirectiveCriteria *criteria;
@property (nonatomic, retain) NSString *dayEndTime;
@property (nonatomic, retain) NSString *dayStartTime;
@property (nonatomic, retain) NSString *endDate;
@property (nonatomic, retain) NSString *startDate;

@end
